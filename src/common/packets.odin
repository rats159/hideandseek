package common

C2SPacket :: union {
    MessagePacket,
    SetUsernamePacket,
    Position_Update_Packet,
    Request_Positions_Packet,
    Whos_Here_Packet
}

StringPacket :: struct {
    id: u64,
    message: string
}

Request_Positions_Packet :: struct{}
Whos_Here_Packet :: struct{}
Position_Update_Packet :: struct {
    id: u64,
    position: [2]f32
}

MessagePacket :: distinct StringPacket
SetUsernamePacket :: distinct StringPacket

S2CPacket :: union {
    AssignIDPacket,
    UsernameReceivedPacket,
    Update_All_Positions_Packet,
    Join_Packet,
    Leave_Packet
}

Join_Packet :: struct {
    ids: []u64
}

Leave_Packet :: struct {
    ids: []u64
}


Server_Position_Update :: struct {
    id: u64,
    position: [2]f32
}

Update_All_Positions_Packet :: struct {
    positions: []Server_Position_Update
}

UsernameReceivedPacket :: struct {
    result: Username_Validation_Result,
    value: string
}

AssignIDPacket :: struct {
    id: u64
}