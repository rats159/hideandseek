#pragma once
#include <clay.h>
#include <raylib.h>
#include <algorithm>
#include <vector>

// All my components are in here.
// UI is done using Clay because I like it.
// The class is static, I'm not sure if it would be better to use namespaced functions instead?
class UI
{
public:
    static std::vector<Font> fonts;

    static bool button(const char *label);
    static void centeredText(const char *label, Clay_TextElementConfig* config);
    static void vGap(float size);

    // Borrowed and slightly modified from Clay's example raylib measure text function
    //   https://github.com/nicbarker/clay/blob/main/renderers/raylib/clay_renderer_raylib.c#L84
    //
    // Clay will only call this function on individual lines, so newlines don't need handling
    static Clay_Dimensions measureText(Clay_StringSlice text, Clay_TextElementConfig *config, void *userData);


    static void render(Clay_RenderCommandArray commands);

    static void loadFont(const char* filepath, int size);
};