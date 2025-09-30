#include "collider.hpp"

#include <cstdint>
#include <cstdlib>

#include "writer.hpp"

// I could use writeDirect, but i prefer to be more explitit
void Collider::write(Writer writer)
{
    writer.write((uint8_t)this->type);
    writer.write(x1);
    writer.write(y1);
    writer.write(x2);
    writer.write(y2);
}

Collider Collider::read(Reader reader)
{
    Collider collider;
    collider.type = reader.readRaw<ColliderType>();
    collider.x1 = reader.readRaw<int>();
    collider.y1 = reader.readRaw<int>();
    collider.x2 = reader.readRaw<int>();
    collider.y2 = reader.readRaw<int>();

    return collider;
}

#ifdef DEVTOOLS
void Collider::randomize()
{
    this->type = (ColliderType)(rand() % (int)ColliderType::MAX);
    this->x1 = rand();
    this->y1 = rand();
    this->x2 = rand();
    this->y2 = rand();
}
#endif
