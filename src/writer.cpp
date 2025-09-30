#include "writer.hpp"

#include "serializer.hpp"

void Writer::writeDirect(void* data, size_t size)
{
    for (size_t i = 0; i < size; i++)
    {
        buffer.put(((uint8_t*)data)[i]);
    }
}

#define VALUE_WRITER(type) void Writer::write(type val) \
{                                                        \
    writeDirect(&val, sizeof(type));                     \
}

VALUE_WRITER(int8_t)
VALUE_WRITER(uint8_t)
VALUE_WRITER(int16_t)
VALUE_WRITER(uint16_t)
VALUE_WRITER(int32_t)
VALUE_WRITER(uint32_t)
VALUE_WRITER(int64_t)
VALUE_WRITER(uint64_t)

template <typename T>
void Writer::write(Serializer<T> *serializer)
{
    serializer->write(this);
}