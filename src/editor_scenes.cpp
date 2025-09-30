#ifdef DEVTOOLS
#include "editor_scenes.hpp"
#include "game.hpp"
#include "filedialog.hpp"
#include "collider.hpp"
#include <algorithm>

#include "serialization_test_scene.hpp"

// Editor scene defined in its own file since it has a lot of extra stuff

void DevToolsScene::draw(Game* game)
{
    CLAY_AUTO_ID({
                 .layout = {
                 .sizing = {
                 .width = CLAY_SIZING_GROW(),
                 .height = CLAY_SIZING_GROW(),
                 },
                     .childGap = 10,
                 .childAlignment = {
                 CLAY_ALIGN_X_CENTER,
                 CLAY_ALIGN_Y_CENTER,
                 },
                 .layoutDirection = CLAY_TOP_TO_BOTTOM,
                 },
                 .backgroundColor = {255, 255, 255, 255}
                 })
    {
        if (UI::button("Edit a sprite's collision!"))
        {
            game->changeScene<SpriteEditorScene>();
        }
        if (UI::button("Test serialization!"))
        {
            game->changeScene<SerializationTestScene>();
        }
        if (UI::button("Back"))
        {
            game->changeScene<MainMenuScene>();
        }
    }
}

SpriteEditorScene::SpriteEditorScene()
{
    Image img = GenImageColor(16, 16,BLANK);
    baseTex = LoadTextureFromImage(img);
    camera = {
        .offset = {
            (float)GetScreenWidth() / 2,
            (float)GetScreenHeight() / 2,
        },
        .target = {0, 0},
        .rotation = 0,
        .zoom = 1
    };
    UnloadImage(img);
}

SpriteEditorScene::~SpriteEditorScene()
{
    UnloadTexture(baseTex);
}

// Colliders are drawn at full res,
//   just translated and scaled to fit the viewport
void SpriteEditorScene::drawCollider(Collider* col)
{
    Vector2 xy1 = GetWorldToScreen2D({(float)col->x1, (float)col->y1}, camera);
    Vector2 xy2 = GetWorldToScreen2D({(float)col->x2, (float)col->y2}, camera);

    Rectangle colliderRec = {
        xy1.x, xy1.y, xy2.x - xy1.x, xy2.y - xy1.y,
    };
    Color colliderColor = {0, 255, 0, 64};
    Color tagboxColor = {255, 0, 0, 64};
    Color color = col->type == ColliderType::CollisionBox ? colliderColor : tagboxColor;
    DrawRectangleRec(colliderRec, color);

    if (CheckCollisionPointRec(GetMousePosition(), colliderRec))
    {
        if (IsMouseButtonPressed(MOUSE_BUTTON_MIDDLE))
        {
            for (size_t i = 0; i < colliders.size(); i++)
            {
                if (&colliders[i] == col)
                {
                    colliders[i] = colliders.back();
                    colliders.pop_back();
                    return;
                }
            }
        }
        if (IsMouseButtonPressed(MOUSE_BUTTON_RIGHT))
        {
            col->type = (ColliderType)(((int)col->type + 1) % (2));
        }
    }

    float pixel = camera.zoom;

    Vector2 LEFT = {xy1.x, (xy1.y + xy2.y) / 2};
    Vector2 RIGHT = {xy2.x, (xy1.y + xy2.y) / 2};
    Vector2 TOP = {(xy1.x + xy2.x) / 2, xy1.y};
    Vector2 BOTTOM = {(xy1.x + xy2.x) / 2, xy2.y};

    float longAxis = pixel * 4;
    float shortAxis = pixel;

    Rectangle LEFT_REC = {LEFT.x - shortAxis * 0.5f, LEFT.y - longAxis * 0.5f, shortAxis, longAxis};
    Rectangle RIGHT_REC = {RIGHT.x - shortAxis * 0.5f, RIGHT.y - longAxis * 0.5f, shortAxis, longAxis};
    Rectangle TOP_REC = {TOP.x - longAxis * 0.5f, TOP.y - shortAxis * 0.5f, longAxis, shortAxis};
    Rectangle BOTTOM_REC = {BOTTOM.x - longAxis * 0.5f, BOTTOM.y - shortAxis * 0.5f, longAxis, shortAxis};


    Color hoverColor = {color.r, color.g, color.b, 255};
    Color inactiveColor = {
        (uint8_t)(std::max(int(color.r) - 20, 0)),
        (uint8_t)(std::max(int(color.g) - 20, 0)),
        (uint8_t)(std::max(int(color.b) - 20, 0)),
        255
    };

    if (CheckCollisionPointRec(GetMousePosition(), LEFT_REC))
    {
        DrawRectangleRec(LEFT_REC, hoverColor);
        if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT))
        {
            dragCallback = [col, this](Vector2 pos)
            {
                col->x1 = (int)GetScreenToWorld2D(pos, camera).x;
            };
        }
    }
    else
    {
        DrawRectangleRec(LEFT_REC, inactiveColor);
    }

    if (CheckCollisionPointRec(GetMousePosition(), RIGHT_REC))
    {
        DrawRectangleRec(RIGHT_REC, hoverColor);
        if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT))
        {
            dragCallback = [col, this](Vector2 pos)
            {
                col->x2 = (int)GetScreenToWorld2D(pos, camera).x;
            };
        }
    }
    else
    {
        DrawRectangleRec(RIGHT_REC, inactiveColor);
    }
    if (CheckCollisionPointRec(GetMousePosition(), TOP_REC))
    {
        DrawRectangleRec(TOP_REC, hoverColor);
        if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT))
        {
            dragCallback = [col, this](Vector2 pos)
            {
                col->y1 = (int)GetScreenToWorld2D(pos, camera).y;
            };
        }
    }
    else
    {
        DrawRectangleRec(TOP_REC, inactiveColor);
    }
    if (CheckCollisionPointRec(GetMousePosition(), BOTTOM_REC))
    {
        DrawRectangleRec(BOTTOM_REC, hoverColor);
        if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT))
        {
            dragCallback = [col, this](Vector2 pos)
            {
                col->y2 = (int)GetScreenToWorld2D(pos, camera).y;
            };
        }
    }
    else
    {
        DrawRectangleRec(BOTTOM_REC, inactiveColor);
    }
}

