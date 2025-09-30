#ifdef DEVTOOLS
#include "serialization_test_scene.hpp"

#include "collider.hpp"
#include <sstream>
#include <cstdlib>
#include <iomanip>

#include "writer.hpp"
#include "reader.hpp"

template <typename T>
bool test(Writer& writer, Reader& reader, Writer& secondWriter, std::stringstream& firstStream,
          std::stringstream& secondStream)
{
    firstStream.clear();
    firstStream.seekp(0, std::ios::beg);
    firstStream.seekg(0, std::ios::beg);
    secondStream.clear();
    secondStream.seekp(0, std::ios::beg);
    secondStream.seekg(0, std::ios::beg);

    T first{};
    first.randomize();

    first.write(writer);
    T second = T{}.read(reader);
    second.write(secondWriter);

    firstStream.seekg(0, std::ios::beg);
    secondStream.seekg(0, std::ios::beg);

    char byte1;
    char byte2;
    while (firstStream.read(&byte1, 1), secondStream.read(&byte2, 1))
    {
        if (byte1 != byte2) return false;
    }

    if (!firstStream.eof() || !secondStream.eof()) return false;


    return true;
}

#define TEST(type) \
    log << "Testing type "#type":";\
    if (!test<type>(writer, reader, otherWriter, firstStream, secondStream)) \
         log << " Failed!\n"; \
    else log << " Passed!\n"; \

SerializationTestScene::SerializationTestScene()
{
    std::stringstream firstStream(std::ios::in | std::ios::out | std::ios::binary);
    std::stringstream secondStream(std::ios::in | std::ios::out | std::ios::binary);

    Writer writer(firstStream);
    Reader reader(firstStream);
    Writer otherWriter(secondStream);

    TEST(Collider);
}

void SerializationTestScene::draw(Game* game)
{
    ClearBackground(WHITE);
    std::string str = log.str();
    Clay_String claystr = {
        .isStaticallyAllocated = false,
        .length = (int32_t)str.size(),
        .chars = str.data(),
    };
    CLAY_TEXT(claystr, CLAY_TEXT_CONFIG({
                  .textColor = {0,0,0, 255},
                  .fontId = 0,
                  .fontSize = 24,
                  }));
}
#endif
