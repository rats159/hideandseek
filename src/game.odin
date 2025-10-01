package main

import clay "../libs/clay-odin"
import "ui"
import rl "vendor:raylib"

Game :: struct {
	running:       bool,
	current_scene: ^Scene,
	next_scene:    ^Scene,
}

init_clay :: proc() {
	min_mem := uint(clay.MinMemorySize())
	arena := clay.CreateArenaWithCapacityAndMemory(min_mem, make([^]u8, min_mem))
	clay.Initialize(arena, {f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}, {})
}

init_game :: proc(game: ^Game) {
	init_window(1280, 720)
	init_clay()
	game.running = true
	game.current_scene = main_menu_scene_make()
    ui.loadFont("./assets/NotoSans-Regular.ttf", 64);
    ui.loadFont("./assets/JetBrainsMonoNL-Regular.ttf", 64);
}

change_scene :: proc(game: ^Game, scene: ^Scene) {
	game.next_scene = scene
}

quit :: proc(game: ^Game) {
	game.running = false
}

update_clay :: proc() {
    clay.SetLayoutDimensions({(f32)(rl.GetScreenWidth()),
                              (f32)(rl.GetScreenHeight())});
    clay.SetPointerState(
        rl.GetMousePosition(),
        rl.IsMouseButtonDown(.LEFT));
}

run_game :: proc(game: ^Game) {
	for (!rl.WindowShouldClose() && game.running) {
		if (game.current_scene.tick != nil) {
			game.current_scene->tick(game)
		}
		update_clay()
		clay.BeginLayout()
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		game.current_scene->draw(game)
		commands := clay.EndLayout()
		ui.clay_raylib_render(&commands, ui.fonts)
		rl.EndDrawing()

		if (game.next_scene != nil) {
			game.current_scene->destroy()
			game.current_scene = game.next_scene
			game.next_scene = nil
		}
	}
}
