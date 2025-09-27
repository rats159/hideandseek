#pragma once

#include <initializer_list>
#include "biterator.hpp"
#include <cstdint>
#include <type_traits>
#include <cassert>

// This class is a mess, it didn't work for a long time
//   This and "biterator.hpp" are probably the two most 
//   confusing classes in this project so far
template <typename E>
class Bitset
{
    static_assert(std::is_enum<E>::value, "E must be an enum type");
    static_assert(sizeof(E) <= sizeof(uint64_t), "Enum size exceeds 64 bits");

    uint64_t value = 0;

public:
    Bitset(std::initializer_list<E> values)
    {
        for (E val : values)
        {
            *this += val;
        }
    }

    Bitset() = default;

    Bitset<E> &operator+=(E val)
    {
        this->value |= (1 << (int)val);
        return *this;
    }

    Bitset<E> &operator+=(Bitset<E> &other)
    {
        this->value |= other.value;
        return *this;
    }

    bool operator[](E val)
    {
        return (value >> (int)val) & 1;
    }

    bool operator>=(Bitset<E> &other)
    {
        return (this->value & other.value) == other.value;
    }

    Biterator<E> begin()
    {
        for (int i = 0; i < 64; i++)
        {
            if ((value >> i) & 1)
            {
                return Biterator<E>(this, i);
            }
        }
        return end();
    }

    Biterator<E> end()
    {
        return Biterator<E>(this, 64);
    }
};
