# A sane way of building. Change the command if you aren't on windows
# See why-i-didn't-use-cmake.txt for why this is my choice

CC := "g++"

build:
    {{CC}} src/*.cpp -o out/hideandseek -Lvendor -Ivendor -lraylib -lglfw3 -lgdi32 -lwinmm -std=c++20 -Wall -Werror

run: build
    @out/hideandseek