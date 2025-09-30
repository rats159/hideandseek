#pragma once

#include <iostream>
#include <memory>
#include <fstream>

class Reader
{
private:
    std::istream& stream;
public:
    Reader(std::istream& str) : stream(str){}

    template<typename T>
    T readRaw()
    {
        T value;
        stream.read((char *)(&value), sizeof(T));
        return value;
    }
};
