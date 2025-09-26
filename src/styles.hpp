#pragma once

#include "clay.h"

// Is this a good use of namespaces?
//   there's some weird rules around static consts in classes and stuff,
//   so this seemed like a better idea
namespace DefaultStyles
{
    static Clay_TextElementConfig buttonText{
        .textColor = {255, 255, 255, 255},
        .fontId = 0,
        .fontSize = 32,
    };
};