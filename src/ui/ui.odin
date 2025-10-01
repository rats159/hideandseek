package ui

import clay "../../libs/clay-odin"
import rl "vendor:raylib"

fonts: [dynamic]rl.Font

buttonColor :: proc() -> clay.Color
{
    if (clay.Hovered())
    {
        if (rl.IsMouseButtonPressed(.LEFT))
        {
            return {128, 128, 128, 255};
        }
        return {192, 192, 192, 255};
    }

    return {255, 255, 255, 255};
}

button :: proc(label: string, textConfig: clay.TextElementConfig = default_button_text) -> bool
{
    if clay.UI()({
        layout = {
            padding = {16, 16, 8, 8},
        },
        backgroundColor = buttonColor(),
        cornerRadius = clay.CornerRadiusAll(8),
        border = {
            color = {0, 0, 0, 255},
            width = clay.BorderOutside(2),
        }, 
    })
    {
        centeredText(label, clay.TextConfig(textConfig));
        if (clay.Hovered() && rl.IsMouseButtonReleased(.LEFT))
        {
            return true
        }
    }
    return false;
}

vGap :: proc(size: f32)
{
    if clay.UI()({layout = {
                      sizing = {
                          height = clay.SizingFixed(size)}}}){}
}

vGrow :: proc()
{
    clay.UI()({
        layout = {
            sizing = {
                height =  clay.SizingGrow()
            }
        }
    });
}

hGrow :: proc()
{
    clay.UI()({
        layout = {
            sizing = {
                width =  clay.SizingGrow()
            }
        }
    });
}

centeredText :: proc(label: string, config: ^clay.TextElementConfig)
{
    if clay.UI()({
        layout = {
            childAlignment = {
                x = .Center,
                y = .Center,
            }},
    })
    {
        clay.TextDynamic(label, config);
    };
}

loadFont :: proc(filepath: cstring, size: i32) -> u16
{
    font := rl.LoadFontEx(filepath, size, nil, 0);
    rl.SetTextureFilter(font.texture, .BILINEAR);
    append(&fonts, font);

    // Reset the function when we load a font
    //   1. This keeps the pointer valid in case of a resize
    //   2. This stops us from trying to measure text when we have no fonts loaded
    //      Clay will give us an error log if we try to measure without a function
    clay.SetMeasureTextFunction(measure_text, raw_data(fonts));

    return u16(len(fonts))
}