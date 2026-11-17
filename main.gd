extends Node2D

@onready var world = $World

const BLOCK_SIZE = 16
const WORLD_WIDTH = 300
const WORLD_DEPTH = 1200

# --- VARIABEL MINING ---
var target_block: Vector2i = Vector2i(-1, -1)
var mine_timer: float = 0.0
const MAX_DISTANCE: float = 96.0 
const PLACE_DISTANCE: float = 120.0 
var crack_sprite: Sprite2D
var dungeon_gold: int = 0

# Daftar ID Tile (DIPERLUAS)
const TILE_DIRT = 0
const TILE_COAL = 1
const TILE_IRON = 2
const TILE_COPPER = 3
const TILE_GRAVEL = 4
const TILE_STONE = 5
const TILE_SILVER = 6
const TILE_GOLD = 7
const TILE_MITHRIL = 8
# T3 Ores
const TILE_QUARTZ = 9
const TILE_TOPAZ = 10
const TILE_EMERALD = 11
const TILE_AMETHYST = 12
const TILE_DIAMOND = 13
const TILE_VOID = 14
const TILE_UBERILIUM = 15
# T3 Blocks
const TILE_CRYSTAL_STONE = 16
const TILE_HARDENED_STONE = 17

# --- VARIABEL DATA ITEM ---
var item_data = {
	# Senjata dasar
	"Fist": {"color": Color(0.9, 0.7, 0.5), "tile": -1, "damage": 4, "range": 64.0, "attack_speed": 0.25, "knockback": 4.0, "weapon_type": "Physical Damage"},
	"Wooden Sword": {"color": Color(0.6, 0.4, 0.1), "tile": -1, "damage": 15, "range": 64.0, "attack_speed": 0.4, "knockback": 8.0, "weapon_type": "Physical Damage"},
	"Stone Pickaxe": {"color": Color(0.4, 0.4, 0.4), "tile": -1, "damage": 10, "range": 96.0, "attack_speed": 0.7, "knockback": 10.0, "efficiency": 1.0, "weapon_type": "Physical Damage"},
	"Bow": {"color": Color(0.6, 0.4, 0.2), "tile": -1, "damage": 7, "charge_damage": 20, "range": 300.0, "attack_speed": 0.5, "charge_speed": 1.0, "knockback": 0.0, "weapon_type": "Physical Damage"},
	
	# --- TAMBAHKAN SENJATA BARU INI ---
	"Menacing Dagger": {"color": Color(0.5, 0.5, 0.8), "tile": -1, "damage": 16, "range": 64.0, "attack_speed": 0.3, "knockback": 2.0, "weapon_type": "Elemental Damage"},
	"Maniacal Chainsaw": {"color": Color(0.8, 0.2, 0.2), "tile": -1, "damage": 11, "range": 48.0, "attack_speed": 0.1, "knockback": 0.0, "weapon_type": "Physical Damage", "trait": "DoT (Bleed)", "passive": "Attack rapidly with insane speed, beware for exhausted machine for 4 seconds after used"},
	"Hunter Bow": {"color": Color(0.2, 0.6, 0.2), "tile": -1, "damage": 15, "charge_damage": 25, "range": 350.0, "attack_speed": 0.6, "charge_speed": 1.0, "knockback": 0.0, "weapon_type": "Physical Damage"},
	"Heretic Staff": {"color": Color(0.6, 0.1, 0.6), "tile": -1, "damage": 32, "range": 384.0, "attack_speed": 1.2, "knockback": 0.0, "weapon_type": "Magic Damage"},
	"Iron Sword": {"color": Color(0.8, 0.8, 0.8), "tile": -1, "damage": 20, "range": 64.0, "attack_speed": 0.5, "knockback": 6.0, "weapon_type": "Physical Damage"},
	"Iron Pickaxe": {"color": Color(0.8, 0.8, 0.8), "tile": -1, "damage": 20, "range": 96.0, "attack_speed": 0.8, "efficiency": 2.0, "knockback": 12.0, "weapon_type": "Physical Damage"},
	"Iron Bow": {"color": Color(0.8, 0.8, 0.8), "tile": -1, "damage": 12, "charge_damage": 28, "range": 300.0, "attack_speed": 0.5, "charge_speed": 1.0, "knockback": 0.0, "weapon_type": "Physical Damage"},
	"Iron Armor": {"color": Color(0.8, 0.8, 0.8), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "damage_reduction": 6, "weapon_type": "Armor"},
	# --- BOSS DROP WEAPONS ---
	"Heavy Amethyst Armor": {"color": Color(0.6, 0.2, 0.9), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Rare", "damage_reduction": 13, "passive": "When taking >10 dmg, next hit takes 5 less dmg."},
	"Marble Slingshot": {"color": Color(0.8, 0.8, 0.8), "tile": -1, "damage": 15, "charge_damage": 32, "range": 300.0, "attack_speed": 0.5, "charge_speed": 0.8, "knockback": 0.0, "weapon_type": "Physical Damage", "rarity": "Epic", "trait": "Burst", "passive": "Charge attack splits into 8 projectiles (10% dmg each)."},
	"Blueprint Ricochet Bow": {"color": Color(0.8, 0.9, 0.2), "tile": -1, "rarity": "Uncommon", "blueprint_for": "Ricochet Bow", "domain_source": "Domain of Tricks", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Ricochet Bow": {"color": Color(0.8, 0.9, 0.2), "tile": -1, "damage": 15, "charge_damage": 28, "range": 384.0, "attack_speed": 0.6, "charge_speed": 0.4, "knockback": 0.0, "weapon_type": "Physical Damage", "rarity": "Uncommon", "trait": "Focused", "passive": "Charge attack has a 20% chance to ricochet to the nearest enemy. Bounced shots can also ricochet.", "craft_cost": 260, "craft_recipe": {"Iron Bar": 4, "Mithril Bar": 2, "Silver Bar": 4}},
	"Blueprint Bounty Bow": {"color": Color(0.5, 0.8, 1.0), "tile": -1, "rarity": "Rare", "blueprint_for": "Bounty Bow", "domain_source": "Domain of Precision", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Bounty Bow": {"color": Color(0.5, 0.8, 1.0), "tile": -1, "damage": 20, "charge_damage": 35, "range": 480.0, "attack_speed": 0.7, "charge_speed": 0.7, "knockback": 10.0, "weapon_type": "Magic Damage", "rarity": "Rare", "trait": "Focused", "passive": "Hits apply Bounty. Killing a bountied enemy grants +20% damage (max 5 stacks). Stacks reset if no bountied kill within 7s.", "craft_cost": 590, "craft_recipe": {"Mithril Bar": 5, "Silver Bar": 5, "Topaz Bar": 3, "Quartz Bar": 3}},
	"Blueprint Radiance Scepter": {"color": Color(1.0, 0.9, 0.5), "tile": -1, "rarity": "Uncommon", "blueprint_for": "Radiance Scepter", "domain_source": "Domain of Believer", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Radiance Scepter": {"color": Color(1.0, 0.9, 0.5), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 1.5, "knockback": 0.0, "weapon_type": "Magic Damage", "rarity": "Uncommon", "trait": "Focused", "passive": "Self-heal utility. Cannot deal damage. Uses 25 Mana to heal 12 HP (scales with level).", "mana_cost": 25, "heal_amount": 12, "craft_cost": 300, "craft_recipe": {"Topaz Bar": 4, "Emerald Crystal": 2, "Amethyst": 2}},
	"Blueprint Sticky Crossbow": {"color": Color(0.5, 0.7, 0.3), "tile": -1, "rarity": "Rare", "blueprint_for": "Sticky Crossbow", "domain_source": "Domain of Cheap", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Sticky Crossbow": {"color": Color(0.5, 0.7, 0.3), "tile": -1, "damage": 13, "charge_damage": 27, "range": 320.0, "attack_speed": 0.6, "charge_speed": 1.0, "knockback": 0.0, "weapon_type": "Elemental Damage", "rarity": "Rare", "trait": "CC", "passive": "Grappling hook: Pulls player to target. Immobilizes enemies for 3s.", "craft_cost": 530, "craft_recipe": {"Diamond": 3, "Uberilium Bar": 2, "Stable Crystal": 3, "Silver Bar": 5}},
	"Blueprint Headhitter Heavy Bow": {"color": Color(0.8, 0.2, 0.2), "tile": -1, "rarity": "Rare", "blueprint_for": "Headhitter Heavy Bow", "domain_source": "Domain of Power", "weapon_class": "Range", "desc": "Use this on Forge Station to unlock recipe."},
	"Headhitter Heavy Bow": {"color": Color(0.8, 0.2, 0.2), "tile": -1, "damage": 26, "charge_damage": 42, "range": 320.0, "attack_speed": 0.8, "charge_speed": 1.2, "knockback": 64.0, "weapon_type": "Physical Damage", "rarity": "Rare", "trait": "Focused", "passive": "Full charge fires a wider projectile with massive knockback. Deals +50% damage to enemies below 30% HP.", "craft_cost": 650, "craft_recipe": {"Diamond": 4, "Amethyst": 4, "Emerald Crystal": 4, "Stable Crystal": 4}},
	"Explosive Crossbow": {"color": Color(0.6, 0.3, 0.1), "tile": -1, "damage": 18, "charge_damage": 78, "range": 250.0, "attack_speed": 0.5, "charge_speed": 3.0, "knockback": 0.0, "weapon_type": "Physical Damage", "rarity": "Epic", "trait": "AoE", "passive": "Charge attack explodes in a 4-block radius."},
	"Sharding Sword": {"color": Color(0.8, 0.4, 0.9), "tile": -1, "damage": 21, "charge_damage": 49, "range": 56.0, "attack_speed": 0.6, "charge_speed": 2.0, "knockback": 0.0, "weapon_type": "Magic Damage", "rarity": "Epic", "trait": "Burst", "passive": "Hits reduce enemy magic resistance by 20%."},
	"Swarmid Drill": {"color": Color(0.1, 0.9, 0.3), "tile": -1, "damage": 5, "range": 64.0, "attack_speed": 0.25, "efficiency": 5.0, "knockback": 0.0, "weapon_type": "Elemental Damage", "rarity": "Rare", "passive": "Mining breaks a 3x3 area."},
	"Galahad Chimelin": {"color": Color(1.0, 0.8, 0.2), "tile": -1, "damage": 65, "range": 80.0, "attack_speed": 1.0, "knockback": 48.0, "weapon_type": "Physical Damage", "rarity": "Legendary", "trait": "Burst", "passive": "Kill enemies to gain +1% dmg (max +80%). Right click to Parry."},
	# ----------------------------------
	
	# --- T3 CRAFTED WEAPONS ---
	"Mourning Bow": {"color": Color(0.2, 0.6, 0.8), "tile": -1, "damage": 15, "charge_damage": 36, "range": 350.0, "attack_speed": 0.5, "charge_speed": 1.2, "knockback": 0.0, "weapon_type": "Elemental Damage", "rarity": "Epic", "trait": "CC", "passive": "Every charge shot fires a web that stuns enemies for 2 seconds."},
	"Crystal Minigun": {"color": Color(0.8, 0.2, 0.5), "tile": -1, "damage": 12, "range": 208.0, "attack_speed": 0.1, "knockback": 0.0, "weapon_type": "Physical Damage", "rarity": "Legendary", "trait": "Burst", "passive": "Every 10th shot releases a boulder that deals AoE 3x3 damage (+30% bonus)."},
	"Crystal Armor": {"color": Color(0.4, 0.8, 1.0), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Epic", "damage_reduction": 16, "trait": "", "passive": "Gain 1 crystal stack per hit (max 10, each +0.5% DR)."},
	
	# --- T3 ARMOR BLUEPRINTS ---
	"Blueprint Metal Skin Armor": {"color": Color(0.6, 0.6, 0.65), "tile": -1, "rarity": "Uncommon", "blueprint_for": "Metal Skin Armor", "domain_source": "Domain of Tricks", "weapon_class": "Armor", "desc": "Use this on Forge Station to unlock recipe."},
	"Metal Skin Armor": {"color": Color(0.6, 0.6, 0.65), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Uncommon", "damage_reduction": 10, "trait": "", "passive": "Reflect 20% melee damage to nearest enemy (100 radius)."},
	"Blueprint Shining Justice": {"color": Color(1.0, 0.9, 0.5), "tile": -1, "rarity": "Uncommon", "blueprint_for": "Shining Justice", "domain_source": "Domain of Precision", "weapon_class": "Armor", "desc": "Use this on Forge Station to unlock recipe."},
	"Shining Justice": {"color": Color(1.0, 0.9, 0.5), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Uncommon", "damage_reduction": 9, "trait": "", "passive": "35% chance drop random ore when hit."},
	"Blueprint Tenacity Battle Armor": {"color": Color(0.3, 0.6, 0.7), "tile": -1, "rarity": "Rare", "blueprint_for": "Tenacity Battle Armor", "domain_source": "Domain of Power", "weapon_class": "Armor", "desc": "Use this on Forge Station to unlock recipe."},
	"Tenacity Battle Armor": {"color": Color(0.3, 0.6, 0.7), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Rare", "damage_reduction": 15, "trait": "", "passive": "40% chance reflect projectiles back to nearest enemy (400 radius)."},
	"Blueprint Deep Cave Armor": {"color": Color(0.4, 0.3, 0.2), "tile": -1, "rarity": "Rare", "blueprint_for": "Deep Cave Armor", "domain_source": "Domain of Believer", "weapon_class": "Armor", "desc": "Use this on Forge Station to unlock recipe."},
	"Deep Cave Armor": {"color": Color(0.4, 0.3, 0.2), "tile": -1, "damage": 0, "range": 0.0, "attack_speed": 0.0, "knockback": 0.0, "weapon_type": "Armor", "rarity": "Rare", "damage_reduction": 13, "trait": "", "passive": "When HP < 50%: petrify 2s (invulnerable, regen 7 HP/s). CD 30s."},
	
	# --- T3 BLUEPRINT WEAPONS ---
	"Blueprint Silver Gray Sword": {"color": Color(0.75, 0.75, 0.8), "rarity": "Uncommon", "blueprint_for": "Silver Gray Sword", "domain_source": "Domain of Tricks", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Silver Gray Sword": {"color": Color(0.75, 0.75, 0.8), "tile": -1, "damage": 23, "range": 64.0, "attack_speed": 0.5, "knockback": 4.0, "weapon_type": "Physical Damage", "rarity": "Uncommon", "trait": "Burst", "passive": "Every 5th hit adds 1 Accelerate stack (+10% attack speed, max 5 = +50%).", "craft_cost": 240, "craft_recipe": {"Silver": 5, "Iron": 5, "Copper": 2}},
	"Blueprint Golden Conductor": {"color": Color(1.0, 0.8, 0.2), "rarity": "Rare", "blueprint_for": "Golden Conductor", "domain_source": "Domain of Brutality", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Golden Conductor": {"color": Color(1.0, 0.8, 0.2), "tile": -1, "damage": 54, "range": 48.0, "attack_speed": 1.0, "knockback": 10.0, "weapon_type": "Elemental Damage", "rarity": "Rare", "trait": "AoE", "passive": "Hold left-click to charge 3s. Nearby enemies take 5% weapon dmg while charging. Release for 2x7 AoE explosion (+70% dmg)."},
	
	"Blueprint Stormjade Cutter": {"color": Color(0.2, 0.9, 0.5), "rarity": "Rare", "blueprint_for": "Stormjade Cutter", "domain_source": "Domain of Cheap", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Stormjade Cutter": {"color": Color(0.2, 0.9, 0.5), "tile": -1, "damage": 25, "range": 64.0, "attack_speed": 0.7, "knockback": 4.0, "weapon_type": "Elemental Damage", "rarity": "Rare", "trait": "Burst", "passive": "Right-click charge 3s, then dash 8 blocks through all enemies. Base +50% dmg, +25% per subsequent enemy hit (max +200%)."},
	
	"Blueprint Revenger Crystallinum": {"color": Color(0.3, 0.7, 0.9), "rarity": "Uncommon", "blueprint_for": "Revenger Crystallinum", "domain_source": "Domain of Power", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Revenger Crystallinum": {"color": Color(0.3, 0.7, 0.9), "tile": -1, "damage": 17, "range": 48.0, "attack_speed": 0.3, "knockback": 2.0, "weapon_type": "Physical Damage", "rarity": "Uncommon", "trait": "Burst", "passive": "When hit by an enemy, gain +30% damage against that enemy only (max 3 stacks = +90%). Reset after 5s."},
	
	"Blueprint Crystal Hammer": {"color": Color(0.4, 0.8, 1.0), "rarity": "Uncommon", "blueprint_for": "Crystal Hammer", "domain_source": "Domain of Durability", "weapon_class": "Melee", "desc": "Use this on Forge Station to unlock recipe."},
	"Blueprint Bonecrusher": {"color": Color(0.6, 0.4, 0.2), "rarity": "Rare", "blueprint_for": "Bonecrusher", "domain_source": "Domain of Brutality", "weapon_class": "Tool", "desc": "Use this on Forge Station to unlock recipe."},
	"Blueprint Magic Pickaxe": {"color": Color(0.5, 0.3, 0.9), "rarity": "Uncommon", "blueprint_for": "Magic Pickaxe", "domain_source": "Domain of Believer", "weapon_class": "Tool", "desc": "Use this on Forge Station to unlock recipe."},
	"Blueprint Pneumatic Drill": {"color": Color(0.4, 0.5, 0.6), "rarity": "Rare", "blueprint_for": "Pneumatic Drill", "domain_source": "Domain of Durability", "weapon_class": "Tool", "desc": "Use this on Forge Station to unlock recipe."},
	"Crystal Hammer": {"color": Color(0.4, 0.8, 1.0), "tile": -1, "damage": 48, "range": 48.0, "attack_speed": 1.0, "knockback": 10.0, "weapon_type": "Magic Damage", "rarity": "Uncommon", "trait": "CC", "passive": "Right-click charge 2s. On hit: enemies in 2x4 area stunned 1.5s. On kill: 35% chance drop random ore."},
	
	# --- T3 MINING TOOLS (Blueprint) ---
	"Bonecrusher": {"color": Color(0.6, 0.4, 0.2), "tile": -1, "damage": 11, "range": 96.0, "attack_speed": 0.7, "efficiency": 5.0, "knockback": 10.0, "weapon_type": "Physical Damage", "rarity": "Rare", "trait": "", "passive": "Mining breaks adjacent toughness."},
	"Magic Pickaxe": {"color": Color(0.5, 0.3, 0.9), "tile": -1, "damage": 9, "range": 320.0, "attack_speed": 0.7, "efficiency": 4.0, "knockback": 0.0, "weapon_type": "Magic Damage", "rarity": "Uncommon", "trait": "", "passive": "Beam mining up to 20 blocks."},
	"Pneumatic Drill": {"color": Color(0.4, 0.5, 0.6), "tile": -1, "damage": 10, "range": 64.0, "attack_speed": 0.4, "efficiency": 5.0, "knockback": 10.0, "weapon_type": "Physical Damage", "rarity": "Rare", "trait": "", "passive": "30% chance bomb on break."},
	
	# Block & Ore Items
	"Dirt": {"color": Color(0.55, 0.27, 0.07), "tile": TILE_DIRT},
	"Coal": {"color": Color(0.15, 0.15, 0.15), "tile": TILE_COAL},
	"Iron": {"color": Color(0.7, 0.3, 0.2), "tile": TILE_IRON},
	"Copper": {"color": Color(0.8, 0.5, 0.1), "tile": TILE_COPPER},
	"Gravel": {"color": Color(0.6, 0.6, 0.6), "tile": TILE_GRAVEL},
	"Stone": {"color": Color(0.5, 0.5, 0.5), "tile": TILE_STONE},
	"Silver": {"color": Color(0.8, 0.8, 0.9), "tile": TILE_SILVER},
	"Gold": {"color": Color(1.0, 0.8, 0.1), "tile": TILE_GOLD},
	"Mithril": {"color": Color(0.2, 0.9, 1.0), "tile": TILE_MITHRIL},
	# T3 Ores
	"Quartz": {"color": Color(0.9, 0.9, 0.95), "tile": TILE_QUARTZ},
	"Topaz": {"color": Color(1.0, 0.6, 0.1), "tile": TILE_TOPAZ},
	"Emerald": {"color": Color(0.1, 0.9, 0.3), "tile": TILE_EMERALD},
	"Amethyst": {"color": Color(0.6, 0.2, 0.9), "tile": TILE_AMETHYST},
	"Diamond": {"color": Color(0.4, 0.9, 1.0), "tile": TILE_DIAMOND},
	"Void Crystal": {"color": Color(0.3, 0.0, 0.5), "tile": TILE_VOID},
	"Uberilium": {"color": Color(0.0, 1.0, 0.7), "tile": TILE_UBERILIUM},
	"Scrap": {"color": Color(0.6, 0.5, 0.4), "tile": -1},
	"Essence Crystal": {"color": Color(0.8, 0.2, 1.0), "tile": -1},
	
	# T3 Blocks
	"Crystal Stone": {"color": Color(0.4, 0.5, 0.7), "tile": TILE_CRYSTAL_STONE},
	"Hardened Crystal Stone": {"color": Color(0.2, 0.2, 0.3), "tile": TILE_HARDENED_STONE},
	
	# Sisa Item
	"Flint": {"color": Color(0.3, 0.3, 0.3), "tile": -1},
	"Stick": {"color": Color(0.4, 0.25, 0.1), "tile": -1},
	"Torch": {"color": Color(1.0, 0.8, 0.2), "tile": -2},
	"Arrow": {"color": Color(0.7, 0.7, 0.7), "tile": -1},
	"Minigun Ammo": {"color": Color(0.8, 0.5, 0.1), "tile": -1},
	"Food Box": {"color": Color(0.9, 0.5, 0.5), "tile": -3},
	"Bomb": {"color": Color(0.1, 0.1, 0.1), "tile": -4},
	
	# --- WEAPON PARTS (Dasar) ---
	"Dagger Part": {"color": Color(0.5, 0.5, 0.8), "tile": -1},
	"Chainsaw Part": {"color": Color(0.8, 0.2, 0.2), "tile": -1},
	"Hunter Bow Part": {"color": Color(0.2, 0.6, 0.2), "tile": -1},
	"Heretic Staff Part": {"color": Color(0.6, 0.1, 0.6), "tile": -1},
	"Mourning Bow Part": {"color": Color(0.2, 0.6, 0.8), "tile": -1},
	"Crystal Minigun Part": {"color": Color(0.8, 0.2, 0.5), "tile": -1},
	"Crystal Armor Part": {"color": Color(0.4, 0.8, 1.0), "tile": -1},
	
	# --- WEAPON PARTS 💀 (Drop dari Monster) ---
	"Dagger Part 💀": {"color": Color(0.5, 0.5, 0.8), "tile": -1},
	"Chainsaw Part 💀": {"color": Color(0.8, 0.2, 0.2), "tile": -1},
	"Hunter Bow Part 💀": {"color": Color(0.2, 0.6, 0.2), "tile": -1},
	"Heretic Staff Part 💀": {"color": Color(0.6, 0.1, 0.6), "tile": -1},
	"Mourning Bow Part 💀": {"color": Color(0.2, 0.6, 0.8), "tile": -1},
	"Crystal Minigun Part 💀": {"color": Color(0.8, 0.2, 0.5), "tile": -1},
	"Crystal Armor Part 💀": {"color": Color(0.4, 0.8, 1.0), "tile": -1},
	
	# --- WEAPON PARTS ⛏️ (Drop dari Nambang) ---
	"Dagger Part ⛏️": {"color": Color(0.5, 0.5, 0.8), "tile": -1},
	"Chainsaw Part ⛏️": {"color": Color(0.8, 0.2, 0.2), "tile": -1},
	"Hunter Bow Part ⛏️": {"color": Color(0.2, 0.6, 0.2), "tile": -1},
	"Heretic Staff Part ⛏️": {"color": Color(0.6, 0.1, 0.6), "tile": -1},
	"Mourning Bow Part ⛏️": {"color": Color(0.2, 0.6, 0.8), "tile": -1},     # <--- BARU
	"Crystal Minigun Part ⛏️": {"color": Color(0.8, 0.2, 0.5), "tile": -1},  # <--- BARU
	"Crystal Armor Part ⛏️": {"color": Color(0.4, 0.8, 1.0), "tile": -1},    # <--- BARU
	
	# --- WEAPON PARTS ⚔️ (Drop dari Peti Bos) ---
	"Dagger Part ⚔️": {"color": Color(0.5, 0.5, 0.8), "tile": -1},
	"Chainsaw Part ⚔️": {"color": Color(0.8, 0.2, 0.2), "tile": -1},
	"Hunter Bow Part ⚔️": {"color": Color(0.2, 0.6, 0.2), "tile": -1},
	"Heretic Staff Part ⚔️": {"color": Color(0.6, 0.1, 0.6), "tile": -1},
	"Mourning Bow Part ⚔️": {"color": Color(0.2, 0.6, 0.8), "tile": -1},     # <--- BARU
	"Crystal Minigun Part ⚔️": {"color": Color(0.8, 0.2, 0.5), "tile": -1},  # <--- BARU
	"Crystal Armor Part ⚔️": {"color": Color(0.4, 0.8, 1.0), "tile": -1},    # <--- BARU
	
	# Broken Tools (Hanya 1 versi, tanpa tambahan)
	"Broken Tools": {"color": Color(0.4, 0.2, 0.1), "tile": -1},
	
	# Makanan
	# Makanan
	"Banana": {"color": Color(1.0, 0.9, 0.2), "tile": -1, "desc": "+20 HP (Instant)"},
	"Grape": {"color": Color(0.6, 0.2, 0.8), "tile": -1, "desc": "+5 HP per second (6s)"},
	"Bacon": {"color": Color(0.8, 0.3, 0.3), "tile": -1, "desc": "+30 HP & Damage Reduction (8s)"},
	"Pizza Slice": {"color": Color(1.0, 0.6, 0.2), "tile": -1, "desc": "+5 HP & +50% Damage (8s)"},
	"Burger": {"color": Color(0.7, 0.4, 0.2), "tile": -1, "desc": "+40% Speed & +80% Damage (10s)"},
	"Golden Burger": {"color": Color(1.0, 0.8, 0.1), "tile": -1, "desc": "INVINCIBLE (8s)"},
	"Frozen Apple": {"color": Color(0.4, 0.8, 1.0), "tile": -1, "desc": "Freeze all enemies (8s)"}
}

# --- VARIABEL INVENTORY & UI ---
var inventory = {}
var ui_inventory_panel: Panel
var slot_nodes = [] 
var is_inventory_open = false
var inv_hotbar_slots = []
var selected_inv_item = null

# --- VARIABEL UI TUTORIAL 2 ---
var tutorial2_step = 0 
var tutorial2_stats = {"sticks": 0}
var ui_objective_label: Label
var ui_layer_label: Label
var ui_buff_label: Label
var ui_dialog_panel: Panel
var ui_dialog_text: Label
var ui_prompt: Label

# Tracker untuk UI timer efek makanan
var active_food_buffs = {
	"Bacon (DR)": 0.0,
	"Pizza (Dmg)": 0.0,
	"Burger (Spd/Dmg)": 0.0,
	"Golden Burger (Inv)": 0.0,
	"Grape (Regen)": 0.0,
	"Frozen Apple (Freeze)": 0.0
}

# --- VARIABEL KARAKTER (I) ---
var is_char_open = false
var char_panel: Panel
var char_slot_labels = []
var char_slots_panels = []
# HAPUS ATAU KOMENTARI: var tooltip_char: Label 

# TAMBAHKAN VARIABEL HOVER INI:
var char_hover_panel: Panel
var char_hover_name: Label
var char_hover_stats: Label
# --- VARIABEL CRAFTING ---
var ui_crafting_panel: Panel
var is_crafting_open = false
var pause_panel_main: Control
var pause_blocker_main: ColorRect
var is_pause_main_open: bool = false

var abort_confirm_panel: Panel
var abort_blocker: ColorRect

var btn_torch: Button
var btn_arrow: Button
var btn_minigun_ammo: Button

# --- VARIABEL HOTBAR ---
var hotbar_items = [] # Akan diisi dari Global
var selected_hotbar_index = 0
var hotbar_ui_labels = []

# --- VARIABEL HP, EXP & NYAWA ---
var max_hp = 100
var current_hp = 100
var heart_labels = []
var lives = 3
var is_dead = false
var player_stun_timer = 0.0
var player_slow_timer = 0.0
var damage_cooldown = 0.0
var regen_timer = 0.0 
var dungeon_level = 0
var dungeon_exp = 0
var dungeon_exp_to_next_level = 10

# --- PASSIVE T3 WEAPONS ---
var minigun_shot_count: int = 0
# --- MINING TOOL BLUEPRINT STATE ---
var _bonecrusher_reduced: Dictionary = {}  # Vector2i -> int (0-3)
var _pneumatic_weakened: Dictionary = {}
var _pneumatic_bombs: Array = []
var _magic_beam_line: Line2D = null
var _magic_beam_dmg_cd: float = 0.0
var crystal_armor_stacks = 0
var crystal_armor_timer = 0.0
# --- ADJUSTMENTS ---
var chainsaw_use_timer = 0.0
var chainsaw_exhausted_timer = 0.0
var sgs_reset_timer = 0.0
var minigun_fire_timer = 0.0
var minigun_exhausted_timer = 0.0
# --- MELEE BLUEPRINT PASSIVES a---
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
var ui_exp_label: Label
var ui_lives_label: Label
var boss_hp_ui: Control
var boss_hp_bar: ColorRect
var ui_death_label: Label

# --- VARIABEL BUFF & STATUS ---
var buff_efficiency = 0.0
var buff_dmg_mult = 1.0
var buff_speed_mult = 1.0
var buff_atk_speed_mult = 1.0
var dmg_reduction = 0.0 
var freeze_timer = 0.0

var all_buffs = [
	{"id": "eff", "text": "+1 Mining Efficiency"},
	{"id": "hp", "text": "+20 HP (Heal)"},
	{"id": "dmg", "text": "+5% Damage"},
	{"id": "speed", "text": "+3% Movement Speed"},
	{"id": "atkspd", "text": "+5% Attack Speed"}
]
var ui_buff_panel: Panel
var is_buff_selecting = false

# --- VARIABEL COMBAT & LIGHTING ---
var enemies = []
var domains = []
var saved_domains = {}
var bridge_bodies = []  # Daftar StaticBody2D jembatan
var is_dropping_through_bridge = false
var chests = []
var lore_logs: Array = []
var level_start_time = 0
var lift_nodes: Array = []
var checkpoint_nodes: Array = []
var last_checkpoint_pos: Vector2 = Vector2.ZERO
var is_lifting = false
var arrows = [] 
var is_charging_bow = false
var attack_cooldown = 0.0
var swarmid_use_timer: float = 0.0
var swarmid_exhausted_timer: float = 0.0
var bounty_bow_stacks: int = 0
var bounty_stack_timer: float = 0.0
var sword_combo = 0
var current_music_zone: int = -1
var zone_bgm_times = {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0} # <--- TAMBAHKAN INI
var boss_silence_triggered: bool = false

# --- MANA SYSTEM ---
var max_mana = 100
var current_mana = 100.0
var mana_regen_timer = 0.0

var canvas_mod: CanvasModulate
var player_light: PointLight2D
var ui_tooltip: Label 
var is_spectating = false
var player_poly: Polygon2D

# --- VARIABEL TUTORIAL 1 ---
var is_tutorial_active = true
var current_objective_index = 0
var tutorial_stats = {"flint": 0, "arrows": 0, "charged_bow": 0, "coal": 0, "torches": 0, "placed_torches": 0, "copper": 0, "iron": 0, "goblins_killed": 0, "lift": 0}
var objectives = [
	{"text": "Obtain Flint from Gravel", "stat": "flint", "target": 5},
	{"text": "Craft some arrows", "stat": "arrows", "target": 5},
	{"text": "Right click on bow to charged attack", "stat": "charged_bow", "target": 1},
	{"text": "Obtain Coal", "stat": "coal", "target": 5},
	{"text": "Craft some torches", "stat": "torches", "target": 5},
	{"text": "Place down torches", "stat": "placed_torches", "target": 3},
	{"text": "Obtain Copper", "stat": "copper", "target": 10},
	{"text": "Obtain Iron", "stat": "iron", "target": 10},
	{"text": "Kill the Goblin", "stat": "goblins_killed", "target": 3},
	{"text": "Find a lift", "stat": "lift", "target": 1}
]

var is_boss_arena_locked = false
var galahad_stacks = 0
var galahad_parry_active = false
var galahad_parry_cd = 0.0

func _ready():
	Global.dungeon_start_gold = Global.gold_coins
	MusicManager.play_bgm("res://audio/bgm_caverns.ogg")
	process_mode = Node.PROCESS_MODE_ALWAYS
	level_start_time = Time.get_ticks_msec()
	
	# --- RESET TUTORIAL OBJECTIVE SETIAP ENTER MAIN (fresh mission) ---
	if Global.tutorial_step == 3:
		Global.tutorial2_step = 0
	if Global.tutorial_step == 8:
		Global.tutorial3_step = 0
	# ------------------------------------------------------------------
	
	# Backup despawn Practice Arrow (kalau player force close)
	if Global.saved_inventory.has("Practice Arrow"):
		Global.saved_inventory.erase("Practice Arrow")
	
	# --- SINKRONISASI SENJATA DARI HOME ---
	hotbar_items = Global.hotbar_items.duplicate()
	
	bikin_efek_retak()
	bikin_ui_hotbar()
	bikin_ui_inventory()
	bikin_ui_character()
	bikin_ui_crafting() 
	bikin_ui_hp_dan_nyawa()
	bikin_ui_buff()
	bikin_ui_tutorial2()
	
	# 1. Setup LIGHTING
	canvas_mod = CanvasModulate.new()
	canvas_mod.color = Color(0.1, 0.1, 0.15) 
	add_child(canvas_mod)
	
	player_light = PointLight2D.new()
	player_light.texture = bikin_tekstur_cahaya()
	player_light.shadow_enabled = false
	player_light.shadow_filter = Light2D.SHADOW_FILTER_PCF13 
	player_light.shadow_filter_smooth = 3.0
	player_light.energy = 1.2
	player_light.texture_scale = 2.0 
	$Player.add_child(player_light)
	player_poly = $Player/Polygon2D 
	
	# 2. Setup TileSet (9 Tile)
	var ts = TileSet.new()
	ts.tile_size = Vector2i(BLOCK_SIZE, BLOCK_SIZE)
	ts.add_physics_layer(0)
	ts.add_occlusion_layer(0)
	
	var img = Image.create(BLOCK_SIZE * 18, BLOCK_SIZE, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(0, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.55, 0.27, 0.07))# Dirt
	img.fill_rect(Rect2i(BLOCK_SIZE, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.15, 0.15, 0.15)) # Coal
	img.fill_rect(Rect2i(BLOCK_SIZE * 2, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.7, 0.3, 0.2)) # Iron
	img.fill_rect(Rect2i(BLOCK_SIZE * 3, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.8, 0.5, 0.1)) # Copper
	img.fill_rect(Rect2i(BLOCK_SIZE * 4, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.6, 0.6, 0.6)) # Gravel
	img.fill_rect(Rect2i(BLOCK_SIZE * 5, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.5, 0.5, 0.5)) # Stone
	img.fill_rect(Rect2i(BLOCK_SIZE * 6, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.8, 0.8, 0.9)) # Silver
	img.fill_rect(Rect2i(BLOCK_SIZE * 7, 0, BLOCK_SIZE, BLOCK_SIZE), Color(1.0, 0.8, 0.1)) # Gold
	img.fill_rect(Rect2i(BLOCK_SIZE * 8, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.2, 0.9, 1.0)) # Mithril
	# T3 Ores
	img.fill_rect(Rect2i(BLOCK_SIZE * 9, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.9, 0.9, 0.95)) # Quartz
	img.fill_rect(Rect2i(BLOCK_SIZE * 10, 0, BLOCK_SIZE, BLOCK_SIZE), Color(1.0, 0.6, 0.1)) # Topaz
	img.fill_rect(Rect2i(BLOCK_SIZE * 11, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.1, 0.9, 0.3)) # Emerald
	img.fill_rect(Rect2i(BLOCK_SIZE * 12, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.6, 0.2, 0.9)) # Amethyst
	img.fill_rect(Rect2i(BLOCK_SIZE * 13, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.4, 0.9, 1.0)) # Diamond
	img.fill_rect(Rect2i(BLOCK_SIZE * 14, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.3, 0.0, 0.5)) # Void
	img.fill_rect(Rect2i(BLOCK_SIZE * 15, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.0, 1.0, 0.7)) # Uberilium
	
	# T3 Blocks
	img.fill_rect(Rect2i(BLOCK_SIZE * 16, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.4, 0.5, 0.7)) # Crystal Stone
	img.fill_rect(Rect2i(BLOCK_SIZE * 17, 0, BLOCK_SIZE, BLOCK_SIZE), Color(0.2, 0.2, 0.3)) # Hardened Stone
	var tex = ImageTexture.create_from_image(img)
	
	var source = TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(BLOCK_SIZE, BLOCK_SIZE)
	var source_id = ts.add_source(source)
	
	for i in range(18):
		source.create_tile(Vector2i(i, 0))
		var tile_data = source.get_tile_data(Vector2i(i, 0), 0)
		tile_data.add_collision_polygon(0)
		tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(0, 0), Vector2(BLOCK_SIZE, 0), Vector2(BLOCK_SIZE, BLOCK_SIZE), Vector2(0, BLOCK_SIZE)
		]))
		tile_data.add_occluder_polygon(0)
		var occ_poly = OccluderPolygon2D.new()
		occ_poly.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(BLOCK_SIZE, 0), Vector2(BLOCK_SIZE, BLOCK_SIZE), Vector2(0, BLOCK_SIZE)
		])
		tile_data.set_occluder_polygon(0, 0, occ_poly)
		
	world.tile_set = ts
	world.collision_enabled = true

	var wall_ts = TileSet.new()
	wall_ts.tile_size = Vector2i(BLOCK_SIZE, BLOCK_SIZE)
	var wall_source = TileSetAtlasSource.new()
	wall_source.texture = tex
	wall_source.texture_region_size = Vector2i(BLOCK_SIZE, BLOCK_SIZE)
	for i in range(18): wall_source.create_tile(Vector2i(i, 0))
	var wall_source_id = wall_ts.add_source(wall_source)

	var walls = TileMapLayer.new()
	walls.name = "Walls"
	walls.z_index = -1 
	walls.modulate = Color(0.3, 0.3, 0.3) 
	walls.tile_set = wall_ts 
	add_child(walls)
	move_child(walls, 0) 
	
	# Bump step 7 → 8 di sini, sebelum is_t3 dihitung,
	# agar dungeon T3 benar-benar ter-generate saat pertama kali masuk
	if Global.tutorial_step == 7:
		Global.tutorial_step = 8
		Global.save_game()
	
	# 3. Generate Dunia (Transisi T1, T2, T3)
	var is_t1 = (Global.tutorial_step == 0)
	var is_t3 = (Global.tutorial_step >= 8)
	
	var max_gen_y = WORLD_DEPTH # 1200
	if is_t1:
		max_gen_y = 100
	elif not is_t3:
		max_gen_y = 300 # T2 berhenti di 300

	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.03 
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	
	# --- LOOPING PEMBUATAN BLOK (DIRT, STONE, CRYSTAL, DLL) ---
	for x in range(WORLD_WIDTH):
		for y in range(max_gen_y):
			if y < 8:
				world.set_cell(Vector2i(x, y), source_id, Vector2i(TILE_DIRT, 0))
			else:
				walls.set_cell(Vector2i(x, y), wall_source_id, Vector2i(TILE_DIRT, 0))
				var threshold = 0.15 - (float(y) / float(WORLD_DEPTH)) * 0.3
				if noise.get_noise_2d(x, y) < threshold:
					
					# --- LOGIKA BLOK BERDASARKAN KEDALAMAN (SESUAI REQUEST KAMU) ---
					var block_type = TILE_DIRT
					
					if y >= 250 and y < 500:
						block_type = TILE_STONE
					elif y >= 500 and y < 900:
						block_type = TILE_CRYSTAL_STONE
					elif y >= 900:
						block_type = TILE_HARDENED_STONE
						
					# Transisi acak (Mix) di area batas T2
					if not is_t1:
						if y >= 150 and y < 250:
							var mix_noise = noise.get_noise_2d(x + 1000, y + 1000)
							if mix_noise > 0.2: block_type = TILE_STONE
							
					world.set_cell(Vector2i(x, y), source_id, Vector2i(block_type, 0))

	# Bedrock dasar map
	for x in range(WORLD_WIDTH):
		var bedrock_y = 100 if is_t1 else (300 if not is_t3 else WORLD_DEPTH - 1)
		world.set_cell(Vector2i(x, bedrock_y), source_id, Vector2i(TILE_STONE, 0))
		
	# Tembok Kiri Kanan (Cover dari -1000 tiles ke atas sampai +1200 tiles ke bawah)
	var rect_wall = RectangleShape2D.new()
	rect_wall.size = Vector2(32, 36000) # Tinggi 36000 pixel = ~1125 tiles
	
	var wall_left = StaticBody2D.new()
	wall_left.name = "WallLeft"
	var col_left = CollisionShape2D.new()
	col_left.shape = rect_wall
	wall_left.add_child(col_left)
	wall_left.position = Vector2(0, 1600) # Center di Y=1600 pixel
	add_child(wall_left)

	var wall_right = StaticBody2D.new()
	wall_right.name = "WallRight"
	var col_right = CollisionShape2D.new()
	col_right.shape = rect_wall
	wall_right.add_child(col_right)
	wall_right.position = Vector2(WORLD_WIDTH * BLOCK_SIZE, 1600)
	add_child(wall_right)

	# --- GENERATE ORE PER LAYER (FADING SYSTEM) ---
	# Layer 1-3 (T1 & T2)
	generate_vein_cluster(source_id, TILE_COPPER, 120, 4, 8, 10, 99)
	generate_vein_cluster(source_id, TILE_COAL, 100, 6, 12, 20, 99)
	generate_vein_cluster(source_id, TILE_GRAVEL, 350, 10, 20, 10, 99) 
	generate_vein_cluster(source_id, TILE_IRON, 60, 6, 12, 50, 99)
	
	if not is_t1:
		# T2 Layer 2
		generate_vein_cluster(source_id, TILE_IRON, 200, 6, 12, 100, 199) 
		generate_vein_cluster(source_id, TILE_COPPER, 80, 4, 8, 100, 199) 
		generate_vein_cluster(source_id, TILE_SILVER, 100, 4, 8, 100, 199) 
		generate_vein_cluster(source_id, TILE_COAL, 80, 6, 12, 100, 199)
		
		# T2 Layer 3
		generate_vein_cluster(source_id, TILE_SILVER, 150, 6, 12, 200, 299) 
		generate_vein_cluster(source_id, TILE_GOLD, 100, 6, 10, 200, 299) 
		generate_vein_cluster(source_id, TILE_MITHRIL, 40, 4, 8, 200, 299) 
		generate_vein_cluster(source_id, TILE_IRON, 80, 6, 12, 200, 299) 
		generate_vein_cluster(source_id, TILE_COPPER, 30, 4, 8, 200, 299)
		
	# ==========================================
	# ZONA TUTORIAL 3 (Eksklusif kalau step >= 8)
	# ==========================================
	if is_t3:
		# --- ZONA 1: Crystal Glade (Y: 300 - 599) ---
		# Ore lama mulai memudar
		generate_vein_cluster(source_id, TILE_COPPER, 15, 4, 8, 300, 450) 
		generate_vein_cluster(source_id, TILE_IRON, 50, 4, 8, 300, 500)   
		generate_vein_cluster(source_id, TILE_SILVER, 40, 4, 8, 300, 550)
		generate_vein_cluster(source_id, TILE_COAL, 80, 6, 12, 300, 599)  
		
		# Ore Zona 1 (Banyak)
		generate_vein_cluster(source_id, TILE_QUARTZ, 250, 4, 8, 300, 599)
		generate_vein_cluster(source_id, TILE_TOPAZ, 100, 4, 8, 350, 599)
		
		# Gold & Mithril berlimpah
		generate_vein_cluster(source_id, TILE_GOLD, 150, 4, 8, 300, 599)
		generate_vein_cluster(source_id, TILE_MITHRIL, 120, 4, 8, 300, 599)

		# --- ZONA 2: Amethyst Abyss (Y: 600 - 899) ---
		# Ore lama hampir hilang
		generate_vein_cluster(source_id, TILE_IRON, 10, 4, 8, 600, 700) 
		generate_vein_cluster(source_id, TILE_SILVER, 15, 4, 8, 600, 750)
		generate_vein_cluster(source_id, TILE_COAL, 60, 6, 12, 600, 899)
		
		# Quartz/Topaz pudar
		generate_vein_cluster(source_id, TILE_QUARTZ, 50, 4, 8, 600, 750)
		generate_vein_cluster(source_id, TILE_TOPAZ, 20, 4, 8, 600, 700)
		
		# Ore Zona 2 (Banyak)
		generate_vein_cluster(source_id, TILE_EMERALD, 200, 4, 8, 600, 899)
		generate_vein_cluster(source_id, TILE_AMETHYST, 120, 4, 8, 650, 899)
		
		# Gold & Mithril puncak kejayaan
		generate_vein_cluster(source_id, TILE_GOLD, 200, 4, 8, 600, 899)
		generate_vein_cluster(source_id, TILE_MITHRIL, 200, 4, 8, 600, 899)

		# --- ZONA 3: The Void Core (Y: 900 - 1199) ---
		# Ore lama benar-benar hilang. Hanya Coal, Gold, Mithril sisa.
		generate_vein_cluster(source_id, TILE_COAL, 40, 6, 12, 900, 1199)
		generate_vein_cluster(source_id, TILE_GOLD, 50, 4, 8, 900, 1050) 
		generate_vein_cluster(source_id, TILE_MITHRIL, 80, 4, 8, 900, 1100) 
		
		# Emerald/Amethyst sekarat
		generate_vein_cluster(source_id, TILE_EMERALD, 30, 4, 8, 900, 1000)
		generate_vein_cluster(source_id, TILE_AMETHYST, 15, 4, 8, 900, 950)
		
		# Ore End-Game
		generate_vein_cluster(source_id, TILE_DIAMOND, 150, 4, 8, 900, 1199)
		generate_vein_cluster(source_id, TILE_VOID, 80, 4, 8, 1000, 1199)
		generate_vein_cluster(source_id, TILE_UBERILIUM, 25, 2, 5, 1100, 1199)
				
		# --- SURVIVAL BLOCKS (Dirt & Gravel) untuk T3 (Layers 4-12) ---
		# Zone 1 (Y: 300-599)
		generate_vein_cluster(source_id, TILE_DIRT, 100, 4, 10, 300, 599)
		generate_vein_cluster(source_id, TILE_GRAVEL, 75, 4, 8, 300, 599)
		# Zone 2 (Y: 600-899)
		generate_vein_cluster(source_id, TILE_DIRT, 50, 4, 10, 600, 899)
		generate_vein_cluster(source_id, TILE_GRAVEL, 55, 4, 8, 600, 899)
		# Zone 3 (Y: 900-1199)
		generate_vein_cluster(source_id, TILE_DIRT, 25, 4, 10, 900, 1199)
		generate_vein_cluster(source_id, TILE_GRAVEL, 20, 4, 8, 900, 1199)
	
	# Bump step 7 → 8 HANYA saat dunia T3 benar-benar sudah di-generate
	if Global.tutorial_step == 7:
		Global.tutorial_step = 8
		Global.save_game()
		
	spawn_enemies()
	spawn_chests()
	bikin_arena_boss()
	spawn_domains()
	spawn_mineshafts()
	
	if Global.tutorial_step == 0:
		is_tutorial_active = true
	else:
		is_tutorial_active = false
		
	spawn_lift()
	spawn_checkpoints()
	
	# UI Tooltip
	var canvas_obj = CanvasLayer.new()
	add_child(canvas_obj)
	ui_tooltip = Label.new()
	ui_tooltip.add_theme_font_size_override("font_size", 14)
	ui_tooltip.add_theme_color_override("font_color", Color.WHITE)
	ui_tooltip.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_tooltip.add_theme_constant_override("outline_size", 4)
	ui_tooltip.visible = false
	canvas_obj.add_child(ui_tooltip)
	
	# Cek Tutorial 2
	if Global.tutorial_step == 3:
		tutorial2_step = Global.tutorial2_step
		if tutorial2_step == 0:
			tutorial2_step = 1
		update_objective_tutorial2()
	elif Global.tutorial_step >= 4:
		tutorial2_step = 99
		Global.tutorial_completed = true
		update_objective_tutorial2()

	if Global.tutorial_step >= 8:
		update_objective_tutorial3()

	if is_tutorial_active:
		update_objective_ui()

	bikin_ui_pause_main()
	print("Dunia siap!")

# --- SISA FUNGSI (SAMA SEPERTI SEBELUMNYA, CUMA ADA UPDATE DI BEBERAPA BAGIAN) ---

func bikin_ui_tutorial2():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	ui_objective_label = Label.new()
	ui_objective_label.position = Vector2(20, 100)
	ui_prompt = Label.new()
	ui_prompt.position = Vector2(400, 650)
	ui_prompt.add_theme_font_size_override("font_size", 28)
	ui_prompt.add_theme_color_override("font_color", Color.YELLOW)
	ui_prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_prompt.add_theme_constant_override("outline_size", 6)
	ui_prompt.visible = false
	canvas.add_child(ui_prompt)
	ui_objective_label.add_theme_font_size_override("font_size", 20)
	ui_objective_label.add_theme_color_override("font_color", Color.GOLD)
	ui_objective_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_objective_label.add_theme_constant_override("outline_size", 4)
	canvas.add_child(ui_objective_label)
	
	ui_buff_label = Label.new()
	ui_buff_label.position = Vector2(20, 130) # Posisi di bawah Objective
	ui_buff_label.add_theme_font_size_override("font_size", 16)
	ui_buff_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
	ui_buff_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_buff_label.add_theme_constant_override("outline_size", 4)
	canvas.add_child(ui_buff_label)
	
	ui_layer_label = Label.new()
	ui_layer_label.position = Vector2(20, 75) 
	ui_layer_label.add_theme_font_size_override("font_size", 16)
	ui_layer_label.add_theme_color_override("font_color", Color.CYAN)
	ui_layer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_layer_label.add_theme_constant_override("outline_size", 4)
	canvas.add_child(ui_layer_label)
	
	# --- DIALOG PANEL UTAMA ---
	ui_dialog_panel = Panel.new()
	ui_dialog_panel.size = Vector2(900, 260)
	ui_dialog_panel.position = Vector2(126, 380)
	ui_dialog_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.9)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1)
	ui_dialog_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(ui_dialog_panel)
	
	# --- TEKS DIALOG ---
	ui_dialog_text = Label.new()
	ui_dialog_text.position = Vector2(25, 25)
	ui_dialog_text.size = Vector2(850, 210)
	ui_dialog_text.add_theme_font_size_override("font_size", 20)
	ui_dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	ui_dialog_panel.add_child(ui_dialog_text)

func show_dialog(text):
	ui_dialog_text.text = text
	ui_dialog_panel.visible = true

func update_objective_tutorial2():
	if tutorial2_step == 1:
		ui_objective_label.text = "Obj: Find a stick on a dirt (" + str(min(tutorial2_stats["sticks"], 5)) + "/5)"
	elif tutorial2_step == 2:
		ui_objective_label.text = "Obj: Find the first checkpoint on depth 90 meters"
	elif tutorial2_step == 3:
		ui_objective_label.text = "Obj: Find a lift"
	else:
		ui_objective_label.text = "Explore the Caverns!"

func update_objective_tutorial3():
	if Global.tutorial_step == 8:
		# === SAAT T3 TUTORIAL ===
		if Global.tutorial3_step == 0:
			ui_objective_label.text = "Obj: Find checkpoint 6 at 590 meters"
		elif Global.tutorial3_step == 1:
			ui_objective_label.text = "Obj: Activate checkpoint 6"
		elif Global.tutorial3_step == 2:
			ui_objective_label.text = "Obj: Find and defeat the boss at 1190 meters"
		else:
			ui_objective_label.text = "Obj: Go to the lift and complete the mission!" # Teks baru setelah bos mati di T3
	else:
		# === POST-T3 (main bebas) ===
		if _boss_loot_guard:
			ui_objective_label.text = "Obj: Go to the lift and complete the mission!" # Teks baru setelah bos mati
		else:
			ui_objective_label.text = "Obj: Find a way to defeat a boss!"

func show_t3_checkpoint6_dialog():
	show_dialog("This is checkpoint 6")
	await get_tree().create_timer(3.0).timeout
	show_dialog("You can choose to activate it, or choose the lift to escape if you are too scared for the next layer")
	await get_tree().create_timer(5.0).timeout
	show_dialog("But for now, let's activate checkpoint 6 and continue the journey")
	await get_tree().create_timer(4.0).timeout
	ui_dialog_panel.visible = false

func show_t3_scrap_dialog():
	show_dialog("Oh you found a scrap!")
	await get_tree().create_timer(2.5).timeout
	show_dialog("It's useful to upgrade some stuffs later")
	await get_tree().create_timer(3.0).timeout
	ui_dialog_panel.visible = false

func show_t3_domain_dialog():
	show_dialog("It's a domain that contains a lot of strong enemies, but also a lot of loot!")
	await get_tree().create_timer(4.5).timeout
	show_dialog("Be careful, you can't craft inside, so better prepare everything before you go in")
	await get_tree().create_timer(4.5).timeout
	ui_dialog_panel.visible = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if is_dead or is_lifting: return
		
		if is_instance_valid(abort_confirm_panel) and abort_confirm_panel.visible:
			abort_confirm_panel.visible = false
			abort_blocker.visible = false
			return
			
		if is_instance_valid(pause_panel_main) and is_pause_main_open:
			is_pause_main_open = false
			pause_panel_main.visible = false
			pause_blocker_main.visible = false
			get_tree().paused = false
			$Player.set_physics_process(true)
			return
			
		if is_inventory_open:
			is_inventory_open = false
			ui_inventory_panel.visible = false
			return
			
		# Buka Pause Menu
		if not is_pause_main_open:
			is_pause_main_open = true
			pause_panel_main.visible = true
			pause_blocker_main.visible = true
			get_tree().paused = true
			$Player.set_physics_process(false)
		return
	
	if get_tree().paused: return 
	
	# --- MOUSE WHEEL CYCLE HOTBAR ---
	if event is InputEventMouseButton and event.pressed \
	   and not is_spectating and not is_inventory_open \
	   and not is_char_open and not is_crafting_open:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Sfx.play("tick")
			_change_hotbar_slot(-1)
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Sfx.play("tick")
			_change_hotbar_slot(1)
			return
	
	# --- LOGIKA ZOOM SPECTATOR (SCROLL MOUSE) ---
	if is_spectating and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			$Player/Camera2D.zoom = ($Player/Camera2D.zoom * 1.1).clamp(Vector2(0.05, 0.05), Vector2(1.5, 1.5))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			$Player/Camera2D.zoom = ($Player/Camera2D.zoom / 1.1).clamp(Vector2(0.05, 0.05), Vector2(1.5, 1.5))
		return
	# --------------------------------------------

	# --- CEK DIALOG PANEL ---
	if ui_dialog_panel.visible:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			ui_dialog_panel.visible = false
		return

	if is_dead: return 
	
	# --- INVENTORY TOGGLE ---
	if event.is_action_pressed("inventory"):
		is_inventory_open = !is_inventory_open
		ui_inventory_panel.visible = is_inventory_open
		if is_inventory_open: 
			is_crafting_open = false
			ui_crafting_panel.visible = false
			is_char_open = false
			char_panel.visible = false
			update_inventory_ui()
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		# --- TOMBOL V UNTUK SPECTATOR MODE ---
		if event.keycode == KEY_V:
			toggle_spectator()
			return
			
		if event.keycode == KEY_C: 
			is_crafting_open = !is_crafting_open
			ui_crafting_panel.visible = is_crafting_open
			if is_crafting_open:
				is_inventory_open = false
				ui_inventory_panel.visible = false
				is_char_open = false
				char_panel.visible = false
				update_crafting_ui()
				
		if event.keycode == KEY_I: 
			is_char_open = !is_char_open
			char_panel.visible = is_char_open
			if is_char_open:
				is_inventory_open = false
				ui_inventory_panel.visible = false
				is_crafting_open = false
				ui_crafting_panel.visible = false
				update_char_ui()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		if is_inventory_open:
			var clicked_something = false
			for i in range(7): 
				if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
					clicked_something = true
					# KUNCI SLOT 0, 1, 2 (Weapons & Armor)
					if i < 3:
						show_floating_text("Weapons are locked! Change them in Home.", $Player.global_position, Color.RED)
					else:
						# Cek apakah item yang mau ditaruh itu senjata
						if selected_inv_item != null:
							var w_type = item_data.get(selected_inv_item, {}).get("weapon_type", "")
							if w_type != "" or selected_inv_item in ["Fist", "Stone Pickaxe", "Bow", "Wooden Sword"]:
								show_floating_text("Cannot put weapons in Hotbar!", $Player.global_position, Color.RED)
								return
								
							hotbar_items[i] = selected_inv_item
							selected_inv_item = null
						elif hotbar_items[i] != null:
							hotbar_items[i] = null
						Global.hotbar_items = hotbar_items.duplicate()
						update_hotbar_ui()
						update_inventory_ui()
					break
			if not clicked_something:
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						var items_in_backpack = get_backpack_items()
						if i < items_in_backpack.size():
							var item_name = items_in_backpack[i]
							var w_type = item_data.get(item_name, {}).get("weapon_type", "")
							
							# Blokir kalau itu senjata/armor
							if w_type != "" or item_name in ["Fist", "Stone Pickaxe", "Bow", "Wooden Sword"]:
								show_floating_text("Weapons are locked!", $Player.global_position, Color.RED)
							else:
								selected_inv_item = item_name
								show_floating_text("Selected: " + selected_inv_item, $Player.global_position)
						break
			return
		elif not is_crafting_open and not is_char_open:
			for i in range(7):
				if hotbar_ui_labels[i].get_parent().get_global_rect().has_point(mouse_pos):
					selected_hotbar_index = i
					update_hotbar_ui()
					update_crafting_ui()
					break

	if event is InputEventKey and event.pressed and not event.echo:
		if is_inventory_open:
			var key_num = -1
			if event.keycode == KEY_4: key_num = 3
			elif event.keycode == KEY_5: key_num = 4
			elif event.keycode == KEY_6: key_num = 5
			elif event.keycode == KEY_7: key_num = 6
			
			# === KONSUMSI MAKANAN DARI BACKPACK / HOTBAR PANEL (tekan F atau E) ===
			if event.keycode == KEY_F or event.keycode == KEY_E:
				var mouse_pos = get_viewport().get_mouse_position()
				var food_list = ["Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"]
				
				# Kumpulkan item backpack (sama persis dengan yang dipakai UI)
				var items_in_backpack = get_backpack_items()
				
				# Cek slot BACKPACK
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size():
							var item = items_in_backpack[i]
							if item in food_list:
								consume_food(item)
						return
				
				# Cek slot HOTBAR DI PANEL INVENTORY
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if hotbar_items[i] in food_list:
							consume_food(hotbar_items[i])
						return
				return
			# ================================================================
			
			if key_num != -1:
				var mouse_pos = get_viewport().get_mouse_position()
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						var items_in_backpack = get_backpack_items()
						if i < items_in_backpack.size():
							var _new_item = items_in_backpack[i]
							var _base = Global.get_base_name(_new_item)
							var _w_type = item_data.get(_base, {}).get("weapon_type", "")
							if _w_type != "" or _base in ["Fist", "Stone Pickaxe", "Bow", "Wooden Sword"]:
								show_floating_text("Cannot put weapons in Hotbar 4-7!", $Player.global_position, Color.RED)
								break
							if hotbar_items[key_num] != _new_item:
								hotbar_items[key_num] = _new_item
								Global.hotbar_items = hotbar_items.duplicate()
								Global.save_game()
								update_hotbar_ui()
								update_inventory_ui()
						break
			return
		# Konsumsi makanan dari backpack/hotbar panel saat inventory terbuka (tekan E)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F and is_inventory_open:
		var mouse_pos = get_viewport().get_mouse_position()
		var food_list = ["Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"]
		
		# Cek slot backpack
		for i in range(slot_nodes.size()):
			if slot_nodes[i].get_global_rect().has_point(mouse_pos):
				var items_in_backpack = get_backpack_items()
				if i < items_in_backpack.size():
					var item = items_in_backpack[i]
					if item in food_list:
						consume_food(item)
				return
		
		# Cek slot hotbar di panel inventory
		for i in range(7):
			if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
				if hotbar_items[i] in food_list:
					consume_food(hotbar_items[i])
				return
		return
	
	
	if event is InputEventKey and event.pressed and not event.echo and not is_inventory_open:
		if event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7]:
			var new_idx = event.keycode - KEY_1
			if new_idx != selected_hotbar_index:
				selected_hotbar_index = new_idx
				attack_cooldown = 0.0
				sword_combo = 0
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
				update_crafting_ui()
		
		if event.keycode == KEY_E:
			# --- DOMAIN CHECK (duluan sebelum makan) ---
			for d in domains:
				if is_instance_valid(d) and $Player.global_position.distance_to(d.global_position) < 80.0:
					enter_domain(d)
					return
			# --------------------------------------------
			
			# Konsumsi makanan kalau bukan di dekat domain
			var held = hotbar_items[selected_hotbar_index]
			if held in ["Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"]:
				consume_food(held)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		# === INVENTORY TERBUKA: cuma handle slot, abaikan interaksi dunia ===
		if is_inventory_open:
			if event.pressed:
				var mouse_pos = get_viewport().get_mouse_position()
				
				# Kumpulkan item yang ada di backpack (bukan yang di hotbar)
				var items_in_backpack = get_backpack_items()
				
				# Cek slot BACKPACK
				for i in range(slot_nodes.size()):
					if slot_nodes[i].get_global_rect().has_point(mouse_pos):
						if i < items_in_backpack.size() and items_in_backpack[i] == "Food Box":
							use_food_box()
						return
				
				# Cek slot HOTBAR di dalam panel inventory
				for i in range(7):
					if inv_hotbar_slots[i].get_global_rect().has_point(mouse_pos):
						if hotbar_items[i] == "Food Box":
							use_food_box()
						return
			return  # Selalu return selama inventory buka - cegah charge bow bocor
		# ====================================================================
		
		# === INVENTORY TERTUTUP: interaksi normal di dunia ===
		var held_item = hotbar_items[selected_hotbar_index]
		if event.pressed:
		
		# --- CEK KLIK LORE LOG ---
			var _mouse_w = get_global_mouse_position()
			for _log in lore_logs:
				if is_instance_valid(_log) and _mouse_w.distance_to(_log.global_position) < 30:
					if $Player.global_position.distance_to(_log.global_position) < 150:
						read_lore_log(_log.get_meta("lore_id", 1))
						return # Berhenti di sini, jangan lanjut nembak panah atau taruh blok
			# -------------------------
			if held_item == "Food Box":
				use_food_box()
			
			elif held_item in ["Bow", "Iron Bow", "Hunter Bow", "Mourning Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow","Headhitter Heavy Bow"]:
				is_charging_bow = true
				show_floating_text("Charging...", $Player.global_position)
			elif held_item == "Crystal Hammer":
				hammer_charging = true
				hammer_charge_timer = 0.0
			elif held_item == "Stormjade Cutter":
				stormjade_charging = true
				stormjade_charge_timer = 0.0
			elif held_item == "Galahad Chimelin" and galahad_parry_cd <= 0.0:
				galahad_parry_active = true
				galahad_parry_cd = 3.0
				show_floating_text("PARRY!", $Player.global_position, Color.GOLD)
				await get_tree().create_timer(0.5).timeout
				galahad_parry_active = false
			else:
				try_place_block(get_global_mouse_position())
		else:
			if held_item in ["Bow", "Iron Bow", "Hunter Bow", "Marble Slingshot", "Explosive Crossbow", "Ricochet Bow", "Bounty Bow", "Sticky Crossbow", "Headhitter Heavy Bow"] and is_charging_bow:
				is_charging_bow = false
				if attack_cooldown <= 0:
					await try_attack(get_global_mouse_position(), true)
			
			# --- CRYSTAL HAMMER: charge release ---
			if held_item == "Crystal Hammer" and hammer_charging:
				hammer_charging = false
				if attack_cooldown <= 0:
					if hammer_charge_timer >= 2.0:
						var _facing = sign(get_global_mouse_position().x - $Player.global_position.x)
						if _facing == 0: _facing = 1
						var _reach = 80.0  # 5 block reach in front
						var _player_bottom = $Player.global_position.y + 32
						var _stun_dmg = int(48 * buff_dmg_mult)
						for _e in enemies.duplicate():
							if not is_instance_valid(_e): continue
							if _e.is_queued_for_deletion(): continue
							
							# X check: hanya di depan (satu arah, sesuai mouse)
							var _dx = _e.global_position.x - $Player.global_position.x
							if _facing > 0 and (_dx < -16 or _dx > _reach): continue
							if _facing < 0 and (_dx > 16 or _dx < -_reach): continue
							
							# Y check: tolerance dinamis (berdasarkan ukuran musuh)
							var _e_size_h = _e.get_meta("size_h", _e.get_meta("size", 16.0))
							var _e_bottom = _e.global_position.y + _e_size_h / 2.0
							var _tol = max(32.0, _e_size_h / 2.0 + 8.0)
							if abs(_e_bottom - _player_bottom) > _tol: continue
							
							var _ct = _e.get_meta("type")
							var _ce = _e.get_meta("exp") if _e.has_meta("exp") else 0
							var _hp = _e.get_meta("hp") - _stun_dmg
							_e.set_meta("hp", _hp)
							update_enemy_hp_bar(_e)
							show_floating_text(str(_stun_dmg) + " STUN!", _e.global_position + Vector2(0, -40), Color.CYAN)
							
							if _hp <= 0:
								if is_tutorial_active and _ct == "goblin":
									tutorial_stats["goblins_killed"] += 1
									check_objective_progress()
								if _ct == "boss_spider":
									spawn_final_lift()
									give_boss_loot()
									if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
								gain_exp(_ce)
								drop_loot(_ct)
								_try_drop_hammer_ore(_e)
								enemies.erase(_e)
								if is_instance_valid(_e):
									_e.queue_free()
							else:
								_e.set_meta("terrified_timer", 1.5)
						attack_cooldown = 1.0
					else:
						await try_attack(get_global_mouse_position(), false)
				hammer_charge_timer = 0.0
			
			# --- STORMJADE: charge release ---
			if held_item == "Stormjade Cutter" and stormjade_charging:
				stormjade_charging = false
				if attack_cooldown <= 0:
					if stormjade_charge_timer >= 3.0:
						var _dir = (get_global_mouse_position() - $Player.global_position).normalized()
						var _max_dist = 128.0
						
						# Wall check via raycast (stop di wall)
						var _space = get_world_2d().direct_space_state
						var _q = PhysicsRayQueryParameters2D.create($Player.global_position, $Player.global_position + _dir * _max_dist, 1, [$Player])
						var _hit = _space.intersect_ray(_q)
						if _hit and not (_hit.collider is CharacterBody2D):
							_max_dist = max(8.0, $Player.global_position.distance_to(_hit.position) - 16.0)
						
						var _end = $Player.global_position + _dir * _max_dist
						var _dash_rect = Rect2($Player.global_position, _end - $Player.global_position)
						_dash_rect = _dash_rect.abs().grow(30.0)
						var _base_dmg = int(25 * 1.5 * buff_dmg_mult)
						var _hit_count = 0
						var _hit_enemies = []
						for _e in enemies.duplicate():
							if is_instance_valid(_e) and _dash_rect.has_point(_e.global_position) and _e not in _hit_enemies:
								var _this_dmg = int(_base_dmg * (1.0 + _hit_count * 0.25))
								var _cached_type = _e.get_meta("type")
								var _cached_exp = _e.get_meta("exp") if _e.has_meta("exp") else 0
								var _hp = _e.get_meta("hp") - _this_dmg
								_e.set_meta("hp", _hp)
								update_enemy_hp_bar(_e)
								show_floating_text(str(_this_dmg), _e.global_position + Vector2(0, -40 - _hit_count * 15), Color.GREEN)
								_hit_enemies.append(_e)
								_hit_count += 1
								if _hp <= 0:
									if is_tutorial_active and _cached_type == "goblin":
										tutorial_stats["goblins_killed"] += 1
										check_objective_progress()
									if _cached_type == "boss_spider":
										spawn_final_lift()
										give_boss_loot()
										if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
									gain_exp(_cached_exp)
									drop_loot(_cached_type)
									enemies.erase(_e)
									if is_instance_valid(_e):
										_e.queue_free()
								if _hit_count >= 8: break
						$Player.global_position = _end
						attack_cooldown = 1.0
					else:
						await try_attack(get_global_mouse_position(), false)
				stormjade_charge_timer = 0.0
				
func _process(delta):
	if is_lifting: return
	if get_tree().paused: return 
	# --- DOMAIN PROMPT CHECK ---
	if is_instance_valid(ui_prompt):
		ui_prompt.visible = false
		for d in domains:
			if is_instance_valid(d) and $Player.global_position.distance_to(d.global_position) < 80.0:
				ui_prompt.text = "Press [E] to enter " + d.get_meta("domain_name")
				ui_prompt.visible = true
				break
	# ----------------------------
	
	# --- T3: DOMAIN PROXIMITY DIALOG (sekali) ---
	if Global.tutorial_step >= 8 and not Global.has_shown_domain_dialog:
		for d in domains:
			if is_instance_valid(d) and $Player.global_position.distance_to(d.global_position) < 48.0:
				Global.has_shown_domain_dialog = true
				Global.save_game()
				show_t3_domain_dialog()
				break
	# ---------------------------------------------
	
	# --- T3: CHECKPOINT 6 PROXIMITY DIALOG (Hanya saat tutorial T3) ---
	if Global.tutorial_step == 8 and Global.tutorial3_step == 0:
		for cp in checkpoint_nodes:
			if is_instance_valid(cp):
				var _cp_depth = world.local_to_map(world.to_local(cp.global_position)).y
				if _cp_depth == 590 and $Player.global_position.distance_to(cp.global_position) < 128.0:
					Global.tutorial3_step = 1
					Global.save_game()
					update_objective_tutorial3()
					show_t3_checkpoint6_dialog()
					break
	# -------------------------------------------
	# --- DROP THROUGH BRIDGE (S + SPACE) ---
	if not is_dropping_through_bridge and Input.is_key_pressed(KEY_S) and Input.is_key_pressed(KEY_SPACE):
			drop_through_bridges()
	# ----------------------------------------
	var p_tile = world.local_to_map(world.to_local($Player.global_position))
	# --- LOGIKA HENING SEBELUM BOS (ZONA 1101+) ---
	if p_tile.y >= 1101 and not boss_silence_triggered and not is_boss_arena_locked:
		boss_silence_triggered = true
		MusicManager.stop_bgm()
		if current_music_zone >= 0 and current_music_zone <= 3:
			zone_bgm_times[current_music_zone] = MusicManager.get_precise_time()
	# -----------------------------------------------

	# Buka kuncian arena jika pemain sudah naik keluar dari ruangan bos
	if is_boss_arena_locked and p_tile.y < 1100:
		is_boss_arena_locked = false

	# --- LOGIKA BGM BERPINDAH TIAP ZONA & BOS (VERSI BERSIH) ---
	if not is_boss_arena_locked:
		var _new_zone = 0
		if p_tile.y <= 300: _new_zone = 0 
		elif p_tile.y <= 600: _new_zone = 1 
		elif p_tile.y <= 900: _new_zone = 2 
		else: _new_zone = 3 
		
		# 1. JIKA MASUK KEDALAMAN 1101+ (HENINGKAN MUSIK)
		if p_tile.y >= 1101 and not boss_silence_triggered:
			boss_silence_triggered = true
			if current_music_zone >= 0 and current_music_zone <= 3:
				zone_bgm_times[current_music_zone] = MusicManager.get_precise_time()
			MusicManager.stop_bgm()
		
		# 2. JIKA KABUR KE ATAS (NYALAKAN LAGU LAYER)
		elif p_tile.y < 1101 and boss_silence_triggered:
			boss_silence_triggered = false
			current_music_zone = _new_zone
			_play_layer_bgm(current_music_zone, zone_bgm_times.get(current_music_zone, 0.0))
			
		# 3. JIKA PINDAH ZONA NORMAL (TANPA BOS)
		elif _new_zone != current_music_zone and not boss_silence_triggered:
			if current_music_zone >= 0 and current_music_zone <= 3:
				zone_bgm_times[current_music_zone] = MusicManager.get_precise_time()
			current_music_zone = _new_zone
			_play_layer_bgm(current_music_zone, zone_bgm_times.get(current_music_zone, 0.0))
	# -------------------------------------------------------------
	
	if p_tile.y < 8:
		ui_layer_label.text = "Surface"
	else:
		var layer_name = "Caverns" # Default buat T1
		if Global.tutorial_step >= 8:
			# LOGIKA T3: Nama Layer Soliter (1 per Layer)
			if p_tile.y < 100: layer_name = "Layer 1"
			elif p_tile.y < 200: layer_name = "Layer 2"
			elif p_tile.y < 300: layer_name = "Layer 3"
			elif p_tile.y < 400: layer_name = "Layer 4: Crystal Glade"
			elif p_tile.y < 500: layer_name = "Layer 5: Crystal Glade"
			elif p_tile.y < 600: layer_name = "Layer 6: Crystal Glade"
			elif p_tile.y < 700: layer_name = "Layer 7: Amethyst Abyss"
			elif p_tile.y < 800: layer_name = "Layer 8: Amethyst Abyss"
			elif p_tile.y < 900: layer_name = "Layer 9: Amethyst Abyss"
			elif p_tile.y < 1000: layer_name = "Layer 10: The Void Core"
			elif p_tile.y < 1100: layer_name = "Layer 11: The Void Core"
			else: layer_name = "Layer 12: The Void Core"
		elif Global.tutorial_step != 0:
			# LOGIKA T2 (Tetap pakai yang lama)
			layer_name = "Layer 3"
			if p_tile.y < 100: layer_name = "Layer 1"
			elif p_tile.y < 200: layer_name = "Layer 2"
			
		ui_layer_label.text = layer_name + "  |  Depth = " + str(p_tile.y) + "m"
		# --- CEK APAKAH PLAYER SUDAH MASUK KE DALAM KUBAH (Bukan cuma sejajar) ---
	if p_tile.y >= 1155 and not is_boss_arena_locked and Global.tutorial_step >= 8 and not _boss_loot_guard:
		var dx = p_tile.x - 150 # 150 = Titik tengah kubah (cx)
		var dy = p_tile.y - 1198 # 1198 = Dasar kubah (cy)
		var jarak_dari_pusat = sqrt((dx * dx) + (dy * dy))
		
		# Jika player berada di dalam radius kubah (55 blok), baru trigger aktif
		if jarak_dari_pusat <= 55:
			lock_boss_arena()
		
	if p_tile.y < -25: 
		Global.saved_inventory.clear()
		var consumables = [
			"Dirt", "Gravel", "Stone", "Crystal Stone", "Hardened Crystal Stone",
			"Flint", "Stick", "Arrow", "Torch", "Food Box", "Bomb", "Coal",
			"Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"
		]
		for item_name in inventory.keys():
			if item_name not in consumables:
				Global.saved_inventory[item_name] = inventory[item_name]
				
		inventory.clear() 
		Global.save_game() 
		get_tree().change_scene_to_file("res://home.tscn")
		return 
	
	# --- MANA REGEN (4 point per detik, Smooth) ---
	if current_mana < max_mana:
		current_mana = min(current_mana + (4.0 * delta), max_mana)
		Global.current_mana = current_mana
		update_exp_ui()
	# -------------------------------------------

	_update_pneumatic_bombs(delta)
	update_combat(delta)
	update_arrows(delta)
	
	# --- CRYSTAL ARMOR TIMER ---
	if crystal_armor_timer > 0:
		if _magic_beam_dmg_cd > 0:
			_magic_beam_dmg_cd -= delta
		crystal_armor_timer -= delta
		if crystal_armor_timer <= 0:
			crystal_armor_stacks = 0
	# ---------------------------
	
	if freeze_timer > 0: freeze_timer -= delta
	# --- ARMOR BLUEPRINT TIMERS ---
	if deep_cave_cooldown > 0:
		deep_cave_cooldown -= delta
	
	if deep_cave_active:
		deep_cave_petrify_timer -= delta
		if deep_cave_petrify_timer > 0:
			deep_cave_regen_timer += delta
			if deep_cave_regen_timer >= 1.0:
				deep_cave_regen_timer -= 1.0
				current_hp = min(current_hp + 7, max_hp)
				update_hp_ui()
		else:
			deep_cave_active = false
			$Player.set_physics_process(true)
			show_floating_text("RECOVERED!", $Player.global_position + Vector2(0, -60), Color.GREEN)
	# ------------------------------
	
		# --- BOUNTY BOW TIMER ---
	if bounty_stack_timer > 0:
		bounty_stack_timer -= delta
		if bounty_stack_timer <= 0 and bounty_bow_stacks > 0:
			bounty_bow_stacks = 0
			show_floating_text("Bounty Reset!", $Player.global_position + Vector2(0, -80), Color.GRAY)
	# ------------------------
	
	# --- REVENGER TIMER ---
	if revenger_timer > 0:
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
	
	# --- UPDATE UI BUFF TIMERS ---
	var active_text = ""
	for buff_name in active_food_buffs.keys():
		if active_food_buffs[buff_name] > 0:
			active_food_buffs[buff_name] -= delta
			if active_food_buffs[buff_name] > 0:
				# Format jadi 1 desimal (misal 5.2s)
				var time_left = snapped(active_food_buffs[buff_name], 0.1)
				active_text += buff_name + ": " + str(time_left) + "s\n"
	
	if is_instance_valid(ui_buff_label):
		ui_buff_label.text = active_text
	
	if is_crafting_open:
		update_crafting_ui()

	if is_dead or is_inventory_open or is_crafting_open or is_char_open: return
	if deep_cave_active: return  # Petrify: block attack/mine
	
	var current_zoom = $Player/Camera2D.zoom.x
	if current_zoom < 0.5:
		canvas_mod.color = Color(1, 1, 1)
		player_light.texture_scale = 150.0
	else:
		canvas_mod.color = Color(0.1, 0.1, 0.15)
		if p_tile.y < 8:
			player_light.texture_scale = lerp(player_light.texture_scale, 30.0 / current_zoom, 0.1)
			player_light.energy = lerp(player_light.energy, 1.0, 0.1)
		else:
			player_light.texture_scale = lerp(player_light.texture_scale, 2.5 / current_zoom, 0.1)
			player_light.energy = lerp(player_light.energy, 1.2, 0.1)
	
	if current_hp < max_hp and current_hp > 0:
		regen_timer += delta
		if regen_timer >= 20.0:
			regen_timer = 0.0
			current_hp += 1
			update_hp_ui()
	
	var held_item = hotbar_items[selected_hotbar_index]
	
	# --- GOLDEN CONDUCTOR: charge logic ---
	if held_item == "Golden Conductor":
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not conductor_charging:
				conductor_charging = true
				conductor_charge_timer = 0.0
				conductor_tick_timer = 0.0
		else:
			if conductor_charging:
				if conductor_charge_timer >= 3.0:
					var _exp_dmg = int(54 * 1.7 * buff_dmg_mult)
					var _dir_x = sign(get_global_mouse_position().x - $Player.global_position.x)
					if _dir_x == 0: _dir_x = 1
					var _player_bottom = $Player.global_position.y + 32
					var _max_dist = 128.0
					
					# Raycast stop di WALL (exclude player + enemies — musuh bukan wall)
					var _ray_y = _player_bottom - 12
					var _ray_start = Vector2($Player.global_position.x, _ray_y)
					var _ray_end = _ray_start + Vector2(_dir_x * _max_dist, 0)
					var _space = get_world_2d().direct_space_state
					var _exclude = [$Player]
					for _en in enemies:
						if is_instance_valid(_en):
							_exclude.append(_en)
					var _q = PhysicsRayQueryParameters2D.create(_ray_start, _ray_end, 1, _exclude)
					_q.collide_with_areas = false
					_q.collide_with_bodies = true
					var _hit = _space.intersect_ray(_q)
					if _hit and _hit.collider is StaticBody2D:
						_max_dist = max(8.0, _ray_start.distance_to(_hit.position))
					
					# Damage SEMUA musuh di garis (AOE line clear)
					for _e in enemies.duplicate():
						if not is_instance_valid(_e): continue
						var _e_size_h = _e.get_meta("size_h", _e.get_meta("size", 16.0))
						var _e_bottom = _e.global_position.y + _e_size_h / 2.0
						var _tol = max(24.0, _e_size_h / 2.0 + 8.0)
						if abs(_e_bottom - _player_bottom) > _tol: continue
						var _dx = _e.global_position.x - $Player.global_position.x
						if _dir_x > 0 and (_dx < -16 or _dx > _max_dist + 16): continue
						if _dir_x < 0 and (_dx > 16 or _dx < -_max_dist - 16): continue
						
						var _cached_type = _e.get_meta("type")
						var _cached_exp = _e.get_meta("exp") if _e.has_meta("exp") else 0
						var _hp = _e.get_meta("hp") - _exp_dmg
						_e.set_meta("hp", _hp)
						update_enemy_hp_bar(_e)
						show_floating_text(str(_exp_dmg), _e.global_position + Vector2(0, -40), Color.ORANGE)
						
						if _hp <= 0:
							if is_tutorial_active and _cached_type == "goblin":
								tutorial_stats["goblins_killed"] += 1
								check_objective_progress()
							if _cached_type == "boss_spider":
								spawn_final_lift()
								give_boss_loot()
								if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
							gain_exp(_cached_exp)
							drop_loot(_cached_type)
							enemies.erase(_e)
							if is_instance_valid(_e):
								_e.queue_free()
					
					# Visual
					var _exp = ColorRect.new()
					_exp.size = Vector2(_max_dist, 24)
					if _dir_x > 0:
						_exp.position = Vector2($Player.global_position.x, _player_bottom - 24)
					else:
						_exp.position = Vector2($Player.global_position.x - _max_dist, _player_bottom - 24)
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
		# Charge tick (tick damage tiap 0.5s saat nahan klik)
		if conductor_charging:
			conductor_charge_timer += delta
			conductor_tick_timer += delta
			if conductor_tick_timer >= 0.5:
				conductor_tick_timer = 0.0
				var _tick_dmg = int(54 * 0.05)
				for _e in enemies.duplicate():
					if is_instance_valid(_e) and $Player.global_position.distance_to(_e.global_position) < 64.0:
						var _cached_type = _e.get_meta("type")
						var _cached_exp = _e.get_meta("exp") if _e.has_meta("exp") else 0
						var _hp = _e.get_meta("hp") - _tick_dmg
						_e.set_meta("hp", _hp)
						update_enemy_hp_bar(_e)
						show_floating_text(str(_tick_dmg), _e.global_position + Vector2(0, -40), Color.YELLOW)
						if _hp <= 0:
							gain_exp(_cached_exp)
							drop_loot(_cached_type)
							enemies.erase(_e)
							if is_instance_valid(_e):
								_e.queue_free()
		return
	# --------------------------------------
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and attack_cooldown <= 0:
		var mouse_world_pos = get_global_mouse_position()
		var is_attacking = await try_attack(mouse_world_pos, false)
		if is_attacking: return
		
		if item_data.get(held_item, {}).has("efficiency"):
			if held_item == "Swarmid Drill" and swarmid_exhausted_timer > 0:
				show_floating_text("EXHAUSTED!", $Player.global_position, Color.RED)
				reset_mining()
				return
			
			var tile_pos = world.local_to_map(world.to_local(mouse_world_pos))
			
			# Raycast untuk Magic Pickaxe (stop di blok pertama)
			if held_item == "Magic Pickaxe":
				var _ray_dir = (mouse_world_pos - $Player.global_position).normalized()
				var _trav = 0.0
				var _found = Vector2i(-1, -1)
				while _trav < 320.0:
					var _cpos = $Player.global_position + _ray_dir * _trav
					var _tt = world.local_to_map(world.to_local(_cpos))
					if world.get_cell_source_id(_tt) != -1:
						_found = _tt
						break
					_trav += 8.0
				if _found != Vector2i(-1, -1):
					tile_pos = _found
			
			if world.get_cell_source_id(tile_pos) != -1:
				var player_pos = $Player.global_position
				var tile_center_pos = world.to_global(world.map_to_local(tile_pos))
				var _mining_range = 320.0 if held_item == "Magic Pickaxe" else MAX_DISTANCE
				if player_pos.distance_to(tile_center_pos) <= _mining_range:
					# Magic Pickaxe beam visual
					if held_item == "Magic Pickaxe":
						_draw_magic_beam(player_pos, tile_center_pos)
					# --- CEK BEDROCK (BATAS MAP) ---
					var is_bedrock = false
					if Global.tutorial_step == 0 and tile_pos.y >= 100:
						is_bedrock = true
					elif Global.tutorial_step != 0 and tile_pos.y >= WORLD_DEPTH - 1:
						is_bedrock = true
					
					if is_bedrock:
						show_floating_text("Bedrock is indestructible!", tile_center_pos + Vector2(0, -25), Color.RED)
						reset_mining()
						return
					# --------------------------------

					if tile_pos == target_block:
						var tile_x = world.get_cell_atlas_coords(tile_pos).x
						# TOUGHNESS ORE BARU
						var block_toughness = 2.0 
						
						if tile_x == TILE_GRAVEL: block_toughness = 2.0
						elif tile_x == TILE_STONE: block_toughness = 2.5
						elif tile_x == TILE_COPPER: block_toughness = 2.5
						elif tile_x == TILE_IRON: block_toughness = 3.0
						elif tile_x == TILE_SILVER: block_toughness = 3.5
						elif tile_x == TILE_GOLD: block_toughness = 4.0
						elif tile_x == TILE_MITHRIL: block_toughness = 5.0
						# T3 Ores
						elif tile_x == TILE_QUARTZ: block_toughness = 3.0
						elif tile_x == TILE_TOPAZ: block_toughness = 3.5
						elif tile_x == TILE_EMERALD: block_toughness = 4.5
						elif tile_x == TILE_AMETHYST: block_toughness = 5.0
						elif tile_x == TILE_DIAMOND: block_toughness = 6.0
						elif tile_x == TILE_VOID: block_toughness = 7.0
						elif tile_x == TILE_UBERILIUM: block_toughness = 9.0
						# T3 Blocks
						elif tile_x == TILE_CRYSTAL_STONE: block_toughness = 3.5
						elif tile_x == TILE_HARDENED_STONE: block_toughness = 5.5
						
						# Check pneumatic weakened toughness
						if _pneumatic_weakened.has(tile_pos):
							block_toughness = _pneumatic_weakened[tile_pos]
						var _eff_stats = Global.get_effective_stats(held_item, item_data[held_item])
						var tool_efficiency = _eff_stats.get("efficiency", 1.0) + buff_efficiency
						var required_time = block_toughness / tool_efficiency
						
						mine_timer += delta
						crack_sprite.global_position = tile_center_pos
						crack_sprite.visible = true
						crack_sprite.modulate.a = clamp(mine_timer / required_time, 0.2, 1.0) 
						
						if mine_timer >= required_time: 
							var item_name = ""
							if tile_x == TILE_DIRT: 
								item_name = "Dirt"
								
								if Global.tutorial_step == 0:
									# === T1: hanya Stick ===
									if randf() < 0.65:
										tambah_item("Stick")
										show_floating_text("Stick (1)", tile_center_pos + Vector2(0, -25))
								else:
									if randf() < 0.65:
										var roll = randf()
										if roll < 0.10: 
											tambah_item("Broken Tools")
											show_floating_text("Broken Tools (1)", tile_center_pos + Vector2(0, -25))
										elif roll < 0.64: 
											tambah_item("Stick")
											show_floating_text("Stick (1)", tile_center_pos + Vector2(0, -25))
											if tutorial2_step == 1: 
												tutorial2_stats["sticks"] += 1
												update_objective_tutorial2()
										elif roll < 0.72: 
											tambah_item("Food Box")
											show_floating_text("Food Box (1)", tile_center_pos + Vector2(0, -25))
										elif roll < 0.85: 
											# === SMART SOIL (T3+) / ARROW (T2) ===
											if Global.tutorial_step >= 8:
												var _held_now = hotbar_items[selected_hotbar_index]
												if _held_now == "Crystal Minigun":
													var amt_ammo = randi_range(2, 6)
													tambah_item("Minigun Ammo", amt_ammo)
													show_floating_text("Minigun Ammo (" + str(amt_ammo) + ")", tile_center_pos + Vector2(0, -25), Color.PINK)
												elif _held_now and item_data.has(_held_now) and item_data[_held_now].has("charge_damage"):
													var amt_arrow = randi_range(1, 3)
													tambah_item("Arrow", amt_arrow)
													show_floating_text("Arrow (" + str(amt_arrow) + ")", tile_center_pos + Vector2(0, -25))
												else:
													tambah_item("Stick")
													show_floating_text("Stick (1)", tile_center_pos + Vector2(0, -25))
											else:
												# T2 tetap arrow seperti biasa
												var amt_arrow = randi_range(1, 3)
												tambah_item("Arrow", amt_arrow)
												show_floating_text("Arrow (" + str(amt_arrow) + ")", tile_center_pos + Vector2(0, -25))
										elif roll < 0.98: 
											var amt_torch = randi_range(1, 3)
											tambah_item("Torch", amt_torch)
											show_floating_text("Torch (" + str(amt_torch) + ")", tile_center_pos + Vector2(0, -25))
										else: 
											tambah_item("Dagger Part ⛏️")
											show_floating_text("Dagger Part ⛏️ ", tile_center_pos + Vector2(0, -25), Color.PURPLE)
										
								# --- WOODEN SWORD ---
								if Global.tutorial_step == 3 and not Global.wooden_sword_obtained:
									Global.wooden_sword_obtained = true
									hotbar_items[0] = "Wooden Sword"
									update_hotbar_ui()
									show_dialog("Look what you've got, it's a wooden sword! Some of the blocks not only contained the block itself but contained much more than that!")
							elif tile_x == TILE_COAL: item_name = "Coal"
							
							elif tile_x == TILE_IRON: 
								item_name = "Iron"
								# 4.8% Chance Drop Chainsaw Part dari Iron
								if Global.tutorial_step != 0 and randf() < 0.048:
									tambah_item("Chainsaw Part ⛏️")
									show_floating_text("Chainsaw Part ⛏️", tile_center_pos + Vector2(0, -25), Color.PURPLE)
									
							elif tile_x == TILE_COPPER: item_name = "Copper"
							
							elif tile_x == TILE_GRAVEL: 
								if randf() < 0.7: item_name = "Flint"
								else: item_name = "Gravel"
								# 6% Chance Drop Hunter Bow Part dari Gravel
								if randf() < 0.06:
									tambah_item("Hunter Bow Part ⛏️")
									show_floating_text("Hunter Bow Part ⛏️", tile_center_pos + Vector2(0, -25), Color.PURPLE)
									
							elif tile_x == TILE_STONE: item_name = "Stone"
							elif tile_x == TILE_SILVER: item_name = "Silver"
							elif tile_x == TILE_GOLD: item_name = "Gold"
							
							elif tile_x == TILE_MITHRIL: 
								item_name = "Mithril"
								if randf() < 0.026:
									tambah_item("Heretic Staff Part ⛏️")
									show_floating_text("Heretic Staff Part ⛏", tile_center_pos + Vector2(0, -25), Color.PURPLE)
							
							# --- T3 ORE DROPS ---
							elif tile_x == TILE_QUARTZ: item_name = "Quartz"
							elif tile_x == TILE_TOPAZ: item_name = "Topaz"
							elif tile_x == TILE_EMERALD: item_name = "Emerald"
							elif tile_x == TILE_AMETHYST: item_name = "Amethyst"
							elif tile_x == TILE_DIAMOND: item_name = "Diamond"
							elif tile_x == TILE_VOID: item_name = "Void Crystal"
							elif tile_x == TILE_UBERILIUM: item_name = "Uberilium"
							elif tile_x == TILE_CRYSTAL_STONE: item_name = "Crystal Stone"
							elif tile_x == TILE_HARDENED_STONE: item_name = "Hardened Crystal Stone"
							
							# --- DROP SCRAP DARI IRON / SILVER (T3 Only) ---
							if Global.tutorial_step >= 8 and (tile_x == TILE_IRON or tile_x == TILE_SILVER):
								if randf() < 0.15: # 15% chance
									var amt_scrap = randi_range(1, 2)
									tambah_item("Scrap", amt_scrap)
									show_floating_text("Scrap (" + str(amt_scrap) + ")", tile_center_pos + Vector2(0, -45), Color.LIGHT_GRAY)

							# --- DROP SCRAP DARI ORE T3 (Quartz ke atas) ---
							if Global.tutorial_step >= 8 and tile_x >= TILE_QUARTZ and tile_x <= TILE_UBERILIUM:
								if randf() < 0.25: # 25% chance
									var amt_scrap = randi_range(1, 3)
									tambah_item("Scrap", amt_scrap)
									show_floating_text("Scrap (" + str(amt_scrap) + ")", tile_center_pos + Vector2(0, -45), Color.LIGHT_GRAY)
							
							# --- DROP PART SENJATA (⛏️) DARI BLOK T3 KHUSUS ---
							if Global.tutorial_step >= 8:
								# 1. Hardened Crystal (Untuk Golem)
								if tile_x == TILE_HARDENED_STONE and randf() < 0.05: 
									tambah_item("Crystal Armor Part ⛏️")
									show_floating_text("Crystal Armor Part ⛏️", tile_center_pos + Vector2(0, -45), Color.SKY_BLUE)
									
								# 2. Diamond (Untuk Cave Slime)
								elif tile_x == TILE_DIAMOND and randf() < 0.05: 
									tambah_item("Crystal Minigun Part ⛏️")
									show_floating_text("Crystal Minigun Part ⛏️", tile_center_pos + Vector2(0, -45), Color.PINK)
									
								# 3. Amethyst (Untuk Spider)
								elif tile_x == TILE_AMETHYST and randf() < 0.05: 
									tambah_item("Mourning Bow Part ⛏️")
									show_floating_text("Mourning Bow Part ⛏️", tile_center_pos + Vector2(0, -45), Color.CYAN)
							# ---------------------------------------------------
							
							if item_name != "":
								tambah_item(item_name)
								show_floating_text(item_name + " (1)", tile_center_pos)
								if is_tutorial_active:
									match item_name:
										"Flint": tutorial_stats["flint"] += 1
										"Coal": tutorial_stats["coal"] += 1
										"Copper": tutorial_stats["copper"] += 1
										"Iron": tutorial_stats["iron"] += 1
									check_objective_progress()
								
							if tutorial2_step == 1 and tutorial2_stats["sticks"] >= 5:
								tutorial2_step = 2
								update_objective_tutorial2()
								show_dialog("Good job! Now, find the first checkpoint on depth 90 meters.")
								
							world.erase_cell(tile_pos)
							_pneumatic_weakened.erase(tile_pos)
							
							# --- BONECRUSHER: reduce adjacent toughness ---
							if held_item == "Bonecrusher":
								var _adj_list = [
									tile_pos + Vector2i(0, -1),
									tile_pos + Vector2i(0, 1),
									tile_pos + Vector2i(-1, 0),
									tile_pos + Vector2i(1, 0),
								]
								for _adj in _adj_list:
									if _adj.x < 0 or _adj.x >= WORLD_WIDTH: continue
									if _adj.y < 0: continue
									if Global.tutorial_step == 0 and _adj.y >= 100: continue
									if Global.tutorial_step != 0 and _adj.y >= WORLD_DEPTH - 1: continue
									if world.get_cell_source_id(_adj) == -1: continue
									var _cur = _bonecrusher_reduced.get(_adj, 0)
									if _cur < 3:
										_bonecrusher_reduced[_adj] = _cur + 1
										var _adj_x = world.get_cell_atlas_coords(_adj).x
										var _adj_base = _get_block_toughness_by_id(_adj_x)
										var _adj_eff = _adj_base - _bonecrusher_reduced[_adj]
										if _adj_eff <= 0.0:
											var _adj_center = world.to_global(world.map_to_local(_adj))
											world.erase_cell(_adj)
											var _adj_item = _get_item_name_for_tile(_adj_x)
											if _adj_item != "":
												tambah_item(_adj_item)
												show_floating_text(_adj_item + " (Crusher)", _adj_center, Color.ORANGE)
											_bonecrusher_reduced.erase(_adj)
							
							# --- PNEUMATIC DRILL: 30% bomb on break ---
							if held_item == "Pneumatic Drill" and randf() < 0.30:
								_spawn_pneumatic_bomb(tile_center_pos)
							
							cek_gravel_jatuh(Vector2i(tile_pos.x, tile_pos.y - 1))
							
							# --- SWARMID DRILL: 3x3 mining ---
							if held_item == "Swarmid Drill":
								for _dx in [-1, 0, 1]:
									for _dy in [-1, 0, 1]:
										if _dx == 0 and _dy == 0: continue
										var _adj = tile_pos + Vector2i(_dx, _dy)
										if _adj.x < 0 or _adj.x >= WORLD_WIDTH or _adj.y < 0 or _adj.y >= WORLD_DEPTH: continue
										if Global.tutorial_step == 0 and _adj.y >= 100: continue
										if Global.tutorial_step != 0 and _adj.y >= WORLD_DEPTH - 1: continue
										if world.get_cell_source_id(_adj) == -1: continue
										
										var _ax = world.get_cell_atlas_coords(_adj).x
										var _aitem = ""
										if _ax == TILE_DIRT: 
											_aitem = "Dirt"
											if randf() < 0.65 and Global.tutorial_step != 0:
												if randf() < 0.54: tambah_item("Stick")
												elif randf() < 0.3: tambah_item("Food Box")
												elif randf() < 0.5: tambah_item("Arrow", randi_range(1, 3))
												else: tambah_item("Torch", randi_range(1, 3))
										elif _ax == TILE_COAL: _aitem = "Coal"
										elif _ax == TILE_IRON: _aitem = "Iron"
										elif _ax == TILE_COPPER: _aitem = "Copper"
										elif _ax == TILE_GRAVEL: _aitem = "Flint" if randf() < 0.7 else "Gravel"
										elif _ax == TILE_STONE: _aitem = "Stone"
										elif _ax == TILE_SILVER: _aitem = "Silver"
										elif _ax == TILE_GOLD: _aitem = "Gold"
										elif _ax == TILE_MITHRIL: _aitem = "Mithril"
										elif _ax == TILE_QUARTZ: _aitem = "Quartz"
										elif _ax == TILE_TOPAZ: _aitem = "Topaz"
										elif _ax == TILE_EMERALD: _aitem = "Emerald"
										elif _ax == TILE_AMETHYST: _aitem = "Amethyst"
										elif _ax == TILE_DIAMOND: _aitem = "Diamond"
										elif _ax == TILE_VOID: _aitem = "Void Crystal"
										elif _ax == TILE_UBERILIUM: _aitem = "Uberilium"
										
										if _aitem != "":
											tambah_item(_aitem)
											show_floating_text(_aitem + " (1)", world.to_global(world.map_to_local(_adj)))
										
										world.erase_cell(_adj)
										cek_gravel_jatuh(_adj + Vector2i(0, -1))
							# -----------------------------------
							
							reset_mining()
					else:
						target_block = tile_pos
						mine_timer = 0.0
				else:
					reset_mining()
			else:
				reset_mining()
		else:
			reset_mining()
	else:
		reset_mining()

	var mouse_pos = get_global_mouse_position()
	var hovered_name = ""
	for enemy in enemies:
		if is_instance_valid(enemy) and mouse_pos.distance_to(enemy.global_position) < 35:
			var type = enemy.get_meta("type")
			if type == "goblin": hovered_name = "Goblin"
			elif type == "cannibal": hovered_name = "Cannibal"
			elif type == "slime_small": hovered_name = "Small Slime"
			elif type == "slime_medium": hovered_name = "Medium Slime"
			elif type == "slime_large": hovered_name = "Large Slime"
			elif type == "hunter": hovered_name = "Wild Hunter"
			elif type == "cult": hovered_name = "Cult"
			# --- TAMBAHKAN MUSUH T3 DI SINI ---
			elif type == "spider": hovered_name = "Giant Spider"
			elif type == "cave_slime": hovered_name = "Cave Slime"
			elif type == "crystal_golem": hovered_name = "Crystal Golem"
			break
	if hovered_name == "":
		var mouse_tile = world.local_to_map(world.to_local(mouse_pos))
		if world.get_cell_source_id(mouse_tile) != -1:
			var tile_id = world.get_cell_atlas_coords(mouse_tile).x
			if tile_id == TILE_DIRT: hovered_name = "Dirt"
			elif tile_id == TILE_COAL: hovered_name = "Coal"
			elif tile_id == TILE_IRON: hovered_name = "Iron"
			elif tile_id == TILE_COPPER: hovered_name = "Copper"
			elif tile_id == TILE_GRAVEL: hovered_name = "Gravel"
			elif tile_id == TILE_STONE: hovered_name = "Stone"
			elif tile_id == TILE_SILVER: hovered_name = "Silver"
			elif tile_id == TILE_GOLD: hovered_name = "Gold"
			elif tile_id == TILE_MITHRIL: hovered_name = "Mithril"
			# --- TAMBAHKAN ORE & BLOK T3 DI SINI ---
			elif tile_id == TILE_QUARTZ: hovered_name = "Quartz"
			elif tile_id == TILE_TOPAZ: hovered_name = "Topaz"
			elif tile_id == TILE_EMERALD: hovered_name = "Emerald"
			elif tile_id == TILE_AMETHYST: hovered_name = "Amethyst"
			elif tile_id == TILE_DIAMOND: hovered_name = "Diamond"
			elif tile_id == TILE_VOID: hovered_name = "Void Crystal"
			elif tile_id == TILE_UBERILIUM: hovered_name = "Uberilium"
			elif tile_id == TILE_CRYSTAL_STONE: hovered_name = "Crystal Stone"
			elif tile_id == TILE_HARDENED_STONE: hovered_name = "Hardened Stone"

	if hovered_name != "":
		ui_tooltip.visible = true
		ui_tooltip.text = hovered_name
		ui_tooltip.position = get_viewport().get_mouse_position() + Vector2(15, 15)
	else:
		ui_tooltip.visible = false

func use_food_box():
	if inventory.get("Food Box", 0) <= 0: return
	inventory["Food Box"] -= 1
	if inventory["Food Box"] <= 0: 
		inventory.erase("Food Box")
		for i in range(7):
			if hotbar_items[i] == "Food Box": hotbar_items[i] = null
			
	var roll = randf()
	var food_name = ""
	
	if roll < 0.40: food_name = "Banana"
	elif roll < 0.60: food_name = "Grape"
	elif roll < 0.75: food_name = "Bacon"
	elif roll < 0.825: food_name = "Pizza Slice"
	elif roll < 0.90: food_name = "Burger"
	elif roll < 0.95: food_name = "Golden Burger"
	else: food_name = "Frozen Apple"
		
	tambah_item(food_name)
	show_floating_text(food_name + " (1)", $Player.global_position)
	update_inventory_ui()
	update_hotbar_ui()

func consume_food(food_name):
	if inventory.get(food_name, 0) <= 0: return
	
	inventory[food_name] -= 1
	if inventory[food_name] <= 0: 
		inventory.erase(food_name)
		for i in range(7):
			if hotbar_items[i] == food_name: hotbar_items[i] = null
			
	if food_name == "Banana": 
		current_hp = min(current_hp + 20, max_hp)
		update_hp_ui()
		show_floating_text("+20 HP", $Player.global_position, Color.GREEN)
		
	elif food_name == "Grape": 
		active_food_buffs["Grape (Regen)"] = 6.0
		for i in range(6):
			if current_hp >= max_hp:
				show_floating_text("HP Full", $Player.global_position + Vector2(0, -20), Color.GRAY)
			else:
				current_hp = min(current_hp + 5, max_hp)
				update_hp_ui()
				show_floating_text("+5 HP", $Player.global_position + Vector2(0, -20), Color.GREEN)
			await get_tree().create_timer(1.0).timeout
			
	elif food_name == "Bacon": 
		current_hp = min(current_hp + 30, max_hp)
		update_hp_ui()
		dmg_reduction = 5.0
		active_food_buffs["Bacon (DR)"] = 8.0
		show_floating_text("+30 HP, Dmg Reduction", $Player.global_position, Color.GREEN)
		await get_tree().create_timer(8.0).timeout
		if active_food_buffs["Bacon (DR)"] <= 0: dmg_reduction = 0.0
		
	elif food_name == "Pizza Slice": 
		current_hp = min(current_hp + 5, max_hp)
		update_hp_ui()
		buff_dmg_mult += 0.50
		active_food_buffs["Pizza (Dmg)"] = 8.0
		show_floating_text("+5 HP, +50% Dmg", $Player.global_position, Color.GREEN)
		await get_tree().create_timer(8.0).timeout
		if active_food_buffs["Pizza (Dmg)"] <= 0: buff_dmg_mult -= 0.50
		
	elif food_name == "Burger": 
		buff_speed_mult += 0.40
		buff_dmg_mult += 0.80
		$Player.speed = 300.0 * buff_speed_mult
		active_food_buffs["Burger (Spd/Dmg)"] = 10.0
		show_floating_text("Speed & Dmg UP", $Player.global_position, Color.GREEN)
		await get_tree().create_timer(10.0).timeout
		if active_food_buffs["Burger (Spd/Dmg)"] <= 0:
			buff_speed_mult -= 0.40
			buff_dmg_mult -= 0.80
			$Player.speed = 300.0 * buff_speed_mult
			
	elif food_name == "Golden Burger": 
		dmg_reduction = 99.0
		active_food_buffs["Golden Burger (Inv)"] = 8.0
		show_floating_text("INVINCIBLE", $Player.global_position, Color.GOLD)
		await get_tree().create_timer(8.0).timeout
		if active_food_buffs["Golden Burger (Inv)"] <= 0: dmg_reduction = 0.0
		
	elif food_name == "Frozen Apple": 
		freeze_timer = 8.0
		active_food_buffs["Frozen Apple (Freeze)"] = 8.0
		show_floating_text("Enemies Frozen", $Player.global_position, Color.CYAN)
	
	# Sync ke Global: makanan yang habis harus hilang dari backpack
	if inventory.has(food_name):
		Global.saved_inventory[food_name] = inventory[food_name]
	else:
		Global.saved_inventory.erase(food_name)
	Global.hotbar_items = hotbar_items.duplicate()
	Global.save_game()
	
	update_hp_ui()
	update_inventory_ui()
	update_hotbar_ui()

func drop_loot(type: String):
	var drop_chance = randf()
	if type == "slime_small" or type == "slime_medium" or type == "slime_large":
		if drop_chance < 0.05: dungeon_gold +=2; show_floating_text("+2 Gold", $Player.global_position, Color.GOLD)
	elif type == "goblin":
		if drop_chance < 0.10: tambah_item("Food Box"); show_floating_text("Food Box", $Player.global_position)
		elif drop_chance < 0.17: dungeon_gold += 3; show_floating_text("+3 Gold", $Player.global_position, Color.GOLD)
		elif drop_chance < 0.21: tambah_item("Dagger Part 💀"); show_floating_text("Dagger Part 💀", $Player.global_position, Color.PURPLE)
	elif type == "cannibal":
		if drop_chance < 0.08: dungeon_gold += 3; show_floating_text("+3 Gold", $Player.global_position, Color.GOLD)
		elif drop_chance < 0.12: tambah_item("Food Box"); show_floating_text("Food Box", $Player.global_position)
		elif drop_chance < 0.14: tambah_item("Chainsaw Part 💀"); show_floating_text("Chainsaw Part 💀", $Player.global_position, Color.PURPLE)
	elif type == "hunter":
		if drop_chance < 0.07: dungeon_gold += 3; show_floating_text("+3 Gold", $Player.global_position, Color.GOLD)
		elif drop_chance < 0.27: tambah_item("Arrow"); show_floating_text("Arrows", $Player.global_position)
		elif drop_chance < 0.42: tambah_item("Hunter Bow Part 💀"); show_floating_text("Hunter Bow Part 💀", $Player.global_position, Color.PURPLE)
	elif type == "cult":
		if drop_chance < 0.10: dungeon_gold += 5; show_floating_text("+5 Gold", $Player.global_position, Color.GOLD)
		elif drop_chance < 0.15: tambah_item("Food Box"); show_floating_text("Food Box", $Player.global_position)
		elif drop_chance < 0.16: tambah_item("Heretic Staff Part 💀"); show_floating_text("Heretic Staff Part 💀", $Player.global_position, Color.PURPLE)
	elif type == "spider":
		if drop_chance < 0.04: tambah_item("Mourning Bow Part 💀"); show_floating_text("Mourning Bow Part 💀", $Player.global_position, Color.CYAN)
		elif drop_chance < 0.19: dungeon_gold += randi_range(5, 10); show_floating_text("+Gold", $Player.global_position, Color.GOLD)
	elif type == "cave_slime":
		if drop_chance < 0.02: tambah_item("Crystal Minigun Part 💀"); show_floating_text("Crystal Minigun Part 💀", $Player.global_position, Color.PINK)
		elif drop_chance < 0.23: dungeon_gold +=randi_range(7, 15); show_floating_text("+Gold", $Player.global_position, Color.GOLD)
	elif type == "crystal_golem":
		if drop_chance < 0.04: tambah_item("Crystal Armor Part 💀"); show_floating_text("Crystal Armor Part 💀", $Player.global_position, Color.SKY_BLUE)
		elif drop_chance < 0.09: dungeon_gold +=randi_range(14, 25); show_floating_text("+Gold", $Player.global_position, Color.GOLD)

func try_attack(mouse_world_pos, is_charged):
	var held_item = hotbar_items[selected_hotbar_index]
	var held_uuid = Global.hotbar_uuids[selected_hotbar_index]
	if held_uuid == null: held_uuid = ""
	if held_item == null: return false
	var item_stats = Global.get_effective_stats(held_item, item_data.get(held_item, {}), held_uuid)
	
	# --- RADIANCE SCEPTER: Self-Heal Utility ---
	if held_item == "Radiance Scepter":
		if attack_cooldown > 0: return true
		var _mana_cost = item_stats.get("mana_cost", 25)
		if current_mana < _mana_cost:
			show_floating_text("Not enough Mana!", $Player.global_position, Color.BLUE)
			attack_cooldown = 0.5
			return true
		current_mana -= _mana_cost
		
		var _heal = item_stats.get("heal_amount", 12)
		var _lv = Global.get_item_level("Radiance Scepter")
		if _lv > 1:
			_heal = int(_heal * (1.0 + 0.1 * (_lv - 1)))
		current_hp = min(current_hp + _heal, max_hp)
		attack_cooldown = item_stats.get("attack_speed", 1.5) / buff_atk_speed_mult
		
		show_floating_text("+" + str(_heal) + " HP", $Player.global_position + Vector2(0, -40), Color.GREEN)
		
		var _heal_fx = ColorRect.new()
		_heal_fx.size = Vector2(60, 60)
		_heal_fx.position = $Player.global_position - Vector2(30, 30)
		_heal_fx.color = Color(1.0, 0.9, 0.5, 0.6)
		_heal_fx.z_index = 15
		add_child(_heal_fx)
		var _ht = create_tween()
		_ht.tween_property(_heal_fx, "scale", Vector2(1.8, 1.8), 0.3)
		_ht.parallel().tween_property(_heal_fx, "modulate:a", 0.0, 0.3)
		_ht.tween_callback(_heal_fx.queue_free)
		
		update_hp_ui()
		update_exp_ui()
		return true
	# -------------------------------------------
	
	# LOGIKA BUKA CHEST
	var attack_range = item_stats.get("range", 64.0) 
	for chest in chests:
		if is_instance_valid(chest) and mouse_world_pos.distance_to(chest.global_position) < 30: 
			if $Player.global_position.distance_to(chest.global_position) <= attack_range:
				open_chest(chest)
				return true
			else:
				show_floating_text("Too far!", $Player.global_position)
				return true
	
		# LOGIKA LIFT (Hanya bisa diklik kalau ada lift_nodes)
		# LOGIKA LIFT
	for lift in lift_nodes:
		if is_instance_valid(lift) and mouse_world_pos.distance_to(lift.global_position) < 40:
			var lift_depth = world.local_to_map(world.to_local(lift.global_position)).y
			
			# --- T3 TUTORIAL: lift 590m TRAP (klik = tidak ada respon sama sekali) ---
			if Global.tutorial_step == 8 and lift_depth < 1000:
				return true  # Matikan lift, tidak trigger checkpoint juga
			# ----------------------------------------------------------------------
			
			var tut1_ready = is_tutorial_active and current_objective_index >= objectives.size() - 1
			var tut2_ready = Global.tutorial_step == 3 and tutorial2_step >= 3
			var tut3_ready = Global.tutorial_step >= 8
			
			if tut1_ready or tut2_ready or tut3_ready:
				start_lift_sequence(lift)
			else:
				show_floating_text("Finish the objectives first!", $Player.global_position)
			return true
		
	# LOGIKA CHECKPOINT
	for i in range(checkpoint_nodes.size()):
		var cp = checkpoint_nodes[i]
		if is_instance_valid(cp) and mouse_world_pos.distance_to(cp.global_position) < 40:
			last_checkpoint_pos = cp.global_position + Vector2(0, -32)
			clear_area(world.local_to_map(world.to_local(last_checkpoint_pos)), 1)
			
			if i == 0 and tutorial2_step == 2:
				tutorial2_step = 3
				update_objective_tutorial2()
				show_dialog("Checkpoint activated! Now, descend to depth 290 to find the lift.")
			elif Global.tutorial_step >= 8:
				show_floating_text("Checkpoint Activated!", cp.global_position + Vector2(0, -50), Color.GREEN)
				
				var cp_depth = world.local_to_map(world.to_local(cp.global_position)).y
				# JEBAKAN: Hanya aktif saat T3 belum selesai (tutorial_step == 8)
				if Global.tutorial_step == 8 and cp_depth >= 590:
					var _lift_was_here = false
					for l in lift_nodes:
						if is_instance_valid(l):
							var l_depth = world.local_to_map(world.to_local(l.global_position)).y
							if l_depth == 590:
								explode_lift(l)
								_lift_was_here = true
								break
					if _lift_was_here:
						show_dialog("Warning: Activating the checkpoint triggered a trap! The lift has exploded. You cannot retreat anymore. Defeat the boss at Layer 12!")
				
				# Tutorial 3: CP6 activated → objective advance (hanya T3)
				if cp_depth == 590 and Global.tutorial3_step == 1 and Global.tutorial_step == 8:
					Global.tutorial3_step = 2
					Global.save_game()
					update_objective_tutorial3()
			
			cp.get_child(0).color = Color.GREEN
			var cp_light = cp.get_node_or_null("CheckpointLight")
			if cp_light:
				cp_light.color = Color.GREEN
				
			return true
		
	for i in range(checkpoint_nodes.size()):
		var cp = checkpoint_nodes[i]
		if is_instance_valid(cp) and mouse_world_pos.distance_to(cp.global_position) < 40:
			# Simpan posisi checkpoint sebagai respawn point
			last_checkpoint_pos = cp.global_position + Vector2(0, -32)
			clear_area(world.local_to_map(world.to_local(last_checkpoint_pos)), 1)
			
			# Logika Notifikasi T2
			if i == 0 and tutorial2_step == 2:
				tutorial2_step = 3
				update_objective_tutorial2()
				show_dialog("Checkpoint activated! Now, descend to depth 290 to find the lift.")
			# Logika Notifikasi T3 (BARU)
			elif Global.tutorial_step >= 8:
				show_floating_text("Checkpoint Activated!", cp.global_position + Vector2(0, -50), Color.GREEN)
			
			# Ubah warna tiang dan lampu jadi hijau
			cp.get_child(0).color = Color.GREEN
			var cp_light = cp.get_node_or_null("CheckpointLight")
			if cp_light:
				cp_light.color = Color.GREEN # Lampu nyala hijau
				
			return true
		# LOGIKA MAGIC (HERETIC STAFF)
	if held_item == "Heretic Staff":
		if attack_cooldown > 0: return true
		var mana_cost = item_stats.get("mana_cost", 20)
		if current_mana < mana_cost:
			show_floating_text("Not enough Mana!", $Player.global_position, Color.BLUE)
			attack_cooldown = 0.5
			return true
		
		current_mana -= mana_cost
		attack_cooldown = item_stats.get("attack_speed", 1.2) / buff_atk_speed_mult
		
		# Cari musuh terdekat di arah mouse
		var target = null
		var closest_dist = 384.0
		for enemy in enemies:
			if is_instance_valid(enemy):
				var d = mouse_world_pos.distance_to(enemy.global_position)
				if d < closest_dist:
					closest_dist = d
					target = enemy
		
		if target != null:
			if target.get_meta("is_invulnerable", false):
				show_floating_text("INVULNERABLE!", target.global_position + Vector2(0, -40), Color.GRAY)
				return true
			var dmg = int(item_stats.get("damage", 32) * buff_dmg_mult)
			# Efek visual garis sihir
			var line = Line2D.new()
			line.add_point($Player.global_position)
			line.add_point(target.global_position)
			line.width = 3.0
			line.default_color = Color(0.8, 0.2, 1.0)
			add_child(line)
			var t = create_tween()
			t.tween_property(line, "modulate:a", 0.0, 0.3)
			t.tween_callback(line.queue_free)
			
			# Damage
			var hp = target.get_meta("hp") - dmg
			target.set_meta("hp", hp)
			update_enemy_hp_bar(target)
			show_floating_text(str(dmg), target.global_position + Vector2(0, -20), Color.MEDIUM_PURPLE)
			
			# 70% chance terrify (semua musuh freeze 1.5 detik)
			if randf() < 0.7:
				target.set_meta("terrified_timer", 1.5)
				show_floating_text("TERRIFIED!", target.global_position + Vector2(0, -40), Color.PURPLE)
			
			if hp <= 0:
				gain_exp(target.get_meta("exp"))
				drop_loot(target.get_meta("type"))
				
				if target.get_meta("type") == "boss_spider":
					spawn_final_lift()
					give_boss_loot()
					if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
					
				enemies.erase(target)
				target.queue_free()
		return true
	
	if held_item == "Crystal Minigun":
		if attack_cooldown > 0: return true
		if minigun_exhausted_timer > 0:
			show_floating_text("COOLDOWN!", $Player.global_position, Color.RED)
			return true
		if inventory.get("Minigun Ammo", 0) <= 0:
			show_floating_text("No Ammo!", $Player.global_position, Color.RED)
			attack_cooldown = 0.5
			return true
		
		inventory["Minigun Ammo"] -= 1
		if inventory["Minigun Ammo"] <= 0:
			inventory.erase("Minigun Ammo")
		update_inventory_ui()
		update_hotbar_ui()
		
		minigun_fire_timer += 0.1
		if minigun_fire_timer >= 12.0:
			minigun_exhausted_timer = 4.0
			minigun_fire_timer = 0.0
		
		attack_cooldown = item_stats.get("attack_speed", 0.1) / buff_atk_speed_mult
		var _mg_dmg = int(item_stats.get("damage", 12) * buff_dmg_mult)
		var _mg_range = item_stats.get("range", 208.0)
		
		minigun_shot_count += 1
		if minigun_shot_count >= 10:
			minigun_shot_count = 0
			spawn_minigun_boulder($Player.global_position, get_global_mouse_position(), int(_mg_dmg * 1.3))
		
		for _e in enemies.duplicate():
			if not is_instance_valid(_e): continue
			if $Player.global_position.distance_to(_e.global_position) > _mg_range: continue
			
			var _ct = _e.get_meta("type")
			var _ce = _e.get_meta("exp") if _e.has_meta("exp") else 0
			var _hp = _e.get_meta("hp") - _mg_dmg
			_e.set_meta("hp", _hp)
			update_enemy_hp_bar(_e)
			show_floating_text(str(_mg_dmg), _e.global_position + Vector2(0, -40), Color.PINK)
			
			if _hp <= 0:
				if is_tutorial_active and _ct == "goblin":
					tutorial_stats["goblins_killed"] += 1
					check_objective_progress()
				if _ct == "boss_spider":
					spawn_final_lift()
					give_boss_loot()
					if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
				gain_exp(_ce)
				drop_loot(_ct)
				enemies.erase(_e)
				if is_instance_valid(_e):
					_e.queue_free()
		
		var _mg_beam = Line2D.new()
		_mg_beam.add_point($Player.global_position)
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
			show_floating_text("No Ammo!", $Player.global_position)
			attack_cooldown = 0.5
			return true
		inventory["Arrow"] -= 1
		if inventory["Arrow"] <= 0: 
			inventory.erase("Arrow")
			for i in range(7):
				if hotbar_items[i] == "Arrow": hotbar_items[i] = null
		update_inventory_ui()
		update_hotbar_ui()
		
		var base_bow_dmg = (item_stats.get("charge_damage", 20) if is_charged else item_stats.get("damage", 7))
		if held_item == "Bounty Bow":
			base_bow_dmg = int(base_bow_dmg * (1.0 + bounty_bow_stacks * 0.20))
		var dmg = int(base_bow_dmg * buff_dmg_mult)
		var base_cd = item_stats.get("charge_speed", 1.0) if is_charged else item_stats.get("attack_speed", 0.5)
		attack_cooldown = base_cd / buff_atk_speed_mult
		
		# --- MARBLE SLINGSHOT: split 8 proyektil (shotgun burst) ---
		if held_item == "Marble Slingshot" and is_charged:
			var _pellet_dmg = max(1, int(item_stats.get("damage", 15) * buff_dmg_mult * 0.5))
			for _i in range(8):
				var _angle_off = -20.0 + (40.0 / 7.0) * _i
				var _dir = (mouse_world_pos - $Player.global_position).normalized().rotated(deg_to_rad(_angle_off))
				var _target = $Player.global_position + _dir * 500.0
				spawn_arrow($Player.global_position, _target, _pellet_dmg, "player", held_item, true)
		# --- WEAPON BIASA / MOURNING BOW / EXPLOSIVE CROSSBOW ---
		else:
			spawn_arrow($Player.global_position, mouse_world_pos, dmg, "player", held_item, is_charged)
			# Mourning Bow: stun on charge shot
			if held_item == "Mourning Bow" and is_charged:
				arrows[arrows.size() - 1].set_meta("stun_on_hit", 2.0)
		
		if is_charged and is_tutorial_active and tutorial_stats["charged_bow"] < 1:
			tutorial_stats["charged_bow"] += 1
			check_objective_progress()
		return true
		
	# LOGIKA MELEE (TANPA CRIT)
	if not item_stats.has("damage"): return false 
	attack_range = item_stats["range"]
	var base_damage = item_stats["damage"] * buff_dmg_mult 
	var atk_speed = item_stats["attack_speed"] / buff_atk_speed_mult 
	var knockback = item_stats["knockback"]
	
	if held_item == "Swarmid Drill" and swarmid_exhausted_timer > 0:
		show_floating_text("EXHAUSTED!", $Player.global_position, Color.RED)
		return true
	
	# --- MANIACAL CHAINSAW EXHAUSTED ---
	if held_item == "Maniacal Chainsaw":
		if chainsaw_exhausted_timer > 0:
			show_floating_text("EXHAUSTED!", $Player.global_position, Color.RED) # domain: clone_player
			return true
		chainsaw_use_timer += 0.1
		if chainsaw_use_timer >= 10.0:
			chainsaw_exhausted_timer = 4.0
			chainsaw_use_timer = 0.0
		
	
	var clicked_enemy = null
	for enemy in enemies:
		if is_instance_valid(enemy):
			# Cek jarak berdasarkan ukuran musuh (Boss lebih gampang dipukul)
			var hit_radius = enemy.get_meta("size", 16.0) + 16.0 
			if mouse_world_pos.distance_to(enemy.global_position) < hit_radius:
				clicked_enemy = enemy
				break
			
		# Di atas main.gd tambahkan: var sword_combo =
		
	
	if clicked_enemy:
		if clicked_enemy.get_meta("is_invulnerable", false):
			show_floating_text("INVULNERABLE!", clicked_enemy.global_position + Vector2(0, -40), Color.GRAY)
			return true
			
		# --- RUMUS JARAK BARU: Jarak player ke TEPI musuh, bukan ke tengah ---
		var enemy_radius = clicked_enemy.get_meta("size", 16.0) / 2.0
		if $Player.global_position.distance_to(clicked_enemy.global_position) <= (attack_range + enemy_radius):
			attack_cooldown = atk_speed 
			
			# --- SILVER GRAY SWORD: Accelerate speed bonus ---
			if held_item == "Silver Gray Sword" and sgs_accelerate_stacks > 0:
				attack_cooldown = attack_cooldown / (1.0 + sgs_accelerate_stacks * 0.10)
			# ------------------------------------------------
			
			var final_dmg = int(base_damage)
			
			# --- BLEED VULNERABILITY (musuh bleeding terima +15% physical) ---
			if clicked_enemy.get_meta("bleed_dmg", 0) > 0:
				final_dmg = int(final_dmg * 1.15)
			# ---------------------------------------------------------------
			
			# --- SHARDING SWORD: magic vuln stack ---
			if item_stats.get("weapon_type") == "Magic Damage":
				var _mv = clicked_enemy.get_meta("magic_vuln", 0.0)
				if _mv > 0.0:
					final_dmg = int(final_dmg * (1.0 + _mv))
			
			# --- GALAHAD: +1% dmg per stack ---
			if held_item == "Galahad Chimelin":
				final_dmg = int(final_dmg * (1.0 + galahad_stacks * 0.01))
			
			# --- PASSIVE IRON SWORD ---
			if held_item == "Iron Sword":
				sword_combo += 1
				if sword_combo >= 3:
					final_dmg = int(final_dmg * 1.2)
					sword_combo = 0
					show_floating_text("PASSIVE!", clicked_enemy.global_position + Vector2(0, -40), Color.GOLD)
			else:
				sword_combo = 0
			# ---------------------------
				
			# --- REVENGER: boost vs attacker ---
			if held_item == "Revenger Crystallinum" and clicked_enemy == revenger_target and revenger_stacks > 0:
				final_dmg = int(final_dmg * (1.0 + revenger_stacks * 0.30))
			# ------------------------------------
			
			# --- POISON (MENACING DAGGER) 30% chance ---
			if held_item == "Menacing Dagger" and randf() < 0.3:
				clicked_enemy.set_meta("poison_dmg", max(1, int(final_dmg * 0.25)))
				clicked_enemy.set_meta("poison_tick", 0.0)
				clicked_enemy.set_meta("poison_rem", 5)
				show_floating_text("POISON!", clicked_enemy.global_position + Vector2(0, -60), Color.GREEN)
			# --------------------------------------------
			
			# --- BLEED (MANIACAL CHAINSAW) 40% chance ---
			if held_item == "Maniacal Chainsaw" and randf() < 0.4:
				clicked_enemy.set_meta("bleed_dmg", max(1, int(final_dmg * 0.15)))
				clicked_enemy.set_meta("bleed_tick", 0.0)
				clicked_enemy.set_meta("bleed_rem", 5)
				show_floating_text("BLEED!", clicked_enemy.global_position + Vector2(0, -60), Color.RED)
			# --------------------------------------------
			
			var actual_dmg = final_dmg
			
			# 1. Golem Resistance
			if clicked_enemy.get_meta("type") == "crystal_golem" and item_stats.get("weapon_type") == "Physical Damage":
				actual_dmg = int(actual_dmg * 0.7)
				show_floating_text("Resisted!", clicked_enemy.global_position + Vector2(0, -60), Color.GRAY)
				
			# 2. Slime Armor
			if clicked_enemy.get_meta("type") == "cave_slime" and clicked_enemy.get_meta("armor_hp", 0) > 0:
				var armor_hp = clicked_enemy.get_meta("armor_hp")
				var armor_damage = min(actual_dmg, armor_hp)
				clicked_enemy.set_meta("armor_hp", armor_hp - armor_damage)
				actual_dmg -= armor_damage
				clicked_enemy.set_meta("armor_regen_timer", 0.0) # Reset regen
				show_floating_text(str(armor_damage) + " (Armor)", clicked_enemy.global_position + Vector2(0, -20), Color.YELLOW)
			
			# --- SHARDING SWORD: apply vuln stack (max 3 = 60%, 5s per target) ---
			if held_item == "Sharding Sword":
				var _cv = clicked_enemy.get_meta("magic_vuln", 0.0)
				var _new_vuln = min(_cv + 0.2, 0.6)
				clicked_enemy.set_meta("magic_vuln", _new_vuln)
				clicked_enemy.set_meta("magic_vuln_timer", 5.0)
				show_floating_text("Magic Vuln " + str(int(_new_vuln * 100)) + "%", clicked_enemy.global_position + Vector2(0, -80), Color.PURPLE)
				
			var hp = clicked_enemy.get_meta("hp") - actual_dmg
			if actual_dmg > 0:
				var dmg_color = Color.RED
				var w_type = item_stats.get("weapon_type", "")
				if w_type == "Elemental Damage": dmg_color = Color.GREEN
				elif w_type == "Magic Damage": dmg_color = Color.MEDIUM_PURPLE
				show_floating_text(str(actual_dmg), clicked_enemy.global_position + Vector2(0, -40), dmg_color)
			clicked_enemy.set_meta("hp", hp)
			update_enemy_hp_bar(clicked_enemy)
			# --- SILVER GRAY SWORD: Accelerate stack ---
			if held_item == "Silver Gray Sword":
				set_meta("sgs_reset_timer", 5.0)
				sgs_hit_counter += 1
				if sgs_hit_counter >= 5:
					sgs_hit_counter = 0
					if sgs_accelerate_stacks < 5:
						sgs_accelerate_stacks += 1
						show_floating_text("Accelerate " + str(sgs_accelerate_stacks) + "/5", clicked_enemy.global_position + Vector2(0, -80), Color.CYAN)
			# -------------------------------------------
			
			clicked_enemy.get_child(0).color = Color.WHITE
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(clicked_enemy):
								clicked_enemy.get_child(0).color = clicked_enemy.get_meta("base_color", Color.WHITE)
				
			if hp <= 0:
				# Cache metadata SEBELUM enemy bisa di-free
				var _cached_type = clicked_enemy.get_meta("type")
				var _cached_exp = clicked_enemy.get_meta("exp") if clicked_enemy.has_meta("exp") else 0
				
				# --- GALAHAD: stack on kill ---
				if held_item == "Galahad Chimelin":
					galahad_stacks = min(galahad_stacks + 1, 80)
					show_floating_text("+" + str(galahad_stacks) + "% DMG", $Player.global_position + Vector2(0, -60), Color.GOLD)
				gain_exp(_cached_exp)
				drop_loot(_cached_type)
				
				if is_tutorial_active and _cached_type == "goblin":
					tutorial_stats["goblins_killed"] += 1
					check_objective_progress()
				
				if _cached_type == "boss_spider":
					spawn_final_lift()
					give_boss_loot()
					if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
					
				if clicked_enemy.get_meta("type") == "boss_spider":
					spawn_final_lift()
					give_boss_loot()
					if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false # <--- TAMBAHKAN INI
					
				enemies.erase(clicked_enemy)
				if is_instance_valid(clicked_enemy):
					clicked_enemy.queue_free()
			else:
				if knockback > 0:
					var dir = sign(clicked_enemy.global_position.x - $Player.global_position.x)
					_safe_knockback(clicked_enemy, dir, knockback)
					
					if clicked_enemy.get_meta("type") == "spider":
						clicked_enemy.velocity.x = dir * 600.0
						clicked_enemy.velocity.y = -300.0
						clicked_enemy.set_meta("knockback_timer", 1.0)
					elif clicked_enemy.get_meta("type") == "mini_spideroid":
						clicked_enemy.velocity.x = dir * 400.0
						clicked_enemy.velocity.y = -200.0
						clicked_enemy.set_meta("knockback_timer", 0.5)
					# -------------------------------------------------------------
					elif clicked_enemy.get_meta("type") == "mini_spideroid":
						clicked_enemy.velocity.x = dir * 400.0 # Sedikit lebih rendah
						clicked_enemy.velocity.y = -200.0
						clicked_enemy.set_meta("knockback_timer", 0.5) # Stun lebih singkat
					
				if clicked_enemy.get_meta("type") == "goblin":
					clicked_enemy.set_meta("state", "flee")
					clicked_enemy.set_meta("flee_timer", 3.0)
					show_floating_text("Counter!", clicked_enemy.global_position + Vector2(0, -20))
					
				# TAMBAHAN BARU: Hunter dipukul Melee -> Marah!
				if clicked_enemy.get_meta("type") == "hunter":
					clicked_enemy.set_meta("state", "enraged")
					show_floating_text("Enraged!", clicked_enemy.global_position + Vector2(0, -20), Color.RED)
		return true 
	
	sword_combo = 0
	return false 

func update_combat(delta):
	if is_dead or is_spectating: return
	if damage_cooldown > 0: damage_cooldown -= delta
	if attack_cooldown > 0: attack_cooldown -= delta
	# --- TIMER RESET SENJATA SAAT TIDAK DIPAKAI ---
	var _current_held = hotbar_items[selected_hotbar_index]
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
			show_floating_text("DRILL EXHAUSTED!", $Player.global_position + Vector2(0, -60), Color.RED)
	elif _current_held != "Swarmid Drill" or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		swarmid_use_timer = move_toward(swarmid_use_timer, 0, delta * 2.0)
	if hammer_charging: hammer_charge_timer += delta
	if stormjade_charging: stormjade_charge_timer += delta
	if galahad_parry_cd > 0: galahad_parry_cd -= delta
	var player_pos = $Player.global_position
	
	# --- EFEK STUN & SLOW JARING ---
	if player_stun_timer > 0 or deep_cave_active:
		if player_stun_timer > 0:
			player_stun_timer -= delta
		$Player.velocity.x = 0
		if $Player.is_physics_processing():
			$Player.set_physics_process(false)
	else:
		if not $Player.is_physics_processing():
			$Player.set_physics_process(true)

	if player_slow_timer > 0:
		player_slow_timer -= delta
		if $Player.speed == 300.0: $Player.speed = 150.0
	elif $Player.speed == 150.0:
		$Player.speed = 300.0
	# ------------------------------------------------
	
	var p_rect = Rect2(player_pos.x - 16, player_pos.y - 32, 32, 64)
	p_rect = p_rect.grow(8.0) 
	
	# Loop mundur (dari belakang ke depan) biar aman kalau ada enemy yang mati
	for i in range(enemies.size() - 1, -1, -1):
		if i >= enemies.size(): continue
		var enemy = enemies[i]
		if not is_instance_valid(enemy): continue
		if enemy.is_queued_for_deletion(): continue
		
		# --- POISON TICK (1 damage per detik) ---
		if enemy.has_meta("poison_dmg"):
			var ptick = enemy.get_meta("poison_tick", 0.0) + delta
			if ptick >= 1.0:
				ptick = 0.0
				var pdmg = enemy.get_meta("poison_dmg")
				var php = enemy.get_meta("hp") - pdmg
				enemy.set_meta("hp", php)
				update_enemy_hp_bar(enemy)
				show_floating_text(str(pdmg), enemy.global_position + Vector2(0, -20), Color.GREEN)
				var prem = enemy.get_meta("poison_rem", 5) - 1
				if prem <= 0:
					enemy.remove_meta("poison_dmg")
					enemy.remove_meta("poison_tick")
					enemy.remove_meta("poison_rem")
				else:
					enemy.set_meta("poison_rem", prem)
				if php <= 0:
					gain_exp(enemy.get_meta("exp"))
					drop_loot(enemy.get_meta("type"))
					_try_drop_hammer_ore(enemy)
					if is_tutorial_active and enemy.get_meta("type") == "goblin":
						tutorial_stats["goblins_killed"] += 1
						check_objective_progress()
					if enemy.get_meta("type") == "boss_spider":
						spawn_final_lift()
						give_boss_loot()
						if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
					enemies.remove_at(i)
					enemy.queue_free()
					continue
			enemy.set_meta("poison_tick", ptick)
		# ---------------------------------------
		
		# --- BLEED TICK (1 damage per detik) ---
		if enemy.has_meta("bleed_dmg"):
			var btick = enemy.get_meta("bleed_tick", 0.0) + delta
			if btick >= 1.0:
				btick = 0.0
				var bdmg = enemy.get_meta("bleed_dmg")
				var bhp = enemy.get_meta("hp") - bdmg
				enemy.set_meta("hp", bhp)
				update_enemy_hp_bar(enemy)
				show_floating_text(str(bdmg), enemy.global_position + Vector2(0, -20), Color.RED)
				var brem = enemy.get_meta("bleed_rem", 5) - 1
				if brem <= 0:
					enemy.remove_meta("bleed_dmg")
					enemy.remove_meta("bleed_tick")
					enemy.remove_meta("bleed_rem")
				else:
					enemy.set_meta("bleed_rem", brem)
				if bhp <= 0:
					gain_exp(enemy.get_meta("exp"))
					drop_loot(enemy.get_meta("type"))
					_try_drop_hammer_ore(enemy)
					if is_tutorial_active and enemy.get_meta("type") == "goblin":
						tutorial_stats["goblins_killed"] += 1
						check_objective_progress()
					if enemy.get_meta("type") == "boss_spider":
						spawn_final_lift()
						give_boss_loot()
						if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
					enemies.remove_at(i)
					enemy.queue_free()
					continue
			enemy.set_meta("bleed_tick", btick)
		# ---------------------------------------
		
		# --- TERRIFIED (Freeze 1.5 detik) ---
		if enemy.has_meta("terrified_timer"):
			var terr = enemy.get_meta("terrified_timer") - delta
			if terr <= 0:
				enemy.remove_meta("terrified_timer")
			else:
				enemy.set_meta("terrified_timer", terr)
				enemy.velocity.x = 0
				enemy.velocity.y = 0 # <--- TAMBAHKAN INI BIAR GAK MELAYANG
				enemy.move_and_slide()
				continue
		# ------------------------------------
		
		# --- LANJUTKAN KE LOGIKA AI MUSUH BAWAAN KAMU ---
		# (Mulai dari enemy.velocity.y += 980.0 * delta, dst...)
		
		if freeze_timer > 0: 
			enemy.velocity.x = 0; enemy.velocity.y = 0; enemy.move_and_slide()
			continue
			
		enemy.velocity.y += 980.0 * delta
		var dist = enemy.global_position.distance_to(player_pos)
		# --- OPTIMASI: CULLING MUSUH JAUH (HEMAT 90% CPU) ---
		if dist > 800.0: # Musuh di luar 50 blok
			# Hanya update gravitasi (biar gak melayang), skip AI & logika berat
			if not enemy.is_on_floor():
				enemy.velocity.y += 980.0 * delta
				enemy.move_and_slide()
			continue
		# ----------------------------------------------------
		var type = enemy.get_meta("type")
		var size_w = enemy.get_meta("size", 16.0)
		var size_h = enemy.get_meta("size_h", size_w)
		
		var e_rect = Rect2(enemy.global_position.x - size_w/2, enemy.global_position.y - size_h/2, size_w, size_h)
		e_rect = e_rect.grow(8.0) 
		
		var tabrakan = p_rect.intersects(e_rect)
		var dir = sign(player_pos.x - enemy.global_position.x)
		
		var is_blocked = false
		if enemy.is_on_floor() and enemy.is_on_wall():
			is_blocked = true
			
		var is_on_screen = get_viewport().get_visible_rect().has_point(enemy.get_global_transform_with_canvas().origin)
		var is_in_range = dist < 450.0
		
		if type == "goblin":
			var state = enemy.get_meta("state", "chase")
			var flee_timer = enemy.get_meta("flee_timer", 0.0)
			
			if state == "flee":
				enemy.velocity.x = -dir * 120.0
				flee_timer -= delta
				enemy.set_meta("flee_timer", flee_timer)
				if flee_timer <= 0: enemy.set_meta("state", "chase")
			else:
				# Goblin akan selalu mengejar ke arah player
				enemy.velocity.x = dir * 100.0
				
				if is_blocked: 
					enemy.velocity.y = -320.0 
					
				if tabrakan:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
					enemy.set_meta("state", "flee")
					enemy.set_meta("flee_timer", 3.0)

		elif type == "cannibal":
			if is_in_range:
				if not tabrakan:
					# Hanya jalan & lompat kalau BELUM sampai di depan player
					enemy.velocity.x = dir * 60.0
					if is_blocked: enemy.velocity.y = -380.0
				else:
					# Kalau sudah nempel player, DIAM di depan player, jangan lompat
					enemy.velocity.x = 0
					
				if tabrakan:
					take_damage(enemy.get_meta("damage"))
					_track_revenger_attacker(enemy)
			else:
				enemy.velocity.x = 0
		elif type == "hunter":
			var atk_timer = enemy.get_meta("atk_timer", 2.0)
			var state = enemy.get_meta("state", "attack")
			var stuck_timer = enemy.get_meta("stuck_timer", 0.0)
			atk_timer -= delta
			
			if state == "flee":
				enemy.velocity.x = -dir * 140.0 # Kabur menjauh
				
				# 4. Kepepet tembok & gabisa kabur -> Menyerang
				if is_blocked:
					stuck_timer += delta
					if stuck_timer >= 0.5: # Setengah detik mentok, baru berbalik
						state = "attack"
				else:
					stuck_timer = 0.0
				
				# 3. Player berhenti ngejar (jarak > 150) -> Balik menyerang
				if dist > 150.0:
					state = "attack"
					
			elif state == "enraged":
				# 5. Mode Marah (Dipukul Melee) -> Diam, tembak sampai mati
				enemy.velocity.x = 0
				if atk_timer <= 0 and is_on_screen:
					atk_timer = 2.0 # Tembak lebih cepat karena marah
					spawn_arrow(enemy.global_position, player_pos, 12, "enemy")
					
			else: # state == "attack"
				# 1. Player jauh -> Tetap nembak sambil diam
				enemy.velocity.x = 0 
				if atk_timer <= 0 and is_on_screen:
					atk_timer = 2.0
					spawn_arrow(enemy.global_position, player_pos, 12, "enemy")
					
				# 2. Player mendekat -> Masuk mode kabur
				if dist < 128.0:
					state = "flee"
					stuck_timer = 0.0
					
			enemy.set_meta("atk_timer", atk_timer)
			enemy.set_meta("state", state)
			enemy.set_meta("stuck_timer", stuck_timer)
		elif type == "cult":
			var atk_timer = enemy.get_meta("atk_timer", 3.0)
			atk_timer -= delta
			if is_in_range:
				enemy.velocity.x = dir * 50.0
				if is_blocked: enemy.velocity.y = -380.0
				if tabrakan and atk_timer <= 0:
					take_damage(30)
					_track_revenger_attacker(enemy)
					enemy.set_meta("atk_timer", 3.0) 
					enemy.global_position.x -= dir * 20.0 
			else:
				enemy.velocity.x = 0
			if atk_timer <= 0:
				for ally in enemies:
					if ally != enemy and is_instance_valid(ally) and ally.global_position.distance_to(enemy.global_position) < 200:
						ally.set_meta("buffed_timer", 5.0)
						show_floating_text("BUFFED!", ally.global_position, Color.ORANGE)
						break
				enemy.set_meta("atk_timer", 5.0)
			enemy.set_meta("atk_timer", atk_timer)
		# --- MULAI TAMBAHKAN AI MUSUH T3 DI SINI ---
		elif type == "spider":
			var web_timer = enemy.get_meta("web_timer", 2.0) - delta
			var melee_timer = enemy.get_meta("melee_timer", 0.0) - delta
			var knockback_timer = enemy.get_meta("knockback_timer", 0.0) - delta
			var post_melee_cd = enemy.get_meta("post_melee_cd", 0.0) - delta
			var jump_cd = enemy.get_meta("jump_cd", 0.0) - delta
			
			enemy.set_meta("web_timer", web_timer)
			enemy.set_meta("melee_timer", melee_timer)
			enemy.set_meta("knockback_timer", knockback_timer)
			enemy.set_meta("post_melee_cd", post_melee_cd)
			enemy.set_meta("jump_cd", jump_cd)
			
			if knockback_timer > 0:
				enemy.velocity.x = lerp(enemy.velocity.x, 0.0, 0.05)
			else:
				enemy.velocity.x = dir * 120.0 
				
				# --- WALL CLIMBING BENERAN (CEK TIAP FRAME) ---
				# Cek tile di depan spider (body & head level)
				var front_body_pos = enemy.global_position + Vector2(dir * 30, 0)
				var front_head_pos = enemy.global_position + Vector2(dir * 30, -16)
				var front_body = world.local_to_map(world.to_local(front_body_pos))
				var front_head = world.local_to_map(world.to_local(front_head_pos))
				var wall_in_front = world.get_cell_source_id(front_body) != -1 or world.get_cell_source_id(front_head) != -1
				
				if wall_in_front:
					# Ada dinding di depan — PANJAT TERUS (bukan lompat sekali)
					enemy.velocity.y = -220.0
				elif enemy.is_on_floor() and jump_cd <= 0:
					# Cek lubang 1 blok di depan (jump over pit)
					var front_ground_pos = enemy.global_position + Vector2(dir * 20, 20)
					var front_ground = world.local_to_map(world.to_local(front_ground_pos))
					if world.get_cell_source_id(front_ground) == -1:
						enemy.velocity.y = -350.0
						enemy.set_meta("jump_cd", 0.6)
				# ------------------------------------------------
				
				# SYARAT SHOOT WEB
				if dist > 128.0 and dist < 240.0 and post_melee_cd <= 0.0 and player_stun_timer <= 0.1 and is_on_screen and web_timer <= 0:
					enemy.set_meta("web_timer", 3.5)
					spawn_enemy_projectile(enemy.global_position, player_pos, "web")
					show_floating_text("SPIT!", enemy.global_position + Vector2(0, -30), Color.WHITE)
					
				if tabrakan:
					if melee_timer <= 0:
						take_damage(enemy.get_meta("damage"))
						_track_revenger_attacker(enemy)
						enemy.set_meta("melee_timer", 1.5) 
						enemy.set_meta("post_melee_cd", 2.0)
					$Player.velocity.x = dir * 100.0
		
		elif type == "mini_spideroid":
			var web_timer = enemy.get_meta("web_timer", 2.0) - delta
			var melee_timer = enemy.get_meta("melee_timer", 0.0) - delta
			var knockback_timer = enemy.get_meta("knockback_timer", 0.0) - delta
			var post_melee_cd = enemy.get_meta("post_melee_cd", 0.0) - delta
			
			enemy.set_meta("web_timer", web_timer)
			enemy.set_meta("melee_timer", melee_timer)
			enemy.set_meta("knockback_timer", knockback_timer)
			enemy.set_meta("post_melee_cd", post_melee_cd)
			
			if knockback_timer > 0:
				enemy.velocity.x = lerp(enemy.velocity.x, 0.0, 0.05)
			else:
				enemy.velocity.x = dir * 120.0 
				
				if dist > 128.0 and dist < 240.0 and post_melee_cd <= 0.0 and player_stun_timer <= 0.1 and is_on_screen and web_timer <= 0:
					enemy.set_meta("web_timer", 3.5)
					spawn_enemy_projectile(enemy.global_position, player_pos, "web")
					
				if tabrakan:
					if melee_timer <= 0:
						take_damage(enemy.get_meta("damage"))
						_track_revenger_attacker(enemy)
						enemy.set_meta("melee_timer", 1.5) 
						enemy.set_meta("post_melee_cd", 2.0) # <--- KUNCI
					$Player.velocity.x = dir * 100.0
					
		elif type == "cave_slime":
			var atk_timer = enemy.get_meta("atk_timer", 2.0)
			atk_timer -= delta
			
			# Regen Armor (40 detik)
			if enemy.get_meta("armor_hp", 0) <= 0:
				var regen_t = enemy.get_meta("armor_regen_timer", 0.0) + delta
				if regen_t >= 40.0:
					enemy.set_meta("armor_hp", 200)
					enemy.set_meta("armor_regen_timer", 0.0)
					show_floating_text("ARMOR RESTORED!", enemy.global_position + Vector2(0, -40), Color.YELLOW)
				else:
					enemy.set_meta("armor_regen_timer", regen_t)
					
			if is_on_screen and atk_timer <= 0:
				if dist > 192.0: # Kalau jauh > 12 blok, lempar batu
					atk_timer = 2.5
					spawn_enemy_projectile(enemy.global_position, player_pos, "rock")
				else: # Kalau deket, nyerang melee
					if tabrakan:
						take_damage(enemy.get_meta("damage"))
						_track_revenger_attacker(enemy)
						atk_timer = 1.5
			enemy.set_meta("atk_timer", atk_timer)
			
		elif type == "crystal_golem":
			var atk_timer = enemy.get_meta("atk_timer", 2.0)
			atk_timer -= delta
			enemy.velocity.x = dir * 40.0 # Jalan sangat lambat
			
			if tabrakan and atk_timer <= 0:
				take_damage(enemy.get_meta("damage"))
				_track_revenger_attacker(enemy)
				# Knockback player
				$Player.velocity.x = dir * 300.0
				$Player.velocity.y = -200.0
				show_floating_text("SMASH!", enemy.global_position + Vector2(0, -40), Color.RED)
				atk_timer = 2.0
			enemy.set_meta("atk_timer", atk_timer)
		# --- SELESAI ---
		
		elif type == "boss_spider":
			var state = enemy.get_meta("state", "phase1")
			var atk_timer = enemy.get_meta("atk_timer", 2.0) - delta
			enemy.set_meta("atk_timer", atk_timer)
			
			var current_hp = enemy.get_meta("hp")
			
			# --- CEK TRANSISI KE KEPOMPONG ---
			if current_hp <= enemy.get_meta("max_hp") * 0.5 and state == "phase1":
				state = "cocoon"
				enemy.set_meta("is_invulnerable", true)
				enemy.velocity = Vector2.ZERO
				show_floating_text("COCOON!", enemy.global_position + Vector2(0, -60), Color.PURPLE)
				
				# Reset variabel untuk spawn bergiliran
				enemy.set_meta("minions_spawned", 0)
				enemy.set_meta("minion_spawn_timer", 0.5) # Spawn pertama setelah 0.5 detik
				enemy.set_meta("cocoon_timer", 0.0)
				enemy.set_meta("state", state)
				
						# --- LOGIKA KEPOMPONG ---
			if state == "cocoon":
				enemy.velocity.x = 0
				
				var spawned = enemy.get_meta("minions_spawned", 0)
				var spawn_t = enemy.get_meta("minion_spawn_timer", 0.0) - delta
				enemy.set_meta("minion_spawn_timer", spawn_t)
				
				if spawned < 5 and spawn_t <= 0:
					var boss_tile = world.local_to_map(world.to_local(enemy.global_position))
					
					# 1. Tentukan posisi X (kiri / kanan Boss)
					var spawn_x = 0
					if spawned % 2 == 0:
						spawn_x = boss_tile.x - 20 # Coba ke kiri
						if spawn_x < 105: # Kalau mentok dinding kiri
							spawn_x = boss_tile.x + 20 # Paksa ke kanan
					else:
						spawn_x = boss_tile.x + 20 # Coba ke kanan
						if spawn_x > 195: # Kalau mentok dinding kanan
							spawn_x = boss_tile.x - 20 # Paksa ke kiri
							
					# 2. Kunci X di dalam kubah (X=100 sampai X=200)
					spawn_x = clamp(spawn_x, 100, 200)
					
					# 3. Spawn di lantai (Y=1195, tepat di atas bedrock)
					var spawn_y = 1195
					
					create_enemy("mini_spideroid", Vector2i(spawn_x, spawn_y))
					
					enemy.set_meta("minions_spawned", spawned + 1)
					enemy.set_meta("minion_spawn_timer", 1.0)
					
				var alive_minions = 0
				
				
				for e in enemies:
					if is_instance_valid(e) and e.get_meta("type") == "mini_spideroid":
						alive_minions += 1
				
				if spawned >= 5 and alive_minions == 0:
					enemy.set_meta("is_invulnerable", false)
					enemy.set_meta("state", "enraged")
					enemy.set_meta("dash_cd", 8.0) 
					enemy.set_meta("web_timer", 2.0)
					enemy.set_meta("post_dash_cd", 0.0) 
					enemy.set_meta("web_hit_player", false) 
					show_floating_text("ENRAGED!", enemy.global_position + Vector2(0, -60), Color.RED)
				
			# --- PHASE 1: PENAKUT ---
			elif state == "phase1":
				enemy.velocity.x = -dir * 80.0 
				
				# Syarat Player Benar-Benar di Atas (Minimal 3 blok lebih tinggi)
				var player_above = player_pos.y < enemy.global_position.y - 48.0
				
				if dist > 128.0 and player_stun_timer <= 0.1 and atk_timer <= 0 and is_on_screen:
					atk_timer = 3.0
					spawn_enemy_projectile(enemy.global_position, player_pos, "web")
					
				# Kalau player kena jaring, Boss maju DAN BISA MANJAT kalau player di atas
				if player_stun_timer > 0:
					enemy.velocity.x = dir * 300.0 
					
					if player_above and (is_blocked or enemy.is_on_wall()):
						enemy.velocity.y = -600.0 # Manjat
						
					if tabrakan:
						take_damage(30)
						atk_timer = 1.2
						
						# --- PHASE 2: MARAH ---
			elif state == "enraged":
				var dash_cd = enemy.get_meta("dash_cd", 8.0) - delta
				var web_timer = enemy.get_meta("web_timer", 2.0) - delta
				var is_dashing = enemy.get_meta("is_dashing", false)
				var web_hit = enemy.get_meta("web_hit_player", false)
				var dash_start_x = enemy.get_meta("dash_start_x", 0.0)
				var post_dash_cd = enemy.get_meta("post_dash_cd", 0.0) - delta
				
				# Syarat Player Benar-Benar di Atas (Minimal 3 blok lebih tinggi)
				var player_above = player_pos.y < enemy.global_position.y - 48.0
				
				enemy.set_meta("dash_cd", dash_cd)
				enemy.set_meta("web_timer", web_timer)
				enemy.set_meta("post_dash_cd", post_dash_cd)
				
				if (dash_cd <= 0 or web_hit) and not is_dashing:
					is_dashing = true
					enemy.set_meta("web_hit_player", false)
					enemy.set_meta("dash_start_x", enemy.global_position.x)
					dash_start_x = enemy.global_position.x
					
				if is_dashing:
					enemy.velocity.x = dir * 650.0 
					
					# Kalau Dash nabrak tembok DAN player di atas, Boss manjat!
					if player_above and (is_blocked or enemy.is_on_wall()):
						enemy.velocity.y = -600.0
					
					var dash_distance = abs(enemy.global_position.x - dash_start_x)
					var max_dash_distance = 15 * 16.0
					
					var hit_player = tabrakan or dist < 120.0
					var exceeded_distance = dash_distance >= max_dash_distance
					
					if hit_player or exceeded_distance:
						if hit_player:
							take_damage(30)
							show_floating_text("2x HIT!", $Player.global_position, Color.RED)
							take_damage(30)
						
						enemy.velocity.x = -dir * 400.0
						is_dashing = false
						enemy.set_meta("dash_cd", 8.0) 
						enemy.set_meta("web_timer", 2.0)
						enemy.set_meta("post_dash_cd", 3.0)
						
				else:
					enemy.velocity.x = -dir * 150.0
					
					if dist > 128.0 and post_dash_cd <= 0 and player_stun_timer <= 0.1 and is_on_screen and web_timer <= 0:
						enemy.set_meta("web_timer", 2.5)
						if randf() < 0.25:
							spawn_enemy_projectile(enemy.global_position, player_pos, "poison_web")
						else:
							spawn_enemy_projectile(enemy.global_position, player_pos, "web")
							
				enemy.set_meta("is_dashing", is_dashing)
				
			enemy.set_meta("atk_timer", atk_timer)
			
		elif type == "slime_small" or type == "slime_medium" or type == "slime_large":
			if enemy.is_on_floor():
				enemy.velocity.x = 0 
				var jump_timer = enemy.get_meta("jump_timer", 1.0)
				var is_attacking = enemy.get_meta("is_attacking", false)
				if jump_timer <= 0 and not is_attacking:
					if dist < 250.0: 
						enemy.velocity.x = dir * 80.0 
						enemy.velocity.y = -250.0      
						enemy.set_meta("jump_timer", 1.2) 
				elif not is_attacking:
					enemy.set_meta("jump_timer", jump_timer - delta)
			if tabrakan and not enemy.get_meta("is_attacking", false):
				enemy.set_meta("is_attacking", true)
				var tween = create_tween()
				tween.tween_property(enemy.get_child(0), "scale", Vector2(1.4, 1.4), 0.1)
				tween.tween_callback(func(): 
					if is_instance_valid(enemy): take_damage(enemy.get_meta("damage"))
				) 
				tween.tween_property(enemy.get_child(0), "scale", Vector2(1.0, 1.0), 0.2)
				tween.tween_callback(func(): 
					if is_instance_valid(enemy): enemy.set_meta("is_attacking", false)
				)
				
		var buffed_timer = enemy.get_meta("buffed_timer", 0.0)
		if buffed_timer > 0:
			enemy.velocity.x *= 1.3
			enemy.set_meta("buffed_timer", buffed_timer - delta)
		enemy.move_and_slide()
		

func spawn_enemies():
	# --- SLIME PERMUKAAN (Y: 0 - 15) ---
	var spawned_slime = 0
	var attempts = 0
	while spawned_slime < 7 and attempts < 500:
		attempts += 1
		var rx = randi_range(10, WORLD_WIDTH - 10)
		if abs(rx - 150) < 10: continue
		var ry = 0
		while ry < WORLD_DEPTH and world.get_cell_source_id(Vector2i(rx, ry)) == -1:
			ry += 1
		if ry < WORLD_DEPTH:
			var rng = randf()
			var type = "slime_small"
			if rng < 0.05: type = "slime_large"
			elif rng < 0.30: type = "slime_medium"
			create_enemy(type, Vector2i(rx, ry - 2))
			spawned_slime += 1

	# --- FUNGSI BANTUAN UNTUK SPAWN BERDASARKAN PERSENTASE ---
	var spawn_layer_batch = func(min_y: int, max_y: int, count: int, probs: Dictionary):
		var spawned = 0
		var att = 0
		while spawned < count and att < 50000:
			att += 1
			var rx = randi_range(10, WORLD_WIDTH - 10)
			var ry = randi_range(min_y, max_y)
			if is_area_clear(rx, ry, 2, 5):
				var roll = randf() * 100.0
				var cumulative = 0.0
				var chosen_type = "goblin" # Default fallback
				
				for type_name in probs.keys():
					cumulative += probs[type_name]
					if roll <= cumulative:
						chosen_type = type_name
						break
						
				create_enemy(chosen_type, Vector2i(rx, ry))
				spawned += 1

	# --- T1 & T2 SPAWNS (Hanya jalan kalau BUKAN T3) ---
	if Global.tutorial_step < 8:
		# Layer 1 (Y: 15-99) -> 12 Musuh
		spawn_layer_batch.call(15, 99, 12, {"goblin": 88, "cannibal": 12})
		# Layer 2 (Y: 100-199) -> 15 Musuh
		spawn_layer_batch.call(100, 199, 15, {"goblin": 75, "cannibal": 20, "hunter": 5})
		# Layer 3 (Y: 200-299) -> 18 Musuh
		spawn_layer_batch.call(200, 299, 18, {"goblin": 70, "cannibal": 25, "hunter": 10, "cult": 5})
		
	# --- T3 SPAWNS (Hanya jalan kalau T3) ---
	else:
		# --- TAMBAHKAN INI: Layer 1-3 tetap ada isinya ---
		spawn_layer_batch.call(15, 99, 12, {"goblin": 88, "cannibal": 12})
		spawn_layer_batch.call(100, 199, 15, {"goblin": 75, "cannibal": 20, "hunter": 5})
		spawn_layer_batch.call(200, 299, 18, {"goblin": 70, "cannibal": 25, "hunter": 10, "cult": 5})
		# ---------------------------------------------------
		# Layer 4 (Y: 300-399) -> 20 Musuh
		spawn_layer_batch.call(300, 399, 20, {"goblin": 45, "cannibal": 30, "hunter": 15, "cult": 10})
		# Layer 5 (Y: 400-499) -> 20 Musuh
		spawn_layer_batch.call(400, 499, 20, {"goblin": 30, "cannibal": 35, "hunter": 20, "cult": 10, "spider": 5})
		# Layer 6 (Y: 500-599) -> 23 Musuh
		spawn_layer_batch.call(500, 599, 23, {"goblin": 10, "cannibal": 40, "hunter": 25, "cult": 10, "spider": 15})
		# Layer 7 (Y: 600-699) -> 23 Musuh
		spawn_layer_batch.call(600, 699, 23, {"cannibal": 25, "hunter": 35, "cult": 15, "spider": 25})
		# Layer 8 (Y: 700-799) -> 25 Musuh
		spawn_layer_batch.call(700, 799, 25, {"cannibal": 5, "hunter": 20, "cult": 25, "spider": 40, "cave_slime": 10})
		# Layer 9 (Y: 800-899) -> 25 Musuh
		spawn_layer_batch.call(800, 899, 25, {"hunter": 10, "cult": 15, "spider": 40, "cave_slime": 30, "crystal_golem": 5})
		# Layer 10 (Y: 900-999) -> 27 Musuh
		spawn_layer_batch.call(900, 999, 27, {"cult": 5, "spider": 30, "cave_slime": 45, "crystal_golem": 20})
		# Layer 11 (Y: 1000-1099) -> 30 Musuh
		spawn_layer_batch.call(1000, 1099, 30, {"spider": 25, "cave_slime": 40, "crystal_golem": 35})
		
		# Layer 12 (Y: 1100-1199) -> BOSS ROOM (Kita buat nanti di Fase Boss)
		# Untuk sementara, kita kosongkan dulu (tidak spawn musuh biasa)

func create_enemy(type: String, tile_pos: Vector2i):
	var enemy = CharacterBody2D.new()
	enemy.add_to_group("enemies")
	
	var hp = 80
	var dmg = 10.0
	var color = Color(0.2, 0.8, 0.2)
	var size_w = 16.0
	var size_h = 16.0
	var exp_val = 3
	
	if type == "slime_small":
		hp = 80; dmg = 10; color = Color(0.2, 0.8, 0.2); size_w = 16.0; size_h = 16.0; exp_val = 3
	elif type == "slime_medium":
		hp = 150; dmg = 15; color = Color(0.3, 0.9, 0.3); size_w = 24.0; size_h = 24.0; exp_val = 5
	elif type == "slime_large":
		hp = 200; dmg = 20; color = Color(0.1, 0.5, 0.1); size_w = 32.0; size_h = 32.0; exp_val = 10
	elif type == "goblin":
		hp = 120; dmg = 12; color = Color(0.2, 0.6, 0.2); size_w = 24.0; size_h = 48.0; exp_val = 7
		enemy.set_meta("state", "chase")
		enemy.set_meta("flee_timer", 0.0)
	elif type == "cannibal":
		hp = 300; dmg = 6.5; color = Color(0.6, 0.1, 0.1); size_w = 32.0; size_h = 64.0; exp_val = 15
	elif type == "hunter":
		hp = 100; dmg = 10; color = Color(0.8, 0.4, 0.8); size_w = 24.0; size_h = 48.0; exp_val = 12
		enemy.set_meta("atk_timer", 2.0)
		enemy.set_meta("state", "attack") # Awalnya siap nembak dari jauh
	elif type == "cult":
		hp = 150; dmg = 30; color = Color(0.5, 0.1, 0.5); size_w = 24.0; size_h = 48.0; exp_val = 20
		enemy.set_meta("atk_timer", 3.0)
	elif type == "spider":
		hp = 240; dmg = 14; color = Color(0.487, 0.35, 0.122, 1.0); size_w = 48.0; size_h = 16.0; exp_val = 20
		enemy.set_meta("web_timer", 2.0)
		enemy.set_meta("melee_timer", 0.0)
		enemy.set_meta("knockback_timer", 0.0)
		
	elif type == "cave_slime":
		hp = 200; dmg = 20; color = Color(0.4, 0.2, 0.1); size_w = 32.0; size_h = 32.0; exp_val = 35
		enemy.set_meta("armor_hp", 200) # Tambahan Armor
		enemy.set_meta("armor_regen_timer", 0.0)
		enemy.set_meta("atk_timer", 2.0)
		
	elif type == "crystal_golem":
		hp = 700; dmg = 24; color = Color(0.6, 0.8, 1.0); size_w = 32.0; size_h = 80.0; exp_val = 60
		enemy.set_meta("atk_timer", 2.0)
	
	elif type == "mini_spideroid":
		hp = 240; dmg = 14; color = Color(0.6, 0.0, 0.6); size_w = 48.0; size_h = 16.0; exp_val = 20 # Warna ungu
		enemy.set_meta("web_timer", 2.0)
		enemy.set_meta("melee_timer", 0.0)
		enemy.set_meta("knockback_timer", 0.0)
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	enemy.set_meta("type", type)
	enemy.set_meta("size", size_w)
	enemy.set_meta("size_h", size_h)
	enemy.set_meta("hp", hp) 
	enemy.set_meta("max_hp", hp) 
	enemy.set_meta("damage", dmg)
	enemy.set_meta("exp", exp_val)
	enemy.set_meta("jump_timer", randf_range(0.5, 2.0))
	enemy.set_meta("base_color", color)
	enemy.set_meta("is_attacking", false)
	enemy.set_meta("buffed_timer", 0.0)
	
	var local_pos = world.map_to_local(tile_pos)
	local_pos.y += 8.0 - (size_h / 2.0) 
	enemy.position = world.to_global(local_pos)
	
	var poly = Polygon2D.new()
	var half_w = size_w / 2.0
	var half_h = size_h / 2.0
	poly.polygon = PackedVector2Array([Vector2(-half_w, -half_h), Vector2(half_w, -half_h), Vector2(half_w, half_h), Vector2(-half_w, half_h)])
	poly.color = color
	enemy.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	enemy.add_child(col)
	
	var hp_bar_bg = ColorRect.new()
	hp_bar_bg.size = Vector2(30, 4)
	hp_bar_bg.position = Vector2(-15, -half_h - 10)
	hp_bar_bg.color = Color.BLACK
	enemy.add_child(hp_bar_bg)
	
	var hp_bar = ColorRect.new()
	hp_bar.size = Vector2(30, 4)
	hp_bar.position = Vector2(-15, -half_h - 10)
	hp_bar.color = Color.GREEN
	enemy.add_child(hp_bar)
	enemy.set_meta("hp_bar", hp_bar)
	
	enemy.collision_mask = 1
	add_child(enemy)
	enemies.append(enemy)

func spawn_chests():
	# Di Tutorial 1 tidak ada chest sama sekali, fokus ke objective
	if Global.tutorial_step == 0:
		return
		
	var chest_l1 = randi_range(7, 13)
	for i in range(chest_l1):
		spawn_chest_in_area(15, 99)
		
	var chest_l2 = randi_range(7, 13)
	for i in range(chest_l2):
		spawn_chest_in_area(100, 199)
		
	var chest_l3 = randi_range(7, 13)
	for i in range(chest_l3):
		spawn_chest_in_area(200, 299)

func spawn_chest_in_area(min_y: int, max_y: int):
	var attempts = 0
	while attempts < 100:
		attempts += 1
		var rx = randi_range(10, WORLD_WIDTH - 10)
		var ry = randi_range(min_y, max_y)
		if is_area_clear(rx, ry, 2, 2):
			create_chest(Vector2i(rx, ry))
			break

func create_chest(tile_pos: Vector2i):
	var chest = Node2D.new()
	chest.position = world.to_global(world.map_to_local(tile_pos))
	chest.z_index = -1
	var box = ColorRect.new()
	box.size = Vector2(24, 24)
	box.position = Vector2(-12, -24)
	box.color = Color(0.6, 0.3, 0.1) 
	chest.add_child(box)
	add_child(chest)
	chests.append(chest)

func open_chest(chest: Node2D):
	# --- CEK ORE CHEST DULU ---
	if chest.get_meta("is_ore_chest", false):
		open_ore_chest(chest)
		return
	# --------------------------
	
	var roll = randf()
	var loot_name = ""
	var loot_amount = 1
	
	# Logika T3 (Scrap masuk pool chest)
	if Global.tutorial_step >= 8:
		if roll < 0.30: loot_name = "Scrap"; loot_amount = randi_range(1, 3)
		elif roll < 0.50: loot_name = "Food Box"
		elif roll < 0.70: loot_name = "Arrow"; loot_amount = randi_range(5, 15)
		elif roll < 0.90: loot_name = "Torch"; loot_amount = randi_range(5, 15)
		else: loot_name = "Bomb"; loot_amount = randi_range(1, 5)
	else:
		# Logika T1/T2 (Normal)
		if roll < 0.53: loot_name = "Food Box"
		elif roll < 0.73: loot_name = "Arrow"; loot_amount = randi_range(1, 10)
		elif roll < 0.93: loot_name = "Torch"; loot_amount = randi_range(1, 10)
		else: loot_name = "Bomb"; loot_amount = randi_range(1, 10)
		
	tambah_item(loot_name, loot_amount)
	show_floating_text(loot_name + " (" + str(loot_amount) + ")", chest.global_position, Color.GOLD)
	chests.erase(chest)
	chest.queue_free()

func open_ore_chest(chest: Node2D):
	var chest_pos = chest.global_position
	var chest_tile = world.local_to_map(world.to_local(chest_pos))
	var chest_y = chest_tile.y
	
	# Tentukan 5 ore dominan sesuai zone kedalaman
	var dominant_ores = []
	if chest_y < 600:
		# Zone 1 (Layer 4-6): Quartz, Topaz, Gold, Mithril, Coal
		dominant_ores = ["Quartz", "Topaz", "Gold", "Mithril", "Coal"]
	elif chest_y < 900:
		# Zone 2 (Layer 7-9): Emerald, Amethyst, Gold, Mithril, Quartz
		dominant_ores = ["Emerald", "Amethyst", "Gold", "Mithril", "Quartz"]
	else:
		# Zone 3 (Layer 10-12): Diamond, Void Crystal, Emerald, Gold, Mithril
		dominant_ores = ["Diamond", "Void Crystal", "Emerald", "Gold", "Mithril"]
	
	# Roll semua amounts DULU (2-7 per ore)
	var loot = []
	for ore in dominant_ores:
		loot.append({"name": ore, "amount": randi_range(2, 7)})
	
	# Tambahkan SEMUA ke inventory instan (anti-hilang kalau player mati)
	for item in loot:
		tambah_item(item["name"], item["amount"])
	
	# Hapus chest
	chests.erase(chest)
	chest.queue_free()
	
	# Floating text muncul satu per satu (ilusi "banyak item")
	for idx in range(loot.size()):
		var item = loot[idx]
		var txt = item["name"] + " x" + str(item["amount"])
		var offset = Vector2(randi_range(-20, 20), -40 - (idx * 5))
		show_floating_text(txt, chest_pos + offset, Color.CYAN)
		await get_tree().create_timer(0.4).timeout

func drop_through_bridges():
	if is_dropping_through_bridge: return
	is_dropping_through_bridge = true
	
	# Disable collision dengan semua bridge
	for body in bridge_bodies:
		if is_instance_valid(body):
			$Player.add_collision_exception_with(body)
	
	# Force downward velocity
	$Player.velocity.y = 300.0
	
	# Tunggu singkat (0.25 detik cukup)
	await get_tree().create_timer(0.25).timeout
	
	# Re-enable collision
	for body in bridge_bodies:
		if is_instance_valid(body):
			$Player.remove_collision_exception_with(body)
	
	is_dropping_through_bridge = false

func explode_lift(lift_node: Node2D):
	if not is_instance_valid(lift_node): return
	
	var explosion = ColorRect.new()
	explosion.size = Vector2(64, 64)
	explosion.position = lift_node.global_position - Vector2(32, 32)
	explosion.color = Color(1, 0.4, 0, 0.8) 
	explosion.z_index = 2
	add_child(explosion)
	
	var tween = create_tween()
	tween.tween_property(explosion, "scale", Vector2(2.5, 2.5), 0.4)
	tween.parallel().tween_property(explosion, "modulate:a", 0.0, 0.4)
	tween.tween_callback(explosion.queue_free)
	
	show_floating_text("BOOM!", lift_node.global_position + Vector2(0, -30), Color.RED)
	
	lift_nodes.erase(lift_node)
	lift_node.queue_free()
	
func spawn_lift():
	var lift_ys = []
	
	if Global.tutorial_step == 0:
		lift_ys = [90] # T1
	elif Global.tutorial_step >= 8:
		lift_ys = [590] # T3: Hanya Lift Jebakan di Layer 6
	else:
		lift_ys = [290] # T2

	for lift_y in lift_ys:
		var lift_node = Node2D.new()
		var lift_tile = Vector2i(155, lift_y)
		clear_area(lift_tile, 2)
		lift_node.position = world.to_global(world.map_to_local(lift_tile))
		lift_node.z_index = -1
		
		var visual = ColorRect.new()
		visual.size = Vector2(32, 48)
		visual.position = Vector2(-16, -24)
		visual.color = Color(0.8, 0.6, 0.4) 
		lift_node.add_child(visual)
		
		var text = Label.new()
		text.text = "LIFT"
		text.position = Vector2(-15, -10)
		text.add_theme_font_size_override("font_size", 12)
		text.add_theme_color_override("font_color", Color.WHITE)
		lift_node.add_child(text)
		
		add_child(lift_node)
		lift_nodes.append(lift_node)

# Fungsi khusus untuk memunculkan lift kemenangan di Layer 12 (dipanggil saat boss mati)
func spawn_final_lift():
	var lift_node = Node2D.new()
	var lift_tile = Vector2i(155, 1190)
	clear_area(lift_tile, 2)
	lift_node.position = world.to_global(world.map_to_local(lift_tile))
	lift_node.z_index = -1
	
	var visual = ColorRect.new()
	visual.size = Vector2(32, 48)
	visual.position = Vector2(-16, -24)
	visual.color = Color(0.8, 0.6, 0.4) 
	lift_node.add_child(visual)
	
	var text = Label.new()
	text.text = "LIFT"
	text.position = Vector2(-15, -10)
	text.add_theme_font_size_override("font_size", 12)
	text.add_theme_color_override("font_color", Color.WHITE)
	lift_node.add_child(text)
	
	add_child(lift_node)
	lift_nodes.append(lift_node)
	show_floating_text("A way out has appeared!", lift_node.global_position, Color.GOLD)

func clear_area(tile_pos: Vector2i, radius: int = 2):
	# Batas bawah map (Bedrock)
	var limit_y = 100 if Global.tutorial_step == 0 else WORLD_DEPTH - 1
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var check_pos = tile_pos + Vector2i(dx, dy)
			# Jangan hapus kalau udah nyentuh bedrock
			if check_pos.y >= limit_y: continue
			world.erase_cell(check_pos)

func bikin_ruang_checkpoint(center: Vector2i):
	# Batas bawah map (Bedrock)
	var limit_y = 100 if Global.tutorial_step == 0 else WORLD_DEPTH - 1
	
	# Ruangan 7x7 di tengah
	clear_area(center, 3)
	
	# Lorong vertikal (lebar 3, tinggi 31, clamp Y)
	for dy in range(-15, 16):
		var y = center.y + dy
		# Jangan sampai nembus bedrock (limit_y)
		if y < 0 or y >= limit_y: continue
		for dx in range(-1, 2):
			world.erase_cell(Vector2i(center.x + dx, y))
			
	# Lorong horizontal (lebar 31, tinggi 3, clamp X)
	for dx in range(-15, 16):
		var x = center.x + dx
		if x < 0 or x >= WORLD_WIDTH: continue
		for dy in range(-1, 2):
			var check_y = center.y + dy
			if check_y >= limit_y: continue # Cek bedrock juga di lorong horizontal
			world.erase_cell(Vector2i(x, check_y))

func spawn_checkpoints():
	var depths = []
	
	if Global.tutorial_step == 3:
		depths = [90, 190, 290]
	elif Global.tutorial_step >= 8:
		# T3 Checkpoints: Layer 1-11 + Layer 12 (Boss Room)
		depths = [90, 190, 290, 390, 490, 590, 690, 790, 890, 990, 1090, 1190]
		
	for depth in depths:
		var cp = Node2D.new()
		var cp_tile = Vector2i(150, depth)
		bikin_ruang_checkpoint(cp_tile)
		cp.position = world.to_global(world.map_to_local(cp_tile))
		cp.z_index = -1
		
		var visual = ColorRect.new()
		visual.size = Vector2(8, 80) 
		visual.position = Vector2(-4, -80) 
		visual.color = Color(0.8, 0.2, 0.2) 
		cp.add_child(visual)
		
		var text = Label.new()
		text.text = "CHECKPOINT " + str(depth) + "m"
		text.position = Vector2(-45, -100)
		text.add_theme_font_size_override("font_size", 12)
		text.add_theme_color_override("font_color", Color.WHITE)
		cp.add_child(text)
		
		var cp_light = PointLight2D.new()
		cp_light.name = "CheckpointLight"
		cp_light.texture = bikin_tekstur_cahaya()
		cp_light.color = Color.RED 
		cp_light.energy = 1.5
		cp_light.texture_scale = 4.0 
		cp_light.shadow_enabled = false
		cp_light.shadow_filter = Light2D.SHADOW_FILTER_PCF13
		cp_light.shadow_filter_smooth = 3.0
		cp.add_child(cp_light)
		
		add_child(cp)
		checkpoint_nodes.append(cp)

# --- SISA FUNGSI UI, DLL (SAMA SEPERTI SEBELUMNYA) ---
func bikin_ui_hotbar():
	var canvas = CanvasLayer.new()
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
		lbl.name = "Label"
		lbl.add_theme_font_size_override("font_size", 12)
		slot.add_child(lbl)
		var num_lbl = Label.new()
		num_lbl.text = str(i + 1)
		num_lbl.position = Vector2(2, -2)
		num_lbl.add_theme_font_size_override("font_size", 10)
		slot.add_child(num_lbl)
		hb_container.add_child(slot)
		hotbar_ui_labels.append(lbl)
	update_hotbar_ui()

func update_hotbar_ui():
	for i in range(7):
		var item = hotbar_items[i]
		var lbl = hotbar_ui_labels[i]
		if item != null:
			var w_type = item_data.get(item, {}).get("weapon_type", "")
			if w_type != "":
				var lv = Global.get_item_level(item, Global.hotbar_uuids[i])
				lbl.text = item + "\nLv. " + str(lv)
			else:
				var amount = inventory.get(item, 0)
				lbl.text = item + "\n(" + str(amount) + ")"
			lbl.add_theme_color_override("font_color", item_data.get(item, {"color": Color.WHITE})["color"])
		else:
			lbl.text = ""
		var slot_panel = lbl.get_parent()
		if i == selected_hotbar_index:
			slot_panel.get_theme_stylebox("panel").border_color = Color.YELLOW
		else:
			slot_panel.get_theme_stylebox("panel").border_color = Color(0.5, 0.5, 0.5)

func bikin_ui_inventory():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	ui_inventory_panel = Panel.new()
	ui_inventory_panel.size = Vector2(560, 420) 
	ui_inventory_panel.position = Vector2(280, 120)
	ui_inventory_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5)
	ui_inventory_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(ui_inventory_panel)
	
	var title = Label.new()
	title.text = "BACKPACK"
	title.position = Vector2(20, 10)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.WHITE)
	ui_inventory_panel.add_child(title)
	
	var hb_row = HBoxContainer.new()
	hb_row.position = Vector2(15, 50)
	hb_row.add_theme_constant_override("separation", 5)
	ui_inventory_panel.add_child(hb_row)
	
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
		
	var grid = GridContainer.new()
	grid.columns = 10
	grid.position = Vector2(15, 120) 
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
		slot_nodes.append(slot)

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
	var items_in_backpack = get_backpack_items()

	for i in range(slot_nodes.size()):
		slot_nodes[i].tooltip_text = ""
		slot_nodes[i].get_node("Icon").visible = false
		slot_nodes[i].get_node("AmountLabel").text = ""
		
	for i in range(min(items_in_backpack.size(), 50)):
		var item_key = items_in_backpack[i]
		var item_name = Global.get_base_name(item_key)
		var amount = Global.saved_inventory[item_key]
		
		if item_name == "Food Box":
			slot_nodes[i].tooltip_text = "Food Box\n(Right Click to open)"
		elif item_name in ["Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"]:
			var desc = item_data.get(item_name, {}).get("desc", "")
			slot_nodes[i].tooltip_text = item_name + "\n" + desc + "\n(E to consume)"
		else:
			slot_nodes[i].tooltip_text = item_name
			
		var icon = slot_nodes[i].get_node("Icon")
		icon.color = item_data.get(item_name, {"color": Color.WHITE})["color"]
		icon.visible = true
		
		if Global.is_unique_key(item_key):
			slot_nodes[i].get_node("AmountLabel").text = ""
		else:
			slot_nodes[i].get_node("AmountLabel").text = str(int(amount))
		
	for i in range(7):
		var item = hotbar_items[i]
		var slot_panel = inv_hotbar_slots[i]
		var lbl = slot_panel.get_node("Label")
		
		if item != null:
			var _is_w = item_data.get(item, {}).has("weapon_type") or item in ["Fist", "Stone Pickaxe", "Bow"]
			if _is_w:
				var _lv = Global.get_item_level(item, Global.hotbar_uuids[i])
				lbl.text = item + "\nLv. " + str(_lv)
			else:
				lbl.text = item + "\n(" + str(inventory.get(item, 0)) + ")"
			lbl.add_theme_color_override("font_color", item_data.get(item, {"color": Color.WHITE})["color"])
		else:
			lbl.text = ""

func bikin_ui_character():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	char_panel = Panel.new()
	char_panel.size = Vector2(500, 460)
	char_panel.position = Vector2(400, 150) # Posisi disesuaikan dengan main.gd
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
		
	char_slot_labels.append(armor_lbl)
	char_slots_panels.append(armor_slot)

	# --- 4. PANEL MELAYANG (HOVER) ---
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

	# --- EMBLEM SLOTS ---
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
		item = hotbar_items[index]
		
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

func update_char_ui():
	for i in range(3):
		if hotbar_items[i] != null:
			var lv = Global.get_item_level(hotbar_items[i])
			char_slot_labels[i].text = hotbar_items[i] + "\nLv. " + str(lv)
		else:
			char_slot_labels[i].text = "Empty"
			
	if Global.equipped_armor != null:
		var lv = Global.get_item_level(Global.equipped_armor)
		char_slot_labels[3].text = Global.equipped_armor + "\nLv. " + str(lv)
	else:
		char_slot_labels[3].text = "Empty"

func bikin_ui_crafting():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	ui_crafting_panel = Panel.new()
	ui_crafting_panel.size = Vector2(300, 260)
	ui_crafting_panel.position = Vector2(430, 200) 
	ui_crafting_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5)
	ui_crafting_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(ui_crafting_panel)
	
	var title = Label.new()
	title.text = "CRAFTING (C)"
	title.position = Vector2(20, 10)
	title.add_theme_font_size_override("font_size", 24)
	ui_crafting_panel.add_child(title)
	
	# 1. Torch
	btn_torch = Button.new()
	btn_torch.text = "Torch (1 Coal + 1 Stick) -> 8x"
	btn_torch.position = Vector2(20, 60)
	btn_torch.size = Vector2(260, 40)
	btn_torch.pressed.connect(func(): craft_item("torch"))
	ui_crafting_panel.add_child(btn_torch)
	Sfx.attach(btn_torch, "hover", "") # <--- Kunci: Hover aja, klik jangan
	
	# 2. Arrow
	btn_arrow = Button.new()
	btn_arrow.text = "Arrow (1 Flint + 1 Stick) -> 8x"
	btn_arrow.position = Vector2(20, 110)
	btn_arrow.size = Vector2(260, 40)
	btn_arrow.pressed.connect(func(): craft_item("arrow"))
	ui_crafting_panel.add_child(btn_arrow)
	Sfx.attach(btn_arrow, "hover", "") # <--- Kunci: Hover aja, klik jangan
	
	# 3. Minigun Ammo
	btn_minigun_ammo = Button.new()
	btn_minigun_ammo.text = "Minigun Ammo (2 Copper + 2 Flint) -> 80x"
	btn_minigun_ammo.position = Vector2(20, 160)
	btn_minigun_ammo.size = Vector2(260, 40)
	btn_minigun_ammo.pressed.connect(func(): craft_item("minigun_ammo"))
	ui_crafting_panel.add_child(btn_minigun_ammo)
	Sfx.attach(btn_minigun_ammo, "hover", "") # <--- Kunci: Hover aja, klik jangan

func update_crafting_ui():
	if not is_instance_valid(btn_arrow) or not is_instance_valid(btn_minigun_ammo): return
	
	var _held = hotbar_items[selected_hotbar_index]
	var _show_arrow = false
	var _show_minigun = false
	
	# 1. Cek senjata yang SEDANG DIPEGANG
	if _held == "Crystal Minigun":
		_show_minigun = true
	elif item_data.has(_held) and item_data[_held].has("charge_damage"):
		_show_arrow = true
	else:
		# 2. Kalau lagi pegang pedang/sekop, cek apakah di hotbar ada bow/minigun
		for i in range(7):
			var _it = hotbar_items[i]
			if _it == "Crystal Minigun": _show_minigun = true
			elif item_data.has(_it) and item_data[_it].has("charge_damage"): _show_arrow = true
			
	btn_arrow.visible = _show_arrow
	btn_minigun_ammo.visible = _show_minigun
	
	# 3. Rapikan posisi kalau cuma 1 yang muncul
	if _show_arrow and _show_minigun:
		btn_arrow.position = Vector2(20, 110)
		btn_minigun_ammo.position = Vector2(20, 160)
	elif _show_minigun:
		btn_minigun_ammo.position = Vector2(20, 110)

func _on_ammo_button_pressed():
	var _held = hotbar_items[selected_hotbar_index]
	if _held == "Crystal Minigun":
		craft_item("minigun_ammo")
	else:
		craft_item("arrow")

func craft_item(recipe):
	if recipe == "torch":
		if inventory.get("Coal", 0) >= 1 and inventory.get("Stick", 0) >= 1:
			inventory["Coal"] -= 1; inventory["Stick"] -= 1
			if inventory["Coal"] <= 0: inventory.erase("Coal")
			if inventory["Stick"] <= 0: inventory.erase("Stick")
			inventory["Torch"] = inventory.get("Torch", 0) + 8
			show_floating_text("+8 Torch", $Player.global_position)
			if not hotbar_items.has("Torch"):
				for i in range(3, 7):
					if hotbar_items[i] == null: hotbar_items[i] = "Torch"; break
			update_inventory_ui()
			update_hotbar_ui()
			Sfx.play("click") # <--- SUARA SUKSES CRAFT TORCH
			if is_tutorial_active:
				tutorial_stats["torches"] += 1
				check_objective_progress()
		else:
			Sfx.play("error") # <--- SUARA GAGAL CRAFT TORCH
			show_floating_text("Bahan kurang!", $Player.global_position)
			
	elif recipe == "minigun_ammo":
		if inventory.get("Copper", 0) >= 2 and inventory.get("Flint", 0) >= 2:
			inventory["Copper"] -= 2
			inventory["Flint"] -= 2
			if inventory["Copper"] <= 0: inventory.erase("Copper")
			if inventory["Flint"] <= 0: inventory.erase("Flint")
			inventory["Minigun Ammo"] = inventory.get("Minigun Ammo", 0) + 80
			show_floating_text("+80 Minigun Ammo", $Player.global_position, Color.PINK)
			if not hotbar_items.has("Minigun Ammo"):
				for i in range(3, 7):
					if hotbar_items[i] == null:
						hotbar_items[i] = "Minigun Ammo"
						break
			update_inventory_ui()
			update_hotbar_ui()
			Sfx.play("click") # <--- SUARA SUKSES CRAFT AMMO
		else:
			Sfx.play("error") # <--- SUARA GAGAL CRAFT AMMO
			show_floating_text("Bahan kurang!", $Player.global_position)
			
	elif recipe == "arrow":
		if inventory.get("Flint", 0) >= 1 and inventory.get("Stick", 0) >= 1:
			inventory["Flint"] -= 1; inventory["Stick"] -= 1
			if inventory["Flint"] <= 0: inventory.erase("Flint")
			if inventory["Stick"] <= 0: inventory.erase("Stick")
			inventory["Arrow"] = inventory.get("Arrow", 0) + 8
			show_floating_text("+8 Arrow", $Player.global_position)
			if not hotbar_items.has("Arrow"):
				for i in range(3, 7):
					if hotbar_items[i] == null: hotbar_items[i] = "Arrow"; break
			update_inventory_ui()
			update_hotbar_ui()
			Sfx.play("click") # <--- SUARA SUKSES CRAFT ARROW
			if is_tutorial_active:
				tutorial_stats["arrows"] += 1
				check_objective_progress()
		else:
			Sfx.play("error") # <--- SUARA GAGAL CRAFT ARROW
			show_floating_text("Bahan kurang!", $Player.global_position)

func bikin_ui_hp_dan_nyawa():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	var main_container = HBoxContainer.new()
	main_container.position = Vector2(650, 20)
	main_container.add_theme_constant_override("separation", 15)
	canvas.add_child(main_container)
	ui_exp_label = Label.new()
	ui_exp_label.add_theme_font_size_override("font_size", 20)
	ui_exp_label.add_theme_color_override("font_color", Color.CYAN)
	ui_exp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_exp_label.add_theme_constant_override("outline_size", 4)
	main_container.add_child(ui_exp_label)
	update_exp_ui()
	ui_lives_label = Label.new()
	ui_lives_label.add_theme_font_size_override("font_size", 24)
	ui_lives_label.add_theme_color_override("font_color", Color.WHITE)
	ui_lives_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_lives_label.add_theme_constant_override("outline_size", 4)
	ui_lives_label.text = "✚ " + str(lives)
	main_container.add_child(ui_lives_label)
	var hp_container = HBoxContainer.new()
	hp_container.add_theme_constant_override("separation", 2)
	main_container.add_child(hp_container)
	for i in range(10):
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 24)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.add_theme_constant_override("outline_size", 4)
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.tooltip_text = "HP: " + str(current_hp) + " / " + str(max_hp)
		hp_container.add_child(lbl)
		heart_labels.append(lbl)
	ui_death_label = Label.new()
	ui_death_label.add_theme_font_size_override("font_size", 48)
	ui_death_label.add_theme_color_override("font_color", Color.RED)
	ui_death_label.add_theme_color_override("font_outline_color", Color.BLACK)
	ui_death_label.add_theme_constant_override("outline_size", 8)
	ui_death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_death_label.position = Vector2(0, 250) 
	ui_death_label.size = Vector2(1152, 100)
	ui_death_label.visible = false
	canvas.add_child(ui_death_label)
	update_hp_ui()
	
	# --- UI BOSS HP BAR (Tengah Atas) ---
	boss_hp_ui = VBoxContainer.new()
	boss_hp_ui.anchor_left = 0.5
	boss_hp_ui.anchor_right = 0.5
	boss_hp_ui.anchor_top = 0.0
	boss_hp_ui.anchor_bottom = 0.0
	boss_hp_ui.offset_left = -200
	boss_hp_ui.offset_right = 200
	boss_hp_ui.offset_top = 80
	boss_hp_ui.offset_bottom = 140
	boss_hp_ui.visible = false
	canvas.add_child(boss_hp_ui)
	
	var boss_name = Label.new()
	boss_name.text = "MEGA SPIDEROID"
	boss_name.add_theme_font_size_override("font_size", 24)
	boss_name.add_theme_color_override("font_color", Color.RED)
	boss_name.add_theme_color_override("font_outline_color", Color.BLACK)
	boss_name.add_theme_constant_override("outline_size", 6)
	boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hp_ui.add_child(boss_name)
	
	var bar_bg = ColorRect.new()
	bar_bg.custom_minimum_size = Vector2(400, 20) # Background tetap lebar
	bar_bg.color = Color.BLACK
	boss_hp_ui.add_child(bar_bg)
	
	boss_hp_bar = ColorRect.new()
	boss_hp_bar.custom_minimum_size = Vector2(0, 20) # Isi bar bisa menyusut
	boss_hp_bar.size = Vector2(400, 20)
	boss_hp_bar.color = Color.RED
	bar_bg.add_child(boss_hp_bar)
	# ------------------------------------

func update_hp_ui():
	var hp_text = "HP: " + str(current_hp) + " / " + str(max_hp)
	for i in range(10):
		if current_hp >= (i + 1) * 10:
			heart_labels[i].text = "❤"
			heart_labels[i].add_theme_color_override("font_color", Color.RED)
		else:
			heart_labels[i].text = "♡"
			heart_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		heart_labels[i].tooltip_text = hp_text   # ← update tooltip tiap HP berubah
	ui_lives_label.text = "✚ " + str(lives)

func take_damage(amount):
	if is_dead or damage_cooldown > 0: return
	if amount <= 0: return  # Debuff (web dll) tidak bisa parry
	if galahad_parry_active:
		galahad_parry_active = false
		damage_cooldown = 0.7
		show_floating_text("PARRIED!", $Player.global_position + Vector2(0, -40), Color.GOLD)
		
		var _weapon = hotbar_items[selected_hotbar_index]
		if _weapon == "Galahad Chimelin":
			var _uid = Global.hotbar_uuids[selected_hotbar_index]
			var _stats = Global.get_effective_stats(_weapon, item_data.get(_weapon, {}), _uid)
			var _counter_dmg = int(_stats.get("damage", 65) * 1.75 * buff_dmg_mult)
			var _facing = sign(get_global_mouse_position().x - $Player.global_position.x)
			if _facing == 0: _facing = 1
			
			for _e in enemies.duplicate():
				if not is_instance_valid(_e): continue
				var _e_half_w = _e.get_meta("size", 16.0) / 2.0
				var _dist = $Player.global_position.distance_to(_e.global_position) - _e_half_w
				if _dist > 128: continue
				
				var _dx = _e.global_position.x - $Player.global_position.x
				var _edge_left = _dx - _e_half_w
				var _edge_right = _dx + _e_half_w
				if _facing > 0 and _edge_right < -16: continue
				if _facing < 0 and _edge_left > 16: continue
				
				var _ct = _e.get_meta("type")
				var _ce = _e.get_meta("exp") if _e.has_meta("exp") else 0
				
				var _dmg_left = _counter_dmg
				if _e.get_meta("type") == "cave_slime" and _e.get_meta("armor_hp", 0) > 0:
					var _armor = _e.get_meta("armor_hp")
					var _absorbed = min(_dmg_left, _armor)
					_e.set_meta("armor_hp", _armor - _absorbed)
					_e.set_meta("armor_regen_timer", 0.0)
					_dmg_left -= _absorbed
					show_floating_text(str(_absorbed) + " (Armor)", _e.global_position + Vector2(0, -60), Color.YELLOW)
				
				if _dmg_left > 0:
					var _hp = _e.get_meta("hp") - _dmg_left
					_e.set_meta("hp", _hp)
					update_enemy_hp_bar(_e)
					show_floating_text(str(_dmg_left) + " PARRY!", _e.global_position + Vector2(0, -40), Color.GOLD)
				else:
					update_enemy_hp_bar(_e)
				
				var _kb_dir = sign(_e.global_position.x - $Player.global_position.x)
				if _kb_dir == 0: _kb_dir = _facing
				_safe_knockback(_e, _kb_dir, 64)
				if _e.has_meta("knockback_timer"):
					_e.set_meta("knockback_timer", 1.0)
				
				if _e.get_meta("hp", 1) <= 0:
					galahad_stacks = min(galahad_stacks + 1, 80)
					show_floating_text("+" + str(galahad_stacks) + "% DMG", $Player.global_position + Vector2(0, -60), Color.GOLD)
					if is_tutorial_active and _ct == "goblin":
						tutorial_stats["goblins_killed"] += 1
						check_objective_progress()
					if _ct == "boss_spider":
						spawn_final_lift()
						give_boss_loot()
						if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
					gain_exp(_ce)
					drop_loot(_ct)
					enemies.erase(_e)
					if is_instance_valid(_e):
						_e.queue_free()
			
			var _fan = ColorRect.new()
			_fan.size = Vector2(128, 80)
			if _facing > 0:
				_fan.position = Vector2($Player.global_position.x, $Player.global_position.y - 40)
			else:
				_fan.position = Vector2($Player.global_position.x - 128, $Player.global_position.y - 40)
			_fan.color = Color(1.0, 0.9, 0.3, 0.7)
			_fan.z_index = 15
			add_child(_fan)
			var _t = create_tween()
			_t.tween_property(_fan, "modulate:a", 0.0, 0.3)
			_t.tween_callback(_fan.queue_free)
		return
	
	# --- DEEP CAVE ARMOR: invuln saat petrify ---
	if deep_cave_active:
		show_floating_text("INVULNERABLE!", $Player.global_position + Vector2(0, -40), Color.GRAY)
		return
	# ---------------------------------------------
	
	var armor_dr = 0
	if Global.equipped_armor != null:
		var armor_data = Global.get_effective_stats(Global.equipped_armor, item_data.get(Global.equipped_armor, {}), Global.equipped_armor_uuid)
		armor_dr = armor_data.get("damage_reduction", 0)
		
	# --- PASSIVE HEAVY AMETHYST ARMOR ---
	var extra_dr = 0
	if Global.equipped_armor == "Heavy Amethyst Armor":
		if has_meta("amethyst_buffed"):
			armor_dr += 5
			remove_meta("amethyst_buffed")
		elif amount > 10:
			set_meta("amethyst_buffed", true)
			
	armor_dr += extra_dr
	# -----------------------------------
	
	if Global.equipped_armor == "Crystal Armor":
		crystal_armor_stacks = min(crystal_armor_stacks + 1, 10)
		armor_dr += crystal_armor_stacks * 0.5
		crystal_armor_timer = 7.0 # <--- RESET TIMER
		show_floating_text("Crystal Stack: " + str(crystal_armor_stacks) + "/10", $Player.global_position + Vector2(0, -80), Color.CYAN)
	
	# --- 2. GABUNGKAN DENGAN BUFF MAKANAN ---
	var total_dr = armor_dr + dmg_reduction
	var final_dmg = amount
	
	if total_dr >= 99:
		final_dmg = 1 # Mode Kebal (Golden Burger)
	else:
		final_dmg = amount - total_dr # Kurangi damage dengan total DR
		
	# --- 3. PASTIKAN DAMAGE MINIMAL 1 ---
	if final_dmg < 1: 
		final_dmg = 1
		
	# --- 4. TERAPKAN KE HP ---
	current_hp -= final_dmg
	damage_cooldown = 1.0
	regen_timer = 0.0 
	player_poly.color = Color.RED
	var tween = create_tween()
	tween.tween_property(player_poly, "color", Color(0.0, 1.0, 1.0), 0.2)
	
		# --- ARMOR BLUEPRINT PASSIVES ---
	if Global.equipped_armor == "Metal Skin Armor":
		var _nearest = null
		var _nearest_dist = 100.0
		for _e in enemies:
			if is_instance_valid(_e):
				var _d = $Player.global_position.distance_to(_e.global_position)
				if _d < _nearest_dist:
					_nearest_dist = _d
					_nearest = _e
		if _nearest != null:
			# Thorns pre-mitigation (pakai amount raw, bukan final_dmg)
			var _reflect = max(1, int(amount * 0.20))
			var _nearest_hp = _nearest.get_meta("hp") - _reflect
			_nearest.set_meta("hp", _nearest_hp)
			update_enemy_hp_bar(_nearest)
			show_floating_text(str(_reflect) + " (Reflect)", _nearest.global_position + Vector2(0, -40), Color.CYAN)
			if _nearest_hp <= 0:
				var _nt = _nearest.get_meta("type")
				var _ne = _nearest.get_meta("exp") if _nearest.has_meta("exp") else 0
				gain_exp(_ne)
				drop_loot(_nt)
				_try_drop_hammer_ore(_nearest)
				enemies.erase(_nearest)
				if is_instance_valid(_nearest):
					_nearest.queue_free()
	
	if Global.equipped_armor == "Shining Justice":
		if randf() < 0.35:
			var _ores = ["Copper", "Iron", "Coal", "Silver", "Gold", "Mithril", "Quartz", "Topaz", "Emerald", "Amethyst", "Diamond", "Void Crystal", "Uberilium"]
			var _drop = _ores.pick_random()
			inventory[_drop] = inventory.get(_drop, 0) + 1
			show_floating_text("+" + _drop, $Player.global_position + Vector2(0, -100), Color.GOLD)
			Global.hotbar_items = hotbar_items.duplicate()
			update_inventory_ui()
	
	if Global.equipped_armor == "Deep Cave Armor" and not deep_cave_active and deep_cave_cooldown <= 0:
		if current_hp < max_hp * 0.5 and current_hp > 0:
			deep_cave_active = true
			deep_cave_petrify_timer = 2.0
			deep_cave_regen_timer = 0.0
			deep_cave_cooldown = 30.0
			$Player.set_physics_process(false)
			show_floating_text("PETRIFIED!", $Player.global_position + Vector2(0, -60), Color.GRAY)
	# --------------------------------
	
	if current_hp <= 0:
		current_hp = 0
		update_hp_ui()
		die()
	else:
		update_hp_ui()

func die():
	if is_dead: return
	is_dead = true
	
	boss_silence_triggered = false
	
	# --- WARNING FIRST DEATH (sekali seumur save) ---
	if not Global.has_shown_death_warning:
		Global.has_shown_death_warning = true
		Global.save_game()
		show_dialog("⚠️ CAREFUL!\n\nIf you lose ALL your lives, your backpack and hotbar slots 4-7 will be PERMANENTLY ERASED.\n\nEquipped gear (slots 1-3 + armor) is SAFE.")
		await get_tree().create_timer(5.0).timeout
		if is_instance_valid(ui_dialog_panel):
			ui_dialog_panel.visible = false
	# ---------------------------------------------------
	
	lives -= 1
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
	print("[DEATH] Lives remaining: ", lives, " | HP was: ", current_hp)
	if is_inventory_open:
		is_inventory_open = false
		ui_inventory_panel.visible = false
	if is_crafting_open:
		is_crafting_open = false
		ui_crafting_panel.visible = false
	if is_char_open:
		is_char_open = false
		char_panel.visible = false
	$Player.velocity = Vector2.ZERO
	$Player.set_physics_process(false)
	
	if lives > 0:
		# --- RESPAWN NORMAL ---
		ui_death_label.visible = true
		update_hp_ui()
		ui_death_label.text = "You are died!\nrespawn in 3..."
		await get_tree().create_timer(1.0).timeout
		ui_death_label.text = "You are died!\nrespawn in 2..."
		await get_tree().create_timer(1.0).timeout
		ui_death_label.text = "You are died!\nrespawn in 1..."
		await get_tree().create_timer(1.0).timeout
		current_hp = max_hp
		if last_checkpoint_pos != Vector2.ZERO:
			$Player.global_position = last_checkpoint_pos
		else:
			$Player.global_position = Vector2(2416, 50)
		$Player.set_physics_process(true)
		is_dead = false
		damage_cooldown = 3.0
		ui_death_label.visible = false
		update_hp_ui()
	else:
		# --- GAME OVER: ITEMS LOST ---
		ui_death_label.visible = true
		ui_death_label.text = "GAME OVER!\nAll your items are gone..."
		update_hp_ui()
		await get_tree().create_timer(3.0).timeout
		_trigger_game_over()

func _trigger_game_over():
	Global.wipe_dungeon_fail()
	print("[GAME OVER] Returning to home...")
	get_tree().change_scene_to_file("res://home.tscn")

func bikin_ui_buff():
	var canvas = CanvasLayer.new()
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	ui_buff_panel = Panel.new()
	ui_buff_panel.size = Vector2(400, 300)
	ui_buff_panel.position = Vector2(376, 150)
	ui_buff_panel.visible = false
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2; style.border_width_top = 2; style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.8, 0.2)
	ui_buff_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(ui_buff_panel)
	var title = Label.new()
	title.text = "LEVEL UP! Choose 1 Buff:"
	title.position = Vector2(20, 20)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color.GOLD)
	ui_buff_panel.add_child(title)

