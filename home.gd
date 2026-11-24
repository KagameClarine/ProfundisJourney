extends Node2D

@onready var player = $Player
@onready var guild_area = $GuildArea

var can_enter_guild = false
var can_talk_miner = false
var can_open_ore_storage = false
var can_open_weapon_storage = false

var ui_prompt: Label
var ui_objective_label: Label
var ui_gold_label: Label
var ui_exp_label: Label
var heart_labels = []
var hotbar_ui_labels = []
var ui_inventory_panel: Panel
var slot_nodes = []
var is_inventory_open = false
var inv_hotbar_slots = []

var is_char_open = false
var char_panel: Panel
var char_slot_labels = []
var tooltip_char: Label
var rename_panel: Panel
var rename_input: LineEdit

var char_hover_panel: Panel
var char_slots_panels = []
var char_hover_name: Label
var char_hover_stats: Label
var char_armor_slot: Panel

var old_miner_node: Node2D
var storage_ore_node: Node2D
var storage_weapon_node: Node2D

# --- STATION VARIABLES ---
var forge_node: Node2D
var smelt_node: Node2D
var smelt_selected_ore = ""
var smelt_amount = 0
var forge_tab = "forge" # "forge" atau "craft"
var forge_selected_item = ""
var is_forge_open = false
var is_smelt_open = false
var is_guild_open = false
var guild_panel: Panel
var cutscene_active: bool = false
var cutscene_step: int = 0
var cutscene_panel: Panel
var cutscene_speaker: Label
var cutscene_text: Label
var cutscene_hint: Label
var cutscene_name_input: LineEdit
var cutscene_submit_btn: Button
var guild_master_node: Node2D
var smithing_station_node: Node2D
var gail_node: Node2D
var is_smithing_open: bool = false
var smithing_panel: Panel
var salvage_confirm: Panel
var smithing_inv_slots: Array = []
var smithing_sto_slots: Array = []
var smithing_equip_slots: Array = []
var smithing_selected_uuid: String = ""
var smithing_active_tab: String = "weapon"
var smithing_center_label: Label
var smithing_preview_label: Label
var smithing_upgrade_btn: Button
var smithing_salvage_btn: Button
var pause_panel_home: Panel
var pause_blocker_home: ColorRect
var is_pause_home_open: bool = false
var music_player_node: Node2D
var can_use_music_player = false
var music_player_panel: Panel
var is_music_player_open: bool = false

var is_prep_open = false
var prep_panel: Panel
var prep_title: Label
var btn_ready_main: Button
var confirm_panel: Panel
var forge_panel: Panel
var smelt_panel: Panel
var forge_label: Label
var smelt_label: Label
var forge_preview_rarity: Label
var dummy_node: Node2D
var dummy_atk_timer = 0.0
var home_attack_cooldown = 0.0
var training_chest_node: Node2D

# --- VARIABEL DPS METER ---
var dummy_dps_label: Label
var combat_dmg_total = 0.0
var combat_hits = 0
var combat_timer = 0.0
var idle_timer = 0.0
var selected_home_slot = 1 # 0=Tool, 1=Melee, 2=Range
var is_charging_home_bow = false
var swarmid_use_timer: float = 0.0
var swarmid_exhausted_timer: float = 0.0
var bounty_bow_stacks: int = 0
var bounty_stack_timer: float = 0.0
var sword_combo = 0
var galahad_stacks = 0
var galahad_parry_active = false
var galahad_parry_cd = 0.0
var minigun_shot_count = 0
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

# --- ARMOR BLUEPRINT PASSIVES ---
var deep_cave_petrify_timer = 0.0
var deep_cave_regen_timer = 0.0
var deep_cave_cooldown = 0.0
var deep_cave_active = false

# --- VARIABEL DoT DUMMY ---
var dummy_poison_dmg = 0
var dummy_poison_tick = 0.0
var dummy_poison_rem = 0

var dummy_bleed_dmg = 0
var dummy_bleed_tick = 0.0
var dummy_bleed_rem = 0

# --- SISTEM JUAL BELI ---
var is_selling_ui_open = false
var sell_panel: Panel
var sell_slot_nodes = []
var sell_data = []
var sell_dialog_label: Label
var sell_gold_label: Label
var dialog_step = 0
var dialog_texts = [
	"Old Miner: \"Hello there, rookie!\"",
	"Old Miner: \"Drag and drop your item that you want to sell.\"",
	"Old Miner: \"Or if u want to keep some of your items, use your right click on the item.\"",
	"Old Miner: \"Click SELL when you're ready!\""
]
var thanks_texts = [
	"Old Miner: \"Thank you for your hard work, rookie!\"",
	"Old Miner: \"Much appreciated! Here's your gold.\"",
	"Old Miner: \"You're a lifesaver! Come back anytime.\""
]

# --- SISTEM STORAGE ---
var is_storage_ui_open = false
var storage_panel: Panel
var storage_grid: GridContainer
var storage_slot_nodes = []
var btn_tab_ore: Button
var btn_tab_material: Button
var btn_tab_weapon: Button
var active_storage_type = "" # "ore" atau "weapon"

const ORE_LIST = [
	"Copper", "Iron", "Coal", "Gravel", "Silver", "Gold", "Mithril", "Stone",
	# --- T3 Ores (baru didapat setelah tutorial 3 / dungeon T3) ---
	"Quartz", "Topaz", "Emerald", "Amethyst", "Diamond", "Void Crystal", "Uberilium",
	# --- T3 Blocks (bisa ditaruh seperti Stone/Gravel) ---
	"Crystal Stone", "Hardened Crystal Stone"
]

const MATERIAL_LIST = [
	"Iron Bar", "Copper Bar", "Silver Bar", "Gold Bar", "Mithril Bar", "Broken Tools", "Scrap",
	"Essence Crystal",
	"Blueprint Silver Gray Sword",  # ← tambah 5 blueprint
	"Blueprint Golden Conductor",
	"Blueprint Stormjade Cutter",
	"Blueprint Revenger Crystallinum",
	"Blueprint Crystal Hammer",
	# --- T3 Smelting Results ---
	"Quartz Bar", "Topaz Bar", "Emerald Crystal", "Stable Crystal", "Uberilium Bar",
	# --- Weapon Parts ---
	"Dagger Part 💀", "Dagger Part ⛏️", "Dagger Part ⚔️",
	"Chainsaw Part 💀", "Chainsaw Part ⛏️", "Chainsaw Part ⚔️",
	"Hunter Bow Part 💀", "Hunter Bow Part ⛏️", "Hunter Bow Part ⚔️",
	"Heretic Staff Part 💀", "Heretic Staff Part ⛏️", "Heretic Staff Part ⚔️",
	"Mourning Bow Part 💀", "Mourning Bow Part ⛏️", "Mourning Bow Part ⚔️",
	"Crystal Minigun Part 💀", "Crystal Minigun Part ⛏️", "Crystal Minigun Part ⚔️",
	"Crystal Armor Part 💀", "Crystal Armor Part ⛏️", "Crystal Armor Part ⚔️"
]

# Senjata/tool yang TIDAK menampilkan jumlah di hotbar
const WEAPON_NAMES = [
	"Fist", "Stone Pickaxe", "Bow", "Wooden Sword", 
	"Menacing Dagger", "Maniacal Chainsaw", "Heretic Staff", 
	"Iron Sword", "Iron Pickaxe", "Iron Armor", "Iron Bow"
]

