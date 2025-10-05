package main

import "core:math"
import "core:strings"
import "core:sync"
import "core:time"
import rl "vendor:raylib"


PLAYER_SPRITES := [?]cstring{"player0", "player1", "player2", "player3"}

Network_Player :: struct {
	id:            u64,
	position:      [2]f32,
	next_position: [2]f32,
	sprite:        rl.Texture,
	username:      string,
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

draw_network_player :: proc(game: ^Game, plr: Network_Player, tick_delta: f32) {
	pos := math.lerp(plr.position, plr.next_position, tick_delta)

	rl.DrawTextureV(
		plr.sprite,
		pos - {f32(plr.sprite.width), f32(plr.sprite.height)} / 2,
		rl.WHITE,
	)
	username := strings.clone_to_cstring(plr.username, context.temp_allocator)
	font := game.ui_data.fonts[1]
	font_size := rl.MeasureTextEx(font, username, 32, 0)
	rl.DrawTextEx(font, username, {pos.x - font_size.x/2, pos.y - font_size.y - f32(plr.sprite.height / 2)}, 32, 0, rl.WHITE)
}

get_player_sprite :: proc(id: u64) -> rl.Texture {
	return get_texture(PLAYER_SPRITES[id % len(PLAYER_SPRITES)])
}

make_player :: proc(id: u64) -> Player {
	return {speed = 200, sprite = get_player_sprite(id)}
}
