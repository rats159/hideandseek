package common

C2SPacket :: union {
    MessagePacket,
    SetUsernamePacket
}

StringPacket :: struct {
    id: u64,
    message: string
}

MessagePacket :: distinct StringPacket
SetUsernamePacket :: distinct StringPacket

S2CPacket :: union {
    AssignIDPacket
}

AssignIDPacket :: struct {
    id: u64
}