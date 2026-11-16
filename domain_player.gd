extends CharacterBody2D

var speed = 300.0
var jump_force = -450.0
var gravity = 980.0
var parent_domain = null

func _ready():
	parent_domain = get_parent()

func _physics_process(delta):
	if parent_domain.is_player_dead: return
	if parent_domain.player_stun_timer > 0:
		# Jangan paksa 0, biarkan physics meluncur (knockback)
		velocity.x = move_toward(velocity.x, 0, 300 * 10 * delta) 
		velocity.y += gravity * delta
		move_and_slide()
		return

	# Gravitasi
	velocity.y += gravity * delta

	# Input Gerak
	var dir = 0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): dir -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): dir += 1

	if dir != 0:
		var current_speed = 300.0
		if parent_domain and is_instance_valid(parent_domain.main_ref):
			current_speed = 300.0 * parent_domain.main_ref.buff_speed_mult
		velocity.x = dir * current_speed
	else:
		var current_speed = 300.0
		if parent_domain and is_instance_valid(parent_domain.main_ref):
			current_speed = 300.0 * parent_domain.main_ref.buff_speed_mult
		velocity.x = move_toward(velocity.x, 0, current_speed * 10 * delta)

	# Lompat
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W)) and is_on_floor():
		velocity.y = jump_force

	# Cukup move_and_slide() saja.
	move_and_slide()
