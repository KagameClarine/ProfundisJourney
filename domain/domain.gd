extends Node2D

signal domain_closed(completed: bool, final_hp: int, final_mana: float)

var config_index: int = -1
var domain_name: String = ""
var boss_type: String = ""
var main_ref: Node = null

var player_hp: int = 100
var domain_gold: int = 0
var player_mana: float = 100.0
var inventory: Dictionary = {}

var clone_player: CharacterBody2D
var domain_cam: Camera2D
var ui_label: Label
var debug_dist_label: Label

# --- UI HUD ---
var hud_hp_hearts: Array = []
var hud_exp_label: Label
var hud_lives_label: Label
var hud_hotbar_labels: Array = []

# --- UI INVENTORY ---
var is_inventory_open = false
var inventory_panel: Panel
var inv_slot_nodes: Array = []
var inv_hotbar_slots: Array = []
var selected_inv_item = null

# --- UI CHARACTER ---
var is_char_open = false
var char_panel: Panel
var char_slot_labels = []
var char_slots_panels = []
var char_hover_panel: Panel
var char_hover_name: Label
var char_hover_stats: Label
var is_transitioning = false
var boss_prompt: Label
var boss_cam: Camera2D # <--- TAMBAHKAN INI
var boss_cinematic_bg: ColorRect
var boss_chest: Node2D = null

# --- COMBAT & ARROWS ---
var attack_cooldown = 0.0
var swarmid_use_timer: float = 0.0
var swarmid_exhausted_timer: float = 0.0
var bounty_bow_stacks: int = 0
var bounty_stack_timer: float = 0.0
var damage_cooldown = 0.0
var is_charging_bow = false
var arrows = []
var mana_regen_timer = 0.0
var placed_tiles = {}
var is_boss_fight_started = false
var is_boss_defeated = false
var domain_bgm_time: float = 0.0
var boss_bgm_time: float = 0.0

# --- UI BOS ---
var boss_ui: VBoxContainer     # <--- TAMBAHKAN INI
var boss_bar: ColorRect        # <--- TAMBAHKAN INI
var boss_max_hp: int = 1
var boss_name_label: Label
var boss_armor_bar: ColorRect # <--- TAMBAHKAN INI
var boss_max_armor: int = 1

var enemies = []
var is_player_dead = false
var player_stun_timer = 0.0   # <--- TAMBAHKAN INI
var player_slow_timer = 0.0
var target_block_node = null
var mine_timer = 0.0
var sword_combo: int = 0
var galahad_stacks: int = 0
var galahad_parry_active: bool = false
var galahad_parry_cd: float = 0.0
var minigun_shot_count: int = 0
var crystal_armor_stacks = 0
var crystal_armor_timer = 0.0
# --- MELEE BLUEPRINT PASSIVES ---
var sgs_hit_counter = 0            # Silver Gray Sword
var sgs_accelerate_stacks = 0
var revenger_target = null         # Revenger Crystallinum
var revenger_stacks = 0
var revenger_timer = 0.0
var conductor_charge_timer = 0.0   # Golden Conductor
var conductor_charging = false
var conductor_tick_timer = 0.0
var stormjade_charge_timer = 0.0   # Stormjade Cutter
var stormjade_charging = false
var hammer_charge_timer = 0.0      # Crystal Hammer
var hammer_charging = false
# TARUH DI SINI BERSAMAAN DENGAN VARIABEL LAIN
var chainsaw_use_timer = 0.0
var chainsaw_exhausted_timer = 0.0
var minigun_fire_timer = 0.0
var minigun_exhausted_timer = 0.0
# --- ARMOR BLUEPRINT PASSIVES ---
var deep_cave_petrify_timer = 0.0
# --- MINING TOOL BLUEPRINT STATE ---
var _bonecrusher_reduced: Dictionary = {}
var _pneumatic_bombs: Array = []
var _magic_beam_line: Line2D = null
var _magic_beam_dmg_cd: float = 0.0
var deep_cave_regen_timer = 0.0
var deep_cave_cooldown = 0.0
var deep_cave_active = false
var crack_sprite: Sprite2D

func setup(cfg_idx: int, dname: String, btype: String, main_node: Node, inv_data: Dictionary) -> void:
	config_index = cfg_idx
	domain_name = dname
	boss_type = btype
	main_ref = main_node
	player_hp = main_node.current_hp
	player_mana = main_node.current_mana
	inventory = inv_data.duplicate() 

func _ready() -> void:
	_play_domain_bgm() # <--- Panggil fungsi sakti ini saja
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bikin_hud_domain()
	bikin_ui_bos()
	bikin_ui_inventory()
	bikin_ui_character()
	bikin_arena()
	bikin_player_clone()
	bikin_efek_retak()
	spawn_domain_minions()
	
	print("[DOMAIN] Siap.")

func _process(delta):
	if is_player_dead or is_transitioning: return
	_update_pneumatic_bombs_domain(delta)
	if is_instance_valid(_magic_beam_line) and Global.hotbar_items[main_ref.selected_hotbar_index] != "Magic Pickaxe":
		_magic_beam_line.queue_free()
		_magic_beam_line = null
	if galahad_parry_cd > 0: galahad_parry_cd -= delta
	if is_player_dead: return
	
	# --- LOGIKA STUN & PETRIFY ---
	if player_stun_timer > 0 or deep_cave_active:
		if player_stun_timer > 0:
			player_stun_timer -= delta
		clone_player.velocity.x = 0
		if clone_player.is_physics_processing():
			clone_player.set_physics_process(false)
			if is_instance_valid(clone_player.get_child(0)) and clone_player.get_child(0) is Polygon2D:
				clone_player.get_child(0).color = Color(0.8, 0.8, 0.8)
	else:
		if not clone_player.is_physics_processing():
			clone_player.set_physics_process(true)
			if is_instance_valid(clone_player.get_child(0)) and clone_player.get_child(0) is Polygon2D:
				clone_player.get_child(0).color = Color.CYAN

	# --- LOGIKA SLOW ---
	if player_slow_timer > 0:
		player_slow_timer -= delta
		if clone_player.speed == 300.0: clone_player.speed = 150.0
	elif clone_player.speed == 150.0:
		clone_player.speed = 300.0
	# ---------------------------
	# Debug Jarak
	if is_instance_valid(clone_player) and is_instance_valid(debug_dist_label):
		var jarak_blok = (700.0 - clone_player.global_position.x) / 16.0
		if jarak_blok > 0:
			debug_dist_label.text = "Jarak ke Bos: " + str(snapped(jarak_blok, 0.1)) + " blok (X: " + str(int(clone_player.global_position.x)) + ")"
		else:
			debug_dist_label.text = "MASUK AREA BOS!"

	# Mana Regen
	if player_mana < main_ref.max_mana:
		mana_regen_timer += delta
		if mana_regen_timer >= 0.5:
			mana_regen_timer = 0.0
			player_mana = min(player_mana + 2, main_ref.max_mana)
			update_hud()

	# Cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if damage_cooldown > 0:
		damage_cooldown -= delta
		
	# --- TIMER RESET SENJATA SAAT TIDAK DIPAKAI ---
	var _current_held = Global.hotbar_items[main_ref.selected_hotbar_index]
	if _current_held != "Crystal Minigun":
		minigun_fire_timer = move_toward(minigun_fire_timer, 0, delta)
	if _current_held != "Maniacal Chainsaw":
		chainsaw_use_timer = move_toward(chainsaw_use_timer, 0, delta)
	# -----------------------------------------------
	
	if minigun_exhausted_timer > 0:
		minigun_exhausted_timer -= delta
	if chainsaw_exhausted_timer > 0:
		chainsaw_exhausted_timer -= delta
	if swarmid_exhausted_timer > 0:
		swarmid_exhausted_timer -= delta
		
	if _current_held == "Swarmid Drill" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and swarmid_exhausted_timer <= 0:
		swarmid_use_timer += delta
		if swarmid_use_timer >= 8.0:
			swarmid_exhausted_timer = 3.5
			swarmid_use_timer = 0.0
			show_floating_text("DRILL EXHAUSTED!", clone_player.global_position + Vector2(0, -60), Color.RED)
	elif _current_held != "Swarmid Drill" or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		swarmid_use_timer = move_toward(swarmid_use_timer, 0, delta * 2.0)
	
	if hammer_charging: hammer_charge_timer += delta
	if stormjade_charging: stormjade_charge_timer += delta
	
	# Klik Kiri (Attack / Mine / Place Block)
	if not is_inventory_open and not is_char_open and attack_cooldown <= 0 and player_stun_timer <= 0 and not deep_cave_active:
		var _held_check = Global.hotbar_items[main_ref.selected_hotbar_index]
		
		# --- GOLDEN CONDUCTOR ---
		if _held_check == "Golden Conductor":
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				if not conductor_charging:
					conductor_charging = true
					conductor_charge_timer = 0.0
					conductor_tick_timer = 0.0
			else:
				if conductor_charging:
					if conductor_charge_timer >= 3.0:
						var _exp_dmg = int(54 * 1.7 * main_ref.buff_dmg_mult)
						var _dir_x = sign(get_global_mouse_position().x - clone_player.global_position.x)
						if _dir_x == 0: _dir_x = 1
						var _player_bottom = clone_player.global_position.y + 32
						var _max_dist = 128.0
						
						var _ray_y = _player_bottom - 12
						var _ray_start = Vector2(clone_player.global_position.x, _ray_y)
						var _ray_end = _ray_start + Vector2(_dir_x * _max_dist, 0)
						var _space = get_world_2d().direct_space_state
						var _q = PhysicsRayQueryParameters2D.create(_ray_start, _ray_end, 1)
						var _hit = _space.intersect_ray(_q)
						if _hit:
							_max_dist = max(8.0, _ray_start.distance_to(_hit.position))
						
						for _e in enemies.duplicate():
							if not is_instance_valid(_e): continue
							var _e_size_h = _e.get_meta("size_h", _e.get_meta("size", 16.0))
							var _e_bottom = _e.global_position.y + _e_size_h / 2.0
							var _tol = max(24.0, _e_size_h / 2.0 + 8.0)
							if abs(_e_bottom - _player_bottom) > _tol: continue
							var _dx = _e.global_position.x - clone_player.global_position.x
							if _dir_x > 0 and (_dx < -16 or _dx > _max_dist + 16): continue
							if _dir_x < 0 and (_dx > 16 or _dx < -_max_dist - 16): continue
							
							var _cached_type = _e.get_meta("type")
							var _hp = _e.get_meta("hp") - _exp_dmg
							_e.set_meta("hp", _hp)
							# --- TAMBAHKAN INI ---
							var _ename = _cached_type.to_lower().replace("_boss", "")
							Sfx.play(_ename + "_hurt")
							# ---------------------

							if _hp <= 0:
								Sfx.play(_ename + "_die")
							var _bar = _e.get_meta("hp_bar", null)
							if _bar: _bar.size.x = 30.0 * (float(max(_hp,0)) / _e.get_meta("max_hp"))
							show_floating_text(str(_exp_dmg), _e.global_position + Vector2(0, -40), Color.ORANGE)
							
							if _hp <= 0:
								if "boss" in _cached_type:
									show_floating_text("BOSS DEFEATED!", _e.global_position + Vector2(0, -60), Color.GOLD)
									if is_instance_valid(boss_ui): boss_ui.visible = false
									is_boss_defeated = true
									spawn_boss_chest()
								enemies.erase(_e)
								_e.queue_free()
						
						var _exp = ColorRect.new()
						_exp.size = Vector2(_max_dist, 24)
						if _dir_x > 0:
							_exp.position = Vector2(clone_player.global_position.x, _player_bottom - 24)
						else:
							_exp.position = Vector2(clone_player.global_position.x - _max_dist, _player_bottom - 24)
						_exp.color = Color(1.0, 0.8, 0.2, 0.8)
						_exp.z_index = 15
						add_child(_exp)
						var _t = create_tween()
						_t.tween_property(_exp, "modulate:a", 0.0, 0.3)
						_t.tween_callback(_exp.queue_free)
						attack_cooldown = 1.0
					else:
						if attack_cooldown <= 0:
							var mouse_world_pos = get_global_mouse_position()
							await try_attack(mouse_world_pos, false)
							attack_cooldown = 1.0
					conductor_charging = false
					conductor_charge_timer = 0.0
					conductor_tick_timer = 0.0
			if conductor_charging:
				conductor_charge_timer += delta
				conductor_tick_timer += delta
				if conductor_tick_timer >= 0.5:
					conductor_tick_timer = 0.0
					var _tick_dmg = int(54 * 0.05)
					for _e in enemies.duplicate():
						if is_instance_valid(_e) and clone_player.global_position.distance_to(_e.global_position) < 64.0:
							var _cached_type = _e.get_meta("type")
							var _hp = _e.get_meta("hp") - _tick_dmg
							_e.set_meta("hp", _hp)
							var _bar = _e.get_meta("hp_bar", null)
							if _bar: _bar.size.x = 30.0 * (float(max(_hp,0)) / _e.get_meta("max_hp"))
							show_floating_text(str(_tick_dmg), _e.global_position + Vector2(0, -40), Color.YELLOW)
							if _hp <= 0:
								if "boss" in _cached_type:
									if is_instance_valid(boss_ui): boss_ui.visible = false
									is_boss_defeated = true
									spawn_boss_chest()
								enemies.erase(_e)
								_e.queue_free()
			
			update_arrows(delta)
			return
		# ------------------------
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var held_item = _held_check
			var w_type = main_ref.item_data.get(held_item, {}).get("weapon_type", "")
			var tile_id = main_ref.item_data.get(held_item, {}).get("tile", -1)
			
			# --- RADIANCE SCEPTER (Langsung di _process) ---
			if held_item == "Radiance Scepter" and attack_cooldown <= 0:
				var _item_stats = Global.get_effective_stats(held_item, main_ref.item_data.get(held_item, {}))
				var _mana_cost = _item_stats.get("mana_cost", 25)
				if player_mana >= _mana_cost:
					player_mana -= _mana_cost
					var _heal = _item_stats.get("heal_amount", 12)
					var _lv = Global.get_item_level("Radiance Scepter")
					if _lv > 1:
						_heal = int(_heal * (1.0 + 0.1 * (_lv - 1)))
					player_hp = min(player_hp + _heal, main_ref.max_hp)
					attack_cooldown = _item_stats.get("attack_speed", 1.5) / main_ref.buff_atk_speed_mult
						
					show_floating_text("+" + str(_heal) + " HP", clone_player.global_position + Vector2(0, -40), Color.GREEN)
					var _heal_fx = ColorRect.new()
					_heal_fx.size = Vector2(60, 60)
					_heal_fx.position = clone_player.global_position - Vector2(30, 30)
					_heal_fx.color = Color(1.0, 0.9, 0.5, 0.6)
					_heal_fx.z_index = 15
					add_child(_heal_fx)
					var _ht = create_tween()
					_ht.tween_property(_heal_fx, "scale", Vector2(1.8, 1.8), 0.3)
					_ht.parallel().tween_property(_heal_fx, "modulate:a", 0.0, 0.3)
					_ht.tween_callback(_heal_fx.queue_free)
					update_hud()
				else:
					show_floating_text("Not enough Mana!", clone_player.global_position, Color.BLUE)
					attack_cooldown = 0.5
			# -------------------------------------------
			
			# 1. Logika Nambang (Pickaxe)
			if held_item in ["Stone Pickaxe", "Iron Pickaxe", "Swarmid Drill", "Bonecrusher", "Pneumatic Drill"]:
				if held_item == "Swarmid Drill" and swarmid_exhausted_timer > 0:
					show_floating_text("EXHAUSTED!", clone_player.global_position, Color.RED)
					target_block_node = null
					if is_instance_valid(crack_sprite): crack_sprite.visible = false
				else:
					try_mine_block(get_global_mouse_position(), held_item, delta)
			elif held_item == "Magic Pickaxe":
				_handle_magic_pickaxe_domain(get_global_mouse_position(), delta)
			# 2. Logika Serang (Sword, Bow, dll)
			elif w_type != "":
				try_attack(get_global_mouse_position(), false)
			# 3. Logika Taruh Blok / Torch
						# 3. Logika Taruh Blok / Torch
			elif held_item != null and (tile_id != -1 or held_item == "Torch"):
				try_place_block(get_global_mouse_position(), held_item)
		else:
			target_block_node = null
			mine_timer = 0.0
			if is_instance_valid(crack_sprite): crack_sprite.visible = false
	
	# --- ARMOR BLUEPRINT TIMERS ---
	if deep_cave_cooldown > 0:
		deep_cave_cooldown -= delta
	
	if deep_cave_active:
		deep_cave_petrify_timer -= delta
		if deep_cave_petrify_timer > 0:
			deep_cave_regen_timer += delta
			if deep_cave_regen_timer >= 1.0:
				deep_cave_regen_timer -= 1.0
				player_hp = min(player_hp + 7, main_ref.max_hp)
				update_hud()
		else:
			deep_cave_active = false
			clone_player.set_physics_process(true)
			show_floating_text("RECOVERED!", clone_player.global_position + Vector2(0, -60), Color.GREEN)
	# ------------------------------
	
	# --- BOUNTY BOW TIMER ---
	if bounty_stack_timer > 0:
		bounty_stack_timer -= delta
		if bounty_stack_timer <= 0 and bounty_bow_stacks > 0:
			bounty_bow_stacks = 0
			show_floating_text("Bounty Reset!", clone_player.global_position + Vector2(0, -80), Color.GRAY)
	# ------------------------
	
	# --- REVENGER TIMER ---
	if revenger_timer > 0:
		if _magic_beam_dmg_cd > 0:
			_magic_beam_dmg_cd -= delta
		revenger_timer -= delta
		if revenger_timer <= 0:
			revenger_stacks = 0
			revenger_target = null
	# ----------------------
	
	# --- MAGIC VULN RESET 3s (Sharding Sword) ---
	for _e in enemies:
		if is_instance_valid(_e) and _e.has_meta("magic_vuln_timer"):
			var _t = _e.get_meta("magic_vuln_timer") - delta
			if _t <= 0:
				_e.remove_meta("magic_vuln")
				_e.remove_meta("magic_vuln_timer")
			else:
				_e.set_meta("magic_vuln_timer", _t)
	# ---------------------------------------------
	
	# --- SGS ACCELERATE RESET 5s ---
	if sgs_accelerate_stacks > 0:
		var _sgs_t = get_meta("sgs_reset_timer", 5.0) - delta
		if _sgs_t <= 0:
			sgs_accelerate_stacks = 0
			sgs_hit_counter = 0
			remove_meta("sgs_reset_timer")
		else:
			set_meta("sgs_reset_timer", _sgs_t)
	# -------------------------------
	
	update_arrows(delta)

func _physics_process(delta):
	if is_player_dead or is_transitioning: return
	
	# --- PROMPT PINTU BOS ---
	if is_instance_valid(clone_player) and is_instance_valid(boss_prompt):
		var px = clone_player.global_position.x
		if not is_boss_fight_started:
			if px > 630 and px < 720:
				boss_prompt.text = "Press [E] to enter Boss Room"
				boss_prompt.visible = true
			else:
				boss_prompt.visible = false
		else:
			# Sedang fight — tampilkan prompt escape kalau dekat pintu
			if px > 630 and px < 800:
				boss_prompt.text = "Press [E] to escape Boss Room"
				boss_prompt.visible = true
			else:
				boss_prompt.visible = false
	# -------------------------
	
	# Update musuh (tabrakan sudah diurus oleh domain_player.gd)
	update_minions(delta)
	
func start_boss_fight():
	# Simpan waktu lagu domain, lalu mainkan lagu boss dari waktu terakhir
	domain_bgm_time = MusicManager.get_precise_time()
	MusicManager.play_bgm("res://audio/bgm_domain_boss_fight.mp3", boss_bgm_time)
	is_boss_fight_started = true
	is_transitioning = true
	
	if is_instance_valid(boss_prompt): boss_prompt.visible = false
	clone_player.velocity = Vector2.ZERO
	clone_player.set_physics_process(false)
	
	# 1. Fade Out (Hitam)
	var fade_layer = CanvasLayer.new()
	fade_layer.layer = 100
	add_child(fade_layer)
	
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.size = get_viewport().get_visible_rect().size
	fade_layer.add_child(fade)
	
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.6)
	await tween.finished
	
	# --- KUNCI KAMERA KE TENGAH RUANGAN ---
	# Ruangan berada di X: 700 s/d 1660 (Tengah = 1180), Y: -640 s/d 20 (Tengah = -310)
	if is_instance_valid(domain_cam):
		domain_cam.enabled = false # Matikan kamera player
		
	boss_cam = Camera2D.new()
	boss_cam.global_position = Vector2(1180, -250) # Posisi tengah ruangan
	boss_cam.zoom = Vector2(1.5, 1.5)
	add_child(boss_cam)
	boss_cam.make_current() # Fokuskan layar ke kamera bos
	# ---------------------------------------
	
	# --- SEMBUNYIKAN DUNIA LUAR (Masking) ---
	boss_cinematic_bg = ColorRect.new()
	boss_cinematic_bg.color = Color(0.02, 0.02, 0.05) # Warna hitam kebiruan
	boss_cinematic_bg.size = Vector2(4000, 4000)
	boss_cinematic_bg.position = Vector2(-2000, -2000)
	boss_cinematic_bg.z_index = 5 # Di atas background domain, di bawah lantai bos
	add_child(boss_cinematic_bg)
	# ----------------------------------------
	
	# Bangun Arena
	if not has_node("BossDoorLock"):
		var boss_bg = ColorRect.new()
		boss_bg.color = Color(0.15, 0.05, 0.05)
		boss_bg.position = Vector2(700, -640)
		boss_bg.size = Vector2(960, 960) 
		boss_bg.z_index = 6 # Di atas cinematic_bg
		add_child(boss_bg)
		
		create_static_block(Vector2(1660, -160), Vector2(40, 960), Color(0.1, 0.15, 0.1), true)
		create_static_block(Vector2(1180, -640), Vector2(960, 40), Color(0.1, 0.15, 0.1), true)
		create_static_block(Vector2(1180, 20), Vector2(960, 40), Color(0.15, 0.25, 0.15), true)
		var door_lock = create_static_block(Vector2(700, -320), Vector2(40, 640), Color(0.6, 0.1, 0.1), true)
		door_lock.name = "BossDoorLock"
		
		Sfx.play("door")
		
		# --- PLATFORM HUNTER ---
		if boss_type == "Powerful Hunter":
			var p_color = Color(0.3, 0.2, 0.1) # Warna kayu
			# 3 Platform Bawah (Y = -90)
			create_static_block(Vector2(900, -90), Vector2(120, 20), p_color, true)
			create_static_block(Vector2(1180, -90), Vector2(120, 20), p_color, true)
			create_static_block(Vector2(1460, -90), Vector2(120, 20), p_color, true)
			# 2 Platform Tengah (Y = -180)
			create_static_block(Vector2(1040, -180), Vector2(120, 20), p_color, true)
			create_static_block(Vector2(1320, -180), Vector2(120, 20), p_color, true)
			# 1 Platform Atas (Y = -270)
			create_static_block(Vector2(1180, -270), Vector2(160, 20), p_color, true)
		# -----------------------
		
		# --- PLATFORM CRYSTAL GOLEM (Bentuk X) ---
		if boss_type == "Powerful Crystal Golem":
			var g_color = Color(0.5, 0.6, 0.7) # Warna Kristal
			# 2 Atas (Diturunkan dari -350 ke -240 agar bisa dilompat)
			create_static_block(Vector2(900, -240), Vector2(160, 20), g_color, true)
			create_static_block(Vector2(1460, -240), Vector2(160, 20), g_color, true)
			# 1 Tengah
			create_static_block(Vector2(1180, -150), Vector2(200, 20), g_color, true)
			# 2 Bawah
			create_static_block(Vector2(850, -50), Vector2(150, 20), g_color, true)
			create_static_block(Vector2(1510, -50), Vector2(150, 20), g_color, true)
			
	var existing_boss = null
	for e in enemies:
		# Cek apakah tipenya berakhiran "_boss"
		if is_instance_valid(e) and "boss" in e.get_meta("type"):
			existing_boss = e
			break
			
	if existing_boss != null:
		existing_boss.visible = true
		existing_boss.collision_layer = 1
		existing_boss.collision_mask = 1
		var btype = existing_boss.get_meta("type")
		if btype == "goblin_boss": existing_boss.set_meta("state", "chase")
		elif btype == "cannibal_boss": existing_boss.set_meta("state", "chase")
		elif btype == "hunter_boss": existing_boss.set_meta("state", "attack")
		elif btype == "cult_boss": existing_boss.set_meta("state", "idle")
		elif btype == "spider_boss": existing_boss.set_meta("state", "web")
		elif btype == "cave_slime_boss": existing_boss.set_meta("state", "rock_throw")
		elif btype == "crystal_golem_boss": existing_boss.set_meta("state", "walk")
		if is_instance_valid(boss_ui): boss_ui.visible = true
	else:
		# Spawn Bos sesuai dengan domain yang dimasuki
		if boss_type == "Powerful Cannibal":
			spawn_cannibal_boss()
		elif boss_type == "Powerful Hunter": # <--- TAMBAHKAN INI
			spawn_hunter_boss()
		elif boss_type == "Powerful Cult":
			spawn_cult_boss()
		elif boss_type == "Powerful Spider": # <--- TAMBAHKAN INI
			spawn_spider_boss()
		elif boss_type == "Powerful Cave Slime": # <--- TAMBAHKAN INI
			spawn_cave_slime_boss()
		elif boss_type == "Powerful Crystal Golem":
			spawn_crystal_golem_boss()
		else:
			spawn_goblin_boss() # Fallback ke Goblin kalau tipenya belum dibuat
	
	clone_player.global_position = Vector2(850, -50)
	clone_player.z_index = 10
	clone_player.velocity = Vector2.ZERO
	
	# 2. Fade In (Terang)
	var tween2 = create_tween()
	tween2.tween_property(fade, "color:a", 0.0, 0.6)
	await tween2.finished
	fade_layer.queue_free()
	
	clone_player.set_physics_process(true)
	is_transitioning = false
	show_floating_text("BOSS FIGHT!", clone_player.global_position + Vector2(0, -100), Color.RED)

