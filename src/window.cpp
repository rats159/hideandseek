#include "window.hpp"
#include <raylib.h>

Window::Window(int width, int height)
{
    SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT);
    InitWindow(width, height, "Hide and Seek!");
}

Window::~Window()
{
    CloseWindow();
}