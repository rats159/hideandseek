#pragma once // Why this and not a standard include guard?

#include <iostream>
#include "ui.hpp"

// I think i have to forward declare this :(
class Game;

class Scene {
    // = 0 is strange, but i suppose you'd need some special syntax to differentiate it from a function signature.
    //   Still, I prefer java's dedicated `abstract` keyword
    public:
        virtual ~Scene(){};
        virtual void draw(Game* game) = 0;
};

// It seems like this class is implicitly abstract since it's inheriting a "pure virtual" method.
//   That seems like a huge way to get hidden errors, and I'd prefer c++ explicitly requiring me to redeclare it as abstract if I wanted it to be.
class MainMenuScene : public Scene {
    public:
        MainMenuScene() {

        }

        ~MainMenuScene() {
            std::cout << "No more main menu scene!";
        }

    public:
        // It seems like override is an optional keyword, which is weird.
        //   Also why is it there and not at the start?
        virtual void draw(Game* game) override;
};

class GameScene : public Scene {
    public:
            virtual void draw(Game* game) override;

        ~GameScene() {
            std::cout << "No more GameScene!";
        }
        };