func spawn_goblin_boss():
	var boss = CharacterBody2D.new()
	boss.set_meta("type", "goblin_boss")
	
	# 1. Hitung Stats
	var hp = 120 * 1.5 
	var dmg = 12 * 1.2
	var size_w = 24 * 1.25
	var size_h = 48 * 1.25
	
	# 2. Simpan HP ke variabel global & nyalakan UI
	boss_max_hp = hp
	if is_instance_valid(boss_ui):
		boss_ui.visible = true
		boss_bar.size.x = 400.0 # Reset bar ke penuh
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	# 3. Masukkan Stats ke Boss
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg)
	boss.set_meta("size", size_w)
	boss.set_meta("size_h", size_h)
	boss.set_meta("state", "chase")
	boss.set_meta("flee_timer", 0.0)
	boss.set_meta("invis_timer", 0.0)
	boss.set_meta("atk_timer", 1.0)
	
	# 4. Visual Bos
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(0.1, 0.3, 0.1) 
	boss.add_child(poly)
	
	# 5. Collision
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED # <--- TAMBAHKAN INI
	boss.safe_margin = 0.08
	
	# 7. Spawn Posisi
	boss.z_index = 10
	boss.position = Vector2(1400, -100) 
	add_child(boss)
	enemies.append(boss)

func spawn_cannibal_boss():
	var boss = CharacterBody2D.new()
	boss.set_meta("type", "cannibal_boss")
	
	# STATS: 50% HP, 20% DMG, 25% Size (Base main.gd: 300 HP, 15 DMG)
	var hp = 300 * 1.5
	var dmg = 15 * 1.2
	var size_w = 32 * 1.25
	var size_h = 64 * 1.25
	
	boss_max_hp = hp
	if is_instance_valid(boss_ui):
		boss_ui.visible = true
		boss_bar.size.x = 400.0
		boss_name_label.text = "Powerful Cannibal" # Set Nama Baru
		
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg)
	boss.set_meta("size", size_w)
	boss.set_meta("size_h", size_h)
	boss.set_meta("state", "chase")
	boss.set_meta("atk_timer", 1.0)
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(0.5, 0.05, 0.05) # Merah Darah Gelap
	boss.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED # <--- TAMBAHKAN INI
	boss.safe_margin = 0.08
	
	boss.z_index = 10
	boss.position = Vector2(1400, -100) 
	add_child(boss)
	enemies.append(boss)

func spawn_hunter_boss():
	var boss = CharacterBody2D.new()
	boss.set_meta("type", "hunter_boss")
	
	# STATS: HP 100 (+50%), DMG 10 (+20%), Size (+25%)
	var hp = 100 * 1.5
	var dmg = 10 * 1.2
	var size_w = 24 * 1.25
	var size_h = 48 * 1.25
	
	boss_max_hp = hp
	if is_instance_valid(boss_ui):
		boss_ui.visible = true
		boss_bar.size.x = 400.0
		boss_name_label.text = "Powerful Hunter"
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg)
	boss.set_meta("size", size_w)
	boss.set_meta("size_h", size_h)
	boss.set_meta("state", "attack")
	boss.set_meta("atk_timer", 1.5)
	boss.set_meta("next_teleport_hp", hp * 0.8) # Teleport pertama di 80% HP
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(0.6, 0.2, 0.6) # Warna ungu
	boss.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED # <--- TAMBAHKAN INI
	boss.safe_margin = 0.08
	
	boss.z_index = 10
	boss.position = Vector2(1180, -310) # Spawn di platform paling atas
	add_child(boss)
	enemies.append(boss)

func spawn_cult_boss():
	var boss = CharacterBody2D.new()
	boss.set_meta("type", "cult_boss")
	
	# STATS: Base Cult (150 HP, 30 DMG)
	var hp = 150 * 1.5 
	var dmg = 30 * 1.2
	var size_w = 24 * 1.25
	var size_h = 48 * 1.25
	
	boss_max_hp = hp
	if is_instance_valid(boss_ui):
		boss_ui.visible = true
		boss_bar.size.x = 400.0
		boss_name_label.text = "Powerful Cult"
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg)
	boss.set_meta("size", size_w)
	boss.set_meta("size_h", size_h)
	boss.set_meta("state", "idle")
	boss.set_meta("atk_timer", 1.5)
	boss.set_meta("home_pos", Vector2(1400, -100)) # Posisi diam dia
	boss.set_meta("summon_count", 0) # Hitungan summon cannibal
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(0.5, 0.1, 0.5) # Warna ungu cult
	boss.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED # <--- TAMBAHKAN INI
	boss.safe_margin = 0.08
	boss.z_index = 10
	boss.position = boss.get_meta("home_pos")
	add_child(boss)
	enemies.append(boss)
	
	# Spawn 1 Cannibal Buffed di awal
	spawn_cult_cannibal(Vector2(1300, -100))

func spawn_cult_cannibal(pos: Vector2):
	var c = CharacterBody2D.new()
	c.set_meta("type", "cannibal")
	c.set_meta("is_cult_buffed", true) # Penanda buff
	
	# Base Cannibal
	var hp = 300
	var dmg = 15
	var size_w = 32
	var size_h = 64
	
	c.set_meta("hp", hp)
	c.set_meta("max_hp", hp)
	c.set_meta("damage", dmg)
	c.set_meta("size", size_w)
	c.set_meta("atk_timer", 1.0)
	c.set_meta("buff_speed_mult", 1.1) # Buff 10% speed
	c.set_meta("damage_reduction", 0.5) # Buff 50% DR
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(0.8, 0.3, 0.3) # Warna merah agak terang (tanda dibuff)
	c.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	c.add_child(col)
	
	c.collision_layer = 1
	c.collision_mask = 1
	c.z_index = 9
	c.position = pos
	add_child(c)
	enemies.append(c)

func spawn_spider_boss():
	var boss = CharacterBody2D.new()
	boss.set_meta("type", "spider_boss")
	
	# STATS: Base Spider (240 HP, 14 DMG)
	var hp = 240 * 1.5 # 360 HP
	var dmg = 14 * 1.2 # 16.8 DMG
	var size_w = 48 * 1.25 # 60
	var size_h = 16 * 1.25 # 20
	
	boss_max_hp = hp
	if is_instance_valid(boss_ui):
		boss_ui.visible = true
		boss_bar.size.x = 400.0
		boss_name_label.text = "Powerful Spider"
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg)
	boss.set_meta("size", size_w)
	boss.set_meta("size_h", size_h)
	
	# State Awal
	boss.set_meta("state", "web")
	boss.set_meta("web_count", 0)
	boss.set_meta("pattern_timer", 1.0)
	boss.set_meta("web_timer", 1.0)
	boss.set_meta("web_count", 0)
	boss.set_meta("dash_dir", 1)
	boss.set_meta("dash_hit", false)
	boss.set_meta("atk_timer", 1.0)
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(1.0, 0.8, 0.2) # Kuning terang
	boss.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED # <--- TAMBAHKAN INI
	boss.safe_margin = 0.08
	
	boss.z_index = 10
	boss.position = Vector2(1180, -50) # Spawn di tengah lantai
	add_child(boss)
	enemies.append(boss)

func spawn_cave_slime_boss():
	var boss = CharacterBody2D.new()
	boss.set_meta("type", "cave_slime_boss")
	
	# STATS: Base (200 HP, 20 DMG)
	var hp = 200 * 1.5 # 300 HP
	var dmg = 20 * 1.2 # 24 DMG
	var size_w = 32 * 1.25
	var size_h = 32 * 1.25
	
	boss_max_hp = hp
	if is_instance_valid(boss_ui):
		boss_ui.visible = true
		boss_bar.size.x = 400.0
		boss_name_label.text = "Powerful Cave Slime"
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg)
	boss.set_meta("size", size_w)
	boss.set_meta("size_h", size_h)
	
	# Shield
	boss.set_meta("armor_hp", 200)
	boss_max_armor = 200 # <--- TAMBAHKAN INI
	if is_instance_valid(boss_armor_bar): boss_armor_bar.size.x = 400.0 # Reset bar armor
	
	# State Pattern
	boss.set_meta("state", "rock_throw")
	boss.set_meta("rocks_thrown", 0)
	boss.set_meta("gravels_dropped", 0)
	boss.set_meta("sub_timer", 0.3)
	boss.set_meta("pattern_timer", 0.0)
	boss.set_meta("atk_timer", 1.0)
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(0.5, 0.3, 0.1) # Coklat Slime
	boss.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	boss.safe_margin = 0.08
	
	boss.z_index = 10
	boss.position = Vector2(1180, -50) # Tengah ruangan
	add_child(boss)
	enemies.append(boss)

func spawn_crystal_golem_boss():
	var boss = CharacterBody2D.new()
	boss.set_meta("type", "crystal_golem_boss")
	
	# STATS: Base Golem (700 HP, 24 DMG) -> 1050 HP, 28.8 DMG
	var hp = 700 * 1.5 
	var dmg = 24 * 1.2 
	var size_w = 32 * 1.25
	var size_h = 80 * 1.25
	
	boss_max_hp = hp
	if is_instance_valid(boss_ui):
		boss_ui.visible = true
		boss_bar.size.x = 400.0
		boss_name_label.text = "Powerful Crystal Golem"
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg)
	boss.set_meta("size", size_w)
	boss.set_meta("size_h", size_h)
	
	# Shield (Mulai dari 0)
	boss.set_meta("armor_hp", 0)
	boss_max_armor = 1 # Max awal biar ga divide by zero
	if is_instance_valid(boss_armor_bar): boss_armor_bar.size.x = 0
	
	boss.set_meta("state", "walk")
	boss.set_meta("boulder_cd", 5.0) # Cooldown lempar batu
	boss.set_meta("atk_timer", 1.5)
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = Color(0.4, 0.6, 0.8) # Biru Kristal
	boss.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_layer = 1
	boss.collision_mask = 1
	boss.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	boss.safe_margin = 0.08
	
	boss.z_index = 10
	boss.position = Vector2(1400, -100) 
	add_child(boss)
	enemies.append(boss)
	
# ==========================================
# SISTEM MINING & PLACING BLOCK (FIXED)
# ==========================================
func try_mine_block(mouse_world_pos, held_item, delta):
	var grid_x = floor(mouse_world_pos.x / 16.0) * 16.0 + 8.0
	var grid_y = floor(mouse_world_pos.y / 16.0) * 16.0 + 8.0
	var grid_pos = Vector2(grid_x, grid_y)

	if placed_tiles.has(grid_pos):
		var node = placed_tiles[grid_pos]
		
		if node == target_block_node:
			# Hitung waktu nambang
			var item_stats = Global.get_effective_stats(held_item, main_ref.item_data.get(held_item, {}))
			var tool_efficiency = item_stats.get("efficiency", 1.0) + main_ref.buff_efficiency
			var toughness = node.get_meta("toughness", 2.0)
			var required_time = toughness / tool_efficiency
			
			mine_timer += delta
			
			# Tampilkan Animasi Retak
			if is_instance_valid(crack_sprite):
				crack_sprite.global_position = node.global_position
				crack_sprite.visible = true
				crack_sprite.modulate.a = clamp(mine_timer / required_time, 0.2, 1.0)
			
			# Blok Hancur
			if mine_timer >= required_time:
				var item_name = node.get_meta("item_name", "Dirt")
				inventory[item_name] = inventory.get(item_name, 0) + 1
				show_floating_text("Mined!", grid_pos, Color.WHITE)
				
				node.queue_free()
				placed_tiles.erase(grid_pos)
				
				# --- BONECRUSHER di domain ---
				if held_item == "Bonecrusher":
					var _adj_offsets = [Vector2(0, -16), Vector2(0, 16), Vector2(-16, 0), Vector2(16, 0)]
					for _off in _adj_offsets:
						var _adj = grid_pos + _off
						if placed_tiles.has(_adj):
							var _cur = _bonecrusher_reduced.get(_adj, 0)
							if _cur < 3:
								_bonecrusher_reduced[_adj] = _cur + 1
								var _adj_node = placed_tiles[_adj]
								if not is_instance_valid(_adj_node): continue
								var _adj_base = _adj_node.get_meta("toughness", 2.0)
								var _adj_eff = _adj_base - _bonecrusher_reduced[_adj]
								if _adj_eff <= 0.0:
									var _adj_item = _adj_node.get_meta("item_name", "Dirt")
									inventory[_adj_item] = inventory.get(_adj_item, 0) + 1
									show_floating_text(_adj_item + " (Crusher)", _adj, Color.ORANGE)
									_adj_node.queue_free()
									placed_tiles.erase(_adj)
									_bonecrusher_reduced.erase(_adj)
				
				# --- PNEUMATIC DRILL bomb di domain ---
				if held_item == "Pneumatic Drill" and randf() < 0.30:
					_spawn_pneumatic_bomb_domain(grid_pos)
				
				# --- SWARMID DRILL: 3x3 mining ---
				if held_item == "Swarmid Drill":
					for _dx in [-1, 0, 1]:
						for _dy in [-1, 0, 1]:
							if _dx == 0 and _dy == 0: continue
							var _adj_pos = grid_pos + Vector2(_dx * 16, _dy * 16)
							if placed_tiles.has(_adj_pos):
								var _adj_node = placed_tiles[_adj_pos]
								if not is_instance_valid(_adj_node): continue
								var _adj_item = _adj_node.get_meta("item_name", "Dirt")
								inventory[_adj_item] = inventory.get(_adj_item, 0) + 1
								show_floating_text(_adj_item + " (1)", _adj_pos, Color.LIGHT_GRAY)
								_adj_node.queue_free()
								placed_tiles.erase(_adj_pos)
				# -----------------------------------
				
				update_inventory_ui()
				update_hud()
				
				target_block_node = null
				mine_timer = 0.0
				if is_instance_valid(crack_sprite): crack_sprite.visible = false
		else:
			# Mulai nambang blok baru
			target_block_node = node
			mine_timer = 0.0
	else:
		target_block_node = null
		mine_timer = 0.0
		if is_instance_valid(crack_sprite): crack_sprite.visible = false

# --- DOMAIN MINING TOOL HELPERS ---
func _spawn_pneumatic_bomb_domain(grid_pos: Vector2):
	var bomb = ColorRect.new()
	bomb.size = Vector2(16, 16)
	bomb.color = Color(0.2, 0.2, 0.2)
	bomb.position = grid_pos - Vector2(8, 8)
	bomb.z_index = 15
	add_child(bomb)
	var t = create_tween().set_loops(3)
	t.tween_property(bomb, "modulate:a", 0.3, 0.25)
	t.tween_property(bomb, "modulate:a", 1.0, 0.25)
	_pneumatic_bombs.append({"node": bomb, "timer": 1.5, "position": grid_pos})

func _update_pneumatic_bombs_domain(delta):
	for i in range(_pneumatic_bombs.size() - 1, -1, -1):
		var b = _pneumatic_bombs[i]
		if not is_instance_valid(b["node"]):
			_pneumatic_bombs.remove_at(i)
			continue
		b["timer"] -= delta
		if b["timer"] <= 0:
			_explode_pneumatic_bomb_domain(b["position"])
			b["node"].queue_free()
			_pneumatic_bombs.remove_at(i)

func _explode_pneumatic_bomb_domain(center_pos: Vector2):
	var _radius = 32.0
	var _aoe = Rect2(center_pos - Vector2(_radius, _radius), Vector2(_radius * 2, _radius * 2))
	
	var exp = ColorRect.new()
	exp.size = Vector2(64, 64)
	exp.position = center_pos - Vector2(32, 32)
	exp.color = Color(1.0, 0.5, 0.0, 0.8)
	exp.z_index = 15
	add_child(exp)
	var t = create_tween()
	t.tween_property(exp, "scale", Vector2(1.5, 1.5), 0.2)
	t.tween_property(exp, "modulate:a", 0.0, 0.2)
	t.tween_callback(exp.queue_free)
	
	var _dmg = 30
	for _e in enemies.duplicate():
		if not is_instance_valid(_e): continue
		if _aoe.has_point(_e.global_position):
			damage_enemy(_e, _dmg, false)
	
	for _pos in placed_tiles.keys():
		if _aoe.has_point(_pos):
			var _node = placed_tiles[_pos]
			if not is_instance_valid(_node): continue
			var _item = _node.get_meta("item_name", "Dirt")
			inventory[_item] = inventory.get(_item, 0) + 1
			_node.queue_free()
			placed_tiles.erase(_pos)
	
	update_inventory_ui()
	update_hud()

func _handle_magic_pickaxe_domain(mouse_world_pos: Vector2, delta: float):
	var player_pos = clone_player.global_position
	var dir = (mouse_world_pos - player_pos).normalized()
	var max_dist = 320.0
	var step = 8.0
	var traveled = 0.0
	var hit_pos = Vector2(-9999, -9999)
	var hit_node = null
	
	while traveled < max_dist:
		var check_pos = player_pos + dir * traveled
		var grid_x = floor(check_pos.x / 16.0) * 16.0 + 8.0
		var grid_y = floor(check_pos.y / 16.0) * 16.0 + 8.0
		var grid_pos = Vector2(grid_x, grid_y)
		if placed_tiles.has(grid_pos):
			hit_pos = grid_pos
			hit_node = placed_tiles[grid_pos]
			break
		traveled += step
	
	# Beam visual
	if not is_instance_valid(_magic_beam_line):
		_magic_beam_line = Line2D.new()
		_magic_beam_line.width = 4.0
		_magic_beam_line.default_color = Color(0.5, 0.3, 0.9, 0.8)
		_magic_beam_line.z_index = 15
		add_child(_magic_beam_line)
	_magic_beam_line.clear_points()
	_magic_beam_line.add_point(player_pos)
	if hit_node != null:
		_magic_beam_line.add_point(hit_pos)
	else:
		_magic_beam_line.add_point(player_pos + dir * max_dist)
	
	# Damage musuh di jalur (CD 0.7s terpisah dari attack_cooldown)
	if _magic_beam_dmg_cd <= 0:
		_magic_beam_dmg_cd = 0.7
		var beam_end_pos = hit_pos if hit_node != null else (player_pos + dir * max_dist)
		var beam_dist = player_pos.distance_to(beam_end_pos)
		for _e in enemies.duplicate():
			if not is_instance_valid(_e): continue
			var _e_pos = _e.global_position
			var proj = (_e_pos - player_pos).dot(dir)
			if proj <= 0 or proj >= beam_dist: continue
			var perp = abs((_e_pos - player_pos).cross(dir))
			if perp < 40:
				var dmg = int(9 * main_ref.buff_dmg_mult)
				damage_enemy(_e, dmg, false)
	
	# Mining
	if hit_node != null and is_instance_valid(hit_node):
		if hit_node == target_block_node:
			var _item_stats = Global.get_effective_stats("Magic Pickaxe", main_ref.item_data.get("Magic Pickaxe", {}))
			var _eff = _item_stats.get("efficiency", 4.0) + main_ref.buff_efficiency
			var _toughness = hit_node.get_meta("toughness", 2.0)
			var _req = _toughness / _eff
			mine_timer += delta
			if is_instance_valid(crack_sprite):
				crack_sprite.global_position = hit_pos
				crack_sprite.visible = true
				crack_sprite.modulate.a = clamp(mine_timer / _req, 0.2, 1.0)
			if mine_timer >= _req:
				var _item = hit_node.get_meta("item_name", "Dirt")
				inventory[_item] = inventory.get(_item, 0) + 1
				show_floating_text("Mined!", hit_pos, Color.WHITE)
				hit_node.queue_free()
				placed_tiles.erase(hit_pos)
				update_inventory_ui()
				update_hud()
				target_block_node = null
				mine_timer = 0.0
				if is_instance_valid(crack_sprite): crack_sprite.visible = false
		else:
			target_block_node = hit_node
			mine_timer = 0.0

func try_place_block(mouse_world_pos, held_item):
	if not inventory.has(held_item) or inventory[held_item] <= 0: return
	
	# --- VALIDASI: hanya item dengan tile != -1 atau Torch ---
	var _tile_id = main_ref.item_data.get(held_item, {}).get("tile", -1)
	if _tile_id == -1 and held_item != "Torch":
		return
	# ---------------------------------------------------
	
	var grid_x = floor(mouse_world_pos.x / 16.0) * 16.0 + 8.0
	var grid_y = floor(mouse_world_pos.y / 16.0) * 16.0 + 8.0
	var grid_pos = Vector2(grid_x, grid_y)
	
	if clone_player.global_position.distance_to(grid_pos) > 120.0: return
	if placed_tiles.has(grid_pos): return 
	
	# Cek support (Lantai utama, nempel blok lain, ATAU nempel dinding arena)
	var has_support = false
	if grid_y >= -8.0: has_support = true
	var dirs = [Vector2(16, 0), Vector2(-16, 0), Vector2(0, 16), Vector2(0, -16)]
	for d in dirs:
		if placed_tiles.has(grid_pos + d): 
			has_support = true
			break
			
	# Cek apakah nempel ke dinding bawaan (StaticBody2D)
	if not has_support:
		var space = get_world_2d().direct_space_state
		for d in dirs:
			var query = PhysicsPointQueryParameters2D.new()
			query.position = grid_pos + d
			query.collision_mask = 1
			var result = space.intersect_point(query)
			for r in result:
				if r.collider is StaticBody2D:
					has_support = true
					break
			if has_support: break

	if not has_support: 
		show_floating_text("No support!", clone_player.global_position, Color.RED)
		return
	
	# Cek tabrakan dengan player
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	query.shape = rect
	query.transform = Transform2D(0, grid_pos)
	query.collision_mask = 1
	var result = space_state.intersect_shape(query)
	for r in result:
		if r.collider == clone_player:
			show_floating_text("Too close!", clone_player.global_position, Color.RED)
			return
	
	# Taruh Blok / Torch
	var new_node
	if held_item == "Torch":
		new_node = Node2D.new()
		new_node.position = grid_pos
		
		var stick = ColorRect.new()
		stick.size = Vector2(4, 10); stick.position = Vector2(-2, -2); stick.color = Color(0.4, 0.2, 0.1)
		new_node.add_child(stick)
		
		var flame = ColorRect.new()
		flame.size = Vector2(6, 6); flame.position = Vector2(-3, -8); flame.color = Color(1, 0.8, 0.2)
		new_node.add_child(flame)
		
		var light = PointLight2D.new()
		light.texture = bikin_tekstur_cahaya()
		light.shadow_enabled = false
		light.energy = 1.0; light.texture_scale = 3.0; light.color = Color(1, 0.8, 0.5)
		light.blend_mode = Light2D.BLEND_MODE_MIX 
		new_node.add_child(light)
		
		var tween = create_tween().bind_node(new_node).set_loops()
		tween.tween_property(flame, "modulate:a", 0.7, 0.2)
		tween.tween_property(flame, "modulate:a", 1.0, 0.2)
		tween.parallel().tween_property(light, "energy", 0.8, 0.2)
		tween.tween_property(light, "energy", 1.2, 0.2)
		add_child(new_node)
	else:
		var color = main_ref.item_data.get(held_item, {"color": Color.WHITE})["color"]
		new_node = create_static_block(grid_pos, Vector2(16, 16), color, true)
	
	# Simpan nama item ke node agar bisa dikembalikan saat dihancurkan
	# Simpan nama item & TOUGHNESS ke node
	var toughness = 2.0
	if held_item == "Dirt" or held_item == "Gravel": toughness = 2.0
	elif held_item == "Stone" or held_item == "Copper": toughness = 2.5
	elif held_item == "Crystal Stone": toughness = 3.5
	elif held_item == "Hardened Crystal Stone": toughness = 5.5
	
	new_node.set_meta("item_name", held_item)
	new_node.set_meta("toughness", toughness)
	placed_tiles[grid_pos] = new_node
	
	# Kurangi item
	inventory[held_item] -= 1
	if inventory[held_item] <= 0:
		inventory.erase(held_item)
		for i in range(7):
			if Global.hotbar_items[i] == held_item: Global.hotbar_items[i] = null
			
	attack_cooldown = 0.2
	update_hud()
	update_inventory_ui()

