#pragma once

#include <raylib.h>
#include <unordered_map>
#include <string>

namespace Assets
{
    // Asset lazy loader
    //   Assets are never destroyed automatically (sorry).
    //   They live as long as the program in most cases,
    //   but a scene can choose to unload certain assets.
    template <typename T>
    class AssetLoader
    {
    public:
        virtual T &operator[](const char *filepath) = 0;

    protected:
        const std::string assetPath = "assets/";
        std::unordered_map<std::string, T> assets;
    };

    class TextureLoader : public AssetLoader<Texture>
    {
    public:
        virtual Texture &operator[](const char *fileName) override;

    protected:
        const std::string imgSuffix = ".png";
    };

    extern TextureLoader textures;
}