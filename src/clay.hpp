#pragma once

#include <clay.h>
#include <optional>
#include <vector>
#include <cmath>

// Wrapper over Clay's global stuff because C++.
class ClayInstance
{
public:
    ClayInstance()
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
                                std::cout << "Clay error:" << errorData.errorText.chars << "\n";
                            },
                        });
    }
    ~ClayInstance()
    {
        free(arena.memory);
    }

    void beginLayout()
    {
        Clay_BeginLayout();
    }

    void update() {
        Clay_SetLayoutDimensions({
            (float)GetScreenWidth(),
            (float)GetScreenHeight()
        });
        Vector2 mousePos = GetMousePosition();
        // For some reason C can't auto cast between two different
        //   structs that are the exact same? That's not C++ though,
        //   so I guess I can't complain about it too much
        Clay_SetPointerState(
            {mousePos.x, mousePos.y},
            IsMouseButtonDown(MOUSE_BUTTON_LEFT)
        );
    }

    Clay_RenderCommandArray endLayout()
    {
        return Clay_EndLayout();
    }


private:
    Clay_Arena arena;
    std::vector<Font> fonts;
};