func bikin_tekstur_cahaya():
	var grad = Gradient.new()
	grad.colors = [Color(1, 1, 1, 1), Color(1, 1, 1, 0)]
	grad.offsets = [0.0, 1.0]
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 1.0)
	tex.width = 128
	tex.height = 128
	return tex

# ==========================================
# ARENA & SCENERY (KEMBALI SEPERTI ASLINYA)
# ==========================================
func bikin_arena():
	# Lantai Utama
	create_static_block(Vector2(-640, 20), Vector2(2720, 40), Color(0.15, 0.25, 0.15), true)
	var ground_fill = ColorRect.new()
	ground_fill.color = Color(0.1, 0.15, 0.1)
	ground_fill.position = Vector2(-2000, 40)
	ground_fill.size = Vector2(2720, 1200) 
	add_child(ground_fill)

	# Dinding Kiri & Ceiling
	create_static_block(Vector2(-2000, -560), Vector2(40, 1120), Color(0.1, 0.15, 0.1), true) 
	create_static_block(Vector2(-640, -1120), Vector2(2720, 40), Color(0.1, 0.15, 0.1), true) 
	
	var ceiling_fill = ColorRect.new()
	ceiling_fill.color = Color(0.1, 0.15, 0.1)
	ceiling_fill.position = Vector2(-2000, -2000) 
	ceiling_fill.size = Vector2(2760, 880) 
	add_child(ceiling_fill)

	# Pintu Masuk
	var door_in = ColorRect.new()
	door_in.color = Color(0.4, 0.2, 0.1)
	door_in.position = Vector2(-1980, -80) 
	door_in.size = Vector2(20, 80) 
	add_child(door_in)

	# ZONA LORONG KIRI (Wall untuk taruh Torch)
	create_static_block(Vector2(-1680, -240), Vector2(640, 40), Color(0.1, 0.15, 0.1), true) 
	create_static_block(Vector2(-1360, -680), Vector2(40, 880), Color(0.1, 0.15, 0.1), true) 
	create_static_block(Vector2(-1680, -690), Vector2(640, 880), Color(0.1, 0.15, 0.1), true)

	# ZONA ALAM TERBUKA (Scenery Bintang & Platform)
	var scenery = ColorRect.new()
	scenery.color = Color(0.02, 0.01, 0.1)
	scenery.position = Vector2(-1360, -1120)
	scenery.size = Vector2(1920, 1120) 
	scenery.z_index = -50
	add_child(scenery)
	
	for i in range(80):
		var star = ColorRect.new()
		star.color = Color(1, 1, 1, randf_range(0.3, 0.8))
		star.size = Vector2(randi_range(2, 6), randi_range(2, 6))
		star.position = Vector2(randi_range(0, 1900), randi_range(0, 1100))
		scenery.add_child(star)

	var plat_color = Color(0.2, 0.3, 0.2)
	create_static_block(Vector2(-1200, -150), Vector2(150, 20), plat_color, true)
	create_static_block(Vector2(-900, -300), Vector2(200, 20), plat_color, true)
	create_static_block(Vector2(-1100, -450), Vector2(150, 20), plat_color, true)
	create_static_block(Vector2(-600, -200), Vector2(150, 20), plat_color, true)
	create_static_block(Vector2(-300, -400), Vector2(200, 20), plat_color, true)
	create_static_block(Vector2(-500, -600), Vector2(150, 20), plat_color, true)
	create_static_block(Vector2(0, -300), Vector2(200, 20), plat_color, true)
	create_static_block(Vector2(200, -550), Vector2(150, 20), plat_color, true)
	create_static_block(Vector2(400, -800), Vector2(250, 20), plat_color, true)

	# ZONA LORONG KANAN (Wall untuk taruh Torch)
	create_static_block(Vector2(640, -240), Vector2(160, 40), Color(0.1, 0.15, 0.1), true) 
	create_static_block(Vector2(560, -680), Vector2(40, 880), Color(0.1, 0.15, 0.1), true) 
	create_static_block(Vector2(740, -560), Vector2(40, 1120), Color(0.1, 0.15, 0.1), true)
	
	# Pintu Bos
	var door_boss = ColorRect.new()
	door_boss.color = Color(0.6, 0.1, 0.1)
	door_boss.position = Vector2(700, -80) 
	door_boss.size = Vector2(20, 80)
	add_child(door_boss)

func create_static_block(pos: Vector2, size: Vector2, color: Color, has_collision: bool) -> StaticBody2D:
	var body = StaticBody2D.new()
	body.position = pos
	if has_collision:
		var col = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = size
		col.shape = rect
		body.add_child(col)
	var vis = ColorRect.new()
	vis.color = color
	vis.size = size
	vis.position = -size / 2
	vis.z_index = 7 # <--- TAMBAHKAN INI (Lantai & Dinding jadi di depan layar hitam)
	body.add_child(vis)
	add_child(body)
	return body

# ==========================================
# UI INVENTORY & SWAP SYSTEM
# ==========================================
func bikin_ui_inventory():
	var canvas = CanvasLayer.new()
	canvas.layer = 15
	add_child(canvas)
	
	inventory_panel = Panel.new()
	inventory_panel.size = Vector2(560, 420) 
	inventory_panel.position = Vector2(280, 120)
	inventory_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5)
	inventory_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(inventory_panel)
	
	var title = Label.new()
	title.text = "BACKPACK"
	title.position = Vector2(20, 10)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.WHITE)
	inventory_panel.add_child(title)
	
	# HOTBAR ROW
	var hb_row = HBoxContainer.new()
	hb_row.position = Vector2(15, 50)
	hb_row.add_theme_constant_override("separation", 5)
	inventory_panel.add_child(hb_row)
	
	for i in range(7):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(55, 55) 
		var slot_style = StyleBoxFlat.new()
		if i < 3:
			slot_style.bg_color = Color(0.3, 0.1, 0.1) 
		else:
			slot_style.bg_color = Color(0.1, 0.1, 0.1, 0.8) 
		slot_style.border_width_left = 2; slot_style.border_width_top = 2; slot_style.border_width_right = 2; slot_style.border_width_bottom = 2
		slot_style.border_color = Color(0.5, 0.5, 0.5)
		slot.add_theme_stylebox_override("panel", slot_style)
		
		var lbl = Label.new()
		lbl.name = "Label"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		slot.add_child(lbl)
		
		var num_lbl = Label.new()
		num_lbl.text = str(i + 1)
		num_lbl.position = Vector2(2, -2)
		num_lbl.add_theme_font_size_override("font_size", 10)
		slot.add_child(num_lbl)
		
		hb_row.add_child(slot)
		inv_hotbar_slots.append(slot)
		
	# GRID BACKPACK
	var grid = GridContainer.new()
	grid.columns = 10
	grid.position = Vector2(15, 120) 
	inventory_panel.add_child(grid)
	
	for i in range(50):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(50, 50)
		var slot_style = StyleBoxFlat.new()
		slot_style.bg_color = Color(0.2, 0.2, 0.2)
		slot_style.border_width_left = 1; slot_style.border_width_top = 1; slot_style.border_width_right = 1; slot_style.border_width_bottom = 1
		slot_style.border_color = Color(0.4, 0.4, 0.4)
		slot.add_theme_stylebox_override("panel", slot_style)
		
		var icon = ColorRect.new()
		icon.name = "Icon"
		icon.size = Vector2(30, 30)
		icon.position = Vector2(10, 10)
		icon.visible = false
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE 
		slot.add_child(icon)
		
		var lbl = Label.new()
		lbl.name = "AmountLabel"
		lbl.position = Vector2(30, 28)
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.add_theme_constant_override("outline_size", 4)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE 
		slot.add_child(lbl)
		
		grid.add_child(slot)
		inv_slot_nodes.append(slot)

func get_backpack_items() -> Array:
	var items = []
	for item_key in Global.saved_inventory.keys():
		if Global.saved_inventory[item_key] <= 0: continue
		
		if Global.is_unique_key(item_key):
			# Weapon/armor (ada "|") — filter pakai UUID
			if Global.hotbar_uuids.has(item_key): continue
			if item_key == Global.equipped_armor_uuid: continue
		else:
			# Material (Dirt, Coal, dll) — filter pakai nama
			if Global.hotbar_items.has(item_key): continue
			if item_key == Global.equipped_armor: continue
		
		items.append(item_key)
	return items

func update_inventory_ui():
	if not inventory_panel.visible: return
	
	var items_in_backpack = get_backpack_items()

	for slot in inv_slot_nodes:
		slot.tooltip_text = ""
		slot.get_node("Icon").visible = false
		slot.get_node("AmountLabel").text = ""
		
	for i in range(min(items_in_backpack.size(), 50)):
		var item_key = items_in_backpack[i]
		var item_name = Global.get_base_name(item_key)
		var amount = Global.saved_inventory[item_key]
		var slot = inv_slot_nodes[i]
		
		if item_name == "Food Box":
			slot.tooltip_text = "Food Box\n(Right Click to open)"
		elif item_name in ["Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"]:
			var desc = main_ref.item_data.get(item_name, {}).get("desc", "")
			slot.tooltip_text = item_name + "\n" + desc + "\n(Press F to consume)"
		else:
			slot.tooltip_text = item_name
			
		var icon = slot.get_node("Icon")
		icon.color = main_ref.item_data.get(item_name, {"color": Color.WHITE})["color"]
		icon.visible = true
		
		if Global.is_unique_key(item_key):
			slot.get_node("AmountLabel").text = ""
		else:
			slot.get_node("AmountLabel").text = str(amount)
		
	for i in range(7):
		var item = Global.hotbar_items[i]
		var slot_panel = inv_hotbar_slots[i]
		var lbl = slot_panel.get_node("Label")
		
		if item != null:
			var _is_w = main_ref.item_data.get(item, {}).has("weapon_type") or item in ["Fist", "Stone Pickaxe", "Bow"]
			if _is_w:
				var _lv = Global.get_item_level(item, Global.hotbar_uuids[i])
				lbl.text = item + "\nLv. " + str(_lv)
			else:
				lbl.text = item + "\n(" + str(inventory.get(item, 0)) + ")"
			lbl.add_theme_color_override("font_color", main_ref.item_data.get(item, {"color": Color.WHITE})["color"])
		else:
			lbl.text = ""

# ==========================================
# UI CHARACTER
# ==========================================
func bikin_ui_character():
	var canvas = CanvasLayer.new()
	canvas.layer = 15
	add_child(canvas)
	
	char_panel = Panel.new()
	char_panel.size = Vector2(500, 460)
	char_panel.position = Vector2(400, 150)
	char_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5)
	char_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(char_panel)

	var title = Label.new()
	title.text = "CHARACTER (I)"
	title.position = Vector2(20, 15); title.add_theme_font_size_override("font_size", 24)
	char_panel.add_child(title)

	var armor_slot = Panel.new()
	armor_slot.size = Vector2(80, 80); armor_slot.position = Vector2(210, 60)
	var as_style = StyleBoxFlat.new(); as_style.bg_color = Color(0.2, 0.2, 0.2)
	as_style.border_width_left = 2; as_style.border_width_top = 2; as_style.border_width_right = 2; as_style.border_width_bottom = 2
	as_style.border_color = Color(0.5, 0.5, 0.5)
	armor_slot.add_theme_stylebox_override("panel", as_style)
	char_panel.add_child(armor_slot)
	
	var armor_lbl = Label.new()
	armor_lbl.name = "Label"
	armor_lbl.size = Vector2(80, 80)
	armor_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	armor_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	armor_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	armor_lbl.text = "Armor"
	armor_lbl.add_theme_font_size_override("font_size", 12)
	armor_slot.add_child(armor_lbl)
	
	armor_slot.mouse_entered.connect(func(): show_char_hover(3, true))
	armor_slot.mouse_exited.connect(func(): show_char_hover(3, false))

	var body_visual = ColorRect.new()
	body_visual.size = Vector2(64, 128); body_visual.position = Vector2(218, 150); body_visual.color = Color(0.0, 1.0, 1.0)
	char_panel.add_child(body_visual)

	var slot_names = ["Tool", "Melee", "Range"]
	var start_x = 100
	for i in range(3):
		var s = Panel.new()
		s.size = Vector2(80, 80); s.position = Vector2(start_x + (i * 100), 300)
		var st = StyleBoxFlat.new(); st.bg_color = Color(0.2, 0.2, 0.2)
		st.border_width_left = 2; st.border_width_top = 2; st.border_width_right = 2; st.border_width_bottom = 2
		st.border_color = Color(0.5, 0.5, 0.5)
		s.add_theme_stylebox_override("panel", st)
		char_panel.add_child(s)

		var lbl = Label.new()
		lbl.name = "Label"
		lbl.size = Vector2(80, 80)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		lbl.text = slot_names[i]
		lbl.add_theme_font_size_override("font_size", 12)
		s.add_child(lbl); char_slot_labels.append(lbl)

		s.mouse_entered.connect(func(): show_char_hover(i, true))
		s.mouse_exited.connect(func(): show_char_hover(i, false))
		
		char_slots_panels.append(s)
		
	char_slot_labels.append(armor_lbl)
	char_slots_panels.append(armor_slot)

	char_hover_panel = Panel.new()
	char_hover_panel.size = Vector2(480, 440)
	char_hover_panel.position = Vector2(10, 400)
	var hs = StyleBoxFlat.new(); hs.bg_color = Color(0.15, 0.15, 0.15)
	hs.border_width_left = 2; hs.border_width_top = 2; hs.border_width_right = 2; hs.border_width_bottom = 2
	hs.border_color = Color(0.8, 0.3, 0.1)
	char_hover_panel.add_theme_stylebox_override("panel", hs)
	char_hover_panel.visible = false
	char_panel.add_child(char_hover_panel)

	char_hover_name = Label.new(); char_hover_name.position = Vector2(20, 15)
	char_hover_name.add_theme_font_size_override("font_size", 22)
	char_hover_name.add_theme_color_override("font_color", Color.GOLD)
	char_hover_panel.add_child(char_hover_name)

	char_hover_stats = Label.new(); char_hover_stats.position = Vector2(20, 50)
	char_hover_stats.size = Vector2(440, 280) 
	char_hover_stats.add_theme_font_size_override("font_size", 16)
	char_hover_stats.autowrap_mode = TextServer.AUTOWRAP_WORD 
	char_hover_panel.add_child(char_hover_stats)

	var emblem_title = Label.new()
	emblem_title.name = "EmblemTitle"
	emblem_title.text = "Emblems (Coming Soon)"
	emblem_title.position = Vector2(20, 350)
	emblem_title.add_theme_font_size_override("font_size", 14)
	emblem_title.add_theme_color_override("font_color", Color.GRAY)
	char_hover_panel.add_child(emblem_title)

	var emblem_container = HBoxContainer.new()
	emblem_container.name = "EmblemSlots"
	emblem_container.position = Vector2(150, 380)
	emblem_container.add_theme_constant_override("separation", 15)
	char_hover_panel.add_child(emblem_container)

	for i in range(3):
		var em_slot = Panel.new()
		em_slot.custom_minimum_size = Vector2(50, 50)
		var em_style = StyleBoxFlat.new(); em_style.bg_color = Color(0.05, 0.05, 0.05)
		em_style.border_width_left = 2; em_style.border_width_top = 2; em_style.border_width_right = 2; em_style.border_width_bottom = 2
		em_style.border_color = Color(0.3, 0.3, 0.3)
		em_slot.add_theme_stylebox_override("panel", em_style)
		
		var em_lbl = Label.new()
		em_lbl.text = "🔒"
		em_lbl.size = Vector2(50, 50)
		em_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		em_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		em_lbl.add_theme_font_size_override("font_size", 20)
		em_slot.add_child(em_lbl)
		
		emblem_container.add_child(em_slot)

func show_char_hover(index, is_hovering):
	if not is_hovering:
		char_hover_panel.visible = false
		return
		
	var item = null
	if index == 3:
		item = Global.equipped_armor
	else:
		item = Global.hotbar_items[index]
		
	if item == null:
		char_hover_name.text = "[ Empty Slot ]"
		char_hover_stats.text = "No equipment."
		char_hover_panel.visible = true
		char_hover_panel.get_node("EmblemTitle").visible = false
		char_hover_panel.get_node("EmblemSlots").visible = false
		return
		
	char_hover_panel.get_node("EmblemTitle").visible = true
	char_hover_panel.get_node("EmblemSlots").visible = true
	
	var _uid = Global.equipped_armor_uuid if index == 3 else Global.hotbar_uuids[index]
	var data = Global.get_effective_stats(item, main_ref.item_data.get(item, {}), _uid)
	char_hover_name.text = item
	char_hover_panel.visible = true
	
	var stats_text = ""
	var is_upg = Global.is_upgradeable(item)
	var max_lv_text = str(Global.MAX_ITEM_LEVEL) if is_upg else "1"
	stats_text += "Level: " + str(Global.get_item_level(item, _uid)) + " / " + max_lv_text + "\n"
	if not is_upg:
		stats_text += "(Starter weapon - Unupgradeable)\n"
	stats_text += "------------------------\n"
	
	stats_text += "Type: " + str(data.get("weapon_type", "None")) + "\n"
	
	var trait_str = str(data.get("trait", "")).strip_edges()
	if trait_str != "" and trait_str != "null":
		stats_text += "Trait: " + trait_str + "\n"
		
	stats_text += "\n"
	
	if str(data.get("weapon_type", "")) == "Armor":
		stats_text += "Damage Reduction: " + str(data.get("damage_reduction", 0)) + "\n"
	else:
		stats_text += "ATK: " + str(data.get("damage", 0)) + "\n"
		stats_text += "Range: " + str(int(data.get("range", 0) / 16.0)) + " blocks\n"
		stats_text += "Speed: " + str(data.get("attack_speed", 0)) + "s\n"
		if data.has("charge_damage"):
			if item == "Marble Slingshot":
				var pellet = int(data.get("damage", 15) * 0.5)
				stats_text += "Charge DMG: " + str(pellet) + "x8 Projectiles\n"
			else:
				stats_text += "Charge DMG: " + str(data["charge_damage"]) + "\n"
		if data.has("efficiency"): 
			stats_text += "Efficiency: " + str(data["efficiency"]) + "\n"
		
	var passive_str = str(data.get("passive", "")).strip_edges()
	if passive_str == "" or passive_str == "null" or passive_str == "None (Basic)":
		passive_str = "None"
		
	stats_text += "\nPassive:\n" + passive_str
	char_hover_stats.text = stats_text

func update_char_ui():
	for i in range(3):
		if Global.hotbar_items[i] != null:
			var lv = Global.get_item_level(Global.hotbar_items[i])
			char_slot_labels[i].text = Global.hotbar_items[i] + "\nLv. " + str(lv)
		else:
			char_slot_labels[i].text = "Empty"
			
	if Global.equipped_armor != null:
		var lv = Global.get_item_level(Global.equipped_armor)
		char_slot_labels[3].text = Global.equipped_armor + "\nLv. " + str(lv)
	else:
		char_slot_labels[3].text = "Empty"

# ==========================================
# INPUT HANDLING (SWAP + KONSUMSI)
# ==========================================
func _input(event: InputEvent) -> void:
	# --- MOUSE WHEEL CYCLE HOTBAR ---
	if event is InputEventMouseButton and event.pressed \
	   and not is_inventory_open and not is_char_open \
	   and not is_transitioning and not is_player_dead:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Sfx.play("tick") # <--- TAMBAHKAN BARIS INI
			_change_hotbar_slot_domain(-1)
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Sfx.play("tick") # <--- TAMBAHKAN BARIS INI
			_change_hotbar_slot_domain(1)
			return
	
	if event is InputEventKey and event.pressed and not event.echo:
		
		if event.keycode == KEY_E:
			if is_transitioning: return # Cegah spam saat layar lagi gelap
			
			# --- LANGKAH KELUAR (Di cek duluan) ---
			# 1. Buka Peti
			if is_instance_valid(boss_chest) and clone_player.global_position.distance_to(boss_chest.global_position) < 100:
				open_boss_chest()
				return
				
			# 2. Keluar dari Ruangan Bos (Pintu Kiri) - BISA KAPAN SAJA selama fight
			if is_boss_fight_started:
				if clone_player.global_position.x > 630 and clone_player.global_position.x < 800:
					exit_boss_room()
					return
					
			# 3. Keluar dari Domain (Pintu Utama, X = -1900)
			if clone_player.global_position.x < -1800:
				close_domain()
				return

			# --- LANGKAH MASUK ---
			# 4. Masuk ke Ruangan Bos (Pintu Kanan)
			if not is_boss_fight_started and not is_boss_defeated:
				if clone_player.global_position.x > 630 and clone_player.global_position.x < 720:
					start_boss_fight()
					return
					
		elif event.keycode == KEY_ESCAPE:
			close_domain() # Tetap biarkan ESC sebagai jalan pintas darurat
		elif event.keycode == KEY_B:
			is_inventory_open = !is_inventory_open
			inventory_panel.visible = is_inventory_open
			is_char_open = false
			char_panel.visible = false
			update_inventory_ui()
		elif event.keycode == KEY_I:
			is_char_open = !is_char_open
			char_panel.visible = is_char_open
			is_inventory_open = false
			inventory_panel.visible = false
			update_char_ui()
		elif event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7]:
			var new_idx = event.keycode - KEY_1
			if new_idx != main_ref.selected_hotbar_index:
				main_ref.selected_hotbar_index = new_idx
				attack_cooldown = 0.0
				sgs_hit_counter = 0
				sgs_accelerate_stacks = 0
				revenger_stacks = 0
				revenger_target = null
				conductor_charging = false
				conductor_charge_timer = 0.0
				conductor_tick_timer = 0.0
				hammer_charging = false
				hammer_charge_timer = 0.0
				stormjade_charging = false
				stormjade_charge_timer = 0.0
				update_hud()
				
		elif event.keycode == KEY_F:
			if is_inventory_open:
				var mouse_pos = get_viewport().get_mouse_position()
				var food_list = ["Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"]
				
				var items_in_backpack = get_backpack_items()
				
				for i in range(inv_slot_nodes.size()):
					if inv_slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size():
							var item = items_in_backpack[i]
							if item in food_list: consume_food(item)
						return
				
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if Global.hotbar_items[i] in food_list: consume_food(Global.hotbar_items[i])
						return
			else:
				var held = Global.hotbar_items[main_ref.selected_hotbar_index]
				if held in ["Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"]:
					consume_food(held)

	# --- LOGIKA KLIK KIRI (SWAP ITEM) ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		if is_inventory_open:
			var clicked_something = false
			for i in range(7): 
				if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
					clicked_something = true
					if i < 3:
						show_floating_text("Weapons are locked! Change them in Home.", clone_player.global_position, Color.RED)
					else:
						if selected_inv_item != null:
							var w_type = main_ref.item_data.get(selected_inv_item, {}).get("weapon_type", "")
							if w_type != "" or selected_inv_item in ["Fist", "Stone Pickaxe", "Bow", "Wooden Sword"]:
								show_floating_text("Cannot put weapons in Hotbar!", clone_player.global_position, Color.RED)
								return
								
							Global.hotbar_items[i] = selected_inv_item
							selected_inv_item = null
						elif Global.hotbar_items[i] != null:
							Global.hotbar_items[i] = null
						update_hud()
						update_inventory_ui()
					break
			if not clicked_something:
				for i in range(inv_slot_nodes.size()):
					if inv_slot_nodes[i].get_global_rect().has_point(mouse_pos):
						var items_in_backpack = get_backpack_items()
						if i < items_in_backpack.size():
							var item_name = items_in_backpack[i]
							var w_type = main_ref.item_data.get(item_name, {}).get("weapon_type", "")
							
							if w_type != "" or item_name in ["Fist", "Stone Pickaxe", "Bow", "Wooden Sword"]:
								show_floating_text("Weapons are locked!", clone_player.global_position, Color.RED)
							else:
								selected_inv_item = item_name
								show_floating_text("Selected: " + selected_inv_item, clone_player.global_position)
						break
			return

	# --- LOGIKA KLIK KANAN (FOOD BOX / BOW) ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			if is_inventory_open:
				var mouse_pos = get_viewport().get_mouse_position()
				var items_in_backpack = get_backpack_items()
						
				for i in range(inv_slot_nodes.size()):
					if inv_slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size() and items_in_backpack[i] == "Food Box":
							use_food_box()
						return
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if Global.hotbar_items[i] == "Food Box":
							use_food_box()
						return
			else:
				var held = Global.hotbar_items[main_ref.selected_hotbar_index]
				if held == "Food Box": use_food_box()
				elif held in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow", "Headhitter Heavy Bow"]:
					is_charging_bow = true
					show_floating_text("Charging...", clone_player.global_position, Color.CYAN)
				elif held == "Crystal Hammer":
					hammer_charging = true
					hammer_charge_timer = 0.0
				elif held == "Stormjade Cutter":
					stormjade_charging = true
					stormjade_charge_timer = 0.0
				elif held == "Galahad Chimelin" and galahad_parry_cd <= 0.0:
					galahad_parry_active = true
					galahad_parry_cd = 3.0
					show_floating_text("PARRY!", clone_player.global_position, Color.GOLD)
					await get_tree().create_timer(0.5).timeout
					galahad_parry_active = false
		else:
			var held = Global.hotbar_items[main_ref.selected_hotbar_index]
			if held in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow", "Headhitter Heavy Bow"] and is_charging_bow:
				is_charging_bow = false
				if attack_cooldown <= 0:
					try_attack(get_global_mouse_position(), true)
			
			# --- CRYSTAL HAMMER: charge release ---
			if held == "Crystal Hammer" and hammer_charging:
				hammer_charging = false
				if attack_cooldown <= 0:
					if hammer_charge_timer >= 2.0:
						var _facing = sign(get_global_mouse_position().x - clone_player.global_position.x)
						if _facing == 0: _facing = 1
						var _reach = 80.0
						var _player_bottom = clone_player.global_position.y + 32
						var _stun_dmg = int(48 * main_ref.buff_dmg_mult)
						for _e in enemies.duplicate():
							if not is_instance_valid(_e): continue
							if _e.is_queued_for_deletion(): continue
							
							var _dx = _e.global_position.x - clone_player.global_position.x
							if _facing > 0 and (_dx < -16 or _dx > _reach): continue
							if _facing < 0 and (_dx > 16 or _dx < -_reach): continue
							
							var _e_size_h = _e.get_meta("size_h", _e.get_meta("size", 16.0))
							var _e_bottom = _e.global_position.y + _e_size_h / 2.0
							var _tol = max(32.0, _e_size_h / 2.0 + 8.0)
							if abs(_e_bottom - _player_bottom) > _tol: continue
							
							damage_enemy(_e, _stun_dmg, false)
							if is_instance_valid(_e) and not _e.is_queued_for_deletion():
								_e.set_meta("terrified_timer", 1.5)
								show_floating_text("STUN!", _e.global_position + Vector2(0, -40), Color.CYAN)
						attack_cooldown = 1.0
					else:
						try_attack(get_global_mouse_position(), false)
				hammer_charge_timer = 0.0
			
			# --- STORMJADE: charge release ---
			if held == "Stormjade Cutter" and stormjade_charging:
				stormjade_charging = false
				if attack_cooldown <= 0:
					if stormjade_charge_timer >= 3.0:
						var _dir = (get_global_mouse_position() - clone_player.global_position).normalized()
						var _max_dist = 128.0
						
						var _space = get_world_2d().direct_space_state
						var _q = PhysicsRayQueryParameters2D.create(clone_player.global_position, clone_player.global_position + _dir * _max_dist, 1, [clone_player])
						var _hit = _space.intersect_ray(_q)
						if _hit and not (_hit.collider is CharacterBody2D):
							_max_dist = max(8.0, clone_player.global_position.distance_to(_hit.position) - 16.0)
						
						var _end = clone_player.global_position + _dir * _max_dist
						var _dash_rect = Rect2(clone_player.global_position, _end - clone_player.global_position)
						_dash_rect = _dash_rect.abs().grow(30.0)
						var _base_dmg = int(25 * 1.5 * main_ref.buff_dmg_mult)
						var _hit_count = 0
						var _hit_enemies = []
						for _e in enemies.duplicate():
							if is_instance_valid(_e) and _dash_rect.has_point(_e.global_position) and _e not in _hit_enemies:
								var _this_dmg = int(_base_dmg * (1.0 + _hit_count * 0.25))
								damage_enemy(_e, _this_dmg, false)
								_hit_enemies.append(_e)
								_hit_count += 1
								if _hit_count >= 8: break
						clone_player.global_position = _end
						attack_cooldown = 1.0
					else:
						try_attack(get_global_mouse_position(), false)
				stormjade_charge_timer = 0.0

