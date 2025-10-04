package main

import clay "../libs/clay-odin"
import "common"
import "core:encoding/cbor"
import "core:fmt"
import "core:net"
import "core:strings"
import "core:text/edit"
import "core:time"
import "ui"
import enet "vendor:ENet"
import rl "vendor:raylib"

Game_Scene :: struct {
	using _:      Scene,
	network_data: Network_Data,
	username:     string,
	builder:      strings.Builder,
	state:        edit.State,
}

game_scene_destroy :: proc(scene: ^Scene) {
	generic_scene_destroy(scene)

	scene := (^Game_Scene)(scene)

	strings.builder_destroy(&scene.builder)
	delete(scene.username)

	edit.destroy(&scene.state)
}

game_scene_make :: proc(network_data: Network_Data) -> ^Scene {
	scene := new(Game_Scene)

	scene.draw = game_scene_draw
	scene.destroy = game_scene_destroy

	edit.init(&scene.state, context.allocator, context.allocator, max(time.Duration))
	scene.state.builder = &scene.builder
	scene.network_data = network_data

	return scene
}

game_scene_tick :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Game_Scene)(scene)

	network_data := &scene.network_data
	event: enet.Event

	for enet.host_service(network_data.client, &event, 0) > 0 {
		#partial switch event.type {
		case .RECEIVE:
			{
				packet: common.S2CPacket
				_ = cbor.unmarshal_from_bytes(event.packet.data[:event.packet.dataLength], &packet)

				switch type in packet {
				case common.AssignIDPacket:
					network_data.id = type.id
				}

				fmt.println(packet)
			}
		}
	}

	if rl.IsKeyPressed(.ENTER) {
		str := strings.to_string(scene.builder)
		if scene.username == {} {
			send_packet(network_data.peer, common.SetUsernamePacket{network_data.id, str})
			scene.username = strings.clone(str)
		} else {
			send_packet(network_data.peer, common.MessagePacket{network_data.id, str})
		}
		edit.clear_all(&scene.state)
	}
}

game_scene_draw :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Game_Scene)(scene)

	ui.text_input(
		&scene.state,
		clay.TextConfig({fontId = 1, fontSize = 32, textColor = {0, 0, 0, 255}}),
	)
}

send_packet :: proc(to: ^enet.Peer, data: common.C2SPacket) {
	message, _ := cbor.marshal_into_bytes(data)
	packet := enet.packet_create(raw_data(message), uint(len(message)), {.RELIABLE})
	enet.peer_send(to, 0, packet)
	delete(message)
}
