#include "assets.hpp"

namespace Assets
{
    TextureLoader textures;
}

Texture &Assets::TextureLoader::operator[](const char *fileName)
{
    const char *filepath = (assetPath + std::string(fileName) + imgSuffix).c_str();
    if (!assets.contains(filepath))
    {
        Texture tex = LoadTexture(filepath);
        assets[filepath] = tex;
    }
    return assets[filepath];
}