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
		
	$ShootTimer.timeout.connect(_on_action_timeout)

func setup_pokemon():
	$Sprite2D.texture = stats.sprite
	$ShootTimer.wait_time = stats.action_rate
	health = stats.health
	
	if stats.pkmn_type == PokemonData.Type.ATTACK:
		$LineDetector.target_position.x = stats.range_tiles * 64
		$LineDetector.enabled = true
	else:
		$LineDetector.enabled = false
		# Les producteurs lancent leur chrono immédiatement
		if stats.pkmn_type == PokemonData.Type.PRODUCE:
			$ShootTimer.start()

func _process(_delta):
	if stats.pkmn_type == PokemonData.Type.ATTACK:
		if $LineDetector.is_colliding():
			if $ShootTimer.is_stopped():
				$ShootTimer.start()

func _on_action_timeout():
	if stats.pkmn_type == PokemonData.Type.ATTACK:
		if $LineDetector.is_colliding():
			spawn_projectile()
			$ShootTimer.start()
			
	elif stats.pkmn_type == PokemonData.Type.PRODUCE:
		spawn_energy()
		$ShootTimer.start()

func spawn_projectile():
	var proj = projectile_scene.instantiate()
	proj.setup(stats.proj_sprite, stats.proj_speed, stats.primary_value)
	get_tree().current_scene.get_node("Projectiles").add_child(proj)
	proj.global_position = global_position

func spawn_energy():
	var energy_item = projectile_scene.instantiate()
	energy_item.global_position = global_position 
	get_tree().current_scene.get_node("Projectiles").add_child(energy_item)
	energy_item.setup(stats.proj_sprite, 0, stats.primary_value, true)

func take_damage(amount):
	health -= amount
	flash_hit()
	if health <= 0:
		queue_free()

func flash_hit():
	var tween = create_tween()
	$Sprite2D.modulate = Color(1, 0, 0)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
