package main

import clay "../libs/clay-odin"
import "ui"
import rl "vendor:raylib"

Scene :: struct {
	entities: [dynamic]Entity,
	destroy:  proc(self: ^Scene),
	draw:     proc(scene: ^Scene, game: ^Game),
	tick:     proc(scene: ^Scene, game: ^Game),
}

MainMenuScene :: struct {
	using _: Scene,
}

GameScene :: struct {
	using _: Scene,
}

generic_scene_destroy :: proc(scene: ^Scene) {
	delete(scene.entities)
}

game_scene_make :: proc() -> ^Scene {
	scene := new(GameScene)

	scene.draw = game_scene_draw
	scene.tick = game_scene_tick
	scene.destroy = generic_scene_destroy

	append(&scene.entities, make_player())

	return scene
}

main_menu_scene_make :: proc() -> ^Scene {
	scene := new(MainMenuScene)

	scene.draw = main_menu_draw
	scene.destroy = generic_scene_destroy


	return scene
}

main_menu_draw :: proc(scene: ^Scene, game: ^Game) {
	if clay.UI()(
	{
		layout = {
			sizing = {width = clay.SizingGrow(), height = clay.SizingGrow()},
			childGap = 10,
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
		if (ui.button("Play!")) {
			change_scene(game, game_scene_make())
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

game_scene_tick :: proc(scene: ^Scene, game: ^Game) {
	for &ent in scene.entities {
		if (ent.components >= PLAYER_COMPONENTS) {
			tick_player(&ent)
		}
	}
}

game_scene_draw :: proc(scene: ^Scene, game: ^Game) {
	rl.ClearBackground(rl.BLACK)
	for &ent in scene.entities {
		if .SPRITE in ent.components {
			rl.DrawTexture(ent.sprite, i32(ent.position.x), i32(ent.position.y), rl.WHITE)
		}
	}
	if clay.UI()(
	{
		layout = {
			sizing = {width = clay.SizingGrow(), height = clay.SizingGrow()},
			childAlignment = {.Center, .Center},
			layoutDirection = .TopToBottom,
		},
	},
	) {
		ui.centeredText(
			"Game Scene!",
			clay.TextConfig({textColor = {255, 255, 255, 255}, fontId = 0, fontSize = 64}),
		)
	}
}
