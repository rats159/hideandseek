package server

import "../common"
import "core:encoding/cbor"
import "core:fmt"
import "core:math/rand"
import "core:strings"
import "core:time"
import enet "vendor:ENet"

Client :: struct {
	id:       u64,
	peer:     ^enet.Peer,
	username: string,
	position: [2]f32,
}

Server_Network_Data :: struct {
	clients: map[u64]Client,
	server:  ^enet.Host,
}

main :: proc() {
	if error_code := enet.initialize(); error_code != 0 {
		fmt.panicf("Failed to initialize ENet with error code", error_code)
	}

	address := enet.Address {
		host = enet.HOST_ANY,
		port = 7777,
	}

	data: Server_Network_Data
	data.server = enet.host_create(&address, 8, 1, 0, 0)

	if data.server == nil {
		fmt.panicf("Failed to create a server")
	}

	for {
		start := time.tick_now()
		parse_incoming_packets(&data)
		broadcast_positions(&data)

		sleep_time := time.tick_diff(time.tick_now(), time.tick_add(start, common.TICK_RATE))
		free_all(context.temp_allocator)
		time.sleep(sleep_time)
	}

	when ODIN_DEBUG {
		enet.host_destroy(server)
	}
}

broadcast_positions :: proc(data: ^Server_Network_Data) {
	positions := make([]common.Server_Position_Update, len(data.clients), context.temp_allocator)
	i := 0
	for _, client in data.clients {
		positions[i] = {client.id, client.position}
		i += 1
	}
	broadcast_packet(data.server, common.Update_All_Positions_Packet{positions})
}

handle_packet :: proc(data: ^Server_Network_Data, packet: common.C2SPacket, event: enet.Event) {
	client := &data.clients[u64(uintptr(event.peer.data))]

	switch type in packet {
	case common.SetUsernamePacket:
		fmt.printfln("Client with id %016X request username '%s'", client.id, type.message)
		result := validate_username(type.message)

		if result != .All_Good {
			fmt.printfln("  Invalid username.")
		} else {
			client.username = strings.clone(type.message)
		}

		send_packet(
			event.peer,
			common.UsernameReceivedPacket{result = result, value = type.message},
		)
		broadcast_packet(data.server, type)

	case common.Position_Update_Packet:
		fmt.printfln("%016X: New Position: (%f,%f)", type.id, type.position.x, type.position.y)
		client.position = type.position
	case common.Whos_Here_Packet:
		existing_players := make([]common.StringPacket, len(data.clients), context.temp_allocator)
		i := 0
		for id, client in data.clients {
			existing_players[i] = {id, client.username}
			i += 1
		}
		send_packet(event.peer, common.Join_Packet{existing_players})
	}
}

parse_incoming_packets :: proc(data: ^Server_Network_Data) {
	event: enet.Event
	for enet.host_service(data.server, &event, 0) > 0 {
		#partial switch event.type {
		case .CONNECT:
			id := rand.uint64()
			data.clients[id] = {
				id   = id,
				peer = event.peer,
			}
			event.peer.data = rawptr(uintptr(id))
			fmt.printfln("New client connected. Assigning id %016X.", id)

			send_packet(data.clients[id].peer, common.AssignIDPacket{id})
			broadcast_packet(data.server, common.Join_Packet{{{id, "New Player"}}})
		case .RECEIVE:
			packet: common.C2SPacket
			_ = cbor.unmarshal_from_bytes(event.packet.data[:event.packet.dataLength], &packet)
			handle_packet(data, packet, event)

		case .DISCONNECT:
			client := &data.clients[u64(uintptr(event.peer.data))]
			fmt.printfln(
				"Client with id %016X and username %s disconnected.",
				client.id,
				client.username,
			)
			delete_key(&data.clients, client.id)
			broadcast_packet(data.server, common.Leave_Packet{ids = {client.id}})
		}
	}
}

validate_username :: proc(name: string) -> common.Username_Validation_Result {
	if len(name) == 0 {
		return .Zero_Length
	}
	if len(name) > 32 {
		return .Over_32
	}

	for i in 0 ..< len(name) {
		if name[i] > 127 {
			return .Non_Ascii
		}

		if name[i] < 32 || name[i] == 127 {
			return .Control_Char
		}
	}

	return .All_Good
}

send_packet :: proc(to: ^enet.Peer, data: common.S2CPacket) {
	message, _ := cbor.marshal_into_bytes(data)
	packet := enet.packet_create(raw_data(message), uint(len(message)), {.RELIABLE})
	enet.peer_send(to, 0, packet)
}

broadcast_packet :: proc(host: ^enet.Host, data: common.S2CPacket) {
	message, _ := cbor.marshal_into_bytes(data)
	packet := enet.packet_create(raw_data(message), uint(len(message)), {.RELIABLE})
	enet.host_broadcast(host, 0, packet)
}
