package main

import rl "vendor:raylib"

PLAYER_COMPONENTS :: bit_set[Component]{.PLAYER_CONTROLLED, .SPRITE, .POSITION}

tick_player :: proc(plr: ^Entity) {
	//TODO: keyboard abstraction layer?

	movement: rl.Vector2

	if (rl.IsKeyDown(.W)) {
		movement.y -= 1
	}
	if (rl.IsKeyDown(.S)) {
		movement.y += 1
	}
	if (rl.IsKeyDown(.A)) {
		movement.x -= 1
	}
	if (rl.IsKeyDown(.D)) {
		movement.x += 1
	}

	if (rl.Vector2Length(movement) != 0) {
		movement = rl.Vector2Normalize(movement)
	}

	movement *= plr.speed * rl.GetFrameTime()

	plr.position += movement
}
