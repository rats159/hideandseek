package main

import "core:fmt"
import "core:mem"

DEVTOOLS :: #config(DEVTOOLS, true)

main :: proc() {
	when ODIN_DEBUG {
		tracking_alloc: mem.Tracking_Allocator
		mem.tracking_allocator_init(&tracking_alloc, context.allocator)

		context.allocator = mem.tracking_allocator(&tracking_alloc)

		defer for ptr, alloc in tracking_alloc.allocation_map {
			fmt.printfln("%v: Leaked %m at address %p", alloc.location, alloc.size, ptr)
		}
	}
	game: Game

	init_game(&game)
	run_game(&game)

	destroy_game(game)
}
