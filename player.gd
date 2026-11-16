extends CharacterBody2D

@export var speed: float = 300.0
@export var gravity: float = 980.0
@export var jump_force: float = -400.0

var max_fall_y: float = -99999.0
var is_spectator = false

func _physics_process(delta):
	# --- LOGIKA SPECTATOR MODE (TERBANG PAKAI WASD) ---
	if is_spectator:
		var move_x = 0
		var move_y = 0
		
		# Cek tombol A / Panah Kiri
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move_x -= 1
		# Cek tombol D / Panah Kanan
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move_x += 1
		# Cek tombol W / Panah Atas
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move_y -= 1
		# Cek tombol S / Panah Bawah
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move_y += 1
		
		var input_dir = Vector2(move_x, move_y)
		velocity = input_dir.normalized() * speed * 2.0
		move_and_slide()
		return # Keluar dari fungsi, abaikan gravitasi
	# ---------------------------------------

	if not is_on_floor():
		velocity.y += gravity * delta
		if global_position.y < max_fall_y:
			max_fall_y = global_position.y
	else:
		if max_fall_y != -99999.0:
			var fall_distance = global_position.y - max_fall_y
			var blocks = fall_distance / 16.0
			var dmg = 0
			if blocks > 80: dmg = 100
			elif blocks > 60: dmg = 75
			elif blocks > 40: dmg = 50
			elif blocks > 25: dmg = 30
			elif blocks > 20: dmg = 20
			elif blocks > 15: dmg = 10
			
			if dmg > 0:
				get_parent().take_true_damage(dmg, global_position)
			max_fall_y = -99999.0

	# Kontrol Normal (Jalan & Lompat)
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()
