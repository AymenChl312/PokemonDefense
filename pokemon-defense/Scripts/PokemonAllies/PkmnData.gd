extends Resource
class_name PokemonData

enum Type { ATTACK, PRODUCE, DEFEND, EXPLODE }
enum AttackMode { PROJECTILE, BREATH, AREA }

@export_group("Identity")
@export var pkmn_type: Type = Type.ATTACK
@export var pkmn_name: PkmnID.Name
@export var sprite: Texture2D
@export var icon_sprite: Texture2D
@export var pkmn_name_string: String = ""
@export var pkmn_description: String = ""
@export var evolution_id: PkmnID.Name = PkmnID.Name.NONE
@export var is_buyable: bool = true

@export_group("Stats")
@export var health: int = 100
@export var primary_value: float = 20.0
@export var secondary_value: float = 10.0
@export var action_rate: float = 1.5
@export var range_tiles: int = 9
@export var cost: int = 50
@export var cooldown: float = 5.0

@export_group("Abilities & Projectiles")
@export var attack_mode: AttackMode = AttackMode.PROJECTILE
@export var proj_sprite: Texture2D
@export var proj_speed: float = 400.0
@export var projectile_count: int = 1
@export var multi_lane: bool = false
@export var is_slow: bool = false
@export var shoots_backward: bool = false
