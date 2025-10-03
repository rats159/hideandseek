package ui

import clay "../../libs/clay-odin"
import "core:math"
import "core:strings"
import "core:text/edit"
import "core:time"
import rl "vendor:raylib"

text_input :: proc(state: ^edit.State, config: ^clay.TextElementConfig) {
	text_input_tick(state)
	str := strings.to_string(state.builder^)
	if clay.UI()({layout = {sizing = {height = clay.SizingFixed(f32(config.fontSize))}}}) {
		clay.TextDynamic(str, config)

		selection_left_idx := state.selection[0]
		selection_right_idx := state.selection[1]

		selection_left_offset: f32
		selection_right_offset: f32
		if clay.UI()(
		{
			floating = {
				attachTo = .Parent,
				zIndex   = -999, // Just for text measurement
			},
		},
		) {
			measurement_config := config^
			measurement_config.textColor = {0, 0, 0, 0} // Transparent so it's culled
			if clay.UI(clay.ID_LOCAL("selection", 0))({}) {
				clay.TextDynamic(str[:selection_left_idx], clay.TextConfig(measurement_config))
			}
			if clay.UI(clay.ID_LOCAL("selection", 1))({}) {
				clay.TextDynamic(str[:selection_right_idx], clay.TextConfig(measurement_config))
			}

			selection_left_offset =
				clay.GetElementData(clay.ID_LOCAL("selection", 0)).boundingBox.width
			selection_right_offset =
				clay.GetElementData(clay.ID_LOCAL("selection", 1)).boundingBox.width
		}

		if clay.UI()(
		{
			floating = {
				attachTo = .Parent,
				offset = {0 = min(selection_right_offset, selection_left_offset)},
			},
		},
		) {
			if clay.UI()(
			{
				layout = {
					sizing = {
						width = clay.SizingFixed(
							abs(selection_right_offset - selection_left_offset),
						),
						height = clay.SizingFixed(32),
					},
				},
				backgroundColor = {128, 128, 255, 128},
			},
			) {

			}
		}
		last_edit_at := state.last_edit_time
		cursor_color := clay.Color{0, 0, 0, 255}

		if time.tick_since(last_edit_at) > time.Millisecond * 100 {
			cursor_color = clay.Color {
				0,
				0,
				0,
				f32(math.remap(math.sin(rl.GetTime() * 4), -1, 1, 0, 255)),
			}

		}
		if clay.UI()(
		{
			layout = {sizing = {height = clay.SizingFixed(32), width = clay.SizingFixed(2)}},
			backgroundColor = cursor_color,
			floating = {attachTo = .Parent, offset = {0 = selection_left_offset}},
		},
		) {}
	}
}

text_input_tick :: proc(state: ^edit.State) {
	inputted :: proc(key: rl.KeyboardKey) -> bool {
		return rl.IsKeyPressed(key) || rl.IsKeyPressedRepeat(key)
	}

	edit.update_time(state)

	for {
		char := rl.GetCharPressed()

		if char == 0 do break

		edit.input_rune(state, char)
	}


	ctrl := rl.IsKeyDown(.LEFT_CONTROL)
	shift := rl.IsKeyDown(.LEFT_SHIFT)

	if inputted(.BACKSPACE) {
		if ctrl {
			edit.perform_command(state, .Delete_Word_Left)
		} else {
			edit.perform_command(state, .Backspace)
		}
	}

	if inputted(.DELETE) {
		if ctrl {
			edit.perform_command(state, .Delete_Word_Right)
		} else {
			edit.perform_command(state, .Delete)
		}
	}

	if rl.IsKeyPressed(.A) && ctrl {
		edit.perform_command(state, .Select_All)
	}

	if inputted(.LEFT) {
		if shift {
			if ctrl {
				edit.perform_command(state, .Select_Word_Left)
			} else {
				edit.perform_command(state, .Select_Left)
			}
		} else {
			if ctrl {
				edit.perform_command(state, .Word_Left)
			} else {
				edit.perform_command(state, .Left)
			}
		}

	}

	if inputted(.RIGHT) {
		if shift {
			if ctrl {
				edit.perform_command(state, .Select_Word_Right)
			} else {
				edit.perform_command(state, .Select_Right)
			}
		} else {
			if ctrl {
				edit.perform_command(state, .Word_Right)
			} else {
				edit.perform_command(state, .Right)
			}
		}
	}

	if inputted(.HOME) {
		if shift {
			edit.perform_command(state, .Select_Start)
		} else {
			edit.perform_command(state, .Start)
		}
	}

	if inputted(.END) {
		if shift {
			edit.perform_command(state, .Select_Start)
		} else {
			edit.perform_command(state, .End)
		}
	}
}
