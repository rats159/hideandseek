package main
import "core:fmt"
import rl "vendor:raylib"

ASSET_PATH :: "./assets/"
IMAGE_SUFFIX :: ".png"

@(private)
textures: map[string]rl.Texture

get_texture :: proc(fileName: cstring) -> rl.Texture {

	fullPath := fmt.ctprintf("%s%s%s", ASSET_PATH, fileName, IMAGE_SUFFIX)
	strPath := string(fullPath)

    fmt.println("LOADING TEXTURE",strPath)

	if (strPath not_in textures) {
		tex := rl.LoadTexture(fullPath)
		textures[strPath] = tex
	}

	return textures[strPath]
}
