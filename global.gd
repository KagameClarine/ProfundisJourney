extends Node

const SAVE_DIR = "user://"
var active_slot: int = 1
var max_slots: int = 3
var home_bgm_index: int = 1

func get_save_path() -> String:
	return SAVE_DIR + "savegame_slot" + str(active_slot) + ".save"

func slot_exists(slot_num: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "savegame_slot" + str(slot_num) + ".save")

func peek_slot_info(slot_num: int) -> Dictionary:
	var path = SAVE_DIR + "savegame_slot" + str(slot_num) + ".save"
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return {}
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return {}
	file.close()
	var data = json.data
	return {
		"player_name": str(data.get("player_name", "Player")),
		"player_level": int(data.get("player_level", 1)),
		"tutorial_step": int(data.get("tutorial_step", 0))
	}

func select_slot(slot_num: int) -> void:
	if slot_exists(active_slot) and active_slot != slot_num:
		save_game()
	active_slot = slot_num
	if slot_exists(slot_num):
		load_game()
	else:
		reset_save()
	save_game()

func switch_slot(new_slot: int) -> void:
	if new_slot == active_slot: return
	save_game()  # Save slot sekarang dulu
	active_slot = new_slot
	if slot_exists(new_slot):
		load_game()
	else:
		reset_save()  # Slot baru = fresh start
	get_tree().reload_current_scene()

var tutorial_completed = false
# Catatan: Kalau kamu punya default item (misal Copper 11), taruh di sini
var saved_inventory = {"Copper": 11}
var hotbar_uuids: Array = [null, null, null, null, null, null, null]
var equipped_armor_uuid: String = ""
var player_level = 1
var player_exp = 0
var exp_to_next_level = 50
var max_hp = 100
var current_hp = 100
var max_mana = 100
var current_mana = 100.0
var hotbar_items = ["Fist", "Stone Pickaxe", "Bow", null, null, null, null]
var equipped_armor = null
# --- SISTEM LEVEL ITEM (UPGRADE) ---
const MAX_ITEM_LEVEL: int = 5
var item_levels = {} # Format: {"Iron Sword": 2, "Wooden Sword": 1}
const UNUPGRADEABLE_ITEMS = ["Fist", "Bow", "Stone Pickaxe"]

const RESTRICTED_FROM_HOME: Array = [
	"Dirt", "Gravel", "Stone", "Crystal Stone", "Hardened Crystal Stone",
	"Flint", "Stick", "Arrow", "Torch", "Food Box", "Bomb", "Coal", "Minigun Ammo",
	"Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple",
	"Practice Arrow"
]

func strip_dungeon_materials() -> void:
	var _stripped = 0
	
	# 1. Hapus dari saved_inventory
	for item in RESTRICTED_FROM_HOME:
		if saved_inventory.has(item):
			_stripped += int(saved_inventory[item])
			saved_inventory.erase(item)
	
	# 2. Hapus dari hotbar_items + hotbar_uuids
	for i in range(7):
		var h_item = hotbar_items[i]
		if h_item != null and h_item in RESTRICTED_FROM_HOME:
			hotbar_items[i] = null
			hotbar_uuids[i] = null
			_stripped += 1
	
	# 3. Hapus dari equipped armor (jika material nyasar di sana, jarang tapi possible)
	if equipped_armor != null and equipped_armor in RESTRICTED_FROM_HOME:
		equipped_armor = null
		equipped_armor_uuid = ""
	
	if _stripped > 0:
		print("[STRIP] Removed ", _stripped, " restricted items from inventory + hotbar")
		save_game()
func wipe_dungeon_fail() -> void:
	# Simpan level dari equipment aktif (slot 0-2 + armor)
	var _kept_levels = {}
	for i in range(3):
		var uid = hotbar_uuids[i]
		if uid != null and uid != "":
			_kept_levels[uid] = item_levels.get(uid, 1)
	var armor_uid = equipped_armor_uuid
	if armor_uid != "":
		_kept_levels[armor_uid] = item_levels.get(armor_uid, 1)
	
	# Clear SEMUA backpack + item_levels
	saved_inventory.clear()
	item_levels.clear()
	
	# Restore level equipment aktif
	for uid in _kept_levels.keys():
		item_levels[uid] = _kept_levels[uid]
	
	# Clear hotbar slot 3-6
	for i in range(3, 7):
		hotbar_items[i] = null
		hotbar_uuids[i] = null
	
	save_game()
	print("[WIPE] Dungeon failed (force quit). Backpack + hotbar 3-6 wiped. Equipment safe.")

