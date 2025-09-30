#pragma once
#include <cstdint>
#include <iostream>
#include <memory>

#include "serializer.hpp"

// Ignores endianness because idk how c++ handles  that
class Writer
{
public:
    std::ostream& buffer;
    Writer(std::ostream& stream): buffer(stream) {}

    void writeDirect(void* data, size_t size);
    void write(int8_t num);
    void write(uint8_t num);
    void write(int16_t num);
    void write(uint16_t num);
    void write(int32_t num);
    void write(uint32_t num);
    void write(int64_t num);
    void write(uint64_t num);
    template <class T>
    void write(Serializer<T>* serializer);
};
