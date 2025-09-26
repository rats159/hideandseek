// Clay is a single-header library, I'm throwing the implementation into this source file for simplicity
#define CLAY_IMPLEMENTATION
#include <clay.h>
#include <iostream>
#include <cmath>
#include "ui.hpp"
#include <cstring>
#include "styles.hpp"

#define CLAY_RECTANGLE_TO_RAYLIB_RECTANGLE(rectangle) \
    Rectangle { .x = rectangle.x, .y = rectangle.y, .width = rectangle.width, .height = rectangle.height }
#define CLAY_COLOR_TO_RAYLIB_COLOR(color) \
    Color { .r = (unsigned char)round(color.r), .g = (unsigned char)round(color.g), .b = (unsigned char)round(color.b), .a = (unsigned char)round(color.a) }

std::vector<Font> UI::fonts;

bool UI::button(const char *label)
{
    CLAY_AUTO_ID({
        .layout = {
            .padding = {16,16,8,8},
        },
        .backgroundColor = Clay_Hovered()? Clay_Color{128,0,0,255} :Clay_Color{255, 0, 0, 255},
        .cornerRadius = CLAY_CORNER_RADIUS(8)
    })
    {
        centeredText(label, &DefaultStyles::buttonText);
        if (Clay_Hovered() && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
            return true;
        }
    }
    return false;
}

void UI::centeredText(const char *label, Clay_TextElementConfig *config)
{
    CLAY_AUTO_ID({
        .layout = {
            .sizing = {
                .width = CLAY_SIZING_GROW(0),
                .height = CLAY_SIZING_GROW(0),
            },
            .childAlignment = {
                .x = CLAY_ALIGN_X_CENTER,
                .y = CLAY_ALIGN_Y_CENTER,
            }
        },
    })
    {
        Clay_String str = Clay_String{
            .isStaticallyAllocated = false,
            .length = (int)strlen(label), // Could probably avoid this, but I don't know how to do it in a nice way
            .chars = label,
        };
        CLAY_TEXT(str, config);
    };
}