func use_food_box():
	if inventory.get("Food Box", 0) <= 0: return
	inventory["Food Box"] -= 1
	if inventory["Food Box"] <= 0: 
		inventory.erase("Food Box")
		for i in range(7):
			if Global.hotbar_items[i] == "Food Box": Global.hotbar_items[i] = null
			
	var roll = randf()
	var food_name = ""
	if roll < 0.40: food_name = "Banana"
	elif roll < 0.60: food_name = "Grape"
	elif roll < 0.75: food_name = "Bacon"
	elif roll < 0.825: food_name = "Pizza Slice"
	elif roll < 0.90: food_name = "Burger"
	elif roll < 0.95: food_name = "Golden Burger"
	else: food_name = "Frozen Apple"
		
	inventory[food_name] = inventory.get(food_name, 0) + 1
	show_floating_text(food_name + " (1)", clone_player.global_position)
	update_inventory_ui()
	update_hud()

func consume_food(food_name):
	if inventory.get(food_name, 0) <= 0: return
	
	inventory[food_name] -= 1
	if inventory[food_name] <= 0: 
		inventory.erase(food_name)
		for i in range(7):
			if Global.hotbar_items[i] == food_name: Global.hotbar_items[i] = null
			
	if food_name == "Banana": 
		player_hp = min(player_hp + 20, main_ref.max_hp)
		update_hud()
		show_floating_text("+20 HP", clone_player.global_position, Color.GREEN)
	elif food_name == "Grape": 
		show_floating_text("Regen Active", clone_player.global_position, Color.GREEN)
		player_hp = min(player_hp + 30, main_ref.max_hp) 
		update_hud()
	elif food_name == "Bacon": 
		player_hp = min(player_hp + 30, main_ref.max_hp)
		update_hud()
		show_floating_text("+30 HP", clone_player.global_position, Color.GREEN)
	elif food_name == "Pizza Slice": 
		player_hp = min(player_hp + 5, main_ref.max_hp)
		update_hud()
		show_floating_text("+5 HP", clone_player.global_position, Color.GREEN)
	elif food_name == "Burger": 
		show_floating_text("Speed UP", clone_player.global_position, Color.GREEN)
	elif food_name == "Golden Burger": 
		show_floating_text("INVINCIBLE", clone_player.global_position, Color.GOLD)
	elif food_name == "Frozen Apple": 
		show_floating_text("Enemies Frozen", clone_player.global_position, Color.CYAN)
		
	update_hud()
	update_inventory_ui()

# ==========================================
# SISA FUNGSI
# ==========================================
func try_attack(mouse_world_pos, is_charged):
	var held_item = Global.hotbar_items[main_ref.selected_hotbar_index]
	var held_uuid = Global.hotbar_uuids[main_ref.selected_hotbar_index]
	if held_uuid == null: held_uuid = ""
	if held_item == null: return false
	var item_stats = Global.get_effective_stats(held_item, main_ref.item_data.get(held_item, {}), held_uuid)
	# --- RADIANCE SCEPTER: Self-Heal Utility ---
	if held_item == "Radiance Scepter":
		if attack_cooldown > 0: return true
		var _mana_cost = item_stats.get("mana_cost", 25)
		if player_mana < _mana_cost:
			show_floating_text("Not enough Mana!", clone_player.global_position, Color.BLUE)
			attack_cooldown = 0.5
			return true
		player_mana -= _mana_cost
				
		var _heal = item_stats.get("heal_amount", 12)
		var _lv = Global.get_item_level("Radiance Scepter")
		if _lv > 1:
			_heal = int(_heal * (1.0 + 0.1 * (_lv - 1)))
		player_hp = min(player_hp + _heal, main_ref.max_hp)
		attack_cooldown = item_stats.get("attack_speed", 1.5) / main_ref.buff_atk_speed_mult
				
		show_floating_text("+" + str(_heal) + " HP", clone_player.global_position + Vector2(0, -40), Color.GREEN)
				
		var _heal_fx = ColorRect.new()
		_heal_fx.size = Vector2(60, 60)
		_heal_fx.position = clone_player.global_position - Vector2(30, 30)
		_heal_fx.color = Color(1.0, 0.9, 0.5, 0.6)
		_heal_fx.z_index = 15
		add_child(_heal_fx)
		var _ht = create_tween()
		_ht.tween_property(_heal_fx, "scale", Vector2(1.8, 1.8), 0.3)
		_ht.parallel().tween_property(_heal_fx, "modulate:a", 0.0, 0.3)
		_ht.tween_callback(_heal_fx.queue_free)
				
		update_hud()
		return true
	# -------------------------------------------
	
	if held_item == "Heretic Staff":
		if attack_cooldown > 0: return true
		var mana_cost = item_stats.get("mana_cost", 20)
		if player_mana < mana_cost:
			show_floating_text("Not enough Mana!", clone_player.global_position, Color.BLUE)
			attack_cooldown = 0.5
			return true
		player_mana -= mana_cost
		attack_cooldown = item_stats.get("attack_speed", 1.2) / main_ref.buff_atk_speed_mult
		
		# Cari musuh terdekat di dekat kursor (dalam range)
		var _hs_target = null
		var _hs_closest = item_stats.get("range", 384.0)
		for _e in enemies:
			if is_instance_valid(_e):
				var _d = mouse_world_pos.distance_to(_e.global_position)
				if _d < _hs_closest:
					_hs_closest = _d
					_hs_target = _e
		
		# Beam visual (ke musuh kalau ada, ke kursor kalau kosong)
		var line = Line2D.new()
		line.add_point(clone_player.global_position)
		if _hs_target != null:
			line.add_point(_hs_target.global_position)
		else:
			line.add_point(mouse_world_pos)
		line.width = 3.0
		line.default_color = Color(0.8, 0.2, 1.0)
		add_child(line)
		var t = create_tween()
		t.tween_property(line, "modulate:a", 0.0, 0.3)
		t.tween_callback(line.queue_free)
		
		# Damage (magic bypass resistance — sama seperti main.gd)
		if _hs_target != null:
			var _hs_dmg = int(item_stats.get("damage", 32) * main_ref.buff_dmg_mult)
			var _hs_hp = _hs_target.get_meta("hp") - _hs_dmg
			_hs_target.set_meta("hp", _hs_hp)
			var _hs_bar = _hs_target.get_meta("hp_bar", null)
			if _hs_bar:
				_hs_bar.size.x = 30.0 * (float(max(_hs_hp, 0)) / _hs_target.get_meta("max_hp"))
			show_floating_text(str(_hs_dmg), _hs_target.global_position + Vector2(0, -20), Color.MEDIUM_PURPLE)
			
			# 70% terrify
			if randf() < 0.7:
				_hs_target.set_meta("terrified_timer", 1.5)
				show_floating_text("TERRIFIED!", _hs_target.global_position + Vector2(0, -40), Color.PURPLE)
			
		# Death handling (boss & non-boss)
			# 70% terrify
			if randf() < 0.7:
				_hs_target.set_meta("terrified_timer", 1.5)
				show_floating_text("TERRIFIED!", _hs_target.global_position + Vector2(0, -40), Color.PURPLE)
			
			# Death handling (boss & non-boss) — DI DALAM null check
			if _hs_hp <= 0:
				if "boss" in _hs_target.get_meta("type"):
					show_floating_text("BOSS DEFEATED!", _hs_target.global_position + Vector2(0, -60), Color.GOLD)
					if is_instance_valid(boss_ui): boss_ui.visible = false
					is_boss_defeated = true
					spawn_boss_chest()
				enemies.erase(_hs_target)
				_hs_target.queue_free()
		
		update_hud()
		return true
	
	if held_item == "Crystal Minigun":
		if attack_cooldown > 0: return true
		if minigun_exhausted_timer > 0:
			show_floating_text("COOLDOWN!", clone_player.global_position, Color.RED)
			return true
		if inventory.get("Minigun Ammo", 0) <= 0:
			show_floating_text("No Ammo!", clone_player.global_position, Color.RED)
			attack_cooldown = 0.5
			return true
		
		inventory["Minigun Ammo"] -= 1
		if inventory["Minigun Ammo"] <= 0:
			inventory.erase("Minigun Ammo")
		update_inventory_ui()
		update_hud()
		
		minigun_fire_timer += 0.1
		if minigun_fire_timer >= 12.0:
			minigun_exhausted_timer = 4.0
			minigun_fire_timer = 0.0
		
		attack_cooldown = item_stats.get("attack_speed", 0.1) / main_ref.buff_atk_speed_mult
		var _mg_dmg = int(item_stats.get("damage", 12) * main_ref.buff_dmg_mult)
		var _mg_range = item_stats.get("range", 208.0)
		
		minigun_shot_count += 1
		if minigun_shot_count >= 10:
			minigun_shot_count = 0
			spawn_minigun_boulder(clone_player.global_position, get_global_mouse_position(), int(_mg_dmg * 1.3))
		
		for _e in enemies.duplicate():
			if not is_instance_valid(_e): continue
			if clone_player.global_position.distance_to(_e.global_position) > _mg_range: continue
			damage_enemy(_e, _mg_dmg, false)
		
		var _mg_beam = Line2D.new()
		_mg_beam.add_point(clone_player.global_position)
		_mg_beam.add_point(get_global_mouse_position())
		_mg_beam.width = 2.0
		_mg_beam.default_color = Color(0.8, 0.2, 0.5, 0.8)
		add_child(_mg_beam)
		var _mg_t = create_tween()
		_mg_t.tween_property(_mg_beam, "modulate:a", 0.0, 0.1)
		_mg_t.tween_callback(_mg_beam.queue_free)
		
		return true
	
	if held_item in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow", "Headhitter Heavy Bow"]:
		if attack_cooldown > 0: return true
		if inventory.get("Arrow", 0) <= 0:
			show_floating_text("No Ammo!", clone_player.global_position)
			attack_cooldown = 0.5
			return true
		inventory["Arrow"] -= 1
		if inventory["Arrow"] <= 0: inventory.erase("Arrow")
		update_inventory_ui()
		update_hud()
		
		var base_bow_dmg = (item_stats.get("charge_damage", 20) if is_charged else item_stats.get("damage", 7))
		if held_item == "Bounty Bow":
			base_bow_dmg = int(base_bow_dmg * (1.0 + bounty_bow_stacks * 0.20))
		var dmg = int(base_bow_dmg * main_ref.buff_dmg_mult)
		
		var base_cd = item_stats.get("charge_speed", 1.0) if is_charged else item_stats.get("attack_speed", 0.5)
		attack_cooldown = base_cd / main_ref.buff_atk_speed_mult
		
		# --- MARBLE SLINGSHOT: split 8 proyektil (shotgun burst) ---
		if held_item == "Marble Slingshot" and is_charged:
			var _pellet_dmg = max(1, int(item_stats.get("damage", 15) * main_ref.buff_dmg_mult * 0.5))
			for _i in range(8):
				var _off = -20.0 + (40.0 / 7.0) * _i
				var _dir = (mouse_world_pos - clone_player.global_position).normalized().rotated(deg_to_rad(_off))
				var _tgt = clone_player.global_position + _dir * 500.0
				spawn_arrow(clone_player.global_position, _tgt, _pellet_dmg, true, "Marble Slingshot", 0.0)
		else:
			# Stun duration untuk Mourning Bow charge
			var _stun_dur = 0.0
			if held_item == "Mourning Bow" and is_charged:
				_stun_dur = 2.0
			spawn_arrow(clone_player.global_position, mouse_world_pos, int(base_bow_dmg), is_charged, held_item, _stun_dur)
		return true
		
	# LOGIKA MELEE (TANPA CRIT)
	if not item_stats.has("damage"): return false 
	attack_cooldown = item_stats["attack_speed"] / main_ref.buff_atk_speed_mult
	
	if held_item == "Swarmid Drill" and swarmid_exhausted_timer > 0:
		show_floating_text("EXHAUSTED!", clone_player.global_position, Color.RED)
		return true
		
	# --- MANIACAL CHAINSAW EXHAUSTED ---
	if held_item == "Maniacal Chainsaw":
		if chainsaw_exhausted_timer > 0:
			show_floating_text("EXHAUSTED!", clone_player.global_position, Color.RED)
			return true
		chainsaw_use_timer += 0.1
		if chainsaw_use_timer >= 10.0:
			chainsaw_exhausted_timer = 4.0
			chainsaw_use_timer = 0.0
	
	# --- SILVER GRAY SWORD: Accelerate speed bonus ---
	if held_item == "Silver Gray Sword" and sgs_accelerate_stacks > 0:
		attack_cooldown = attack_cooldown / (1.0 + sgs_accelerate_stacks * 0.10)
	# ------------------------------------------------
	
	# --- HIT MINION (MELEE) ---
	var attack_range = item_stats.get("range", 64.0)
	var base_dmg = int(item_stats.get("damage", 10) * main_ref.buff_dmg_mult)
	var knockback_power = item_stats.get("knockback", 0.0) # Ambil nilai knockback dari senjata
	
	for e in enemies:
		if is_instance_valid(e):
			# Cek jarak player ke minion
			if clone_player.global_position.distance_to(e.global_position) <= (attack_range + 20):
				var _melee_dmg = base_dmg
				
				# --- SHARDING SWORD: magic vuln apply to magic damage ---
				if item_stats.get("weapon_type") == "Magic Damage":
					var _mv = e.get_meta("magic_vuln", 0.0)
					if _mv > 0.0:
						_melee_dmg = int(_melee_dmg * (1.0 + _mv))
				
				# --- GALAHAD: stack dmg ---
				if held_item == "Galahad Chimelin":
					_melee_dmg = int(_melee_dmg * (1.0 + galahad_stacks * 0.01))
				
				# --- IRON SWORD: 3rd hit +20% ---
				if held_item == "Iron Sword":
					sword_combo += 1
					if sword_combo >= 3:
						_melee_dmg = int(_melee_dmg * 1.2)
						sword_combo = 0
						show_floating_text("PASSIVE!", e.global_position + Vector2(0, -40), Color.GOLD)
				else:
					sword_combo = 0
				
				# --- BLEED VULN ---
				if e.get_meta("bleed_dmg", 0) > 0:
					_melee_dmg = int(_melee_dmg * 1.15)
				
				# --- DAGGER POISON ---
				if held_item == "Menacing Dagger" and randf() < 0.3:
					e.set_meta("poison_dmg", max(1, int(_melee_dmg * 0.25)))
					e.set_meta("poison_tick", 0.0)
					e.set_meta("poison_rem", 5)
					show_floating_text("POISON!", e.global_position + Vector2(0, -60), Color.GREEN)
				
				# --- CHAINSAW BLEED ---
				if held_item == "Maniacal Chainsaw" and randf() < 0.4:
					e.set_meta("bleed_dmg", max(1, int(_melee_dmg * 0.15)))
					e.set_meta("bleed_tick", 0.0)
					e.set_meta("bleed_rem", 5)
					show_floating_text("BLEED!", e.global_position + Vector2(0, -60), Color.RED)
				
				# --- SHARDING SWORD: apply vuln stack (max 3 = 60%, 5s per target) ---
				if held_item == "Sharding Sword":
					var _cv = e.get_meta("magic_vuln", 0.0)
					var _new_vuln = min(_cv + 0.2, 0.6)
					e.set_meta("magic_vuln", _new_vuln)
					e.set_meta("magic_vuln_timer", 5.0)
					show_floating_text("Magic Vuln " + str(int(_new_vuln * 100)) + "%", e.global_position + Vector2(0, -80), Color.PURPLE)
													
				# --- REVENGER: boost vs attacker ---
				if held_item == "Revenger Crystallinum" and e == revenger_target and revenger_stacks > 0:
					_melee_dmg = int(_melee_dmg * (1.0 + revenger_stacks * 0.30))
				# ------------------------------------
				
				# --- GALAHAD: stack on kill ---
				var _pre_hp = e.get_meta("hp", 0)
				damage_enemy(e, _melee_dmg, true)
				
				# --- SILVER GRAY SWORD: Accelerate stack ---
				if held_item == "Silver Gray Sword":
					set_meta("sgs_reset_timer", 5.0)
					sgs_hit_counter += 1
					if sgs_hit_counter >= 5:
						sgs_hit_counter = 0
						if sgs_accelerate_stacks < 5:
							sgs_accelerate_stacks += 1
							show_floating_text("Accelerate " + str(sgs_accelerate_stacks) + "/5", e.global_position + Vector2(0, -80), Color.CYAN)
				# -------------------------------------------
				
				if held_item == "Galahad Chimelin" and is_instance_valid(e) and e.get_meta("hp", 0) <= 0 and _pre_hp > 0:
					galahad_stacks = min(galahad_stacks + 1, 80)
					show_floating_text("+" + str(galahad_stacks) + "% DMG", clone_player.global_position + Vector2(0, -60), Color.GOLD)
				
				# Terapkan Knockback
				if knockback_power > 0 and is_instance_valid(e):
					var dir = sign(e.global_position.x - clone_player.global_position.x)
					e.global_position.x += dir * knockback_power
					if e.get_meta("type") == "spider":
						e.velocity.x = dir * 600.0
						e.velocity.y = -300.0
						e.set_meta("knockback_timer", 1.0)
						
				break
	# ---------------------------
	# ---------------------------

	var slash = ColorRect.new()
	slash.size = Vector2(40, 10)
	slash.color = Color(1, 1, 1, 0.5)
	slash.position = clone_player.global_position + (mouse_world_pos - clone_player.global_position).normalized() * 30 - Vector2(20, 5)
	add_child(slash)
	var t = create_tween()
	t.tween_property(slash, "modulate:a", 0.0, 0.2)
	t.tween_callback(slash.queue_free)
	return true

func spawn_arrow(start_pos: Vector2, target_pos: Vector2, damage: int, is_charged: bool, weapon_name: String = "", stun_duration: float = 0.0):
	var arrow = ColorRect.new()
	arrow.size = Vector2(12, 4)
	arrow.color = Color(0.8, 0.8, 0.8)
	# Warna khusus untuk tiap weapon
	if weapon_name == "Mourning Bow": arrow.color = Color(0.2, 0.6, 0.8)
	elif weapon_name == "Marble Slingshot": arrow.color = Color(0.8, 0.8, 0.9)
	elif weapon_name == "Explosive Crossbow": arrow.color = Color(1.0, 0.6, 0.1)
	arrow.position = start_pos
	arrow.z_index = 15
	arrow.set_meta("velocity", (target_pos - start_pos).normalized() * 600.0)
	arrow.set_meta("damage", damage)
	arrow.set_meta("life_timer", 1.5)
	arrow.set_meta("weapon", weapon_name)
	arrow.set_meta("is_charged", is_charged)
	arrow.set_meta("hit_enemies", [])
	if stun_duration > 0.0:
		arrow.set_meta("stun_duration", stun_duration)
	arrow.rotation = (target_pos - start_pos).angle()
	add_child(arrow)
	arrows.append(arrow)
	
func spawn_minigun_boulder(start_pos: Vector2, target_pos: Vector2, dmg: int):
	var boulder = ColorRect.new()
	boulder.size = Vector2(24, 24)
	boulder.color = Color(0.8, 0.3, 0.5)
	boulder.position = start_pos - Vector2(12, 12)
	boulder.z_index = 15
	boulder.set_meta("velocity", (target_pos - start_pos).normalized() * 500.0)
	boulder.set_meta("damage", dmg)
	boulder.set_meta("life_timer", 1.5)
	boulder.set_meta("is_player_boulder", true)
	add_child(boulder)
	arrows.append(boulder)

func explode_player_boulder(pos: Vector2, dmg: int):
	var _radius = 48.0
	var _aoe = Rect2(pos - Vector2(_radius, _radius), Vector2(_radius * 2, _radius * 2))
	
	for _e in enemies.duplicate():
		if not is_instance_valid(_e): continue
		var _sz = _e.get_meta("size", 16.0)
		var _rect = Rect2(_e.global_position - Vector2(_sz/2.0, _sz/2.0), Vector2(_sz, _sz))
		if _aoe.intersects(_rect):
			damage_enemy(_e, dmg, false)
	
	var _exp = ColorRect.new()
	_exp.size = Vector2(_radius * 2, _radius * 2)
	_exp.position = pos - Vector2(_radius, _radius)
	_exp.color = Color(0.8, 0.3, 0.5, 0.8)
	_exp.z_index = 15
	add_child(_exp)
	var _t = create_tween()
	_t.tween_property(_exp, "scale", Vector2(1.5, 1.5), 0.2)
	_t.parallel().tween_property(_exp, "modulate:a", 0.0, 0.2)
	_t.tween_callback(_exp.queue_free)

