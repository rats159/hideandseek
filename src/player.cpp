#include "player.hpp"
#include "entity.hpp"
#include <iostream>

namespace Player {
    void tick(Entity &entity){
        //TODO: keyboard abstraction layer?

        Vector2 movement{};

        if (IsKeyDown(KEY_W)) {
            movement.y -= 1;
        }
        if (IsKeyDown(KEY_S)) {
            movement.y += 1;
        }
        if (IsKeyDown(KEY_A)) {
            movement.x -= 1;
        }
        if (IsKeyDown(KEY_D)) {
            movement.x += 1;
        }

        if (Vector2Length(movement) != 0) {
            movement = Vector2Normalize(movement);
        }

        movement *= entity.speed * GetFrameTime();

        entity.position += movement;
        std::cout << entity.position.x << ' ' << entity.position.y << '\n';
    }
}