extends Node

var _players: Array[AudioStreamPlayer] = []
var _sounds: Dictionary = {}

func _ready():
	# Pastikan tulisannya .ogg
	if ResourceLoader.exists("res://audio/sfx_hover.ogg"):
		_sounds["hover"] = load("res://audio/sfx_hover.ogg")
	if ResourceLoader.exists("res://audio/sfx_click.ogg"):
		_sounds["click"] = load("res://audio/sfx_click.ogg")
	# --- Suara Gameplay/UI Spesifik ---
	if ResourceLoader.exists("res://audio/sfx_tick.ogg"):
		_sounds["tick"] = load("res://audio/sfx_tick.ogg")
	if ResourceLoader.exists("res://audio/sfx_error.ogg"):
		_sounds["error"] = load("res://audio/sfx_error.ogg")
	if ResourceLoader.exists("res://audio/sfx_ready.ogg"):
		_sounds["ready"] = load("res://audio/sfx_ready.ogg")
	if ResourceLoader.exists("res://audio/sfx_coin.ogg"):
		_sounds["coin"] = load("res://audio/sfx_coin.ogg")
	if ResourceLoader.exists("res://audio/sfx_drop.ogg"):
		_sounds["drop"] = load("res://audio/sfx_drop.ogg")
	if ResourceLoader.exists("res://audio/sfx_upgrade.ogg"):
		_sounds["upgrade"] = load("res://audio/sfx_upgrade.ogg")
	if ResourceLoader.exists("res://audio/sfx_interact.ogg"):
		_sounds["interact"] = load("res://audio/sfx_interact.ogg")
	if ResourceLoader.exists("res://audio/sfx_door.ogg"):
		_sounds["door"] = load("res://audio/sfx_door.ogg")
	
	# --- SUARA MUSUH SPESIFIK: KENA HIT (Format .mp3 dari Pixabay) ---
	if ResourceLoader.exists("res://audio/sfx_goblin_hurt.mp3"):
		_sounds["goblin_hurt"] = load("res://audio/sfx_goblin_hurt.mp3")
	if ResourceLoader.exists("res://audio/sfx_cave_slime_hurt.mp3"):
		_sounds["cave_slime_hurt"] = load("res://audio/sfx_cave_slime_hurt.mp3")
	if ResourceLoader.exists("res://audio/sfx_crystal_golem_hurt.mp3"):
		_sounds["crystal_golem_hurt"] = load("res://audio/sfx_crystal_golem_hurt.mp3")
	if ResourceLoader.exists("res://audio/sfx_spider_hurt.mp3"):
		_sounds["spider_hurt"] = load("res://audio/sfx_spider_hurt.mp3")
	if ResourceLoader.exists("res://audio/sfx_cannibal_hurt.mp3"):
		_sounds["cannibal_hurt"] = load("res://audio/sfx_cannibal_hurt.mp3")
	if ResourceLoader.exists("res://audio/sfx_cult_hurt.mp3"):
		_sounds["cult_hurt"] = load("res://audio/sfx_cult_hurt.mp3")
	if ResourceLoader.exists("res://audio/sfx_hunter_hurt.mp3"):
		_sounds["hunter_hurt"] = load("res://audio/sfx_hunter_hurt.mp3")
	
	# --- SUARA MUSUH SPESIFIK: MATI (Format .mp3 dari Pixabay) ---
	if ResourceLoader.exists("res://audio/sfx_goblin_die.mp3"):
		_sounds["goblin_die"] = load("res://audio/sfx_goblin_die.mp3")
	if ResourceLoader.exists("res://audio/sfx_cave_slime_die.mp3"):
		_sounds["cave_slime_die"] = load("res://audio/sfx_cave_slime_die.mp3")
	if ResourceLoader.exists("res://audio/sfx_crystal_golem_die.mp3"):
		_sounds["crystal_golem_die"] = load("res://audio/sfx_crystal_golem_die.mp3")
	if ResourceLoader.exists("res://audio/sfx_spider_die.mp3"):
		_sounds["spider_die"] = load("res://audio/sfx_spider_die.mp3")
	if ResourceLoader.exists("res://audio/sfx_cannibal_die.mp3"):
		_sounds["cannibal_die"] = load("res://audio/sfx_cannibal_die.mp3")
	if ResourceLoader.exists("res://audio/sfx_cult_die.mp3"):
		_sounds["cult_die"] = load("res://audio/sfx_cult_die.mp3")
	if ResourceLoader.exists("res://audio/sfx_hunter_die.mp3"):
		_sounds["hunter_die"] = load("res://audio/sfx_hunter_die.mp3")
	if ResourceLoader.exists("res://audio/sfx_cave_slime_armor_break.mp3"):
		_sounds["cave_slime_armor_break"] = load("res://audio/sfx_cave_slime_armor_break.mp3")
	if ResourceLoader.exists("res://audio/sfx_cave_slime_armor_hurt.mp3"):
		_sounds["cave_slime_armor_hurt"] = load("res://audio/sfx_cave_slime_armor_hurt.mp3")
	# -----------------------------------------
	
	# --- SUARA PROYEKTIL & SKILL BOS ---
	if ResourceLoader.exists("res://audio/sfx_teleport.mp3"):
		_sounds["teleport"] = load("res://audio/sfx_teleport.mp3")
	if ResourceLoader.exists("res://audio/sfx_arrow_shoot.mp3"):
		_sounds["arrow_shoot"] = load("res://audio/sfx_arrow_shoot.mp3")
	if ResourceLoader.exists("res://audio/sfx_web_shoot.mp3"):
		_sounds["web_shoot"] = load("res://audio/sfx_web_shoot.mp3")
	if ResourceLoader.exists("res://audio/sfx_web_hit.mp3"):
		_sounds["web_hit"] = load("res://audio/sfx_web_hit.mp3")
	if ResourceLoader.exists("res://audio/sfx_spider_dash.mp3"):
		_sounds["spider_dash"] = load("res://audio/sfx_spider_dash.mp3")
	if ResourceLoader.exists("res://audio/sfx_rock_throw.mp3"):
		_sounds["rock_throw"] = load("res://audio/sfx_rock_throw.mp3")
	if ResourceLoader.exists("res://audio/sfx_earthquake.mp3"):
		_sounds["earthquake"] = load("res://audio/sfx_earthquake.mp3")
	if ResourceLoader.exists("res://audio/sfx_boulder_throw.mp3"):
		_sounds["boulder_throw"] = load("res://audio/sfx_boulder_throw.mp3")
	if ResourceLoader.exists("res://audio/sfx_boulder_impact.mp3"):
		_sounds["boulder_impact"] = load("res://audio/sfx_boulder_impact.mp3")
	# ------------------------------------
	
	# --- SUARA MAKANAN BARU ---
	if ResourceLoader.exists("res://audio/sfx_eat_wet.mp3"):   # Contoh: Grape, Burger, Potion
		_sounds["eat_wet"] = load("res://audio/sfx_eat_wet.mp3")
	if ResourceLoader.exists("res://audio/sfx_eat_dry.mp3"):   # Contoh: Banana, Bacon, Bread
		_sounds["eat_dry"] = load("res://audio/sfx_eat_dry.mp3")
	
	# --- SUARA CHEST & LOOT BARU ---
	if ResourceLoader.exists("res://audio/sfx_chest_open.mp3"): # Suara engsel peti kayu/logam
		_sounds["chest_open"] = load("res://audio/sfx_chest_open.mp3")
	if ResourceLoader.exists("res://audio/sfx_loot_drop.mp3"):  # Suara "pop" atau "shimmer" saat item muncul
		_sounds["loot_drop"] = load("res://audio/sfx_loot_drop.mp3")
	
	# --- SUARA PEMAIN ---
	if ResourceLoader.exists("res://audio/sfx_player_hurt.mp3"):
		_sounds["player_hurt"] = load("res://audio/sfx_player_hurt.mp3")
	if ResourceLoader.exists("res://audio/sfx_player_die.mp3"):
		_sounds["player_die"] = load("res://audio/sfx_player_die.mp3")
	# --------------------
	
	# --- SUARA SENJATA MELEE & TOOL (9 SFX) ---
	if ResourceLoader.exists("res://audio/sfx_melee_slash_light.mp3"):
		_sounds["melee_slash_light"] = load("res://audio/sfx_melee_slash_light.mp3")
	if ResourceLoader.exists("res://audio/sfx_melee_slash_standard.mp3"):
		_sounds["melee_slash_standard"] = load("res://audio/sfx_melee_slash_standard.mp3")
	if ResourceLoader.exists("res://audio/sfx_magic_sword.mp3"):
		_sounds["magic_sword"] = load("res://audio/sfx_magic_sword.mp3")
	if ResourceLoader.exists("res://audio/sfx_chainsaw_idle.ogg"):
		_sounds["chainsaw_idle"] = load("res://audio/sfx_chainsaw_idle.ogg")
	if ResourceLoader.exists("res://audio/sfx_heavy_sword.mp3"):
		_sounds["heavy_sword"] = load("res://audio/sfx_heavy_sword.mp3")
	if ResourceLoader.exists("res://audio/sfx_hammer_swing.mp3"):
		_sounds["hammer_swing"] = load("res://audio/sfx_hammer_swing.mp3")
	if ResourceLoader.exists("res://audio/sfx_laser_cast.mp3"):
		_sounds["laser_cast"] = load("res://audio/sfx_laser_cast.mp3")
	if ResourceLoader.exists("res://audio/sfx_drill_idle.mp3"):
		_sounds["drill_idle"] = load("res://audio/sfx_drill_idle.mp3")
	if ResourceLoader.exists("res://audio/sfx_machine_exhausted.mp3"):
		_sounds["machine_exhausted"] = load("res://audio/sfx_machine_exhausted.mp3")
	# -------------------------------------------
	
	# --- SUARA PARRY GALAHAD ---
	if ResourceLoader.exists("res://audio/sfx_parry_activate.mp3"):
		_sounds["parry_activate"] = load("res://audio/sfx_parry_activate.mp3")
	if ResourceLoader.exists("res://audio/sfx_parry_slash.mp3"):
		_sounds["parry_slash"] = load("res://audio/sfx_parry_slash.mp3")
	# --------------------------------
	
	# --- SUARA SKILL SENJATA CHARGE ---
	if ResourceLoader.exists("res://audio/sfx_hammer_charge.mp3"):
		_sounds["hammer_charge"] = load("res://audio/sfx_hammer_charge.mp3")
	if ResourceLoader.exists("res://audio/sfx_heavy_slam.mp3"):
		_sounds["heavy_slam"] = load("res://audio/sfx_heavy_slam.mp3")
	if ResourceLoader.exists("res://audio/sfx_conductor_charge.mp3"):
		_sounds["conductor_charge"] = load("res://audio/sfx_conductor_charge.mp3")
	if ResourceLoader.exists("res://audio/sfx_conductor_electric.mp3"):
		_sounds["conductor_electric"] = load("res://audio/sfx_conductor_electric.mp3")
	if ResourceLoader.exists("res://audio/sfx_stormjade_charge.mp3"):
		_sounds["stormjade_charge"] = load("res://audio/sfx_stormjade_charge.mp3")
	if ResourceLoader.exists("res://audio/sfx_stormjade_dash.mp3"):
		_sounds["stormjade_dash"] = load("res://audio/sfx_stormjade_dash.mp3")
	# ----------------------------------
	
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)

