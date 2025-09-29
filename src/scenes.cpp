#include "scenes.hpp"
#include "game.hpp"
#include "bitset.hpp"
#include "player.hpp"
#include "editor_scenes.hpp"

void MainMenuScene::draw(Game *game)
{

    CLAY_AUTO_ID({
        .layout = {
            .sizing = {
                .width = CLAY_SIZING_GROW(0),
                .height = CLAY_SIZING_GROW(0),
            },
            .childGap = 10,
            .childAlignment = {CLAY_ALIGN_X_CENTER, CLAY_ALIGN_Y_CENTER},
            .layoutDirection = CLAY_TOP_TO_BOTTOM},
        .backgroundColor = {128, 192, 255, 255},
    })
    {
        UI::centeredText("Hide & Seek!", CLAY_TEXT_CONFIG({
                                             .textColor = {0, 0, 0, 255},
                                             .fontSize = 48,
                                         }));
        UI::vGap(20);
        if (UI::button("Play!"))
        {
            game->changeScene<GameScene>();
        }
#ifdef EDITOR
        if (UI::button("Editor!"))
        {
            game->changeScene<BaseEditorScene>();
        }
#endif
        if (UI::button("Quit!"))
        {
            game->quit();
        }
    };
    DrawFPS(0, 0);
}

GameScene::GameScene()
{
    entities.push_back(Entity::player());
}

void GameScene::tick(Game *game)
{
    for (Entity &ent : entities)
    {
        if (ent.components >= Entities::PLAYER_COMPONENTS)
        {
            Player::tick(ent);
        }
    }
}

void GameScene::draw(Game *game)
{
    ClearBackground(BLACK);
    for (Entity &ent : entities)
    {
        if (ent.components[Components::SPRITE])
        {
            DrawTexture(ent.sprite, ent.position.x, ent.position.y, WHITE);
        }
    }
    CLAY_AUTO_ID({
        .layout = {
            .sizing = {
                .width = CLAY_SIZING_GROW(0),
                .height = CLAY_SIZING_GROW(0),
            },
            .childAlignment = {CLAY_ALIGN_X_CENTER, CLAY_ALIGN_Y_CENTER},
            .layoutDirection = CLAY_TOP_TO_BOTTOM},
    })
    {
        UI::centeredText("Game Scene!", CLAY_TEXT_CONFIG({
                                            .textColor = {255, 255, 255, 255},
                                            .fontId = 0,
                                            .fontSize = 64,
                                        }));
    }
}