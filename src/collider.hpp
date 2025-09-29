#pragma once

enum class ColliderType
{
    CollisionBox,
    TagBox,
    MAX
};

class Collider
{
public:
    ColliderType type;
    int x1;
    int y1;
    int x2;
    int y2;
};