func play(sound_name: String, custom_volume: float = 0.0) -> void:
	var stream: AudioStream = _sounds.get(sound_name)
	if stream == null:
		return
		
	# --- PITCH VARIATION OTOMATIS UNTUK MONSTER ---
	var pitch_variance = 0.0
	if sound_name.ends_with("_hurt") or sound_name.ends_with("_die"):
		pitch_variance = 0.15  # Variasi 15% untuk suara monster
	# -----------------------------------------------
	
	# --- KHUSUS CANNIBAL: KECILKAN VOLUME OTOMATIS ---
	var final_volume = custom_volume
	if sound_name == "cannibal_hurt" or sound_name == "cannibal_die":
		final_volume = -15.0  # Kecilkan volume Cannibal (angka lebih minus = lebih pelan)
	# --------------------------------------------------
		
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.volume_db = final_volume  # <-- TERAPKAN VOLUME DI SINI
			p.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
			p.play()
			return
			
	_players[0].stream = stream
	_players[0].volume_db = final_volume  # <-- TERAPKAN VOLUME DI SINI
	_players[0].pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	_players[0].play()

func attach(button: Button, hover: String = "hover", click: String = "click") -> void:
	# Cek apakah tombol sedang disabled. Kalau iya, jangan bunyikan hover.
	button.mouse_entered.connect(func():
		if not button.disabled:
			play(hover)
	)
	button.focus_entered.connect(func():
		if not button.disabled:
			play(hover)
	)
	button.pressed.connect(func(): play(click))
	
