package server

import "../common"
import "core:encoding/cbor"
import "core:fmt"
import "core:math/rand"
import "core:strings"
import enet "vendor:ENet"

Client :: struct {
	id:       u64,
	peer:     ^enet.Peer,
	username: string,
}

main :: proc() {
	if error_code := enet.initialize(); error_code != 0 {
		fmt.panicf("Failed to initialize ENet with error code", error_code)
	}

	address := enet.Address {
		host = enet.HOST_ANY,
		port = 7777,
	}

	server := enet.host_create(&address, 8, 1, 0, 0)

	if server == nil {
		fmt.panicf("Failed to create a server")
	}

	event: enet.Event

	clients: map[u64]Client

	for {
		for enet.host_service(server, &event, 1000) > 0 {
			#partial switch event.type {
			case .CONNECT:
				id := rand.uint64()
				clients[id] = {
					id   = id,
					peer = event.peer,
				}
				event.peer.data = rawptr(uintptr(id))
				fmt.printfln("New client connected. Assigning id %016X.", id)

				send_packet(clients[id].peer, common.AssignIDPacket{id})
			case .RECEIVE:
				packet: common.C2SPacket
				_ = cbor.unmarshal_from_bytes(event.packet.data[:event.packet.dataLength], &packet)
				client := &clients[u64(uintptr(event.peer.data))]
				switch type in packet {
				case common.MessagePacket:
					fmt.printfln("Client '%s' says %s", client.username, type.message)
				case common.SetUsernamePacket:
					client.username = strings.clone(type.message)
					fmt.printfln("Client with id %016X request username '%s'", client.id, client.username)
				}

			case .DISCONNECT:
				client := &clients[u64(uintptr(event.peer.data))]
				fmt.printfln("Client with id %016X and username %s disconnected.", client.id, client.username)
			}
		}
	}

	when ODIN_DEBUG {
		enet.host_destroy(server)
	}
}

send_packet :: proc(to: ^enet.Peer, data: common.S2CPacket) {
	message, _ := cbor.marshal_into_bytes(data)
	packet := enet.packet_create(raw_data(message), uint(len(message)), {.RELIABLE})
	enet.peer_send(to, 0, packet)
}