var item_data = {
	# Senjata dasar
	"Fist": {"color": Color(0.9, 0.7, 0.5), "damage": 4, "range": 64.0, "attack_speed": 0.25, "knockback": 4.0, "weapon_type": "Physical Damage", "trait": "Focused", "passive": "Basic attack"},
	"Stone Pickaxe": {"color": Color(0.4, 0.4, 0.4), "damage": 10, "range": 96.0, "attack_speed": 0.7, "efficiency": 1.0, "knockback": 10.0, "weapon_type": "Physical Damage", "trait": "", "passive": ""},
	"Bow": {"color": Color(0.6, 0.4, 0.2), "damage": 7, "range": 300.0, "attack_speed": 0.5, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "Focused", "passive": ""},
	"Wooden Sword": {"color": Color(0.6, 0.4, 0.1), "damage": 15, "range": 64.0, "attack_speed": 0.4, "knockback": 8.0, "weapon_type": "Physical Damage", "trait": "Focused", "passive": ""},
	
	"Menacing Dagger": {"color": Color(0.5, 0.5, 0.8), "rarity": "Epic", "damage": 16, "range": 64.0, "attack_speed": 0.3, "knockback": 2.0, "weapon_type": "Elemental Damage", "trait": "DoT (Poison)", "passive": "30% chance to inflict poison", "craft_cost": 1000},
	"Maniacal Chainsaw": {"color": Color(0.8, 0.2, 0.2), "rarity": "Epic", "damage": 11, "range": 48.0, "attack_speed": 0.1, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "DoT (Bleed)", "passive": "Attack rapidly with insane speed, beware for exhausted machine for 4 seconds after used", "craft_cost": 1000},
	"Hunter Bow": {"color": Color(0.2, 0.6, 0.2), "rarity": "Rare", "damage": 15, "range": 350.0, "attack_speed": 0.6, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "Focused", "passive": "Basic hunting bow", "craft_cost": 1000},
	"Heretic Staff": {"color": Color(0.6, 0.1, 0.6), "rarity": "Epic", "damage": 32, "range": 384.0, "attack_speed": 1.2, "knockback": 0.0, "weapon_type": "Magic Damage", "trait": "Crowd Control", "passive": "70% chance to terrify enemies on hit", "mana_cost": 20, "craft_cost": 1000},
	"Iron Sword": {"color": Color(0.8, 0.8, 0.8), "rarity": "Common", "damage": 20, "range": 64.0, "attack_speed": 0.5, "knockback": 6.0, "weapon_type": "Physical Damage", "trait": "Focused", "passive": "Third strike deals +20% damage", "craft_cost": 70, "craft_recipe": {"Copper Bar": 2, "Iron Bar": 5}},
	"Iron Pickaxe": {"color": Color(0.8, 0.8, 0.8), "rarity": "Common", "damage": 20, "range": 96.0, "attack_speed": 0.8, "efficiency": 2.0, "knockback": 12.0, "weapon_type": "Physical Damage", "trait": "", "passive": "Mines iron faster", "craft_cost": 70, "craft_recipe": {"Iron Bar": 3, "Copper Bar": 1}},
	"Iron Armor": {"color": Color(0.8, 0.8, 0.8), "rarity": "Common", "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "trait": "", "passive": "Reduce melee damage by 15%", "damage_reduction": 6, "craft_cost": 100, "craft_recipe": {"Iron Bar": 10}},
	"Iron Bow": {"color": Color(0.8, 0.8, 0.8), "rarity": "Common", "damage": 12, "charge_damage": 28, "range": 300.0, "attack_speed": 0.5, "charge_speed": 1.0, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "Focused", "passive": "10% chance to pierce on charge shot", "craft_cost": 60, "craft_recipe": {"Iron Bar": 6}},

	# Block & Ore
	"Dirt": {"color": Color(0.55, 0.27, 0.07)},
	"Coal": {"color": Color(0.15, 0.15, 0.15)},
	"Iron": {"color": Color(0.7, 0.3, 0.2)},
	"Copper": {"color": Color(0.8, 0.5, 0.1)},
	"Gravel": {"color": Color(0.6, 0.6, 0.6)},
	"Stone": {"color": Color(0.5, 0.5, 0.5)},
	"Silver": {"color": Color(0.8, 0.8, 0.9)},
	"Gold": {"color": Color(1.0, 0.8, 0.1)},
	"Mithril": {"color": Color(0.2, 0.9, 1.0)},
	"Iron Bar": {"color": Color(0.6, 0.6, 0.65)},

	# Material dasar
	"Flint": {"color": Color(0.3, 0.3, 0.3)},
	"Stick": {"color": Color(0.4, 0.25, 0.1)},
	"Torch": {"color": Color(1.0, 0.8, 0.2)},
	"Arrow": {"color": Color(0.7, 0.7, 0.7)},
	"Practice Arrow": {"color": Color(0.2, 0.8, 1.0)}, # Warna Biru Cyan biar beda
	"Broken Tools": {"color": Color(0.4, 0.2, 0.1), "craft_cost": 100, "craft_recipe": {"Broken Tools": 1}},
	"Food Box": {"color": Color(0.9, 0.5, 0.5)},
	"Bomb": {"color": Color(0.1, 0.1, 0.1)},

	# Weapon Parts — 💀 dari monster
	"Dagger Part 💀": {"color": Color(0.5, 0.5, 0.8)},
	"Chainsaw Part 💀": {"color": Color(0.8, 0.2, 0.2)},
	"Hunter Bow Part 💀": {"color": Color(0.2, 0.6, 0.2)},
	"Heretic Staff Part 💀": {"color": Color(0.6, 0.1, 0.6)},

	# Weapon Parts — ⛏️ dari mining
	"Dagger Part ⛏️": {"color": Color(0.5, 0.5, 0.8)},
	"Chainsaw Part ⛏️": {"color": Color(0.8, 0.2, 0.2)},
	"Hunter Bow Part ⛏️": {"color": Color(0.2, 0.6, 0.2)},
	"Heretic Staff Part ⛏️": {"color": Color(0.6, 0.1, 0.6)},

	# Weapon Parts — ⚔️ dari dungeon (siap-siap nanti)
	"Dagger Part ⚔️": {"color": Color(0.5, 0.5, 0.8)},
	"Chainsaw Part ⚔️": {"color": Color(0.8, 0.2, 0.2)},
	"Hunter Bow Part ⚔️": {"color": Color(0.2, 0.6, 0.2)},
	"Heretic Staff Part ⚔️": {"color": Color(0.6, 0.1, 0.6)},
	
	# --- T3 BOSS DROP WEAPONS (dari peti boss di domain) ---
	"Heavy Amethyst Armor": {"color": Color(0.6, 0.2, 0.9), "rarity": "Rare", "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "damage_reduction": 13, "trait": "", "passive": "When taking >10 dmg, next hit takes 5 less dmg."},
	"Marble Slingshot": {"color": Color(0.8, 0.8, 0.8), "rarity": "Epic", "damage": 15, "charge_damage": 32, "range": 300.0, "attack_speed": 0.5, "charge_speed": 0.8, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "Burst", "passive": "Charge attack splits into 8 projectiles (10% dmg each)."},
	"Blueprint Ricochet Bow": {"color": Color(0.8, 0.9, 0.2), "tile": -1, "rarity": "Uncommon", "blueprint_for": "Ricochet Bow", "domain_source": "Domain of Tricks", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Ricochet Bow": {"color": Color(0.8, 0.9, 0.2), "tile": -1, "damage": 15, "charge_damage": 28, "range": 384.0, "attack_speed": 0.6, "charge_speed": 0.4, "knockback": 0.0, "weapon_type": "Physical Damage", "rarity": "Uncommon", "trait": "Focused", "passive": "Charge attack has a 20% chance to ricochet to the nearest enemy. Bounced shots can also ricochet.", "craft_cost": 260, "craft_recipe": {"Iron Bar": 4, "Mithril Bar": 2, "Silver Bar": 4}},
	"Blueprint Radiance Scepter": {"color": Color(1.0, 0.9, 0.5), "tile": -1, "rarity": "Uncommon", "blueprint_for": "Radiance Scepter", "domain_source": "Domain of Believer", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Radiance Scepter": {"color": Color(1.0, 0.9, 0.5), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 1.5, "knockback": 0.0, "weapon_type": "Magic Damage", "rarity": "Uncommon", "trait": "Focused", "passive": "Self-heal utility. Cannot deal damage. Uses 25 Mana to heal 12 HP (scales with level).", "mana_cost": 25, "heal_amount": 12, "craft_cost": 300, "craft_recipe": {"Topaz Bar": 4, "Emerald Crystal": 2, "Amethyst": 2}},
	"Blueprint Sticky Crossbow": {"color": Color(0.5, 0.7, 0.3), "tile": -1, "rarity": "Rare", "blueprint_for": "Sticky Crossbow", "domain_source": "Domain of Cheap", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Sticky Crossbow": {"color": Color(0.5, 0.7, 0.3), "tile": -1, "damage": 13, "charge_damage": 27, "range": 320.0, "attack_speed": 0.6, "charge_speed": 1.0, "knockback": 0.0, "weapon_type": "Elemental Damage", "rarity": "Rare", "trait": "CC", "passive": "Grappling hook: Pulls player to target. Immobilizes enemies for 3s.", "craft_cost": 530, "craft_recipe": {"Diamond": 3, "Uberilium Bar": 2, "Stable Crystal": 3, "Silver Bar": 5}},
	"Blueprint Headhitter Heavy Bow": {"color": Color(0.8, 0.2, 0.2), "tile": -1, "rarity": "Rare", "blueprint_for": "Headhitter Heavy Bow", "domain_source": "Domain of Power", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Headhitter Heavy Bow": {"color": Color(0.8, 0.2, 0.2), "tile": -1, "damage": 26, "charge_damage": 42, "range": 320.0, "attack_speed": 0.8, "charge_speed": 1.2, "knockback": 64.0, "weapon_type": "Physical Damage", "rarity": "Rare", "trait": "Focused", "passive": "Full charge fires a wider projectile with massive knockback. Deals +50% damage to enemies below 30% HP.", "craft_cost": 650, "craft_recipe": {"Diamond": 4, "Amethyst": 4, "Emerald Crystal": 4, "Stable Crystal": 4}},
	"Blueprint Bounty Bow": {"color": Color(0.5, 0.8, 1.0), "tile": -1, "rarity": "Rare", "blueprint_for": "Bounty Bow", "domain_source": "Domain of Precision", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Bounty Bow": {"color": Color(0.5, 0.8, 1.0), "tile": -1, "damage": 20, "charge_damage": 35, "range": 480.0, "attack_speed": 0.7, "charge_speed": 0.7, "knockback": 10.0, "weapon_type": "Magic Damage", "rarity": "Rare", "trait": "Focused", "passive": "Hits apply Bounty. Killing a bountied enemy grants +20% damage (max 5 stacks). Stacks reset if no bountied kill within 7s.", "craft_cost": 590, "craft_recipe": {"Mithril Bar": 5, "Silver Bar": 5, "Topaz Bar": 3, "Quartz Bar": 3}},
	"Explosive Crossbow": {"color": Color(0.6, 0.3, 0.1), "rarity": "Epic", "damage": 0, "charge_damage": 78, "range": 250.0, "attack_speed": 0.5, "charge_speed": 3.0, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "AoE", "passive": "Charge attack explodes in a 4-block radius."},
	"Sharding Sword": {"color": Color(0.8, 0.4, 0.9), "rarity": "Epic", "damage": 21, "charge_damage": 49, "range": 56.0, "attack_speed": 0.6, "charge_speed": 2.0, "knockback": 0.0, "weapon_type": "Magic Damage", "trait": "Burst", "passive": "Hits reduce enemy magic resistance by 20%."},
	"Swarmid Drill": {"color": Color(0.1, 0.9, 0.3), "rarity": "Rare", "damage": 5, "range": 64.0, "attack_speed": 0.25, "efficiency": 5.0, "knockback": 0.0, "weapon_type": "Elemental Damage", "trait": "", "passive": "Mining breaks a 3x3 area."},
	"Galahad Chimelin": {"color": Color(1.0, 0.8, 0.2), "rarity": "Legendary", "damage": 65, "range": 80.0, "attack_speed": 1.0, "knockback": 48.0, "weapon_type": "Physical Damage", "trait": "Burst", "passive": "Kill enemies to gain +1% dmg (max +80%). Right click to Parry."},
	
	# --- T3 CRAFTED WEAPONS ---
	"Mourning Bow": {"color": Color(0.2, 0.6, 0.8), "rarity": "Epic", "damage": 15, "charge_damage": 36, "range": 350.0, "attack_speed": 0.5, "charge_speed": 1.2, "knockback": 0.0, "weapon_type": "Elemental Damage", "trait": "CC", "passive": "Every charge shot fires a web that stuns enemies for 2 seconds.", "craft_cost": 1000},
	"Crystal Minigun": {"color": Color(0.8, 0.2, 0.5), "rarity": "Legendary", "damage": 12, "range": 300.0, "attack_speed": 0.1, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "Burst", "passive": "Every 10th shot releases a boulder that deals AoE 3x3 damage (+30% bonus).", "craft_cost": 1000},
	"Crystal Armor": {"color": Color(0.4, 0.8, 1.0), "rarity": "Epic", "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "damage_reduction": 16, "trait": "", "passive": "Gain 1 crystal stack per hit (max 10, each +0.5% DR).", "craft_cost": 1000},
	
		
	# --- T3 BLUEPRINT WEAPONS ---
	"Blueprint Silver Gray Sword": {"color": Color(0.75, 0.75, 0.8), "rarity": "Uncommon", "blueprint_for": "Silver Gray Sword", "domain_source": "Domain of Tricks", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Silver Gray Sword": {"color": Color(0.75, 0.75, 0.8), "damage": 23, "range": 64.0, "attack_speed": 0.5, "knockback": 4.0, "weapon_type": "Physical Damage", "rarity": "Uncommon", "trait": "Burst", "passive": "Every 5th hit adds 1 Accelerate stack (+10% attack speed, max 5 = +50%).", "craft_cost": 240, "craft_recipe": {"Silver Bar": 5, "Iron Bar": 5, "Copper Bar": 2}},
		
	"Blueprint Golden Conductor": {"color": Color(1.0, 0.8, 0.2), "rarity": "Rare", "blueprint_for": "Golden Conductor", "domain_source": "Domain of Brutality", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Golden Conductor": {"color": Color(1.0, 0.8, 0.2), "damage": 54, "range": 48.0, "attack_speed": 1.0, "knockback": 10.0, "weapon_type": "Elemental Damage", "rarity": "Rare", "trait": "AoE", "passive": "Hold left-click to charge 3s. Nearby enemies take 5% weapon dmg while charging. Release for 2x7 AoE explosion (+70% dmg).", "craft_cost": 520, "craft_recipe": {"Gold Bar": 6, "Iron Bar": 4, "Copper Bar": 4, "Silver Bar": 2}},
	
	"Blueprint Stormjade Cutter": {"color": Color(0.2, 0.9, 0.5), "rarity": "Rare", "blueprint_for": "Stormjade Cutter", "domain_source": "Domain of Cheap", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Stormjade Cutter": {"color": Color(0.2, 0.9, 0.5), "damage": 25, "range": 64.0, "attack_speed": 0.7, "knockback": 4.0, "weapon_type": "Elemental Damage", "rarity": "Rare", "trait": "Burst", "passive": "Right-click charge 3s, then dash 8 blocks through all enemies. Base +50% dmg, +25% per subsequent enemy hit (max +200%).", "craft_cost": 530, "craft_recipe": {"Mithril Bar": 7, "Emerald Crystal": 3, "Quartz Bar": 3}},
	
	"Blueprint Revenger Crystallinum": {"color": Color(0.3, 0.7, 0.9), "rarity": "Uncommon", "blueprint_for": "Revenger Crystallinum", "domain_source": "Domain of Power", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Revenger Crystallinum": {"color": Color(0.3, 0.7, 0.9), "damage": 17, "range": 48.0, "attack_speed": 0.3, "knockback": 2.0, "weapon_type": "Physical Damage", "rarity": "Uncommon", "trait": "Burst", "passive": "When hit by an enemy, gain +30% damage against that enemy only (max 3 stacks = +90%). Reset after 5s.", "craft_cost": 250, "craft_recipe": {"Diamond": 2, "Amethyst": 5, "Topaz Bar": 2, "Stable Crystal": 1}},
	
	"Blueprint Crystal Hammer": {"color": Color(0.4, 0.8, 1.0), "rarity": "Uncommon", "blueprint_for": "Crystal Hammer", "domain_source": "Domain of Durability", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Blueprint Bonecrusher": {"color": Color(0.6, 0.4, 0.2), "rarity": "Rare", "blueprint_for": "Bonecrusher", "domain_source": "Domain of Brutality", "weapon_class": "Tool", "desc": "Use this on Forge Station to unlock recipe."},
	"Blueprint Magic Pickaxe": {"color": Color(0.5, 0.3, 0.9), "rarity": "Uncommon", "blueprint_for": "Magic Pickaxe", "domain_source": "Domain of Believer", "weapon_class": "Tool", "desc": "Use this on Forge Station to unlock recipe."},
	"Blueprint Pneumatic Drill": {"color": Color(0.4, 0.5, 0.6), "rarity": "Rare", "blueprint_for": "Pneumatic Drill", "domain_source": "Domain of Durability", "weapon_class": "Tool", "desc": "Use this on Forge Station to unlock recipe."},
	"Crystal Hammer": {"color": Color(0.4, 0.8, 1.0), "damage": 48, "range": 48.0, "attack_speed": 1.0, "knockback": 10.0, "weapon_type": "Magic Damage", "rarity": "Uncommon", "trait": "CC", "passive": "Right-click charge 2s. On hit: enemies in 2x4 area stunned 1.5s. On kill: 35% chance drop random T1-T2 ore.", "craft_cost": 250, "craft_recipe": {"Diamond": 1, "Amethyst": 1, "Topaz Bar": 1, "Stable Crystal": 1, "Emerald Crystal": 1, "Uberilium Bar": 1}},
	
	# --- T3 ORES (setelah tutorial 3) ---
	"Quartz": {"color": Color(0.9, 0.9, 0.95)},
	"Topaz": {"color": Color(1.0, 0.6, 0.1)},
	"Emerald": {"color": Color(0.1, 0.9, 0.3)},
	"Amethyst": {"color": Color(0.6, 0.2, 0.9)},
	"Diamond": {"color": Color(0.4, 0.9, 1.0)},
	"Void Crystal": {"color": Color(0.3, 0.0, 0.5)},
	"Uberilium": {"color": Color(0.0, 1.0, 0.7)},

	# --- T3 BLOCKS ---
	"Crystal Stone": {"color": Color(0.4, 0.5, 0.7)},
	"Hardened Crystal Stone": {"color": Color(0.2, 0.2, 0.3)},

	# --- T3 SMELTING RESULTS ---
	"Quartz Bar": {"color": Color(0.85, 0.85, 0.95)},        # putih keperakan
	"Topaz Bar": {"color": Color(0.95, 0.6, 0.15)},          # oranye keemasan
	"Emerald Crystal": {"color": Color(0.1, 0.85, 0.35)},    # hijau zamrud
	"Stable Crystal": {"color": Color(0.4, 0.15, 0.6)},      # ungu gelap (void → stabil)
	"Uberilium Bar": {"color": Color(0.05, 0.95, 0.7)},      # cyan kehijauan

	# --- T3 MATERIAL DROPS ---
	"Scrap": {"color": Color(0.6, 0.5, 0.4)},
	"Essence Crystal": {"color": Color(0.8, 0.2, 1.0)},

	# --- T3 WEAPON PARTS (⛏️ dari mining T3) ---
	"Mourning Bow Part ⛏️": {"color": Color(0.2, 0.6, 0.8)},
	"Crystal Minigun Part ⛏️": {"color": Color(0.8, 0.2, 0.5)},
	"Crystal Armor Part ⛏️": {"color": Color(0.4, 0.8, 1.0)},

	# --- T3 WEAPON PARTS (💀 dari monster T3) ---
	"Mourning Bow Part 💀": {"color": Color(0.2, 0.6, 0.8)},
	"Crystal Minigun Part 💀": {"color": Color(0.8, 0.2, 0.5)},
	"Crystal Armor Part 💀": {"color": Color(0.4, 0.8, 1.0)},

	# --- T3 WEAPON PARTS (⚔️ dari peti boss domain) ---
	"Mourning Bow Part ⚔️": {"color": Color(0.2, 0.6, 0.8)},
	"Crystal Minigun Part ⚔️": {"color": Color(0.8, 0.2, 0.5)},
	"Crystal Armor Part ⚔️": {"color": Color(0.4, 0.8, 1.0)},
	
	# --- T3 ARMOR & TOOLS ---
	"Metal Skin Armor": {"color": Color(0.6, 0.6, 0.65), "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Uncommon", "damage_reduction": 10, "trait": "", "passive": "Reflect 20% melee damage.", "craft_cost": 250, "craft_recipe": {"Iron Bar": 3, "Copper Bar": 4, "Gold Bar": 4, "Mithril Bar": 3}},
	"Shining Justice": {"color": Color(1.0, 0.9, 0.5), "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Uncommon", "damage_reduction": 9, "trait": "", "passive": "35% chance drop ore when hit.", "craft_cost": 260, "craft_recipe": {"Quartz Bar": 5, "Gold Bar": 4, "Topaz Bar": 4}},
	"Tenacity Battle Armor": {"color": Color(0.3, 0.6, 0.7), "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Rare", "damage_reduction": 15, "trait": "", "passive": "40% reflect projectiles.", "craft_cost": 570, "craft_recipe": {"Diamond": 4, "Stable Crystal": 4, "Uberilium Bar": 1}},
	"Deep Cave Armor": {"color": Color(0.4, 0.3, 0.2), "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Rare", "damage_reduction": 13, "trait": "", "passive": "Petrify 2s when HP < 50%.", "craft_cost": 520, "craft_recipe": {"Emerald Crystal": 5, "Amethyst": 5, "Uberilium Bar": 2}},
	
	"Bonecrusher": {"color": Color(0.6, 0.4, 0.2), "damage": 11, "range": 96.0, "attack_speed": 0.7, "efficiency": 5.0, "knockback": 10.0, "weapon_type": "Physical Damage", "rarity": "Rare", "trait": "", "passive": "Mining breaks adjacent toughness.", "craft_cost": 590, "craft_recipe": {"Silver Bar": 4, "Iron Bar": 4, "Mithril Bar": 6}},
	"Magic Pickaxe": {"color": Color(0.5, 0.3, 0.9), "damage": 9, "range": 320.0, "attack_speed": 0.7, "efficiency": 4.0, "knockback": 0.0, "weapon_type": "Magic Damage", "rarity": "Uncommon", "trait": "", "passive": "Beam mining up to 20 blocks.", "craft_cost": 240, "craft_recipe": {"Topaz Bar": 3, "Amethyst": 3, "Emerald Crystal": 3, "Quartz Bar": 3}},
	"Pneumatic Drill": {"color": Color(0.4, 0.5, 0.6), "damage": 10, "range": 64.0, "attack_speed": 0.4, "efficiency": 5.0, "knockback": 10.0, "weapon_type": "Physical Damage", "rarity": "Rare", "trait": "", "passive": "30% chance bomb on break.", "craft_cost": 630, "craft_recipe": {"Diamond": 4, "Uberilium Bar": 4, "Emerald Crystal": 6}},
	
	# Makanan
	"Banana": {"color": Color(1.0, 0.9, 0.2)},
	"Grape": {"color": Color(0.6, 0.2, 0.8)},
	"Bacon": {"color": Color(0.8, 0.3, 0.3)},
	"Pizza Slice": {"color": Color(1.0, 0.6, 0.2)},
	"Burger": {"color": Color(0.7, 0.4, 0.2)},
	"Golden Burger": {"color": Color(1.0, 0.8, 0.1)},
	"Frozen Apple": {"color": Color(0.4, 0.8, 1.0)},
}

# FIX #1: helper warna item — fallback ke putih kalau item belum terdaftar
func get_item_color(item_name: String) -> Color:
	return item_data.get(item_name, {"color": Color.WHITE})["color"]

func _ready():
	# --- LOGIKA MUSIK HOME ---
	if Global.tutorial_step == 0:
		MusicManager.stop_bgm() 
	else:
		play_home_bgm()
	# -------------------------
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	
	# Paksa kamera menyala (Fix layar abu-abu)
	if has_node("Player/Camera2D"):
		$Player/Camera2D.make_current()
	
	# --- SAFETY NET: Strip material dungeon yang bocor ---
	Global.strip_dungeon_materials()
	# -----------------------------------------------------

	# ========================================================================
	# --- DEBUG MODE: UNLOCK SEMUA SENJATA & MAKANAN UNTUK TESTING SFX ---
	# (PENTING: Ubah 'if true:' menjadi 'if false:' setelah selesai testing 
	#  agar game kembali ke loadout normal 4 item!)
	if true: 
		Global.saved_inventory.clear()
		Global.ore_storage.clear()
		Global.material_storage.clear()
		Global.weapon_storage.clear()
		Global.unlocked_blueprints.clear()
		
		var all_test_items = [
			# Tools
			"Stone Pickaxe", "Iron Pickaxe", "Swarmid Drill", "Bonecrusher", "Magic Pickaxe",
			# Melee
			"Fist", "Wooden Sword", "Iron Sword", "Menacing Dagger", 
			"Sharding Sword", "Silver Gray Sword", "Stormjade Cutter", 
			"Revenger Crystallinum", "Galahad Chimelin", "Golden Conductor", "Crystal Hammer",
			# Range
			"Bow", "Hunter Bow", "Iron Bow", "Marble Slingshot", "Ricochet Bow", 
			"Sticky Crossbow", "Headhitter Heavy Bow", "Bounty Bow", 
			"Explosive Crossbow", "Mourning Bow", "Crystal Minigun",
			# Magic / Utility
			"Heretic Staff", "Maniacal Chainsaw", "Radiance Scepter",
			# Armor
			"Iron Armor", "Heavy Amethyst Armor", "Crystal Armor", 
			"Metal Skin Armor", "Shining Justice", "Tenacity Battle Armor", "Deep Cave Armor",
			# Consumables (Untuk testing SFX makan: eat_dry & eat_wet)
			"Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"
		]
		
		# Masukkan ke inventory & set level 1 (menggunakan sistem UUID)
		for item in all_test_items:
			var is_weapon = item_data.get(item, {}).has("weapon_type")
			if is_weapon:
				var uid = Global.create_weapon_key(item)
				Global.saved_inventory[uid] = 1
				Global.item_levels[uid] = 1
			else:
				Global.saved_inventory[item] = 5 # Kasih 5x untuk makanan/testing
		
		# Atur Hotbar agar rapi dan mewakili berbagai kategori SFX (7 slot: 0-6)
		Global.hotbar_items[0] = "Swarmid Drill"
		Global.hotbar_uuids[0] = Global.create_weapon_key("Swarmid Drill")
		
		Global.hotbar_items[1] = "Galahad Chimelin"
		Global.hotbar_uuids[1] = Global.create_weapon_key("Galahad Chimelin")
		
		Global.hotbar_items[2] = "Crystal Minigun"
		Global.hotbar_uuids[2] = Global.create_weapon_key("Crystal Minigun")
		
		Global.hotbar_items[3] = "Golden Conductor"
		Global.hotbar_uuids[3] = Global.create_weapon_key("Golden Conductor")
		
		Global.hotbar_items[4] = "Heretic Staff"
		Global.hotbar_uuids[4] = Global.create_weapon_key("Heretic Staff")
		
		Global.hotbar_items[5] = "Maniacal Chainsaw"
		Global.hotbar_uuids[5] = Global.create_weapon_key("Maniacal Chainsaw")
		
		Global.hotbar_items[6] = "Bounty Bow"
		Global.hotbar_uuids[6] = Global.create_weapon_key("Bounty Bow")
		
		# Equip Armor default
		Global.equipped_armor = "Crystal Armor"
		Global.equipped_armor_uuid = Global.create_weapon_key("Crystal Armor")
		
		Global.loadout_v6_done = true # Tandai supaya tidak reset lagi
		Global.save_game()
		print("[DEBUG] ALL WEAPONS, ARMOR & CONSUMABLES UNLOCKED FOR SFX TESTING!")
	# ========================================================================

	# (Kode asli kamu untuk tutorial fix & anti-softlock)
	if Global.tutorial_completed and Global.tutorial_step == 0:
		Global.tutorial_step = 1
		print("FIXED TUTORIAL STEP TO 1")
	
	if Global.tutorial_step == 4 and not Global.tut_home_checked_gold:
		Global.tut_home_checked_gold = true
		var total_value = Global.gold_coins
		var ores = {"Copper": 1, "Iron": 2, "Silver": 4, "Gold": 7, "Mithril": 15}
		for ore in ores.keys():
			total_value += Global.saved_inventory.get(ore, 0) * ores[ore]
			total_value += Global.ore_storage.get(ore, 0) * ores[ore]
			
		if total_value < 120:
			Global.gold_coins += 120
			Global.tutorial_step = 5 
			Global.save_game()
			show_home_dialog("Old Miner: \"Wow seems like u are in a hurry... welp cant do nothing about that! here's 120 gold!\"")
			update_objective_ui()

	print("DEBUG: Current Tutorial Step = ", Global.tutorial_step)

	var canvas = CanvasLayer.new()
	add_child(canvas)

	ui_prompt = Label.new()
	ui_prompt.position = Vector2(400, 650)
	ui_prompt.add_theme_font_size_override("font_size", 28)
	ui_prompt.add_theme_color_override("font_color", Color.YELLOW)
	ui_prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_prompt.add_theme_constant_override("outline_size", 6)
	ui_prompt.visible = false
	canvas.add_child(ui_prompt)

	ui_objective_label = Label.new()
	ui_objective_label.position = Vector2(20, 100)
	ui_objective_label.add_theme_font_size_override("font_size", 24)
	ui_objective_label.add_theme_color_override("font_color", Color.GOLD)
	ui_objective_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_objective_label.add_theme_constant_override("outline_size", 6)
	canvas.add_child(ui_objective_label)

	if Global.tutorial_completed or Global.tutorial_step >= 1:
		spawn_buildings()
		spawn_interactables()
		spawn_testing_area() 
		
		if Global.tutorial_step >= 4:
			spawn_stations()
			
		bikin_ui_lobby(canvas)
		bikin_ui_pause_home()
		bikin_ui_selling(canvas)
		bikin_ui_storage(canvas)
		bikin_ui_forge(canvas)
		bikin_ui_music_player(canvas)
		bikin_ui_smelt(canvas)
		bikin_ui_guild(canvas)
		bikin_ui_prep(canvas)
		bikin_ui_dialog(canvas)
		bikin_ui_smithing(canvas)
		bikin_cutscene_ui(canvas)
		spawn_guild_master()
		update_objective_ui()
		update_hotbar_ui()
		_refresh_player_name_label()
		
		if Global.tutorial_step == 9:
			if Global.post_t3_cutscene_step < 9:
				call_deferred("_resume_post_t3_cutscene")
			else:
				Global.tutorial_step = 10
				Global.post_t3_cutscene_step = 0
				Global.save_game()
				update_objective_ui()
		
func update_objective_ui():
	if not is_instance_valid(ui_objective_label): return

	if Global.tutorial_step == 1:
		ui_objective_label.text = "Obj: Sell 5 Copper to Old Miner (" + str(Global.copper_sold) + "/5)"
	elif Global.tutorial_step == 2:
		ui_objective_label.text = "Obj: Store all Ores in Ore Storage (Blue House)"
	elif Global.tutorial_step == 3:
		ui_objective_label.text = "Obj: Enter Crystaline Caverns"
	elif Global.tutorial_step == 4:
		ui_objective_label.text = "Obj: Obtain 120 Gold from Old Miner (" + str(Global.gold_coins) + "/120)"
	elif Global.tutorial_step == 5:
		var bars = Global.saved_inventory.get("Iron Bar", 0)
		ui_objective_label.text = "Obj: Smelt 10 Iron Bars at Smelter (" + str(bars) + "/10)"
	elif Global.tutorial_step == 6:
		ui_objective_label.text = "Obj: Craft Iron Armor at Forge"
	elif Global.tutorial_step == 7 or Global.tutorial_step == 8:
		ui_objective_label.text = "Obj: Enter Crystaline Caverns"
	elif Global.tutorial_step == 9:
		ui_objective_label.text = ""
	elif Global.tutorial_step == 10:
		ui_objective_label.text = "Obj: Go to Smithing Station and talk to Gail"
	elif Global.tutorial_step == 11:
		ui_objective_label.text = "Obj: Upgrade your Iron Sword at Gail"
	elif Global.tutorial_step == 12:
		ui_objective_label.text = "Obj: Talk to Mike for the next adventure"
	elif Global.tutorial_step >= 13:
		ui_objective_label.text = ""
	else:
		ui_objective_label.text = ""

func spawn_buildings():
	var house = Node2D.new()
	house.position = Vector2(-250, 180)
	house.z_index = -1
	var h_visual = ColorRect.new()
	h_visual.size = Vector2(250, 150)
	h_visual.position = Vector2(-125, -150)
	h_visual.color = Color(0.2, 0.3, 0.6)
	house.add_child(h_visual)
	var h_text = Label.new(); h_text.text = "PLAYER HOUSE"; h_text.position = Vector2(-40, -80)
	house.add_child(h_text); add_child(house)

	var mine = Node2D.new()
	mine.position = Vector2(-550, 180)
	mine.z_index = -1
	var m_visual = ColorRect.new()
	m_visual.size = Vector2(150, 100); m_visual.position = Vector2(-75, -100); m_visual.color = Color(0.3, 0.2, 0.1)
	mine.add_child(m_visual)
	var m_text = Label.new(); m_text.text = "OLD MINE"; m_text.position = Vector2(-25, -50)
	mine.add_child(m_text); add_child(mine)
	
	# --- BANGUNAN MUSIC PLAYER ---
	music_player_node = Node2D.new()
	music_player_node.position = Vector2(100, 180)
	music_player_node.z_index = -1
	
	var mp_visual = ColorRect.new()
	mp_visual.size = Vector2(40, 60)
	mp_visual.position = Vector2(-20, -60)
	mp_visual.color = Color(0.6, 0.2, 0.8) # Warna ungu (Jukebox)
	music_player_node.add_child(mp_visual)
	
	var mp_text = Label.new()
	mp_text.text = "MUSIC\nPLAYER"
	mp_text.position = Vector2(-25, -85)
	mp_text.add_theme_font_size_override("font_size", 10)
	mp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	music_player_node.add_child(mp_text)
	add_child(music_player_node)

func spawn_interactables():
	old_miner_node = Node2D.new()
	old_miner_node.position = Vector2(-550, 180)
	old_miner_node.z_index = -1
	var m_visual = ColorRect.new()
	m_visual.size = Vector2(32, 48); m_visual.position = Vector2(-16, -48); m_visual.color = Color(1.0, 0.8, 0.2)
	old_miner_node.add_child(m_visual); add_child(old_miner_node)

	storage_ore_node = Node2D.new()
	storage_ore_node.position = Vector2(-320, 180)
	storage_ore_node.z_index = -1
	var so_visual = ColorRect.new()
	so_visual.size = Vector2(40, 40); so_visual.position = Vector2(-20, -40); so_visual.color = Color(0.6, 0.3, 0.1)
	storage_ore_node.add_child(so_visual); add_child(storage_ore_node)

	storage_weapon_node = Node2D.new()
	storage_weapon_node.position = Vector2(-180, 180)
	storage_weapon_node.z_index = -1
	var sw_visual = ColorRect.new()
	sw_visual.size = Vector2(40, 40)
	sw_visual.position = Vector2(-20, -40)
	sw_visual.color = Color(0.1, 0.3, 0.6)
	storage_weapon_node.add_child(sw_visual)
	add_child(storage_weapon_node)

func spawn_guild_master():
	guild_master_node = Node2D.new()
	var _guild_x = guild_area.global_position.x if is_instance_valid(guild_area) else -100
	guild_master_node.position = Vector2(_guild_x - 80, 180) # Paksa Y=180 biar nginjak tanah
	guild_master_node.z_index = -1
	
	var _h = 52.0 # Tinggi Mike (3/4 dari player)
	var _w = 32.0
	
	var visual = ColorRect.new()
	visual.size = Vector2(_w, _h)
	visual.position = Vector2(-_w/2, -_h)
	visual.color = Color(0.3, 0.5, 0.9)
	guild_master_node.add_child(visual)
	
	var title_lbl = Label.new()
	title_lbl.text = "Guild Master"
	title_lbl.position = Vector2(-35, -_h - 40)
	title_lbl.add_theme_font_size_override("font_size", 11)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	title_lbl.add_theme_constant_override("outline_size", 2)
	guild_master_node.add_child(title_lbl)
	
	var name_lbl = Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.text = "Mike"
	name_lbl.position = Vector2(-20, -_h - 20)
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color.GOLD)
	name_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	name_lbl.add_theme_constant_override("outline_size", 3)
	guild_master_node.add_child(name_lbl)
	
	add_child(guild_master_node)

func get_base_cost(item_name: String) -> int:
	var data = item_data.get(item_name, {})
	if data.has("craft_cost"): return int(data["craft_cost"])
	match data.get("rarity", "Common"):
		"Uncommon": return 250
		"Rare": return 500
		"Epic": return 1000
		"Legendary": return 2000
		_: return 70 # Common

func get_upgrade_scrap_cost(item_name: String, target_lv: int) -> int:
	var rarity = item_data.get(item_name, {}).get("rarity", "Common")
	var table = {
		"Common": [20, 25, 30, 40],
		"Uncommon": [30, 35, 40, 50],
		"Rare": [40, 50, 60, 70],
		"Epic": [50, 65, 80, 100],
		"Legendary": [70, 90, 110, 130]
	}
	var arr = table.get(rarity, table["Common"])
	return arr[target_lv - 2]

func _process(delta):
	if get_tree().paused: return
	if is_instance_valid(ui_exp_label):
		ui_exp_label.text = Global.player_name + " Lv " + str(Global.player_level) + " | EXP: " + str(Global.player_exp) + "/" + str(Global.exp_to_next_level) + " | Mana: " + str(int(Global.current_mana)) + "/" + str(Global.max_mana)
		
	# --- LOGIKA DPS METER ---
	if combat_hits > 0:
		idle_timer += delta
		combat_timer += delta
		
		if idle_timer >= 3.0:
			combat_hits = 0
			combat_dmg_total = 0.0
			combat_timer = 0.0
			idle_timer = 0.0
			dummy_dps_label.text = "DPS: 0.0\nAvg Dmg: 0.0"
		else:
			var current_dps = combat_dmg_total / combat_timer
			var avg_dmg = combat_dmg_total / combat_hits
			dummy_dps_label.text = "DPS: " + str(snapped(current_dps, 0.1)) + "\nAvg Dmg: " + str(snapped(avg_dmg, 0.1))
	
	if bounty_stack_timer > 0:
		bounty_stack_timer -= delta
		if bounty_stack_timer <= 0 and bounty_bow_stacks > 0:
			bounty_bow_stacks = 0
			show_floating_text("Bounty Reset!", player.global_position + Vector2(0, -80), Color.GRAY)
	
	if swarmid_exhausted_timer > 0:
		swarmid_exhausted_timer -= delta
		
	var _held = Global.hotbar_items[selected_home_slot]
	if _held == "Swarmid Drill" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and swarmid_exhausted_timer <= 0:
		swarmid_use_timer += delta
		if swarmid_use_timer >= 8.0:
			swarmid_exhausted_timer = 3.5
			swarmid_use_timer = 0.0
			show_floating_text("DRILL EXHAUSTED!", player.global_position + Vector2(0, -60), Color.RED)
	elif _held != "Swarmid Drill" or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		swarmid_use_timer = move_toward(swarmid_use_timer, 0, delta * 2.0)
	
	if home_attack_cooldown > 0:
		home_attack_cooldown -= delta
	
	# --- GOLDEN CONDUCTOR: charge tick ---
	if conductor_charging:
		conductor_charge_timer += delta
		conductor_tick_timer += delta
		if conductor_tick_timer >= 0.5:
			conductor_tick_timer = 0.0
			if is_instance_valid(dummy_node) and player.global_position.distance_to(dummy_node.global_position) < 64.0:
				var _tick_dmg = int(54 * 0.05)
				combat_dmg_total += _tick_dmg
				combat_hits += 1
				idle_timer = 0.0
				show_floating_text(str(_tick_dmg), dummy_node.global_position + Vector2(0, -60), Color.YELLOW)
	
	# --- HAMMER & STORMJADE CHARGE TICK (FIX) ---
	if hammer_charging:
		hammer_charge_timer += delta
	if stormjade_charging:
		stormjade_charge_timer += delta
		
	# --- TIMERS (Armor, Parry, Revenger, Crystal) ---
	if galahad_parry_cd > 0:
		galahad_parry_cd -= delta
		
	if deep_cave_cooldown > 0:
		deep_cave_cooldown -= delta
	if deep_cave_active:
		deep_cave_petrify_timer -= delta
		if deep_cave_petrify_timer > 0:
			deep_cave_regen_timer += delta
			if deep_cave_regen_timer >= 1.0:
				deep_cave_regen_timer -= 1.0
				Global.current_hp = min(Global.current_hp + 7, Global.max_hp)
				update_hp_ui()
		else:
			deep_cave_active = false
			player.set_physics_process(true)
			show_floating_text("RECOVERED!", player.global_position + Vector2(0, -60), Color.GREEN)
			
	if revenger_timer > 0:
		revenger_timer -= delta
		if revenger_timer <= 0:
			revenger_stacks = 0
			revenger_target = null
			
	if crystal_armor_timer > 0:
		crystal_armor_timer -= delta
		if crystal_armor_timer <= 0:
			crystal_armor_stacks = 0
	
	# --- TICKER POISON & BLEED DUMMY ---
	if dummy_poison_dmg > 0:
		dummy_poison_tick += delta
		if dummy_poison_tick >= 1.0:
			dummy_poison_tick -= 1.0
			dummy_poison_rem -= 1
			combat_dmg_total += dummy_poison_dmg
			combat_hits += 1
			idle_timer = 0.0
			show_floating_text(str(dummy_poison_dmg), dummy_node.global_position + Vector2(0, -80), Color.GREEN)
			if dummy_poison_rem <= 0:
				dummy_poison_dmg = 0
				
	if dummy_bleed_dmg > 0:
		dummy_bleed_tick += delta
		if dummy_bleed_tick >= 1.0:
			dummy_bleed_tick -= 1.0
			dummy_bleed_rem -= 1
			combat_dmg_total += dummy_bleed_dmg
			combat_hits += 1
			idle_timer = 0.0
			show_floating_text(str(dummy_bleed_dmg), dummy_node.global_position + Vector2(0, -80), Color.RED)
			if dummy_bleed_rem <= 0:
				dummy_bleed_dmg = 0

	# --- LOGIKA PLAYER NYERANG DUMMY ---
	if not is_inventory_open and not is_forge_open and not is_smelt_open and not is_selling_ui_open and not is_storage_ui_open:
		var _held_check = Global.hotbar_items[selected_home_slot]
		
		if _held_check == "Golden Conductor":
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				if not conductor_charging:
					conductor_charging = true
					conductor_charge_timer = 0.0
					conductor_tick_timer = 0.0
			else:
				if conductor_charging:
					if conductor_charge_timer >= 3.0:
						# === EXPLOSION ke arah mouse (visual sama seperti dungeon) ===
						var _explosion_dmg = int(54 * 1.7)
						var _dir_x = sign(get_global_mouse_position().x - player.global_position.x)
						if _dir_x == 0: _dir_x = 1
						var _player_bottom = player.global_position.y + 32
						var _max_dist = 128.0
						
						# Damage dummy
						if is_instance_valid(dummy_node):
							var _dummy_bottom = dummy_node.global_position.y + 40  # dummy body extends -80 to 0
							var _dx = dummy_node.global_position.x - player.global_position.x
							var _in_x = (_dir_x > 0 and _dx >= -16 and _dx <= _max_dist + 16) or (_dir_x < 0 and _dx <= 16 and _dx >= -_max_dist - 16)
							var _in_y = abs(_dummy_bottom - _player_bottom) < 60  # dummy lebih besar
							if _in_x and _in_y:
								combat_dmg_total += _explosion_dmg
								combat_hits += 1
								idle_timer = 0.0
								show_floating_text(str(_explosion_dmg), dummy_node.global_position + Vector2(0, -100), Color.ORANGE)
								var _dt = create_tween()
								_dt.tween_property(dummy_node, "position:x", dummy_node.position.x + 20, 0.05)
								_dt.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
						
						# Visual garis horizontal
						var _exp = ColorRect.new()
						_exp.size = Vector2(_max_dist, 24)
						if _dir_x > 0:
							_exp.position = Vector2(player.global_position.x, _player_bottom - 24)
						else:
							_exp.position = Vector2(player.global_position.x - _max_dist, _player_bottom - 24)
						_exp.color = Color(1.0, 0.8, 0.2, 0.8)
						_exp.z_index = 15
						add_child(_exp)
						var _t = create_tween()
						_t.tween_property(_exp, "modulate:a", 0.0, 0.3)
						_t.tween_callback(_exp.queue_free)
						
						home_attack_cooldown = 1.0
					else:
						if home_attack_cooldown <= 0:
							if is_instance_valid(dummy_node) and player.global_position.distance_to(dummy_node.global_position) < 200.0:
								test_dummy_attack(false)
							home_attack_cooldown = 1.0
					conductor_charging = false
					conductor_charge_timer = 0.0
					conductor_tick_timer = 0.0
			# Charge tick
			if conductor_charging:
				conductor_charge_timer += delta
				conductor_tick_timer += delta
				if conductor_tick_timer >= 0.5:
					conductor_tick_timer = 0.0
					if is_instance_valid(dummy_node) and player.global_position.distance_to(dummy_node.global_position) < 64.0:
						var _tick_dmg = int(54 * 0.05)
						combat_dmg_total += _tick_dmg
						combat_hits += 1
						idle_timer = 0.0
						show_floating_text(str(_tick_dmg), dummy_node.global_position + Vector2(0, -60), Color.YELLOW)
			return
			
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and home_attack_cooldown <= 0:
			var held = Global.hotbar_items[selected_home_slot]
			if held in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Heretic Staff", "Ricochet Bow", "Sticky Crossbow"]:
				test_dummy_attack(false)
			else:
				if is_instance_valid(dummy_node) and player.global_position.distance_to(dummy_node.global_position) < 200.0:
					test_dummy_attack(false)

	# --- LOGIKA DUMMY NYERANG PLAYER ---
	if is_instance_valid(dummy_node) and not is_inventory_open and not is_forge_open and not is_smelt_open:
		if player.global_position.distance_to(dummy_node.global_position) < 150.0:
			dummy_atk_timer -= delta
			if dummy_atk_timer <= 0:
				dummy_atk_timer = 2.0
				
				var armor_dr = 0
				if Global.equipped_armor != null:
					var _eff_armor = Global.get_effective_stats(Global.equipped_armor, item_data.get(Global.equipped_armor, {}), Global.equipped_armor_uuid)
					armor_dr = _eff_armor.get("damage_reduction", 0)
				
				if Global.equipped_armor == "Heavy Amethyst Armor":
					if has_meta("amethyst_buffed"):
						armor_dr += 5
						remove_meta("amethyst_buffed")
					if 20 > 10:
						set_meta("amethyst_buffed", true)
				
				if Global.equipped_armor == "Crystal Armor":
					crystal_armor_stacks = min(crystal_armor_stacks + 1, 10)
					armor_dr += crystal_armor_stacks * 0.5
					crystal_armor_timer = 7.0
					show_floating_text("Crystal Stack: " + str(crystal_armor_stacks) + "/10", player.global_position + Vector2(0, -80), Color.CYAN)

				var final_dmg = max(1, 20 - armor_dr)
				if galahad_parry_active:
					show_floating_text("PARRIED!", player.global_position + Vector2(0, -40), Color.GOLD)
					galahad_parry_active = false
					final_dmg = 0
					if is_instance_valid(dummy_node):
						var _counter_dmg = int(65 * 1.75)
						combat_dmg_total += _counter_dmg
						combat_hits += 1
						idle_timer = 0.0
						show_floating_text(str(_counter_dmg) + " PARRY!", dummy_node.global_position + Vector2(0, -100), Color.GOLD)
						var _kb = sign(dummy_node.global_position.x - player.global_position.x)
						if _kb == 0: _kb = 1
						var _base_x = dummy_node.position.x
						var _t = create_tween()
						_t.tween_property(dummy_node, "position:x", _base_x + _kb * 64, 0.1)
				
				if final_dmg > 0 and Global.hotbar_items[selected_home_slot] == "Revenger Crystallinum":
					if revenger_target == dummy_node:
						revenger_stacks = min(revenger_stacks + 1, 3)
					else:
						revenger_target = dummy_node
						revenger_stacks = 1
					revenger_timer = 5.0
					show_floating_text("Revenge +" + str(revenger_stacks * 30) + "%", player.global_position + Vector2(0, -100), Color.RED)
				
				Global.current_hp -= final_dmg
				show_floating_text("-" + str(final_dmg) + " HP", player.global_position + Vector2(0, -50), Color.RED)
				
				if Global.equipped_armor == "Metal Skin Armor" and is_instance_valid(dummy_node):
					if player.global_position.distance_to(dummy_node.global_position) < 100.0:
						var _reflect = max(1, int(20 * 0.20))
						combat_dmg_total += _reflect
						combat_hits += 1
						idle_timer = 0.0
						show_floating_text(str(_reflect) + " (Reflect)", dummy_node.global_position + Vector2(0, -50), Color.CYAN)
				
				if Global.equipped_armor == "Shining Justice":
					if randf() < 0.35:
						var _ores = ["Copper", "Iron", "Coal", "Silver", "Gold", "Mithril", "Quartz", "Topaz", "Emerald", "Amethyst", "Diamond", "Void Crystal", "Uberilium"]
						var _drop = _ores.pick_random()
						Global.saved_inventory[_drop] = Global.saved_inventory.get(_drop, 0) + 1
						show_floating_text("+" + _drop, player.global_position + Vector2(0, -100), Color.GOLD)
						Global.save_game()
				
				if Global.equipped_armor == "Deep Cave Armor" and not deep_cave_active and deep_cave_cooldown <= 0:
					if Global.current_hp < Global.max_hp * 0.5 and Global.current_hp > 0:
						deep_cave_active = true
						deep_cave_petrify_timer = 2.0
						deep_cave_regen_timer = 0.0
						deep_cave_cooldown = 30.0
						player.set_physics_process(false)
						show_floating_text("PETRIFIED!", player.global_position + Vector2(0, -60), Color.GRAY)
				
				var tween = create_tween()
				tween.tween_property(dummy_node, "position:x", dummy_node.position.x - 10, 0.1)
				tween.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
				
				if Global.current_hp <= 0:
					Global.current_hp = Global.max_hp
					show_floating_text("RESPAWNED!", player.global_position + Vector2(0, -70), Color.CYAN)
					
				for i in range(10):
					if Global.current_hp >= (i + 1) * 10:
						heart_labels[i].text = "❤"
						heart_labels[i].add_theme_color_override("font_color", Color.RED)
					else:
						heart_labels[i].text = "♡"
						heart_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		else:
			dummy_atk_timer = 0.0

	# --- LOGIKA UI & INTERAKSI BAWAAN ---
	update_objective_ui()
	if is_selling_ui_open or is_storage_ui_open: return

	can_enter_guild = false
	can_talk_miner = false
	can_open_ore_storage = false
	can_open_weapon_storage = false
	can_use_music_player = false
	ui_prompt.visible = false

	# 1. PRIORITAS PERTAMA: MIKE (Hanya saat tutorial step 12)
	if Global.tutorial_step == 12 and is_instance_valid(guild_master_node) and player.global_position.distance_to(guild_master_node.global_position) < 150.0:
		can_enter_guild = true
		ui_prompt.text = "Press [E] to talk to Mike"
		ui_prompt.visible = true
		
	# 2. PRIORITAS KEDUA: PINTU GUILD
	elif player.global_position.distance_to(guild_area.global_position) < 150.0:
		can_enter_guild = true
		ui_prompt.text = "Press [E] to enter Adventurer Guild"
		ui_prompt.visible = true
		
	# 3. INTERAKSI LAINNYA
	elif Global.tutorial_step == 1 and is_instance_valid(old_miner_node) and player.global_position.distance_to(old_miner_node.global_position) < 150.0:
		can_talk_miner = true
		ui_prompt.text = "Press [E] to talk to Old Miner"
		ui_prompt.visible = true
	elif Global.tutorial_step >= 2 and is_instance_valid(storage_ore_node) and player.global_position.distance_to(storage_ore_node.global_position) < 150.0:
		can_open_ore_storage = true
		ui_prompt.text = "Press [E] to open Ore Storage"
		ui_prompt.visible = true
	elif Global.tutorial_step >= 2 and is_instance_valid(storage_weapon_node) and player.global_position.distance_to(storage_weapon_node.global_position) < 150.0:
		can_open_weapon_storage = true
		ui_prompt.text = "Press [E] to open Weapon Storage"
		ui_prompt.visible = true
	elif is_instance_valid(smithing_station_node) and player.global_position.distance_to(smithing_station_node.global_position) < 150.0:
		ui_prompt.text = "Press [E] to use Smithing Station"
		ui_prompt.visible = true
	elif is_instance_valid(forge_node) and player.global_position.distance_to(forge_node.global_position) < 150.0:
		ui_prompt.text = "Press [E] to use Forge"
		ui_prompt.visible = true
	elif is_instance_valid(smelt_node) and player.global_position.distance_to(smelt_node.global_position) < 150.0:
		ui_prompt.text = "Press [E] to use Smelter"
		ui_prompt.visible = true
	elif is_instance_valid(music_player_node) and player.global_position.distance_to(music_player_node.global_position) < 150.0:
		can_use_music_player = true
		ui_prompt.text = "Press [E] to use Music Player"
		ui_prompt.visible = true

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if is_forge_open or is_smelt_open or is_inventory_open or is_guild_open or is_prep_open or is_smithing_open:
			close_all_menus()
		else:
			# --- PENGAMAN: Cek apakah panel udah dibuat ---
			if not is_instance_valid(pause_panel_home):
				bikin_ui_pause_home()
			# ---------------------------------------------
			
			is_pause_home_open = not is_pause_home_open
			pause_panel_home.visible = is_pause_home_open
			get_tree().paused = is_pause_home_open
			$Player.set_physics_process(not is_pause_home_open)
		return
	
	# --- SMITHING STATION UI (PASTE DI SINI) ---
	if is_smithing_open:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mp = get_viewport().get_mouse_position()
			var _is_tut = (Global.tutorial_step == 11)
			
			# Klik Backpack
			for i in range(smithing_inv_slots.size()):
				if smithing_inv_slots[i].get_global_rect().has_point(mp):
					var ibp = get_backpack_items()
					if i < ibp.size():
						var _k = ibp[i]
						var _base_name = Global.get_base_name(_k)
						
						# --- BLOKIR SCRAP & MATERIAL ---
						if _base_name == "Scrap" or not item_data.get(_base_name, {}).has("weapon_type"):
							show_floating_text("This item cannot be upgraded or salvaged!", player.global_position, Color.RED)
							return
						# --------------------------------
						
						# --- LOCKDOWN TUTORIAL ---
						if _is_tut:
							if Global.get_base_name(_k) != "Iron Sword" or Global.get_item_level("Iron Sword", _k) != 1:
								show_floating_text("Locked! You must upgrade the Iron Sword first.", player.global_position, Color.RED)
								return
						# -------------------------
						smithing_selected_uuid = _k
						update_smithing_ui()
					return
					
			# Klik Storage
			for i in range(smithing_sto_slots.size()):
				if smithing_sto_slots[i].get_global_rect().has_point(mp):
					if _is_tut:
						show_floating_text("Locked! You must upgrade the Iron Sword first.", player.global_position, Color.RED)
						return
					var storage = Global.weapon_storage if smithing_active_tab == "weapon" else Global.material_storage
					var keys = storage.keys()
					if i < keys.size():
						var k = keys[i]
						if Global.is_unique_key(k):
							smithing_selected_uuid = k
							update_smithing_ui()
						else:
							move_to_inventory(k, 999)
							update_smithing_ui()
					return
					
			# Klik Equip
			for i in range(4):
				if smithing_equip_slots[i].get_global_rect().has_point(mp):
					if _is_tut:
						show_floating_text("Locked! You must upgrade the Iron Sword first.", player.global_position, Color.RED)
						return
					var uid = Global.equipped_armor_uuid if i == 3 else Global.hotbar_uuids[i]
					if uid != "":
						smithing_selected_uuid = uid
						update_smithing_ui()
					return
					
		# Tombol E buat keluar
		if event is InputEventKey and event.pressed and event.keycode == KEY_E:
			close_all_menus()
			return
		return
	# --------------------------------------------
	
	if event is InputEventKey and event.pressed and not event.echo:
		# --- BUKA/TUTUP INVENTORY & CHARACTER (B / I) ---
		if event.keycode == KEY_B or event.keycode == KEY_I:
			# Jika ada panel lain yang terbuka, tutup semuanya dulu
			if is_forge_open or is_smelt_open or is_guild_open or is_prep_open or is_smithing_open or is_selling_ui_open or is_storage_ui_open:
				close_all_menus()
				return
			
			if is_inventory_open:
				close_all_menus()
			else:
				close_all_menus()
				is_char_open = true
				is_inventory_open = true
				
				if is_instance_valid(char_panel): char_panel.visible = true
				if is_instance_valid(ui_inventory_panel): ui_inventory_panel.visible = true
				
				update_char_ui()
				update_inventory_ui()
				
				# Freeze player
				if is_instance_valid(player):
					player.set_physics_process(false)
			return
		
		# --- GANTI SENJATA PAKAI ANGKA 1, 2, 3 ---
		if event.keycode in [KEY_1, KEY_2, KEY_3]:
			var _new_slot = event.keycode - KEY_1
			if _new_slot != selected_home_slot:
				selected_home_slot = _new_slot
				sgs_hit_counter = 0
				sgs_accelerate_stacks = 0
				revenger_stacks = 0
				revenger_target = null
				revenger_timer = 0.0
				conductor_charging = false
				conductor_charge_timer = 0.0
				conductor_tick_timer = 0.0
				hammer_charging = false
				hammer_charge_timer = 0.0
				stormjade_charging = false
				stormjade_charge_timer = 0.0
			update_hotbar_ui()
			
		if event.keycode == KEY_E:
			# 1. TUTUP UI JIKA ADA YANG TERBUKA
			if is_forge_open or is_smelt_open or is_inventory_open or is_guild_open or is_prep_open or is_smithing_open:
				close_all_menus()
				return
				
			# --- INTERAKSI MUSIC PLAYER ---
			if can_use_music_player:
				Sfx.play("interact")
				close_all_menus()
				open_music_player_ui()
				player.set_physics_process(false)
				return
				
			# 2. PRIORITAS UTAMA: MIKE (Guild Master)
			if is_instance_valid(guild_master_node) and player.global_position.distance_to(guild_master_node.global_position) < 150.0:
				if Global.tutorial_step == 12:
					Global.tutorial_step = 13
					Global.tutorial_completed = true # Pastikan status tamat
					Global.save_game()
					update_objective_ui()
					
					Sfx.play("interact")
					close_all_menus()
					player.set_physics_process(false)
					
					show_home_dialog("Mike: \"Oh hey you are back!\"")
					await get_tree().create_timer(3.0).timeout
					show_home_dialog("Mike: \"Are you ready for your next adventure? I have some maps for you to explore.\"")
					await get_tree().create_timer(3.5).timeout
					
					# Efek tamat tutorial
					show_floating_text("TUTORIAL COMPLETED!", player.global_position + Vector2(0, -80), Color.GOLD)
					await get_tree().create_timer(1.5).timeout
					
					# Buka menu pilih map
					is_guild_open = true
					guild_panel.visible = true
					update_guild_ui()
				elif Global.tutorial_step >= 13:
					# Kalau udah tamat, klik E di Mike langsung buka map tanpa dialog lagi
					Sfx.play("interact")
					close_all_menus()
					is_guild_open = true
					guild_panel.visible = true
					player.set_physics_process(false)
					update_guild_ui()
				return

			# 4. SMITHING STATION (GAIL)
			if is_instance_valid(smithing_station_node) and player.global_position.distance_to(smithing_station_node.global_position) < 150.0:
				Sfx.play("interact")
				close_all_menus()
				player.set_physics_process(false)
				
				if Global.tutorial_step == 10:
					Global.tutorial_step = 11
					Global.save_game()
					update_objective_ui()
					show_home_dialog("Gail: \"Hello, you can level up your equipment here, just need some gold and scrap then you have it!\"")
					await get_tree().create_timer(4.5).timeout
				
				open_smithing_ui()
				return
			
			# 5. INTERAKSI LAINNYA
			if is_instance_valid(old_miner_node) and Global.tutorial_step >= 1:
				if player.global_position.distance_to(old_miner_node.global_position) < 150.0:
					Sfx.play("interact")
					close_all_menus()
					open_selling_ui()
					player.set_physics_process(false)
					return

			if is_instance_valid(storage_ore_node) and Global.tutorial_step >= 2:
				if player.global_position.distance_to(storage_ore_node.global_position) < 150.0:
					Sfx.play("interact")
					close_all_menus()
					open_storage_ui("ore")
					player.set_physics_process(false)
					return

			if is_instance_valid(storage_weapon_node) and Global.tutorial_step >= 2:
				if player.global_position.distance_to(storage_weapon_node.global_position) < 150.0:
					Sfx.play("interact")
					close_all_menus()
					open_storage_ui("weapon")
					player.set_physics_process(false)
					return
			
			if is_instance_valid(forge_node) and player.global_position.distance_to(forge_node.global_position) < 150.0:
				Sfx.play("interact")
				close_all_menus()
				open_forge_ui()
				player.set_physics_process(false)
				return
				
			if is_instance_valid(smelt_node) and player.global_position.distance_to(smelt_node.global_position) < 150.0:
				Sfx.play("interact")
				close_all_menus()
				open_smelt_ui()
				player.set_physics_process(false)
				return

	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		
		# --- LOGIKA KHUSUS PREP MODE ---
		if is_prep_open:
			# 1. Klik Equipment (Unequip pakai Klik Kiri)
			for slot_idx in range(4):
				if char_slots_panels[slot_idx].get_global_rect().has_point(mouse_pos):
					if event.button_index == MOUSE_BUTTON_LEFT:
						var eq_item = null
						if slot_idx == 3: eq_item = Global.equipped_armor
						else: eq_item = Global.hotbar_items[slot_idx]
						
						if eq_item != null:
							Global.saved_inventory[eq_item] = Global.saved_inventory.get(eq_item, 0) + 1
							if slot_idx == 3: Global.equipped_armor = null
							else: Global.hotbar_items[slot_idx] = null
							
							update_char_ui()
							update_inventory_ui()
							Global.save_game() 
					return
					
			# 2. Klik Backpack
			for i in range(slot_nodes.size()):
				if slot_nodes[i].get_global_rect().has_point(mouse_pos):
					var items = get_backpack_items()
					if i < items.size():
						var item_to_equip = items[i]
						var item_type = item_data.get(item_to_equip, {}).get("weapon_type", "")
						
						# KALAU KLIK KANAN -> EQUIP SENJATA
						if event.button_index == MOUSE_BUTTON_RIGHT:
							var _base_name = Global.get_base_name(item_to_equip)
							if item_type in ["Armor", "Physical Damage", "Elemental Damage", "Magic Damage"]:
								var target_slot = -1
								if item_type == "Armor":
									target_slot = 3
								elif _base_name in ["Stone Pickaxe", "Iron Pickaxe", "Swarmid Drill", "Bonecrusher", "Magic Pickaxe", "Pneumatic Drill"]:
									target_slot = 0
								elif _base_name in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow", "Headhitter Heavy Bow", "Radiance Scepter", "Crystal Minigun", "Heretic Staff"]:
									target_slot = 2
								elif item_type in ["Physical Damage", "Elemental Damage", "Magic Damage"]:
									target_slot = 1
								# ... (rest tidak berubah)
								
								if target_slot != -1:
									var old_item = null
									if target_slot == 3:
										old_item = Global.equipped_armor
										Global.equipped_armor = item_to_equip
									else:
										old_item = Global.hotbar_items[target_slot]
										Global.hotbar_items[target_slot] = item_to_equip
									
									if old_item != null:
										Global.saved_inventory[old_item] = Global.saved_inventory.get(old_item, 0) + 1
									Global.saved_inventory[item_to_equip] -= 1
									if Global.saved_inventory[item_to_equip] <= 0: Global.saved_inventory.erase(item_to_equip)
									
									update_char_ui()
									update_inventory_ui()
									update_hotbar_ui()
									Global.save_game() 
						# KALAU KLIK KIRI -> MASUK STORAGE
						elif event.button_index == MOUSE_BUTTON_LEFT:
							move_to_storage(item_to_equip, 999)
					return
					
			# 3. Klik Storage (Pindah ke Backpack)
			for i in range(storage_slot_nodes.size()):
				if storage_slot_nodes[i].get_global_rect().has_point(mouse_pos):
					if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
						var storage_data = {}
						if active_storage_type == "ore": storage_data = Global.ore_storage
						elif active_storage_type == "material": storage_data = Global.material_storage
						else: storage_data = Global.weapon_storage
						var keys = storage_data.keys()
						if i < keys.size():
							move_to_inventory(keys[i], 999)
					return

			return # <--- Biar klik di background gak nutup panel
		
		# --- TUTUP UI PAKAI KLIK DI LUAR ---
		if is_forge_open and not forge_panel.get_global_rect().has_point(mouse_pos):
			close_all_menus()
			return
		if is_smelt_open and not smelt_panel.get_global_rect().has_point(mouse_pos):
			close_all_menus()
			return
		if is_inventory_open and not char_panel.get_global_rect().has_point(mouse_pos) and not ui_inventory_panel.get_global_rect().has_point(mouse_pos):
			close_all_menus()
			return
		if is_guild_open and not guild_panel.get_global_rect().has_point(mouse_pos):
			close_all_menus()
			return
		
		# --- KLIK TRAINING CHEST ---
		if not is_inventory_open and not is_forge_open and not is_smelt_open and not is_selling_ui_open and not is_storage_ui_open:
			var mouse_world = get_global_mouse_position()
			if is_instance_valid(training_chest_node) and mouse_world.distance_to(training_chest_node.global_position) < 50:
				if player.global_position.distance_to(training_chest_node.global_position) < 200:
					Global.saved_inventory["Practice Arrow"] = 999
					show_floating_text("Got 999 Practice Arrows!", player.global_position, Color.CYAN)
					update_inventory_ui()
					Global.save_game()
					return

		# --- LOGIKA KLIK KANAN (CHARGE BOW) ---
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not is_inventory_open and not is_forge_open and not is_smelt_open and not is_selling_ui_open and not is_storage_ui_open:
				var held = Global.hotbar_items[selected_home_slot]
				if held in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Heretic Staff", "Ricochet Bow", "Sticky Crossbow"]:
					is_charging_home_bow = true
					show_floating_text("Charging...", player.global_position, Color.CYAN)
				elif held == "Galahad Chimelin" and galahad_parry_cd <= 0.0:
					galahad_parry_active = true
					galahad_parry_cd = 3.0
					show_floating_text("PARRY!", player.global_position, Color.GOLD)
					await get_tree().create_timer(0.5).timeout
					galahad_parry_active = false
				elif held == "Crystal Hammer":
					hammer_charging = true
					hammer_charge_timer = 0.0
				elif held == "Stormjade Cutter":
					stormjade_charging = true
					stormjade_charge_timer = 0.0

		# --- LOGIKA STORAGE (ORE / WEAPON / MATERIAL) ---
		if is_storage_ui_open:
			var items_in_backpack = get_backpack_items()
			var storage_data = {}
			if active_storage_type == "ore": storage_data = Global.ore_storage
			elif active_storage_type == "material": storage_data = Global.material_storage
			else: storage_data = Global.weapon_storage
			
			var keys = storage_data.keys()
			
			if event.button_index == MOUSE_BUTTON_LEFT:
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if Global.hotbar_items[i] != null:
							var item = Global.hotbar_items[i]
							move_to_storage(item, 999)
							if Global.saved_inventory.get(item, 0) <= 0:
								Global.hotbar_items[i] = null
								update_hotbar_ui()
						return
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size(): move_to_storage(items_in_backpack[i], 999)
						return
				for i in range(storage_slot_nodes.size()):
					if storage_slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < keys.size(): move_to_inventory(keys[i], 999)
						return
						
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if Global.hotbar_items[i] != null:
							var item = Global.hotbar_items[i]
							move_to_storage(item, 1)
							if Global.saved_inventory.get(item, 0) <= 0:
								Global.hotbar_items[i] = null
								update_hotbar_ui()
						return
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size(): move_to_storage(items_in_backpack[i], 1)
						return
				for i in range(storage_slot_nodes.size()):
					if storage_slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < keys.size(): move_to_inventory(keys[i], 1)
						return
			return

		# --- LOGIKA JUAL BELI (MINER) ---
		if is_selling_ui_open:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if sell_dialog_label.get_global_rect().has_point(mouse_pos) and Global.tutorial_step < 2:
					dialog_step = 0
					sell_dialog_label.text = dialog_texts[dialog_step]
					return

				if dialog_step < dialog_texts.size():
					sell_dialog_label.text = dialog_texts[dialog_step]
					dialog_step += 1
					if dialog_step == dialog_texts.size():
						sell_dialog_label.text = "Old Miner: \"Now, click your items to sell!\""
					return
				
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if Global.hotbar_items[i] != null:
							var item = Global.hotbar_items[i]
							move_to_sell_slot(item, 999)
							if Global.saved_inventory.get(item, 0) <= 0:
								Global.hotbar_items[i] = null
								update_hotbar_ui()
						return
				
				var items_in_backpack = get_backpack_items()
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size(): move_to_sell_slot(items_in_backpack[i], 999)
						return

				for i in range(sell_slot_nodes.size()):
					if sell_slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < sell_data.size() and sell_data[i]["amount"] > 0:
							Global.saved_inventory[sell_data[i]["item"]] = Global.saved_inventory.get(sell_data[i]["item"], 0) + sell_data[i]["amount"]
							sell_data.remove_at(i)
							update_selling_ui()
							update_inventory_ui()
						return

			elif event.button_index == MOUSE_BUTTON_RIGHT:
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if Global.hotbar_items[i] != null:
							var item = Global.hotbar_items[i]
							move_to_sell_slot(item, 1)
							if Global.saved_inventory.get(item, 0) <= 0:
								Global.hotbar_items[i] = null
								update_hotbar_ui()
						return
						
				var items_in_backpack = get_backpack_items()
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size(): move_to_sell_slot(items_in_backpack[i], 1)
						return

		# --- LOGIKA PINDAH BARANG DI DALAM INVENTORY ---
		if is_inventory_open and not is_selling_ui_open and not is_storage_ui_open:
			var clicked_something = false

			# 1. Cek Klik di Slot Karakter (Unequip)
			for slot_idx in range(4):
				if char_slots_panels[slot_idx].get_global_rect().has_point(mouse_pos):
					clicked_something = true
					var eq_item = null
					
					if slot_idx == 3:
						eq_item = Global.equipped_armor
					else:
						eq_item = Global.hotbar_items[slot_idx]
						
					if eq_item != null:
						var eq_uuid = ""
						if slot_idx == 3: 
							eq_uuid = Global.equipped_armor_uuid
						else: 
							eq_uuid = Global.hotbar_uuids[slot_idx]
						
						if eq_uuid != "":
							Global.saved_inventory[eq_uuid] = 1
							
						if slot_idx == 3: 
							Global.equipped_armor = null
							Global.equipped_armor_uuid = ""
						else: 
							Global.hotbar_items[slot_idx] = null
							Global.hotbar_uuids[slot_idx] = null
						update_char_ui()
						update_inventory_ui()
						update_hotbar_ui()
						Global.save_game()
					return

			# 2. Cek Klik di Backpack (Equip)
			if not clicked_something:
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						var items = get_backpack_items()
						if i < items.size():
							var item_to_equip = items[i]
							var _base_name = Global.get_base_name(item_to_equip)
							var item_type = item_data.get(_base_name, {}).get("weapon_type", "")
							
							var target_slot = -1
							if item_type == "Armor": 
								target_slot = 3
							elif _base_name in ["Stone Pickaxe", "Iron Pickaxe", "Swarmid Drill", "Bonecrusher", "Magic Pickaxe", "Pneumatic Drill"]: 
								target_slot = 0
							elif _base_name in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow", "Headhitter Heavy Bow", "Radiance Scepter", "Crystal Minigun", "Heretic Staff"]: 
								target_slot = 2 
							elif item_type in ["Physical Damage", "Elemental Damage", "Magic Damage"]: 
								target_slot = 1 
							
							if target_slot != -1:
								var base_n = Global.get_base_name(item_to_equip)
								var old_uuid = ""
								
								if target_slot == 3:
									old_uuid = Global.equipped_armor_uuid
									Global.equipped_armor = base_n
									Global.equipped_armor_uuid = item_to_equip
								else:
									old_uuid = Global.hotbar_uuids[target_slot]
									Global.hotbar_items[target_slot] = base_n
									Global.hotbar_uuids[target_slot] = item_to_equip
								
								if old_uuid != "" and old_uuid != item_to_equip:
									Global.saved_inventory[old_uuid] = 1
									
								Global.saved_inventory.erase(item_to_equip)
								
								update_char_ui()
								update_inventory_ui()
								update_hotbar_ui()
								Global.save_game()
						break
			return

	if event is InputEventMouseButton and not event.pressed:
		# --- LOGIKA LEPAS KLIK KANAN (TEMBAK CHARGE BOW) ---
		if event.button_index == MOUSE_BUTTON_RIGHT and is_charging_home_bow:
			is_charging_home_bow = false
			if home_attack_cooldown <= 0:
				test_dummy_attack(true)
		
		# --- CRYSTAL HAMMER: charge release ---
		if event.button_index == MOUSE_BUTTON_RIGHT and hammer_charging:
			hammer_charging = false
			if hammer_charge_timer >= 2.0:
				# Stun attack
				if is_instance_valid(dummy_node) and player.global_position.distance_to(dummy_node.global_position) < 200.0:
					var _stun_dmg = int(48 * 1.0)
					combat_dmg_total += _stun_dmg
					combat_hits += 1
					idle_timer = 0.0
					show_floating_text(str(_stun_dmg) + " STUN!", dummy_node.global_position + Vector2(0, -100), Color.CYAN)
					var _t = create_tween()
					_t.tween_property(dummy_node, "position:x", dummy_node.position.x + 15, 0.05)
					_t.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
				home_attack_cooldown = 1.0
			else:
				# Normal attack
				if home_attack_cooldown <= 0:
					test_dummy_attack(false)
			hammer_charge_timer = 0.0

		# --- STORMJADE: charge release ---
		if event.button_index == MOUSE_BUTTON_RIGHT and stormjade_charging:
			stormjade_charging = false
			if stormjade_charge_timer >= 3.0:
				# DASH
				var _dir = (get_global_mouse_position() - player.global_position).normalized()
				var _end = player.global_position + _dir * 128.0
				var _dash_rect = Rect2(player.global_position, _end - player.global_position)
				_dash_rect = _dash_rect.abs().grow(30.0)
				
				# Damage (single dummy di home)
				var _base_dmg = int(25 * 1.5)
				if is_instance_valid(dummy_node) and _dash_rect.has_point(dummy_node.global_position):
					combat_dmg_total += _base_dmg
					combat_hits += 1
					idle_timer = 0.0
					show_floating_text(str(_base_dmg), dummy_node.global_position + Vector2(0, -80), Color.GREEN)
				
				player.global_position = _end
				home_attack_cooldown = 1.0
			else:
				if home_attack_cooldown <= 0:
					test_dummy_attack(false)
			stormjade_charge_timer = 0.0

# ==========================================
# FUNGSI JUAL BELI (MINER)
# ==========================================
func get_backpack_items() -> Array:
	var items = []
	for item_key in Global.saved_inventory.keys():
		if item_key == null: continue
		if not (item_key is String): continue
		if Global.saved_inventory[item_key] <= 0: continue
		
		if Global.is_unique_key(item_key):
			if Global.hotbar_uuids.has(item_key): continue
			if item_key == Global.equipped_armor_uuid: continue
		else:
			if Global.hotbar_items.has(item_key): continue
			if item_key == Global.equipped_armor: continue
		
		items.append(item_key)
	return items

func move_to_sell_slot(item_name, amount_to_move):
	if item_name.begins_with("Blueprint "):
		show_floating_text("Blueprint can't be sold!", player.global_position, Color.RED)
		return
	var have = Global.saved_inventory.get(item_name, 0)
	var move = min(have, amount_to_move)
	if move <= 0: return

	Global.saved_inventory[item_name] -= move
	if Global.saved_inventory[item_name] <= 0: Global.saved_inventory.erase(item_name)

	var added = false
	for i in range(sell_data.size()):
		if sell_data[i]["item"] == item_name:
			sell_data[i]["amount"] += move
			added = true
			break

	if not added and sell_data.size() < 10:
		sell_data.append({"item": item_name, "amount": move})

	update_selling_ui()
	update_inventory_ui()

func bikin_ui_selling(canvas: CanvasLayer):
	sell_panel = Panel.new()
	sell_panel.size = Vector2(500, 450)
	sell_panel.position = Vector2(100, 150)
	sell_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.8, 0.2)
	sell_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(sell_panel)

	sell_dialog_label = Label.new()
	sell_dialog_label.position = Vector2(20, 20)
	sell_dialog_label.size = Vector2(460, 80)
	sell_dialog_label.add_theme_font_size_override("font_size", 18)
	sell_dialog_label.add_theme_color_override("font_color", Color.WHITE)
	sell_panel.add_child(sell_dialog_label)

	var grid = GridContainer.new()
	grid.columns = 5
	grid.position = Vector2(125, 110)
	sell_panel.add_child(grid)

	for i in range(10):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(50, 50)
		var s = StyleBoxFlat.new(); s.bg_color = Color(0.2, 0.2, 0.2)
		s.border_width_left = 1; s.border_width_top = 1; s.border_width_right = 1; s.border_width_bottom = 1
		s.border_color = Color(0.5, 0.5, 0.5)
		slot.add_theme_stylebox_override("panel", s)

		var lbl = Label.new()
		lbl.name = "Label"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_child(lbl)
		grid.add_child(slot)
		sell_slot_nodes.append(slot)

	sell_gold_label = Label.new()
	sell_gold_label.position = Vector2(125, 230)
	sell_gold_label.add_theme_font_size_override("font_size", 20)
	sell_gold_label.add_theme_color_override("font_color", Color.GOLD)
	sell_panel.add_child(sell_gold_label)

	var btn_sell = Button.new()
	btn_sell.text = "SELL"
	btn_sell.add_to_group("no_click_sfx")
	btn_sell.position = Vector2(190, 280)
	btn_sell.size = Vector2(120, 40)
	btn_sell.pressed.connect(func(): execute_sell())
	sell_panel.add_child(btn_sell)

	var btn_close = Button.new()
	btn_close.text = "CLOSE"
	btn_close.position = Vector2(190, 340)
	btn_close.size = Vector2(120, 40)
	btn_close.pressed.connect(func(): close_selling_ui())
	sell_panel.add_child(btn_close)

func open_selling_ui():
	is_selling_ui_open = true
	sell_panel.visible = true
	ui_inventory_panel.visible = true

	if Global.tutorial_step >= 2:
		dialog_step = dialog_texts.size()
		sell_dialog_label.text = "Old Miner: \"Drag and drop your item to sell, click SELL when ready!\""
	else:
		dialog_step = 0
		sell_dialog_label.text = dialog_texts[dialog_step]

	sell_data.clear()
	update_selling_ui()
	update_inventory_ui()

func close_selling_ui():
	# 1. Kembalikan barang yang belum kejual ke tas player
	for data in sell_data:
		Global.saved_inventory[data["item"]] = Global.saved_inventory.get(data["item"], 0) + data["amount"]
	sell_data.clear()
	
	# 2. Update UI dan simpan
	update_inventory_ui()
	Global.save_game()
	
	# 3. TUTUP SEMUA MENU & BIKIN PLAYER BISA GERAK LAGI
	close_all_menus()

func execute_sell():
	var total_gold = 0
	var sold_copper_this_time = 0

	for data in sell_data:
		if data["item"] == "Copper":
			total_gold += data["amount"] * 1
			sold_copper_this_time += data["amount"]
		elif data["item"] == "Iron":
			total_gold += data["amount"] * 2
		elif data["item"] == "Silver":
			total_gold += data["amount"] * 4
		elif data["item"] == "Gold":
			total_gold += data["amount"] * 7
		elif data["item"] == "Mithril":
			total_gold += data["amount"] * 15
		# --- T3 Ores (harga sesuai balancing) ---
		elif data["item"] == "Quartz":
			total_gold += data["amount"] * 10
		elif data["item"] == "Topaz":
			total_gold += data["amount"] * 12
		elif data["item"] == "Emerald":
			total_gold += data["amount"] * 15
		elif data["item"] == "Amethyst":
			total_gold += data["amount"] * 20
		elif data["item"] == "Diamond":
			total_gold += data["amount"] * 30
		elif data["item"] == "Void Crystal":
			total_gold += data["amount"] * 25
		elif data["item"] == "Uberilium":
			total_gold += data["amount"] * 35
		# Scrap TIDAK bisa dijual (crafting material)

	if total_gold > 0:
		Global.gold_coins += total_gold
		ui_gold_label.text = "Gold: " + str(Global.gold_coins)
		Sfx.play("coin")

		var random_index = randi() % thanks_texts.size()
		sell_dialog_label.text = thanks_texts[random_index]
		dialog_step = dialog_texts.size()

		Global.copper_sold += sold_copper_this_time

		if Global.tutorial_step == 1 and Global.copper_sold >= 5:
			Global.tutorial_step = 2
			update_objective_ui()
			show_floating_text("Tutorial step updated!", player.global_position)
		elif Global.tutorial_step == 4 and Global.gold_coins >= 120:
			Global.tutorial_step = 5
			update_objective_ui()
			show_home_dialog("Old Miner: \"Great! Now go to the Smelter and turn that Iron into Bars.\"")
		else:
			update_objective_ui()
			
	# ▼▼▼ TAMBAHKAN BLOK ELSE INI ▼▼▼
	else:
		Sfx.play("error")
		sell_dialog_label.text = "Old Miner: \"You don't have anything to sell, rookie!\""
	# ▲▲▲ CUKUP SAMPAI SINI SAJA ▲▲▲

	# Bagian ini biarkan apa adanya (tidak akan rusak)
	sell_data.clear()
	update_selling_ui()
	update_inventory_ui()
	Global.save_game()

func update_selling_ui():
	for i in range(10):
		if i < sell_data.size():
			sell_slot_nodes[i].get_node("Label").text = sell_data[i]["item"] + "\n(" + str(int(sell_data[i]["amount"])) + ")"
			# FIX #1: pakai get_item_color dengan fallback
			sell_slot_nodes[i].get_node("Label").add_theme_color_override("font_color", get_item_color(sell_data[i]["item"]))
		else:
			sell_slot_nodes[i].get_node("Label").text = ""

	var total_gold = 0
	for data in sell_data:
		if data["item"] == "Copper": total_gold += data["amount"] * 1
		elif data["item"] == "Iron": total_gold += data["amount"] * 2
		elif data["item"] == "Silver": total_gold += data["amount"] * 4
		elif data["item"] == "Gold": total_gold += data["amount"] * 7
		elif data["item"] == "Mithril": total_gold += data["amount"] * 15
		elif data["item"] == "Quartz": total_gold += data["amount"] * 10
		elif data["item"] == "Topaz": total_gold += data["amount"] * 12
		elif data["item"] == "Emerald": total_gold += data["amount"] * 15
		elif data["item"] == "Amethyst": total_gold += data["amount"] * 20
		elif data["item"] == "Diamond": total_gold += data["amount"] * 30
		elif data["item"] == "Void Crystal": total_gold += data["amount"] * 25
		elif data["item"] == "Uberilium": total_gold += data["amount"] * 35

	sell_gold_label.text = "Total Gold: " + str(total_gold)

# ==========================================
# FUNGSI STORAGE (ORE & WEAPON)
# ==========================================
func bikin_ui_storage(canvas: CanvasLayer):
	storage_panel = Panel.new()
	storage_panel.size = Vector2(400, 750)
	storage_panel.position = Vector2(150, 50)
	storage_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.2, 0.6, 1.0)
	storage_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(storage_panel)

	btn_tab_ore = Button.new()
	btn_tab_ore.text = "Ore Storage"
	btn_tab_ore.position = Vector2(20, 20)
	btn_tab_ore.size = Vector2(110, 40)
	btn_tab_ore.pressed.connect(func(): switch_storage_tab("ore"))
	storage_panel.add_child(btn_tab_ore)

	btn_tab_material = Button.new()
	btn_tab_material.text = "Material"
	btn_tab_material.position = Vector2(140, 20)
	btn_tab_material.size = Vector2(110, 40)
	btn_tab_material.pressed.connect(func(): switch_storage_tab("material"))
	storage_panel.add_child(btn_tab_material)

	btn_tab_weapon = Button.new()
	btn_tab_weapon.text = "Weapons"
	btn_tab_weapon.position = Vector2(260, 20)
	btn_tab_weapon.size = Vector2(110, 40)
	btn_tab_weapon.pressed.connect(func(): switch_storage_tab("weapon"))
	storage_panel.add_child(btn_tab_weapon)

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 80)
	scroll.size = Vector2(360, 580)
	storage_panel.add_child(scroll)

	storage_grid = GridContainer.new()
	scroll.add_child(storage_grid)

	var btn_close = Button.new()
	btn_close.text = "CLOSE"
	btn_close.position = Vector2(140, 680)
	btn_close.size = Vector2(120, 40)
	btn_close.pressed.connect(func(): close_storage_ui())
	storage_panel.add_child(btn_close)

# FIX #3: open_storage_ui sekarang cuma delegate ke switch_storage_tab
# (sebelumnya bikin slot dobel karena switch + loop rebuild)
func open_storage_ui(type: String = "ore"):
	is_storage_ui_open = true
	storage_panel.visible = true
	ui_inventory_panel.visible = true
	switch_storage_tab(type)
	update_inventory_ui()

func close_storage_ui():
	close_all_menus()
	is_storage_ui_open = false
	storage_panel.visible = false
	ui_inventory_panel.visible = false

func switch_storage_tab(type: String):
	active_storage_type = type

	# FIX #3: remove_child dulu biar gak dobel visual selama 1 frame
	for child in storage_grid.get_children():
		storage_grid.remove_child(child)
		child.queue_free()
	storage_slot_nodes.clear()

	var max_slots = 0
	if type == "ore":
		storage_grid.columns = 5
		max_slots = 40
		btn_tab_ore.modulate = Color(1, 1, 1, 1)
		btn_tab_material.modulate = Color(0.5, 0.5, 0.5, 1)
		btn_tab_weapon.modulate = Color(0.5, 0.5, 0.5, 1)
	elif type == "material":
		storage_grid.columns = 5
		max_slots = 60
		btn_tab_ore.modulate = Color(0.5, 0.5, 0.5, 1)
		btn_tab_material.modulate = Color(1, 1, 1, 1)
		btn_tab_weapon.modulate = Color(0.5, 0.5, 0.5, 1)
	else:
		storage_grid.columns = 5
		max_slots = 60
		btn_tab_ore.modulate = Color(0.5, 0.5, 0.5, 1)
		btn_tab_material.modulate = Color(0.5, 0.5, 0.5, 1)
		btn_tab_weapon.modulate = Color(1, 1, 1, 1)

	for i in range(max_slots):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(55, 55)
		var s = StyleBoxFlat.new(); s.bg_color = Color(0.2, 0.2, 0.2)
		slot.add_theme_stylebox_override("panel", s)

		var lbl = Label.new()
		lbl.name = "Label"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_child(lbl)

		storage_grid.add_child(slot)
		storage_slot_nodes.append(slot)

	update_storage_ui()

func move_to_storage(item_name, amount_to_move):
	if item_name == "Practice Arrow":
		show_floating_text("Cannot store Practice Arrows!", player.global_position, Color.RED)
		return
	var storage_data = {}
	if active_storage_type == "ore": storage_data = Global.ore_storage
	elif active_storage_type == "material": storage_data = Global.material_storage
	else: storage_data = Global.weapon_storage
	
	# Routing Logic
	if active_storage_type == "ore" and item_name not in ORE_LIST: return
	if active_storage_type == "material" and item_name not in MATERIAL_LIST: return
	if active_storage_type == "weapon" and (item_name in ORE_LIST or item_name in MATERIAL_LIST): return

	var have = Global.saved_inventory.get(item_name, 0)
	var move = min(have, amount_to_move)
	if move <= 0: return

	Global.saved_inventory[item_name] -= move
	if Global.saved_inventory[item_name] <= 0: Global.saved_inventory.erase(item_name)

	storage_data[item_name] = storage_data.get(item_name, 0) + move

	if active_storage_type == "ore" and Global.tutorial_step == 2:
		Global.tutorial_step = 3
		update_objective_ui()
		show_floating_text("Ores stored!", player.global_position)

	update_storage_ui()
	update_inventory_ui()
	update_hotbar_ui()
	Global.save_game()

func move_to_inventory(item_name, amount_to_move):
	# --- PERBAIKAN DI SINI ---
	var storage_data = {}
	if active_storage_type == "ore": storage_data = Global.ore_storage
	elif active_storage_type == "material": storage_data = Global.material_storage
	else: storage_data = Global.weapon_storage
	# -------------------------
	
	var have = storage_data.get(item_name, 0)
	var move = min(have, amount_to_move)
	if move <= 0: return

	storage_data[item_name] -= move
	if storage_data[item_name] <= 0: storage_data.erase(item_name)

	Global.saved_inventory[item_name] = Global.saved_inventory.get(item_name, 0) + move

	update_storage_ui()
	update_inventory_ui()
	update_hotbar_ui()
	Global.save_game()

func update_storage_ui():
	var storage_data = {}
	if active_storage_type == "ore": storage_data = Global.ore_storage
	elif active_storage_type == "material": storage_data = Global.material_storage
	else: storage_data = Global.weapon_storage
	
	var keys = storage_data.keys()

	for i in range(storage_slot_nodes.size()):
		if i < keys.size():
			var item = keys[i]
			storage_slot_nodes[i].get_node("Label").text = item + "\n(" + str(int(storage_data[item])) + ")"
			# FIX #1: pakai get_item_color
			storage_slot_nodes[i].get_node("Label").add_theme_color_override("font_color", get_item_color(item))
		else:
			storage_slot_nodes[i].get_node("Label").text = ""

# ==========================================
# FUNGSI UI LOBBY & LAINNYA
# ==========================================
func show_floating_text(text: String, pos: Vector2, color: Color = Color.WHITE):
	var lbl = Label.new()
	lbl.text = text
	lbl.z_index = 10
	lbl.position = pos + Vector2(-50, -50)
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 4)
	add_child(lbl)
	var tween = create_tween()
	tween.tween_property(lbl, "position:y", lbl.position.y - 40, 1.0)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 1.0)
	tween.finished.connect(func(): lbl.queue_free())

func bikin_ui_lobby(canvas: CanvasLayer):
	var main_container = HBoxContainer.new()
	main_container.position = Vector2(500, 20)
	main_container.add_theme_constant_override("separation", 20)
	canvas.add_child(main_container)

	ui_gold_label = Label.new()
	ui_gold_label.add_theme_font_size_override("font_size", 20)
	ui_gold_label.add_theme_color_override("font_color", Color.GOLD)
	ui_gold_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_gold_label.add_theme_constant_override("outline_size", 4)
	ui_gold_label.text = "Gold: " + str(Global.gold_coins)
	main_container.add_child(ui_gold_label)

	ui_exp_label = Label.new()
	ui_exp_label.add_theme_font_size_override("font_size", 20)
	ui_exp_label.add_theme_color_override("font_color", Color.CYAN)
	ui_exp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_exp_label.add_theme_constant_override("outline_size", 4)
	ui_exp_label.text = Global.player_name + " Lv " + str(Global.player_level) + " | EXP: " + str(Global.player_exp) + "/" + str(Global.exp_to_next_level) + " | Mana: " + str(int(Global.current_mana)) + "/" + str(Global.max_mana)
	ui_exp_label.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_exp_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	ui_exp_label.gui_input.connect(_on_hud_name_clicked)
	main_container.add_child(ui_exp_label)

	var hp_container = HBoxContainer.new()
	hp_container.add_theme_constant_override("separation", 2)
	main_container.add_child(hp_container)
	for i in range(10):
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 24)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.add_theme_constant_override("outline_size", 4)
		if Global.current_hp >= (i + 1) * 10:
			lbl.text = "❤"; lbl.add_theme_color_override("font_color", Color.RED)
		else:
			lbl.text = "♡"; lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hp_container.add_child(lbl)
		heart_labels.append(lbl)

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
		lbl.name = "Label"
		lbl.add_theme_font_size_override("font_size", 12)
		slot.add_child(lbl)
		hb_container.add_child(slot)
		hotbar_ui_labels.append(lbl)

	# PANEL INVENTORY
	ui_inventory_panel = Panel.new()
	ui_inventory_panel.size = Vector2(560, 420)
	ui_inventory_panel.position = Vector2(720, 150)
	ui_inventory_panel.visible = false
	var style2 = StyleBoxFlat.new()
	style2.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style2.border_width_left = 2; style2.border_width_top = 2; style2.border_width_right = 2; style2.border_width_bottom = 2
	style2.border_color = Color(0.5, 0.5, 0.5)
	ui_inventory_panel.add_theme_stylebox_override("panel", style2)
	canvas.add_child(ui_inventory_panel)

	var inv_title = Label.new()
	inv_title.text = "BACKPACK"
	inv_title.position = Vector2(15, 10)
	inv_title.add_theme_font_size_override("font_size", 20)
	ui_inventory_panel.add_child(inv_title)

	var inv_hb_row = HBoxContainer.new()
	inv_hb_row.position = Vector2(15, 45)
	inv_hb_row.add_theme_constant_override("separation", 5)
	ui_inventory_panel.add_child(inv_hb_row)

	for i in range(7):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(50, 50)
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
		lbl.add_theme_font_size_override("font_size", 10)
		slot.add_child(lbl)

		var num_lbl = Label.new()
		num_lbl.text = str(i + 1)
		num_lbl.position = Vector2(2, -2)
		num_lbl.add_theme_font_size_override("font_size", 10)
		slot.add_child(num_lbl)

		inv_hb_row.add_child(slot)
		inv_hotbar_slots.append(slot)

	var grid = GridContainer.new()
	grid.columns = 10
	grid.position = Vector2(15, 110)
	ui_inventory_panel.add_child(grid)
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
		icon.size = Vector2(30, 30); icon.position = Vector2(10, 10)
		icon.visible = false; icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		slot_nodes.append(slot)

		# --- CHAR PANEL (Sejajar dengan Backpack) ---
	char_panel = Panel.new()
	char_panel.size = Vector2(500, 460) # Tinggi pas untuk karakter & slot
	char_panel.position = Vector2(100, 150) # <-- DISAMAKAN DENGAN BACKPACK (Y=150)
	char_panel.visible = false
	var style3 = StyleBoxFlat.new()
	style3.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style3.border_width_left = 2; style3.border_width_top = 2; style3.border_width_right = 2; style3.border_width_bottom = 2
	style3.border_color = Color(0.5, 0.5, 0.5)
	char_panel.add_theme_stylebox_override("panel", style3)
	canvas.add_child(char_panel)

	var title = Label.new()
	title.text = "Equipment"; title.position = Vector2(20, 15); title.add_theme_font_size_override("font_size", 24)
	char_panel.add_child(title)

	# --- 1. SLOT ARMOR ---
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
	armor_lbl.position = Vector2(0, 0)
	armor_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	armor_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	armor_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	armor_lbl.text = "Armor"
	armor_lbl.add_theme_font_size_override("font_size", 12)
	armor_slot.add_child(armor_lbl)
	
	armor_slot.mouse_entered.connect(func(): show_char_hover(3, true))
	armor_slot.mouse_exited.connect(func(): show_char_hover(3, false))

	# --- 2. GAMBAR KARAKTER ---
	var body_visual = ColorRect.new()
	body_visual.size = Vector2(64, 128); body_visual.position = Vector2(218, 150); body_visual.color = Color(0.0, 1.0, 1.0)
	char_panel.add_child(body_visual)

	# --- 3. SLOT SENJATA ---
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
		lbl.position = Vector2(0, 0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		lbl.text = slot_names[i]
		lbl.add_theme_font_size_override("font_size", 12)
		s.add_child(lbl); char_slot_labels.append(lbl)

		s.mouse_entered.connect(func(): show_char_hover(i, true))
		s.mouse_exited.connect(func(): show_char_hover(i, false))
		
		char_slots_panels.append(s)
		
	# Tambahkan armor ke urutan paling akhir (Index 3)
	char_slot_labels.append(armor_lbl)
	char_slots_panels.append(armor_slot)

	# --- 5. PANEL MELAYANG (HOVER) ---
	char_hover_panel = Panel.new()
	char_hover_panel.size = Vector2(480, 440) # Diperbesar
	char_hover_panel.position = Vector2(10, 400) # Posisi tepat di bawah slot senjata
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

	# --- EMBLEM SLOTS (Diturunkan Jauh) ---
	var emblem_title = Label.new()
	emblem_title.name = "EmblemTitle"
	emblem_title.text = "Emblems (Coming Soon)"
	emblem_title.position = Vector2(20, 350) # <-- DITURUNKAN JAUH KE Y=350
	emblem_title.add_theme_font_size_override("font_size", 14)
	emblem_title.add_theme_color_override("font_color", Color.GRAY)
	char_hover_panel.add_child(emblem_title)

	var emblem_container = HBoxContainer.new()
	emblem_container.name = "EmblemSlots"
	emblem_container.position = Vector2(150, 380) # <-- KOTAK DITURUNKAN KE Y=380
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
		
	# --- RENAME PANEL ---
	rename_panel = Panel.new()
	rename_panel.size = Vector2(400, 150)
	rename_panel.position = Vector2(376, 250)
	rename_panel.visible = false
	var r_style = StyleBoxFlat.new()
	r_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	r_style.border_width_left = 2; r_style.border_width_top = 2; r_style.border_width_right = 2; r_style.border_width_bottom = 2
	r_style.border_color = Color.CYAN
	rename_panel.add_theme_stylebox_override("panel", r_style)
	canvas.add_child(rename_panel)
	
	var r_title = Label.new()
	r_title.text = "Change Your Name"
	r_title.position = Vector2(20, 15)
	r_title.add_theme_font_size_override("font_size", 20)
	rename_panel.add_child(r_title)
	
	rename_input = LineEdit.new()
	rename_input.position = Vector2(20, 50)
	rename_input.size = Vector2(360, 40)
	rename_input.max_length = 20 # MAKSIMAL 20 KARAKTER
	rename_panel.add_child(rename_input)
	
	var r_btn = Button.new()
	r_btn.text = "Confirm"
	r_btn.position = Vector2(140, 100)
	r_btn.size = Vector2(120, 30)
	r_btn.pressed.connect(_on_rename_confirm)
	rename_panel.add_child(r_btn)
	# --------------------
	
	# --- PAUSE MENU HOME ---
	pause_panel_home = Panel.new()
	pause_panel_home.size = Vector2(300, 350)
	pause_panel_home.position = Vector2(get_viewport().get_visible_rect().size.x/2 - 150, get_viewport().get_visible_rect().size.y/2 - 175)
	pause_panel_home.visible = false
	pause_panel_home.z_index = 100
	var p_style = StyleBoxFlat.new(); p_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	p_style.border_width_left = 2; p_style.border_width_top = 2; p_style.border_width_right = 2; p_style.border_width_bottom = 2
	p_style.border_color = Color.GOLD
	pause_panel_home.add_theme_stylebox_override("panel", p_style)
	add_child(pause_panel_home) # Ditambah ke root, bukan canvas, biar gampang di-pause
	
	var p_title = Label.new(); p_title.text = "PAUSED"; p_title.position = Vector2(0, 20); p_title.size = Vector2(300, 40)
	p_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; p_title.add_theme_font_size_override("font_size", 28)
	pause_panel_home.add_child(p_title)
	
	var b_cont = Button.new(); b_cont.text = "Continue"; b_cont.position = Vector2(50, 80); b_cont.size = Vector2(200, 50)
	b_cont.pressed.connect(func(): 
		is_pause_home_open = false
		pause_panel_home.visible = false
		get_tree().paused = false
		player.set_physics_process(true)
	)
	pause_panel_home.add_child(b_cont)
	
	var b_set = Button.new(); b_set.text = "Settings (Coming Soon)"; b_set.position = Vector2(50, 150); b_set.size = Vector2(200, 50); b_set.disabled = true
	pause_panel_home.add_child(b_set)
	
	var b_quit = Button.new(); b_quit.text = "Quit to Main Menu"; b_quit.position = Vector2(50, 230); b_quit.size = Vector2(200, 50)
	b_quit.pressed.connect(func():
		Global.save_game()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
	)
	pause_panel_home.add_child(b_quit)
	
func update_hotbar_ui():
	for i in range(7):
		var item = Global.hotbar_items[i]
		var lbl = hotbar_ui_labels[i]
		if item != null:
			var is_equipment = item_data.get(item, {}).has("weapon_type") or item in ["Fist", "Stone Pickaxe", "Bow"]
			
			if is_equipment:
				var lv = Global.get_item_level(item, Global.hotbar_uuids[i])
				lbl.text = item + "\nLv. " + str(lv)
			else:
				var amount = Global.saved_inventory.get(item, 0)
				lbl.text = item + "\n(" + str(int(amount)) + ")"
				
			lbl.add_theme_color_override("font_color", get_item_color(item))
		else:
			lbl.text = ""
			
		var slot_panel = lbl.get_parent()
		if i == selected_home_slot:
			slot_panel.get_theme_stylebox("panel").border_color = Color.YELLOW
		else:
			slot_panel.get_theme_stylebox("panel").border_color = Color(0.5, 0.5, 0.5)

func update_inventory_ui():
	var items_in_backpack = get_backpack_items()
	for i in range(slot_nodes.size()):
		slot_nodes[i].tooltip_text = ""
		slot_nodes[i].get_node("Icon").visible = false
		slot_nodes[i].get_node("AmountLabel").text = ""

	for i in range(min(items_in_backpack.size(), 50)):
		var item_key = items_in_backpack[i]
		var item_name = Global.get_base_name(item_key)
		var amount = Global.saved_inventory[item_key]
		
		if item_name.begins_with("Blueprint "):
			var _bp_data = item_data.get(item_name, {})
			slot_nodes[i].tooltip_text = item_name + "\n" + str(_bp_data.get("desc", ""))
		else:
			slot_nodes[i].tooltip_text = item_name
			
		var icon = slot_nodes[i].get_node("Icon")
		icon.color = get_item_color(item_name)
		icon.visible = true
		
		if Global.is_unique_key(item_key):
			slot_nodes[i].get_node("AmountLabel").text = ""
		else:
			slot_nodes[i].get_node("AmountLabel").text = str(int(amount))

	for i in range(7):
		var item = Global.hotbar_items[i]
		var lbl = inv_hotbar_slots[i].get_node("Label")
		if item != null:
			lbl.text = item
			lbl.add_theme_color_override("font_color", get_item_color(item))
		else:
			lbl.text = ""

func update_char_ui():
	for i in range(3):
		if Global.hotbar_items[i] != null:
			var item = Global.hotbar_items[i]
			var lv = Global.get_item_level(item, Global.hotbar_uuids[i])
			char_slot_labels[i].text = item + "\nLv. " + str(lv)
		else:
			char_slot_labels[i].text = "Empty"
			
	if Global.equipped_armor != null:
		var item = Global.equipped_armor
		var lv = Global.get_item_level(item, Global.equipped_armor_uuid)
		char_slot_labels[3].text = item + "\nLv. " + str(lv)
	else:
		char_slot_labels[3].text = "Empty"

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
		# Sembunyikan Emblem kalau kosong
		char_hover_panel.get_node("EmblemTitle").visible = false
		char_hover_panel.get_node("EmblemSlots").visible = false
		return
		
	# Tampilkan Emblem kalau ada senjatanya
	char_hover_panel.get_node("EmblemTitle").visible = true
	char_hover_panel.get_node("EmblemSlots").visible = true
	
	var _uid = Global.equipped_armor_uuid if index == 3 else Global.hotbar_uuids[index]
	var data = Global.get_effective_stats(item, item_data.get(item, {}), _uid)
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

func craft_weapon(weapon_name: String):
	var can_craft = false
	var parts_needed = []

	if weapon_name == "Menacing Dagger":
		parts_needed = ["Dagger Part 💀", "Dagger Part ⛏️", "Dagger Part ⚔️"]
	elif weapon_name == "Maniacal Chainsaw":
		parts_needed = ["Chainsaw Part 💀", "Chainsaw Part ⛏️", "Chainsaw Part ⚔️"]

	can_craft = true
	for part in parts_needed:
		if Global.saved_inventory.get(part, 0) <= 0:
			can_craft = false
			break

	if can_craft:
		for part in parts_needed:
			Global.saved_inventory[part] -= 1
			if Global.saved_inventory[part] <= 0:
				Global.saved_inventory.erase(part)

		Global.saved_inventory[weapon_name] = Global.saved_inventory.get(weapon_name, 0) + 1
		Sfx.play("coin")

		show_floating_text(weapon_name + " Crafted!", player.global_position, Color.GOLD)
		update_inventory_ui()
		open_forge_ui()
	else:
		# FIX: typo show_floatinga_text -> show_floating_text
		show_floating_text("You need 3 different parts!", player.global_position, Color.RED)

func spawn_stations():
	# 1. Bangunan Forge (Warna Oranye) - Digeser ke kanan
	forge_node = Node2D.new()
	forge_node.position = Vector2(650, 180) # <--- Ubah X dari 300 ke 650
	forge_node.z_index = -1
	var f_visual = ColorRect.new()
	f_visual.size = Vector2(80, 100)
	f_visual.position = Vector2(-40, -100)
	f_visual.color = Color(0.8, 0.3, 0.1) 
	forge_node.add_child(f_visual)
	var f_text = Label.new(); f_text.text = "FORGE"; f_text.position = Vector2(-15, -50)
	forge_node.add_child(f_text)
	add_child(forge_node)
	
	# 2. Bangunan Smelter (Warna Abu-abu Gelap) - Digeser lebih kanan lagi
	smelt_node = Node2D.new()
	smelt_node.position = Vector2(850, 180) # <--- Ubah X dari 450 ke 850
	smelt_node.z_index = -1
	var s_visual = ColorRect.new()
	s_visual.size = Vector2(80, 120)
	s_visual.position = Vector2(-40, -120)
	s_visual.color = Color(0.3, 0.3, 0.35) 
	smelt_node.add_child(s_visual)
	var s_text = Label.new(); s_text.text = "SMELTER"; s_text.position = Vector2(-25, -60)
	smelt_node.add_child(s_text)
	add_child(smelt_node)
	
	# Spawn Smithing Station & Gail
	smithing_station_node = Node2D.new()
	smithing_station_node.position = Vector2(1450, 180) # Sebelah kanan dummy
	smithing_station_node.z_index = -1
	var sv = ColorRect.new()
	sv.size = Vector2(100, 120); sv.position = Vector2(-50, -120); sv.color = Color(0.2, 0.2, 0.25)
	smithing_station_node.add_child(sv)
	var st = Label.new(); st.text = "SMITHING\nSTATION"; st.position = Vector2(-30, -60)
	smithing_station_node.add_child(st)
	add_child(smithing_station_node)
	
	gail_node = Node2D.new()
	gail_node.position = Vector2(1350, 180) # Sebelah kiri station
	gail_node.z_index = -1
	var gv = ColorRect.new()
	gv.size = Vector2(32, 48); gv.position = Vector2(-16, -48); gv.color = Color(0.8, 0.4, 0.6)
	gail_node.add_child(gv)
	var glbl = Label.new(); glbl.text = "Gail"; glbl.position = Vector2(-15, -65); glbl.add_theme_color_override("font_color", Color.GOLD)
	gail_node.add_child(glbl)
	add_child(gail_node)

var forge_item_grid: GridContainer
var forge_slot_label: Label
var forge_recipe_label: RichTextLabel
var forge_action_btn: Button
var btn_tab_forge: Button
var btn_tab_craft: Button
var btn_tab_blueprint: Button
var forge_info_btn: Button

# Variabel Preview Kanan
var forge_preview_panel: Panel
var forge_preview_name: Label
var forge_preview_icon: ColorRect
var forge_preview_stats: Label

func bikin_ui_forge(canvas: CanvasLayer):
	forge_panel = Panel.new()
	# PERLEBAR PANEL (dari 850 jadi 1050)
	forge_panel.size = Vector2(1050, 620) 
	forge_panel.position = Vector2(50, 50)
	forge_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.3, 0.1)
	forge_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(forge_panel)
	
	var title = Label.new(); title.text = "Forge"
	title.position = Vector2(20, 20); title.add_theme_font_size_override("font_size", 24)
	forge_panel.add_child(title)
	
	var subtitle = Label.new(); subtitle.text = "choose what you want to forge!"
	subtitle.position = Vector2(20, 50); subtitle.add_theme_font_size_override("font_size", 16)
	forge_panel.add_child(subtitle)
	
	# --- TABS ---
	btn_tab_forge = Button.new(); btn_tab_forge.text = "FORGE"
	btn_tab_forge.position = Vector2(20, 85); btn_tab_forge.size = Vector2(100, 40)
	btn_tab_forge.pressed.connect(func(): switch_forge_tab("forge"))
	forge_panel.add_child(btn_tab_forge)
	
	btn_tab_craft = Button.new(); btn_tab_craft.text = "CRAFT (Parts)"
	btn_tab_craft.position = Vector2(130, 85); btn_tab_craft.size = Vector2(120, 40)
	btn_tab_craft.pressed.connect(func(): switch_forge_tab("craft"))
	forge_panel.add_child(btn_tab_craft)
		
	btn_tab_blueprint = Button.new(); btn_tab_blueprint.text = "BLUEPRINT"
	btn_tab_blueprint.position = Vector2(260, 85); btn_tab_blueprint.size = Vector2(120, 40)
	btn_tab_blueprint.pressed.connect(func(): switch_forge_tab("blueprint"))
	forge_panel.add_child(btn_tab_blueprint)
	
	# --- KOLOM KIRI (Grid Item) ---
	forge_item_grid = GridContainer.new()
	forge_item_grid.columns = 2
	forge_item_grid.position = Vector2(20, 140)
	forge_panel.add_child(forge_item_grid)
	
	# --- KOLOM TENGAH (Resep & Tombol) ---
	var mid_panel = Panel.new()
	mid_panel.size = Vector2(250, 450); mid_panel.position = Vector2(350, 140) # Geser ke kanan
	var ms = StyleBoxFlat.new(); ms.bg_color = Color(0.15, 0.15, 0.15)
	mid_panel.add_theme_stylebox_override("panel", ms)
	forge_panel.add_child(mid_panel)
	
	forge_slot_label = Label.new(); forge_slot_label.position = Vector2(15, 15)
	forge_slot_label.add_theme_font_size_override("font_size", 18)
	mid_panel.add_child(forge_slot_label)
	
	forge_recipe_label = RichTextLabel.new(); forge_recipe_label.position = Vector2(15, 60)
	forge_recipe_label.size = Vector2(220, 300)
	forge_recipe_label.bbcode_enabled = true
	forge_recipe_label.add_theme_font_size_override("normal_font_size", 15)
	mid_panel.add_child(forge_recipe_label)
	
	forge_action_btn = Button.new()
	forge_action_btn.position = Vector2(25, 380); forge_action_btn.size = Vector2(200, 50)
	forge_action_btn.pressed.connect(func(): do_forge())
	mid_panel.add_child(forge_action_btn)
	
	# --- KOLOM KANAN (Preview Item) ---
	forge_preview_panel = Panel.new()
	# Lebih lebar & geser ke kanan
	forge_preview_panel.size = Vector2(380, 450); forge_preview_panel.position = Vector2(620, 140)
	var ps = StyleBoxFlat.new(); ps.bg_color = Color(0.15, 0.15, 0.15)
	ps.border_width_left = 2; ps.border_width_top = 2; ps.border_width_right = 2; ps.border_width_bottom = 2
	ps.border_color = Color(0.3, 0.3, 0.3)
	forge_preview_panel.add_theme_stylebox_override("panel", ps)
	forge_panel.add_child(forge_preview_panel)
	
	forge_preview_name = Label.new(); forge_preview_name.position = Vector2(15, 15)
	forge_preview_name.add_theme_font_size_override("font_size", 20)
	forge_preview_name.add_theme_color_override("font_color", Color.GOLD)
	forge_preview_panel.add_child(forge_preview_name)
	
	forge_preview_icon = ColorRect.new()
	forge_preview_icon.size = Vector2(80, 80); forge_preview_icon.position = Vector2(15, 50)
	forge_preview_panel.add_child(forge_preview_icon)
	
	forge_preview_rarity = Label.new(); forge_preview_rarity.position = Vector2(15, 145)
	forge_preview_rarity.add_theme_font_size_override("font_size", 16)
	forge_preview_rarity.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	forge_preview_panel.add_child(forge_preview_rarity)
	
	forge_preview_stats = Label.new(); forge_preview_stats.position = Vector2(15, 175)
	forge_preview_stats.size = Vector2(340, 290)
	forge_preview_stats.add_theme_font_size_override("font_size", 15)
	forge_preview_stats.autowrap_mode = TextServer.AUTOWRAP_WORD
	forge_preview_panel.add_child(forge_preview_stats)

func open_forge_ui():
	is_forge_open = true
	forge_panel.visible = true
	forge_tab = "forge"
	forge_selected_item = ""
	update_forge_ui()

func switch_forge_tab(tab):
	forge_tab = tab
	forge_selected_item = ""
	update_forge_ui()

func update_forge_ui():
	for child in forge_item_grid.get_children(): child.queue_free()
	
	btn_tab_forge.modulate = Color(1,1,1,1) if forge_tab == "forge" else Color(0.5,0.5,0.5,1)
	btn_tab_craft.modulate = Color(1,1,1,1) if forge_tab == "craft" else Color(0.5,0.5,0.5,1)
	btn_tab_blueprint.modulate = Color(1,1,1,1) if forge_tab == "blueprint" else Color(0.5,0.5,0.5,1)
	
	# --- BLUEPRINT TAB: show unlockable blueprints ---
	if forge_tab == "blueprint":
		var _any_shown = false
		var _all_bps = {}
		# Kumpulkan dari semua sumber
		for _src in [Global.saved_inventory, Global.material_storage]:
			for _item in _src.keys():
				if _item.begins_with("Blueprint ") and item_data.get(_item, {}).has("blueprint_for"):
					_all_bps[_item] = _src
		
		for _item in _all_bps.keys():
			var _bp_weapon = item_data[_item].get("blueprint_for", "")
			if _bp_weapon != "" and _bp_weapon not in Global.unlocked_blueprints:
				_any_shown = true
				var _btn = Button.new()
				_btn.custom_minimum_size = Vector2(200, 40)
				_btn.text = "Unlock: " + _bp_weapon
				_btn.pressed.connect(_on_unlock_blueprint.bind(_item, _bp_weapon))
				forge_item_grid.add_child(_btn)
		
		if not _any_shown:
			forge_slot_label.text = "No blueprints"
			forge_recipe_label.text = "Get blueprints from domain minions."
		else:
			forge_slot_label.text = "Click to unlock"
			forge_recipe_label.text = "Blueprint unlocks new recipe at the Forge."
		forge_action_btn.disabled = true
		forge_action_btn.text = "UNLOCK"
		forge_preview_name.text = ""
		forge_preview_rarity.text = ""
		forge_preview_icon.visible = false
		forge_preview_stats.text = ""
		return
	# ----------------------------------------------
		
	var recipes = []
	if forge_tab == "forge":
		recipes = ["Iron Armor", "Iron Sword", "Iron Pickaxe", "Iron Bow", "Broken Tools"]
		# Add unlocked blueprint weapons
		for _bp_weapon in Global.unlocked_blueprints:
			if _bp_weapon not in recipes:
				recipes.append(_bp_weapon)
	else:
		recipes = ["Menacing Dagger", "Maniacal Chainsaw", "Hunter Bow", "Heretic Staff"]
		# T3 crafted weapons: muncul kalau player PUNYA part T3 (bukan berdasarkan step)
		var _has_t3_part = false
		for _p in ["Mourning Bow Part 💀", "Mourning Bow Part ⛏️", "Mourning Bow Part ⚔️",
				   "Crystal Minigun Part 💀", "Crystal Minigun Part ⛏️", "Crystal Minigun Part ⚔️",
				   "Crystal Armor Part 💀", "Crystal Armor Part ⛏️", "Crystal Armor Part ⚔️"]:
			if get_total_item_count(_p) > 0:
				_has_t3_part = true
				break
		if _has_t3_part:
			recipes.append_array(["Mourning Bow", "Crystal Minigun", "Crystal Armor"])
		
	for item in recipes:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(150, 40)
		btn.text = item
		
		if Global.tutorial_step == 6 and forge_tab == "forge" and item != "Iron Armor":
			btn.disabled = true
		else:
			btn.pressed.connect(func(): select_forge_item(item))
		forge_item_grid.add_child(btn)
		
	if forge_selected_item == "":
		forge_slot_label.text = "[ Empty Slot ]"
		forge_recipe_label.text = "Select an item."
		forge_action_btn.disabled = true
		forge_action_btn.text = "FORGE"
		forge_preview_name.text = ""
		forge_preview_rarity.text = ""
		forge_preview_icon.visible = false
		forge_preview_stats.text = ""
		return

	forge_slot_label.text = "Forge: " + forge_selected_item
	var data = item_data.get(forge_selected_item, {})
	
	var can_craft = true
	var recipe_text = "Recipe:\n"
	
	# --- WARNA MERAH / PUTIH INTERAKTIF (FORGE) ---
	if forge_tab == "forge":
		var cost = data.get("craft_cost", 0)
		var recipe = data.get("craft_recipe", {})
		
		for mat in recipe.keys():
			var req = recipe[mat]
			var have = get_total_item_count(mat)
			var color = "red" if have < req else "white"
			if have < req: can_craft = false
			recipe_text += "[color=" + color + "]" + str(req) + "x " + mat + " (" + str(int(have)) + ")[/color]\n"
			
		var gold_color = "red" if Global.gold_coins < cost else "white"
		if Global.gold_coins < cost: can_craft = false
		recipe_text += "\n[color=" + gold_color + "]Cost: " + str(cost) + " Gold[/color]"
		
		forge_recipe_label.text = recipe_text
		forge_action_btn.text = "FORGE (" + str(cost) + " G)"
		
	# --- WARNA MERAH / PUTIH INTERAKTIF (CRAFT) ---
	else:
		var parts = []
		if forge_selected_item == "Menacing Dagger":
			parts = ["Dagger Part 💀", "Dagger Part ⛏️", "Dagger Part ⚔️"]
		elif forge_selected_item == "Maniacal Chainsaw":
			parts = ["Chainsaw Part 💀", "Chainsaw Part ⛏️", "Chainsaw Part ⚔️"]
		elif forge_selected_item == "Hunter Bow":
			parts = ["Hunter Bow Part 💀", "Hunter Bow Part ⛏️", "Hunter Bow Part ⚔️"]
		elif forge_selected_item == "Heretic Staff":
			parts = ["Heretic Staff Part 💀", "Heretic Staff Part ⛏️", "Heretic Staff Part ⚔️"]
		elif forge_selected_item == "Mourning Bow":
			parts = ["Mourning Bow Part 💀", "Mourning Bow Part ⛏️", "Mourning Bow Part ⚔️"]
		elif forge_selected_item == "Crystal Minigun":
			parts = ["Crystal Minigun Part 💀", "Crystal Minigun Part ⛏️", "Crystal Minigun Part ⚔️"]
		elif forge_selected_item == "Crystal Armor":
			parts = ["Crystal Armor Part 💀", "Crystal Armor Part ⛏️", "Crystal Armor Part ⚔️"]
		
		for part in parts:
			var have = get_part_count(part)
			var color = "red" if have < 1 else "white"
			if have < 1: can_craft = false
			recipe_text += "[color=" + color + "]1x " + part + " (" + str(int(have)) + ")[/color]\n"
			
		var cost = data.get("craft_cost", 0)
		var gold_color = "red" if Global.gold_coins < cost else "white"
		if Global.gold_coins < cost: can_craft = false
		recipe_text += "\n[color=" + gold_color + "]Cost: " + str(cost) + " Gold[/color]"
			
		forge_recipe_label.text = recipe_text
		forge_action_btn.text = "CRAFT (" + str(cost) + " G)"
		
	# Disable tombol kalau ada yang kurang
	if not can_craft:
		forge_action_btn.disabled = true
	else:
		forge_action_btn.disabled = false

	# --- UPDATE UI KANAN (PREVIEW STATS LENGKAP + RARITY) ---
	forge_preview_name.text = forge_selected_item
	forge_preview_icon.visible = true
	forge_preview_icon.color = data.get("color", Color.WHITE)
	
	# Rarity Logic
	var rarity = data.get("rarity", "Common")
	forge_preview_rarity.text = "Rarity: " + rarity
	if rarity == "Rare":
		forge_preview_rarity.add_theme_color_override("font_color", Color.CYAN)
	elif rarity == "Epic":
		forge_preview_rarity.add_theme_color_override("font_color", Color.MEDIUM_PURPLE)
	else:
		forge_preview_rarity.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	
	var stats_text = "Type: " + str(data.get("weapon_type", "None")) + "\n"
	var trait_str = str(data.get("trait", ""))
	
	if trait_str != "":
		stats_text += "Trait: " + trait_str + "\n"
		
	stats_text += "\n"
	
	# Tampilkan Stats khusus Armor
	if str(data.get("weapon_type", "")) == "Armor":
		stats_text += "Damage Reduction: " + str(data.get("damage_reduction", 0)) + "\n"
	else:
		# Tampilkan Stats Senjata
		var atk = data.get("damage", 0)
		if data.has("charge_damage"):
			atk = str(atk) + " (Charge: " + str(data["charge_damage"]) + ")"
		stats_text += "ATK: " + str(atk) + "\n"
		
		var rng = data.get("range", 0)
		stats_text += "Range: " + str(int(rng / 16.0)) + " blocks\n"
		
		var spd = data.get("attack_speed", 0)
		if data.has("charge_speed"):
			spd = str(spd) + "s (Charge: " + str(data["charge_speed"]) + "s)"
		else:
			spd = str(spd) + "s"
		stats_text += "Speed: " + spd + "\n"
		
		if data.has("efficiency"): 
			stats_text += "Efficiency: " + str(data["efficiency"]) + "\n"
		if data.has("mana_cost"): 
			stats_text += "Mana: " + str(data["mana_cost"]) + "\n"
		
	stats_text += "\nPassive:\n" + str(data.get("passive", "None"))
	forge_preview_stats.text = stats_text

func select_forge_item(item):
	forge_selected_item = item
	update_forge_ui()

func do_forge():
	var data = item_data.get(forge_selected_item, {})
	var success = false
	
	if forge_tab == "forge":
		var cost = data.get("craft_cost", 0)
		var recipe = data.get("craft_recipe", {})
		if Global.gold_coins >= cost:
			Global.gold_coins -= cost
			ui_gold_label.text = "Gold: " + str(Global.gold_coins)
			for mat in recipe.keys():
				remove_item_from_all(mat, recipe[mat])
			success = true
	else:
		var parts = []
		if forge_selected_item == "Menacing Dagger":
			parts = ["Dagger Part 💀", "Dagger Part ⛏️", "Dagger Part ⚔️"]
		elif forge_selected_item == "Maniacal Chainsaw":
			parts = ["Chainsaw Part 💀", "Chainsaw Part ⛏️", "Chainsaw Part ⚔️"]
		elif forge_selected_item == "Hunter Bow":
			parts = ["Hunter Bow Part 💀", "Hunter Bow Part ⛏️", "Hunter Bow Part ⚔️"]
		elif forge_selected_item == "Heretic Staff":
			parts = ["Heretic Staff Part 💀", "Heretic Staff Part ⛏️", "Heretic Staff Part ⚔️"]
		elif forge_selected_item == "Mourning Bow":
			parts = ["Mourning Bow Part 💀", "Mourning Bow Part ⛏️", "Mourning Bow Part ⚔️"]
		elif forge_selected_item == "Crystal Minigun":
			parts = ["Crystal Minigun Part 💀", "Crystal Minigun Part ⛏️", "Crystal Minigun Part ⚔️"]
		elif forge_selected_item == "Crystal Armor":
			parts = ["Crystal Armor Part 💀", "Crystal Armor Part ⛏️", "Crystal Armor Part ⚔️"]
			
		var cost = data.get("craft_cost", 0)
		if Global.gold_coins >= cost:
			Global.gold_coins -= cost
			ui_gold_label.text = "Gold: " + str(Global.gold_coins)
			for part in parts:
				remove_part(part) # <--- UBAH BARIS INI
			success = true
		
	if success:
		if forge_selected_item == "Broken Tools":
			show_home_dialog("Repair logic coming soon! (Gold deducted)")
		else:
			Global.saved_inventory[forge_selected_item] = Global.saved_inventory.get(forge_selected_item, 0) + 1
		show_floating_text(forge_selected_item + " Crafted!", player.global_position, Color.GOLD)
		
		if Global.tutorial_step == 6 and forge_selected_item == "Iron Armor":
			Global.tutorial_step = 7
			update_objective_ui()
			show_home_dialog("Armor crafted! You are ready to enter the Crystaline Caverns.")
			
		forge_selected_item = ""
		update_forge_ui()
		update_inventory_ui()
		Global.save_game()
	
func close_forge_ui():
	close_all_menus()
	is_forge_open = false
	forge_panel.visible = false

func _on_unlock_blueprint(bp_item, weapon_name):
	if weapon_name in Global.unlocked_blueprints: return
	# Coba hapus dari backpack dulu, lalu storage
	if Global.saved_inventory.has(bp_item):
		Global.saved_inventory.erase(bp_item)
	elif Global.material_storage.has(bp_item):
		Global.material_storage.erase(bp_item)
	else:
		return
	Global.unlocked_blueprints.append(weapon_name)
	Global.save_game()
	show_floating_text("Unlocked: " + weapon_name, player.global_position, Color.GOLD)
	update_forge_ui()
	update_inventory_ui()
	update_storage_ui()

var smelt_item_grid: GridContainer
var smelt_slot_label: Label
var smelt_recipe_label: Label
var smelt_button: Button
var smelt_max_button: Button

func get_smelt_cost(ore_name):
	match ore_name:
		"Silver", "Gold": return 2
		"Mithril": return 4
		# --- T3 Ores (Amethyst & Diamond sengaja tidak ada: bukan smeltable) ---
		"Quartz": return 2
		"Topaz": return 4
		"Emerald": return 5
		"Void Crystal": return 8
		"Uberilium": return 10
		_: return 1 # Copper, Iron, dan default lainnya# Copper, Iron, dan default lainnya

func get_smelt_result(ore_name: String) -> String:
	match ore_name:
		"Emerald": return "Emerald Crystal"          # ← nama special
		"Void Crystal": return "Stable Crystal"      # ← nama special
		_: return ore_name + " Bar"                  # default: <ore> Bar
		
func bikin_ui_smelt(canvas: CanvasLayer):
	smelt_panel = Panel.new()
	smelt_panel.size = Vector2(600, 400)
	smelt_panel.position = Vector2(250, 150)
	smelt_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.35)
	smelt_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(smelt_panel)
	
	var title = Label.new(); title.text = "Smelter\nchoose what you want to smelt!"
	title.position = Vector2(20, 20); title.add_theme_font_size_override("font_size", 20)
	smelt_panel.add_child(title)
	
	smelt_item_grid = GridContainer.new()
	smelt_item_grid.columns = 2
	smelt_item_grid.position = Vector2(20, 80)
	smelt_panel.add_child(smelt_item_grid)
	
	var right_panel = Panel.new()
	right_panel.size = Vector2(250, 250); right_panel.position = Vector2(320, 80)
	var rs = StyleBoxFlat.new(); rs.bg_color = Color(0.15, 0.15, 0.15)
	right_panel.add_theme_stylebox_override("panel", rs)
	smelt_panel.add_child(right_panel)
	
	smelt_slot_label = Label.new(); smelt_slot_label.position = Vector2(20, 20)
	smelt_slot_label.add_theme_font_size_override("font_size", 18)
	right_panel.add_child(smelt_slot_label)
	
	smelt_recipe_label = Label.new(); smelt_recipe_label.position = Vector2(20, 80)
	right_panel.add_child(smelt_recipe_label)
	
	# Tombol MAX (Buat smelt sebanyak mungkin)
	smelt_max_button = Button.new(); smelt_max_button.text = "MAX"
	smelt_max_button.position = Vector2(20, 180); smelt_max_button.size = Vector2(50, 40)
	smelt_max_button.pressed.connect(func(): set_max_smelt())
	right_panel.add_child(smelt_max_button)
	
	# Tombol SMELT
	smelt_button = Button.new(); smelt_button.text = "SMELT"
	smelt_button.position = Vector2(80, 180); smelt_button.size = Vector2(150, 40)
	smelt_button.pressed.connect(func(): do_smelt())
	right_panel.add_child(smelt_button)

func open_smelt_ui():
	is_smelt_open = true
	smelt_panel.visible = true
	smelt_selected_ore = ""
	smelt_amount = 0
	
	# Anti-Softlock Iron
	if Global.tutorial_step == 5:
		var total_iron = get_total_item_count("Iron")
		var bars = get_total_item_count("Iron Bar")
		if total_iron + bars < 10:
			Global.saved_inventory["Iron"] = Global.saved_inventory.get("Iron", 0) + 10
			Global.save_game()
			show_home_dialog("System: \"I think u are lack of iron aren't ya? here is your iron...\" (+10 Iron)")
			
	update_smelt_ui()

func close_smelt_ui():
	close_all_menus()
	is_smelt_open = false
	smelt_panel.visible = false

var ui_dialog_panel: Panel
var ui_dialog_label: Label

func bikin_ui_dialog(canvas: CanvasLayer):
	ui_dialog_panel = Panel.new()
	ui_dialog_panel.size = Vector2(600, 100)
	ui_dialog_panel.position = Vector2(200, 500)
	ui_dialog_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.9)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color.WHITE
	ui_dialog_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(ui_dialog_panel)
	
	ui_dialog_label = Label.new()
	ui_dialog_label.position = Vector2(20, 20)
	ui_dialog_label.size = Vector2(560, 60)
	ui_dialog_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	ui_dialog_label.add_theme_font_size_override("font_size", 18)
	ui_dialog_panel.add_child(ui_dialog_label)

func bikin_ui_smithing(canvas: CanvasLayer):
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS # Biar UI tetap jalan saat pause

	smithing_panel = Panel.new()
	smithing_panel.size = Vector2(1200, 700)
	var vp_size = get_viewport().get_visible_rect().size
	smithing_panel.position = (vp_size - smithing_panel.size) / 2.0 # Auto Center
	smithing_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.98)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.5, 0.2)
	smithing_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(smithing_panel)
	
	var title = Label.new(); title.text = "Smithing Station"; title.position = Vector2(30, 20); title.add_theme_font_size_override("font_size", 28); smithing_panel.add_child(title)
	var gail = Label.new(); gail.text = "Gail: \"Select an item to upgrade or salvage.\""; gail.position = Vector2(30, 60); gail.add_theme_color_override("font_color", Color.LIGHT_GREEN); smithing_panel.add_child(gail)
	
	# Kiri (Backpack)
	var bp_panel = Panel.new(); bp_panel.size = Vector2(320, 500); bp_panel.position = Vector2(20, 100); smithing_panel.add_child(bp_panel)
	var bp_grid = GridContainer.new(); bp_grid.columns = 5; bp_grid.position = Vector2(10, 10); bp_panel.add_child(bp_grid)
	for i in range(25):
		var s = Panel.new(); s.custom_minimum_size = Vector2(55, 55)
		var l = Label.new(); l.name = "Label"; l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; l.add_theme_font_size_override("font_size", 10); s.add_child(l)
		bp_grid.add_child(s); smithing_inv_slots.append(s)
		
	# Kanan (Storage)
	var sto_panel = Panel.new(); sto_panel.size = Vector2(320, 500); sto_panel.position = Vector2(860, 100); smithing_panel.add_child(sto_panel)
	var bw = Button.new(); bw.text = "Weapons"; bw.position = Vector2(10, 10); bw.size = Vector2(140, 30); bw.pressed.connect(func(): smithing_active_tab = "weapon"; update_smithing_ui()); sto_panel.add_child(bw)
	var bm = Button.new(); bm.text = "Material"; bm.position = Vector2(160, 10); bm.size = Vector2(140, 30); bm.pressed.connect(func(): smithing_active_tab = "material"; update_smithing_ui()); sto_panel.add_child(bm)
	var sto_grid = GridContainer.new(); sto_grid.columns = 5; sto_grid.position = Vector2(10, 50); sto_panel.add_child(sto_grid)
	for i in range(25):
		var s = Panel.new(); s.custom_minimum_size = Vector2(55, 55)
		var l = Label.new(); l.name = "Label"; l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; l.add_theme_font_size_override("font_size", 10); s.add_child(l)
		sto_grid.add_child(s); smithing_sto_slots.append(s)

	# Tengah (Upgrade Center)
	var center = Panel.new(); center.size = Vector2(520, 500); center.position = Vector2(340, 100); smithing_panel.add_child(center)
	smithing_center_label = Label.new(); smithing_center_label.position = Vector2(20, 20); smithing_center_label.add_theme_font_size_override("font_size", 24); center.add_child(smithing_center_label)
	smithing_preview_label = Label.new(); smithing_preview_label.position = Vector2(20, 70); smithing_preview_label.size = Vector2(480, 300); smithing_preview_label.add_theme_font_size_override("font_size", 18); smithing_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD; center.add_child(smithing_preview_label)
	
	smithing_upgrade_btn = Button.new(); smithing_upgrade_btn.text = "UPGRADE"; smithing_upgrade_btn.position = Vector2(50, 420); smithing_upgrade_btn.size = Vector2(180, 50); smithing_upgrade_btn.pressed.connect(_on_smithing_upgrade); center.add_child(smithing_upgrade_btn)
	smithing_salvage_btn = Button.new(); smithing_salvage_btn.text = "SALVAGE"; smithing_salvage_btn.position = Vector2(290, 420); smithing_salvage_btn.size = Vector2(180, 50); smithing_salvage_btn.pressed.connect(_on_smithing_salvage); center.add_child(smithing_salvage_btn)
	
	# Bawah (Equipment)
	var eq_panel = Panel.new(); eq_panel.size = Vector2(1160, 80); eq_panel.position = Vector2(20, 610); smithing_panel.add_child(eq_panel)
	var eql = Label.new(); eql.text = "Equipped:"; eql.position = Vector2(20, 30); eql.add_theme_font_size_override("font_size", 18); eq_panel.add_child(eql)
	for i in range(4):
		var s = Panel.new(); s.size = Vector2(60, 60); s.position = Vector2(120 + (i*75), 10)
		var l = Label.new(); l.name = "Label"; l.size = Vector2(60, 60); l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; l.add_theme_font_size_override("font_size", 10); s.add_child(l)
		eq_panel.add_child(s); smithing_equip_slots.append(s)
		
	var close_btn = Button.new(); close_btn.text = "CLOSE (E)"; close_btn.position = Vector2(1020, 20); close_btn.size = Vector2(120, 40); close_btn.pressed.connect(close_all_menus); eq_panel.add_child(close_btn)
	 
	# --- CUSTOM POP-UP KONFIRMASI SALVAGE ---
	salvage_confirm = Panel.new()
	salvage_confirm.size = Vector2(500, 200)
	salvage_confirm.position = (smithing_panel.size - salvage_confirm.size) / 2.0
	salvage_confirm.visible = false
	salvage_confirm.z_index = 10 # Pastikan di paling atas
	var sc_style = StyleBoxFlat.new()
	sc_style.bg_color = Color(0.1, 0.1, 0.1, 1.0)
	sc_style.border_width_left = 2; sc_style.border_width_top = 2; sc_style.border_width_right = 2; sc_style.border_width_bottom = 2
	sc_style.border_color = Color.RED
	salvage_confirm.add_theme_stylebox_override("panel", sc_style)
	smithing_panel.add_child(salvage_confirm)
	
	var sc_label = Label.new()
	sc_label.name = "ConfirmLabel"
	sc_label.position = Vector2(20, 20)
	sc_label.size = Vector2(460, 100)
	sc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	salvage_confirm.add_child(sc_label)
	
	var btn_yes = Button.new()
	btn_yes.text = "SALVAGE"
	btn_yes.position = Vector2(100, 140)
	btn_yes.size = Vector2(120, 40)
	btn_yes.pressed.connect(func(): 
		_execute_salvage()
		salvage_confirm.visible = false
	)
	salvage_confirm.add_child(btn_yes)
	
	var btn_no = Button.new()
	btn_no.text = "Cancel"
	btn_no.position = Vector2(280, 140)
	btn_no.size = Vector2(120, 40)
	btn_no.pressed.connect(func(): salvage_confirm.visible = false)
	salvage_confirm.add_child(btn_no)
	
func open_smithing_ui():
	is_smithing_open = true
	smithing_panel.visible = true
	smithing_selected_uuid = ""
	get_tree().paused = true
	update_smithing_ui()

func update_smithing_ui():
	var items_bp = get_backpack_items()
	for i in range(smithing_inv_slots.size()):
		var lbl = smithing_inv_slots[i].get_node("Label")
		if i < items_bp.size():
			var k = items_bp[i]
			lbl.text = Global.get_base_name(k)
			lbl.add_theme_color_override("font_color", get_item_color(Global.get_base_name(k)))
		else: lbl.text = ""
		
	var storage = Global.weapon_storage if smithing_active_tab == "weapon" else Global.material_storage
	var keys = storage.keys()
	for i in range(smithing_sto_slots.size()):
		var lbl = smithing_sto_slots[i].get_node("Label")
		if i < keys.size():
			var k = keys[i]
			lbl.text = Global.get_base_name(k) + "\n(" + str(storage[k]) + ")"
			lbl.add_theme_color_override("font_color", get_item_color(Global.get_base_name(k)))
		else: lbl.text = ""
		
	for i in range(4):
		var lbl = smithing_equip_slots[i].get_node("Label")
		var item = Global.equipped_armor if i == 3 else Global.hotbar_items[i]
		var uid = Global.equipped_armor_uuid if i == 3 else Global.hotbar_uuids[i]
		if item != null:
			lbl.text = item + "\nLv." + str(Global.get_item_level(item, uid))
		else: lbl.text = "Empty"
		
	if smithing_selected_uuid != "":
		var base_n = Global.get_base_name(smithing_selected_uuid)
		var lv = Global.get_item_level(base_n, smithing_selected_uuid)
		var target_lv = lv + 1
		smithing_center_label.text = "Forge: " + base_n + " (Lv " + str(lv) + ")"
		
		var txt = generate_preview_text(base_n, smithing_selected_uuid, target_lv)
		var _is_tutorial = (Global.tutorial_step == 11)
		
		if _is_tutorial:
			if base_n == "Iron Sword" and lv == 1:
				txt += "\n[TUTORIAL] Upgrade this to Lv 2."
				txt += "\nCost: 10 Gold, 20 Scrap"
				smithing_upgrade_btn.disabled = false
				smithing_upgrade_btn.text = "UPGRADE"
				smithing_salvage_btn.disabled = true # Kunci salvage saat tutorial
			else:
				txt += "\nLOCKED! Finish the tutorial first."
				smithing_upgrade_btn.disabled = true
				smithing_upgrade_btn.text = "LOCKED"
				smithing_salvage_btn.disabled = true
		else:
			if lv >= 5:
				txt += "\nMAX LEVEL REACHED"
				smithing_upgrade_btn.disabled = true
				smithing_upgrade_btn.text = "MAXED"
			elif target_lv - 1 > Global.highest_difficulty_cleared and not (base_n == "Iron Sword" and lv == 1):
				txt += "\nRequires Difficulty " + str(target_lv - 1) + " cleared!"
				smithing_upgrade_btn.disabled = true
				smithing_upgrade_btn.text = "LOCKED"
			else:
				var gold_c = get_base_cost(base_n) + int(get_base_cost(base_n) * 0.2 * (target_lv - 1))
				var scrap_c = get_upgrade_scrap_cost(base_n, target_lv)
				if base_n == "Iron Sword" and lv == 1:
					gold_c = 10; scrap_c = 20
				txt += "\nCost: " + str(gold_c) + " Gold, " + str(scrap_c) + " Scrap"
				smithing_upgrade_btn.disabled = false
				smithing_upgrade_btn.text = "UPGRADE"
				
			# Normal salvage (Iron sword lv 1 tetap gabisa salvage)
			smithing_salvage_btn.disabled = (base_n == "Iron Sword" and lv == 1 and Global.tutorial_step == 11)
			
		smithing_preview_label.text = txt
	else:
		smithing_center_label.text = "[ Select an Equipment ]"
		smithing_preview_label.text = ""
		smithing_upgrade_btn.disabled = true
		smithing_salvage_btn.disabled = true

func generate_preview_text(item_name, uuid, target_lv):
	var data = item_data.get(item_name, {})
	var cur_lv = Global.get_item_level(item_name, uuid)
	var txt = "Level: " + str(cur_lv) + " -> " + str(target_lv) + "\n"
	if data.get("weapon_type") == "Armor":
		var b = data.get("damage_reduction", 0)
		txt += "DR: " + str(int(b * (1.0 + 0.1 * (cur_lv - 1)))) + " -> " + str(int(b * (1.0 + 0.1 * (target_lv - 1)))) + "\n"
	else:
		var d = data.get("damage", 0)
		if d > 0: txt += "DMG: " + str(int(d * (1.0 + 0.1 * (cur_lv - 1)))) + " -> " + str(int(d * (1.0 + 0.1 * (target_lv - 1)))) + "\n"
	var cd = data.get("charge_damage", 0)
	if cd > 0:
		if item_name == "Marble Slingshot":
			var p_cur = int(data.get("damage", 15) * 0.5 * (1.0 + 0.1 * (cur_lv - 1)))
			var p_tgt = int(data.get("damage", 15) * 0.5 * (1.0 + 0.1 * (target_lv - 1)))
			txt += "Charge DMG: " + str(p_cur) + "x8 -> " + str(p_tgt) + "x8\n"
		else:
			txt += "Charge DMG: " + str(int(cd * (1.0 + 0.1 * (cur_lv - 1)))) + " -> " + str(int(cd * (1.0 + 0.1 * (target_lv - 1)))) + "\n"
		var ef = data.get("efficiency", 0)
		if ef > 0: txt += "Efficiency: " + str(ef + (cur_lv - 1)) + " -> " + str(ef + (target_lv - 1)) + "\n"
	return txt

func _on_smithing_upgrade():
	var base_n = Global.get_base_name(smithing_selected_uuid)
	var lv = Global.get_item_level(base_n, smithing_selected_uuid)
	if Global.tutorial_step == 11:
		if base_n != "Iron Sword" or lv != 1:
			show_floating_text("Locked! Finish the tutorial first.", player.global_position, Color.RED)
			return
	if lv >= 5: return
	var target_lv = lv + 1
	if target_lv - 1 > Global.highest_difficulty_cleared and not (base_n == "Iron Sword" and lv == 1):
		show_floating_text("Requires Difficulty " + str(target_lv - 1) + " cleared!", player.global_position, Color.RED)
		return
	var gold_c = get_base_cost(base_n) + int(get_base_cost(base_n) * 0.2 * (target_lv - 1))
	var scrap_c = get_upgrade_scrap_cost(base_n, target_lv)
	if base_n == "Iron Sword" and lv == 1:
		gold_c = 10; scrap_c = 20
		
	if Global.gold_coins < gold_c or get_total_item_count("Scrap") < scrap_c:
		Sfx.play("error")
		show_floating_text("Not enough Gold or Scrap!", player.global_position, Color.RED)
		return
		
	Global.gold_coins -= gold_c
	remove_item_from_all("Scrap", scrap_c)
	Global.set_item_level(base_n, target_lv, smithing_selected_uuid)
	Sfx.play("upgrade")
	Global.weapon_investment_gold[smithing_selected_uuid] = Global.weapon_investment_gold.get(smithing_selected_uuid, get_base_cost(base_n)) + gold_c
	Global.weapon_investment_scrap[smithing_selected_uuid] = Global.weapon_investment_scrap.get(smithing_selected_uuid, 0) + scrap_c

	# --- TRIGGER TUTORIAL UPGRADE ---
	if base_n == "Iron Sword" and target_lv == 2 and Global.tutorial_step == 11:
		Global.tutorial_step = 12
		Global.save_game()
		update_objective_ui()
		
		# Paksa tutup panel & unpause game
		close_all_menus()
		
		# Munculkan dialog Gail setelah panel tertutup
		show_home_dialog("Gail: \"Excellent! Your Iron Sword is now Lv 2. You should go see Mike for your next adventure.\"")
		
		return # Hentikan fungsi di sini agar tidak ada update UI panel yang udah ketutup
	# --------------------------------

	Global.save_game()
	update_smithing_ui()
	update_inventory_ui()
	ui_gold_label.text = "Gold: " + str(Global.gold_coins)
	show_floating_text("Upgraded to Lv " + str(target_lv) + "!", player.global_position, Color.GOLD)

func _on_smithing_salvage():
	var base_n = Global.get_base_name(smithing_selected_uuid)
	var lv = Global.get_item_level(base_n, smithing_selected_uuid)
	if base_n == "Iron Sword" and lv == 1 and Global.tutorial_step == 11: return
	
	var gold_inv = Global.weapon_investment_gold.get(smithing_selected_uuid, get_base_cost(base_n))
	var scrap_inv = Global.weapon_investment_scrap.get(smithing_selected_uuid, 0)
	var g_return = int(gold_inv * 0.7)
	var s_return = int(scrap_inv * 0.5)
	
	var lbl = salvage_confirm.get_node("ConfirmLabel")
	lbl.text = "Are you sure want to salvage this for " + str(g_return) + " Gold and " + str(s_return) + " Scrap?\n\nThis equipment will gone forever!"
	Sfx.play("drop")
	salvage_confirm.visible = true

func _execute_salvage():
	var base_n = Global.get_base_name(smithing_selected_uuid)
	var gold_inv = Global.weapon_investment_gold.get(smithing_selected_uuid, get_base_cost(base_n))
	var scrap_inv = Global.weapon_investment_scrap.get(smithing_selected_uuid, 0)
	
	var g_return = int(gold_inv * 0.7)
	var s_return = int(scrap_inv * 0.5)
	
	# Kasih hadiah salvage
	Global.gold_coins += g_return
	Global.saved_inventory["Scrap"] = Global.saved_inventory.get("Scrap", 0) + s_return
	Sfx.play("coin")
	
	# HAPUS DARI SEMUA TEMPAT (Tas, Equip, Hotbar, Storage)
	Global.saved_inventory.erase(smithing_selected_uuid)
	Global.weapon_storage.erase(smithing_selected_uuid)
	Global.material_storage.erase(smithing_selected_uuid)
	Global.ore_storage.erase(smithing_selected_uuid)
	
	Global.item_levels.erase(smithing_selected_uuid)
	Global.weapon_investment_gold.erase(smithing_selected_uuid)
	Global.weapon_investment_scrap.erase(smithing_selected_uuid)
	
	# Kalau senjatanya lagi dipakai, lepas dari badan/tangan
	for i in range(3):
		if Global.hotbar_uuids[i] == smithing_selected_uuid:
			Global.hotbar_uuids[i] = null
			Global.hotbar_items[i] = null
	if Global.equipped_armor_uuid == smithing_selected_uuid:
		Global.equipped_armor_uuid = ""
		Global.equipped_armor = null
		
	smithing_selected_uuid = ""
	
	Global.save_game()
	update_smithing_ui()
	update_inventory_ui()
	update_hotbar_ui()
	update_char_ui()
	ui_gold_label.text = "Gold: " + str(Global.gold_coins)
	show_floating_text("Salvaged! +" + str(g_return) + " G, +" + str(s_return) + " Scrap", player.global_position, Color.GREEN)

func show_home_dialog(text):
	ui_dialog_label.text = text
	ui_dialog_panel.visible = true
	await get_tree().create_timer(4.0).timeout
	ui_dialog_panel.visible = false

func bikin_cutscene_ui(canvas: CanvasLayer):
	cutscene_panel = Panel.new()
	cutscene_panel.size = Vector2(900, 200)
	cutscene_panel.position = Vector2(126, 480)
	cutscene_panel.visible = false
	cutscene_panel.z_index = 100
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	st.border_width_left = 3; st.border_width_top = 3; st.border_width_right = 3; st.border_width_bottom = 3
	st.border_color = Color.GOLD
	cutscene_panel.add_theme_stylebox_override("panel", st)
	canvas.add_child(cutscene_panel)
	
	cutscene_speaker = Label.new()
	cutscene_speaker.position = Vector2(20, 10)
	cutscene_speaker.add_theme_font_size_override("font_size", 24)
	cutscene_speaker.add_theme_color_override("font_color", Color.GOLD)
	cutscene_speaker.add_theme_color_override("font_outline_color", Color.BLACK)
	cutscene_speaker.add_theme_constant_override("outline_size", 4)
	cutscene_panel.add_child(cutscene_speaker)
	
	cutscene_text = Label.new()
	cutscene_text.position = Vector2(20, 55)
	cutscene_text.size = Vector2(860, 90)
	cutscene_text.add_theme_font_size_override("font_size", 20)
	cutscene_text.add_theme_color_override("font_color", Color.WHITE)
	cutscene_text.add_theme_color_override("font_outline_color", Color.BLACK)
	cutscene_text.add_theme_constant_override("outline_size", 3)
	cutscene_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	cutscene_panel.add_child(cutscene_text)
	
	cutscene_hint = Label.new()
	cutscene_hint.text = "[Click to continue...]"
	cutscene_hint.position = Vector2(730, 170)
	cutscene_hint.add_theme_font_size_override("font_size", 14)
	cutscene_hint.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	cutscene_panel.add_child(cutscene_hint)
	
	cutscene_name_input = LineEdit.new()
	cutscene_name_input.position = Vector2(20, 145)
	cutscene_name_input.size = Vector2(500, 40)
	cutscene_name_input.placeholder_text = "Enter your name..."
	cutscene_name_input.max_length = 20
	cutscene_name_input.visible = false
	cutscene_name_input.text_submitted.connect(func(_t): _on_cutscene_name_submit())
	cutscene_panel.add_child(cutscene_name_input)
	
	cutscene_submit_btn = Button.new()
	cutscene_submit_btn.text = "Confirm"
	cutscene_submit_btn.position = Vector2(530, 145)
	cutscene_submit_btn.size = Vector2(120, 40)
	cutscene_submit_btn.visible = false
	cutscene_submit_btn.pressed.connect(_on_cutscene_name_submit)
	cutscene_panel.add_child(cutscene_submit_btn)

func update_smelt_ui():
	for child in smelt_item_grid.get_children(): child.queue_free()
	
	# Base ores (selalu tampil)
	var ores = ["Copper", "Iron", "Silver", "Gold", "Mithril"]
	
	# T3 ores: hanya muncul setelah tutorial 3 selesai (step >= 8)
	# T3 ores: muncul kalau player PUNYA ore T3 (bukan berdasarkan step)
	var _has_t3_ore = false
	for _o in ["Quartz", "Topaz", "Emerald", "Void Crystal", "Uberilium"]:
		if Global.saved_inventory.get(_o, 0) > 0 or Global.ore_storage.get(_o, 0) > 0:
			_has_t3_ore = true
			break
	if _has_t3_ore:
		ores.append_array(["Quartz", "Topaz", "Emerald", "Void Crystal", "Uberilium"])
	for ore in ores:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(120, 40)
		var total = get_total_item_count(ore)
		btn.text = ore + " (" + str(int(total)) + ")"
		
		if Global.tutorial_step == 5 and ore != "Iron":
			btn.disabled = true
		else:
			# Klik = Tambah antrean
			btn.pressed.connect(func(): add_smelt_amount(ore))
		smelt_item_grid.add_child(btn)
		
	if smelt_selected_ore == "":
		smelt_slot_label.text = "[ Empty Slot ]"
		smelt_recipe_label.text = "Select an ore to smelt."
		smelt_button.disabled = true
		smelt_max_button.disabled = true
	else:
		smelt_slot_label.text = smelt_selected_ore + "\nx" + str(int(smelt_amount))
		
		# --- UBAH BAGIAN INI ---
		var cost_per = get_smelt_cost(smelt_selected_ore)
		var cost = smelt_amount * cost_per
		smelt_recipe_label.text = "Cost: " + str(cost) + " Gold\n(" + str(cost_per) + " Gold per bar)"
		# -----------------------
		
		smelt_max_button.disabled = false
		
		if smelt_amount == 0:
			smelt_button.disabled = true
			smelt_button.text = "SELECT AMOUNT"
		elif Global.gold_coins >= cost:
			smelt_button.disabled = false
			smelt_button.text = "SMELT (" + str(cost) + " G)"
		else:
			smelt_button.disabled = true
			smelt_button.text = "NOT ENOUGH GOLD"

func add_smelt_amount(ore):
	# Kalau pilih ore baru, reset ke 1. Kalau ore sama, tambah 1.
	if smelt_selected_ore != ore:
		smelt_selected_ore = ore
		smelt_amount = 1
	else:
		var max_amt = get_total_item_count(ore)
		if smelt_amount < max_amt:
			smelt_amount += 1
			
	# Batasi kalau di tutorial cuma butuh 10
	if Global.tutorial_step == 5 and smelt_amount > 10: 
		smelt_amount = 10
		
	update_smelt_ui()

func set_max_smelt():
	if smelt_selected_ore == "":
		return
	var max_ore = get_total_item_count(smelt_selected_ore)
	var cost_per = get_smelt_cost(smelt_selected_ore)
	
	# Hitung maksimal yang bisa dibeli pakai gold saat ini
	var max_by_gold = Global.gold_coins / cost_per
	
	smelt_amount = min(max_ore, max_by_gold)
	
	if Global.tutorial_step == 5 and smelt_amount > 10: 
		smelt_amount = 10
	
	if smelt_amount <= 0: smelt_amount = 1
	update_smelt_ui()
	
func do_smelt():
	var cost = smelt_amount * get_smelt_cost(smelt_selected_ore)
	
	if Global.gold_coins >= cost and smelt_amount > 0:
		Global.gold_coins -= cost
		ui_gold_label.text = "Gold: " + str(Global.gold_coins) # <--- TAMBAHKAN INI
		
		remove_item_from_all(smelt_selected_ore, smelt_amount)
		
		# Gunakan helper supaya Emerald → Emerald Crystal, Void Crystal → Stable Crystal
		var result_item = get_smelt_result(smelt_selected_ore)
		Global.saved_inventory[result_item] = Global.saved_inventory.get(result_item, 0) + smelt_amount
		
		show_floating_text("Smelted " + str(int(smelt_amount)) + " " + result_item + "!", player.global_position, Color.ORANGE)
		
		if Global.tutorial_step == 5 and Global.saved_inventory.get("Iron Bar", 0) >= 10:
			Global.tutorial_step = 6
			update_objective_ui()
			show_home_dialog("Good! Now craft the Iron Armor at the Forge.")
			
		smelt_amount = 0
		if get_total_item_count(smelt_selected_ore) > 0:
			smelt_amount = 1
			
		update_smelt_ui()
		update_inventory_ui()
		Global.save_game()

func get_total_item_count(item_name):
	var count = Global.saved_inventory.get(item_name, 0)
	count += Global.ore_storage.get(item_name, 0)
	count += Global.material_storage.get(item_name, 0)
	count += Global.weapon_storage.get(item_name, 0)
	return count

func remove_item_from_all(item_name, amount):
	var removed = 0
	# 1. Ambil dari Backpack
	if Global.saved_inventory.has(item_name):
		var take = min(Global.saved_inventory[item_name], amount)
		Global.saved_inventory[item_name] -= take
		amount -= take
		removed += take
		if Global.saved_inventory[item_name] <= 0: Global.saved_inventory.erase(item_name)
	
	# 2. Ambil dari Ore Storage
	if amount > 0 and Global.ore_storage.has(item_name):
		var take = min(Global.ore_storage[item_name], amount)
		Global.ore_storage[item_name] -= take
		amount -= take
		removed += take
		if Global.ore_storage[item_name] <= 0: Global.ore_storage.erase(item_name)
		
	# 3. Ambil dari Material Storage
	if amount > 0 and Global.material_storage.has(item_name):
		var take = min(Global.material_storage[item_name], amount)
		Global.material_storage[item_name] -= take
		amount -= take
		removed += take
		if Global.material_storage[item_name] <= 0: Global.material_storage.erase(item_name)
		
	# 4. Ambil dari Weapon Storage
	if amount > 0 and Global.weapon_storage.has(item_name):
		var take = min(Global.weapon_storage[item_name], amount)
		Global.weapon_storage[item_name] -= take
		amount -= take
		removed += take
		if Global.weapon_storage[item_name] <= 0: Global.weapon_storage.erase(item_name)
		
	return removed

func show_forge_item_info():
	if forge_selected_item == "": return
	var data = item_data.get(forge_selected_item, {})
	var text = "Name: " + forge_selected_item + "\n"
	text += "Type: " + data.get("weapon_type", "None") + "\n"
	text += "Trait: " + data.get("trait", "None") + "\n"
	text += "Passive: " + data.get("passive", "None")
	show_home_dialog(text)

func get_part_count(part_name):
	var base_name = part_name.replace(" 💀", "").replace(" ⛏️", "").replace(" ⚔️", "")
	return get_total_item_count(part_name) + get_total_item_count(base_name)

func remove_part(part_name):
	var base_name = part_name.replace(" 💀", "").replace(" ⛏️", "").replace(" ⚔️", "")
	
	# Coba kurangi yang pakai emoji dulu
	if get_total_item_count(part_name) > 0:
		remove_item_from_all(part_name, 1)
	# Kalau gak ada, kurangi yang versi lama
	elif get_total_item_count(base_name) > 0:
		remove_item_from_all(base_name, 1)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.save_game()
		get_tree().quit()

func _start_post_t3_cutscene():
	if cutscene_active: return
	if Global.tutorial_step != 9: return
	if not is_instance_valid(cutscene_panel): return
	
	cutscene_active = true
	cutscene_step = 0
	cutscene_panel.visible = true
	if is_instance_valid(player):
		player.set_physics_process(false)
	_show_cutscene_step(0)

func _show_cutscene_step(step_num):
	cutscene_step = step_num
	Global.post_t3_cutscene_step = step_num
	Global.save_game()
	
	var _name = Global.player_name
	
	cutscene_name_input.visible = (step_num == 3)
	cutscene_submit_btn.visible = (step_num == 3)
	cutscene_hint.visible = (step_num != 3)
	cutscene_speaker.add_theme_color_override("font_color", Color.GOLD)
	
	match step_num:
		0:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "Hey there, seems you are a expert explorer over there."
		1:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "Thank goodness that you already defeat Mega Spideroid. That creature has been haunting us for a decade."
		2:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "May I know your name, unknown traveler?"
		3:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "May I know your name, unknown traveler?"
			cutscene_name_input.text = ""
			cutscene_name_input.grab_focus()
		4:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "Ohh " + _name + "... that's such an interesting name for an unknown hero."
		5:
			cutscene_speaker.text = _name
			cutscene_speaker.add_theme_color_override("font_color", Color.CYAN)
			cutscene_text.text = "Where have you been at? Didn't see you at the first place."
		6:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "I was on the different country to do other quest."
		7:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "Well, great to know you " + _name + ". If you need help for adventure later, just call me and you can gain access to other map."
		8:
			# --- STEP HADIAH DARI MIKE ---
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "Before you go, please take this Iron Sword and 20 Scraps as a token of our gratitude. You might need them for your future upgrades."
			
			# Berikan 1 Iron Sword
			var _uuid = Global.create_weapon_key("Iron Sword")
			Global.saved_inventory[_uuid] = 1
			Global.item_levels[_uuid] = 1
			
			# Berikan 20 Scrap
			Global.saved_inventory["Scrap"] = Global.saved_inventory.get("Scrap", 0) + 20
			
			Global.save_game()
			update_inventory_ui() # Biar kalau langsung buka tas, barangnya udah ada
		9:
			cutscene_speaker.text = "Mike"
			cutscene_text.text = "Goodluck, I hope you enjoy your day!"
		10:
			_end_post_t3_cutscene()
			
func _advance_cutscene():
	if cutscene_step == 3: return
	if cutscene_step >= 10: return
	_show_cutscene_step(cutscene_step + 1)

func _on_cutscene_name_submit():
	var _n = cutscene_name_input.text.strip_edges()
	if _n == "": _n = "Player"
	Global.player_name = _n.substr(0, 20) # <--- PAKSA MAX 20 KARAKTER
	Global.save_game()
	_show_cutscene_step(4)

func _end_post_t3_cutscene():
	cutscene_active = false
	cutscene_panel.visible = false
	Global.tutorial_step = 10
	Global.post_t3_cutscene_step = 0  # Reset untuk playthrough berikutnya
	Global.save_game()
	if is_instance_valid(player):
		player.set_physics_process(true)
	update_objective_ui()
	_refresh_player_name_label()

func _refresh_player_name_label():
	if is_instance_valid(ui_exp_label):
		ui_exp_label.text = Global.player_name + " Lv " + str(Global.player_level) + " | EXP: " + str(Global.player_exp) + "/" + str(Global.exp_to_next_level) + " | Mana: " + str(int(Global.current_mana)) + "/" + str(Global.max_mana)
		
		# Ubah kursor jadi tangan kalau udah tamat T3
		if Global.tutorial_step >= 10:
			ui_exp_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		else:
			ui_exp_label.mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_hud_name_clicked(event):
	if Global.tutorial_step < 10: return # HANYA BISA DIKLIK POST-T3
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		rename_panel.visible = true
		rename_input.text = Global.player_name
		rename_input.grab_focus()
		if is_instance_valid(player):
			player.set_physics_process(false)

func _on_rename_confirm():
	var _n = rename_input.text.strip_edges()
	if _n == "": _n = "Player"
	Global.player_name = _n.substr(0, 20) # Paksa max 20
	Global.save_game()
	rename_panel.visible = false
	if is_instance_valid(player):
		player.set_physics_process(true)
	_refresh_player_name_label()

func spawn_testing_area():
	# 1. PERPANJANG LANTAI (Visual & Fisik)
	var floor_ext = ColorRect.new()
	floor_ext.size = Vector2(1500, 30)
	floor_ext.position = Vector2(850, 165) # Posisi Y disesuaikan biar pas sama lantai utama
	floor_ext.color = Color(0.2, 0.8, 0.4) # Warna hijau sama kayak lantai utama
	floor_ext.z_index = -2
	add_child(floor_ext)
	
	var floor_body = StaticBody2D.new()
	var floor_col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(1500, 30)
	floor_col.shape = rect
	floor_body.position = Vector2(850 + 750, 180) # Disamain sama visual
	floor_body.add_child(floor_col)
	add_child(floor_body)
	
	# 2. BIKIN DUMMY
	dummy_node = Node2D.new()
	dummy_node.position = Vector2(1250, 165) 
	dummy_node.z_index = -1
	
	var pole = ColorRect.new()
	pole.size = Vector2(10, 100)
	pole.position = Vector2(-5, -100)
	pole.color = Color(0.4, 0.2, 0.1)
	dummy_node.add_child(pole)
	
	var body = ColorRect.new()
	body.size = Vector2(50, 60)
	body.position = Vector2(-25, -80)
	body.color = Color(0.8, 0.7, 0.5) 
	dummy_node.add_child(body)
	
	var target = ColorRect.new()
	target.size = Vector2(24, 24)
	target.position = Vector2(-12, -62)
	target.color = Color.RED
	dummy_node.add_child(target)
	
		# Teks Dummy
	var text = Label.new()
	text.text = "ATTACKING DUMMY"
	text.position = Vector2(-55, -170) # Digeser ke atas
	text.add_theme_font_size_override("font_size", 14)
	dummy_node.add_child(text)
	
	# --- DPS METER LABEL ---
	dummy_dps_label = Label.new()
	dummy_dps_label.text = "DPS: 0.0\nAvg Dmg: 0.0"
	dummy_dps_label.position = Vector2(-55, -130) # Di bawah nama dummy
	dummy_dps_label.add_theme_font_size_override("font_size", 16)
	dummy_dps_label.add_theme_color_override("font_color", Color.CYAN)
	dummy_dps_label.add_theme_color_override("font_outline_color", Color.BLACK)
	dummy_dps_label.add_theme_constant_override("outline_size", 4)
	dummy_node.add_child(dummy_dps_label)
	
	add_child(dummy_node)
	
	# 3. BIKIN CHEST LATIHAN (Practice Arrow)
	training_chest_node = Node2D.new()
	training_chest_node.position = Vector2(1100, 165) 
	training_chest_node.z_index = -1
	
	var box = ColorRect.new()
	box.size = Vector2(30, 30)
	box.position = Vector2(-15, -30)
	box.color = Color(0.6, 0.3, 0.1) 
	training_chest_node.add_child(box)
	
	var text_chest = Label.new()
	text_chest.text = "TRAINING CHEST\n(Click Me)"
	text_chest.position = Vector2(-45, -60)
	text_chest.add_theme_font_size_override("font_size", 12)
	training_chest_node.add_child(text_chest)
	
	add_child(training_chest_node)

func test_dummy_attack(is_charge = false):
	var weapon = Global.hotbar_items[selected_home_slot]
	var weapon_uuid = Global.hotbar_uuids[selected_home_slot]
	var item_stats = Global.get_effective_stats(weapon, item_data.get(weapon, {}), weapon_uuid)
	if weapon == null: weapon = "Fist"
	
	var dmg = item_stats.get("damage", 0)
	
	# --- HEADHITTER HEAVY BOW SIMULATION ---
	if weapon == "Headhitter Heavy Bow" and is_charge:
		dmg = int(dmg * 1.5) # Simulasi execute (karena dummy dianggap low HP)
		show_floating_text("EXECUTE!", dummy_node.global_position + Vector2(0, -100), Color.RED)
		var _hb_dir = sign(dummy_node.global_position.x - player.global_position.x)
		if _hb_dir == 0: _hb_dir = 1
		var _base_x = dummy_node.position.x
		var _hb_tween = create_tween()
		_hb_tween.tween_property(dummy_node, "position:x", _base_x + _hb_dir * 64, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# --- RADIANCE SCEPTER: Self-Heal Utility (Free in home for testing) ---
	if weapon == "Radiance Scepter":
		if home_attack_cooldown > 0: return
		var _heal = item_stats.get("heal_amount", 12)
		var _lv = Global.get_item_level("Radiance Scepter")
		if _lv > 1:
			_heal = int(_heal * (1.0 + 0.1 * (_lv - 1)))
		Global.current_hp = min(Global.current_hp + _heal, Global.max_hp)
		home_attack_cooldown = item_stats.get("attack_speed", 1.5)
		
		show_floating_text("+" + str(_heal) + " HP", player.global_position + Vector2(0, -40), Color.GREEN)
		
		var _heal_fx = ColorRect.new()
		_heal_fx.size = Vector2(60, 60)
		_heal_fx.position = player.global_position - Vector2(30, 30)
		_heal_fx.color = Color(1.0, 0.9, 0.5, 0.6)
		_heal_fx.z_index = 15
		add_child(_heal_fx)
		var _ht = create_tween()
		_ht.tween_property(_heal_fx, "scale", Vector2(1.8, 1.8), 0.3)
		_ht.parallel().tween_property(_heal_fx, "modulate:a", 0.0, 0.3)
		_ht.tween_callback(_heal_fx.queue_free)
		
		update_hp_ui()
		return
	# -------------------------------------------------
	
	# --- SET COOLDOWN SESUAI ATTACK SPEED SENJATA ---
	home_attack_cooldown = item_stats.get("attack_speed", 0.5)
	
	# --- SET COOLDOWN DULU DI AWAL (BIAR GAK BISA DI SPAM) ---
	var base_atk_speed = item_stats.get("attack_speed", 0.5)
	if base_atk_speed <= 0: base_atk_speed = 0.5 # Jaga-jaga kalau 0
	home_attack_cooldown = base_atk_speed
	# ---------------------------------------------------------
	
	# --- SILVER GRAY SWORD: Accelerate speed bonus ---
	if weapon == "Silver Gray Sword" and sgs_accelerate_stacks > 0:
		home_attack_cooldown = home_attack_cooldown / (1.0 + sgs_accelerate_stacks * 0.10)
	# ------------------------------------------------

	# --- REVENGER: check stack target ---
	if weapon == "Revenger Crystallinum" and revenger_target == dummy_node and revenger_stacks > 0:
		dmg = int(dmg * (1.0 + revenger_stacks * 0.30))
	# ------------------------------------

	# --- HERETIC STAFF: hitscan magic beam ---
	if weapon == "Heretic Staff":
		home_attack_cooldown = item_stats.get("attack_speed", 1.2)
		var mouse_world_hs = get_global_mouse_position()
		
		var beam = Line2D.new()
		beam.add_point(player.global_position)
		beam.add_point(mouse_world_hs)
		beam.width = 3.0
		beam.default_color = Color(0.8, 0.2, 1.0)
		add_child(beam)
		var bt = create_tween()
		bt.tween_property(beam, "modulate:a", 0.0, 0.3)
		bt.tween_callback(beam.queue_free)
		
		if mouse_world_hs.distance_to(dummy_node.global_position) < 100:
			show_floating_text(str(dmg), dummy_node.global_position + Vector2(0, -80), Color.MEDIUM_PURPLE)
			if randf() < 0.7:
				show_floating_text("TERRIFIED!", dummy_node.global_position + Vector2(0, -110), Color.PURPLE)
			combat_dmg_total += dmg
			combat_hits += 1
			if combat_hits == 1: combat_timer = 0.0
			idle_timer = 0.0
			var dt = create_tween()
			dt.tween_property(dummy_node, "position:x", dummy_node.position.x + 10, 0.05)
			dt.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
		return
	
	if weapon == "Crystal Minigun":
		if Global.saved_inventory.get("Practice Arrow", 0) <= 0:
			show_floating_text("No Practice Arrows!", player.global_position, Color.RED)
			return
		
		Global.saved_inventory["Practice Arrow"] -= 1
		update_inventory_ui()
		update_hotbar_ui()
		
		home_attack_cooldown = item_stats.get("attack_speed", 0.1)
		
		# Boulder every 10th shot
		minigun_shot_count += 1
		if minigun_shot_count >= 10:
			minigun_shot_count = 0
			spawn_practice_boulder(int(dmg * 1.3))
		
		# Beam visual (hitscan ke mouse)
		var beam = Line2D.new()
		beam.add_point(player.global_position)
		beam.add_point(get_global_mouse_position())
		beam.width = 2.0
		beam.default_color = Color(0.8, 0.2, 0.5, 0.8)
		add_child(beam)
		var bt = create_tween()
		bt.tween_property(beam, "modulate:a", 0.0, 0.1)
		bt.tween_callback(beam.queue_free)
		
		# Damage dummy kalau kena aim + dalam range
		if is_instance_valid(dummy_node):
			var dist = player.global_position.distance_to(dummy_node.global_position)
			var mouse_aim_dist = get_global_mouse_position().distance_to(dummy_node.global_position)
			if dist <= 208 and mouse_aim_dist < 80:
				combat_dmg_total += dmg
				combat_hits += 1
				idle_timer = 0.0
				show_floating_text(str(dmg), dummy_node.global_position + Vector2(0, -80), Color.PINK)
				var t = create_tween()
				t.tween_property(dummy_node, "position:x", dummy_node.position.x + 10, 0.05)
				t.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
		return
	
	if weapon in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow", "Headhitter Heavy Bow"]:
		if weapon == "Bounty Bow":
			dmg = int(dmg * (1.0 + bounty_bow_stacks * 0.20))
			bounty_bow_stacks = min(bounty_bow_stacks + 1, 5)
			bounty_stack_timer = 7.0
			show_floating_text("Bounty Stack: " + str(bounty_bow_stacks) + "/5", player.global_position + Vector2(0, -60), Color.GOLD)
			show_floating_text("BOUNTY!", dummy_node.global_position + Vector2(0, -70), Color.YELLOW)
			
		if Global.saved_inventory.get("Practice Arrow", 0) <= 0:
			show_floating_text("No Practice Arrows!", player.global_position, Color.RED)
			return
		
		Global.saved_inventory["Practice Arrow"] -= 1
		update_inventory_ui()
		update_hotbar_ui()
		
		if is_charge:
			if weapon == "Bow": dmg = 20
			elif weapon == "Iron Bow": dmg = 28
			elif weapon == "Hunter Bow": dmg = 25
			else: dmg = item_stats.get("charge_damage", dmg * 2)
			home_attack_cooldown = item_stats.get("charge_speed", 1.0)
		
		var mouse_world = get_global_mouse_position()
		
		# --- MARBLE SLINGSHOT: split 8 proyektil ---
		if weapon == "Marble Slingshot" and is_charge:
			for _i in range(8):
				var _off = Vector2(randf_range(-80, 80), randf_range(-80, 80))
				spawn_practice_arrow(mouse_world + _off, max(1, int(dmg * 0.1)))
			show_floating_text("8x SPLIT!", player.global_position + Vector2(0, -60), Color.ORANGE)
		# --- EXPLOSIVE CROSSBOW: AoE visual ---
		elif weapon == "Explosive Crossbow" and is_charge:
			spawn_practice_arrow(mouse_world, dmg)
			if mouse_world.distance_to(dummy_node.global_position) < 100:
				var exp = ColorRect.new()
				exp.size = Vector2(128, 128)
				exp.position = dummy_node.global_position - Vector2(64, 64)
				exp.color = Color(1.0, 0.5, 0.0, 0.8)
				add_child(exp)
				var et = create_tween()
				et.tween_property(exp, "modulate:a", 0.0, 0.4)
				et.tween_callback(exp.queue_free)
				show_floating_text("EXPLOSION!", dummy_node.global_position + Vector2(0, -110), Color.ORANGE)
		# --- MOURNING BOW: stun visual ---
		elif weapon == "Mourning Bow" and is_charge:
			spawn_practice_arrow(mouse_world, dmg)
			if mouse_world.distance_to(dummy_node.global_position) < 100:
				show_floating_text("STUNNED (2s)!", dummy_node.global_position + Vector2(0, -110), Color.CYAN)
		else:
			spawn_practice_arrow(mouse_world, dmg)
		
		# --- IRON BOW PIERCE ---
		if weapon == "Iron Bow" and is_charge and randf() < 0.10:
			show_floating_text("PIERCE!", player.global_position + Vector2(0, -60), Color.CYAN)
		# --- STICKY CROSSBOW: GRAPPLING HOOK ---
		if weapon == "Sticky Crossbow":
			var _target_pos = get_global_mouse_position()
			var _pull_center = _target_pos
			
			# Kalau aim ke dummy (dalam 100px), tarik ke dummy + stun
			if is_instance_valid(dummy_node) and _target_pos.distance_to(dummy_node.global_position) < 100:
				_pull_center = dummy_node.global_position
				show_floating_text("STUCK (3s)!", dummy_node.global_position + Vector2(0, -100), Color.GREEN)
				combat_dmg_total += dmg
				combat_hits += 1
				idle_timer = 0.0
				show_floating_text(str(dmg), dummy_node.global_position + Vector2(0, -80), Color.GREEN)
				var dt = create_tween()
				dt.tween_property(dummy_node, "position:x", dummy_node.position.x + 10, 0.05)
				dt.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
			else:
				show_floating_text("PULL!", player.global_position + Vector2(0, -60), Color.GREEN)
			
			# Visual arrow menembak ke target
			var _sc_arrow = ColorRect.new()
			_sc_arrow.size = Vector2(12, 4)
			_sc_arrow.color = Color(0.5, 0.7, 0.3)
			_sc_arrow.position = player.global_position
			_sc_arrow.rotation = (get_global_mouse_position() - player.global_position).angle()
			add_child(_sc_arrow)
			var _arrow_t = create_tween()
			var _travel_time = player.global_position.distance_to(_target_pos) / 1500.0
			if _travel_time < 0.05: _travel_time = 0.05
			_arrow_t.tween_property(_sc_arrow, "position", _target_pos, _travel_time)
			_arrow_t.tween_callback(_sc_arrow.queue_free)
			
			# Delay pull biar arrow sempat nyampe dulu
			await get_tree().create_timer(_travel_time + 0.02).timeout
			
			# Tarik player ke target (stop sisa 40px biar ga nabrak)
			var _dir_pull = (_pull_center - player.global_position).normalized()
			var _end_pos = _pull_center - _dir_pull * 40.0
			player.set_physics_process(false)
			var _pt = create_tween()
			_pt.tween_property(player, "global_position", _end_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_pt.tween_callback(player.set_physics_process.bind(true))
	else:
				# --- SHARDING SWORD: magic vuln stack ---
		if item_data.get(weapon, {}).get("weapon_type") == "Magic Damage":
			var _mv = dummy_node.get_meta("magic_vuln", 0.0) if dummy_node.has_meta("magic_vuln") else 0.0
			if _mv > 0.0:
				dmg = int(dmg * (1.0 + _mv))
		if weapon == "Sharding Sword":
			var _cv = dummy_node.get_meta("magic_vuln", 0.0) if dummy_node.has_meta("magic_vuln") else 0.0
			dummy_node.set_meta("magic_vuln", min(_cv + 0.2, 1.0))
			show_floating_text("Magic Vuln +20%", dummy_node.global_position + Vector2(0, -130), Color.PURPLE)
		
		# --- GALAHAD: +1% dmg per stack (home: stack per hit for testing) ---
		if weapon == "Galahad Chimelin":
			dmg = int(dmg * (1.0 + galahad_stacks * 0.01))
			galahad_stacks = min(galahad_stacks + 1, 80)
			show_floating_text("+" + str(galahad_stacks) + "% DMG", dummy_node.global_position + Vector2(0, -130), Color.GOLD)
		
		# --- CRYSTAL MINIGUN: boulder every 10th shot ---
		if weapon == "Crystal Minigun":
			minigun_shot_count += 1
			if minigun_shot_count >= 10:
				minigun_shot_count = 0
				spawn_practice_boulder(int(dmg * 1.3))
		
		# --- SILVER GRAY SWORD: Accelerate stack ---
		if weapon == "Silver Gray Sword":
			sgs_hit_counter += 1
			if sgs_hit_counter >= 5:
				sgs_hit_counter = 0
				if sgs_accelerate_stacks < 5:
					sgs_accelerate_stacks += 1
					show_floating_text("Accelerate " + str(sgs_accelerate_stacks) + "/5", dummy_node.global_position + Vector2(0, -130), Color.CYAN)
		# -------------------------------------------
		
		# --- PASSIVE IRON SWORD ---
		if weapon == "Iron Sword":
			sword_combo += 1
			if sword_combo >= 3:
				dmg = int(dmg * 1.2) 
				sword_combo = 0 
				show_floating_text("PASSIVE!", dummy_node.global_position + Vector2(0, -110), Color.GOLD)
		else:
			sword_combo = 0
		# ---------------------------
		
		# --- BLEED VULNERABILITY ---
		if dummy_bleed_dmg > 0:
			dmg = int(dmg * 1.15)
		# ---------------------------
		
		# --- POISON (MENACING DAGGER) 30% chance ---
		if weapon == "Menacing Dagger" and randf() < 0.3:
			dummy_poison_dmg = max(1, int(dmg * 0.25))
			dummy_poison_rem = 5
			dummy_poison_tick = 0.0
			show_floating_text("POISON!", dummy_node.global_position + Vector2(0, -110), Color.GREEN)
		# --------------------------------------------
		
		# --- BLEED (MANIACAL CHAINSAW) 40% chance ---
		if weapon == "Maniacal Chainsaw" and randf() < 0.4:
			dummy_bleed_dmg = max(1, int(dmg * 0.15))
			dummy_bleed_rem = 5
			dummy_bleed_tick = 0.0
			show_floating_text("BLEED!", dummy_node.global_position + Vector2(0, -110), Color.RED)
		# --------------------------------------------
		
		# --- TERRIFIED (HERETIC STAFF) 70% chance ---
		if weapon == "Heretic Staff" and randf() < 0.7:
			show_floating_text("TERRIFIED!", dummy_node.global_position + Vector2(0, -110), Color.PURPLE)
		# --------------------------------------------
		
		# --- CATAT DAMAGE UNTUK DPS ---
		combat_dmg_total += dmg
		combat_hits += 1
		if combat_hits == 1: combat_timer = 0.0 
		idle_timer = 0.0
		# ------------------------------
		
		show_floating_text(str(dmg), dummy_node.global_position + Vector2(0, -80), Color.YELLOW)
		
		var tween = create_tween()
		tween.tween_property(dummy_node, "position:x", dummy_node.position.x + 10, 0.05)
		tween.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)

# --- FUNGSI BARU BUAT ANIMASI PANAH ---
func spawn_practice_arrow(target_pos, dmg):
	var arrow = ColorRect.new()
	arrow.size = Vector2(12, 4)
	arrow.color = Color(0.2, 0.8, 1.0)
	arrow.position = player.global_position
	
	var dir = (target_pos - player.global_position).normalized()
	arrow.rotation = dir.angle()
	
	add_child(arrow)
	
	# Animasi panah melesat ke arah mouse
	var dist = player.global_position.distance_to(target_pos)
	var durasi = dist / 1000.0 # Kecepatan panah
	if durasi < 0.1: durasi = 0.1
	
	var tween = create_tween()
	tween.tween_property(arrow, "position", target_pos, durasi)
	tween.finished.connect(func():
		arrow.queue_free()
		# Kalau panah nyampe deket dummy, kasih damage
		if target_pos.distance_to(dummy_node.global_position) < 100:
			show_floating_text(str(dmg), dummy_node.global_position + Vector2(0, -80), Color.CYAN)
			var t = create_tween()
			t.tween_property(dummy_node, "position:x", dummy_node.position.x + 10, 0.05)
			t.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
			
			# --- CATAT DAMAGE UNTUK DPS ---
			combat_dmg_total += dmg
			combat_hits += 1
			if combat_hits == 1: combat_timer = 0.0
			idle_timer = 0.0
			# ------------------------------
	)

func spawn_practice_boulder(dmg: int):
	var boulder = ColorRect.new()
	boulder.size = Vector2(24, 24)
	boulder.color = Color(0.8, 0.3, 0.5)
	boulder.position = player.global_position - Vector2(12, 12)
	boulder.z_index = 5
	add_child(boulder)
	
	var target = dummy_node.global_position
	var tween = create_tween()
	tween.tween_property(boulder, "position", target - Vector2(12, 12), 0.3)
	tween.finished.connect(func():
		boulder.queue_free()
		if target.distance_to(dummy_node.global_position) < 100:
			show_floating_text(str(dmg) + " (BOULDER)", dummy_node.global_position + Vector2(0, -100), Color.MAGENTA)
			combat_dmg_total += dmg
			combat_hits += 1
			if combat_hits == 1: combat_timer = 0.0
			idle_timer = 0.0
			var t = create_tween()
			t.tween_property(dummy_node, "position:x", dummy_node.position.x + 15, 0.05)
			t.tween_property(dummy_node, "position:x", dummy_node.position.x, 0.1)
	)

func close_all_menus():
	get_tree().paused = false
	is_forge_open = false
	is_smelt_open = false
	is_storage_ui_open = false
	is_selling_ui_open = false
	is_inventory_open = false
	is_char_open = false
	is_guild_open = false
	is_prep_open = false 
	is_smithing_open = false
	is_music_player_open = false
	
	if is_instance_valid(music_player_panel): music_player_panel.visible = false
	if is_instance_valid(smithing_panel): smithing_panel.visible = false
	if is_instance_valid(forge_panel): forge_panel.visible = false
	if is_instance_valid(smelt_panel): smelt_panel.visible = false
	if is_instance_valid(storage_panel): storage_panel.visible = false
	if is_instance_valid(sell_panel): sell_panel.visible = false
	if is_instance_valid(ui_inventory_panel): ui_inventory_panel.visible = false
	if is_instance_valid(char_panel): char_panel.visible = false
	if is_instance_valid(guild_panel): guild_panel.visible = false
	if is_instance_valid(prep_panel): prep_panel.visible = false 
	if is_instance_valid(confirm_panel): confirm_panel.visible = false 
	
	# Kembalikan HUD
	if is_instance_valid(ui_objective_label): ui_objective_label.visible = true
	if is_instance_valid(ui_gold_label): ui_gold_label.visible = true
	if is_instance_valid(ui_exp_label): ui_exp_label.visible = true
	for h in heart_labels:
		if is_instance_valid(h): h.visible = true
	for l in hotbar_ui_labels:
		if is_instance_valid(l) and is_instance_valid(l.get_parent()):
			l.get_parent().visible = true
	
	# Kembalikan tombol CLOSE Storage
	if is_instance_valid(storage_panel):
		for child in storage_panel.get_children():
			if child is Button and child.text == "CLOSE":
				child.visible = true
				
	# Kembalikan posisi 3 panel ke layout asli
	if is_instance_valid(char_panel): char_panel.position = Vector2(100, 150)
	if is_instance_valid(ui_inventory_panel): ui_inventory_panel.position = Vector2(720, 150)
	if is_instance_valid(storage_panel): storage_panel.position = Vector2(150, 50)
	
	if is_instance_valid(player):
		player.set_physics_process(true)

var btn_maps = []
var diff_buttons = []
var guild_right_panel: Panel
var guild_diff_info: Label
var btn_ready_guild: Button
var btn_anomaly: Button
var selected_guild_map: String = ""

func bikin_ui_guild(canvas: CanvasLayer):
	guild_panel = Panel.new()
	guild_panel.size = Vector2(950, 550)
	var vp_size = get_viewport().get_visible_rect().size
	guild_panel.position = (vp_size - guild_panel.size) / 2.0
	guild_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.98)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.2, 0.6, 1.0)
	guild_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(guild_panel)
	
	var title = Label.new(); title.text = "Adventurers Guild"
	title.position = Vector2(30, 20); title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color.GOLD)
	guild_panel.add_child(title)
	
	# KIRI: Daftar Map
	var map_vbox = VBoxContainer.new()
	map_vbox.position = Vector2(30, 80)
	map_vbox.size = Vector2(380, 400)
	map_vbox.add_theme_constant_override("separation", 15)
	guild_panel.add_child(map_vbox)
	
	var maps = ["Crystaline Caverns", "Volcano Cave", "Spooky Cave", "Underwater Abyss"]
	for m in maps:
		var b = Button.new()
		b.text = m
		b.custom_minimum_size = Vector2(380, 55)
		b.add_theme_font_size_override("font_size", 18)
		b.pressed.connect(func(): select_guild_map(m))
		map_vbox.add_child(b)
		btn_maps.append(b)
	
	# KANAN: Panel Difficulty
	guild_right_panel = Panel.new()
	guild_right_panel.size = Vector2(480, 450)
	guild_right_panel.position = Vector2(440, 80)
	guild_right_panel.visible = false
	var rs = StyleBoxFlat.new(); rs.bg_color = Color(0.15, 0.15, 0.15)
	guild_right_panel.add_theme_stylebox_override("panel", rs)
	guild_panel.add_child(guild_right_panel)
	
	# Title & Anomaly Placeholder (Default)
	var rt = Label.new(); rt.text = "Select Difficulty"
	rt.position = Vector2(20, 20); rt.add_theme_font_size_override("font_size", 22)
	guild_right_panel.add_child(rt)
	
	btn_anomaly = Button.new()
	btn_anomaly.text = "Default"
	btn_anomaly.position = Vector2(340, 20); btn_anomaly.size = Vector2(120, 35)
	btn_anomaly.disabled = true # Nanti diaktifkan buat Anomaly
	guild_right_panel.add_child(btn_anomaly)
	
	var rst = Label.new(); rst.text = "Choose your difficulty:"
	rst.position = Vector2(20, 65); rst.add_theme_font_size_override("font_size", 16)
	guild_right_panel.add_child(rst)
	
	var diff_hbox = HBoxContainer.new()
	diff_hbox.position = Vector2(20, 100)
	diff_hbox.add_theme_constant_override("separation", 10)
	guild_right_panel.add_child(diff_hbox)
	
	for i in range(1, 6):
		var b = Button.new()
		b.text = str(i)
		b.custom_minimum_size = Vector2(80, 80)
		b.add_theme_font_size_override("font_size", 28)
		b.pressed.connect(func(): on_difficulty_selected(i))
		diff_hbox.add_child(b)
		diff_buttons.append(b)
		
	guild_diff_info = Label.new()
	guild_diff_info.position = Vector2(20, 210)
	guild_diff_info.size = Vector2(440, 140)
	guild_diff_info.autowrap_mode = TextServer.AUTOWRAP_WORD
	guild_diff_info.add_theme_font_size_override("font_size", 18)
	guild_diff_info.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	guild_right_panel.add_child(guild_diff_info)
	
	# Tombol READY
	btn_ready_guild = Button.new()
	btn_ready_guild.text = "READY"
	btn_ready_guild.position = Vector2(280, 380); btn_ready_guild.size = Vector2(180, 50)
	btn_ready_guild.add_theme_font_size_override("font_size", 20)
	btn_ready_guild.disabled = true
	btn_ready_guild.pressed.connect(_on_guild_ready_pressed)
	guild_right_panel.add_child(btn_ready_guild)

