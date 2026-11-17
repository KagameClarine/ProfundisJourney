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
	
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)

func play(sound_name: String) -> void:
	var stream: AudioStream = _sounds.get(sound_name)
	if stream == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	_players[0].stream = stream
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
	