var gold_coins = 0
var dungeon_start_gold: int = 0
var copper_sold = 0
var ore_storage = {}
var material_storage = {}
var weapon_storage = {}

# 0 = Tutorial 1 belum selesai
# 1 = Selesai T1 (di Home), harus jual 5 copper
# 2 = Sudah jual, harus simpan ore
# 3 = Sudah simpan, siap masuk Guild lagi
var current_difficulty = 1
var current_anomaly = 0
var tutorial_step = 0
var tutorial2_step = 0
var tutorial3_step = 0
var scrap_collected = 0
var tut_home_checked_gold = false
var wooden_sword_obtained = false
var unlocked_blueprints: Array = []
var has_shown_scrap_dialog = false
var has_shown_domain_dialog = false
var has_shown_death_warning: bool = false
var player_name: String = "Player"
var weapon_investment_gold: Dictionary = {}
var weapon_investment_scrap: Dictionary = {}
var highest_difficulty_cleared: int = 0
var post_t3_cutscene_step: int = 0
var loadout_v6_done: bool = false
var uuid_migration_v1_done: bool = false



func _ready():
	tutorial2_step = 0
	tutorial3_step = 0
	load_game()
	if has_meta("post_t3_loadout_v6"):
		loadout_v6_done = true
	if has_meta("uuid_migration_v1_done"):
		uuid_migration_v1_done = true
	migrate_weapons_to_uuid()

# --- SISTEM SAVE & LOAD (JSON) ---
func save_game():
	var save_file = FileAccess.open(get_save_path(), FileAccess.WRITE)
	if save_file:
		var data = {
			"tutorial_completed": tutorial_completed,
			"saved_inventory": saved_inventory,
			"player_level": player_level,
			"player_exp": player_exp,
			"exp_to_next_level": exp_to_next_level,
			"max_hp": max_hp,
			"current_hp": current_hp,
			"hotbar_items": hotbar_items,
			"hotbar_uuids": hotbar_uuids,
			"equipped_armor": equipped_armor,
			"equipped_armor_uuid": equipped_armor_uuid,
			"gold_coins": gold_coins,
			"copper_sold": copper_sold,
			"ore_storage": ore_storage,
			"material_storage": material_storage,
			"weapon_storage": weapon_storage,
			"tutorial_step": tutorial_step,
			"item_levels": item_levels,
			"has_shown_scrap_dialog": has_shown_scrap_dialog,
			"has_shown_domain_dialog": has_shown_domain_dialog,
			"has_shown_death_warning": has_shown_death_warning,
			"player_name": player_name,
			"weapon_investment_gold": weapon_investment_gold,
			"weapon_investment_scrap": weapon_investment_scrap,
			"highest_difficulty_cleared": highest_difficulty_cleared,
			"post_t3_cutscene_step": post_t3_cutscene_step,
			"unlocked_blueprints": unlocked_blueprints,
			"scrap_collected": scrap_collected,
			"loadout_v6_done": loadout_v6_done,
			"home_bgm_index": home_bgm_index,
			"uuid_migration_v1_done": uuid_migration_v1_done
		}
		save_file.store_line(JSON.stringify(data))
		save_file.close()
		print("GAME SAVED!")

