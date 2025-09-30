#pragma once
#ifdef DEVTOOLS
#include "scenes.hpp"
#include <sstream>

class SerializationTestScene : public Scene
{
private:
    std::stringstream log;
public:
    SerializationTestScene();
    void draw(Game* game) override;
};
#endif