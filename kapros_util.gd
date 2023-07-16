extends Node

## Turn a Vector2 into a Vector3, using X and Y as X and Z and leaving Y as 0.
static func v2_xz_v3(v2: Vector2) -> Vector3:
	return Vector3(v2.x, 0, v2.y)