func show_buff_options():
	is_buff_selecting = true
	get_tree().paused = true
	ui_buff_panel.visible = true
	for child in ui_buff_panel.get_children():
		if child is Button: child.queue_free()
	var available_buffs = all_buffs.duplicate()
	available_buffs.shuffle()
	for i in range(3):
		var buff = available_buffs[i]
		var btn = Button.new()
		btn.text = buff["text"]
		btn.position = Vector2(50, 70 + (i * 60))
		btn.size = Vector2(300, 40)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(func(): apply_buff(buff["id"]))
		ui_buff_panel.add_child(btn)
		Sfx.attach(btn)

func apply_buff(id: String):
	if id == "eff": buff_efficiency += 1.0
	elif id == "hp": current_hp = min(current_hp + 20, max_hp); update_hp_ui()
	elif id == "dmg": buff_dmg_mult += 0.05
	elif id == "speed": buff_speed_mult += 0.03; $Player.speed = 300.0 * buff_speed_mult
	elif id == "atkspd": buff_atk_speed_mult += 0.05
	ui_buff_panel.visible = false
	get_tree().paused = false
	is_buff_selecting = false
	show_floating_text("Buff Applied!", $Player.global_position)

func gain_exp(amount):
	dungeon_exp += amount
	while dungeon_exp >= dungeon_exp_to_next_level:
		dungeon_exp -= dungeon_exp_to_next_level
		dungeon_level += 1
		dungeon_exp_to_next_level += 5
		show_floating_text("DUNGEON LEVEL UP!", $Player.global_position + Vector2(0, -30))
		if not is_tutorial_active and Global.tutorial_step >= 3:
			show_buff_options()
	update_exp_ui()

