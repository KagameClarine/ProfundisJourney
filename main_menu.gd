extends Control

var slot_buttons: Array = []
var delete_confirm_panel: Panel
var delete_blocker: ColorRect
var delete_target_slot: int = -1

func _ready():
	MusicManager.play_bgm("res://audio/bgm_main_menu.mp3") # Ganti dengan nama file BGM menu kamu
	
	var vp = get_viewport().get_visible_rect().size
	custom_minimum_size = vp
	
	# Background
	var bg = ColorRect.new()
	bg.size = vp
	bg.color = Color(0.05, 0.05, 0.1)
	add_child(bg)
	
	# 1. Layar Hitam Pengunci (Blocker)
	delete_blocker = ColorRect.new()
	delete_blocker.size = vp
	delete_blocker.color = Color(0, 0, 0, 0.7) # Hitam transparan 70%
	delete_blocker.visible = false
	delete_blocker.z_index = 99 # Di bawah panel, tapi di atas UI lain
	delete_blocker.mouse_filter = Control.MOUSE_FILTER_STOP # Kunci semua klik
	add_child(delete_blocker)

	# 2. Panel Konfirmasi Merah
	delete_confirm_panel = Panel.new()
	delete_confirm_panel.size = Vector2(600, 250)
	delete_confirm_panel.position = Vector2(vp.x/2 - 300, vp.y/2 - 125)
	delete_confirm_panel.visible = false
	delete_confirm_panel.z_index = 100
	delete_confirm_panel.mouse_filter = Control.MOUSE_FILTER_STOP # Kunci klik di area panel
	var d_style = StyleBoxFlat.new()
	d_style.bg_color = Color(0.15, 0.05, 0.05, 0.98)
	d_style.border_width_left = 3; d_style.border_width_top = 3; d_style.border_width_right = 3; d_style.border_width_bottom = 3
	d_style.border_color = Color.RED
	delete_confirm_panel.add_theme_stylebox_override("panel", d_style)
	add_child(delete_confirm_panel)
	
	var d_title = Label.new()
	d_title.text = "Delete Save"
	d_title.position = Vector2(0, 20) 
	d_title.size = Vector2(600, 40)
	d_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d_title.add_theme_font_size_override("font_size", 32)
	d_title.add_theme_color_override("font_color", Color.GOLD)
	delete_confirm_panel.add_child(d_title)
	
	var d_lbl = Label.new()
	d_lbl.text = "Are you sure want to delete this save?\nThis action cannot be undone."
	d_lbl.position = Vector2(20, 70) 
	d_lbl.size = Vector2(560, 60) # Tinggi dikurangi biar gak nabrak
	d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP # Kunci teks di atas
	d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	d_lbl.add_theme_font_size_override("font_size", 20)
	delete_confirm_panel.add_child(d_lbl)
	
	var b_yes = Button.new()
	b_yes.text = "YES"
	b_yes.position = Vector2(150, 160) # Diturunkan sedikit biar seimbang
	b_yes.size = Vector2(140, 50)
	b_yes.add_theme_font_size_override("font_size", 24)
	b_yes.pressed.connect(func():
		var path = Global.SAVE_DIR + "savegame_slot" + str(delete_target_slot) + ".save"
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
		delete_blocker.visible = false
		delete_confirm_panel.visible = false
		get_tree().reload_current_scene()
	)
	delete_confirm_panel.add_child(b_yes)
	
	var b_no = Button.new()
	b_no.text = "NO"
	b_no.position = Vector2(310, 160) # Diturunkan sedikit biar seimbang
	b_no.size = Vector2(140, 50)
	b_no.add_theme_font_size_override("font_size", 24)
	b_no.pressed.connect(func():
		delete_blocker.visible = false
		delete_confirm_panel.visible = false
	)
	delete_confirm_panel.add_child(b_no)
	
	# Title
	var title = Label.new()
	title.text = "FROM THE DEPTH"
	title.position = Vector2(0, vp.y * 0.2) # Posisi 20% dari atas layar
	title.size = Vector2(vp.x, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color.GOLD)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 8)
	add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Defeat the Swarm. Save the World."
	subtitle.position = Vector2(0, vp.y * 0.2 + 90) # 90px di bawah judul
	subtitle.size = Vector2(vp.x, 40)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	add_child(subtitle)
	
	# Menu Buttons (Posisi pas di tengah layar)
	var center_x = vp.x / 2 - 150
	var start_y = vp.y * 0.45 # Mulai dari 45% tinggi layar
	
	_create_button("PLAY", Vector2(center_x, start_y), _on_play_pressed)
	_create_button("SETTINGS (Coming Soon)", Vector2(center_x, start_y + 80), _on_settings_pressed, true)
	_create_button("CREDITS (Coming Soon)", Vector2(center_x, start_y + 160), _on_credits_pressed, true)
	_create_button("EXIT", Vector2(center_x, start_y + 240), _on_exit_pressed)

