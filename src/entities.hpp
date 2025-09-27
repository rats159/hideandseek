#pragma once

#include "bitset.hpp"
#include "components.hpp"

// I really don't know why I can't put this stuff inside the Entity class but that's fine I guess
namespace Entities
{
    extern Bitset<Components> PLAYER_COMPONENTS;
}