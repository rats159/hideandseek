#pragma once

#include "raylib.h"

class Window {
    public:
        Window(int width, int height) {
            SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT);
            InitWindow(width, height, "Hide and Seek!");
        }

        // Does the publicity of a destructor matter?
        ~Window() {
            CloseWindow();
        }
};