func trigger_crossbow_explosion(pos: Vector2, damage: int):
	var _radius = 64.0
	var _aoe_rect = Rect2(pos - Vector2(_radius, _radius), Vector2(_radius * 2, _radius * 2))
	
	for _e in enemies.duplicate():
		if not is_instance_valid(_e): continue
		if _e.is_queued_for_deletion(): continue
		if not (_e in enemies): continue
		
		var _sz = _e.get_meta("size", 16.0)
		var _e_rect = Rect2(_e.global_position - Vector2(_sz/2.0, _sz/2.0), Vector2(_sz, _sz))
		if _aoe_rect.intersects(_e_rect):
			damage_enemy(_e, damage, false)
			if is_instance_valid(_e) and not _e.is_queued_for_deletion() and (_e in enemies):
				show_floating_text("AOE!", _e.global_position + Vector2(0, -30), Color.ORANGE)
	
	var _exp = ColorRect.new()
	_exp.size = Vector2(_radius * 2, _radius * 2)
	_exp.position = pos - Vector2(_radius, _radius)
	_exp.color = Color(1.0, 0.5, 0.0, 0.8)
	_exp.z_index = 15
	add_child(_exp)
	var _t = create_tween()
	_t.tween_property(_exp, "scale", Vector2(1.5, 1.5), 0.2)
	_t.parallel().tween_property(_exp, "modulate:a", 0.0, 0.2)
	_t.tween_callback(_exp.queue_free)

func update_arrows(delta):
	for i in range(arrows.size() - 1, -1, -1):
		var arrow = arrows[i]
		if not is_instance_valid(arrow):
			arrows.remove_at(i)
			continue
			
		var vel = arrow.get_meta("velocity")
		arrow.position += vel * delta
		arrow.rotation = vel.angle()
		var hit = false
		var owner_type = arrow.get_meta("owner", "player")
		
		# --- FIX 1: CEK BATAS JARAK PROYEKTIL MUSUH ---
		if arrow.has_meta("spawn_pos") and arrow.has_meta("max_distance"):
			if arrow.position.distance_to(arrow.get_meta("spawn_pos")) > arrow.get_meta("max_distance"):
				arrow.queue_free()
				arrows.remove_at(i)
				continue
		# ----------------------------------------------
		
		# --- PLAYER BOULDER (Crystal Minigun) ---
		if arrow.get_meta("is_player_boulder", false):
			var _bhit = false
			# Kena musuh?
			for _e in enemies:
				if is_instance_valid(_e) and arrow.position.distance_to(_e.global_position) < 30:
					_bhit = true
					break
			# Kena dinding (StaticBody2D)?
			if not _bhit:
				var _space_b = get_world_2d().direct_space_state
				var _q_b = PhysicsPointQueryParameters2D.new()
				_q_b.position = arrow.position
				_q_b.collision_mask = 1
				var _res_b = _space_b.intersect_point(_q_b)
				for _r_b in _res_b:
					if _r_b.collider is StaticBody2D:
						_bhit = true
						break
			# Lifetime habis?
			var _bl = arrow.get_meta("life_timer", 1.5) - delta
			arrow.set_meta("life_timer", _bl)
			if _bl <= 0:
				_bhit = true
			if _bhit:
				explode_player_boulder(arrow.position, arrow.get_meta("damage"))
				arrow.queue_free()
				arrows.remove_at(i)
				continue
		
		# Tambahkan gravitasi untuk jaring & panah pantul
		if arrow.get_meta("proj_type", "") in ["falling_web", "sticky_web"]:
			if vel != Vector2.ZERO:
				vel.y += 980.0 * delta
				arrow.set_meta("velocity", vel)
		elif arrow.get_meta("is_deflected", false): # <--- KUNCI PARABOLA PANAH
			vel.y += 980.0 * delta
			arrow.set_meta("velocity", vel)
				
		arrow.position += vel * delta
		arrow.rotation = vel.angle()
		
		# --- CEK JARING JATUH & STICKY WEB ---
		if arrow.get_meta("proj_type", "") in ["falling_web", "sticky_web"]:
			# Cek tabrakan dengan player
			if arrow.position.distance_to(clone_player.global_position) < 40:
				player_stun_timer = 2.0
				show_floating_text("STUNNED!", clone_player.global_position + Vector2(0, -40), Color.WHITE)
				arrow.queue_free()
				arrows.remove_at(i)
				continue
			
			# Jika menyentuh tanah (Y >= 0)
			if arrow.position.y >= 0:
				if arrow.get_meta("proj_type", "") == "sticky_web":
					arrow.position.y = 0 # Tempel di permukaan lantai
					
					# Jika masih bergerak (baru mendarat)
					if arrow.get_meta("velocity", Vector2.ONE) != Vector2.ZERO:
						arrow.set_meta("velocity", Vector2.ZERO)
						arrow.set_meta("life_timer", 4.0) # Timer baru mulai 4 detik saat mendarat
					else:
						# Kurangi timer jika sudah diam di tanah
						var life = arrow.get_meta("life_timer", 4.0) - delta
						arrow.set_meta("life_timer", life)
						if life <= 0:
							arrow.queue_free()
							arrows.remove_at(i)
							continue
				else:
					arrow.queue_free()
					arrows.remove_at(i)
					continue
			continue # Jaring dilewati dari cek tembok biasa
		# --------------------------------------
		
		# --- PANAH PANTUL MENYENTUH TANAH ---
		if arrow.get_meta("is_deflected", false):
			if arrow.position.y >= 0: # Jika menyentuh lantai (Y=0)
				arrow.queue_free()
				arrows.remove_at(i)
				continue
		# -------------------------------------

		# --- PROYEKTIL MUSUH KENA PLAYER (Panah, Batu, Web biasa) ---
		if arrow.get_meta("is_enemy_proj", false):
			# Tentukan radius tabrakan (Batu lebih lebar karena ukurannya besar)
			var hit_radius = 30
			if arrow.get_meta("proj_type", "") == "boulder":
				hit_radius = 40
				
			if arrow.position.distance_to(clone_player.global_position) < hit_radius:
				
				# --- TENACITY: reflect projectile ---
				if Global.equipped_armor == "Tenacity Battle Armor" and randf() < 0.40:
					var _nearest = null
					var _nearest_dist = 400.0
					for _e in enemies:
						if is_instance_valid(_e):
							var _d = clone_player.global_position.distance_to(_e.global_position)
							if _d < _nearest_dist:
								_nearest_dist = _d
								_nearest = _e
					if _nearest != null:
						var _dmg = arrow.get_meta("damage")
						show_floating_text(str(_dmg) + " (Reflect)", _nearest.global_position + Vector2(0, -40), Color.CYAN)
						show_floating_text("REFLECT!", clone_player.global_position + Vector2(0, -40), Color.GOLD)
						damage_enemy(_nearest, _dmg, false)
						arrow.queue_free()
						arrows.remove_at(i)
						continue
				# ----------------------------------
				
				
				# 1. CEK WEB (Jaring Biasa)
				if arrow.get_meta("proj_type", "") == "web":
					Sfx.play("web_hit")
					player_stun_timer = 2.0
					player_slow_timer = 3.0
					show_floating_text("STUNNED!", clone_player.global_position + Vector2(0, -40), Color.WHITE)
					clone_player.get_child(0).color = Color(0.8, 0.8, 0.8) # Warna jadi abu-abu
					
				# 2. CEK BOULDER (Batu Raksasa Crystal Golem)
				elif arrow.get_meta("proj_type", "") == "boulder":
					take_damage(15) # Damage batunya 15
					player_stun_timer = 2.0 # Stun 2 Detik
					
					# Knockback Ringan (Mundur sedikit)
					var knock_dir = sign(clone_player.global_position.x - arrow.position.x)
					if knock_dir == 0: knock_dir = 1
					clone_player.velocity.x = knock_dir * 300.0
					clone_player.velocity.y = -100.0
					
					show_floating_text("BOULDER HIT! STUNNED!", clone_player.global_position + Vector2(0, -40), Color.RED)
					
				# 3. CEK PANAH BIASA (Atau proyektil musuh lainnya)
				else:
					take_damage(arrow.get_meta("damage"))
		
				# Hancurkan proyektil setelah kena player
				arrow.queue_free()
				arrows.remove_at(i)
				continue
		else:
			# --- PANAH PLAYER KENA MUSUH ---
			var hit_enemy = false
			var _hit_list = arrow.get_meta("hit_enemies", [])
			for e in enemies:
				if is_instance_valid(e) and arrow.position.distance_to(e.global_position) < 30:
					
					if e in _hit_list and arrow.get_meta("weapon", "") != "Ricochet Bow":
						continue
						
					# --- BOUNTY BOW EFFECT ---
					if arrow.get_meta("weapon", "") == "Bounty Bow":
						e.set_meta("is_bountied", true)
						show_floating_text("BOUNTY!", e.global_position + Vector2(0, -70), Color.YELLOW)
					
					# --- MARBLE SLINGSHOT: inline damage + SOAK + deflect shield ---
					if arrow.get_meta("weapon", "") == "Marble Slingshot":
						# Deflect cave_slime_boss shield (projectile mantul)
						if e.get_meta("type") == "cave_slime_boss" and e.get_meta("armor_hp", 0) > 0:
							var _sh_dmg = max(1, int(arrow.get_meta("damage") * 0.1))
							e.set_meta("armor_hp", e.get_meta("armor_hp") - _sh_dmg)
							if is_instance_valid(boss_armor_bar):
								boss_armor_bar.size.x = 400.0 * (float(max(e.get_meta("armor_hp"), 0)) / boss_max_armor)
							show_floating_text(str(_sh_dmg) + " (Shield)", e.global_position + Vector2(0, -20), Color.YELLOW)
							arrow.set_meta("is_enemy_proj", true)
							arrow.set_meta("is_deflected", true)
							var reflect_dir = sign(clone_player.global_position.x - e.global_position.x)
							if reflect_dir == 0: reflect_dir = 1
							arrow.set_meta("velocity", Vector2(reflect_dir * 400.0, -500.0))
							arrow.set_meta("life_timer", 3.0)
							arrow.size = Vector2(24, 8)
							arrow.color = Color(1.0, 0.2, 0.2)
							arrow.z_index = 20
							show_floating_text("DEFLECTED!", e.global_position + Vector2(0, -50), Color.CYAN)
							hit_enemy = false
							break
						
						# Damage normal + armor soak cave_slime biasa
						var _dmg_left = arrow.get_meta("damage")
						if e.get_meta("type") == "cave_slime" and e.get_meta("armor_hp", 0) > 0:
							var _armor = e.get_meta("armor_hp")
							var _absorb = min(_dmg_left, _armor)
							e.set_meta("armor_hp", _armor - _absorb)
							_dmg_left -= _absorb
							show_floating_text(str(_absorb) + " (Armor)", e.global_position + Vector2(0, -20), Color.YELLOW)
						if _dmg_left > 0:
							var _hp = e.get_meta("hp") - _dmg_left
							e.set_meta("hp", _hp)
							var _bar = e.get_meta("hp_bar", null)
							if _bar: _bar.size.x = 30.0 * (float(max(_hp, 0)) / e.get_meta("max_hp"))
							if "boss" in e.get_meta("type") and is_instance_valid(boss_bar):
								boss_bar.size.x = 400.0 * (float(max(_hp, 0)) / boss_max_hp)
							show_floating_text(str(_dmg_left), e.global_position + Vector2(randf_range(-20, 20), -30 - randf_range(0, 15)), Color.CYAN)
							if _hp <= 0:
								var _ct = e.get_meta("type")
								if "boss" in _ct:
									show_floating_text("BOSS DEFEATED!", e.global_position + Vector2(0, -60), Color.GOLD)
									if is_instance_valid(boss_ui): boss_ui.visible = false
									is_boss_defeated = true
									spawn_boss_chest()
								enemies.erase(e)
								if is_instance_valid(e):
									e.queue_free()
						
						# SOAK: pellet destroy
						hit_enemy = true
						break
					# -----------------------------------------------
						
					# --- LOGIKA DEFLECT CAVE SLIME ---
					if e.get_meta("type") == "cave_slime_boss" and e.get_meta("armor_hp", 0) > 0:
						damage_enemy(e, int(arrow.get_meta("damage") * 0.1), false) # 90% DR
						# Guard: kalau shield break dan boss mati, break loop
						if not is_instance_valid(e) or e.is_queued_for_deletion():
							hit_enemy = false
							break
						
						# Pantulkan panah (Gaya Parabola)
						arrow.set_meta("is_enemy_proj", true)
						arrow.set_meta("is_deflected", true) # Penanda panah mantul
						
						# Arah pantulan: Ke arah player (X) dan mental ke atas (Y)
						var reflect_dir = sign(clone_player.global_position.x - e.global_position.x)
						if reflect_dir == 0: reflect_dir = 1
						arrow.set_meta("velocity", Vector2(reflect_dir * 400.0, -500.0))
						
						arrow.set_meta("life_timer", 3.0) # Bertahan 3 detik
						
						# --- BIAR PANAH PANTUL LEBIH KELIHATAN ---
						arrow.size = Vector2(24, 8)
						arrow.color = Color(1.0, 0.2, 0.2) # Warna Merah Terang
						arrow.z_index = 20 
						# ------------------------------------------
						
						show_floating_text("DEFLECTED!", e.global_position + Vector2(0, -50), Color.CYAN)
						
						hit_enemy = false # Jangan hancurkan panah
						break
					# ----------------------------------
					
					# --- HEADHITTER HEAVY BOW: EXECUTION ---
					var _hh_arrow_dmg = arrow.get_meta("damage")
					if arrow.get_meta("weapon", "") == "Headhitter Heavy Bow":
						if e.get_meta("hp") < (e.get_meta("max_hp") * 0.3):
							_hh_arrow_dmg = int(_hh_arrow_dmg * 1.5)
							show_floating_text("EXECUTE!", e.global_position + Vector2(0, -60), Color.RED)
							
					# --- MOURNING BOW: stun on hit ---
					if arrow.has_meta("stun_duration") and arrow.get_meta("stun_duration") > 0.0:
						e.set_meta("terrified_timer", arrow.get_meta("stun_duration"))
						show_floating_text("STUNNED!", e.global_position + Vector2(0, -60), Color.CYAN)
					
					# --- EXPLOSIVE CROSSBOW: skip single-target damage, AoE handled below ---
					if arrow.get_meta("weapon", "") == "Explosive Crossbow" and arrow.get_meta("is_charged", false):
						hit_enemy = true
						break
					
					# --- RICOCHET BOW LOGIC ---
					var _is_ricochet = false
					if arrow.get_meta("weapon", "") == "Ricochet Bow" and arrow.get_meta("is_charged", false):
						var _bounces = arrow.get_meta("bounce_count", 0)
						if _bounces < 4 and randf() < 0.20:
							var _nearest = null
							var _min_dist = 128.0  # Range mantul maksimal 8 block
							for _other in enemies:
								if not is_instance_valid(_other) or _other.is_queued_for_deletion(): continue
								if _other in _hit_list: continue  # Jangan mantul ke musuh yang sudah kena
								var _d = arrow.position.distance_to(_other.global_position)
								if _d < _min_dist and _d > 10.0:
									_min_dist = _d
									_nearest = _other
							if _nearest != null:
								arrow.set_meta("bounce_count", _bounces + 1)
								var _dir = (_nearest.global_position - arrow.position).normalized()
								arrow.set_meta("velocity", _dir * 600.0)
								arrow.set_meta("life_timer", 1.5)
								arrow.rotation = _dir.angle()
								show_floating_text("RICOCHET!", arrow.position, Color.YELLOW)
								_is_ricochet = true
								# Tandai musuh saat ini sudah kena
								_hit_list.append(e)
								arrow.set_meta("hit_enemies", _hit_list)


					# Panggil damage_enemy (ini otomatis menghitung kematian, exp, dan loot)
					damage_enemy(e, _hh_arrow_dmg, false)
					
					# --- HEADHITTER KNOCKBACK ---
					if arrow.get_meta("weapon", "") == "Headhitter Heavy Bow" and arrow.get_meta("is_charged", false):
						if is_instance_valid(e) and not e.is_queued_for_deletion():
							var _hb_dir = sign(e.global_position.x - clone_player.global_position.x)
							if _hb_dir == 0: _hb_dir = 1
							_safe_knockback(e, _hb_dir, 64)
							if e.has_meta("knockback_timer"):
								e.set_meta("knockback_timer", 1.0)
					
					# --- BOUNTY BOW KILL LOGIC ---
					if arrow.get_meta("weapon", "") == "Bounty Bow":
						if not is_instance_valid(e) or e.get_meta("hp", 0) <= 0:
							bounty_bow_stacks = min(bounty_bow_stacks + 1, 5)
							bounty_stack_timer = 7.0
							show_floating_text("Bounty Stack: " + str(bounty_bow_stacks) + "/5", clone_player.global_position + Vector2(0, -60), Color.GOLD)
					# ------------------------------
					
					if _is_ricochet:
						hit_enemy = false
						break # Panah tidak hancur, lanjut ke musuh berikutnya
					else:
						hit_enemy = true
						break
			if hit_enemy:
				# --- EXPLOSIVE CROSSBOW AoE on enemy hit ---
				if arrow.get_meta("weapon", "") == "Explosive Crossbow" and arrow.get_meta("is_charged", false):
					trigger_crossbow_explosion(arrow.position, arrow.get_meta("damage"))
				arrow.queue_free()
				arrows.remove_at(i)
				continue
		
		# --- PANAH KENA DINDING ---
		var hit_wall = false
		var pierce = arrow.get_meta("pierce_wall", false) # Cek tembus tembok
		
		if not pierce: # Jika tidak tembus, cek tabrakan dinding
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = arrow.position
			query.collide_with_bodies = true
			var result = space_state.intersect_point(query)
			
			for r in result:
				if r.collider is StaticBody2D:
					hit_wall = true
					break
		
		# --- STICKY CROSSBOW WALL PULL ---
		if hit_wall and arrow.get_meta("weapon", "") == "Sticky Crossbow":
			clone_player.set_physics_process(false)
			clone_player.velocity = Vector2.ZERO
			var _pt = create_tween()
			_pt.tween_property(clone_player, "global_position", arrow.position, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_pt.tween_callback(clone_player.set_physics_process.bind(true))
		
		# --- LOGIKA AOE BOULDER (LEDAKAN BATU) ---
		if hit_wall and arrow.get_meta("proj_type", "") == "boulder":
			Sfx.play("boulder_impact")
			# 1. Efek Visual Ledakan (3x3 Blok = 48x48 pixel)
			var explosion = ColorRect.new()
			explosion.size = Vector2(48, 48) 
			explosion.position = arrow.position - Vector2(24, 24)
			explosion.color = Color(1.0, 0.5, 0.0, 0.8) # Warna Oranye
			explosion.z_index = 15
			add_child(explosion)
			
			var t = create_tween()
			t.tween_property(explosion, "scale", Vector2(1.5, 1.5), 0.2)
			t.tween_property(explosion, "modulate:a", 0.0, 0.2)
			t.tween_callback(explosion.queue_free)
			
			# 2. Cek Damage Area ke Player
			var aoe_rect = Rect2(arrow.position.x - 24, arrow.position.y - 24, 48, 48)
			var p_rect = Rect2(clone_player.global_position.x - 16, clone_player.global_position.y - 32, 32, 64)
			
			if aoe_rect.intersects(p_rect):
				take_damage(15)
				player_stun_timer = 2.0
				
				# Knockback ringan
				var knock_dir = sign(clone_player.global_position.x - arrow.position.x)
				if knock_dir == 0: knock_dir = 1
				clone_player.velocity.x = knock_dir * 300.0
				clone_player.velocity.y = -100.0
				
				show_floating_text("BOULDER AOE!", clone_player.global_position + Vector2(0, -40), Color.RED)
				
			hit_wall = true # Hancurkan batunya setelah meledak
		# --------------------------------------------
				
		var life_timer = arrow.get_meta("life_timer", 1.5) - delta
		arrow.set_meta("life_timer", life_timer)
		
		if hit_wall or life_timer <= 0:
			# --- EXPLOSIVE CROSSBOW AoE on wall / lifetime ---
			if arrow.get_meta("weapon", "") == "Explosive Crossbow" and arrow.get_meta("is_charged", false):
				trigger_crossbow_explosion(arrow.position, arrow.get_meta("damage"))
			arrow.queue_free()
			arrows.remove_at(i)

func bikin_hud_domain():
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)
	
	var hb_container = HBoxContainer.new()
	hb_container.position = Vector2(20, 20) 
	hb_container.add_theme_constant_override("separation", 5)
	canvas.add_child(hb_container)
	
	for i in range(7):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(55, 55)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
		style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
		style.border_color = Color(0.5, 0.5, 0.5)
		slot.add_theme_stylebox_override("panel", style)
		
		var lbl = Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		slot.add_child(lbl)
		
		var num_lbl = Label.new()
		num_lbl.text = str(i + 1)
		num_lbl.position = Vector2(2, -2)
		num_lbl.add_theme_font_size_override("font_size", 10)
		slot.add_child(num_lbl)
		
		hb_container.add_child(slot)
		hud_hotbar_labels.append(lbl)
		
	var main_container = HBoxContainer.new()
	main_container.position = Vector2(650, 20)
	main_container.add_theme_constant_override("separation", 15)
	canvas.add_child(main_container)
	
	hud_exp_label = Label.new()
	hud_exp_label.add_theme_font_size_override("font_size", 20)
	hud_exp_label.add_theme_color_override("font_color", Color.CYAN)
	hud_exp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hud_exp_label.add_theme_constant_override("outline_size", 4)
	main_container.add_child(hud_exp_label)
	
	# TAMBAHKAN LABEL NYAWA
	hud_lives_label = Label.new()
	hud_lives_label.add_theme_font_size_override("font_size", 24)
	hud_lives_label.add_theme_color_override("font_color", Color.WHITE)
	hud_lives_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hud_lives_label.add_theme_constant_override("outline_size", 4)
	main_container.add_child(hud_lives_label)
	
	var hp_container = HBoxContainer.new()
	hp_container.add_theme_constant_override("separation", 2)
	main_container.add_child(hp_container)
	
	for i in range(10):
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 24)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.add_theme_constant_override("outline_size", 4)
		hp_container.add_child(lbl)
		hud_hp_hearts.append(lbl)
		
	ui_label = Label.new()
	ui_label.text = "(Press [E] to leave)"
	ui_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	ui_label.position = Vector2(-300, -50)
	ui_label.add_theme_font_size_override("font_size", 20)
	ui_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	ui_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_label.add_theme_constant_override("outline_size", 4)
	canvas.add_child(ui_label)

	debug_dist_label = Label.new()
	debug_dist_label.position = Vector2(20, 90)
	debug_dist_label.add_theme_font_size_override("font_size", 22)
	debug_dist_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_dist_label.add_theme_color_override("font_outline_color", Color.BLACK)
	debug_dist_label.add_theme_constant_override("outline_size", 5)
	canvas.add_child(debug_dist_label)
	
	update_hud()

func update_hud():
	for i in range(10):
		if player_hp >= (i + 1) * 10:
			hud_hp_hearts[i].text = "❤"
			hud_hp_hearts[i].add_theme_color_override("font_color", Color.RED)
		else:
			hud_hp_hearts[i].text = "♡"
			hud_hp_hearts[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			
	if is_instance_valid(hud_exp_label):
		hud_exp_label.text = "Dungeon Lv " + str(main_ref.dungeon_level) + " | Mana: " + str(int(player_mana)) + "/" + str(main_ref.max_mana)
	if is_instance_valid(hud_lives_label): # <--- TAMBAHKAN INI
		hud_lives_label.text = "✚ " + str(main_ref.lives)
		
	for i in range(7):
		var item = Global.hotbar_items[i]
		var lbl = hud_hotbar_labels[i]
		if item != null:
			var w_type = main_ref.item_data.get(item, {}).get("weapon_type", "")
			if w_type != "": 
				lbl.text = item + "\nLv. " + str(Global.get_item_level(item, Global.hotbar_uuids[i]))
			else: 
				lbl.text = item + "\n(" + str(inventory.get(item, 0)) + ")"
			lbl.add_theme_color_override("font_color", main_ref.item_data.get(item, {"color": Color.WHITE})["color"])
		else:
			lbl.text = ""
			
		var slot_panel = lbl.get_parent()
		if i == main_ref.selected_hotbar_index:
			slot_panel.get_theme_stylebox("panel").border_color = Color.YELLOW
		else:
			slot_panel.get_theme_stylebox("panel").border_color = Color(0.5, 0.5, 0.5)

func bikin_player_clone():
	clone_player = CharacterBody2D.new()
	clone_player.set_script(load("res://domain_player.gd"))
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-16, -32), Vector2(16, -32), Vector2(16, 32), Vector2(-16, 32)])
	poly.color = Color.CYAN
	clone_player.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 64)
	col.shape = rect
	clone_player.add_child(col)
	
	# PAKSA COLLISION & MOTION AGAR SOLID
	clone_player.collision_layer = 1
	clone_player.collision_mask = 1
	clone_player.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	clone_player.safe_margin = 0.08
	
	var cam = Camera2D.new()
	cam.limit_left = -2000
	cam.limit_right = 1700
	cam.limit_top = -1120
	cam.limit_bottom = 100
	cam.zoom = Vector2(1.5, 1.5)
	clone_player.add_child(cam)
	domain_cam = cam
	
	clone_player.global_position = Vector2(-1900, -50)
	add_child(clone_player)
	cam.make_current()
	
	if "speed" in clone_player:
		clone_player.speed = 300.0 * main_ref.buff_speed_mult