func update_exp_ui():
	if ui_exp_label != null:
		ui_exp_label.text = "Dungeon Lv " + str(dungeon_level) + " | EXP: " + str(dungeon_exp) + "/" + str(dungeon_exp_to_next_level) + " | Mana: " + str(int(current_mana)) + "/" + str(max_mana)

func generate_vein_cluster(source_id, tile_index, vein_count, min_size, max_size, min_y, max_y):
	var placed = 0
	var attempts = 0 # <--- TAMBAHKAN PENGAMAN
	while placed < vein_count and attempts < 20000: # <--- BIAR GAK INFINITE LOOP
		attempts += 1
		var start_x = randi_range(10, WORLD_WIDTH - 10)
		var start_y = randi_range(min_y, max_y)
		
		# Cek base tile (Dirt, Stone, atau Blok T3)
		var base_tile = world.get_cell_atlas_coords(Vector2i(start_x, start_y)).x
		if base_tile != TILE_DIRT and base_tile != TILE_STONE and base_tile != TILE_CRYSTAL_STONE and base_tile != TILE_HARDENED_STONE: 
			continue
		
		var cx = start_x
		var cy = start_y
		var size = randi_range(min_size, max_size)
		for j in range(size):
			var current_tile = world.get_cell_atlas_coords(Vector2i(cx, cy)).x
			# Ganti blok jika itu Dirt, Stone, atau Blok T3
			if current_tile == TILE_DIRT or current_tile == TILE_STONE or current_tile == TILE_CRYSTAL_STONE or current_tile == TILE_HARDENED_STONE:
				world.set_cell(Vector2i(cx, cy), source_id, Vector2i(tile_index, 0))
			var dir = randi() % 4
			if dir == 0: cx += 1
			elif dir == 1: cx -= 1
			elif dir == 2: cy += 1
			elif dir == 3: cy -= 1
			cx = clamp(cx, 0, WORLD_WIDTH - 1)
			cy = clamp(cy, min_y, max_y)
		placed += 1

