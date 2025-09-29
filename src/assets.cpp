#include "assets.hpp"

namespace Assets
{
    TextureLoader textures;
}

Texture &Assets::TextureLoader::operator[](const char *fileName)
{
    std::string fullPath = assetPath + std::string(fileName) + imgSuffix;

    if (!assets.contains(fullPath)) {
        Texture tex = LoadTexture(fullPath.c_str());
        assets[fullPath] = tex;
    }

    return assets[fullPath];
}