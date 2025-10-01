package main

import rl "vendor:raylib"

init_window :: proc(width, height: i32) {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(width, height, "Hide and Seek!")
}

close_window :: proc() {
	rl.CloseWindow()
}