func update_guild_ui():
	guild_right_panel.visible = false
	selected_guild_map = ""
	for i in range(btn_maps.size()):
		var b = btn_maps[i]
		var m = b.text.replace(" (Coming Soon)", "").replace(" (Locked)", "")
		if m == "Crystaline Caverns":
			b.text = m
			b.disabled = false
		else:
			if Global.tutorial_step < 13:
				b.visible = false
			else:
				b.visible = true
				b.text = m + " (Coming Soon)"
				b.disabled = true

func select_guild_map(m):
	if m != "Crystaline Caverns": return
	selected_guild_map = m
	guild_right_panel.visible = true
	update_difficulty_buttons()

func update_difficulty_buttons():
	for i in range(5):
		var diff = i + 1
		var b = diff_buttons[i]
		b.disabled = false # Selalu bisa diklik
		
		# Visual Gembok
		if diff > 1 and Global.highest_difficulty_cleared < diff - 1:
			b.text = "🔒"
			b.modulate = Color(0.5, 0.5, 0.5) # Redup
		else:
			b.text = str(diff)
			b.modulate = Color(1, 1, 1) # Normal
			
	guild_diff_info.text = "Select a difficulty to start."
	btn_ready_guild.disabled = true

func on_difficulty_selected(diff):
	# Cek apakah masih terkunci
	if diff > 1 and Global.highest_difficulty_cleared < diff - 1:
		guild_diff_info.text = "Defeat Mega Spideroid on difficulty " + str(diff - 1) + " or defeat other boss on other map first!"
		btn_ready_guild.disabled = true
		
		# Reset highlight tombol
		for b in diff_buttons:
			b.modulate = Color(1, 1, 1)
		diff_buttons[diff - 1].modulate = Color(1, 0.3, 0.3) # Merah tanda error
		return
		
	# Jika terbuka, set difficulty dan tampilkan stats
	Global.current_difficulty = diff
	
	# Highlight tombol yang dipilih
	for i in range(5):
		if i == diff - 1:
			diff_buttons[i].modulate = Color(0.3, 1.0, 0.3) # Hijau
		else:
			diff_buttons[i].modulate = Color(1, 1, 1)
			
	# Teks Preview Stat
	if diff == 1:
		guild_diff_info.text = "Enemies in here are normal!"
	else:
		var hp_buff = (diff - 1) * 10
		var atk_buff = (diff - 1) * 5
		guild_diff_info.text = "Enemy HP +" + str(hp_buff) + "%\nEnemy Attack +" + str(atk_buff) + "%"
		
	btn_ready_guild.disabled = false