func is_area_clear(x: int, y: int, w: int, h: int) -> bool:
	for i in range(x - w, x + w + 1):
		for j in range(y - h, y + 1): 
			if world.get_cell_source_id(Vector2i(i, j)) != -1:
				return false
	if world.get_cell_source_id(Vector2i(x, y + 1)) == -1:
		return false
	return true

func try_place_block(mouse_world_pos):
	var held_item = hotbar_items[selected_hotbar_index]
	if held_item == null: return
	if not inventory.has(held_item) or inventory[held_item] <= 0: return
	var b_pos = world.local_to_map(world.to_local(mouse_world_pos))
	if world.get_cell_source_id(b_pos) != -1: return
	var pl_pos = $Player.global_position
	var b_center = world.to_global(world.map_to_local(b_pos))
	if pl_pos.distance_to(b_center) > PLACE_DISTANCE: return
	var walls_node = $Walls
	var has_support = false
	if walls_node.get_cell_source_id(b_pos) != -1: has_support = true
	else:
		var neighbors = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		for n in neighbors:
			if world.get_cell_source_id(b_pos + n) != -1:
				has_support = true
				break
	if not has_support: return
	if held_item == "Torch":
		var torch_node = Node2D.new()
		torch_node.position = b_center
		var stick = ColorRect.new()
		stick.size = Vector2(4, 10); stick.position = Vector2(-2, -2); stick.color = Color(0.4, 0.2, 0.1)
		torch_node.add_child(stick)
		var flame = ColorRect.new()
		flame.size = Vector2(6, 6); flame.position = Vector2(-3, -8); flame.color = Color(1, 0.8, 0.2)
		torch_node.add_child(flame)
		var light = PointLight2D.new()
		light.texture = bikin_tekstur_cahaya()
		light.shadow_enabled = false
		light.shadow_filter = Light2D.SHADOW_FILTER_PCF13
		light.shadow_filter_smooth = 3.0
		light.energy = 1.0; light.texture_scale = 3.0; light.color = Color(1, 0.8, 0.5)
		light.blend_mode = Light2D.BLEND_MODE_MIX 
		torch_node.add_child(light)
		var tween = create_tween().bind_node(torch_node).set_loops()
		tween.tween_property(flame, "modulate:a", 0.7, 0.2)
		tween.tween_property(flame, "modulate:a", 1.0, 0.2)
		tween.parallel().tween_property(light, "energy", 0.8, 0.2)
		tween.tween_property(light, "energy", 1.2, 0.2)
		add_child(torch_node)
		if is_tutorial_active:
			tutorial_stats["placed_torches"] += 1
			check_objective_progress()
	elif item_data.has(held_item) and item_data[held_item]["tile"] != -1:
		var tile_id = item_data[held_item]["tile"]
		world.set_cell(b_pos, 0, Vector2i(tile_id, 0))
		cek_gravel_jatuh(b_pos)
	else:
		return 
	inventory[held_item] -= 1
	if inventory[held_item] <= 0:
		inventory.erase(held_item)
		for i in range(7):
			if hotbar_items[i] == held_item: hotbar_items[i] = null
	update_inventory_ui()
	update_hotbar_ui()

