package main

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

	when ODIN_DEBUG {
		// Only destroy program-lifelong memory in debug mode for the tracking allocator
		//   Otherwise, the OS can handle it for a faster close
		destroy_game(game)
	}
}
