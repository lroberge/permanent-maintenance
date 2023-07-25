class_name InfluencePoint extends Node3D

enum INFLUENCE_DIM {NONE, X, Z, ALL}

## The intensity of the influence exerted by this point.
@export var intensity = 2.0
## Radius of the circle around this point that is safe/dangerous
@export var arrival_radius = 1.0
## For safe points: the radius around this point where characters *must* stop (to avoid jitter)
@export var hard_arrival_radius = 1.0