# --- MINING TOOL HELPERS ---
func _get_block_toughness_by_id(tile_id: int) -> float:
	match tile_id:
		TILE_DIRT: return 2.0
		TILE_COAL: return 2.0
		TILE_IRON: return 3.0
		TILE_COPPER: return 2.5
		TILE_GRAVEL: return 2.0
		TILE_STONE: return 2.5
		TILE_SILVER: return 3.5
		TILE_GOLD: return 4.0
		TILE_MITHRIL: return 5.0
		TILE_QUARTZ: return 3.0
		TILE_TOPAZ: return 3.5
		TILE_EMERALD: return 4.5
		TILE_AMETHYST: return 5.0
		TILE_DIAMOND: return 6.0
		TILE_VOID: return 7.0
		TILE_UBERILIUM: return 9.0
		TILE_CRYSTAL_STONE: return 3.5
		TILE_HARDENED_STONE: return 5.5
		_: return 2.0

func _get_item_name_for_tile(tile_id: int) -> String:
	match tile_id:
		TILE_DIRT: return "Dirt"
		TILE_COAL: return "Coal"
		TILE_IRON: return "Iron"
		TILE_COPPER: return "Copper"
		TILE_GRAVEL: return "Gravel"
		TILE_STONE: return "Stone"
		TILE_SILVER: return "Silver"
		TILE_GOLD: return "Gold"
		TILE_MITHRIL: return "Mithril"
		TILE_QUARTZ: return "Quartz"
		TILE_TOPAZ: return "Topaz"
		TILE_EMERALD: return "Emerald"
		TILE_AMETHYST: return "Amethyst"
		TILE_DIAMOND: return "Diamond"
		TILE_VOID: return "Void Crystal"
		TILE_UBERILIUM: return "Uberilium"
		TILE_CRYSTAL_STONE: return "Crystal Stone"
		TILE_HARDENED_STONE: return "Hardened Crystal Stone"
		_: return ""