func show_floating_text(text: String, pos: Vector2, color: Color = Color.WHITE):
	var lbl = Label.new()
	lbl.text = text
	lbl.z_index = 10
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.size = Vector2(100, 20)
	lbl.position = pos - Vector2(50, 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(lbl)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "position:y", lbl.position.y - 40, 0.8)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.8)
	tween.finished.connect(func(): lbl.queue_free())

func close_domain() -> void:
	reset_boss_room() 
	
	# --- TAMBAHKAN INI ---
	Global.gold_coins += domain_gold
	domain_gold = 0
	# ---------------------
	
	main_ref.inventory = inventory.duplicate()
	# --- SYNC KE GLOBAL (defensive, jaga-jaga kalau ada loot yang belum ke-sync) ---
	Global.saved_inventory = inventory.duplicate()
	Global.save_game()
	# -------------------------------------------------------------------------------
	main_ref.current_hp = player_hp
	main_ref.current_mana = player_mana
	
	main_ref.update_inventory_ui()
	main_ref.update_hotbar_ui()
	main_ref.update_hp_ui()
	
	Global.hotbar_items = Global.hotbar_items 
	print("[DOMAIN] Closing domain")
	
	domain_closed.emit(false, player_hp, player_mana)

func bikin_efek_retak():
	var crack_img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	crack_img.fill(Color(0, 0, 0, 0))
	for i in range(4, 12): crack_img.set_pixel(i, i, Color(0.1, 0.1, 0.1, 1))
	for i in range(8, 14): crack_img.set_pixel(i, i-4, Color(0.1, 0.1, 0.1, 1))
	for i in range(2, 8): crack_img.set_pixel(i, i+6, Color(0.1, 0.1, 0.1, 1))
	var crack_tex = ImageTexture.create_from_image(crack_img)
	crack_sprite = Sprite2D.new()
	crack_sprite.texture = crack_tex
	crack_sprite.visible = false
	crack_sprite.z_index = 1
	add_child(crack_sprite)

# ==========================================
# SISTEM MINION
# ==========================================
func get_minion_pool(idx: int) -> Array:
	if idx == 0: return ["goblin", "cannibal"]
	elif idx == 1: return ["goblin", "cannibal", "hunter"]
	elif idx == 2: return ["goblin", "cannibal", "hunter", "cult"]
	elif idx == 3: return ["goblin", "cannibal", "hunter", "cult"]
	elif idx == 4: return ["goblin", "cannibal", "hunter", "cult", "spider"]
	elif idx == 5: return ["goblin", "cannibal", "hunter", "cult", "spider"]
	elif idx == 6: return ["cannibal", "hunter", "cult", "spider"]
	elif idx == 7: return ["cannibal", "hunter", "cult", "spider", "cave_slime"]
	elif idx == 8: return ["hunter", "cult", "spider", "cave_slime", "crystal_golem"]
	elif idx == 9: return ["cult", "spider", "cave_slime", "crystal_golem"]
	elif idx == 10: return ["spider", "cave_slime", "crystal_golem"]
	else: return ["cult", "spider", "cave_slime", "crystal_golem"]

func spawn_domain_minions():
	var pool = get_minion_pool(config_index)
	for i in range(10):
		var m_type = pool.pick_random()
		# Spawn tersebar di area domain (X: -1200 s/d 500, Y: -800 s/d -50)
		var spawn_pos = Vector2(randf_range(-1200, 500), randf_range(-800, -50))
		create_minion(m_type, spawn_pos)

func create_minion(type: String, pos: Vector2):
	var enemy = CharacterBody2D.new()
	enemy.set_meta("type", type)
	
	var hp = 100
	var dmg = 10
	var size_w = 24
	var size_h = 48
	var color = Color.WHITE
	
	if type == "goblin": 
		hp=120; dmg=12; color=Color(0.2,0.6,0.2); size_w=24; size_h=48
		enemy.set_meta("state", "chase")
		enemy.set_meta("flee_timer", 0.0)
	elif type == "cannibal": 
		hp=300; dmg=15; color=Color(0.6,0.1,0.1); size_w=32; size_h=64
	elif type == "hunter": 
		hp=100; dmg=10; color=Color(0.8,0.4,0.8); size_w=24; size_h=48
		enemy.set_meta("state", "attack")
	elif type == "cult": 
		hp=150; dmg=30; color=Color(0.5,0.1,0.5); size_w=24; size_h=48
	elif type == "spider": 
		hp=240; dmg=14; color=Color(0.487,0.35,0.122); size_w=48; size_h=16
		enemy.set_meta("web_timer", 2.0)
		enemy.set_meta("melee_timer", 0.0)
		enemy.set_meta("post_melee_cd", 0.0)
	elif type == "cave_slime": 
		hp=200; dmg=20; color=Color(0.4,0.2,0.1); size_w=32; size_h=32
		enemy.set_meta("armor_hp", 200)
		enemy.set_meta("armor_regen_timer", 0.0)
	elif type == "crystal_golem": 
		hp=700; dmg=24; color=Color(0.6,0.8,1.0); size_w=32; size_h=80
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	enemy.set_meta("hp", hp)
	enemy.set_meta("max_hp", hp)
	enemy.set_meta("damage", dmg)
	enemy.set_meta("atk_timer", randf_range(1.0, 2.0))
	enemy.set_meta("jump_cd", 0.0)
	
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-size_w/2, -size_h/2), Vector2(size_w/2, -size_h/2), Vector2(size_w/2, size_h/2), Vector2(-size_w/2, size_h/2)])
	poly.color = color
	enemy.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	enemy.add_child(col)
	
	# PAKSA COLLISION & MOTION AGAR SOLID
	enemy.collision_layer = 1
	enemy.collision_mask = 1
	enemy.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	enemy.safe_margin = 0.08
	
	var hp_bar_bg = ColorRect.new()
	hp_bar_bg.size = Vector2(30, 4)
	hp_bar_bg.position = Vector2(-15, -size_h/2 - 10)
	hp_bar_bg.color = Color.BLACK
	enemy.add_child(hp_bar_bg)
	
	var hp_bar = ColorRect.new()
	hp_bar.size = Vector2(30, 4)
	hp_bar.position = Vector2(-15, -size_h/2 - 10)
	hp_bar.color = Color.GREEN
	enemy.add_child(hp_bar)
	enemy.set_meta("hp_bar", hp_bar)
	
	enemy.position = pos
	enemy.collision_mask = 1
	add_child(enemy)
	enemies.append(enemy)

func update_minions(delta):
	var player_pos = clone_player.global_position
	
	# --- SAFETY: Clamp boss ke arena (cegah softlock) ---
	for _e in enemies:
		if is_instance_valid(_e) and "boss" in _e.get_meta("type"):
			_clamp_boss_to_arena(_e)
	# ---------------------------------------------------
	
	for i in range(enemies.size() - 1, -1, -1):
		if i >= enemies.size(): continue
		var enemy = enemies[i]
		if not is_instance_valid(enemy): continue
		if enemy.is_queued_for_deletion(): continue
		
		# --- POISON TICK ---
		if enemy.has_meta("poison_dmg"):
			var _pt = enemy.get_meta("poison_tick", 0.0) + delta
			if _pt >= 1.0:
				_pt = 0.0
				var _pd = enemy.get_meta("poison_dmg")
				var _ph = enemy.get_meta("hp") - _pd
				enemy.set_meta("hp", _ph)
				var _pb = enemy.get_meta("hp_bar", null)
				if _pb: _pb.size.x = 30.0 * (float(max(_ph, 0)) / enemy.get_meta("max_hp"))
				show_floating_text(str(_pd), enemy.global_position + Vector2(0, -20), Color.GREEN)
				var _pr = enemy.get_meta("poison_rem", 5) - 1
				if _pr <= 0:
					enemy.remove_meta("poison_dmg")
					enemy.remove_meta("poison_tick")
					enemy.remove_meta("poison_rem")
				else:
					enemy.set_meta("poison_rem", _pr)
				if _ph <= 0:
					if "boss" in enemy.get_meta("type"):
						show_floating_text("BOSS DEFEATED!", enemy.global_position + Vector2(0, -60), Color.GOLD)
						if is_instance_valid(boss_ui): boss_ui.visible = false
						is_boss_defeated = true
						spawn_boss_chest()
					enemies.remove_at(i)
					enemy.queue_free()
					continue
			enemy.set_meta("poison_tick", _pt)
		
		# --- BLEED TICK ---
		if enemy.has_meta("bleed_dmg"):
			var _bt = enemy.get_meta("bleed_tick", 0.0) + delta
			if _bt >= 1.0:
				_bt = 0.0
				var _bd = enemy.get_meta("bleed_dmg")
				var _bh = enemy.get_meta("hp") - _bd
				enemy.set_meta("hp", _bh)
				var _bb = enemy.get_meta("hp_bar", null)
				if _bb: _bb.size.x = 30.0 * (float(max(_bh, 0)) / enemy.get_meta("max_hp"))
				show_floating_text(str(_bd), enemy.global_position + Vector2(0, -20), Color.RED)
				var _br = enemy.get_meta("bleed_rem", 5) - 1
				if _br <= 0:
					enemy.remove_meta("bleed_dmg")
					enemy.remove_meta("bleed_tick")
					enemy.remove_meta("bleed_rem")
				else:
					enemy.set_meta("bleed_rem", _br)
				if _bh <= 0:
					if "boss" in enemy.get_meta("type"):
						show_floating_text("BOSS DEFEATED!", enemy.global_position + Vector2(0, -60), Color.GOLD)
						if is_instance_valid(boss_ui): boss_ui.visible = false
						is_boss_defeated = true
						spawn_boss_chest()
					enemies.remove_at(i)
					enemy.queue_free()
					continue
			enemy.set_meta("bleed_tick", _bt)
		
		# --- LOGIKA KNOCKBACK ---
		
		# --- TERRIFIED (Heretic Staff / Mourning Bow stun) ---
		if enemy.has_meta("terrified_timer"):
			var _terr = enemy.get_meta("terrified_timer") - delta
			if _terr <= 0:
				enemy.remove_meta("terrified_timer")
			else:
				enemy.set_meta("terrified_timer", _terr)
				enemy.velocity.x = 0
				enemy.velocity.y += 980.0 * delta
				enemy.move_and_slide()
				continue
		# ----------------------------------------------------
		
		# --- LOGIKA KNOCKBACK ---
		
		# --- FREEZE BOSS SAAT PLAYER DI LUAR (mid-fight escape) ---
		if "boss" in enemy.get_meta("type") and not is_boss_fight_started:
			enemy.velocity.x = 0
			enemy.velocity.y += 980.0 * delta
			enemy.move_and_slide()
			continue
		# -----------------------------------------------------------
		
		# --- LOGIKA KNOCKBACK ---
		var knockback_timer = enemy.get_meta("knockback_timer", 0.0)
		if knockback_timer > 0:
			enemy.set_meta("knockback_timer", knockback_timer - delta)
			enemy.velocity.x = lerp(enemy.velocity.x, 0.0, 0.05)
			enemy.velocity.y += 980.0 * delta
			enemy.move_and_slide()
			continue

		var dist = enemy.global_position.distance_to(player_pos)
		var dir = sign(player_pos.x - enemy.global_position.x)
		var type = enemy.get_meta("type")
		var atk_timer = enemy.get_meta("atk_timer", 1.0) - delta
		enemy.set_meta("atk_timer", atk_timer)
		
		enemy.velocity.y += 980.0 * delta
		
		var size_w = enemy.get_meta("size", 16.0)
		var size_h = enemy.get_meta("size_h", size_w)
		var tabrakan = dist < (size_w / 2.0 + 25.0) 
		
		var is_blocked = false
		if enemy.is_on_floor() and enemy.is_on_wall():
			is_blocked = true
			
		var is_in_range = dist < 450.0
		
		# --- LOGIKA ANTRIAN (QUEUE) ---
		# Cek apakah ada musuh lain persis di depan kita
				# --- LOGIKA ANTRIAN (QUEUE) ---
		var is_blocked_by_enemy = false
		var push_force = 0.0 # <--- TAMBAHKAN INI
		
		for other in enemies:
			if other != enemy and is_instance_valid(other):
				var other_size_w = other.get_meta("size", 16.0)
				var other_size_h = other.get_meta("size_h", other_size_w)
				var dx = other.global_position.x - enemy.global_position.x
				var dy = other.global_position.y - enemy.global_position.y
				
				# Cek untuk antrian (hanya yang searah)
				if sign(dx) == dir and abs(dx) < (size_w/2.0 + other_size_w/2.0 + 10.0) and abs(dy) < (size_h/2.0 + other_size_h/2.0):
					is_blocked_by_enemy = true
					
				# Cek jika benar-benar tumpang tindih (untuk Hunter yang diam)
				# HAPUS sign(dx) == dir dan + 10.0 agar pendorong bekerja ke segala arah
				if abs(dx) < (size_w/2.0 + other_size_w/2.0) and abs(dy) < (size_h/2.0 + other_size_h/2.0):
					if dx > 0: push_force -= 20.0 # Dorong ke kiri
					elif dx < 0: push_force += 20.0 # Dorong ke kanan
					else: push_force += randf_range(-20.0, 20.0) # Jika posisi X persis sama, dorong acak
		
		# ==========================================
		# AI MUSUH (DENGAN SISTEM ANTRIAN)
		# ==========================================
		if type == "goblin_boss":
			var state = enemy.get_meta("state", "chase")
			var flee_timer = enemy.get_meta("flee_timer", 0.0)
			var invis_timer = enemy.get_meta("invis_timer", 0.0)
			
			if state == "chase":
				if not tabrakan and not is_blocked_by_enemy:
					enemy.velocity.x = dir * 150.0 # Bos lebih cepat
				else:
					enemy.velocity.x = 0
					
				if is_blocked: enemy.velocity.y = -400.0
				
				if tabrakan and atk_timer <= 0:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
					enemy.set_meta("state", "flee")
					enemy.set_meta("flee_timer", 3.0)
					enemy.set_meta("invis_timer", 1.0)
					enemy.modulate.a = 0.3 # Transparan (Aamon mode)
					atk_timer = 1.0
			
			elif state == "flee":
				enemy.velocity.x = -dir * 200.0 # Lari kencang
				
				invis_timer -= delta
				enemy.set_meta("invis_timer", invis_timer)
				if invis_timer <= 0:
					enemy.modulate.a = 1.0 # Muncul lagi
					
				flee_timer -= delta
				enemy.set_meta("flee_timer", flee_timer)
				if flee_timer <= 0:
					enemy.set_meta("state", "chase")
					enemy.modulate.a = 1.0
		
		elif type == "cannibal_boss":
			var state = enemy.get_meta("state", "chase")
			
			if state == "chase":
				if not tabrakan and not is_blocked_by_enemy:
					enemy.velocity.x = dir * 80.0 # Jalan agak lambat tapi berat
				else:
					enemy.velocity.x = 0
					
				if is_blocked: enemy.velocity.y = -380.0
				
				if tabrakan and atk_timer <= 0:
					var dmg_dealt = enemy.get_meta("damage")
					take_damage(dmg_dealt)
					_track_revenger_attacker(enemy)
					
					# --- SKILL LIFESTEAL (DI BAWAH 50% HP) ---
					var current_hp = enemy.get_meta("hp")
					var max_hp = enemy.get_meta("max_hp")
					
					if current_hp <= (max_hp * 0.5):
						var heal_amount = dmg_dealt * 0.15
						enemy.set_meta("hp", min(max_hp, current_hp + heal_amount))
						
						# Update bar HP Bos secara langsung
						if is_instance_valid(boss_bar):
							boss_bar.size.x = 400.0 * (float(enemy.get_meta("hp")) / boss_max_hp)
							
						show_floating_text("+" + str(int(heal_amount)) + " HP", enemy.global_position + Vector2(0, -80), Color.GREEN)
					# -----------------------------------------
					
					enemy.velocity.x = -dir * 100.0 # Mundur sedikit setelah mukul
					atk_timer = 1.5
		
		elif type == "hunter_boss":
			var current_hp = enemy.get_meta("hp")
			var next_tp = enemy.get_meta("next_teleport_hp")
			
			# --- SKILL TELEPORT (Setiap Kurang 20% HP) ---
			if current_hp <= next_tp:
				var tele_spots = [
					Vector2(900, -110), Vector2(1180, -110), Vector2(1460, -110),
					Vector2(1040, -200), Vector2(1320, -200), Vector2(1180, -290)
				]
				var new_pos = tele_spots.pick_random()
				
				# Pastikan tidak teleport ke posisi player
				if new_pos.distance_to(player_pos) > 200:
					enemy.global_position = new_pos
					enemy.set_meta("next_teleport_hp", next_tp - (boss_max_hp * 0.2))
					enemy.modulate.a = 0.2 # Efek transparan
					var tween = create_tween()
					tween.tween_property(enemy, "modulate:a", 1.0, 0.3)
					show_floating_text("TELEPORT!", enemy.global_position + Vector2(0, -50), Color.PURPLE)
					Sfx.play("teleport")
			# ---------------------------------------------

			var state = enemy.get_meta("state", "attack")
			if state == "flee":
				enemy.velocity.x = -dir * 140.0
				if is_blocked: state = "attack"
				if dist > 150.0: state = "attack"
			else:
				enemy.velocity.x = 0 # Diam dan menembak
				if atk_timer <= 0:
					# Tembak panah tembus tembok! (Parameter ke-5 = true)
					spawn_enemy_projectile(enemy.global_position, player_pos, "arrow", int(enemy.get_meta("damage")), true, 320.0)
					atk_timer = 0.75
				if dist < 128.0:
					state = "flee"
			enemy.set_meta("state", state)
		
		elif type == "cult_boss":
			var home_pos = enemy.get_meta("home_pos")
			var state = enemy.get_meta("state", "idle")
			
			# Skill Summon (Jika HP < 50% dan Cannibal mati)
			var current_hp = enemy.get_meta("hp")
			var max_hp = enemy.get_meta("max_hp")
			var summon_count = enemy.get_meta("summon_count", 0)
			
			# Cek apakah ada cannibal hidup di sekitar cult
			var cannibal_alive = false
			for e in enemies:
				if is_instance_valid(e) and e.get_meta("type") == "cannibal" and e.get_meta("is_cult_buffed", false):
					cannibal_alive = true
					break
					
			if not cannibal_alive and current_hp <= (max_hp * 0.5) and summon_count < 2:
				spawn_cult_cannibal(enemy.global_position + Vector2(-50, 0))
				enemy.set_meta("summon_count", summon_count + 1)
				show_floating_text("SUMMON!", enemy.global_position + Vector2(0, -60), Color.PURPLE)
			
			# State AI
			if state == "idle":
				enemy.velocity.x = 0
				# Jika player terlalu dekat (4 blok = 64 pixel), maju untuk mukul
				if dist < 64.0 and atk_timer <= 0:
					enemy.set_meta("state", "attack")
					
			elif state == "attack":
				enemy.velocity.x = dir * 150.0 # Maju cepat
				if tabrakan:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
					
					# --- KNOCKBACK JAUH (HORIZONTAL SAJA) ---
					clone_player.velocity.x = dir * 900.0 # Dorongan horizontal super kuat (6+ blok)
					clone_player.velocity.y = 0.0 # <--- KUNCI: Agar tidak melayang ke atas
					show_floating_text("KNOCKBACK!", clone_player.global_position + Vector2(0, -40), Color.RED)
					# -----------------------------------------
					
					# Kembali ke posisi awal (Home)
					enemy.set_meta("state", "return")
					atk_timer = 2.0 # Jeda sebelum bisa mukul lagi
					
			elif state == "return":
				# Jalan kembali ke titik awal
				var home_dir = sign(home_pos.x - enemy.global_position.x)
				if abs(enemy.global_position.x - home_pos.x) > 10:
					enemy.velocity.x = home_dir * 100.0
				else:
					enemy.velocity.x = 0
					enemy.set_meta("state", "idle")
		
		elif type == "spider_boss":
			var state = enemy.get_meta("state", "web")
			var pattern_timer = enemy.get_meta("pattern_timer", 0.0) - delta
			var web_count = enemy.get_meta("web_count", 0)
			
			# Cek jarak dekat (Bite) - Tidak mereset pattern
			if state != "dash" and dist < 120: # Jarak gigit 120 pixel
				state = "bite"
			elif state == "bite" and dist >= 120:
				state = "web" 
				
			if state == "web":
				enemy.velocity.x = 0 # DIAM
				if pattern_timer <= 0:
					for w in range(4):
						var is_sticky = (w == 0)
						spawn_thrown_web(enemy.global_position + Vector2(0, -20), is_sticky)
					show_floating_text("WEB RAIN!", enemy.global_position + Vector2(0, -60), Color.WHITE)
					
					web_count += 1
					if web_count >= 2:
						state = "dash"
						enemy.set_meta("dash_dir", sign(player_pos.x - enemy.global_position.x))
						Sfx.play("spider_dash")
						enemy.set_meta("dash_hit", false)
					else:
						pattern_timer = 3.0 
					
			elif state == "dash":
				var dash_dir = enemy.get_meta("dash_dir", 1)
				enemy.velocity.x = dash_dir * 1500.0
				
				if not enemy.get_meta("dash_hit", false):
					# Gunakan Rect2 untuk deteksi tabrakan yang akurat
					var p_rect = Rect2(clone_player.global_position.x - 16, clone_player.global_position.y - 32, 32, 64)
					var e_rect = Rect2(enemy.global_position.x - size_w/2, enemy.global_position.y - size_h/2, size_w, size_h)
					
					# Perbesar sedikit hitbox spider saat dash biar lebih adil
					e_rect = e_rect.grow(10.0)
					
					if p_rect.intersects(e_rect):
						take_damage(enemy.get_meta("damage") * 0.8)
						_track_revenger_attacker(enemy)
						enemy.set_meta("dash_hit", true)
						show_floating_text("DASH HIT!", clone_player.global_position + Vector2(0, -40), Color.RED)
						
						# Dorong player agar terlempar menjauh
						clone_player.velocity.x = dash_dir * 400.0
						clone_player.velocity.y = -200.0
					
				if enemy.is_on_wall() or abs(enemy.global_position.x - 1180) > 450:
					enemy.set_meta("dash_dir", -dash_dir) 
					web_count = 0 
					state = "web"
					pattern_timer = 2.0 
					
			elif state == "bite":
				enemy.velocity.x = 0 # <--- KUNCI: DIAM AJA SAAT MENGGIGIT
				if tabrakan and atk_timer <= 0:
					take_damage(enemy.get_meta("damage") * 1.2)
					_track_revenger_attacker(enemy)
					show_floating_text("BITE!", clone_player.global_position + Vector2(0, -40), Color.RED)
					atk_timer = 1.5
					
			enemy.set_meta("state", state)
			enemy.set_meta("pattern_timer", pattern_timer)
			enemy.set_meta("web_count", web_count)
		
		elif type == "cave_slime_boss":
			enemy.velocity.x = 0 # Diam di tempat
			var state = enemy.get_meta("state", "rock_throw")
			var rocks = enemy.get_meta("rocks_thrown", 0)
			var gravels = enemy.get_meta("gravels_dropped", 0)
			
			# 1. Kurangi timer setiap frame (waktu berjalan mundur)
			var sub_timer = enemy.get_meta("sub_timer", 0.0) - delta
			var pat_timer = enemy.get_meta("pattern_timer", 0.0) - delta
			
			enemy.set_meta("sub_timer", sub_timer)
			enemy.set_meta("pattern_timer", pat_timer)
			
			# 2. Jalankan Pattern
			if state == "rock_throw":
				if sub_timer <= 0:
					# Tembak batu
					spawn_enemy_projectile(enemy.global_position, player_pos, "rock", int(enemy.get_meta("damage")), false, 320.0)
					rocks += 1
					enemy.set_meta("rocks_thrown", rocks)
					
					# JIKA BATU BELUM 3, SET JEDA 1.5 DETIK UNTUK BATU BERIKUTNYA
					if rocks < 3:
						enemy.set_meta("sub_timer", 1.5)
					else:
						# KALAU SUDAH 3 BATU, JEDA 2 DETIK SEBELUM HUJAN KERIKIL
						state = "wait_rock"
						enemy.set_meta("pattern_timer", 2.0) 
						
			elif state == "wait_rock":
				if pat_timer <= 0:
					# Mulai hujan kerikil
					state = "gravel_rain"
					Sfx.play("earthquake")
					enemy.set_meta("gravels_dropped", 0)
					# Jeda 0.1 detik sebelum kerikil pertama muncul
					enemy.set_meta("sub_timer", 0.1) 
					
			elif state == "gravel_rain":
				if sub_timer <= 0:
					# Jatuhkan kerikil
					var rx = randf_range(750, 1600) # X Acak
					spawn_falling_gravel(rx, int(enemy.get_meta("damage") * 0.7))
					gravels += 1
					enemy.set_meta("gravels_dropped", gravels)
					
					# JIKA KERIKIL BELUM 12, SET JEDA 0.1 DETIK UNTUK KERIKIL BERIKUTNYA
					if gravels < 12:
						enemy.set_meta("sub_timer", 0.1)
					else:
						# KALAU SUDAH 12 KERIKIL, JEDA 2 DETIK LALU KEMBALI LEMPAR BATU
						state = "wait_gravel"
						enemy.set_meta("pattern_timer", 2.0) 
						
			elif state == "wait_gravel":
				if pat_timer <= 0:
					state = "rock_throw"
					enemy.set_meta("rocks_thrown", 0)
					enemy.set_meta("sub_timer", 0.3)
					
			enemy.set_meta("state", state)
		
		elif type == "crystal_golem_boss":
			var boulder_cd = enemy.get_meta("boulder_cd", 0.0) - delta
			enemy.set_meta("boulder_cd", boulder_cd)
			
			# 1. Jalan ke arah player (KECUALI kalau sedang jeda lempar batu)
			if boulder_cd > 5.5: # Jeda 0.5 detik berhenti buat lempar
				enemy.velocity.x = 0 
			else:
				enemy.velocity.x = dir * 40.0
				
			if is_blocked: enemy.velocity.y = -300.0
			
			# 2. MELEE SMASH
			if tabrakan and atk_timer <= 0:
				take_damage(enemy.get_meta("damage"))
				_track_revenger_attacker(enemy)
				clone_player.velocity.x = dir * 400.0 
				clone_player.velocity.y = -250.0 
				show_floating_text("SMASH!", enemy.global_position + Vector2(0, -40), Color.RED)
				atk_timer = 2.0
				
			# 3. LEMPAR BATU (Jarak > 8 blok & CD siap)
			if dist > 128.0 and boulder_cd <= 0:
				spawn_enemy_projectile(enemy.global_position, player_pos, "boulder", 15, false, 320.0)
				show_floating_text("BOULDER!", enemy.global_position + Vector2(0, -60), Color.CYAN)
				boulder_cd = 6.0 # <--- Cooldown dinaikkan jadi 6 detik
				
			enemy.set_meta("boulder_cd", boulder_cd)
			
		elif type == "goblin":
			var state = enemy.get_meta("state", "chase")
			var flee_timer = enemy.get_meta("flee_timer", 0.0)
			if state == "flee":
				enemy.velocity.x = -dir * 120.0
				flee_timer -= delta
				enemy.set_meta("flee_timer", flee_timer)
				if flee_timer <= 0: enemy.set_meta("state", "chase")
			else:
				if not tabrakan and not is_blocked_by_enemy: 
					enemy.velocity.x = dir * 100.0
				else: 
					enemy.velocity.x = push_force # Berhenti mengantri
				
				if is_blocked: enemy.velocity.y = -320.0 
				if tabrakan:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
					enemy.set_meta("state", "flee")
					enemy.set_meta("flee_timer", 3.0)
					
		elif type == "cannibal":
			var speed_mult = enemy.get_meta("buff_speed_mult", 1.0)
			if is_in_range:
				if not tabrakan and not is_blocked_by_enemy: 
					enemy.velocity.x = dir * 60.0 * speed_mult # <--- Dikalikan buff
				else: 
					enemy.velocity.x = 0
				
				if is_blocked: enemy.velocity.y = -380.0
				if tabrakan:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
					enemy.velocity.x = -dir * 100.0 
			else:
				enemy.velocity.x = 0
				
		elif type == "hunter":
			var state = enemy.get_meta("state", "attack")
			if state == "flee":
				enemy.velocity.x = -dir * 140.0
				if is_blocked: state = "attack"
				if dist > 150.0: state = "attack"
			elif state == "enraged":
				enemy.velocity.x = push_force # <--- Terapkan dorongan
				if atk_timer <= 0:
					spawn_enemy_projectile(enemy.global_position, player_pos, "arrow", 12, false, 320.0)
					atk_timer = 2.0
			else:
				enemy.velocity.x = push_force # <--- Terapkan dorongan
				if atk_timer <= 0:
					spawn_enemy_projectile(enemy.global_position, player_pos, "arrow", 12, false, 320.0)
					atk_timer = 2.0
				if dist < 128.0: state = "flee"
			enemy.set_meta("state", state)
			
		elif type == "cult":
			if is_in_range:
				if not tabrakan and not is_blocked_by_enemy: 
					enemy.velocity.x = dir * 50.0
				else: 
					enemy.velocity.x = 0
				
				if is_blocked: enemy.velocity.y = -380.0
				if tabrakan and atk_timer <= 0:
					take_damage(30) 
					_track_revenger_attacker(enemy)
					enemy.set_meta("atk_timer", 3.0) 
					enemy.velocity.x = -dir * 100.0 
			else:
				enemy.velocity.x = 0
				
		elif type == "spider":
			var web_timer = enemy.get_meta("web_timer", 2.0) - delta
			var melee_timer = enemy.get_meta("melee_timer", 0.0) - delta
			var post_melee_cd = enemy.get_meta("post_melee_cd", 0.0) - delta
			enemy.set_meta("web_timer", web_timer)
			enemy.set_meta("melee_timer", melee_timer)
			enemy.set_meta("post_melee_cd", post_melee_cd)
			
			if not tabrakan and not is_blocked_by_enemy: 
				enemy.velocity.x = dir * 120.0 
			else: 
				enemy.velocity.x = 0
				
			if is_blocked: enemy.velocity.y = -220.0
			if dist > 128.0 and dist < 240.0 and post_melee_cd <= 0.0 and web_timer <= 0:
				enemy.set_meta("web_timer", 3.5)
				spawn_enemy_projectile(enemy.global_position, player_pos, "web", 5, false, 96.0)
				
			if tabrakan:
				if melee_timer <= 0:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
					enemy.set_meta("melee_timer", 1.5)
					enemy.set_meta("post_melee_cd", 2.0)
				enemy.velocity.x = -dir * 50.0
				
		elif type == "cave_slime":
			if enemy.get_meta("armor_hp", 0) <= 0:
				var regen_t = enemy.get_meta("armor_regen_timer", 0.0) + delta
				if regen_t >= 40.0:
					enemy.set_meta("armor_hp", 200)
					enemy.set_meta("armor_regen_timer", 0.0)
					show_floating_text("ARMOR RESTORED!", enemy.global_position + Vector2(0, -40), Color.YELLOW)
				else:
					enemy.set_meta("armor_regen_timer", regen_t)
					
			if atk_timer <= 0:
				if dist > 192.0:
					spawn_enemy_projectile(enemy.global_position, player_pos, "rock", 35, false, 320.0)
					atk_timer = 2.0
				elif tabrakan:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
					atk_timer = 1.5
					
		elif type == "crystal_golem":
			if not tabrakan and not is_blocked_by_enemy: 
				enemy.velocity.x = dir * 40.0
			else: 
				enemy.velocity.x = 0
				
			if tabrakan and atk_timer <= 0:
				take_damage(enemy.get_meta("damage"))
				_track_revenger_attacker(enemy)
				clone_player.velocity.x = dir * 300.0
				clone_player.velocity.y = -200.0
				show_floating_text("SMASH!", enemy.global_position + Vector2(0, -40), Color.RED)
				atk_timer = 2.0
				
		enemy.set_meta("atk_timer", atk_timer)
		
		if player_hp <= 0:
			on_player_death_in_domain()
			return
			
		# --- HANYA INI YANG MENGGERAKKAN MEREKA ---
		enemy.move_and_slide()