func _on_guild_ready_pressed():
	if selected_guild_map == "": return
	close_all_menus()
	open_prep_ui()

func start_crystaline_caverns():
	if Global.saved_inventory.has("Practice Arrow"):
		Global.saved_inventory.erase("Practice Arrow")
	# --- RESET T2 & T3 OBJECTIVE SETIAP MASUK ---
	Global.tutorial2_step = 0
	Global.tutorial3_step = 0
	# ---------------------------------------------
	Global.save_game()
	get_tree().change_scene_to_file("res://main.tscn")

func bikin_ui_prep(canvas: CanvasLayer):
	# --- 1. PANEL LATAR BELAKANG (FULL SCREEN) ---
	prep_panel = Panel.new()
	canvas.add_child(prep_panel) 
	prep_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prep_panel.z_index = -10 
	prep_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	prep_panel.visible = false
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.05, 0.05, 0.05, 0.95) 
	prep_panel.add_theme_stylebox_override("panel", st)
	
	# --- 2. TITLE ---
	prep_title = Label.new()
	prep_title.text = "Make sure you are all set!"
	prep_title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	prep_title.position = Vector2(-250, 80) # Digeser ke bawah biar gak ketutupan Hotbar
	prep_title.size = Vector2(500, 50)
	prep_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prep_title.add_theme_font_size_override("font_size", 36)
	prep_title.add_theme_color_override("font_color", Color.GOLD)
	prep_panel.add_child(prep_title)
	
	# --- 3. TOMBOL READY (Di bawah tengah) ---
	btn_ready_main = Button.new()
	btn_ready_main.text = "Ready!"
	btn_ready_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	btn_ready_main.position = Vector2(-100, -90)
	btn_ready_main.size = Vector2(200, 60)
	btn_ready_main.add_theme_font_size_override("font_size", 24)
	prep_panel.add_child(btn_ready_main)
	
	# TAMBAHKAN BARIS INI: 
	# Hover pakai suara biasa, tapi klik pakai suara "ready"
	Sfx.attach(btn_ready_main, "hover", "ready")
	btn_ready_main.pressed.connect(func(): check_ready_to_go())
	
	# --- 4. TOMBOL X CLOSE (Pojok Kanan Atas) ---
	var btn_close_prep = Button.new()
	btn_close_prep.text = "X"
	btn_close_prep.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	btn_close_prep.position = Vector2(-60, 20)
	btn_close_prep.size = Vector2(40, 40)
	btn_close_prep.add_theme_font_size_override("font_size", 20)
	btn_close_prep.pressed.connect(func(): close_all_menus())
	prep_panel.add_child(btn_close_prep)
	
	# --- 5. PANEL KONFIRMASI (POP-UP WARNING) ---
	confirm_panel = Panel.new()
	confirm_panel.size = Vector2(600, 220)
	confirm_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	confirm_panel.position = Vector2(-300, -110)
	confirm_panel.visible = false
	confirm_panel.z_index = 100 # Biar di depan
	var cs = StyleBoxFlat.new()
	cs.bg_color = Color(0.15, 0.03, 0.03, 0.98)
	cs.border_width_left = 2; cs.border_width_top = 2; cs.border_width_right = 2; cs.border_width_bottom = 2
	cs.border_color = Color.RED
	confirm_panel.add_theme_stylebox_override("panel", cs)
	canvas.add_child(confirm_panel) # Taruh di canvas, bukan prep_panel
	
	var warn_txt = Label.new()
	warn_txt.text = "Are you sure to bring some materials to the cave?\nIf you die, those materials vanish from your backpack\nand never come back!"
	warn_txt.position = Vector2(30, 20)
	warn_txt.size = Vector2(540, 100)
	warn_txt.add_theme_font_size_override("font_size", 16)
	warn_txt.add_theme_color_override("font_color", Color.WHITE)
	warn_txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warn_txt.autowrap_mode = TextServer.AUTOWRAP_WORD
	confirm_panel.add_child(warn_txt)
	
	var btn_confirm = Button.new()
	btn_confirm.text = "Ready!"
	btn_confirm.position = Vector2(100, 150)
	btn_confirm.size = Vector2(150, 45)
	btn_confirm.pressed.connect(func(): execute_start_crystaline())
	confirm_panel.add_child(btn_confirm)
	
	var btn_cancel = Button.new()
	btn_cancel.text = "Think Again"
	btn_cancel.position = Vector2(350, 150)
	btn_cancel.size = Vector2(150, 45)
	btn_cancel.pressed.connect(func(): confirm_panel.visible = false)
	confirm_panel.add_child(btn_cancel)

