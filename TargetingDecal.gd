extends Decal

@export var targeted = false

func target():
	targeted = true
func untarget():
	targeted = false
