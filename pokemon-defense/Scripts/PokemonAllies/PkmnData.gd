extends Resource
class_name PokemonData

@export_group("Identity")
@export var pkmn_name: PkmnID.Name
@export var sprite: Texture2D
@export var pkmn_name_string: String = ""

@export_group("Stats")
@export var health: int = 100
@export var damage: int = 20
@export var attack_speed: float = 1.5
@export var range_tiles: int = 9
@export var cost: int = 50

@export_group("Projectile")
@export var proj_sprite: Texture2D
@export var proj_speed: float = 400.0
