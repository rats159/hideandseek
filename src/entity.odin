package main 

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

Entity:: struct
{
    id: u64,
    components: bit_set[Component],

    position: rl.Vector2,
    speed: f32,
    velocity: rl.Vector2,
    sprite: rl.Texture,

};

make_entity :: proc() -> Entity {
    return {
        id = rand.uint64()
    }
}

make_player :: proc() -> Entity {
    fmt.println("MAKIGN PLAYER")
    plr := make_entity()
    plr.components += PLAYER_COMPONENTS;
    plr.sprite = get_texture("player")//Assets::textures["player"];
    plr.speed = 200;
    plr.position = {0, 0};
    return plr;
}
// Entity Entity::player()
// {

// }