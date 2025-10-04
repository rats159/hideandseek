package main

import clay "../libs/clay-odin"
import "core:fmt"
import "core:math"
import "core:mem"
import "core:net"
import "core:strings"
import "core:text/edit"
import "core:time"
import "core:unicode/utf8"
import "ui"
import rl "vendor:raylib"

Server_Picker_Scene :: struct {
	using _:        Scene,
	address_input:  edit.State,
	address_buffer: strings.Builder,
}

server_picker_scene_destroy :: proc(scene: ^Scene) {
	generic_scene_destroy(scene)

	scene := (^Server_Picker_Scene)(scene)

	edit.destroy(&scene.address_input)
	strings.builder_destroy(&scene.address_buffer)
	
}

server_picker_scene_make :: proc() -> ^Scene {
	scene := new(Server_Picker_Scene)

	scene.destroy = server_picker_scene_destroy
	scene.draw = server_picker_scene_draw
	scene.tick = nil

	edit.init(&scene.address_input, context.allocator, context.allocator, max(time.Duration))
	scene.address_input.builder = &scene.address_buffer
	return scene
}

server_picker_scene_draw :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Server_Picker_Scene)(scene)

	if clay.UI()(
	{
		layout = {
			sizing = {clay.SizingGrow(), clay.SizingGrow()},
			childAlignment = {.Center, .Center},
			layoutDirection = .TopToBottom,
		},
		backgroundColor = {255, 255, 255, 255},
	},
	) {
		str := strings.to_string(scene.address_buffer)
        color: = clay.Color{0, 0, 0, 255}
        ip, parsing_error := net.parse_hostname_or_endpoint(str)
		if parsing_error != nil {
            color = {255, 0, 0, 255}
		}

		clay.Text("IP Address", clay.TextConfig({textColor = {0, 0, 0, 255}, fontSize = 32}))

		if clay.UI()({
            layout = {
                layoutDirection = .TopToBottom,
                childGap = 8
            }
        }) {

			if clay.UI()(
			{
				layout = {
					sizing = {width = clay.SizingGrow()},
					padding = clay.PaddingAll(8),
				},
				border = {width = clay.BorderOutside(2), color = {0, 0, 0, 255}},
			},
			) {
				ui.text_input(
					&scene.address_input,
					clay.TextConfig({fontId = 1, fontSize = 32, textColor = color}),
				)
			}

			if clay.UI()({layout = {childGap = 8, sizing = {width = clay.SizingGrow()}}}) {
				if ui.button("Connect!") || rl.IsKeyPressed(.ENTER) {
                    if parsing_error != nil {
                        ui.open_modal({
                            title = strings.clone("Invalid IP Address!")
                        },&game.ui_data)
                    } else {
                        change_scene(game, connection_scene_make(strings.clone(str), game))
                    }
                }
                ui.hGrow()
				if ui.button("Back") {
                    change_scene(game, main_menu_scene_make())
                }
			}
		}


	}
}
