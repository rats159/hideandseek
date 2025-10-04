package main

import clay "../libs/clay-odin"
import "common"
import "core:encoding/cbor"
import "core:fmt"
import "core:net"
import "core:strings"
import "core:sync"
import "core:text/edit"
import "core:thread"
import "core:time"
import "ui"
import enet "vendor:ENet"
import rl "vendor:raylib"

Connection_State :: enum {
	Resolving,
	Resolved,
	Resolution_Failed,
	Connecting,
	Connected,
	Connection_Failed,
}

Network_Data :: struct {
	client: ^enet.Host,
	peer:   ^enet.Peer,
	id:     u64,
}

Connection_Scene :: struct {
	using _:          Scene,
	target:           Maybe(net.Endpoint),
	target_name:      string,
	thread_pool:      thread.Pool,
	connection_state: Connection_State,
	data_mutex:       sync.Mutex,
	network_data:     Maybe(Network_Data),
}

resolve_ip :: proc(scene: ^Connection_Scene) {
	target, error := net.resolve_ip4(scene.target_name)

	if error != nil {
		sync.lock(&scene.data_mutex)
		scene.connection_state = .Resolution_Failed
		sync.unlock(&scene.data_mutex)
	} else {
		sync.lock(&scene.data_mutex)
		scene.target = target
		scene.connection_state = .Resolved
		sync.unlock(&scene.data_mutex)
	}
}

connection_scene_destroy :: proc(scene: ^Scene) {
	scene := (^Connection_Scene)(scene)

	thread.pool_destroy(&scene.thread_pool)
	delete(scene.target_name)
}

connection_scene_make :: proc(target_name: string, game: ^Game) -> ^Scene {
	scene := new(Connection_Scene)

	scene.destroy = connection_scene_destroy
	scene.draw = connection_scene_draw
	scene.tick = nil
	scene.target_name = target_name
	scene.connection_state = .Resolving

	thread.pool_init(&scene.thread_pool, context.allocator, 1)
	thread.pool_start(&scene.thread_pool)
	thread.pool_add_task(&scene.thread_pool, context.allocator, proc(t: thread.Task) {
			scene := (^Connection_Scene)(t.data)
			resolve_ip(scene)
		}, scene)


	return scene
}

connection_scene_draw :: proc(scene: ^Scene, game: ^Game) {
	scene := (^Connection_Scene)(scene)

	if clay.UI()(
	{
		layout = {sizing = {clay.SizingGrow(), clay.SizingGrow()}},
		backgroundColor = {255, 255, 255, 255},
	},
	) {
		state: Connection_State
		target: Maybe(net.Endpoint)

		sync.lock(&scene.data_mutex)
		state = scene.connection_state
		target = scene.target
		sync.unlock(&scene.data_mutex)

		switch state {
		case .Resolving:
			time := int(rl.GetTime() * 3) % 4
			text := "Resolving..."
			ui.centeredText(
				text[:len("Resolving") + time],
				clay.TextConfig({fontId = 0, fontSize = 32, textColor = {0, 0, 0, 255}}),
			)
		case .Resolved:
			scene.connection_state = .Connecting

			thread.pool_add_task(&scene.thread_pool, context.allocator, proc(t: thread.Task) {
					scene := (^Connection_Scene)(t.data)

					sync.lock(&scene.data_mutex)
					target := scene.target.?
					sync.unlock(&scene.data_mutex)

					data, err := connect(target)
					if err != .None {
						sync.lock(&scene.data_mutex)
						scene.connection_state = .Connection_Failed
						sync.unlock(&scene.data_mutex)
					} else {
						sync.lock(&scene.data_mutex)
						scene.network_data = data
						scene.connection_state = .Connected
						sync.unlock(&scene.data_mutex)
					}
				}, scene)

		case .Resolution_Failed:
			thread.pool_join(&scene.thread_pool)
			ui.open_modal({title = strings.clone("Failed to resolve")}, &game.ui_data)
			change_scene(game, server_picker_scene_make())

		case .Connection_Failed:
			thread.pool_join(&scene.thread_pool)
			ui.open_modal({title = strings.clone("Failed to connect")}, &game.ui_data)
			change_scene(game, server_picker_scene_make())

		case .Connecting:
			time := int(rl.GetTime() * 3) % 4
			text := "Connecting..."
			ui.centeredText(
				text[:len("Connecting") + time],
				clay.TextConfig({fontId = 0, fontSize = 32, textColor = {0, 0, 0, 255}}),
			)
		case .Connected:
			thread.pool_join(&scene.thread_pool)
			change_scene(game, username_picker_scene_make(scene.network_data.?))
		}
	}
}