func load_game():
	if FileAccess.file_exists(get_save_path()):
		var save_file = FileAccess.open(get_save_path(), FileAccess.READ)
		if save_file:
			var json = JSON.new()
			var parse_error = json.parse(save_file.get_as_text())
			if parse_error == OK:
				var data = json.data
				tutorial_completed = data.get("tutorial_completed", false)
				saved_inventory = data.get("saved_inventory", {})
				
				player_level = int(data.get("player_level", 1))
				player_exp = int(data.get("player_exp", 0))
				exp_to_next_level = int(data.get("exp_to_next_level", 50))
				max_hp = int(data.get("max_hp", 100))
				current_hp = int(data.get("current_hp", 100))
				current_hp = max_hp
				current_mana = max_mana
				
				if saved_inventory.has("Practice Arrow"):
					saved_inventory.erase("Practice Arrow")
				
				hotbar_items = data.get("hotbar_items", ["Fist", "Stone Pickaxe", "Bow", null, null, null, null])
				hotbar_uuids = data.get("hotbar_uuids", [null, null, null, null, null, null, null])
				equipped_armor = data.get("equipped_armor", null)
				equipped_armor_uuid = str(data.get("equipped_armor_uuid", ""))
				
				gold_coins = int(data.get("gold_coins", 0))
				copper_sold = int(data.get("copper_sold", 0))
				ore_storage = data.get("ore_storage", {})
				material_storage = data.get("material_storage", {})
				weapon_storage = data.get("weapon_storage", {})
				
				for k in saved_inventory.keys():
					saved_inventory[k] = int(saved_inventory[k])
				for k in ore_storage.keys():
					ore_storage[k] = int(ore_storage[k])
				for k in weapon_storage.keys():
					weapon_storage[k] = int(weapon_storage[k])
					
				tutorial_step = int(data.get("tutorial_step", 0))
				has_shown_scrap_dialog = data.get("has_shown_scrap_dialog", false)
				has_shown_domain_dialog = data.get("has_shown_domain_dialog", false)
				has_shown_death_warning = data.get("has_shown_death_warning", false)
				player_name = str(data.get("player_name", "Player"))
				home_bgm_index = int(data.get("home_bgm_index", 1))
				weapon_investment_gold = data.get("weapon_investment_gold", {})
				weapon_investment_scrap = data.get("weapon_investment_scrap", {})
				for k in weapon_investment_gold.keys(): weapon_investment_gold[k] = int(weapon_investment_gold[k])
				for k in weapon_investment_scrap.keys(): weapon_investment_scrap[k] = int(weapon_investment_scrap[k])
				
				highest_difficulty_cleared = int(data.get("highest_difficulty_cleared", 0))
				post_t3_cutscene_step = int(data.get("post_t3_cutscene_step", 0))
				
				var _bp_arr = data.get("unlocked_blueprints", [])
				unlocked_blueprints = []
				for _bp in _bp_arr:
					unlocked_blueprints.append(str(_bp))
				scrap_collected = int(data.get("scrap_collected", 0))
				loadout_v6_done = data.get("loadout_v6_done", false)
				uuid_migration_v1_done = data.get("uuid_migration_v1_done", false)
				
				item_levels = data.get("item_levels", {})
				for k in item_levels.keys():
					item_levels[k] = int(item_levels[k])
				
				if tutorial_completed and tutorial_step == 0:
					tutorial_step = 1
					
				print("GAME LOADED! Slot: ", active_slot)
			save_file.close()

func reset_save():
	if FileAccess.file_exists(get_save_path()):
		DirAccess.remove_absolute(get_save_path())
		
	# Reset semua variabel ke awal
	tutorial_completed = false
	saved_inventory = {"Copper": 11} # <--- Sesuaikan dengan default item barumu
	player_level = 1
	player_exp = 0
	exp_to_next_level = 10
	max_hp = 100
	current_hp = 100
	hotbar_items = ["Fist", "Stone Pickaxe", "Bow", null, null, null, null]
	hotbar_uuids = [null, null, null, null, null, null, null]
	equipped_armor = null
	equipped_armor_uuid = ""
	
	# Reset variabel baru
	gold_coins = 0
	copper_sold = 0
	ore_storage = {}
	material_storage = {}
	weapon_storage = {}
	tutorial_step = 0
	tutorial2_step = 0
	tutorial3_step = 0
	item_levels = {}
	has_shown_scrap_dialog = false
	has_shown_domain_dialog = false
	has_shown_death_warning = false
	player_name = "Player"
	weapon_investment_gold.clear()
	weapon_investment_scrap.clear()
	post_t3_cutscene_step = 0
	unlocked_blueprints = []
	loadout_v6_done = false
	uuid_migration_v1_done = false
	highest_difficulty_cleared = 0
	
	print("SAVE DI-RESET TOTAL!")

func add_player_exp(amount: int):
	if amount <= 0: return
	
	player_exp += amount
	print("Mendapat EXP Permanen: ", amount)
	
	# Cek Level Up (bisa naik lebih dari 1 level kalau EXP banyak)
	while player_exp >= exp_to_next_level:
		player_exp -= exp_to_next_level
		player_level += 1
		exp_to_next_level *= 2 # Rumus: 50 -> 100 -> 200 -> 400
		print("PLAYER LEVEL UP! Sekarang Lv ", player_level)
		
	save_game() # Auto save pas dapet EXP

