#include "clay.hpp"
#include <raylib.h>
#include <iostream>

ClayInstance::ClayInstance()
{
    uint32_t minMemory = Clay_MinMemorySize();
    arena = Clay_CreateArenaWithCapacityAndMemory(minMemory, malloc(minMemory));
    // Lambdas are neat but the syntax is pretty ugly
    Clay_Initialize(arena,
                    {
                        (float)(GetScreenWidth()),
                        (float)(GetScreenHeight()),
                    },
                    {
                        .errorHandlerFunction = [](Clay_ErrorData errorData)
                        {
                            std::cerr << "Clay error:" << errorData.errorText.chars << "\n";
                        },
                    });
}

ClayInstance::~ClayInstance()
{
    free(arena.memory);
}

void ClayInstance::beginLayout()
{
    Clay_BeginLayout();
}

void ClayInstance::update()
{
    Clay_SetLayoutDimensions({(float)GetScreenWidth(),
                              (float)GetScreenHeight()});
    Vector2 mousePos = GetMousePosition();
    // For some reason C can't auto cast between two different
    //   structs that are the exact same? That's not C++ though,
    //   so I guess I can't complain about it too much
    Clay_SetPointerState(
        {mousePos.x, mousePos.y},
        IsMouseButtonDown(MOUSE_BUTTON_LEFT));
}

Clay_RenderCommandArray ClayInstance::endLayout()
{
    return Clay_EndLayout();
}