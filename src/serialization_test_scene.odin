package main
import clay "../libs/clay-odin"
import "core:math"
import "base:builtin"
import "base:runtime"
import "core:encoding/cbor"
import "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:mem/virtual"
import "core:reflect"
import "core:strings"
import "core:time"
import "ui"
import rl "vendor:raylib"

when DEVTOOLS {

	MAX_RAND_LEN :: 10
	MIN_RAND_LEN :: 1

	TestData :: struct {
		passed:   bool,
		data:     any,
		expanded: bool,
	}

	SerializationTestScene :: struct {
		using _:    Scene,
		arena:      virtual.Arena,
		alloc:      mem.Allocator,
		tests:      [dynamic]TestData,
		test_index: int,
	}

	dynamic_array_at :: proc(arr: ^[dynamic]$T, index: int) -> ^T {
		if len(arr) <= index {
			assign_at(arr, index, T{})
		}
		return &arr[index]
	}

	randomize :: proc(val: any, allocator: mem.Allocator) {
		info := type_info_of(val.id)

		#partial switch value in info.variant {
		case runtime.Type_Info_Struct:
			for field in reflect.struct_fields_zipped(val.id) {
				randomize(
					any{id = field.type.id, data = rawptr(uintptr(val.data) + field.offset)},
					allocator,
				)
			}
		case runtime.Type_Info_Enum:
			opt := rand.choice(value.values)
			mem.copy(val.data, &opt, value.base.size)
		case runtime.Type_Info_Named:
			randomize(any{data = val.data, id = value.base.id}, allocator)
		case runtime.Type_Info_Slice:
			length := int(rand.uint32() % (MAX_RAND_LEN - MIN_RAND_LEN) + MIN_RAND_LEN)
			data, err := mem.alloc_bytes(
				value.elem.size * length,
				value.elem.align,
				allocator = allocator,
			)

			slc := (^runtime.Raw_Slice)(val.data)
			slc^ = runtime.Raw_Slice{raw_data(data), length}
			for i in 0 ..< slc.len {
				addr := uintptr(slc.data) + uintptr(i * value.elem_size)
				randomize(any{data = rawptr(addr), id = value.elem.id}, allocator)
			}
		case runtime.Type_Info_Array:
			for i in 0 ..< value.count {
				addr := uintptr(val.data) + uintptr(i * value.elem_size)
				randomize(any{data = rawptr(addr), id = value.elem.id}, allocator)
			}
		case runtime.Type_Info_Integer:
			big_value := rand.uint128()
			mem.copy(val.data, &big_value, reflect.size_of_typeid(val.id))
		case runtime.Type_Info_Float:
			switch val.id {
				case f64: (^f64)(val.data)^ = rand.float64() * 100 
				case f32: (^f32)(val.data)^ = rand.float32() * 100
				case f16: (^f16)(val.data)^ = f16(rand.float32() * 100)
				case: fmt.panicf("Unhandled float type",val.id)
			}

		case:
			fmt.panicf(
				"Trying to randomize unrandomizable type %s with variant %s",
				val.id,
				reflect.union_variant_typeid(value),
			)
		}
	}

	test :: proc($T: typeid, allocator: mem.Allocator) -> (T, bool) {

		first: T
		randomize(first, allocator)
		first_bytes := cbor.marshal_into_bytes(first) or_else panic("First marshalling failed!")

		second: T
		cbor.unmarshal_from_bytes(first_bytes, &second)

		second_bytes := cbor.marshal_into_bytes(second) or_else panic("Second marshalling failed!")

		if (len(first_bytes) != len(second_bytes)) do return first, false

		for i in 0 ..< len(first_bytes) {
			if (first_bytes[i] != second_bytes[i]) do return first, false
		}

		return first, true
	}


	log_test :: proc($T: typeid, scene: ^SerializationTestScene) {
		value, passed := test(T, scene.alloc)
		allocd_value := new_clone(value, scene.alloc)
		data := dynamic_array_at(&scene.tests, scene.test_index)
		data.passed = passed
		data.data = any {
			data = allocd_value,
			id   = typeid_of(T),
		}
		scene.test_index += 1
	}

	run_tests :: proc(scene: ^SerializationTestScene) {
		free_all(scene.alloc)
		scene.test_index = 0
		log_test(Collider, scene)
		log_test([]Collider, scene)
		log_test(rl.Vector2, scene)
		log_test([]rl.Vector2, scene)
	}

	serialization_test_scene_make :: proc() -> ^Scene {
		scene := new(SerializationTestScene)

		err := virtual.arena_init_growing(&scene.arena)
		if err != nil do panic("Failed to init serialization test arena")

		scene.alloc = virtual.arena_allocator(&scene.arena)

		scene.draw = serialization_test_scene_draw
		scene.destroy = generic_scene_destroy

		run_tests(scene)


		return scene
	}

	serialization_test_scene_draw :: proc(scene: ^Scene, game: ^Game) {
		scene := (^SerializationTestScene)(scene)
		run_tests(scene)
		rl.ClearBackground(rl.BLACK)

		if clay.UI()(
		{
			layout = {layoutDirection = .TopToBottom},
			clip = {vertical = true, childOffset = clay.GetScrollOffset()},
		},
		) {
			for &test, i in scene.tests {
				if clay.UI()({layout = {layoutDirection = .TopToBottom}}) {
					if clay.UI()({}) {
						if clay.Hovered() && rl.IsMouseButtonPressed(.LEFT) {
							test.expanded = !test.expanded
						}
						if test.expanded {
							clay.Text(
								"v ",
								clay.TextConfig(
									{textColor = {255, 255, 255, 255}, fontId = 1, fontSize = 18},
								),
							)
						} else {
							clay.Text(
								"> ",
								clay.TextConfig(
									{textColor = {255, 255, 255, 255}, fontId = 1, fontSize = 18},
								),
							)
						}
						clay.TextDynamic(
							fmt.tprintf("%v: ", test.data.id),
							clay.TextConfig(
								{textColor = {255, 255, 255, 255}, fontId = 1, fontSize = 18},
							),
						)
						if (test.passed) {
							clay.Text(
								"Passed",
								clay.TextConfig(
									{textColor = {0, 255, 0, 255}, fontId = 1, fontSize = 18},
								),
							)
						} else {
							clay.Text(
								"Failed",
								clay.TextConfig(
									{textColor = {255, 0, 0, 255}, fontId = 1, fontSize = 18},
								),
							)
						}}

					if test.expanded {
						if clay.UI()({layout = {padding = {20, 0, 0, 20}}}) {
							clay.TextDynamic(
								fmt.tprintf("%#v", test.data),
								clay.TextConfig(
									{textColor = {255, 255, 255, 255}, fontId = 1, fontSize = 18},
								),
							)
						}
					}
				}
			}
		}
		// str := strings.to_string(scene.log)


		if clay.UI()({floating = {attachment = {.RightTop, .RightTop}, attachTo = .Root}}) {
			if ui.button("Reset") {
				run_tests(scene)
			}
		}
	}
}
