#include "scenes.hpp"
#include "game.hpp"

void MainMenuScene::draw(Game *game)
{

    CLAY_AUTO_ID({
        .layout = {
            .sizing = {
                .width = CLAY_SIZING_GROW(0),
                .height = CLAY_SIZING_GROW(0),
            },
            .childAlignment = {CLAY_ALIGN_X_CENTER, CLAY_ALIGN_Y_CENTER},
            .layoutDirection = CLAY_TOP_TO_BOTTOM},
        .backgroundColor = {0, 0, 0, 255},
    })
    {
        UI::centeredText("Hide & Seek!", CLAY_TEXT_CONFIG({.textColor = {255, 255, 255, 255},
                                                           .fontSize = 32}));
        if (UI::button("Play!"))
        {
            game->changeScene<GameScene>();
        }
        if (UI::button("Quit!"))
        {
            game->quit();
        }
    };
    DrawFPS(0, 0);
}

void GameScene::draw(Game *game)
{
    CLAY_AUTO_ID({
        .layout = {
            .sizing = {
                .width = CLAY_SIZING_GROW(0),
                .height = CLAY_SIZING_GROW(0),
            },
            .childAlignment = {CLAY_ALIGN_X_CENTER, CLAY_ALIGN_Y_CENTER},
            .layoutDirection = CLAY_TOP_TO_BOTTOM},
        .backgroundColor = {0, 0, 0, 255},
    })
    {
        std::cout<<"Drawing Game scene!\n";
        UI::centeredText("Game Scene!", CLAY_TEXT_CONFIG({
                                            .textColor = {255, 255, 255, 255},
                                            .fontId = 0,
                                            .fontSize = 64,
                                        }));
    }
}