extends AudioStreamPlayer

var current_bgm_path: String = ""
var tween: Tween

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = "Music"

func play_bgm(path: String, start_pos: float = 0.0):
	if path == current_bgm_path and playing:
		return 
		
	if not ResourceLoader.exists(path):
		print("[MUSIC] File tidak ditemukan: ", path)
		return
		
	if playing:
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(self, "volume_db", -40.0, 0.8)
		tween.tween_callback(_start_new_bgm.bind(path, start_pos))
	else:
		_start_new_bgm(path, start_pos)

func _start_new_bgm(path: String, start_pos: float = 0.0):
	current_bgm_path = path
	stream = load(path)
	volume_db = -40.0
	
	var safe_start_pos = 0.0
	if stream.get_length() > 0:
		safe_start_pos = clamp(start_pos, 0.0, stream.get_length() - 1.0)
		
	play(safe_start_pos)
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "volume_db", 0.0, 0.8)

func get_precise_time() -> float:
	if not playing: return 0.0
	return get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_time_to_next_mix()

func stop_bgm():
	if playing:
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(self, "volume_db", -40.0, 1.0)
		tween.tween_callback(_on_stop_bgm_finished)

func _on_stop_bgm_finished():
	stop()
	current_bgm_path = ""