func _draw_magic_beam(start_pos: Vector2, end_pos: Vector2):
	# Raycast untuk stop di blok pertama
	var dir = (end_pos - start_pos).normalized()
	var traveled = 0.0
	var beam_end = end_pos
	while traveled < 320.0:
		var check_pos = start_pos + dir * traveled
		var tile = world.local_to_map(world.to_local(check_pos))
		if world.get_cell_source_id(tile) != -1:
			beam_end = world.to_global(world.map_to_local(tile))
			break
		traveled += 8.0
	
	# Beam visual
	if not is_instance_valid(_magic_beam_line):
		_magic_beam_line = Line2D.new()
		_magic_beam_line.width = 4.0
		_magic_beam_line.default_color = Color(0.5, 0.3, 0.9, 0.8)
		_magic_beam_line.z_index = 15
		add_child(_magic_beam_line)
	_magic_beam_line.clear_points()
	_magic_beam_line.add_point(start_pos)
	_magic_beam_line.add_point(beam_end)
	
	# Damage cooldown (separate dari attack_cooldown)
	if _magic_beam_dmg_cd > 0: return
	_magic_beam_dmg_cd = 0.7
	var dist = start_pos.distance_to(beam_end)
	for _e in enemies.duplicate():
		if not is_instance_valid(_e): continue
		var _e_pos = _e.global_position
		var proj = (_e_pos - start_pos).dot(dir)
		if proj <= 0 or proj >= dist: continue
		var perp = abs((_e_pos - start_pos).cross(dir))
		if perp < 40:
			var dmg = int(9 * buff_dmg_mult)
			var _cached_type = _e.get_meta("type")
			var _cached_exp = _e.get_meta("exp") if _e.has_meta("exp") else 0
			var hp = _e.get_meta("hp") - dmg
			_e.set_meta("hp", hp)
			update_enemy_hp_bar(_e)
			show_floating_text(str(dmg), _e_pos + Vector2(0, -40), Color.MEDIUM_PURPLE)
			if hp <= 0:
				if is_tutorial_active and _cached_type == "goblin":
					tutorial_stats["goblins_killed"] += 1
					check_objective_progress()
				if _cached_type == "boss_spider":
					spawn_final_lift()
					give_boss_loot()
					if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
				gain_exp(_cached_exp)
				drop_loot(_cached_type)
				enemies.erase(_e)
				if is_instance_valid(_e):
					_e.queue_free()

