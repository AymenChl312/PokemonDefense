extends StaticBody2D

@export var my_id: PkmnID.Name 
var stats: PokemonData
var health: int
var projectile_scene = preload("res://Scenes/Pokemons/Projectile.tscn")

func _ready():
	var library = preload("res://Data/Pokemons/MasterLibrary.tres")
	if library.database.has(my_id):
		stats = library.database[my_id]
		setup_pokemon()
		
	$ShootTimer.timeout.connect(_on_shoot_timer_timeout)

func setup_pokemon():
	$Sprite2D.texture = stats.sprite
	$ShootTimer.wait_time = stats.attack_speed
	$LineDetector.target_position.x = stats.range_tiles * 64
	health = stats.health

func _process(_delta):
	if $LineDetector.is_colliding():
		if $ShootTimer.is_stopped():
			$ShootTimer.start()

func take_damage(amount):
	health -= amount
	flash_hit()
	if health <= 0:
		queue_free()

func _on_shoot_timer_timeout():
	if $LineDetector.is_colliding():
		var proj = projectile_scene.instantiate()
		proj.setup(stats.proj_sprite, stats.proj_speed, stats.damage)
		get_tree().current_scene.get_node("Projectiles").add_child(proj)
		proj.global_position = global_position
		
		$ShootTimer.start()

func flash_hit():
	var tween = create_tween()
	$Sprite2D.modulate = Color(1, 0, 0)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
