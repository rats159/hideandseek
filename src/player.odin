package main

import rl "vendor:raylib"
import "core:sync"


PLAYER_SPRITES :: [?]string{
	"player0",
	"player1",
}

Player :: struct {
	position: [2]f32,
	speed:    f32,
	sprite:   rl.Texture,
	mutex:    sync.Mutex,
}


tick_player :: proc(plr: ^Player) {
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

draw_player :: proc(plr: Player) {
	rl.DrawTextureV(
		plr.sprite,
		plr.position - {f32(plr.sprite.width), f32(plr.sprite.height)} / 2,
		rl.WHITE,
	)
}

make_player :: proc() -> Player {
	return {speed = 200, sprite = get_texture("player")}
}
