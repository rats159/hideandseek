#pragma once
#include <iostream>

#include "reader.hpp"

class Writer;

// Robust serialization is very hard,
//   but I know my own use cases, so it's a lot easier

// class Foo : Serializer<Foo>
// or
// class FooWriter : Serializer<Foo>
template<typename T>
class Serializer
{
public:
    virtual void write(Writer writer) = 0;
    virtual T read(Reader reader) = 0; // I don't think there's static inheritance so just do `Foo f = Foo{}.read()` i guess
#ifdef DEVTOOLS
    virtual void randomize() = 0;
    #endif
};