func _spawn_pneumatic_bomb(center_pos: Vector2):
	var bomb = ColorRect.new()
	bomb.size = Vector2(16, 16)
	bomb.color = Color(0.2, 0.2, 0.2)
	bomb.position = center_pos - Vector2(8, 8)
	bomb.z_index = 15
	add_child(bomb)
	var t = create_tween().set_loops(3)
	t.tween_property(bomb, "modulate:a", 0.3, 0.25)
	t.tween_property(bomb, "modulate:a", 1.0, 0.25)
	_pneumatic_bombs.append({"node": bomb, "timer": 1.5, "position": center_pos})

func _update_pneumatic_bombs(delta):
	for i in range(_pneumatic_bombs.size() - 1, -1, -1):
		var b = _pneumatic_bombs[i]
		if not is_instance_valid(b["node"]):
			_pneumatic_bombs.remove_at(i)
			continue
		b["timer"] -= delta
		if b["timer"] <= 0:
			_explode_pneumatic_bomb(b["position"])
			b["node"].queue_free()
			_pneumatic_bombs.remove_at(i)

func _explode_pneumatic_bomb(center_pos: Vector2):
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
	
	# Damage enemies (dengan cave slime armor soak)
	var _dmg = 30
	for _e in enemies.duplicate():
		if not is_instance_valid(_e): continue
		if _aoe.has_point(_e.global_position):
			var _actual = _dmg
			if _e.get_meta("type") == "cave_slime" and _e.get_meta("armor_hp", 0) > 0:
				var _armor = _e.get_meta("armor_hp")
				var _absorb = min(_actual, _armor)
				_e.set_meta("armor_hp", _armor - _absorb)
				_actual -= _absorb
				_e.set_meta("armor_regen_timer", 0.0)
				show_floating_text(str(_absorb) + " (Armor)", _e.global_position + Vector2(0, -20), Color.YELLOW)
			if _actual > 0:
				var _ct = _e.get_meta("type")
				var _ce = _e.get_meta("exp") if _e.has_meta("exp") else 0
				var hp = _e.get_meta("hp") - _actual
				_e.set_meta("hp", hp)
				update_enemy_hp_bar(_e)
				show_floating_text(str(_actual), _e.global_position + Vector2(0, -40), Color.ORANGE)
				if hp <= 0:
					gain_exp(_ce)
					drop_loot(_ct)
					_try_drop_hammer_ore(_e)
					enemies.erase(_e)
					if is_instance_valid(_e):
						_e.queue_free()
	
	# Destroy/weaken blocks — toughness limit 5
	var _tl = world.local_to_map(world.to_local(center_pos - Vector2(_radius, _radius)))
	var _br = world.local_to_map(world.to_local(center_pos + Vector2(_radius, _radius)))
	for _x in range(_tl.x, _br.x + 1):
		for _y in range(_tl.y, _br.y + 1):
			if _x < 0 or _x >= WORLD_WIDTH: continue
			if _y < 0: continue
			if Global.tutorial_step == 0 and _y >= 100: continue
			if Global.tutorial_step != 0 and _y >= WORLD_DEPTH - 1: continue
			var _cell = Vector2i(_x, _y)
			if world.get_cell_source_id(_cell) == -1: continue
			var _tile_x = world.get_cell_atlas_coords(_cell).x
			var _base_t = _get_block_toughness_by_id(_tile_x)
			var _current_t = _base_t
			if _pneumatic_weakened.has(_cell):
				_current_t = _pneumatic_weakened[_cell]
			
			if _current_t <= 5.0:
				# Destroy + loot otomatis
				var _item = _get_item_name_for_tile(_tile_x)
				if _item != "":
					tambah_item(_item)
					show_floating_text("+" + _item, world.to_global(world.map_to_local(_cell)), Color.LIGHT_GRAY)
				world.erase_cell(_cell)
				_pneumatic_weakened.erase(_cell)
			else:
				# Weaken -5 toughness
				_pneumatic_weakened[_cell] = _current_t - 5.0
				show_floating_text("-5 Toughness", world.to_global(world.map_to_local(_cell)), Color.ORANGE)

func take_true_damage(amount, source_pos=Vector2.ZERO):
	if is_dead: return
	current_hp -= amount
	if source_pos != Vector2.ZERO: show_floating_text("-" + str(amount) + " HP", source_pos)
	player_poly.color = Color.RED
	var tween = create_tween()
	tween.tween_property(player_poly, "color", Color(0.0, 1.0, 1.0), 0.2)
	if current_hp <= 0:
		current_hp = 0
		update_hp_ui()
		die()
	else:
		update_hp_ui()

func cek_gravel_jatuh(tile_pos: Vector2i):
	if tile_pos.y < 0 or tile_pos.y >= WORLD_DEPTH: return
	if world.get_cell_atlas_coords(tile_pos).x == TILE_GRAVEL:
		var below = Vector2i(tile_pos.x, tile_pos.y + 1)
		if world.get_cell_source_id(below) == -1:
			world.erase_cell(tile_pos)
			spawn_jatuh_gravel(tile_pos)
			cek_gravel_jatuh(Vector2i(tile_pos.x, tile_pos.y - 1))

func spawn_jatuh_gravel(start_tile: Vector2i):
	var faller = ColorRect.new()
	faller.size = Vector2(16, 16)
	faller.color = Color(0.6, 0.6, 0.6)
	faller.position = world.to_global(world.map_to_local(start_tile)) - Vector2(8, 8)
	add_child(faller)
	var target_y = start_tile.y + 1
	while true:
		var check_pos = Vector2i(start_tile.x, target_y)
		if world.get_cell_source_id(check_pos) != -1 or target_y >= WORLD_DEPTH: break
		target_y += 1
	var target_pos = world.to_global(world.map_to_local(Vector2i(start_tile.x, target_y - 1))) - Vector2(8, 8)
	var tween = create_tween()
	var durasi = 0.1 * (target_y - start_tile.y)
	if durasi < 0.1: durasi = 0.1
	tween.tween_property(faller, "position", target_pos, durasi).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(func():
		faller.queue_free()
		if target_y - 1 < WORLD_DEPTH:
			world.set_cell(Vector2i(start_tile.x, target_y - 1), 0, Vector2i(TILE_GRAVEL, 0))
			cek_gravel_jatuh(Vector2i(start_tile.x, target_y - 2))
	)

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

func tambah_item(item_name: String, amount: int = 1, force_new_uuid: bool = false):
	var is_weapon = item_data.get(item_name, {}).has("weapon_type")
	
	if is_weapon:
		for i in range(amount):
			var _has_weapon = false
			
			# Jika force_new_uuid aktif (misal dari drop bos), lewati cek anti-duplikat
			if not force_new_uuid:
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
				show_floating_text("+5 Scrap (Dup)", $Player.global_position, Color.GRAY)
			else:
				var new_key = Global.create_weapon_key(item_name)
				inventory[new_key] = 1
				Global.item_levels[new_key] = 1
	else:
		var is_new_item = not inventory.has(item_name)
		inventory[item_name] = inventory.get(item_name, 0) + amount
		if is_new_item and not hotbar_items.has(item_name):
			for i in range(3, 7):
				if hotbar_items[i] == null:
					hotbar_items[i] = item_name
					break
	
	Global.saved_inventory = inventory.duplicate()
	Global.hotbar_items = hotbar_items.duplicate()
	
	if item_name == "Scrap" and not Global.has_shown_scrap_dialog:
		Global.has_shown_scrap_dialog = true
		Global.save_game()
		show_t3_scrap_dialog()
	
	update_inventory_ui()
	update_hotbar_ui()

func bikin_efek_retak():
	var crack_img = Image.create(BLOCK_SIZE, BLOCK_SIZE, false, Image.FORMAT_RGBA8)
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

func reset_mining():
	target_block = Vector2i(-1, -1)
	mine_timer = 0.0
	if crack_sprite: crack_sprite.visible = false
	
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

