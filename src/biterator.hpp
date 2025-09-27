#pragma once

#include <iostream>

template <typename E>
class Bitset;

template <typename E>
class Biterator
{
public:
    Biterator(Bitset<E> *set, int index) : index(index), set(set) {}

    E operator*() const
    {
        return (E)index;
    }

    Biterator<E> &operator++()
    {
        do
        {
            index++;
            if (index >= 64)
            {          
                break; 
            }
        } while (!(*set)[(E)index]);
        return *this;
    }

    // Comparison operator
    bool operator!=(const Biterator<E> &other) const
    {
        return index != other.index;
    }

private:
    int index;
    Bitset<E> *set;
};