func get_map_exp_reward(tutorial_step: int) -> int:
	if tutorial_step == 0: return 0 # Tutorial 1 (0 EXP)
	if tutorial_step == 3: return 50 # Tutorial 2 (50 EXP)
	
	# Base EXP untuk Anomaly 0 (Difficulty 1 = 120, Diff 2 = 150, dst)
	var base_exp = 120 + ((current_difficulty - 1) * 30)
	
	# Multiplier berdasarkan tingkat Anomaly
	var anomaly_multiplier = 1
	
	match current_anomaly:
		0: anomaly_multiplier = 1
		1: anomaly_multiplier = 2
		2: anomaly_multiplier = 4
		3: anomaly_multiplier = 8
		4: anomaly_multiplier = 12
		5: anomaly_multiplier = 20
		_: anomaly_multiplier = 20 # Fallback kalau lebih dari 5
		
	# Hitung total EXP
	return base_exp * anomaly_multiplier

# --- FUNGSI SISTEM LEVEL ITEM ---
func get_item_level(item_name: String, uuid: String = "") -> int:
	if item_name in UNUPGRADEABLE_ITEMS:
		return 1
	# Kalau ada UUID, pakai UUID sebagai lookup key
	var lookup_key = uuid if uuid != "" else item_name
	return int(item_levels.get(lookup_key, 1))

func set_item_level(item_name: String, level: int, uuid: String = "") -> void:
	if item_name in UNUPGRADEABLE_ITEMS: return
	var lookup_key = uuid if uuid != "" else item_name
	item_levels[lookup_key] = clampi(level, 1, MAX_ITEM_LEVEL)

func is_upgradeable(item_name: String) -> bool:
	return not (item_name in UNUPGRADEABLE_ITEMS)

# --- UUID SYSTEM (Per-Instance Weapon Identity) ---
func generate_uuid() -> String:
	return str(Time.get_ticks_usec()) + "-" + str(randi() % 99999)

func is_unique_key(key: String) -> bool:
	return "|" in key

func get_base_name(key: String) -> String:
	if "|" in key:
		return key.split("|")[0]
	return key

func create_weapon_key(base_name: String) -> String:
	return base_name + "|" + generate_uuid()

# --- MIGRATION: Konversi Save Lama ke UUID ---
func migrate_weapons_to_uuid():
	if uuid_migration_v1_done:
		return
	uuid_migration_v1_done = true
	
	var weapon_names = [
		"Wooden Sword", "Iron Sword", "Iron Bow", "Iron Armor", "Iron Pickaxe",
		"Menacing Dagger", "Maniacal Chainsaw", "Hunter Bow", "Heretic Staff",
		"Heavy Amethyst Armor", "Marble Slingshot", "Explosive Crossbow",
		"Sharding Sword", "Swarmid Drill", "Galahad Chimelin",
		"Mourning Bow", "Crystal Minigun", "Crystal Armor",
		"Silver Gray Sword", "Golden Conductor", "Stormjade Cutter",
		"Revenger Crystallinum", "Crystal Hammer",
		"Metal Skin Armor", "Shining Justice", "Tenacity Battle Armor",
		"Deep Cave Armor", "Bonecrusher", "Magic Pickaxe", "Pneumatic Drill",
		"Ricochet Bow", "Bounty Bow", "Radiance Scepter", "Sticky Crossbow",
		"Headhitter Heavy Bow"
	]
	
	var to_migrate = []
	for weapon in weapon_names:
		if saved_inventory.has(weapon) and saved_inventory[weapon] > 0:
			var count = saved_inventory[weapon]
			var old_level = int(item_levels.get(weapon, 1))
			to_migrate.append({"name": weapon, "count": count, "level": old_level})
			saved_inventory.erase(weapon)
			item_levels.erase(weapon)
	
	for mig in to_migrate:
		for i in range(int(mig["count"])):
			var new_key = create_weapon_key(mig["name"])
			saved_inventory[new_key] = 1
			item_levels[new_key] = mig["level"]
	
	if to_migrate.size() > 0:
		print("[MIGRATION] Migrated ", to_migrate.size(), " weapon types to UUID")
	save_game()

func get_effective_stats(item_name: String, base_stats: Dictionary, uuid: String = "") -> Dictionary:
	var lv = get_item_level(item_name, uuid)
	var stats = base_stats.duplicate()
	if lv <= 1: return stats
	
	var lv_bonus = lv - 1
	
	if stats.has("damage"):
		stats["damage"] = int(stats["damage"] * (1.0 + 0.1 * lv_bonus))
	if stats.has("charge_damage"):
		stats["charge_damage"] = int(stats["charge_damage"] * (1.0 + 0.1 * lv_bonus))
	if stats.has("efficiency"):
		stats["efficiency"] = stats["efficiency"] + lv_bonus
	if stats.has("damage_reduction"):
		stats["damage_reduction"] = stats["damage_reduction"] * (1.0 + 0.1 * lv_bonus)
	
	return stats
