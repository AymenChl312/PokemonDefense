extends Resource
class_name PokemonData

enum Type { ATTACK, PRODUCE, DEFEND }

@export_group("Identity")
@export var pkmn_type: Type = Type.ATTACK
@export var pkmn_name: PkmnID.Name
@export var sprite: Texture2D
@export var pkmn_name_string: String = ""

@export_group("Stats")
@export var health: int = 100
@export var primary_value: float = 20.0 
@export var action_rate: float = 1.5   
@export var range_tiles: int = 9 
@export var cost: int = 50

@export_group("Visuals")
@export var proj_sprite: Texture2D
@export var proj_speed: float = 400.0
