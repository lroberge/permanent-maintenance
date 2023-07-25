class_name PartyCharacter extends CombatBody

@export var ignore_distance_self: float = 0.5
@export var ignore_distance_global: float = 0.25
@export var my_influencepoints: Array[InfluencePoint] = []

@onready var FSM: StateChart = $StateChart

var might_be_in_danger = false
@onready var stopping_time_left = 0
var stopping_ticks_left:
	get:
		return stopping_time_left * Engine.physics_ticks_per_second
@onready var resolve_ticks_left = resolve_time * Engine.physics_ticks_per_second
var safe_to_do_job = true

const RESCUE_LENGTH = 0.75
const RESCUE_RELEASE_TIME = 0.5
const RESCUE_SPEED_BASE = 25
var rescue_dir = null
var rescue_speed = RESCUE_SPEED_BASE
var rescue_time = 0
var rescue_dist = 0

const MIN_REACTION_TIME = 0.1

@export_group("Character Details/Skill")
## Average time it takes this party member to realize they're covered by an AoE, in seconds.
@export var reaction_time: float = 0.5
## Range of possible reaction times around the average.
@export var reaction_time_variability: float = 0.25
## Average time it takes this party member to find a safe spot, in seconds.
@export var resolve_time: float = 1.0

@export_group("Character Details/Personality")
## Whether this character will turn to face the enemy, even if they aren't in range to attack.
@export var defiant: bool = false
## How often this party member will cancel their cast to move, as a percentage between 0.0 and 1.0.
@export_range(0.0, 1.0, 0.05) var move_when_casting: float = 1.0
## Average amount of "overshoot" this party member has when avoiding AoEs, in extra seconds spent moving.
@export var max_stopping_time: float = 2
@onready var max_ticks_to_stop = floori(max_stopping_time * Engine.physics_ticks_per_second)

@export_group("Character Details/Build")
## Distance from which this character is allowed to attack enemies.
@export var attack_range: float = 5

func _ready():
	$StateChart.reaction_time = reaction_time
	$StateChart.reaction_time_variability = reaction_time_variability
	super()

func rescue(to_pos: Vector3):
	rescue_dir = Util.yless(self.global_position, 0).direction_to(to_pos)
	rescue_speed = clampf(pow(Util.yless(self.global_position, 0).distance_to(to_pos), 2), 0, RESCUE_SPEED_BASE)
	rescue_time = RESCUE_LENGTH
	FSM.send_event("being_rescued")

func revive(percenthealth: float):
	if self.is_dead:
		self.alter_health(MAX_HEALTH * percenthealth)
		return true
	else:
		return false

func random_stopping_time():
	return randf_range(0.1, max_stopping_time)

func add_own_influence_points(probe: bool = false):
	for point in my_influencepoints:
		var dist_squared = point.global_position.distance_to(self.global_position)
		var point_is_unsafe = false
		if probe and EncounterManager.dangerpoints.size() > 0:
			var potential_endpoint = self.global_position + self.global_position.direction_to(point.global_position)
			for dangerpoint in EncounterManager.dangerpoints:
				if potential_endpoint.distance_to(dangerpoint.global_position) < dangerpoint.arrival_radius:
					point_is_unsafe = true
					break
		if !point_is_unsafe and dist_squared > ignore_distance_self and dist_squared > point.arrival_radius:
			moveDirection += self.global_position.direction_to(point.global_position) * point.intensity

func add_safe_influence_points(delta: float):
	for point in EncounterManager.safepoints:
		var dist = point.global_position.distance_to(self.global_position)
		if dist > ignore_distance_global && dist > point.arrival_radius:
			moveDirection += self.global_position.direction_to(point.global_position) * point.intensity
		elif dist < point.hard_arrival_radius:
			stopping_time_left = 0
			break

func add_danger_influence_points(delta: float):
	for point in EncounterManager.dangerpoints:
		var dist_squared = point.global_position.distance_to(self.global_position)
		if dist_squared < point.arrival_radius:
			moveDirection += self.global_position.direction_to(point.global_position) * -point.intensity
			stopping_time_left = random_stopping_time()

func _on_FSM_updated(state, delta) -> void:
	pass # Replace with function body.

func _attack_noticed() -> void:
	stopping_time_left = random_stopping_time()
	pass # Replace with function body.

func _rescue_physics_process(delta) -> void:
	if rescue_time > 0:
		velocity = rescue_dir * (rescue_time / RESCUE_LENGTH) * rescue_speed
		move_and_slide()
		rescue_time -= delta
		if rescue_time <= 0:
			FSM.send_event("rescue_finished")


func _standard_rotation_physics_process(delta) -> void:
	moveDirection = Vector3.ZERO
	add_own_influence_points(false)
	moveDirection = moveDirection.normalized()


func _resolve_mechanic_start() -> void:
	FSM.send_event("cancel_casting")
	var unsafe = false
	for dangerpoint in EncounterManager.dangerpoints:
		if global_position.distance_to(dangerpoint.global_position) < dangerpoint.arrival_radius:
			unsafe = true
			break
	if not unsafe:
		FSM.send_event("reached_optimal_safety")
	moveDirection = Vector3.ZERO


func _resolve_mechanic_physics_process(delta) -> void:
	add_danger_influence_points(delta)
	add_safe_influence_points(delta)
	moveDirection = moveDirection.normalized()
	if stopping_time_left <= 0:
		FSM.send_event("reached_safety")
	stopping_time_left -= delta


func _probe_own_attack_range(delta) -> void:
	moveDirection = Vector3.ZERO
	add_own_influence_points(true)
	moveDirection = moveDirection.normalized()
	if moveDirection.length_squared() < 0.1:
		FSM.send_event("reached_optimal_safety")

func _start_avoiding_attack() -> void:
	moveDirection = Vector3.ZERO

func _avoid_attack_physics_process(delta) -> void:
	if curr_target and (defiant or global_position.distance_to(curr_target.global_position) <= attack_range):
		faceDirection = global_position.direction_to(curr_target.global_position)
	pass # Replace with function body.