func open_prep_ui():
	close_all_menus()
	is_prep_open = true
	
	# Sembunyikan HUD
	if is_instance_valid(ui_objective_label): ui_objective_label.visible = false
	if is_instance_valid(ui_prompt): ui_prompt.visible = false
	if is_instance_valid(ui_gold_label): ui_gold_label.visible = false
	if is_instance_valid(ui_exp_label): ui_exp_label.visible = false
	for h in heart_labels:
		if is_instance_valid(h): h.visible = false
	for l in hotbar_ui_labels:
		if is_instance_valid(l) and is_instance_valid(l.get_parent()):
			l.get_parent().visible = false
	
	# Tampilkan layer hitam
	prep_panel.visible = true
	
	# Sembunyikan tombol CLOSE bawaan Storage
	for child in storage_panel.get_children():
		if child is Button and child.text == "CLOSE":
			child.visible = false
	
	# REPOSISI TENGAH (Kiri, Tengah, Kanan)
	char_panel.position = Vector2(50, 150) # Turunin dikit
	ui_inventory_panel.position = Vector2(580, 150) 
	storage_panel.position = Vector2(1170, 150) # Geser jauh ke kanan
	
	char_panel.visible = true
	ui_inventory_panel.visible = true
	storage_panel.visible = true
	
	# SET DEFAULT STORAGE KE ORE BIAR BISA NAMPUNG BARANG
	active_storage_type = "ore"
	switch_storage_tab("ore")
	
	update_char_ui()
	update_inventory_ui()
	update_storage_ui()
	
	player.set_physics_process(false)

