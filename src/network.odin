package main

import "core:net"
import enet "vendor:ENet"

Connection_Error :: enum {
    None,
    Failed_To_Create_Client,
    Failed_To_Connect,
    No_Host_Acknowledgement
}

connect :: proc(to: net.Endpoint) -> (Network_Data, Connection_Error){
	data: Network_Data
    data.client = enet.host_create(nil, 1, 1, 0, 0)

	if data.client == nil {
        return {}, .Failed_To_Create_Client
	}
	target_address := to
	address: enet.Address
	address.host = transmute(u32)(target_address.address.(net.IP4_Address))
	address.port = u16(target_address.port)

	data.peer = enet.host_connect(data.client, &address, 1, 0)

	if data.peer == nil {
        return {}, .Failed_To_Connect
	}

	event: enet.Event

	if enet.host_service(data.client, &event, 5000) > 0 && event.type == .CONNECT {
        return data, .None
    } else {
		enet.peer_reset(data.peer)
        return {}, .No_Host_Acknowledgement
    }
}
