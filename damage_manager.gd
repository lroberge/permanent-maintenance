class_name Damage

static func get_random_opposing_combatant(from: CombatBody):
	return CombatBody.AllCombatants.filter(check_if_damageable(from)).pick_random()

static func deal(amount: float, to: Array[CombatBody]):
#	print("DEALING DAMAGE TO: " + str(to))
	for victim in to:
		victim.alter_health(-abs(amount))

static func deal_singletarget(amount: float, to: CombatBody):
	deal(amount, [to])

static func deal_raidwide(amount: float, from: CombatBody):
	return deal(amount, CombatBody.AllCombatants.filter(check_if_damageable(from)))

static func deal_aoe(amount: float, aoe: Area3D, from: CombatBody):
	var bodies_in_aoe = CombatBody.AllCombatants.filter(check_if_damageable(from)) \
		.filter(func (body: CombatBody): return aoe.overlaps_body(body))
	return deal(amount, bodies_in_aoe)

static func heal(amount: float, to: Array[CombatBody], percent: bool = false):
	if percent:
		for patient in to:
			patient.heal_percent(abs(amount))
	else:
		for patient in to:
			patient.alter_health(abs(amount))

static func heal_aoe(amount: float, aoe: Area3D, from: CombatBody, percent: bool = false):
	var bodies_in_aoe = CombatBody.AllCombatants.filter(check_if_healable(from)) \
		.filter(func (body: CombatBody): return aoe.overlaps_body(body))
	return heal(amount, bodies_in_aoe, percent)

## Curried function. Given a "from" body, return a function that checks if a body can be damaged by the "from" body.
static func check_if_damageable(from: CombatBody):
	return func (body: CombatBody):
		return body.TEAM != from.TEAM

## Curried function. Given a "from" body, return a function that checks if a body can be healed by the "from" body.
static func check_if_healable(from: CombatBody):
	return func (body: CombatBody):
		return body.TEAM == from.TEAM
