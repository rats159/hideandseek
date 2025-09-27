#pragma once

#include "entity.hpp"

// I think a namespace here is better than a class with all static members?
namespace Player {
    void tick(Entity &player);
}