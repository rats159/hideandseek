#include "entity.hpp"

Entity Entity::player()
{
    Entity plr;
    plr.components += Entities::PLAYER_COMPONENTS;
    plr.sprite = Assets::textures["player"];
    plr.speed = 200;
    plr.position = {0, 0};
    return plr;
}