func damage_enemy(enemy, amount, is_melee: bool = false, is_silent: bool = false):
	if not is_instance_valid(enemy): return
	var actual_dmg = amount
	
	# --- LOGIKA SHIELD CURANG CRYSTAL GOLEM ---
	if enemy.get_meta("type") == "crystal_golem_boss" and is_melee:
		var raw_amount = amount
		var current_armor = enemy.get_meta("armor_hp", 0)
		
		# 1. Shield yang ada menyerap damage dulu
		if current_armor > 0:
			var absorbed = min(actual_dmg, current_armor)
			current_armor -= absorbed
			actual_dmg -= absorbed
			enemy.set_meta("armor_hp", current_armor)
			show_floating_text(str(absorbed) + " (Shield)", enemy.global_position + Vector2(0, -20), Color.YELLOW)
			
		# 2. Golem menciptakan shield baru (30% dari RAW DAMAGE, bukan sisa damage)
		var added_shield = int(raw_amount * 0.3)
		current_armor += added_shield
		enemy.set_meta("armor_hp", current_armor)
		
		# Update Max Armor UI
		if current_armor > boss_max_armor:
			boss_max_armor = current_armor
			
		if is_instance_valid(boss_armor_bar):
			boss_armor_bar.size.x = 400.0 * (float(current_armor) / boss_max_armor)
			
		show_floating_text("+" + str(added_shield) + " Shield", enemy.global_position + Vector2(0, -60), Color.CYAN)
	# ------------------------------------------
	
	# --- LOGIKA LEDAKAN SHIELD CAVE SLIME ---
	if enemy.get_meta("type") == "cave_slime_boss" and enemy.get_meta("armor_hp", 0) > 0:
		var armor_hp = enemy.get_meta("armor_hp")
		if actual_dmg >= armor_hp:
			# Shield Pecah!
			enemy.set_meta("armor_hp", 0)
			if is_instance_valid(boss_armor_bar): boss_armor_bar.size.x = 0 # <--- Hancurkan bar kuning
			
			# --- TAMBAHKAN SUARA PECAH ---
			if not is_silent:
				Sfx.play("cave_slime_armor_break")
			# -----------------------------
			
			show_floating_text("SHIELD BROKEN!", enemy.global_position + Vector2(0, -60), Color.RED)
			# Efek Visual Ledakan
			var explosion = ColorRect.new()
			explosion.size = Vector2(100, 100)
			explosion.position = enemy.global_position - Vector2(50, 50)
			explosion.color = Color(0.8, 0.5, 0.1, 0.8)
			explosion.z_index = 15
			add_child(explosion)
			var t = create_tween()
			t.tween_property(explosion, "scale", Vector2(2, 2), 0.2)
			t.tween_property(explosion, "modulate:a", 0.0, 0.2)
			t.tween_callback(explosion.queue_free)
			
			# Knockback (8 Blok)
			var dir = sign(clone_player.global_position.x - enemy.global_position.x)
			clone_player.velocity.x = dir * 1200.0 # Kencang biar 8 blok
			clone_player.velocity.y = -200.0
			take_damage(1) # Damage murni 1
		else:
			enemy.set_meta("armor_hp", armor_hp - actual_dmg)
			
			# --- TAMBAHKAN SUARA KENA HIT ---
			if not is_silent:
				Sfx.play("cave_slime_armor_hurt")
			# --------------------------------
			
			# Update Bar Armor (Kuning)
			if is_instance_valid(boss_armor_bar):
				boss_armor_bar.size.x = 400.0 * (float(armor_hp - actual_dmg) / boss_max_armor)
				
			show_floating_text(str(actual_dmg) + " (Shield)", enemy.global_position + Vector2(0, -20), Color.YELLOW)
			return # Damage berhenti di shield
	# ----------------------------------------

	# (Sisa kode damage_enemy seperti biasa...)
	
	# --- BOSS GOBLIN DAMAGE REDUCTION (HANYA GOBLIN) ---
	if enemy.get_meta("type") == "goblin_boss":
		if enemy.get_meta("state") == "flee" and enemy.get_meta("invis_timer", 0.0) > 0:
			actual_dmg = int(actual_dmg * 0.2) # 80% DR
			show_floating_text("Resisted!", enemy.global_position + Vector2(0, -60), Color.CYAN)
	# ----------------------------------------------------
	
	# --- BUFF DARI CULT ---
	if enemy.get_meta("is_cult_buffed", false):
		actual_dmg = int(actual_dmg * 0.5) # 50% DR
		show_floating_text("Buffed Resisted!", enemy.global_position + Vector2(0, -60), Color.CYAN)
	# ----------------------
	
	# 1. Golem Resistance (HANYA physical -30%, bukan elemental/magic)
	if enemy.get_meta("type") == "crystal_golem":
		var _cur_w = Global.hotbar_items[main_ref.selected_hotbar_index]
		var _w_type = main_ref.item_data.get(_cur_w, {}).get("weapon_type", "Physical Damage")
		if _w_type == "Physical Damage":
			actual_dmg = int(actual_dmg * 0.7)
			show_floating_text("Resisted!", enemy.global_position + Vector2(0, -60), Color.GRAY)
		
	# 2. Cave Slime Armor
	if enemy.get_meta("type") == "cave_slime" and enemy.get_meta("armor_hp", 0) > 0:
		var armor_hp = enemy.get_meta("armor_hp")
		var armor_damage = min(actual_dmg, armor_hp)
		enemy.set_meta("armor_hp", armor_hp - armor_damage)
		actual_dmg -= armor_damage
		enemy.set_meta("armor_regen_timer", 0.0)
		show_floating_text(str(armor_damage) + " (Armor)", enemy.global_position + Vector2(0, -20), Color.YELLOW)
		
		# --- FIX 2: SUARA ARMOR CAVE SLIME ---
		if not is_silent:
			Sfx.play("cave_slime_armor_hurt") # Suara batu/keras saat dipukul
			if enemy.get_meta("armor_hp") == 0:
				Sfx.play("cave_slime_armor_break") # Suara pecah saat habis
		# -------------------------------------

	var hp = enemy.get_meta("hp") - actual_dmg
	if actual_dmg > 0: 
		show_floating_text(str(actual_dmg), enemy.global_position + Vector2(0, -40), Color.RED)
		
		# --- DETEKSI PINTAR SUARA (DENGAN LOGIKA SLIME) ---
		if not is_silent:
			var e_type = str(enemy.get_meta("type", "enemy")).to_lower()
			e_type = e_type.replace("_boss", "")
			
			if hp <= 0:
				# Kalau mati, selalu pakai suara slime mati
				Sfx.play(e_type + "_die")
			else:
				# --- LOGIKA KHUSUS CAVE SLIME ---
				if e_type == "cave_slime":
					# Cek apakah armor masih tersisa
					if enemy.get_meta("armor_hp", 0) > 0:
						Sfx.play("cave_slime_armor_hurt") # Suara Batu/Keras
					else:
						Sfx.play("cave_slime_hurt") # Suara Benyek/Slime
				else:
					# Musuh lain (Goblin, Spider, dll)
					Sfx.play(e_type + "_hurt")
			# ------------------------------------------------
		
	enemy.set_meta("hp", hp)
	
	# Update HP Bar
	var bar = enemy.get_meta("hp_bar")
	if bar: 
		bar.size.x = 30.0 * (float(max(hp,0)) / enemy.get_meta("max_hp"))
		if hp <= 0: bar.color = Color.RED
	
	# --- UPDATE UI BAR BOS (DI ATAS LAYAR) ---
	if "boss" in enemy.get_meta("type"): # <--- Ubah jadi ini (biar semua tipe bos kebaca)
		if is_instance_valid(boss_bar):
			boss_bar.size.x = 400.0 * (float(max(hp, 0)) / boss_max_hp)
	# -----------------------------------------
		
	# State Reaction
	if hp > 0:
		if enemy.get_meta("type") == "goblin":
			enemy.set_meta("state", "flee")
			enemy.set_meta("flee_timer", 3.0)
		elif enemy.get_meta("type") == "hunter":
			enemy.set_meta("state", "enraged")
			
	if hp <= 0:
		
		if "boss" in enemy.get_meta("type"):
			show_floating_text("BOSS DEFEATED!", enemy.global_position + Vector2(0, -60), Color.GOLD)
			if is_instance_valid(boss_ui): 
				boss_ui.visible = false 
				
			is_boss_defeated = true 
			spawn_boss_chest()
				
		enemy.queue_free()
		enemies.erase(enemy)
		
func on_player_death_in_domain():
	if is_player_dead: return
	is_player_dead = true
	crystal_armor_stacks = 0
	sgs_hit_counter = 0
	sgs_accelerate_stacks = 0
	revenger_stacks = 0
	revenger_target = null
	revenger_timer = 0.0
	conductor_charging = false
	conductor_charge_timer = 0.0
	conductor_tick_timer = 0.0
	deep_cave_active = false
	deep_cave_petrify_timer = 0.0
	deep_cave_regen_timer = 0.0
	deep_cave_cooldown = 0.0
	hammer_charging = false
	hammer_charge_timer = 0.0
	stormjade_charging = false
	stormjade_charge_timer = 0.0
	
	main_ref.lives = max(0, main_ref.lives - 1)
	main_ref.update_hp_ui()
	
	show_floating_text("You died! -1 Life", clone_player.global_position, Color.RED)
	
	# Hapus Kamera Bos & Layar Hitam
	if is_instance_valid(boss_cam):
		boss_cam.queue_free()
	if is_instance_valid(domain_cam):
		domain_cam.enabled = true
		domain_cam.make_current()
	if is_instance_valid(boss_cinematic_bg):
		boss_cinematic_bg.queue_free()
	
	# --- SEMBUNYIKAN BOS & HP BAR SAAT MATI ---
	if is_instance_valid(boss_ui):
		boss_ui.visible = false
		
	for e in enemies:
		if is_instance_valid(e) and "boss" in e.get_meta("type"):
			e.visible = false # Sembunyikan Bos
			e.velocity = Vector2.ZERO
			e.set_meta("state", "idle") # Ubah state biar gak jalan-jalan
			
	# Buka pintu bos biar bisa masuk lagi
	if has_node("BossDoorLock"):
		get_node("BossDoorLock").queue_free()
	is_boss_fight_started = false
	# -------------------------------------------
	
	await get_tree().create_timer(1.5).timeout
	
	if main_ref.lives > 0:
		player_hp = main_ref.max_hp
		clone_player.global_position = Vector2(-1900, -50) # Respawn di pintu masuk
		clone_player.z_index = 0
		clone_player.velocity = Vector2.ZERO
		damage_cooldown = 2.0 
		
		# Reset transisi agar bisa masuk bos lagi
		is_transitioning = false
		
		update_hud()
		is_player_dead = false
		show_floating_text("Respawned!", clone_player.global_position, Color.GREEN)
	else:
		show_floating_text("GAME OVER", clone_player.global_position, Color.RED)
		await get_tree().create_timer(1.0).timeout
		player_hp = 1 
		close_domain()

# Tambahkan max_distance: float = 9999.0 di parameter paling belakang
func spawn_enemy_projectile(start_pos: Vector2, target_pos: Vector2, proj_type: String, dmg: int, pierce_wall: bool = false, max_distance: float = 9999.0):
	var proj = ColorRect.new()
	proj.position = start_pos
	proj.z_index = 15
	proj.set_meta("is_enemy_proj", true)
	proj.set_meta("proj_type", proj_type)
	proj.set_meta("damage", dmg)
	proj.set_meta("pierce_wall", pierce_wall)
	proj.set_meta("velocity", (target_pos - start_pos).normalized())
	
	# --- TAMBAHKAN 2 BARIS INI ---
	proj.set_meta("spawn_pos", start_pos)
	proj.set_meta("max_distance", max_distance)
	# -----------------------------
	
	if proj_type == "rock":
		proj.size = Vector2(12, 12); proj.color = Color(0.5, 0.5, 0.5)
		proj.set_meta("velocity", proj.get_meta("velocity") * 400.0)
	elif proj_type == "web":
		proj.size = Vector2(16, 16); proj.color = Color(0.9, 0.9, 0.9, 0.8)
		proj.set_meta("velocity", proj.get_meta("velocity") * 150.0)
	elif proj_type == "arrow":
		proj.size = Vector2(20, 6)
		proj.color = Color(1.0, 0.8, 0.2)
		proj.set_meta("velocity", proj.get_meta("velocity") * 500.0)
	elif proj_type == "boulder":
		proj.size = Vector2(32, 32); proj.color = Color(0.4, 0.6, 0.8)
		proj.set_meta("velocity", proj.get_meta("velocity") * 400.0)
		
	proj.set_meta("life_timer", 2.0)
	proj.rotation = proj.get_meta("velocity").angle()
	
	# --- SUARA TEMBAK OTOMATIS ---
	if proj_type == "arrow": Sfx.play("arrow_shoot")
	elif proj_type == "web": Sfx.play("web_shoot")
	elif proj_type == "rock": Sfx.play("rock_throw")
	elif proj_type == "boulder": Sfx.play("boulder_throw")
	# -----------------------------
	
	add_child(proj)
	arrows.append(proj)

func spawn_thrown_web(start_pos: Vector2, is_sticky: bool = false):
	var web = ColorRect.new()
	web.position = start_pos
	web.size = Vector2(24, 24) 
	web.z_index = 15
	
	web.set_meta("is_enemy_proj", true)
	
	# --- KUNCI JALUR PARABOLA ---
	# Tentukan titik jatuh acak di dalam ruangan (X: 800 s/d 1560)
	var target_x = randf_range(800.0, 1560.0)
	var time_to_land = 2.0 # Waktu yang dibutuhkan untuk jatuh (detik)
	var vel_x = (target_x - start_pos.x) / time_to_land
	
	web.set_meta("velocity", Vector2(vel_x, -1000)) # Lempar sangat tinggi
	web.set_meta("damage", 0)
	
	if is_sticky:
		web.color = Color(0.2, 0.6, 1.0, 0.8) # Warna BIRU
		web.set_meta("proj_type", "sticky_web")
		web.set_meta("life_timer", 4.0) 
	else:
		web.color = Color(0.9, 0.9, 0.9, 0.8) # Warna PUTIH
		web.set_meta("proj_type", "falling_web")
		web.set_meta("life_timer", 5.0)
		
	add_child(web)
	arrows.append(web)

func spawn_falling_gravel(x_pos: float, dmg: int):
	var gravel = ColorRect.new()
	gravel.position = Vector2(x_pos, -600) # Jatuh dari atap
	gravel.size = Vector2(16, 16) 
	gravel.color = Color(0.6, 0.6, 0.6) # Warna Abu-abu
	gravel.z_index = 15
	
	gravel.set_meta("is_enemy_proj", true)
	gravel.set_meta("damage", dmg)
	gravel.set_meta("proj_type", "falling_gravel")
	gravel.set_meta("velocity", Vector2(0, 800)) # Jatuh cepat
	gravel.set_meta("life_timer", 3.0)
	
	add_child(gravel)
	arrows.append(gravel)

func tambah_item(item_name: String, amount: int = 1):
	var is_weapon = main_ref.item_data.get(item_name, {}).has("weapon_type")
	
	if is_weapon:
		for i in range(amount):
			var _has_weapon = false
			for _k in inventory.keys():
				if Global.get_base_name(_k) == item_name:
					_has_weapon = true
					break
			if not _has_weapon:
				for _h in Global.hotbar_items:
					if _h == item_name:
						_has_weapon = true
						break
			if not _has_weapon and Global.equipped_armor == item_name:
				_has_weapon = true
				
			if _has_weapon:
				inventory["Scrap"] = inventory.get("Scrap", 0) + 5
				if is_instance_valid(clone_player):
					show_floating_text("+5 Scrap (Dup)", clone_player.global_position, Color.GRAY)
			else:
				var new_key = Global.create_weapon_key(item_name)
				inventory[new_key] = 1
				Global.item_levels[new_key] = 1
	else:
		inventory[item_name] = inventory.get(item_name, 0) + amount
	
	if is_instance_valid(clone_player):
		update_inventory_ui()
		update_hud()

func setup_fresh_session(inv_data: Dictionary) -> void:
	inventory = inv_data.duplicate()
	player_hp = main_ref.current_hp
	player_mana = main_ref.current_mana
	update_hud()
	update_inventory_ui()

func force_camera() -> void:
	if is_instance_valid(domain_cam):
		domain_cam.make_current()
	_play_domain_bgm()
		
func resume_domain() -> void:
	# Nyalakan kembali kamera saat player masuk ke domain ini lagi
	if is_instance_valid(clone_player):
		var cam = clone_player.get_node_or_null("Camera2D")
		if cam: cam.make_current()
		
