extends Resource
class_name EnemyData

@export_group("Identity")
@export var pkmn_id: PkmnID.Name
@export var sprite: Texture2D
@export var is_boss: bool = false

@export_group("Stats")
@export var health: int = 50
@export var speed: float = 50.0
@export var attack_damage: float = 5.0