func check_ready_to_go():
	var items = get_backpack_items()
	var extra_items = []
	for item in items:
		# Practice Arrow dikecualikan karena bakal hangus
		if item != "Practice Arrow":
			extra_items.append(item)
			
	if extra_items.size() > 0:
		confirm_panel.visible = true # Munculin warning
	else:
		execute_start_crystaline() # Langsung masuk

func execute_start_crystaline():
	close_all_menus()
	if Global.saved_inventory.has("Practice Arrow"):
		Global.saved_inventory.erase("Practice Arrow")
	# --- RESET T2 & T3 OBJECTIVE SETIAP MASUK ---
	Global.tutorial2_step = 0
	Global.tutorial3_step = 0
	# ---------------------------------------------
	Global.save_game()
	get_tree().change_scene_to_file("res://main.tscn")
	
func update_hp_ui():
	for i in range(10):
		if Global.current_hp >= (i + 1) * 10:
			heart_labels[i].text = "❤"
			heart_labels[i].add_theme_color_override("font_color", Color.RED)
		else:
			heart_labels[i].text = "♡"
			heart_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func _resume_post_t3_cutscene():
	if cutscene_active: return
	if not is_instance_valid(cutscene_panel): return
	
	cutscene_active = true
	cutscene_step = Global.post_t3_cutscene_step
	cutscene_panel.visible = true
	if is_instance_valid(player):
		player.set_physics_process(false)
	_show_cutscene_step(Global.post_t3_cutscene_step)