func take_damage(amount):
	if is_player_dead: return
	if damage_cooldown > 0: return
	if amount <= 0: return  # Debuff (web dll) tidak bisa parry
	
	# --- GALAHAD PARRY COUNTER ---
	if galahad_parry_active:
		galahad_parry_active = false
		damage_cooldown = 0.7
		show_floating_text("PARRIED!", clone_player.global_position + Vector2(0, -40), Color.GOLD)
		
		var _weapon = Global.hotbar_items[main_ref.selected_hotbar_index]
		if _weapon == "Galahad Chimelin":
			var _uid = Global.hotbar_uuids[main_ref.selected_hotbar_index]
			var _stats = Global.get_effective_stats(_weapon, main_ref.item_data.get(_weapon, {}), _uid)
			var _counter_dmg = int(_stats.get("damage", 65) * 1.75 * main_ref.buff_dmg_mult)
			var _facing = sign(get_global_mouse_position().x - clone_player.global_position.x)
			if _facing == 0: _facing = 1
			
			for _e in enemies.duplicate():
				if not is_instance_valid(_e): continue
				var _e_half_w = _e.get_meta("size", 16.0) / 2.0
				var _dist = clone_player.global_position.distance_to(_e.global_position) - _e_half_w
				if _dist > 128: continue
				
				var _dx = _e.global_position.x - clone_player.global_position.x
				var _edge_left = _dx - _e_half_w
				var _edge_right = _dx + _e_half_w
				if _facing > 0 and _edge_right < -16: continue
				if _facing < 0 and _edge_left > 16: continue
				
				var _ct = _e.get_meta("type")
				var _dmg_left = _counter_dmg
				if _ct == "cave_slime" and _e.get_meta("armor_hp", 0) > 0:
					var _armor = _e.get_meta("armor_hp")
					var _absorbed = min(_dmg_left, _armor)
					_e.set_meta("armor_hp", _armor - _absorbed)
					_e.set_meta("armor_regen_timer", 0.0)
					_dmg_left -= _absorbed
					show_floating_text(str(_absorbed) + " (Armor)", _e.global_position + Vector2(0, -60), Color.YELLOW)
				
				if _dmg_left > 0:
					var _hp = _e.get_meta("hp") - _dmg_left
					_e.set_meta("hp", _hp)
					
					# --- TAMBAHKAN INI ---
					var _ename = _ct.to_lower().replace("_boss", "")
					Sfx.play(_ename + "_hurt")
					# ---------------------

					var _bar = _e.get_meta("hp_bar", null)
					if _bar: _bar.size.x = 30.0 * (float(max(_hp, 0)) / _e.get_meta("max_hp"))
					if "boss" in _ct and is_instance_valid(boss_bar):
						boss_bar.size.x = 400.0 * (float(max(_hp, 0)) / boss_max_hp)
					show_floating_text(str(_dmg_left) + " PARRY!", _e.global_position + Vector2(0, -40), Color.GOLD)
				else:
					var _bar = _e.get_meta("hp_bar", null)
					if _bar: _bar.size.x = 30.0 * (float(max(_e.get_meta("hp"), 0)) / _e.get_meta("max_hp"))
				
				var _kb_dir = sign(_e.global_position.x - clone_player.global_position.x)
				if _kb_dir == 0: _kb_dir = _facing
				_safe_knockback(_e, _kb_dir, 64)
				if _e.has_meta("knockback_timer"):
					_e.set_meta("knockback_timer", 1.0)
				
				if _e.get_meta("hp", 1) <= 0:
					galahad_stacks = min(galahad_stacks + 1, 80)
					show_floating_text("+" + str(galahad_stacks) + "% DMG", clone_player.global_position + Vector2(0, -60), Color.GOLD)
					if "boss" in _ct:
						show_floating_text("BOSS DEFEATED!", _e.global_position + Vector2(0, -60), Color.GOLD)
						if is_instance_valid(boss_ui): boss_ui.visible = false
						is_boss_defeated = true
						spawn_boss_chest()
					enemies.erase(_e)
					if is_instance_valid(_e):
						_e.queue_free()
			
			var _fan = ColorRect.new()
			_fan.size = Vector2(128, 80)
			if _facing > 0:
				_fan.position = Vector2(clone_player.global_position.x, clone_player.global_position.y - 40)
			else:
				_fan.position = Vector2(clone_player.global_position.x - 128, clone_player.global_position.y - 40)
			_fan.color = Color(1.0, 0.9, 0.3, 0.7)
			_fan.z_index = 15
			add_child(_fan)
			var _t = create_tween()
			_t.tween_property(_fan, "modulate:a", 0.0, 0.3)
			_t.tween_callback(_fan.queue_free)
		return
	# -----------------------------
	
	# --- DEEP CAVE ARMOR: invuln saat petrify ---
	if deep_cave_active:
		show_floating_text("INVULNERABLE!", clone_player.global_position + Vector2(0, -40), Color.GRAY)
		return
	# ---------------------------------------------
	
	var actual_dmg = amount
	var armor_dr = 0
	if Global.equipped_armor != null:
		var armor_data = Global.get_effective_stats(Global.equipped_armor, main_ref.item_data.get(Global.equipped_armor, {}), Global.equipped_armor_uuid)
		armor_dr = armor_data.get("damage_reduction", 0)
	
	# --- PASSIVE HEAVY AMETHYST ARMOR ---
	if Global.equipped_armor == "Heavy Amethyst Armor":
		if has_meta("amethyst_buffed"):
			armor_dr += 5
			remove_meta("amethyst_buffed")
		elif amount > 10:
			set_meta("amethyst_buffed", true)
	# -------------------------------------
	
	if Global.equipped_armor == "Crystal Armor":
		crystal_armor_stacks = min(crystal_armor_stacks + 1, 10)
		armor_dr += crystal_armor_stacks * 0.5
		crystal_armor_timer = 7.0 # <--- RESET TIMER
		show_floating_text("Crystal Stack: " + str(crystal_armor_stacks) + "/10", clone_player.global_position + Vector2(0, -80), Color.CYAN)
	
	actual_dmg -= armor_dr
	actual_dmg = max(1, int(actual_dmg))
	player_hp = max(0, player_hp - actual_dmg)
	damage_cooldown = 1.0
	# --- SUARA PEMAIN KENA HIT ---
	Sfx.play("player_hurt")
	# -----------------------------
	show_floating_text("-" + str(actual_dmg) + " HP", clone_player.global_position + Vector2(0,-40), Color.RED)
	update_hud()
	
	# --- ARMOR BLUEPRINT PASSIVES ---
	if Global.equipped_armor == "Metal Skin Armor":
		var _nearest = null
		var _nearest_dist = 100.0
		for _e in enemies:
			if is_instance_valid(_e):
				var _d = clone_player.global_position.distance_to(_e.global_position)
				if _d < _nearest_dist:
					_nearest_dist = _d
					_nearest = _e
		if _nearest != null:
			# Thorns pre-mitigation (pakai amount raw)
			var _reflect = max(1, int(amount * 0.20))
			show_floating_text(str(_reflect) + " (Reflect)", _nearest.global_position + Vector2(0, -40), Color.CYAN)
			damage_enemy(_nearest, _reflect, false)
	
	if Global.equipped_armor == "Shining Justice":
		if randf() < 0.35:
			var _ores = ["Copper", "Iron", "Coal", "Silver", "Gold", "Mithril", "Quartz", "Topaz", "Emerald", "Amethyst", "Diamond", "Void Crystal", "Uberilium"]
			var _drop = _ores.pick_random()
			inventory[_drop] = inventory.get(_drop, 0) + 1
			show_floating_text("+" + _drop, clone_player.global_position + Vector2(0, -100), Color.GOLD)
			update_inventory_ui()
	
	if Global.equipped_armor == "Deep Cave Armor" and not deep_cave_active and deep_cave_cooldown <= 0:
		if player_hp < main_ref.max_hp * 0.5 and player_hp > 0:
			deep_cave_active = true
			deep_cave_petrify_timer = 2.0
			deep_cave_regen_timer = 0.0
			deep_cave_cooldown = 30.0
			clone_player.set_physics_process(false)
			show_floating_text("PETRIFIED!", clone_player.global_position + Vector2(0, -60), Color.GRAY)
	# --------------------------------
	
	if player_hp <= 0:
		# --- SUARA PEMAIN MATI ---
		Sfx.play("player_die")
		# -------------------------
		on_player_death_in_domain()

func bikin_ui_bos():
	var canvas = CanvasLayer.new()
	canvas.layer = 12
	add_child(canvas)
	
	boss_ui = VBoxContainer.new()
	# Posisi di tengah atas layar
	boss_ui.anchor_left = 0.5
	boss_ui.anchor_right = 0.5
	boss_ui.offset_left = -200
	boss_ui.offset_right = 200
	boss_ui.offset_top = 60
	boss_ui.visible = false # Sembunyikan dulu
	canvas.add_child(boss_ui)
	
	# 1. Teks Nama Bos
	boss_name_label = Label.new() # <--- Ubah 'var lbl' jadi 'boss_name_label'
	boss_name_label.text = "" # <--- Kosongkan, nanti diisi saat bos spawn
	boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name_label.add_theme_font_size_override("font_size", 22)
	boss_name_label.add_theme_color_override("font_color", Color.GOLD)
	boss_name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	boss_name_label.add_theme_constant_override("outline_size", 5)
	boss_ui.add_child(boss_name_label)
	
	# 2. Background Bar (Warna Hitam)
	var bg = ColorRect.new()
	bg.custom_minimum_size = Vector2(400, 14) # <--- Total Tinggi 14
	bg.color = Color.BLACK
	boss_ui.add_child(bg)
	
	# 3. Bar Armor (Kuning - Atas)
	boss_armor_bar = ColorRect.new()
	boss_armor_bar.size = Vector2(0, 7)  # Default 0 = tidak tampil
	boss_armor_bar.position = Vector2(0, 0)
	boss_armor_bar.color = Color.YELLOW
	bg.add_child(boss_armor_bar)
	
	# 4. Bar Darah (Merah - Bawah)
	boss_bar = ColorRect.new()
	boss_bar.size = Vector2(400, 7) # <--- Setengah bawah
	boss_bar.position = Vector2(0, 7)
	boss_bar.color = Color.RED
	bg.add_child(boss_bar)

	# PROMPT INTERAKSI PINTU BOS
	boss_prompt = Label.new()
	boss_prompt.text = "Press [E] to enter Boss Room"
	boss_prompt.add_theme_font_size_override("font_size", 24)
	boss_prompt.add_theme_color_override("font_color", Color.YELLOW)
	boss_prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	boss_prompt.add_theme_constant_override("outline_size", 5)
	boss_prompt.visible = false
	boss_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_prompt.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_prompt.position = Vector2(-200, 200)
	boss_prompt.size = Vector2(400, 40)
	canvas.add_child(boss_prompt)

func spawn_boss_chest():
	_play_domain_bgm(domain_bgm_time)
	
	await get_tree().create_timer(0.5).timeout
	
	# Guard: kalau chest sudah ada (dari boss death sebelumnya), jangan spawn lagi
	if is_instance_valid(boss_chest):
		return
	
	boss_chest = Node2D.new()
	boss_chest.position = Vector2(1180, -20) # Tengah ruangan
	boss_chest.z_index = 10
	
	var vis = ColorRect.new()
	vis.size = Vector2(40, 40)
	vis.position = Vector2(-20, -40)
	vis.color = Color(0.6, 0.3, 0.1) # Warna kayu
	boss_chest.add_child(vis)
	
	var lbl = Label.new()
	lbl.text = "BOSS CHEST\n(Press E)"
	lbl.position = Vector2(-40, -70)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color.GOLD)
	boss_chest.add_child(lbl)
	
	add_child(boss_chest)
	show_floating_text("A chest appeared!", boss_chest.global_position + Vector2(0, -50), Color.GOLD)

func open_boss_chest():
	if boss_chest == null or not is_instance_valid(boss_chest): 
		return
	
	var chest_pos = boss_chest.global_position
	
	# --- 1. GUARANTEE LOOT (Scaling per Difficulty) ---
	var diff_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var gold_amt = randi_range(int(50 * diff_mult), int(110 * diff_mult))
	var scrap_amt = randi_range(int(11 * diff_mult), int(18 * diff_mult))
	var essence_amt = randi_range(int(14 * diff_mult), int(25 * diff_mult))
	
	domain_gold += gold_amt  
	inventory["Scrap"] = inventory.get("Scrap", 0) + scrap_amt
	inventory["Essence Crystal"] = inventory.get("Essence Crystal", 0) + essence_amt
	
	# --- 2. BP vs PART ROLL (100%) ---
	# Threshold kumulatif per domain (empty slot = fallback ke Part)
	var _bp_pool = []
	
	if domain_name == "Domain of Tricks":
		# SGS 25% + Metal Skin 20% + Ricochet Bow 25% + Part 30%
		_bp_pool = [
			{"bp": "Blueprint Silver Gray Sword", "weapon": "Silver Gray Sword", "threshold": 25.0},
			{"bp": "Blueprint Metal Skin Armor", "weapon": "Metal Skin Armor", "threshold": 45.0},
			{"bp": "Blueprint Ricochet Bow", "weapon": "Ricochet Bow", "threshold": 70.0},
		]
	elif domain_name == "Domain of Brutality":
		# Golden Conductor 35% + Bonecrusher 35% + Part 30%
		_bp_pool = [
			{"bp": "Blueprint Golden Conductor", "weapon": "Golden Conductor", "threshold": 35.0},
			{"bp": "Blueprint Bonecrusher", "weapon": "Bonecrusher", "threshold": 70.0},
		]
	elif domain_name == "Domain of Precision":
		# Shining Justice 35% + Bounty Bow 35% + Part 30%
		_bp_pool = [
			{"bp": "Blueprint Shining Justice", "weapon": "Shining Justice", "threshold": 35.0},
			{"bp": "Blueprint Bounty Bow", "weapon": "Bounty Bow", "threshold": 70.0},
		]
	elif domain_name == "Domain of Believer":
		_bp_pool = [
			{"bp": "Blueprint Deep Cave Armor", "weapon": "Deep Cave Armor", "threshold": 25.0},
			{"bp": "Blueprint Magic Pickaxe", "weapon": "Magic Pickaxe", "threshold": 45.0},
			{"bp": "Blueprint Radiance Scepter", "weapon": "Radiance Scepter", "threshold": 70.0},
		]
	elif domain_name == "Domain of Cheap":
		# Stormjade 35% + [Range#4 empty 35%] + Part 30%
		_bp_pool = [
			{"bp": "Blueprint Stormjade Cutter", "weapon": "Stormjade Cutter", "threshold": 35.0},
		]
	elif domain_name == "Domain of Power":
		_bp_pool = [
			{"bp": "Blueprint Revenger Crystallinum", "weapon": "Revenger Crystallinum", "threshold": 25.0},
			{"bp": "Blueprint Tenacity Battle Armor", "weapon": "Tenacity Battle Armor", "threshold": 50.0},
			{"bp": "Blueprint Headhitter Heavy Bow", "weapon": "Headhitter Heavy Bow", "threshold": 70.0},
		]
	elif domain_name == "Domain of Durability":
		# Crystal Hammer 35% + Pneumatic Drill 35% + Part 30%
		_bp_pool = [
			{"bp": "Blueprint Crystal Hammer", "weapon": "Crystal Hammer", "threshold": 35.0},
			{"bp": "Blueprint Pneumatic Drill", "weapon": "Pneumatic Drill", "threshold": 70.0},
		]
	
	# Boss-specific part
	var boss_part = ""
	if boss_type == "Powerful Goblin": boss_part = "Dagger Part ⚔️"
	elif boss_type == "Powerful Cannibal": boss_part = "Chainsaw Part ⚔️"
	elif boss_type == "Powerful Hunter": boss_part = "Hunter Bow Part ⚔️"
	elif boss_type == "Powerful Cult": boss_part = "Heretic Staff Part ⚔️"
	elif boss_type == "Powerful Spider": boss_part = "Mourning Bow Part ⚔️"
	elif boss_type == "Powerful Cave Slime": boss_part = "Crystal Minigun Part ⚔️"
	elif boss_type == "Powerful Crystal Golem": boss_part = "Crystal Armor Part ⚔️"
	
	# Roll
	var _roll = randf() * 100.0
	var _loot_bp = ""
	var _loot_dup_scrap = false
	var _loot_part = false
	
	# Check BP thresholds (cumulative)
	var _matched = false
	for _entry in _bp_pool:
		if _roll < _entry["threshold"]:
			_matched = true
			var _bp_name = _entry["bp"]
			var _weapon_name = _entry["weapon"]
			
			# Cek sudah punya di manapun
			var _already_have = false
			if _weapon_name in Global.unlocked_blueprints: _already_have = true
			if not _already_have and inventory.has(_bp_name): _already_have = true
			if not _already_have and Global.saved_inventory.has(_bp_name): _already_have = true
			if not _already_have and (Global.ore_storage.has(_bp_name) or Global.material_storage.has(_bp_name) or Global.weapon_storage.has(_bp_name)): _already_have = true
			
			if _already_have:
				_loot_dup_scrap = true
			else:
				_loot_bp = _bp_name
			break
	
	# If not matched BP: either Part zone (70-100) or empty BP slot (fallback to Part)
	if not _matched:
		if boss_part != "":
			inventory[boss_part] = inventory.get(boss_part, 0) + 1
			_loot_part = true
	
	# Apply BP or dup scrap
	if _loot_bp != "":
		inventory[_loot_bp] = inventory.get(_loot_bp, 0) + 1
	elif _loot_dup_scrap:
		inventory["Scrap"] = inventory.get("Scrap", 0) + 5
	
	update_hud()
	update_inventory_ui()
	
	# --- 3. HAPUS PETI ---
	var chest_ref = boss_chest 
	boss_chest = null          
	chest_ref.queue_free()     
	
	# --- 4. ANTREAN FLOATING TEXT ---
	var loot_texts = []
	loot_texts.append({"text": "+" + str(gold_amt) + " Gold", "color": Color.GOLD})
	loot_texts.append({"text": "Scrap x" + str(scrap_amt), "color": Color.LIGHT_GRAY})
	loot_texts.append({"text": "Essence x" + str(essence_amt), "color": Color(0.8, 0.2, 1.0)})
	
	if _loot_bp != "":
		loot_texts.append({"text": "BLUEPRINT: " + _loot_bp, "color": Color.CYAN})
	elif _loot_dup_scrap:
		loot_texts.append({"text": "+5 Scrap (BP dup)", "color": Color.LIGHT_GRAY})
	elif _loot_part:
		loot_texts.append({"text": "RARE: " + boss_part, "color": Color.CYAN})
	
	for i in range(loot_texts.size()):
		var offset = Vector2(randi_range(-20, 20), -40 - (i * 10))
		show_floating_text(loot_texts[i]["text"], chest_pos + offset, loot_texts[i]["color"])
		await get_tree().create_timer(0.2).timeout
		
	show_floating_text("Go to the left door to leave!", clone_player.global_position + Vector2(0, -100), Color.CYAN)
	
	# --- SYNC LOOT KE GLOBAL (biar langsung muncul di backpack) ---
	Global.saved_inventory = inventory.duplicate()
	Global.save_game()
	update_inventory_ui()

func exit_boss_room():
	# Simpan waktu lagu boss, lalu lanjutkan lagu domain dari waktu terakhir
	boss_bgm_time = MusicManager.get_precise_time()
	_play_domain_bgm(domain_bgm_time) # <--- Cukup sisakan yang ini saja!
	
	is_transitioning = true
	is_boss_fight_started = false
	clone_player.set_physics_process(false)
	
	# Sembunyikan HP bar boss (biar tidak noise saat player di luar)
	if is_instance_valid(boss_ui):
		boss_ui.visible = false
	
	# 1. Fade Out (Hitam)
	var fade_layer = CanvasLayer.new()
	fade_layer.layer = 100
	add_child(fade_layer)
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.size = get_viewport().get_visible_rect().size
	fade_layer.add_child(fade)
	
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	await tween.finished
	
	# 2. HAPUS SEMUA EFEK BOS (KECUALI BossDoorLock — biar boss tetap terkurung)
	if is_instance_valid(boss_cam): boss_cam.queue_free()
	if is_instance_valid(boss_cinematic_bg): boss_cinematic_bg.queue_free()
	# BossDoorLock DIBIARKAN — boss tidak bisa keluar ngejar player
	
	# 3. KEMBALIKAN KAMERA NORMAL
	if is_instance_valid(domain_cam):
		domain_cam.enabled = true
		domain_cam.limit_right = 720 # Kembalikan batas kamera domain
		domain_cam.make_current()
		
	# 4. KEMBALIKAN PLAYER KE LUAR RUANGAN
	clone_player.global_position = Vector2(600, -50)
	clone_player.z_index = 0 # Reset urutan visual
	
	# 5. RESET STATUS (Agar bisa masuk lagi atau keluar domain)
	is_boss_fight_started = false
	is_boss_defeated = false
	
	# 6. Fade In (Terang)
	var tween2 = create_tween()
	tween2.tween_property(fade, "color:a", 0.0, 0.5)
	await tween2.finished
	fade_layer.queue_free()
	
	clone_player.set_physics_process(true)
	is_transitioning = false

func reset_boss_room():
	if is_instance_valid(boss_cam): boss_cam.queue_free()
	if is_instance_valid(boss_cinematic_bg): boss_cinematic_bg.queue_free()
	if has_node("BossDoorLock"): get_node("BossDoorLock").queue_free()
	if is_instance_valid(boss_chest): boss_chest.queue_free()
	
	# Pastikan HP bar boss tidak nyangkut saat domain di-close
	if is_instance_valid(boss_ui):
		boss_ui.visible = false
	
	if is_instance_valid(domain_cam):
		domain_cam.enabled = true
		domain_cam.limit_right = 720 
		domain_cam.make_current()
		
	clone_player.z_index = 0
	is_boss_fight_started = false
	is_boss_defeated = false
	is_transitioning = false

func _track_revenger_attacker(attacker):
	if Global.hotbar_items[main_ref.selected_hotbar_index] != "Revenger Crystallinum": return
	if not is_instance_valid(attacker): return
	if revenger_target == attacker:
		revenger_stacks = min(revenger_stacks + 1, 3)
	else:
		revenger_target = attacker
		revenger_stacks = 1
	revenger_timer = 5.0
	show_floating_text("Revenge +" + str(revenger_stacks * 30) + "%", clone_player.global_position + Vector2(0, -100), Color.RED)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.saved_inventory = inventory.duplicate()
		Global.wipe_dungeon_fail()
		get_tree().quit()
		
func _safe_knockback(target, direction: float, distance: float):
	if not is_instance_valid(target): return
	if target.is_queued_for_deletion(): return
	
	# Substep movement untuk cegah tunneling
	var _total = Vector2(direction * distance, 0)
	var _step_size = 4.0
	var _steps = max(1, int(abs(distance) / _step_size))
	var _step_vec = _total / _steps
	
	for _i in range(_steps):
		if not is_instance_valid(target): return
		if target is CharacterBody2D:
			var _col = target.move_and_collide(_step_vec)
			if _col:
				break  # Kena wall, stop
		else:
			target.global_position += _step_vec

func _change_hotbar_slot_domain(direction: int):
	var _new_idx = main_ref.selected_hotbar_index + direction
	if _new_idx < 0: _new_idx = 6
	elif _new_idx > 6: _new_idx = 0
	
	if _new_idx == main_ref.selected_hotbar_index: return
	
	main_ref.selected_hotbar_index = _new_idx
	
	attack_cooldown = 0.0
	sgs_hit_counter = 0
	sgs_accelerate_stacks = 0
	revenger_stacks = 0
	revenger_target = null
	conductor_charging = false
	conductor_charge_timer = 0.0
	conductor_tick_timer = 0.0
	hammer_charging = false
	hammer_charge_timer = 0.0
	stormjade_charging = false
	stormjade_charge_timer = 0.0
	
	update_hud()

func _clamp_boss_to_arena(boss: Node2D):
	if not is_instance_valid(boss): return
	var _bx = boss.global_position.x
	var _by = boss.global_position.y
	if _bx < 720: boss.global_position.x = 720
	elif _bx > 1640: boss.global_position.x = 1640
	if _by < -620: boss.global_position.y = -620
	elif _by > -10: boss.global_position.y = -10

func _play_domain_bgm(start_time: float = 0.0):
	var bgm_path = "res://audio/bgm_domain_default.mp3"
	match boss_type:
		"Powerful Goblin":        bgm_path = "res://audio/bgm_domain_goblin.mp3"
		"Powerful Cannibal":      bgm_path = "res://audio/bgm_domain_cannibal.mp3"
		"Powerful Hunter":        bgm_path = "res://audio/bgm_domain_hunter.mp3"
		"Powerful Cult":          bgm_path = "res://audio/bgm_domain_cult.mp3"
		"Powerful Spider":        bgm_path = "res://audio/bgm_domain_spider.mp3"
		"Powerful Cave Slime":    bgm_path = "res://audio/bgm_domain_cave_slime.mp3"
		"Powerful Crystal Golem": bgm_path = "res://audio/bgm_domain_crystal_golem.mp3"
	
	if bgm_path != "":
		MusicManager.play_bgm(bgm_path, start_time)
