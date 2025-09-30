#pragma once
#ifdef DEVTOOLS
#include "scenes.hpp"
#include <raylib.h>
#include <vector>
#include "collider.hpp"
#include <functional>

class DevToolsScene : public Scene {
    virtual void draw(Game *game) override;
};

class SpriteEditorScene : public Scene {
public:
    SpriteEditorScene();
    ~SpriteEditorScene();
    void drawCollider(Collider* col);
    std::function<void(Vector2 mousePos)> dragCallback= nullptr;

private:
    Texture baseTex{};
    Camera2D camera{};
    std::vector<Collider> colliders;
    virtual void draw(Game *game) override;
    virtual void tick(Game *game) override;
};
#endif