void SpriteEditorScene::draw(Game* game)
{
    CLAY_AUTO_ID({.layout = {
                 .layoutDirection = CLAY_TOP_TO_BOTTOM, }})
    {
        CLAY_AUTO_ID({.layout = {
            .childGap = 4}})
        {
            if (UI::button("New", {
                               .textColor = {0, 0, 0, 255},
                               .fontSize = 18
                           }))
            {
                // Not sure if it's worth using std::string here since it's just going to get c_str'd for raylib
                std::optional<std::string> optionalFile = FileDialog::open("Select a sprite image", "*.png");
                if (optionalFile.has_value())
                {
                    const std::string& file = optionalFile.value();
                    UnloadTexture(baseTex);
                    baseTex = LoadTexture(file.c_str());
                }
            }
            if (UI::button("Open", {
                               .textColor = {0, 0, 0, 255},
                               .fontSize = 18
                           }))
            {
                std::cerr << "Not yet implemented!\n";
            }
            if (UI::button("Back", {
                               .textColor = {0, 0, 0, 255},
                               .fontSize = 18
                           }))
            {
                game->changeScene<DevToolsScene>();
            }
            CLAY_AUTO_ID({
                         .floating = {
                         .attachPoints = {
                         CLAY_ATTACH_POINT_RIGHT_TOP,
                         CLAY_ATTACH_POINT_RIGHT_TOP,
                         },
                         .attachTo = CLAY_ATTACH_TO_ROOT,
                         }
                         })
            {
                if (UI::button("Save", {
                                   .textColor = {0, 0, 0, 255},
                                   .fontSize = 18
                               }))
                {
                    std::cerr << "Not yet implemented!\n";
                }
            }
        }
        CLAY_AUTO_ID({
                     .layout = { .layoutDirection = CLAY_TOP_TO_BOTTOM},
                     .floating = {
                     .attachPoints = {
                     CLAY_ATTACH_POINT_LEFT_BOTTOM,
                     CLAY_ATTACH_POINT_LEFT_BOTTOM,
                     },
                     .attachTo = CLAY_ATTACH_TO_ROOT,
                     }})
        {
            if (UI::button("New Collider"))
            {
                Collider collider{};
                collider.x2 = baseTex.width;
                collider.y2 = baseTex.height;
                colliders.push_back(collider);
            }
        }
    }


    BeginMode2D(camera);
    DrawTexture(baseTex, 0, 0,WHITE);
    EndMode2D();
    for (size_t i = 0; i < colliders.size(); i++)
    {
        drawCollider(&colliders[i]);
    }
}

void SpriteEditorScene::tick(Game* game)
{
    if (dragCallback != nullptr)
    {
        dragCallback(GetMousePosition());

        if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT))
        {
            dragCallback = nullptr;
        }
    }
    if (IsMouseButtonDown(MOUSE_BUTTON_LEFT) && dragCallback == nullptr)
    {
        camera.target -= GetMouseDelta() / camera.zoom;
    }

    float scrollDelta = GetMouseWheelMove();
    if (scrollDelta != 0)
    {
        if (scrollDelta > 0)
            camera.zoom *= 1.1;
        else
            camera.zoom /= 1.1;
        camera.zoom = std::clamp(camera.zoom, 0.05f, 16.f);
    }
}

#endif