func _create_button(text: String, pos: Vector2, callback: Callable, disabled: bool = false) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(300, 60)
	btn.add_theme_font_size_override("font_size", 24)
	btn.disabled = disabled
	if not disabled:
		btn.pressed.connect(callback)
	add_child(btn)
	return btn

# ================= PLAY → SLOT SELECTION =================

func _on_play_pressed():
	_show_slot_selection()

func _show_slot_selection():
	var vp = get_viewport().get_visible_rect().size
	
	for child in get_children():
		if child is Button or child is HBoxContainer: child.queue_free()
	
	var header = Label.new()
	header.text = "Select a Save"
	header.position = Vector2(0, vp.y * 0.35) 
	header.size = Vector2(vp.x, 50)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 32)
	header.add_theme_color_override("font_color", Color.GOLD)
	add_child(header)
	
	var start_y = vp.y * 0.45
	for i in range(1, 4):
		var hbox = HBoxContainer.new()
		hbox.position = Vector2(vp.x / 2 - 250, start_y + (i - 1) * 80)
		hbox.size = Vector2(500, 60)
		hbox.add_theme_constant_override("separation", 10)
		add_child(hbox)
		
		var info = Global.peek_slot_info(i)
		var save_text = ""
		if info.is_empty():
			save_text = "Save " + str(i) + " — [ EMPTY ]"
		else:
			var p_name = info.get("player_name", "Player")
			var p_lv = info.get("player_level", 1)
			save_text = "Save " + str(i) + " — " + p_name + " (Lv " + str(p_lv) + ")"
		
		var btn = Button.new()
		btn.text = save_text
		btn.custom_minimum_size = Vector2(420, 60)
		btn.add_theme_font_size_override("font_size", 20)
		btn.pressed.connect(_on_slot_pressed.bind(i))
		hbox.add_child(btn)
		
		# Tombol Delete
		var del_btn = Button.new()
		del_btn.text = "🗑️"
		del_btn.custom_minimum_size = Vector2(60, 60)
		del_btn.add_theme_font_size_override("font_size", 24)
		del_btn.disabled = info.is_empty() # Kalau kosong, gak bisa dihapus
		del_btn.pressed.connect(_on_delete_save_pressed.bind(i))
		hbox.add_child(del_btn)
	
	var back_btn = Button.new()
	back_btn.text = "< Back"
	back_btn.position = Vector2(vp.x / 2 - 100, start_y + 280)
	back_btn.size = Vector2(200, 50)
	back_btn.pressed.connect(func(): get_tree().reload_current_scene())
	add_child(back_btn)

func _on_delete_save_pressed(slot_num: int):
	delete_target_slot = slot_num
	
	# --- KUNCI UTAMA: Pindahkan ke urutan paling akhir agar tidak ditembus ---
	move_child(delete_blocker, get_child_count() - 1)
	move_child(delete_confirm_panel, get_child_count() - 1)
	
	delete_blocker.visible = true
	delete_confirm_panel.visible = true
	
func _on_slot_pressed(slot_num: int):
	Global.select_slot(slot_num)
	get_tree().change_scene_to_file("res://home.tscn")

# ================= OTHER BUTTONS =================

func _on_settings_pressed():
	pass # Nanti

func _on_credits_pressed():
	pass # Nanti

func _on_exit_pressed():
	get_tree().quit()
