extends KinematicBody2D

var state = 1
var GROUNDED = 0
var MIDAIR = 1

var WALK_SPEED = 100
var TERMINAL_VELOCITY = 200
var UP_ANGLE = (PI/-2.0)
var MAX_UP_ANGLE = UP_ANGLE + (PI/4)
var MIN_UP_ANGLE = UP_ANGLE - (PI/4)
var velocity = Vector2()
var animator
var grounded = false

func _ready():
	animator = get_node("Sprite/AnimationPlayer")
	set_fixed_process(true)

func _move_horizontally():
	if (Input.is_action_pressed("ui_left")):
		velocity.x = -WALK_SPEED
	elif (Input.is_action_pressed("ui_right")):
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0

func _apply_gravity(delta):
	velocity.y += 300 * delta
	if (velocity.y > TERMINAL_VELOCITY):
		velocity.y = TERMINAL_VELOCITY

func _move_with(velocity, delta):
	if (velocity.x == 0 and velocity.y == 0):
		return
	var motion = velocity * delta
	move(motion)
	grounded = false
	if (is_colliding()):
		var n = get_collision_normal()
		var normal_angle = atan(n.y / n.x)
		if (normal_angle >= MIN_UP_ANGLE
			and normal_angle <= MAX_UP_ANGLE):
			velocity.y = 0
			grounded = true
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	if (grounded):
		state = GROUNDED
	else:
		state = MIDAIR

func _fixed_process(delta):
	if (state == GROUNDED):
		_move_horizontally()
		_apply_gravity(delta)
		if (velocity.x != 0):
			animator.set_anim("Walk")
		else:
			animator.set_anim("Idle")
		_move_with(velocity, delta)
	elif (state == MIDAIR):
		_move_horizontally()
		_apply_gravity(delta)
		animator.set_anim("Fall")
		_move_with(velocity, delta)
	pass