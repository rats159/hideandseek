package main

import clay "../libs/clay-odin"
import "ui"
import rl "vendor:raylib"

Scene :: struct {
	destroy: proc(self: ^Scene),
	draw:    proc(scene: ^Scene, game: ^Game),
	tick:    proc(scene: ^Scene, game: ^Game),
}

MainMenuScene :: struct {
	using _: Scene,
}

main_menu_scene_make :: proc() -> ^Scene {
	scene := new(MainMenuScene)

	scene.draw = main_menu_draw

	return scene
}

main_menu_draw :: proc(scene: ^Scene, game: ^Game) {
	if clay.UI()(
	{
		layout = {
			sizing = {width = clay.SizingGrow(), height = clay.SizingGrow()},
			childAlignment = {.Center, .Center},
			layoutDirection = .TopToBottom,
		},
		backgroundColor = {128, 192, 255, 255},
	},
	) {
		ui.centeredText(
			"Hide & Seek!",
			clay.TextConfig({textColor = {0, 0, 0, 255}, fontSize = 48}),
		)
		ui.vGap(20)
		if clay.UI()({layout = {layoutDirection = .TopToBottom, childGap = 10}}) {
			if (ui.button("Play!")) {
				change_scene(game, server_picker_scene_make())
			}
			when DEVTOOLS {
				if (ui.button("Dev Tools!")) {
					change_scene(game, dev_tools_scene_make())
				}
			}
			if (ui.button("Quit!")) {
				quit(game)

			}
		}
	}
}
