package client

import "../common"
import "core:encoding/cbor"
import "core:fmt"
import "core:strings"
import enet "vendor:ENet"
import rl "vendor:raylib"

main :: proc() {
	if error_code := enet.initialize(); error_code != 0 {
		fmt.panicf("Failed to initialize ENet with error code", error_code)
	}

	client := enet.host_create(nil, 1, 1, 0, 0)

	if client == nil {
		fmt.panicf("Failed to create a client")
	}

	address: enet.Address

	enet.address_set_host(&address, "localhost")
	address.port = 7777

	peer := enet.host_connect(client, &address, 1, 0)

	if peer == nil {
		fmt.panicf("Failed to connect to host")
	}

	event: enet.Event

	if enet.host_service(client, &event, 5000) > 0 && event.type == .CONNECT {
		fmt.println("Connection succeeded!")
	} else {
		enet.peer_reset(peer)
		fmt.panicf("Failed to connect to server...")
	}

	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(1280, 720, "Client")

	builder := strings.Builder{}

	username: string
	id := ~u64(0)

	for !rl.WindowShouldClose() {
		for enet.host_service(client, &event, 0) > 0 {
			#partial switch event.type {
			case .RECEIVE:
				{
					packet: common.S2CPacket
					_ = cbor.unmarshal_from_bytes(
						event.packet.data[:event.packet.dataLength],
						&packet,
					)

					switch type in packet {
					case common.AssignIDPacket:
						id = type.id
					}

					fmt.println(packet)
				}
			}
		}

		for {
			char := rl.GetCharPressed()
			if char == 0 do break

			strings.write_rune(&builder, char)
		}

		if rl.IsKeyPressed(.BACKSPACE) {
			strings.pop_rune(&builder)
		}

		if rl.IsKeyPressed(.ENTER) {
			str := strings.to_string(builder)
			if username == {} {
				send_packet(peer, common.SetUsernamePacket{id, str})
				username = strings.clone(str)
			} else {
				send_packet(peer, common.MessagePacket{id, str})
			}
			strings.builder_reset(&builder)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		rl.DrawText(strings.to_cstring(&builder), 0, 0, 40, rl.BLACK)
		rl.EndDrawing()
	}

	rl.CloseWindow()

	enet.peer_disconnect(peer, 0)

	for enet.host_service(client, &event, 3000) > 0 {
		#partial switch event.type {
		case .RECEIVE:
			enet.packet_destroy(event.packet)
		case .DISCONNECT:
			fmt.println("Disconnection succeeded!")
		}
	}

	when ODIN_DEBUG {
		enet.deinitialize()
	}
}

send_packet :: proc(to: ^enet.Peer, data: common.C2SPacket) {
	message, _ := cbor.marshal_into_bytes(data)
	packet := enet.packet_create(raw_data(message), uint(len(message)), {.RELIABLE})
	enet.peer_send(to, 0, packet)
}