func bikin_ui_pause_home():
	var pause_canvas = CanvasLayer.new()
	pause_canvas.layer = 100
	pause_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_canvas)
	
	# 1. Layar Hitam (Awalnya disembunyikan)
	pause_blocker_home = ColorRect.new()
	pause_blocker_home.color = Color(0, 0, 0, 0.6)
	pause_blocker_home.size = get_viewport().get_visible_rect().size
	pause_blocker_home.visible = false
	pause_canvas.add_child(pause_blocker_home)
	
	# 2. Panel Utama (Diperbesar jadi 600x500)
	pause_panel_home = Panel.new()
	pause_panel_home.size = Vector2(600, 500)
	var vp = get_viewport().get_visible_rect().size
	pause_panel_home.position = Vector2(vp.x/2 - 300, vp.y/2 - 250)
	pause_panel_home.visible = false
	
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.08, 0.08, 0.1, 0.98) # Sedikit kebiruan gelap
	p_style.border_width_left = 3; p_style.border_width_top = 3; p_style.border_width_right = 3; p_style.border_width_bottom = 3
	p_style.border_color = Color.GOLD
	pause_panel_home.add_theme_stylebox_override("panel", p_style)
	pause_canvas.add_child(pause_panel_home)
	
	# 3. Isi Panel
	var p_title = Label.new()
	p_title.text = "GAME PAUSED"
	p_title.position = Vector2(0, 40)
	p_title.size = Vector2(600, 60)
	p_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p_title.add_theme_font_size_override("font_size", 48) # Font diperbesar
	p_title.add_theme_color_override("font_color", Color.GOLD)
	pause_panel_home.add_child(p_title)
	
	# Ukuran Tombol: 300x60, diposisikan di tengah (X = 150)
	var b_cont = Button.new()
	b_cont.text = "CONTINUE"
	b_cont.position = Vector2(150, 140)
	b_cont.size = Vector2(300, 60)
	b_cont.add_theme_font_size_override("font_size", 28)
	b_cont.pressed.connect(func(): 
		is_pause_home_open = false
		pause_panel_home.visible = false
		pause_blocker_home.visible = false
		get_tree().paused = false
		$Player.set_physics_process(true)
	)
	pause_panel_home.add_child(b_cont)
	Sfx.attach(b_cont) # <--- TAMBAHKAN INI
	
	var b_set = Button.new()
	b_set.text = "SETTINGS (Coming Soon)"
	b_set.position = Vector2(150, 230)
	b_set.size = Vector2(300, 60)
	b_set.add_theme_font_size_override("font_size", 24)
	b_set.disabled = true
	pause_panel_home.add_child(b_set)
	Sfx.attach(b_set) # <--- TAMBAHKAN INI (Aman, walaupun disabled)
	
	var b_quit = Button.new()
	b_quit.text = "QUIT TO MAIN MENU"
	b_quit.position = Vector2(150, 320)
	b_quit.size = Vector2(300, 60)
	b_quit.add_theme_font_size_override("font_size", 24)
	b_quit.pressed.connect(func():
		Global.save_game()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
	)
	pause_panel_home.add_child(b_quit)
	Sfx.attach(b_quit) # <--- TAMBAHKAN INI
	
	# Tambahan teks kecil di bawah
	var hint = Label.new()
	hint.text = "Press ESC to resume"
	hint.position = Vector2(0, 440)
	hint.size = Vector2(600, 30)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("color", Color.GRAY)
	pause_panel_home.add_child(hint)

