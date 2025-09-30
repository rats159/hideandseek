#pragma once
#include <cstdint>

#include "serializer.hpp"

enum class ColliderType : uint8_t
{
    CollisionBox,
    TagBox,
    MAX
};

class Collider : public Serializer<Collider>
{
public:
    ColliderType type;
    int x1;
    int y1;
    int x2;
    int y2;

    void write(Writer writer) override;
    Collider read(Reader writer) override;

#ifdef DEVTOOLS
    void randomize() override;
#endif
};
