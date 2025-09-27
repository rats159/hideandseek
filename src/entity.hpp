#pragma once

#include <vector>
#include "components.hpp"
#include "bitset.hpp"
#include "raylib.h"
#include "raymath.h" // Raymath actually defines math operations for raylib vector types in c++
#include "entities.hpp"
#include "assets.hpp"

// In some cases, I think it makes sense for UI to be an entity
//   But that doesn't seem super compatible with immediate mode,
//   and it seems like making connections that don't need to exist.

// This isn't a full ECS or anything, but there's a loose idea
//   of having components which specify what behavior you have

class Entity
{
public:
    uint64_t id;
    Bitset<Components> components;

    Vector2 position;
    float speed;
    Vector2 velocity;
    Texture sprite;

public:
    static Entity player();
};