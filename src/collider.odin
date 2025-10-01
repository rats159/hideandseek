package main

ColliderType :: enum u8 {
	CollisionBox,
	TagBox,
}

Collider :: struct {
	type: ColliderType,
	x1:   int,
	y1:   int,
	x2:   int,
	y2:   int,
}
