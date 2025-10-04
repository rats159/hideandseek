package main

import "core:math/rand"
import "core:sync"
import rl "vendor:raylib"

Entity :: struct {
	id:         u64,
	mutex:      sync.Mutex,
	components: bit_set[Component],
	position:   rl.Vector2,
	speed:      f32,
	velocity:   rl.Vector2,
	sprite:     rl.Texture,
}

make_entity :: proc() -> Entity {
	return {id = rand.uint64()}
}

make_player :: proc() -> Entity {
	plr := make_entity()
	plr.components += PLAYER_COMPONENTS
	plr.sprite = get_texture("player")
	plr.speed = 200
	plr.position = {0, 0}
	return plr
}
