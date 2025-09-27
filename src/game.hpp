#pragma once
#include "window.hpp"
#include <memory>
#include "scenes.hpp"
#include "clay.hpp"

class Game
{
    // So why does c++ use these blocks for visibility?
    //   Is it for enforcing some amount of organization, or is there a better reason?
private:
    // I'm not sure if Window should be a separate class, since raylib makes most window stuff global anyways
    Window window;

    bool running = true;

    ClayInstance clay;

    // I've heard "raw" pointers are discouraged in c++, but I don't know how else I'd represent this?
    //   Since it's subtype polymorphism, the actual size is unknown, right?
    //   Also, wouldn't this force dynamic dispatch? That's unfortunate
    //
    // I considered having scenes be an enum, or maybe a union, but I don't know.
    //   Enums are what I would usually use, but a class felt more "correct" for c++
    Scene *currentScene;
    Scene *nextScene = nullptr;

public:
    Game();

    ~Game()
    {
        // Is `delete` correct here? I assume delete will call the destructor and free the pointer
        delete currentScene;
    }

    // Is it standard to put multiple public/private blocks? It seems ugly forcing it all together
public:
    // When should/shouldn't a function be placed directly in the class's header?
    void run(void);

    void quit(void);

    // Weird idea I had to avoid calling all sorts of destructors and constructors moving the scene around.
    template<class T>
    void changeScene(void){
        // Manually calling this destructor is probably a red flag
        //   Maybe I should be using some special "box" type? 
        // Maybe this is a bad idea? I had some bugs with switching scenes mid-frame
        //   so this was my solution
        nextScene = new T();
    }
};