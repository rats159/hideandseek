#include <iostream>
#include <raylib.h>

#include "game.hpp"

int main()
{
    // I really think it's gross that this is running code since it's just a declaration
    //   but i guess that's just c++
    Game game;

    game.run();

    // I think this is optional, but why not just let main be void?
    return 0;
}