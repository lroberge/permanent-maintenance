class_name Util extends Node

## Turn a Vector2 into a Vector3, using X and Y as X and Z and leaving Y as 0.
static func v2_xz_v3(v2: Vector2) -> Vector3:
	return Vector3(v2.x, 0, v2.y)

static func yless(v3: Vector3, y: float) -> Vector3:
	return Vector3(v3.x, y, v3.z)

# https://ask.godotengine.org/131718/use-vector3s-get-coordinate-specific-angle-and-distance-away
static func polar_offset(pos: Vector3, angle: float, distance: float) -> Vector3:
	return pos + Vector3(cos(angle), 0, sin(angle)) * distance