func play_home_bgm():
	var path = "res://audio/bgm_home_" + str(Global.home_bgm_index) + ".mp3"
	MusicManager.play_bgm(path)

func change_home_music(index: int):
	Global.home_bgm_index = index
	Global.save_game() # Simpan pilihan player
	play_home_bgm()

func bikin_ui_music_player(canvas: CanvasLayer):
	music_player_panel = Panel.new()
	music_player_panel.size = Vector2(500, 400)
	var vp_size = get_viewport().get_visible_rect().size
	music_player_panel.position = (vp_size - music_player_panel.size) / 2.0
	music_player_panel.visible = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.5, 0.2)
	music_player_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(music_player_panel)
	
	var title = Label.new()
	title.text = "Music Player"
	title.position = Vector2(20, 20)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.GOLD)
	music_player_panel.add_child(title)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(30, 80)
	vbox.size = Vector2(440, 250)
	vbox.add_theme_constant_override("separation", 15)
	music_player_panel.add_child(vbox)
	
	# Daftar lagu (Nama Kreator - Judul Lagu)
	var songs = [
		{"id": 1, "text": "Turning Pages - Beyond the Tall Grass"},
		{"id": 2, "text": "Turning Pages - Horizon Call"}, # <--- UBAH DI SINI
		{"id": 3, "text": "Unknown Creator - Song 3 (Placeholder)"},
		{"id": 4, "text": "Unknown Creator - Song 4 (Placeholder)"}
	]
	
	for song in songs:
		var btn = Button.new()
		btn.text = song["text"]
		btn.custom_minimum_size = Vector2(440, 45)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(func(): 
			change_home_music(song["id"])
			close_music_player_ui()
		)
		vbox.add_child(btn)
		
	var btn_close = Button.new()
	btn_close.text = "CLOSE"
	btn_close.position = Vector2(200, 340)
	btn_close.size = Vector2(100, 40)
	btn_close.pressed.connect(close_music_player_ui)
	music_player_panel.add_child(btn_close)

func open_music_player_ui():
	is_music_player_open = true
	music_player_panel.visible = true

func close_music_player_ui():
	is_music_player_open = false
	music_player_panel.visible = false
	player.set_physics_process(true)
