package main
import clay "../libs/clay-odin"
import "base:runtime"
import "core:encoding/cbor"
import "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:reflect"
import "core:strings"
import "core:time"
import rl "vendor:raylib"
when DEVTOOLS {


	SerializationTestScene :: struct {
		using _: Scene,
		log:     strings.Builder,
	}

	randomize :: proc(val: any) {
		info := type_info_of(val.id)

		#partial switch value in info.variant {
		case runtime.Type_Info_Struct:
			for field in reflect.struct_fields_zipped(val.id) {
				randomize(any{id = field.type.id, data = rawptr(uintptr(val.data) + field.offset)})
			}
		case runtime.Type_Info_Enum:
			opt := rand.choice(value.values)
			mem.copy(val.data, &opt, value.base.size)
		case runtime.Type_Info_Named:
			randomize(any{data = val.data, id = value.base.id})
		case runtime.Type_Info_Integer:
			big_value := rand.uint128()
			mem.copy(val.data, &big_value, reflect.size_of_typeid(val.id))
		case:
			fmt.panicf(
				"Trying to randomize unrandomizable type %s with variant %s",
				val.id,
				reflect.union_variant_typeid(value),
			)
		}
	}

	test :: proc($T: typeid) -> (T, bool) {

		first: T
		randomize(first)
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
		fmt.sbprintfln(&scene.log, "Testing type %s:", typeid_of(T))
		value, passed := test(T)
        if passed {
			fmt.sbprintln(&scene.log, "  Passed!")
		} else {
			fmt.sbprintln(&scene.log, "  Failed!")
		}
        fmt.sbprintfln(&scene.log,"With input %#w\n",value)
	}

	serialization_test_scene_make :: proc() -> ^Scene {
		scene := new(SerializationTestScene)

		scene.draw = serialization_test_scene_draw
		scene.destroy = generic_scene_destroy

		log_test(Collider, scene)


		return scene
	}

	serialization_test_scene_draw :: proc(scene: ^Scene, game: ^Game) {
		scene := (^SerializationTestScene)(scene)
		rl.ClearBackground(rl.WHITE)
		str := strings.to_string(scene.log)
		clay.TextDynamic(
			str,
			clay.TextConfig({textColor = {0, 0, 0, 255}, fontId = 1, fontSize = 24}),
		)
	}
}
