package main

import clay "../libs/clay-odin"
import "common"
import "core:encoding/cbor"
import "core:fmt"
import "core:net"
import "core:strings"
import "core:sync"
import "core:text/edit"
import "core:thread"
import "core:time"
import "ui"
import enet "vendor:ENet"
import rl "vendor:raylib"

Client :: struct {
	position: [2]f32,
}

Game_Scene :: struct {
	using _:       Scene,
	network_data:  Network_Data,
	username:      string,
	network_mutex: sync.Mutex,
	other_clients: map[u64]Client,
}

game_scene_destroy :: proc(scene: ^Scene) {
	generic_scene_destroy(scene)

	scene := (^Game_Scene)(scene)

	delete(scene.username)
}

game_scene_make :: proc(network_data: Network_Data, username: string) -> ^Scene {
	scene := new(Game_Scene)

	scene.draw = game_scene_draw
	scene.destroy = game_scene_destroy
	scene.tick = game_scene_tick

	scene.network_data = network_data

	append(&scene.entities, make_player())

	send_packet(network_data.peer, common.Whos_Here_Packet{})

	thread.create_and_start_with_poly_data(scene, proc(scene: ^Game_Scene) {
		for {
			start := time.tick_now()
			game_scene_network_tick(scene)

			sleep_time := time.tick_diff(time.tick_now(), time.tick_add(start, time.Second / 10))
			time.sleep(sleep_time)
		}
	})

	return scene
}

game_scene_network_tick :: proc(scene: ^Game_Scene) {
	player := scene.entities[0]
	assert(.PLAYER_CONTROLLED in player.components)

	sync.lock(&scene.network_mutex)
	sync.lock(&player.mutex)
	send_packet(
		scene.network_data.peer,
		common.Position_Update_Packet{scene.network_data.id, player.position},
	)

	send_packet(scene.network_data.peer, common.Request_Positions_Packet{})
	sync.unlock(&player.mutex)
	sync.unlock(&scene.network_mutex)
}

game_scene_tick :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Game_Scene)(scene)

	for &ent in scene.entities {
		if ent.components >= PLAYER_COMPONENTS {
			sync.lock(&ent.mutex)
			tick_player(&ent)
			sync.unlock(&ent.mutex)
		}
	}


	event: enet.Event

	for enet.host_service(scene.network_data.client, &event, 0) > 0 {
		#partial switch event.type {
		case .RECEIVE:
			packet: common.S2CPacket
			_ = cbor.unmarshal_from_bytes(event.packet.data[:event.packet.dataLength], &packet)
			handle_packet_receive(scene, packet)
		}
	}
}

handle_packet_receive :: proc(scene: ^Game_Scene, packet: common.S2CPacket) {
	#partial switch type in packet {
	case common.Update_All_Positions_Packet:
		for client in type.positions {
			if client.id == scene.network_data.id do continue
			assert(client.id in scene.other_clients)

			(&scene.other_clients[client.id]).position = client.position
		}
	case common.Join_Packet:
		for id in type.ids {
			if id == scene.network_data.id do continue

			assert(id not_in scene.other_clients)
			scene.other_clients[id] = {}
		}
	case:
		fmt.panicf("Unexpected packet: %s", packet)
	}
}

game_scene_draw :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Game_Scene)(scene)

	rl.ClearBackground(rl.BLACK)

	for &ent in scene.entities {
		if ent.components >= {.SPRITE, .POSITION} {
			rl.DrawTextureV(
				ent.sprite,
				ent.position - {f32(ent.sprite.width), f32(ent.sprite.height)} / 2,
				rl.WHITE,
			)
		}
	}

	for _, client in scene.other_clients {
		rl.DrawCircleV(client.position, 8, {0, 255, 0, 128})
	}
}

send_packet :: proc(to: ^enet.Peer, data: common.C2SPacket) {
	message, _ := cbor.marshal_into_bytes(data)
	packet := enet.packet_create(raw_data(message), uint(len(message)), {.RELIABLE})
	enet.peer_send(to, 0, packet)
	delete(message)
}
