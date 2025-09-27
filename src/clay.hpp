#pragma once

#include <clay.h>
#include <optional>
#include <vector>
#include <cmath>
#include <raylib.h>

// Wrapper over Clay's global stuff because C++.
class ClayInstance
{
public:
    ClayInstance();
    
    ~ClayInstance();

    void update();

    void beginLayout();


    Clay_RenderCommandArray endLayout();


private:
    Clay_Arena arena;
    std::vector<Font> fonts;
};