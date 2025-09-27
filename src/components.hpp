#pragma once

#include "bitset.hpp"

// Components don't actually store any data.
//   All actual data is stored inside the entity,
//   components just specify which data is used.

// Some components are "decorative", like PLAYER_CONTROLLED,
//   which maps to no data
enum class Components {
    POSITION,
    PLAYER_CONTROLLED,
    SPRITE,
};
