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

Game_Scene :: struct {
	using _:       Scene,
	network_data:  Network_Data,
	username:      string,
	network_mutex: sync.Mutex,
	other_clients: map[u64]Network_Player,
	player:        Player,
	last_tick_at:  time.Tick,
}

game_scene_destroy :: proc(scene: ^Scene) {
	scene := (^Game_Scene)(scene)

	delete(scene.username)
}

game_scene_make :: proc(network_data: Network_Data, username: string) -> ^Scene {
	scene := new(Game_Scene)

	scene.draw = game_scene_draw
	scene.destroy = game_scene_destroy
	scene.tick = game_scene_tick

	scene.network_data = network_data

	scene.player = make_player(scene.network_data.id)

	send_packet(network_data.peer, common.Whos_Here_Packet{})

	thread.create_and_start_with_poly_data(scene, proc(scene: ^Game_Scene) {
		for {
			start := time.tick_now()
			game_scene_network_tick(scene)

			sleep_time := time.tick_diff(time.tick_now(), time.tick_add(start, common.TICK_RATE))
			time.sleep(sleep_time)
		}
	})

	return scene
}

game_scene_network_tick :: proc(scene: ^Game_Scene) {
	sync.lock(&scene.network_mutex)
	sync.lock(&scene.player.mutex)
	send_packet(
		scene.network_data.peer,
		common.Position_Update_Packet{scene.network_data.id, scene.player.position},
	)

	scene.last_tick_at = time.tick_now()
	sync.unlock(&scene.player.mutex)
	sync.unlock(&scene.network_mutex)
}

game_scene_tick :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Game_Scene)(scene)

	sync.lock(&scene.player.mutex)
	tick_player(&scene.player)
	sync.unlock(&scene.player.mutex)


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
			if client.id not_in scene.other_clients {
				fmt.printfln(
					"Unexpected: Tried to set position of id %016X, which wasn't in out connection list",
					client.id,
				)
				continue
			}

			local_client := &scene.other_clients[client.id]
			local_client.position = local_client.next_position
			local_client.next_position = client.position
		}
	case common.Join_Packet:
		for user in type.users {
			id := user.id
			username := user.message
			if id == scene.network_data.id do continue

			assert(id not_in scene.other_clients)
			scene.other_clients[id] = {
				id       = id,
				username = strings.clone(username),
				sprite   = get_player_sprite(id),
			}
		}
	case common.SetUsernamePacket:
		assert(type.id in scene.other_clients)
		(&scene.other_clients[type.id]).username = type.message
	case:
		fmt.panicf("Unexpected packet: %s", packet)
	}
}

game_scene_draw :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Game_Scene)(scene)

	rl.ClearBackground(rl.BLACK)

	draw_player(scene.player)

	sync.lock(&scene.network_mutex)
	tick_diff := time.tick_diff(scene.last_tick_at, time.tick_now())
	sync.unlock(&scene.network_mutex)

	tick_delta := f32(tick_diff) / f32(common.TICK_RATE)

	sync.lock(&scene.network_mutex)
	for _, &client in scene.other_clients {
		draw_network_player(game, client, tick_delta)
	}
	sync.unlock(&scene.network_mutex)

}

send_packet :: proc(to: ^enet.Peer, data: common.C2SPacket) {
	message, _ := cbor.marshal_into_bytes(data)
	packet := enet.packet_create(raw_data(message), uint(len(message)), {.RELIABLE})
	enet.peer_send(to, 0, packet)
	delete(message)
}
