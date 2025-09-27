#pragma once

#include "raylib.h"

class Window {
    public:
        Window(int width, int height);

        // Does the publicity of a destructor matter?
        ~Window();
};