// Slightly modified from https://github.com/nicbarker/clay/blob/main/renderers/raylib/clay_renderer_raylib.c
void UI::render(Clay_RenderCommandArray renderCommands)
{
    static std::vector<char> stringBuffer;
    for (int j = 0; j < renderCommands.length; j++)
    {
        Clay_RenderCommand *renderCommand = Clay_RenderCommandArray_Get(&renderCommands, j);
        Clay_BoundingBox boundingBox = {(float)round(renderCommand->boundingBox.x), (float)round(renderCommand->boundingBox.y), (float)round(renderCommand->boundingBox.width), (float)round(renderCommand->boundingBox.height)};
        switch (renderCommand->commandType)
        {
        case CLAY_RENDER_COMMAND_TYPE_TEXT:
        {
            Clay_TextRenderData *textData = &renderCommand->renderData.text;
            Font fontToUse = fonts[textData->fontId];

            stringBuffer.resize(textData->stringContents.length + 1);

            // Raylib uses standard C strings so isn't compatible with cheap slices, we need to clone the string to append null terminator
            memcpy(stringBuffer.data(), textData->stringContents.chars, textData->stringContents.length);
            stringBuffer[stringBuffer.size() - 1] = '\0';
            DrawTextEx(fontToUse, stringBuffer.data(), Vector2{boundingBox.x, boundingBox.y}, (float)textData->fontSize, (float)textData->letterSpacing, CLAY_COLOR_TO_RAYLIB_COLOR(textData->textColor));

            break;
        }
        case CLAY_RENDER_COMMAND_TYPE_IMAGE:
        {
            Texture2D imageTexture = *(Texture2D *)renderCommand->renderData.image.imageData;
            Clay_Color tintColor = renderCommand->renderData.image.backgroundColor;
            if (tintColor.r == 0 && tintColor.g == 0 && tintColor.b == 0 && tintColor.a == 0)
            {
                tintColor = Clay_Color{255, 255, 255, 255};
            }
            DrawTexturePro(
                imageTexture,
                Rectangle{0, 0, (float)imageTexture.width, (float)imageTexture.height},
                Rectangle{boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height},
                Vector2{},
                0,
                CLAY_COLOR_TO_RAYLIB_COLOR(tintColor));
            break;
        }
        case CLAY_RENDER_COMMAND_TYPE_SCISSOR_START:
        {
            BeginScissorMode((int)round(boundingBox.x), (int)round(boundingBox.y), (int)round(boundingBox.width), (int)round(boundingBox.height));
            break;
        }
        case CLAY_RENDER_COMMAND_TYPE_SCISSOR_END:
        {
            EndScissorMode();
            break;
        }
        case CLAY_RENDER_COMMAND_TYPE_RECTANGLE:
        {
            Clay_RectangleRenderData *config = &renderCommand->renderData.rectangle;
            if (config->cornerRadius.topLeft > 0)
            {
                float radius = (config->cornerRadius.topLeft * 2) / (float)((boundingBox.width > boundingBox.height) ? boundingBox.height : boundingBox.width);
                DrawRectangleRounded(Rectangle{boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height}, radius, 8, CLAY_COLOR_TO_RAYLIB_COLOR(config->backgroundColor));
            }
            else
            {
                DrawRectangle(boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height, CLAY_COLOR_TO_RAYLIB_COLOR(config->backgroundColor));
            }
            break;
        }
        case CLAY_RENDER_COMMAND_TYPE_BORDER:
        {
            Clay_BorderRenderData *config = &renderCommand->renderData.border;
            // Left border
            if (config->width.left > 0)
            {
                DrawRectangle((int)round(boundingBox.x), (int)round(boundingBox.y + config->cornerRadius.topLeft), (int)config->width.left, (int)round(boundingBox.height - config->cornerRadius.topLeft - config->cornerRadius.bottomLeft), CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            // Right border
            if (config->width.right > 0)
            {
                DrawRectangle((int)round(boundingBox.x + boundingBox.width - config->width.right), (int)round(boundingBox.y + config->cornerRadius.topRight), (int)config->width.right, (int)round(boundingBox.height - config->cornerRadius.topRight - config->cornerRadius.bottomRight), CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            // Top border
            if (config->width.top > 0)
            {
                DrawRectangle((int)round(boundingBox.x + config->cornerRadius.topLeft), (int)round(boundingBox.y), (int)round(boundingBox.width - config->cornerRadius.topLeft - config->cornerRadius.topRight), (int)config->width.top, CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            // Bottom border
            if (config->width.bottom > 0)
            {
                DrawRectangle((int)round(boundingBox.x + config->cornerRadius.bottomLeft), (int)round(boundingBox.y + boundingBox.height - config->width.bottom), (int)round(boundingBox.width - config->cornerRadius.bottomLeft - config->cornerRadius.bottomRight), (int)config->width.bottom, CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            if (config->cornerRadius.topLeft > 0)
            {
                DrawRing(Vector2{(float)round(boundingBox.x + config->cornerRadius.topLeft), (float)round(boundingBox.y + config->cornerRadius.topLeft)}, (float)round(config->cornerRadius.topLeft - config->width.top), config->cornerRadius.topLeft, 180, 270, 10, CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            if (config->cornerRadius.topRight > 0)
            {
                DrawRing(Vector2{(float)round(boundingBox.x + boundingBox.width - config->cornerRadius.topRight), (float)round(boundingBox.y + config->cornerRadius.topRight)}, (float)round(config->cornerRadius.topRight - config->width.top), config->cornerRadius.topRight, 270, 360, 10, CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            if (config->cornerRadius.bottomLeft > 0)
            {
                DrawRing(Vector2{(float)round(boundingBox.x + config->cornerRadius.bottomLeft), (float)round(boundingBox.y + boundingBox.height - config->cornerRadius.bottomLeft)}, (float)round(config->cornerRadius.bottomLeft - config->width.bottom), config->cornerRadius.bottomLeft, 90, 180, 10, CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            if (config->cornerRadius.bottomRight > 0)
            {
                DrawRing(Vector2{(float)round(boundingBox.x + boundingBox.width - config->cornerRadius.bottomRight), (float)round(boundingBox.y + boundingBox.height - config->cornerRadius.bottomRight)}, (float)round(config->cornerRadius.bottomRight - config->width.bottom), config->cornerRadius.bottomRight, 0.1, 90, 10, CLAY_COLOR_TO_RAYLIB_COLOR(config->color));
            }
            break;
        }
        case CLAY_RENDER_COMMAND_TYPE_CUSTOM:
        {
            break;
        }
        default:
        {
            std::cerr << "Error: unhandled render command.\n";
            exit(1);
        }
        }
    }
}