func start_lift_sequence(clicked_lift: Node2D):
	if is_lifting: return
	is_lifting = true
	$Player.set_physics_process(false)
	
	# Bersihkan state yang mungkin nyangkut
	get_tree().paused = false
	if is_instance_valid(pause_blocker_main): pause_blocker_main.visible = false
	if is_instance_valid(abort_blocker): abort_blocker.visible = false
	if is_instance_valid(pause_panel_main): pause_panel_main.visible = false
	if is_instance_valid(abort_confirm_panel): abort_confirm_panel.visible = false
	
	# Fix utama: pakai TILE Y, bukan PIXEL Y
	var _lift_tile_y = world.local_to_map(world.to_local(clicked_lift.global_position)).y
	var is_final_lift = _lift_tile_y > 1000
	var is_retreat = not is_final_lift and Global.tutorial_step != 3 and Global.tutorial_step != 0
	
	print("[LIFT] START - tile_y=", _lift_tile_y, " is_final=", is_final_lift, " is_retreat=", is_retreat, " step=", Global.tutorial_step, " exp_before=", Global.player_exp)
	
	# EXP: HANYA final lift / selesai T2. Retreat TIDAK dapat EXP.
	if is_final_lift or Global.tutorial_step == 3:
		var map_exp_reward = Global.get_map_exp_reward(Global.tutorial_step)
		if Global.tutorial_step == 8 and Global.player_level < 3:
			var needed = 0
			var lv = Global.player_level
			var ex = Global.player_exp
			var req = Global.exp_to_next_level
			while lv < 3:
				needed += (req - ex)
				lv += 1
				ex = 0
				req *= 2
			map_exp_reward = max(map_exp_reward, needed)
		print("[LIFT] Adding EXP: ", map_exp_reward)
		Global.add_player_exp(map_exp_reward)
	else:
		print("[LIFT] No EXP (retreat / non-clear)")
	
	# Tutorial transitions
	if Global.tutorial_step == 0:
		Global.tutorial_step = 1
	elif Global.tutorial_step == 3:
		Global.tutorial_step = 4
	elif Global.tutorial_step == 8 and is_final_lift:
		Global.tutorial_step = 9
		Global.highest_difficulty_cleared = max(Global.highest_difficulty_cleared, 1)
	
	# Inventory transfer — sama untuk semua tipe lift
	Global.saved_inventory.clear()
	var consumables = [
		"Dirt", "Gravel", "Stone", "Flint", "Stick", "Arrow", "Torch", "Food Box", "Bomb", "Coal",
		"Banana", "Grape", "Bacon", "Pizza Slice", "Burger", "Golden Burger", "Frozen Apple"
	]
	for item_name in inventory.keys():
		if item_name not in consumables:
			Global.saved_inventory[item_name] = inventory[item_name]
	
	var new_hotbar = hotbar_items.duplicate()
	for i in range(3, 7):
		if new_hotbar[i] != null and new_hotbar[i] in consumables:
			new_hotbar[i] = null
	if new_hotbar[0] == null: new_hotbar[0] = "Fist"
	if new_hotbar[1] == null: new_hotbar[1] = "Stone Pickaxe"
	if new_hotbar[2] == null: new_hotbar[2] = "Bow"
	
	Global.hotbar_items = new_hotbar.duplicate()
	inventory.clear()
	
	if not is_retreat:
		Global.tutorial_completed = true
	
	Global.gold_coins += dungeon_gold
	dungeon_gold = 0
	
	Global.save_game()
	print("[LIFT] State saved. exp_after=", Global.player_exp, " step_now=", Global.tutorial_step)
	
	# --- ANIMASI LIFT KEMBALI ---
	var lbl = Label.new()
	if is_final_lift:
		lbl.text = "Level Complete!"
	elif is_retreat:
		lbl.text = "Retreating..."
	else:
		lbl.text = "Returning to Surface..."
	lbl.add_theme_font_size_override("font_size", 48)
	lbl.add_theme_color_override("font_color", Color.GOLD if is_final_lift else Color.CYAN)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 8)
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(lbl)
	
	var tween = create_tween()
	tween.tween_property($Player, "global_position", clicked_lift.global_position, 0.5)
	tween.tween_property(clicked_lift, "global_position:y", clicked_lift.global_position.y - 500, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($Player, "global_position:y", $Player.global_position.y - 500, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await tween.finished
	
	# Fade Out
	var fade_layer = CanvasLayer.new()
	fade_layer.layer = 200
	add_child(fade_layer)
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.size = get_viewport().get_visible_rect().size
	fade_layer.add_child(fade)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(fade, "color:a", 1.0, 0.5)
	await fade_tween.finished
	
	# Change scene (Setelah layar hitam)
	get_tree().change_scene_to_file("res://home.tscn")

func update_objective_ui():
	if not is_tutorial_active: return
	if current_objective_index < objectives.size():
		var obj = objectives[current_objective_index]
		var current_stat = min(tutorial_stats[obj["stat"]], obj["target"])
		ui_objective_label.text = "Obj: " + obj["text"] + " (" + str(current_stat) + "/" + str(obj["target"]) + ")"

func check_objective_progress():
	if not is_tutorial_active or current_objective_index >= objectives.size(): return
	var obj = objectives[current_objective_index]
	if tutorial_stats[obj["stat"]] >= obj["target"]:
		var tween = create_tween()
		tween.tween_property(ui_objective_label, "modulate", Color(1, 1, 0), 0.15)
		tween.tween_property(ui_objective_label, "modulate", Color(1, 1, 1), 0.15)
		tween.set_loops(3)
		tween.finished.connect(func():
			current_objective_index += 1
			while current_objective_index < objectives.size():
				var next_obj = objectives[current_objective_index]
				if tutorial_stats[next_obj["stat"]] >= next_obj["target"]:
					current_objective_index += 1
				else: break
			if current_objective_index < objectives.size():
				update_objective_ui()
			else:
				ui_objective_label.text = "Tutorial Complete!"
				ui_objective_label.add_theme_color_override("font_color", Color.GOLD)
				is_tutorial_active = false
		)
	else:
		update_objective_ui()

func toggle_spectator():
	is_spectating = !is_spectating
	$Player.is_spectator = is_spectating
	if is_spectating:
		$Player.collision_mask = 0 # Noclip
		$Player/Camera2D.zoom = Vector2(0.3, 0.3) # <-- Ubah ke 0.3 (lebih dekat dari 0.15)
		canvas_mod.color = Color(1, 1, 1)
		player_light.texture_scale = 150.0
		show_floating_text("SPECTATOR ON", $Player.global_position)
	else:
		$Player.collision_mask = 1 # Balik tabrakan
		$Player/Camera2D.zoom = Vector2(1, 1)
		canvas_mod.color = Color(0.1, 0.1, 0.15)
		player_light.texture_scale = 2.0
		$Player.velocity = Vector2.ZERO
		show_floating_text("SPECTATOR OFF", $Player.global_position)

func spawn_arrow(start_pos: Vector2, target_pos: Vector2, damage: int, owner_type: String = "player", weapon_name: String = "", is_charged: bool = false):
	var arrow = ColorRect.new()
	arrow.size = Vector2(12, 4)
	arrow.color = Color(0.8, 0.8, 0.8)
	if weapon_name == "Headhitter Heavy Bow" and is_charged:
		arrow.size = Vector2(18, 8) # 25% lebih lebar dan tebal
		arrow.color = Color(0.8, 0.2, 0.2)
	if owner_type == "enemy":
		arrow.color = Color(1.0, 0.4, 0.4)
	arrow.position = start_pos
	arrow.set_meta("velocity", (target_pos - start_pos).normalized() * 600.0)
	arrow.set_meta("damage", damage)
	arrow.set_meta("owner", owner_type)
	arrow.set_meta("weapon", weapon_name)
	arrow.set_meta("is_charged", is_charged)
	arrow.set_meta("hit_enemies", []) # <--- TAMBAHKAN INI (Array kosong)
	add_child(arrow)
	arrows.append(arrow)

func spawn_enemy_projectile(start_pos: Vector2, target_pos: Vector2, proj_type: String):
	var proj = ColorRect.new()
	proj.position = start_pos
	proj.set_meta("owner", "enemy")
	proj.set_meta("proj_type", proj_type)
	proj.set_meta("velocity", (target_pos - start_pos).normalized())
	
	if proj_type == "rock":
		proj.size = Vector2(12, 12); proj.color = Color(0.5, 0.5, 0.5)
		proj.set_meta("velocity", proj.get_meta("velocity") * 400.0); proj.set_meta("damage", 35)
	elif proj_type == "web":
		proj.size = Vector2(16, 16); proj.color = Color(0.9, 0.9, 0.9, 0.8)
		proj.set_meta("velocity", proj.get_meta("velocity") * 150.0); proj.set_meta("damage", 5)
	elif proj_type == "poison_web": # <--- BARU
		proj.size = Vector2(16, 16); proj.color = Color(0.2, 1.0, 0.2, 0.8)
		proj.set_meta("velocity", proj.get_meta("velocity") * 150.0); proj.set_meta("damage", 15)
		
	add_child(proj)
	arrows.append(proj)

func update_arrows(delta):
	if is_dead: return
	
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
		
		# --- PLAYER BOULDER (Crystal Minigun) ---
		if arrow.get_meta("is_player_boulder", false):
			var _bhit = false
			for _e in enemies:
				if is_instance_valid(_e) and arrow.position.distance_to(_e.global_position) < 30:
					_bhit = true
					break
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
			var _bl = arrow.get_meta("life_timer", 1.5) - delta
			arrow.set_meta("life_timer", _bl)
			if _bl <= 0:
				_bhit = true
			if _bhit:
				explode_player_boulder(arrow.position, arrow.get_meta("damage"))
				arrow.queue_free()
				arrows.remove_at(i)
				continue
		# ----------------------------------------

		if owner_type == "player":
			var should_destroy = false
			for enemy in enemies:
				if is_instance_valid(enemy) and arrow.position.distance_to(enemy.global_position) < 20:
					
					# Cek apakah musuh ini udah pernah kena panah ini
					var hit_list = arrow.get_meta("hit_enemies", [])
					if enemy in hit_list and arrow.get_meta("weapon", "") != "Ricochet Bow":
						continue # Skip kalau udah kena
					# --- MARBLE SLINGSHOT: inline damage + SOAK (pellet destroy after 1 hit) ---
					if arrow.get_meta("weapon", "") == "Marble Slingshot":
						var _dmg_left = arrow.get_meta("damage")
						
						# Armor soak cave_slime biasa
						if enemy.get_meta("type") == "cave_slime" and enemy.get_meta("armor_hp", 0) > 0:
							var _armor = enemy.get_meta("armor_hp")
							var _absorb = min(_dmg_left, _armor)
							enemy.set_meta("armor_hp", _armor - _absorb)
							_dmg_left -= _absorb
							show_floating_text(str(_absorb) + " (Armor)", enemy.global_position + Vector2(0, -20), Color.YELLOW)
						
						if _dmg_left > 0:
							var _hp = enemy.get_meta("hp") - _dmg_left
							enemy.set_meta("hp", _hp)
							update_enemy_hp_bar(enemy)
							show_floating_text(str(_dmg_left), enemy.global_position + Vector2(randf_range(-20, 20), -30 - randf_range(0, 15)), Color.CYAN)
							if _hp <= 0:
								var _ct = enemy.get_meta("type")
								var _ce = enemy.get_meta("exp") if enemy.has_meta("exp") else 0
								if is_tutorial_active and _ct == "goblin":
									tutorial_stats["goblins_killed"] += 1
									check_objective_progress()
								if _ct == "boss_spider":
									spawn_final_lift()
									give_boss_loot()
									if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
								gain_exp(_ce)
								drop_loot(_ct)
								enemies.erase(enemy)
								if is_instance_valid(enemy):
									enemy.queue_free()
						
						# SOAK: pellet destroy setelah hit 1 musuh (bukan pierce)
						should_destroy = true
						break
					# -----------------------------------------------
					if enemy.get_meta("is_invulnerable", false):
						show_floating_text("INVULNERABLE!", enemy.global_position + Vector2(0, -40), Color.GRAY)
						should_destroy = true
						break
					var final_dmg = arrow.get_meta("damage")
					# --- HEADHITTER HEAVY BOW: EXECUTION ---
					if arrow.get_meta("weapon", "") == "Headhitter Heavy Bow":
						if enemy.get_meta("hp") < (enemy.get_meta("max_hp") * 0.3):
							final_dmg = int(final_dmg * 1.5)
							show_floating_text("EXECUTE!", enemy.global_position + Vector2(0, -60), Color.RED)
					var actual_dmg = final_dmg
					
					# --- STICKY CROSSBOW EFFECT ---
					if arrow.get_meta("weapon", "") == "Sticky Crossbow":
						enemy.set_meta("terrified_timer", 3.0)
						show_floating_text("STUCK!", enemy.global_position + Vector2(0, -40), Color.GREEN)
						var _pull_pos = enemy.global_position
						$Player.set_physics_process(false)
						$Player.velocity = Vector2.ZERO
						var _pt = create_tween()
						_pt.tween_property($Player, "global_position", _pull_pos, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
						_pt.tween_callback($Player.set_physics_process.bind(true))
						should_destroy = true
						break
					
					# --- BOUNTY BOW EFFECT ---
					if arrow.get_meta("weapon", "") == "Bounty Bow":
						enemy.set_meta("is_bountied", true)
						show_floating_text("BOUNTY!", enemy.global_position + Vector2(0, -70), Color.YELLOW)
					
					# --- MOURNING BOW: stun on charge shot ---
					if arrow.has_meta("stun_on_hit"):
						enemy.set_meta("terrified_timer", arrow.get_meta("stun_on_hit"))
						show_floating_text("STUNNED!", enemy.global_position + Vector2(0, -60), Color.CYAN)
					
					# --- EXPLOSIVE CROSSBOW: skip damage, AOE handled after loop ---
					if arrow.get_meta("weapon", "") == "Explosive Crossbow" and arrow.get_meta("is_charged", false):
						should_destroy = true
						break
					
					
					# 1. Golem Resistance (Karena panah itu Physical, kena resist 30%)
					if enemy.get_meta("type") == "crystal_golem":
						actual_dmg = int(actual_dmg * 0.7)
						show_floating_text("Resisted!", enemy.global_position + Vector2(0, -60), Color.GRAY)
						
					# 2. Slime Armor
					if enemy.get_meta("type") == "cave_slime" and enemy.get_meta("armor_hp", 0) > 0:
						var armor_hp = enemy.get_meta("armor_hp")
						var armor_damage = min(actual_dmg, armor_hp)
						enemy.set_meta("armor_hp", armor_hp - armor_damage)
						actual_dmg -= armor_damage
						enemy.set_meta("armor_regen_timer", 0.0) # Reset timer regen armor
						show_floating_text(str(armor_damage) + " (Armor)", enemy.global_position + Vector2(0, -20), Color.YELLOW)
						
					var hp = enemy.get_meta("hp") - actual_dmg
					if actual_dmg > 0:
						var dmg_color = Color.RED
						var w_name = arrow.get_meta("weapon", "")
						var w_type = item_data.get(w_name, {}).get("weapon_type", "")
						if w_type == "Elemental Damage": dmg_color = Color.GREEN
						elif w_type == "Magic Damage": dmg_color = Color.MEDIUM_PURPLE
						show_floating_text(str(actual_dmg), enemy.global_position + Vector2(0, -40), dmg_color)
					enemy.set_meta("hp", hp)
					update_enemy_hp_bar(enemy)
					
					enemy.get_child(0).color = Color.WHITE
					var t = create_tween()
					t.tween_property(enemy.get_child(0), "color", enemy.get_meta("base_color"), 0.1)
					
					# --- HEADHITTER KNOCKBACK ---
					if arrow.get_meta("weapon", "") == "Headhitter Heavy Bow" and arrow.get_meta("is_charged", false):
						var _hb_dir = sign(enemy.global_position.x - $Player.global_position.x)
						if _hb_dir == 0: _hb_dir = 1
						_safe_knockback(enemy, _hb_dir, 64)
						if enemy.has_meta("knockback_timer"):
							enemy.set_meta("knockback_timer", 1.0)
					
					# --- RICOCHET BOW LOGIC ---
					var _is_ricochet = false
					if arrow.get_meta("weapon", "") == "Ricochet Bow" and arrow.get_meta("is_charged", false):
						var _bounces = arrow.get_meta("bounce_count", 0)
						if _bounces < 4 and randf() < 0.20:
							var _nearest = null
							var _min_dist = 128.0  # Range mantul maksimal 8 block
							for _other in enemies:
								if not is_instance_valid(_other) or _other.is_queued_for_deletion(): continue
								if _other in hit_list: continue  # Jangan mantul ke musuh yang sudah kena
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
								hit_list.append(enemy)
								arrow.set_meta("hit_enemies", hit_list)

					if _is_ricochet:
						should_destroy = false
						break # Lanjut terbang ke musuh berikutnya
					elif hp <= 0:
						# --- BOUNTY BOW KILL LOGIC ---
						if arrow.get_meta("weapon", "") == "Bounty Bow":
							bounty_bow_stacks = min(bounty_bow_stacks + 1, 5)
							bounty_stack_timer = 7.0
							show_floating_text("Bounty Stack: " + str(bounty_bow_stacks) + "/5", $Player.global_position + Vector2(0, -60), Color.GOLD)
						# ------------------------------
						
						gain_exp(enemy.get_meta("exp"))
						drop_loot(enemy.get_meta("type"))
						gain_exp(enemy.get_meta("exp"))
						drop_loot(enemy.get_meta("type"))
						if is_tutorial_active and enemy.get_meta("type") == "goblin":
							tutorial_stats["goblins_killed"] += 1
							check_objective_progress()
						if enemy.get_meta("type") == "boss_spider":
							spawn_final_lift()
							give_boss_loot()
							if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
						enemies.erase(enemy)
						enemy.queue_free()
						
						# --- FIX: Hancurkan panah agar tidak menembus musuh lain ---
						should_destroy = true
						break
					else:
						# --- IRON BOW PIERCE (10% chance pas charge) ---
						var w_name = arrow.get_meta("weapon", "")
						var was_charged = arrow.get_meta("is_charged", false)
						if w_name == "Iron Bow" and was_charged and randf() < 0.10:
							show_floating_text("PIERCE!", enemy.global_position + Vector2(0, -60), Color.CYAN)
							hit_list.append(enemy)
							arrow.set_meta("hit_enemies", hit_list)
							continue
						else:
							should_destroy = true
							break
			if should_destroy:
				hit = true
		else:
			if arrow.position.distance_to($Player.global_position) < 20:
				# --- TENACITY: reflect projectile ---
				if Global.equipped_armor == "Tenacity Battle Armor" and randf() < 0.40:
					var _nearest = null
					var _nearest_dist = 400.0
					for _e in enemies:
						if is_instance_valid(_e):
							var _d = $Player.global_position.distance_to(_e.global_position)
							if _d < _nearest_dist:
								_nearest_dist = _d
								_nearest = _e
					if _nearest != null:
						var _dmg = arrow.get_meta("damage")
						var _hp = _nearest.get_meta("hp") - _dmg
						_nearest.set_meta("hp", _hp)
						update_enemy_hp_bar(_nearest)
						show_floating_text(str(_dmg) + " (Reflect)", _nearest.global_position + Vector2(0, -40), Color.CYAN)
						show_floating_text("REFLECT!", $Player.global_position + Vector2(0, -40), Color.GOLD)
						if _hp <= 0:
							gain_exp(_nearest.get_meta("exp"))
							drop_loot(_nearest.get_meta("type"))
							_try_drop_hammer_ore(_nearest)
							enemies.erase(_nearest)
							_nearest.queue_free()
						arrow.queue_free()
						arrows.remove_at(i)
						continue
				# ----------------------------------
				
				# --- TAMBAHKAN INI: Deteksi Jaring Musuh ---
				if arrow.get_meta("proj_type", "") == "web" or arrow.get_meta("proj_type", "") == "poison_web":
					player_stun_timer = 2.0
					player_slow_timer = 3.0
					show_floating_text("STUNNED!", $Player.global_position + Vector2(0, -40), Color.WHITE)
					$Player/Polygon2D.color = Color(0.8, 0.8, 0.8)
					
					# Kasih tahu Boss kalau jaringnya kena
					for e in enemies:
						if is_instance_valid(e) and e.get_meta("type") == "boss_spider":
							e.set_meta("web_hit_player", true)
							break
				else:
					take_damage(arrow.get_meta("damage"))
				hit = true
			
		var tile_pos = world.local_to_map(world.to_local(arrow.position))
		if world.get_cell_source_id(tile_pos) != -1:
			hit = true
			# --- STICKY CROSSBOW WALL PULL ---
			if arrow.get_meta("weapon", "") == "Sticky Crossbow":
				$Player.set_physics_process(false)
				$Player.velocity = Vector2.ZERO
				var _pt = create_tween()
				_pt.tween_property($Player, "global_position", arrow.position, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				_pt.tween_callback($Player.set_physics_process.bind(true))
		if hit:
			# --- EXPLOSIVE CROSSBOW AOE ---
			if arrow.get_meta("weapon", "") == "Explosive Crossbow" and arrow.get_meta("is_charged", false):
				trigger_crossbow_explosion(arrow.position, arrow.get_meta("damage"))
			arrow.queue_free()
			arrows.remove_at(i)

func update_enemy_hp_bar(enemy):
	if not is_instance_valid(enemy): return
	var hp = enemy.get_meta("hp")
	var max_hp = enemy.get_meta("max_hp")
	var bar = enemy.get_meta("hp_bar", null)
	
	if enemy.get_meta("type") == "cave_slime" and enemy.get_meta("armor_hp", 0) > 0:
		var armor = enemy.get_meta("armor_hp")
		if bar: bar.size.x = 30.0 * (float(armor) / 200.0)
		if bar: bar.color = Color.YELLOW
	elif enemy.get_meta("type") == "boss_spider":
		# Update UI Bar di Tengah Atas
		if is_instance_valid(boss_hp_bar):
			boss_hp_bar.size.x = 400.0 * (float(hp) / max_hp)
			if hp <= max_hp * 0.5: boss_hp_bar.color = Color.PURPLE
			else: boss_hp_bar.color = Color.RED
	elif is_instance_valid(bar):
		bar.size.x = 30.0 * (float(hp) / max_hp)
		if hp <= max_hp * 0.3: bar.color = Color.RED
		else: bar.color = Color.GREEN

func spawn_boss_mega_spideroid():
	if Global.tutorial_step < 8: return
	
	var boss = CharacterBody2D.new()
	boss.add_to_group("enemies")
	
	# Stats Raksasa
	var hp = 2200
	var dmg = 30 # Tambahkan variabel dmg
	var size_w = 240.0 
	var size_h = 64.0
	var pos = Vector2i(150, 1150)
	
	# --- INFLASI DIFFICULTY ---
	var diff_hp_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var diff_dmg_mult = 1.0 + (Global.current_difficulty - 1) * 0.05
	hp = int(hp * diff_hp_mult)
	dmg = int(dmg * diff_dmg_mult)
	# --------------------------
	
	boss.set_meta("type", "boss_spider")
	boss.set_meta("size", size_w)
	boss.set_meta("hp", hp)
	boss.set_meta("max_hp", hp)
	boss.set_meta("damage", dmg) # Ubah 30 jadi dmg
	boss.set_meta("exp", 500)
	boss.set_meta("state", "waiting") # <--- STATE BARU
	boss.set_meta("is_invulnerable", true) # <--- Kebal dulu selama dialog
	boss.set_meta("atk_timer", 2.0)
	boss.set_meta("base_color", Color(0.2, 0.0, 0.0))
	
	boss.position = world.to_global(world.map_to_local(pos))
	boss.position.y += 8.0 - (size_h / 2.0)
	
	# Visual Boss (Hitam/Merah)
	var poly = Polygon2D.new()
	var half_w = size_w / 2.0
	var half_h = size_h / 2.0
	poly.polygon = PackedVector2Array([Vector2(-half_w, -half_h), Vector2(half_w, -half_h), Vector2(half_w, half_h), Vector2(-half_w, half_h)])
	poly.color = Color(0.2, 0.0, 0.0) 
	boss.add_child(poly)
	
	# Collision
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(size_w, size_h)
	col.shape = rect
	boss.add_child(col)
	
	boss.collision_mask = 1
	add_child(boss)
	enemies.append(boss)
	
	return boss # <--- Kembalikan node boss untuk diproses dialog

func bikin_arena_boss():
	if Global.tutorial_step < 8: return
	
	var cx = 150 
	var cy = 1198 # <--- UBAH JADI 1198 (Jangan 1199, biar bedrock aman)
	var radius = 55 
	
	var walls_node = get_node_or_null("Walls")
	
	for x in range(cx - radius, cx + radius):
		for y in range(cy - radius, cy + 1):
			# PENGAMAN: Jangan pernah hapus blok di baris paling bawah (Bedrock)
			if y >= WORLD_DEPTH - 1:
				continue
				
			# Rumus setengah lingkaran
			if (x - cx)*(x - cx) + (y - cy)*(y - cy) <= radius * radius:
				# Hapus blok foreground agar jadi ruangan kosong
				world.erase_cell(Vector2i(x, y))
				
				# Pastikan background wall ada agar tidak bolong hitam
				if walls_node and walls_node.get_cell_source_id(Vector2i(x, y)) == -1:
					walls_node.set_cell(Vector2i(x, y), 0, Vector2i(TILE_HARDENED_STONE, 0))

func lock_boss_arena():
	is_boss_arena_locked = true
	MusicManager.play_bgm("res://audio/bgm_boss_mega_spideroid.mp3") # <--- HAPUS HURUF 's' DI SINI
	
	# 1. Bersihkan area & tutup pintu masuk
	for enemy in enemies:
		if is_instance_valid(enemy):
			var e_tile = world.local_to_map(world.to_local(enemy.global_position))
			if e_tile.y >= 1100 and enemy.get_meta("type") != "boss_spider":
				enemies.erase(enemy)
				enemy.queue_free()
				
	# Tutup seluruh lebar peta di Y=1145 dan Y=1144
	for x in range(0, WORLD_WIDTH):
		world.set_cell(Vector2i(x, 1144), 0, Vector2i(TILE_HARDENED_STONE, 0))
		world.set_cell(Vector2i(x, 1145), 0, Vector2i(TILE_HARDENED_STONE, 0))
		
	# 2. Spawn Boss
	var boss = spawn_boss_mega_spideroid()
	
	# 3. Dialog (Musik pelan mengiringi dialog)
	show_dialog("MEGA SPIDEROID: \"Do they really think a human can fight me?\"")
	await get_tree().create_timer(4.0).timeout
	show_dialog("MEGA SPIDEROID: \"Well then, show me your power before I devour you!\"")
	await get_tree().create_timer(4.0).timeout
	
	# 4. Mulai Pertarungan (Musik sudah masuk bagian berat)
	if is_instance_valid(boss):
		boss.set_meta("is_invulnerable", false)
		boss.set_meta("state", "phase1")
		boss.set_meta("atk_timer", 2.0)
		
	if is_instance_valid(boss_hp_ui):
		boss_hp_ui.visible = true

var _boss_loot_guard: bool = false

func give_boss_loot():
	if _boss_loot_guard: return
	_boss_loot_guard = true
	
	# --- FIX: MATIKAN LAGU BOS, NYALAKAN LAGU GUA ZONE 3 ---
	boss_silence_triggered = false
	current_music_zone = 3
	_play_layer_bgm(3, zone_bgm_times.get(3, 0.0))
	# -------------------------------------------------------
	
	# Set highest difficulty (untuk buka difficulty berikutnya)
	Global.highest_difficulty_cleared = max(Global.highest_difficulty_cleared, Global.current_difficulty)
	
	# --- TUTORIAL 3: BOSS DEFEATED ---
	if Global.tutorial3_step == 2:
		Global.tutorial3_step = 3
		
	# Update teks objective (dipanggil di luar if, biar Post-T3 juga berubah)
	update_objective_tutorial3()
	
	# Munculkan dialog HANYA saat T3 (tutorial_step == 8)
	if Global.tutorial_step == 8:
		show_dialog("The Mega Spideroid has been defeated! The path to the surface is open.")
	# ----------------------------------
	
	# --- GUARANTEE LOOT: GOLD + SCRAP (Scaling per Difficulty) ---
	var diff_mult = 1.0 + (Global.current_difficulty - 1) * 0.10
	var gold_amt = randi_range(int(80 * diff_mult), int(150 * diff_mult))
	var scrap_amt = randi_range(int(15 * diff_mult), int(25 * diff_mult))
	
	dungeon_gold += gold_amt
	tambah_item("Scrap", scrap_amt)
	show_floating_text("+" + str(gold_amt) + " Gold", $Player.global_position + Vector2(0, -30), Color.GOLD)
	show_floating_text("Scrap x" + str(scrap_amt), $Player.global_position + Vector2(0, -60), Color.LIGHT_GRAY)
	
	Global.save_game()
	# ----------------------------------
	
	# --- WEAPON DROP (force UUID baru, meski duplikat) ---
	var roll = randf()
	if roll < 0.25:
		tambah_item("Heavy Amethyst Armor", 1, true); show_floating_text("Rare Drop: Heavy Amethyst Armor!", $Player.global_position, Color.CYAN)
	elif roll < 0.40:
		tambah_item("Marble Slingshot", 1, true); show_floating_text("Epic Drop: Marble Slingshot!", $Player.global_position, Color.PURPLE)
	elif roll < 0.55:
		tambah_item("Explosive Crossbow", 1, true); show_floating_text("Epic Drop: Explosive Crossbow!", $Player.global_position, Color.PURPLE)
	elif roll < 0.70:
		tambah_item("Sharding Sword", 1, true); show_floating_text("Epic Drop: Sharding Sword!", $Player.global_position, Color.PURPLE)
	elif roll < 0.95:
		tambah_item("Swarmid Drill", 1, true); show_floating_text("Rare Drop: Swarmid Drill!", $Player.global_position, Color.CYAN)
	else:
		tambah_item("Galahad Chimelin", 1, true); show_floating_text("LEGENDARY DROP: Galahad Chimelin!", $Player.global_position, Color.GOLD)

func spawn_domains():
	if Global.tutorial_step < 8: return
	
	# Konfigurasi Domain per layer (20% chance masing-masing)
	var domain_configs = [
		{"y_min": 15, "y_max": 99, "name": "Domain of Tricks", "boss": "Powerful Goblin"},
		{"y_min": 100, "y_max": 199, "name": "Domain of Tricks", "boss": "Powerful Goblin"},
		{"y_min": 200, "y_max": 299, "name": "Domain of Brutality", "boss": "Powerful Cannibal"},
		{"y_min": 300, "y_max": 399, "name": "Domain of Brutality", "boss": "Powerful Cannibal"},
		{"y_min": 400, "y_max": 499, "name": "Domain of Precision", "boss": "Powerful Hunter"},
		{"y_min": 500, "y_max": 599, "name": "Domain of Precision", "boss": "Powerful Hunter"},
		{"y_min": 600, "y_max": 699, "name": "Domain of Believer", "boss": "Powerful Cult"},
		{"y_min": 700, "y_max": 799, "name": "Domain of Believer", "boss": "Powerful Cult"},
		{"y_min": 800, "y_max": 899, "name": "Domain of Cheap", "boss": "Powerful Spider"},
		{"y_min": 900, "y_max": 999, "name": "Domain of Cheap", "boss": "Powerful Spider"},
		{"y_min": 1000, "y_max": 1099, "name": "Domain of Power", "boss": "Powerful Cave Slime"},
		{"y_min": 1100, "y_max": 1199, "name": "Domain of Durability", "boss": "Powerful Crystal Golem"},
	]
	
	for idx in range(domain_configs.size()):
		var config = domain_configs[idx]
		
		# Semua domain 20% chance spawn (termasuk Layer 1)
		if randf() > 0.20: 
			continue
		
		var spawn_x = WORLD_WIDTH - 10
		var ry = randi_range(config.y_min, config.y_max)
		
		# Cari tanah di X=290 mulai dari Y=ry ke bawah
		var ground_y = ry
		while ground_y < WORLD_DEPTH - 2 and world.get_cell_source_id(Vector2i(spawn_x, ground_y)) == -1:
			ground_y += 1
		
		if ground_y >= WORLD_DEPTH - 2: continue
		
		# Karve alcove 7x6 di atas tanah (biar domain muat)
		for dy in range(6):
			var cy = ground_y - 1 - dy
			if cy < 1: continue
			for dx in range(-3, 4):
				var cx = spawn_x + dx
				if cx < 0 or cx >= WORLD_WIDTH: continue
				world.erase_cell(Vector2i(cx, cy))
		
		# Karve lorong 2-blok-tinggi ke kiri (30 blok) agar player bisa masuk
		for px in range(spawn_x - 30, spawn_x - 2):
			if px < 0: continue
			world.erase_cell(Vector2i(px, ground_y - 1))
			world.erase_cell(Vector2i(px, ground_y - 2))
		
		create_domain(Vector2i(spawn_x, ground_y - 1), config.name, config.boss, idx)
	
	# --- SPAWN LORE LOG 3 DI DOMAIN PALING ATAS ---
	if domains.size() > 0:
		var _highest_domain = null
		var _min_y = 99999
		for d in domains:
			if is_instance_valid(d):
				var d_y = world.local_to_map(world.to_local(d.global_position)).y
				if d_y < _min_y:
					_min_y = d_y
					_highest_domain = d
		
		if _highest_domain != null:
			# Taruh agak ke kiri dari pintu domain
			create_lore_log(3, _highest_domain.global_position + Vector2(-40, 0))
	print("Domains spawned: ", domains.size())


func create_domain(tile_pos: Vector2i, domain_name: String, boss_type: String, config_index: int):
	var domain = Node2D.new()
	domain.position = world.to_global(world.map_to_local(tile_pos))
	domain.z_index = -1
	domain.set_meta("is_domain", true)
	domain.set_meta("domain_name", domain_name)
	domain.set_meta("boss_type", boss_type)
	domain.set_meta("config_index", config_index)
	
	# Warna berdasarkan boss type (untuk diferensiasi visual sementara)
	var domain_colors = {
		"Powerful Goblin": Color(0.2, 0.5, 0.2),
		"Powerful Cannibal": Color(0.5, 0.1, 0.1),
		"Powerful Hunter": Color(0.4, 0.4, 0.1),
		"Powerful Cult": Color(0.3, 0.1, 0.4),
		"Powerful Spider": Color(0.3, 0.15, 0.1),
		"Powerful Cave Slime": Color(0.4, 0.25, 0.1),
		"Powerful Crystal Golem": Color(0.2, 0.4, 0.5),
	}
	var base_color = domain_colors.get(boss_type, Color(0.3, 0.05, 0.4))
	
	# Base/altar
	var base = ColorRect.new()
	base.size = Vector2(32, 48)
	base.position = Vector2(-16, -48)
	base.color = base_color
	domain.add_child(base)
	
	# Glowing orb di atas
	var orb = ColorRect.new()
	orb.size = Vector2(16, 16)
	orb.position = Vector2(-8, -80)
	orb.color = base_color.lightened(0.5)
	domain.add_child(orb)
	
	# Pulse animation
	var tween = create_tween().bind_node(domain).set_loops()
	tween.tween_property(orb, "modulate:a", 0.4, 0.8)
	tween.tween_property(orb, "modulate:a", 1.0, 0.8)
	
	# Label nama domain
	var text = Label.new()
	text.text = domain_name
	text.position = Vector2(-65, -105)
	text.add_theme_font_size_override("font_size", 11)
	text.add_theme_color_override("font_color", Color.GOLD)
	text.add_theme_color_override("font_outline_color", Color.BLACK)
	text.add_theme_constant_override("outline_size", 4)
	domain.add_child(text)
	
	# Glow light
	var light = PointLight2D.new()
	light.texture = bikin_tekstur_cahaya()
	light.color = base_color.lightened(0.3)
	light.energy = 1.5
	light.texture_scale = 3.0
	light.shadow_enabled = false
	light.position = Vector2(0, -30)
	domain.add_child(light)
	
	add_child(domain)
	domains.append(domain)
	
func spawn_mineshafts():
	if Global.tutorial_step < 8: return
	
	# Layer 4 (Y: 300-399) - Guaranteed
	create_mineshaft(Vector2i(randi_range(120, 180), randi_range(320, 370)))
	
	# Layer 7 (Y: 600-699) - Guaranteed
	create_mineshaft(Vector2i(randi_range(120, 180), randi_range(620, 670)))
	
	# Layer 8 (Y: 700-799) - Guaranteed
	create_mineshaft(Vector2i(randi_range(120, 180), randi_range(720, 770)))
	
	print("Mineshafts spawned: 3")


func create_mineshaft(center_tile: Vector2i):
	var shaft_w = 80
	var shaft_h = 26
	var start_x = center_tile.x - shaft_w / 2
	var start_y = center_tile.y - shaft_h / 2
	
	# --- 1. KARVE dengan NOISE biar natural (bukan kotak) ---
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.12
	noise.fractal_octaves = 3
	
	# Loop sedikit lebih besar dari shaft, tapi noise yang menentukan batas
	for x in range(start_x - 3, start_x + shaft_w + 3):
		for y in range(start_y - 3, start_y + shaft_h + 3):
			if x < 5 or x >= WORLD_WIDTH - 5: continue
			if y < 5 or y >= 1140: continue
			
			# Normalized distance dari center
			var nx = abs(x - center_tile.x) / float(shaft_w / 2.0)
			var ny = abs(y - center_tile.y) / float(shaft_h / 2.0)
			var dist = sqrt(nx * nx + ny * ny)
			
			# Noise untuk edges organik
			var n = noise.get_noise_2d(x * 3, y * 3) * 0.20
			
			if dist + n < 0.92:
				world.erase_cell(Vector2i(x, y))
	
	# --- 2. BRIDGES full-width (nyambung ke kiri & kanan) ---
	var bridge_ys = [start_y + 6, start_y + 13, start_y + 20]
	
	for by in bridge_ys:
		create_bridge_full(start_x + 3, start_x + shaft_w - 3, by)
	
	# --- 3. ORE CHEST (duduk TEPAT di jembatan, bukan ngambang) ---
	create_ore_chest(Vector2i(center_tile.x, bridge_ys[1]))
	
	# 4. Ore Chest bonus
	var bonus_bridge = 0 if randf() < 0.5 else 2
	var bonus_x = center_tile.x + randi_range(-15, 15)
	create_ore_chest(Vector2i(bonus_x, bridge_ys[bonus_bridge]))
	
	# --- SPAWN LORE LOGS DI MINESHAFT ---
	var _lore_x = center_tile.x + randi_range(-10, 10)
	if center_tile.y >= 300 and center_tile.y < 400:
		# Mineshaft Layer 4 (Log 1)
		create_lore_log(1, world.to_global(world.map_to_local(Vector2i(_lore_x, bridge_ys[0]))))
	elif center_tile.y >= 600 and center_tile.y < 700:
		# Mineshaft Layer 7 (Log 2)
		create_lore_log(2, world.to_global(world.map_to_local(Vector2i(_lore_x, bridge_ys[2]))))

func create_bridge_full(start_x_tile: int, end_x_tile: int, y_tile: int):
	var bridge = Node2D.new()
	bridge.position = world.to_global(world.map_to_local(Vector2i(start_x_tile, y_tile)))
	bridge.z_index = -1
	
	var length_px = (end_x_tile - start_x_tile) * BLOCK_SIZE
	
	# Visual kayu utama
	var visual = ColorRect.new()
	visual.size = Vector2(length_px, 10)
	visual.color = Color(0.45, 0.28, 0.15)
	bridge.add_child(visual)
	
	# Papan vertikal (garis-garis)
	for i in range(0, end_x_tile - start_x_tile, 2):
		var plank = ColorRect.new()
		plank.size = Vector2(3, 10)
		plank.position = Vector2(i * BLOCK_SIZE, 0)
		plank.color = Color(0.3, 0.18, 0.1)
		bridge.add_child(plank)
	
	# Tali pengikat di atas
	for i in range(0, end_x_tile - start_x_tile, 6):
		var rope = ColorRect.new()
		rope.size = Vector2(2, 4)
		rope.position = Vector2(i * BLOCK_SIZE, -3)
		rope.color = Color(0.6, 0.4, 0.2)
		bridge.add_child(rope)
	
	# Tiang penyangga (dari jembatan turun ke bawah)
	for i in range(8, end_x_tile - start_x_tile, 12):
		var support = ColorRect.new()
		support.size = Vector2(5, 80)
		support.position = Vector2(i * BLOCK_SIZE - 2, 10)
		support.color = Color(0.35, 0.2, 0.1)
		bridge.add_child(support)
	
	# Collision (ONE-WAY: bisa loncat dari bawah, mendarat dari atas)
	var col_body = StaticBody2D.new()
	col_body.collision_layer = 1
	col_body.collision_mask = 0
	var col_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(length_px, 10)
	col_shape.shape = rect
	col_shape.position = Vector2(length_px / 2, 5)
	col_shape.one_way_collision = true
	col_shape.one_way_collision_margin = 12.0
	col_body.add_child(col_shape)
	bridge.add_child(col_body)
	bridge_bodies.append(col_body)
	
	add_child(bridge)

func create_ore_chest(tile_pos: Vector2i):
	var chest = Node2D.new()
	chest.position = world.to_global(world.map_to_local(tile_pos))
	chest.z_index = -1
	chest.set_meta("is_ore_chest", true)
	
	# Visual - warna biru cyan biar beda dari chest biasa
	var box = ColorRect.new()
	box.size = Vector2(28, 28)
	box.position = Vector2(-14, -28)
	box.color = Color(0.2, 0.7, 0.9)
	chest.add_child(box)
	
	# Glow light
	var light = PointLight2D.new()
	light.texture = bikin_tekstur_cahaya()
	light.color = Color(0.2, 0.8, 1.0)
	light.energy = 1.0
	light.texture_scale = 1.5
	light.shadow_enabled = false
	light.position = Vector2(0, -15)
	chest.add_child(light)
	
	# Label
	var text = Label.new()
	text.text = "ORE CHEST"
	text.position = Vector2(-35, -52)
	text.add_theme_font_size_override("font_size", 10)
	text.add_theme_color_override("font_color", Color.CYAN)
	text.add_theme_color_override("font_outline_color", Color.BLACK)
	text.add_theme_constant_override("outline_size", 3)
	chest.add_child(text)
	
	add_child(chest)
	chests.append(chest)

func enter_domain(domain_node: Node2D) -> void:
	var dom_scene = null
	
	if saved_domains.has(domain_node) and is_instance_valid(saved_domains[domain_node]):
		dom_scene = saved_domains[domain_node]
		dom_scene.visible = true
		dom_scene.process_mode = Node.PROCESS_MODE_ALWAYS
		
		# Munculkan UI Domain
		for child in dom_scene.get_children():
			if child is CanvasLayer: child.visible = true
			
		dom_scene.setup_fresh_session(inventory.duplicate())
		dom_scene.force_camera()
	else:
		var DomainScript = preload("res://domain/domain.gd")
		dom_scene = Node2D.new()
		dom_scene.set_script(DomainScript)
		
		dom_scene.setup(
			domain_node.get_meta("config_index", -1),
			str(domain_node.get_meta("domain_name", "Unknown Domain")),
			str(domain_node.get_meta("boss_type", "Unknown Boss")),
			self,
			inventory.duplicate()
		)
		
		get_tree().root.add_child(dom_scene)
		dom_scene.domain_closed.connect(_on_domain_closed.bind(domain_node, dom_scene))
		saved_domains[domain_node] = dom_scene
	
	$Player.visible = false
	$Player.set_physics_process(false)
	
	# --- MATIKAN COLLISION PLAYER ASLI ---
	$Player.collision_layer = 0
	$Player.collision_mask = 0
	# -------------------------------------
	
	canvas_mod.color = Color(1, 1, 1)
	# Matikan collision DUNGEON saja (biar gak ada invisible wall)
	$World.collision_enabled = false
	$Walls.collision_enabled = false
	set_process_input(false)
	set_process(false)
	visible = false
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_DISABLED 

	for child in get_children():
		if child is CanvasLayer:
			child.visible = false
			
func _on_domain_closed(completed: bool, final_hp: int, final_mana: float, domain_node: Node2D, dom_scene: Node2D) -> void:
	current_hp = max(final_hp, 1)
	current_mana = final_mana
	update_hp_ui()
	update_exp_ui()
	
	if completed:
		show_floating_text("Domain Cleared!", $Player.global_position, Color.GOLD)
		if is_instance_valid(domain_node):
			domains.erase(domain_node)
			domain_node.queue_free()
		saved_domains.erase(domain_node)
		if is_instance_valid(dom_scene):
			dom_scene.queue_free()
	else:
		# Sembunyikan domain
		if is_instance_valid(dom_scene):
			dom_scene.visible = false
			dom_scene.process_mode = Node.PROCESS_MODE_DISABLED
			for child in dom_scene.get_children():
				if child is CanvasLayer:
					child.visible = false
		
	# 1. Munculkan Player & Nyalakan Fisikanya
	$Player.visible = true
	$Player.set_physics_process(true)
	
	# --- NYALAKAN KEMBALI COLLISION PLAYER ASLI ---
	$Player.collision_layer = 1
	$Player.collision_mask = 1
	# ----------------------------------------------
	
	# 2. Nyalakan Kembali Collision Dungeon
	$World.collision_enabled = true
	$Walls.collision_enabled = true
	
	# 3. Ambil Alih Kamera & Nyalakan Modulate
	$Player/Camera2D.make_current() 
	
	if $Player.global_position.y < 8:
		canvas_mod.color = Color(1, 1, 1)
	else:
		canvas_mod.color = Color(0.1, 0.1, 0.15)
	
	# 4. Nyalakan Kembali Proses Game
	visible = true
	set_process_input(true)
	set_process(true)
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT 

	# 5. Munculkan UI Main
	for child in get_children():
		if child is CanvasLayer:
			child.visible = true
			
	if lives <= 0 and not is_dead:
		die()
	
	# --- FIX BGM NYANGKUT SAAT KELUAR DOMAIN ---
	var p_tile = world.local_to_map(world.to_local($Player.global_position))
	if p_tile.y <= 300: current_music_zone = 0
	elif p_tile.y <= 600: current_music_zone = 1
	elif p_tile.y <= 900: current_music_zone = 2
	else: current_music_zone = 3
	
	_play_layer_bgm(current_music_zone, zone_bgm_times[current_music_zone])
	# --------------------------------------------

func trigger_crossbow_explosion(pos: Vector2, damage: int):
	var radius = 64.0  # 4 tiles
	var aoe_rect = Rect2(pos - Vector2(radius, radius), Vector2(radius * 2, radius * 2))
	
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy): continue
		var sz = enemy.get_meta("size", 16.0)
		var e_rect = Rect2(enemy.global_position - Vector2(sz/2, sz/2), Vector2(sz, sz))
		if aoe_rect.intersects(e_rect):
			var new_hp = enemy.get_meta("hp") - damage
			enemy.set_meta("hp", new_hp)
			update_enemy_hp_bar(enemy)
			show_floating_text(str(damage), enemy.global_position + Vector2(0, -40), Color.ORANGE)
			if new_hp <= 0:
				gain_exp(enemy.get_meta("exp"))
				drop_loot(enemy.get_meta("type"))
				if is_tutorial_active and enemy.get_meta("type") == "goblin":
					tutorial_stats["goblins_killed"] += 1
					check_objective_progress()
				if enemy.get_meta("type") == "boss_spider":
					spawn_final_lift()
					give_boss_loot()
					if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
				enemies.erase(enemy)
				enemy.queue_free()
	
	var exp = ColorRect.new()
	exp.size = Vector2(radius * 2, radius * 2)
	exp.position = pos - Vector2(radius, radius)
	exp.color = Color(1.0, 0.5, 0.0, 0.8)
	exp.z_index = 15
	add_child(exp)
	var t = create_tween()
	t.tween_property(exp, "scale", Vector2(1.5, 1.5), 0.2)
	t.tween_property(exp, "modulate:a", 0.0, 0.2)
	t.tween_callback(exp.queue_free)

func _track_revenger_attacker(attacker):
	if Global.hotbar_items[selected_hotbar_index] != "Revenger Crystallinum": return
	if not is_instance_valid(attacker): return
	if revenger_target == attacker:
		revenger_stacks = min(revenger_stacks + 1, 3)
	else:
		revenger_target = attacker
		revenger_stacks = 1
	revenger_timer = 5.0
	show_floating_text("Revenge +" + str(revenger_stacks * 30) + "%", $Player.global_position + Vector2(0, -100), Color.RED)

func _try_drop_hammer_ore(enemy):
	if Global.hotbar_items[selected_hotbar_index] != "Crystal Hammer": return
	if randf() >= 0.35: return
	var _ores = ["Copper", "Iron", "Silver", "Gold", "Mithril", "Quartz", "Topaz", "Emerald", "Diamond", "Amethyst", "Uberilium"]
	var _drop = _ores.pick_random()
	tambah_item(_drop)
	show_floating_text("+" + _drop, enemy.global_position + Vector2(0, -60), Color.GOLD)

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
			var _hp = _e.get_meta("hp") - dmg
			_e.set_meta("hp", _hp)
			update_enemy_hp_bar(_e)
			show_floating_text(str(dmg), _e.global_position + Vector2(0, -40), Color.MAGENTA)
			if _hp <= 0:
				if _e.has_meta("exp"):
					gain_exp(_e.get_meta("exp"))
				drop_loot(_e.get_meta("type"))
				if _e.get_meta("type") == "boss_spider":
					spawn_final_lift()
					give_boss_loot()
					if is_instance_valid(boss_hp_ui): boss_hp_ui.visible = false
				enemies.erase(_e)
				_e.queue_free()
	
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

func create_lore_log(id: int, pos: Vector2):
	var log_node = Node2D.new()
	log_node.position = pos
	log_node.z_index = 1
	log_node.set_meta("lore_id", id)
	
	# Visual: Papan Kayu
	var board = ColorRect.new()
	board.size = Vector2(24, 32)
	board.position = Vector2(-12, -32)
	board.color = Color(0.4, 0.2, 0.1)
	log_node.add_child(board)
	
	# Visual: Kertas
	var paper = ColorRect.new()
	paper.size = Vector2(18, 24)
	paper.position = Vector2(-9, -28)
	paper.color = Color(0.9, 0.9, 0.85)
	log_node.add_child(paper)
	
	# Teks "!" biar player tahu bisa di-klik
	var icon = Label.new()
	icon.text = "!"
	icon.position = Vector2(-3, -28)
	icon.add_theme_color_override("font_color", Color.RED)
	icon.add_theme_font_size_override("font_size", 16)
	log_node.add_child(icon)
	
	add_child(log_node)
	lore_logs.append(log_node)

func read_lore_log(id: int):
	var text = ""
	match id:
		1:
			text = "Note:\n\"I don't know why, but the deeper I dig, the more I feel something is terribly wrong. I feel the condition of this cave is abnormal, different from the normal caves I used to know.\""
		2:
			text = "Note:\n\"What am I seeing? Why have they all turned into terrifying monsters? It seems I am the one who will become a monster after this...\""
		3:
			text = "Note:\n\"Everything has changed and I see a magical door appearing out of nowhere. For the sake of my safety, I'd better go inside, maybe everything will be much safer in here.\""
	show_dialog(text)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.saved_inventory = inventory.duplicate()
		Global.hotbar_items = hotbar_items.duplicate()
		Global.wipe_dungeon_fail()  # ← Wipe backpack + hotbar 3-6, simpan equipment
		get_tree().quit()

func _safe_knockback(target, direction: float, distance: float):
	if not is_instance_valid(target): return
	if target.is_queued_for_deletion(): return
	var _motion = Vector2(direction * distance, 0)
	if target is CharacterBody2D:
		target.move_and_collide(_motion)
	else:
		target.global_position += _motion

func bikin_ui_pause_main():
	var canvas = CanvasLayer.new()
	canvas.layer = 200
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	
	var vp = get_viewport().get_visible_rect().size 
	
	# 1. BLOCKER (Layar Gelap)
	pause_blocker_main = ColorRect.new()
	pause_blocker_main.color = Color(0, 0, 0, 0.7)
	pause_blocker_main.size = vp
	pause_blocker_main.visible = false
	canvas.add_child(pause_blocker_main)
	
	# 2. PANEL PAUSE UTAMA
	pause_panel_main = Panel.new()
	pause_panel_main.size = Vector2(600, 500)
	pause_panel_main.position = Vector2(vp.x/2 - 300, vp.y/2 - 250)
	pause_panel_main.visible = false
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.08, 0.08, 0.1, 0.98) # Gelap kebiruan
	p_style.border_width_left = 3; p_style.border_width_top = 3; p_style.border_width_right = 3; p_style.border_width_bottom = 3
	p_style.border_color = Color.GOLD
	pause_panel_main.add_theme_stylebox_override("panel", p_style)
	canvas.add_child(pause_panel_main)
	
	# Judul Pause
	var p_title = Label.new()
	p_title.text = "PAUSED"
	p_title.position = Vector2(0, 40); p_title.size = Vector2(600, 60)
	p_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p_title.add_theme_font_size_override("font_size", 48)
	p_title.add_theme_color_override("font_color", Color.GOLD)
	pause_panel_main.add_child(p_title)
	
	# Tombol Continue (posisi tetap)
	var b_cont = Button.new()
	b_cont.text = "CONTINUE"
	b_cont.position = Vector2(150, 140); b_cont.size = Vector2(300, 60)
	b_cont.add_theme_font_size_override("font_size", 28)
	b_cont.pressed.connect(func():
		is_pause_main_open = false
		pause_panel_main.visible = false
		pause_blocker_main.visible = false
		get_tree().paused = false
		$Player.set_physics_process(true)
	)
	pause_panel_main.add_child(b_cont)
	Sfx.attach(b_cont)

	# ✅ TAMBAHAN: Tombol Settings
	var b_set = Button.new()
	b_set.text = "SETTINGS (Coming Soon)"
	b_set.position = Vector2(150, 215); b_set.size = Vector2(300, 60)
	b_set.add_theme_font_size_override("font_size", 24)
	b_set.disabled = true
	pause_panel_main.add_child(b_set)
	Sfx.attach(b_set)

	# Tombol Abort (SHIFT dari 230 → 290 biar tidak overlap)
	var b_abort = Button.new()
	b_abort.text = "ABORT MISSION"
	b_abort.position = Vector2(150, 290); b_abort.size = Vector2(300, 60)
	b_abort.add_theme_font_size_override("font_size", 24)
	b_abort.pressed.connect(func():
		abort_blocker.visible = true
		abort_confirm_panel.visible = true
	)
	pause_panel_main.add_child(b_abort)
	Sfx.attach(b_abort)
	
	# --- PANEL KONFIRMASI ABORT ---
	abort_blocker = ColorRect.new()
	abort_blocker.color = Color(0, 0, 0, 0.8)
	abort_blocker.size = vp
	abort_blocker.visible = false
	canvas.add_child(abort_blocker)
	
	abort_confirm_panel = Panel.new()
	abort_confirm_panel.size = Vector2(600, 250)
	abort_confirm_panel.position = Vector2(vp.x/2 - 300, vp.y/2 - 125)
	abort_confirm_panel.visible = false
	var a_style = StyleBoxFlat.new()
	a_style.bg_color = Color(0.15, 0.05, 0.05, 0.98)
	a_style.border_width_left = 3; a_style.border_width_top = 3; a_style.border_width_right = 3; a_style.border_width_bottom = 3
	a_style.border_color = Color.RED
	abort_confirm_panel.add_theme_stylebox_override("panel", a_style)
	canvas.add_child(abort_confirm_panel)
	
	var a_title = Label.new()
	a_title.text = "ABORT MISSION"
	a_title.position = Vector2(0, 20); a_title.size = Vector2(600, 40)
	a_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	a_title.add_theme_font_size_override("font_size", 32)
	a_title.add_theme_color_override("font_color", Color.RED)
	abort_confirm_panel.add_child(a_title)
	
	var a_lbl = Label.new()
	a_lbl.text = "Are you sure want to abort this mission?\nThe rest of the items in your backpack will gone."
	a_lbl.position = Vector2(20, 70); a_lbl.size = Vector2(560, 60)
	a_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	a_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	a_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	a_lbl.add_theme_font_size_override("font_size", 20)
	abort_confirm_panel.add_child(a_lbl)
	
	var b_yes = Button.new()
	b_yes.text = "YES"
	b_yes.position = Vector2(150, 160); b_yes.size = Vector2(140, 50)
	b_yes.add_theme_font_size_override("font_size", 24)
	b_yes.pressed.connect(func():
		get_tree().paused = false
		Global.wipe_dungeon_fail()
		get_tree().change_scene_to_file("res://home.tscn")
	)
	abort_confirm_panel.add_child(b_yes)
	Sfx.attach(b_yes)
	
	var b_no = Button.new()
	b_no.text = "NO"
	b_no.position = Vector2(310, 160); b_no.size = Vector2(140, 50)
	b_no.add_theme_font_size_override("font_size", 24)
	b_no.pressed.connect(func():
		abort_blocker.visible = false
		abort_confirm_panel.visible = false
	)
	abort_confirm_panel.add_child(b_no)
	Sfx.attach(b_no)

func _close_pause_main():
	is_pause_main_open = false
	pause_panel_main.visible = false
	pause_blocker_main.visible = false
	get_tree().paused = false
	$Player.set_physics_process(true)

func _change_hotbar_slot(direction: int):
	var _new_idx = selected_hotbar_index + direction
	if _new_idx < 0: _new_idx = 6
	elif _new_idx > 6: _new_idx = 0
	
	if _new_idx == selected_hotbar_index: return
	
	selected_hotbar_index = _new_idx
	
	attack_cooldown = 0.0
	sword_combo = 0
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
	update_crafting_ui()

func _play_layer_bgm(zone: int, start_time: float = 0.0):
	var path = ""
	match zone:
		0: path = "res://audio/bgm_caverns_zone1.mp3" # Surface & Layer 1-3
		1: path = "res://audio/bgm_caverns_zone2.mp3" # Layer 4-6
		2: path = "res://audio/bgm_caverns_zone3.mp3" # Layer 7-9
		3: path = "res://audio/bgm_caverns_zone4.mp3" # Layer 10-12
	
	if path != "":
		MusicManager.play_bgm(path, start_time)
