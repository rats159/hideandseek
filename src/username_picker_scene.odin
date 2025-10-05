package main

import clay "../libs/clay-odin"
import "common"
import "core:encoding/cbor"
import "core:fmt"
import "core:strings"
import "core:text/edit"
import "core:time"
import "ui"
import enet "vendor:ENet"
import rl "vendor:raylib"

Username_Picker_Scene :: struct {
	using _:      Scene,
	builder:      strings.Builder,
	editor_state: edit.State,
	network_data: Network_Data,
}

username_picker_scene_make :: proc(network_data: Network_Data) -> ^Scene {
	scene := new(Username_Picker_Scene)

	scene.draw = username_picker_scene_draw
	scene.tick = username_picker_scene_tick
	scene.destroy = username_picker_scene_destroy

	scene.network_data = network_data

	edit.init(&scene.editor_state, context.allocator, context.allocator, max(time.Duration))
	scene.editor_state.builder = &scene.builder

	return scene
}

username_picker_scene_draw :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Username_Picker_Scene)(scene)

	if clay.UI()(
	{
		layout = {
			sizing = {clay.SizingGrow(), clay.SizingGrow()},
			childAlignment = {.Center, .Center},
		},
	},
	) {
		if clay.UI()({layout = {layoutDirection = .TopToBottom}}) {
			ui.centeredText(
				"Enter your username:",
				clay.TextConfig({fontId = 0, fontSize = 32, textColor = {0, 0, 0, 255}}),
			)
			if clay.UI()(
			{
				layout = {padding = clay.PaddingAll(8)},
				border = {width = clay.BorderOutside(2), color = {0, 0, 0, 255}},
			},
			) {
				ui.text_input(
					&scene.editor_state,
					clay.TextConfig({fontId = 1, fontSize = 32, textColor = {0, 0, 0, 255}}),
				)
			}
		}
	}
}

username_picker_scene_destroy :: proc(scene: ^Scene) {
	scene := (^Username_Picker_Scene)(scene)

	strings.builder_destroy(&scene.builder)
	edit.destroy(&scene.editor_state)
}

username_picker_scene_tick :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Username_Picker_Scene)(scene)

	network_data := &scene.network_data
	event: enet.Event

	for enet.host_service(network_data.client, &event, 0) > 0 {
		#partial switch event.type {
		case .RECEIVE:
			{
				packet: common.S2CPacket
				_ = cbor.unmarshal_from_bytes(
					event.packet.data[:event.packet.dataLength],
					&packet,
					allocator = context.temp_allocator,
				)

				#partial switch type in packet {
				case common.AssignIDPacket:
					network_data.id = type.id
				case common.UsernameReceivedPacket:
					if type.result == .All_Good {
						change_scene(
							game,
							game_scene_make(scene.network_data, strings.clone(type.value)),
						)
					} else {
						ui.open_modal(
							{
								title = strings.clone("Username not accepted by server"),
								body = fmt.aprint("Reason:", type.result),
							},
							&game.ui_data,
						)
					}
				case common.Join_Packet,
				     common.Update_All_Positions_Packet,
				     common.SetUsernamePacket:
				// ignore
				case:
					fmt.panicf("Unexpected packet: %v", type)
				}
			}
		}
	}

	if rl.IsKeyPressed(.ENTER) {
		str := strings.to_string(scene.builder)
		send_packet(network_data.peer, common.SetUsernamePacket{network_data.id, str})
		edit.clear_all(&scene.editor_state)
	}
}
