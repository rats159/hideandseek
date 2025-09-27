#include "game.hpp"
#include "scenes.hpp"
#include "clay.hpp"

Game::Game() : window(1280, 720)
{
    currentScene = new MainMenuScene();

    UI::loadFont("./assets/NotoSans-Regular.ttf", 64);
}

void Game::quit(void)
{
    running = false;
}

void Game::run(void)
{
    while (!WindowShouldClose() && running)
    {
        this->currentScene->tick(this);
        clay.update();
        clay.beginLayout();
        BeginDrawing();
        ClearBackground(WHITE);
        this->currentScene->draw(this);
        Clay_RenderCommandArray commands = clay.endLayout();
        UI::render(commands);
        EndDrawing();

        if (nextScene != nullptr)
        {
            currentScene->~Scene();
            currentScene = nextScene;
            nextScene = nullptr;
        }
    }
}