package main
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

ASSET_PATH :: "./assets/"
IMAGE_SUFFIX :: ".png"

@(private)
textures: map[string]rl.Texture

get_texture :: proc(fileName: cstring) -> rl.Texture {
	fullPath := fmt.ctprintf("%s%s%s", ASSET_PATH, fileName, IMAGE_SUFFIX)
	strPath := string(fullPath)

	if (strPath not_in textures) {
		tex := rl.LoadTexture(fullPath)
		textures[strings.clone(strPath)] = tex
		return tex
	}

	return textures[strPath]
}

cleanup_assets :: proc() {
	for str, texture in textures {
		delete(str)
		rl.UnloadTexture(texture)
	}

	delete(textures)
}
