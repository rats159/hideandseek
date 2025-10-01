package main

import clay "../libs/clay-odin"
import "core:fmt"
import "ui"
import rl "vendor:raylib"

when DEVTOOLS {

	DevToolsScene :: struct {
		using _: Scene,
	}

	SpriteEditorScene :: struct {
		using _:      Scene,
		dragCallback: proc(scene: ^SpriteEditorScene, mousePos: rl.Vector2, data: rawptr),
		dragUserdata: rawptr,
		baseTex:      rl.Texture,
		camera:       rl.Camera2D,
		colliders:    [dynamic]Collider,
	}

	dev_tools_scene_make :: proc() -> ^Scene {
		scene := new(DevToolsScene)

		scene.draw = dev_tools_scene_draw
		scene.destroy = generic_scene_destroy

		return scene
	}

	dev_tools_scene_draw :: proc(scene: ^Scene, game: ^Game) {
		if clay.UI()(
		{
			layout = {
				sizing = {width = clay.SizingGrow(), height = clay.SizingGrow()},
				childGap = 10,
				childAlignment = {.Center, .Center},
				layoutDirection = .TopToBottom,
			},
			backgroundColor = {255, 255, 255, 255},
		},
		) {
			if (ui.button("Edit a sprite's collision!")) {
				change_scene(game, sprite_editor_scene_make())
			}
			if (ui.button("Test serialization!")) {
				change_scene(game, serialization_test_scene_make())
			}
			if (ui.button("Back")) {
				change_scene(game, main_menu_scene_make())
			}
		}
	}

	sprite_editor_scene_make :: proc() -> ^Scene {
		scene := new(SpriteEditorScene)
		img := rl.GenImageColor(16, 16, rl.BLANK)
		scene.baseTex = rl.LoadTextureFromImage(img)
		scene.camera = {
			offset   = {(f32)(rl.GetScreenWidth()) / 2, (f32)(rl.GetScreenHeight()) / 2},
			target   = {0, 0},
			rotation = 0,
			zoom     = 1,
		}
		rl.UnloadImage(img)

		scene.draw = sprite_editor_scene_draw
		scene.destroy = sprite_editor_scene_destroy
		scene.tick = sprite_editor_scene_tick

		return scene
	}

	sprite_editor_scene_destroy :: proc(scene: ^Scene) {
		generic_scene_destroy(scene)
		rl.UnloadTexture((^SpriteEditorScene)(scene).baseTex)
	}

	// Colliders are drawn at full res,
	//   just translated and scaled to fit the viewport
	drawCollider :: proc(scene: ^Scene, col: ^Collider) {
		scene := (^SpriteEditorScene)(scene)
		xy1 := rl.GetWorldToScreen2D({(f32)(col.x1), (f32)(col.y1)}, scene.camera)
		xy2 := rl.GetWorldToScreen2D({(f32)(col.x2), (f32)(col.y2)}, scene.camera)

		colliderRec := rl.Rectangle{xy1.x, xy1.y, xy2.x - xy1.x, xy2.y - xy1.y}
		colliderColor := rl.Color{0, 255, 0, 64}
		tagboxColor := rl.Color{255, 0, 0, 64}
		color := col.type == .CollisionBox ? colliderColor : tagboxColor
		rl.DrawRectangleRec(colliderRec, color)

		if (rl.CheckCollisionPointRec(rl.GetMousePosition(), colliderRec)) {
			if (rl.IsMouseButtonPressed(.MIDDLE)) {
				for i := 0; i < len(scene.colliders); i += 1 {
					if (&scene.colliders[i] == col) {
						unordered_remove(&scene.colliders, i)
						return
					}
				}
			}
			if (rl.IsMouseButtonPressed(.RIGHT)) {
				col.type = (ColliderType)(((int)(col.type) + 1) % (2))
			}
		}

		pixel := scene.camera.zoom

		LEFT := rl.Vector2{xy1.x, (xy1.y + xy2.y) / 2}
		RIGHT := rl.Vector2{xy2.x, (xy1.y + xy2.y) / 2}
		TOP := rl.Vector2{(xy1.x + xy2.x) / 2, xy1.y}
		BOTTOM := rl.Vector2{(xy1.x + xy2.x) / 2, xy2.y}

		longAxis := pixel * 4
		shortAxis := pixel

		LEFT_REC := rl.Rectangle {
			LEFT.x - shortAxis * 0.5,
			LEFT.y - longAxis * 0.5,
			shortAxis,
			longAxis,
		}
		RIGHT_REC := rl.Rectangle {
			RIGHT.x - shortAxis * 0.5,
			RIGHT.y - longAxis * 0.5,
			shortAxis,
			longAxis,
		}
		TOP_REC := rl.Rectangle {
			TOP.x - longAxis * 0.5,
			TOP.y - shortAxis * 0.5,
			longAxis,
			shortAxis,
		}
		BOTTOM_REC := rl.Rectangle {
			BOTTOM.x - longAxis * 0.5,
			BOTTOM.y - shortAxis * 0.5,
			longAxis,
			shortAxis,
		}


		hoverColor := rl.Color{color.r, color.g, color.b, 255}
		inactiveColor := rl.Color {
			(u8)(max(int(color.r) - 20, 0)),
			(u8)(max(int(color.g) - 20, 0)),
			(u8)(max(int(color.b) - 20, 0)),
			255,
		}

		if (rl.CheckCollisionPointRec(rl.GetMousePosition(), LEFT_REC)) {
			rl.DrawRectangleRec(LEFT_REC, hoverColor)
			if (rl.IsMouseButtonPressed(.LEFT)) {
				scene.dragUserdata = col
				scene.dragCallback =
				proc(scene: ^SpriteEditorScene, pos: rl.Vector2, data: rawptr) {
					col := (^Collider)(data)
					col.x1 = (int)(rl.GetScreenToWorld2D(pos, scene.camera).x)
				}
			}
		} else {
			rl.DrawRectangleRec(LEFT_REC, inactiveColor)
		}

		if (rl.CheckCollisionPointRec(rl.GetMousePosition(), RIGHT_REC)) {
			rl.DrawRectangleRec(RIGHT_REC, hoverColor)
			if (rl.IsMouseButtonPressed(.LEFT)) {
				scene.dragUserdata = col
				scene.dragCallback =
				proc(scene: ^SpriteEditorScene, pos: rl.Vector2, data: rawptr) {
					col := (^Collider)(data)
					col.x2 = (int)(rl.GetScreenToWorld2D(pos, scene.camera).x)
				}
			}
		} else {
			rl.DrawRectangleRec(RIGHT_REC, inactiveColor)
		}
		if (rl.CheckCollisionPointRec(rl.GetMousePosition(), TOP_REC)) {
			rl.DrawRectangleRec(TOP_REC, hoverColor)
			if (rl.IsMouseButtonPressed(.LEFT)) {
				scene.dragUserdata = col
				scene.dragCallback =
				proc(scene: ^SpriteEditorScene, pos: rl.Vector2, data: rawptr) {
					col := (^Collider)(data)
					col.y1 = (int)(rl.GetScreenToWorld2D(pos, scene.camera).y)
				}
			}
		} else {
			rl.DrawRectangleRec(TOP_REC, inactiveColor)
		}
		if (rl.CheckCollisionPointRec(rl.GetMousePosition(), BOTTOM_REC)) {
			rl.DrawRectangleRec(BOTTOM_REC, hoverColor)
			if (rl.IsMouseButtonPressed(.LEFT)) {
				scene.dragUserdata = col
				scene.dragCallback =
				proc(scene: ^SpriteEditorScene, pos: rl.Vector2, data: rawptr) {
					col := (^Collider)(data)
					col.y2 = (int)(rl.GetScreenToWorld2D(pos, scene.camera).y)
				}
			}
		} else {
			rl.DrawRectangleRec(BOTTOM_REC, inactiveColor)
		}
	}

	sprite_editor_scene_draw :: proc(scene: ^Scene, game: ^Game) {
		scene := (^SpriteEditorScene)(scene)
		if clay.UI()({layout = {layoutDirection = .TopToBottom}}) {
			if clay.UI()({layout = {childGap = 4}}) {
				if (ui.button("New", {textColor = {0, 0, 0, 255}, fontSize = 18})) {
					optionalFile := open_file_dialog("Select a sprite image", "*.png")
					if file, ok := optionalFile.?; ok {
						rl.UnloadTexture(scene.baseTex)
						scene.baseTex = rl.LoadTexture(file)
					}
				}
				if (ui.button("Open", {textColor = {0, 0, 0, 255}, fontSize = 18})) {
					fmt.eprintln("Not yet implemented!")
				}
				if (ui.button("Back", {textColor = {0, 0, 0, 255}, fontSize = 18})) {
					change_scene(game, dev_tools_scene_make())
				}
				if clay.UI()(
				{floating = {attachment = {.RightTop, .RightTop}, attachTo = .Root}},
				) {
					if (ui.button("Save", {textColor = {0, 0, 0, 255}, fontSize = 18})) {
						fmt.eprintln("Not yet implemented!")
					}
				}
			}
			if clay.UI()(
			{
				layout = {layoutDirection = .TopToBottom},
				floating = {attachment = {.LeftBottom, .LeftBottom}, attachTo = .Root},
			},
			) {
				if (ui.button("New Collider")) {
					collider: Collider
					collider.x2 = int(scene.baseTex.width)
					collider.y2 = int(scene.baseTex.height)
					append(&scene.colliders, collider)
				}
			}
		}


		rl.BeginMode2D(scene.camera)
		rl.DrawTexture(scene.baseTex, 0, 0, rl.WHITE)
		rl.EndMode2D()
		for i := 0; i < len(scene.colliders); i += 1 {
			drawCollider(scene, &scene.colliders[i])
		}
	}

	sprite_editor_scene_tick :: proc(scene: ^Scene, game: ^Game) {
		scene := (^SpriteEditorScene)(scene)
		if (scene.dragCallback != nil) {
			scene.dragCallback(scene, rl.GetMousePosition(), scene.dragUserdata)

			if (rl.IsMouseButtonReleased(.LEFT)) {
				scene.dragCallback = nil
				scene.dragUserdata = nil
			}
		}
		if (rl.IsMouseButtonDown(.LEFT) && scene.dragCallback == nil) {
			scene.camera.target -= rl.GetMouseDelta() / scene.camera.zoom
		}

		scrollDelta := rl.GetMouseWheelMove()
		if (scrollDelta != 0) {
			if (scrollDelta > 0) {
				scene.camera.zoom *= 1.1} else {
				scene.camera.zoom /= 1.1}
			scene.camera.zoom = clamp(scene.camera.zoom, 0.05, 16)
		}
	}
}
