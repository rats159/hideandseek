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

    // Borrowed and slightly modified from Clay's example raylib measure text function
    //   https://github.com/nicbarker/clay/blob/main/renderers/raylib/clay_renderer_raylib.c#L84
    //
    // Clay will only call this function on individual lines, so newlines don't need handling
    static Clay_Dimensions measureText(Clay_StringSlice text, Clay_TextElementConfig *config, void *userData)
    {
        float lineWidth = 0;

        float textHeight = config->fontSize;

        Font font = ((Font *)userData)[config->fontId];

        float scaleFactor = (float)config->fontSize / (float)font.baseSize;

        for (int i = 0; i < text.length; ++i)
        {
            int index = text.chars[i] - 32;
            if (font.glyphs[index].advanceX != 0)
            {
                lineWidth += font.glyphs[index].advanceX;
            }
            else
            {
                lineWidth += font.recs[index].width + font.glyphs[index].offsetX;
            }
        }


        return {lineWidth * scaleFactor, textHeight};
    }


    static void render(Clay_RenderCommandArray commands);

    static void loadFont(const char* filepath, int size) {
        Font font = LoadFontEx(filepath,size, nullptr, 0);
        SetTextureFilter(font.texture, TEXTURE_FILTER_BILINEAR);
        fonts.push_back(font);

        // Reset the function when we load a font
        //   1. This keeps the pointer valid in case of a resize
        //   2. This stops us from trying to measure text when we have no fonts loaded
        //      Clay will give us an error log if we try to measure without a function
        Clay_SetMeasureTextFunction(UI::measureText, fonts.data());
    }
};