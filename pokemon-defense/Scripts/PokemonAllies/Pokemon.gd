extends StaticBody2D

@export var my_id: PkmnID.Name 
var stats: PokemonData
var health: int
var projectile_scene = preload("res://Scenes/Pokemons/Projectile.tscn")

#--Set Up--

#Start
func _ready():
	var library = preload("res://Data/Pokemons/MasterLibrary.tres")
	if library.database.has(my_id):
		stats = library.database[my_id]
		setup_pokemon()
		
	$ShootTimer.timeout.connect(_on_action_timeout)

#Set parameters
func setup_pokemon():
	$Sprite2D.texture = stats.sprite
	$ShootTimer.wait_time = stats.action_rate
	health = stats.health
	
	if stats.pkmn_type == PokemonData.Type.ATTACK:
		$LineDetector.target_position.x = stats.range_tiles * 128
		$LineDetector.enabled = true
	else:
		$LineDetector.enabled = false
		# Les producteurs lancent leur chrono immédiatement
		if stats.pkmn_type == PokemonData.Type.PRODUCE:
			$ShootTimer.start()

#--Attacks--

#Attack enemies
func _process(_delta):
	if stats.pkmn_type == PokemonData.Type.ATTACK:
		if $LineDetector.is_colliding():
			if $ShootTimer.is_stopped():
				$ShootTimer.start()

#Speed attack enemies
func _on_action_timeout():
	if stats.pkmn_type == PokemonData.Type.ATTACK:
		if $LineDetector.is_colliding():
			spawn_projectile()
			$ShootTimer.start()
			
	elif stats.pkmn_type == PokemonData.Type.PRODUCE:
		spawn_energy()
		$ShootTimer.start()

#--Damage

#Receive damage
func take_damage(amount):
	health -= amount
	flash_hit()
	if health <= 0:
		queue_free()

#Animation damage
func flash_hit():
	var tween = create_tween()
	$Sprite2D.modulate = Color(1, 0, 0)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)

#--Projectiles--

#Projectiles attack spawn
func spawn_projectile():
	var proj = projectile_scene.instantiate()
	proj.setup(stats.proj_sprite, stats.proj_speed, stats.primary_value)
	get_tree().current_scene.get_node("Projectiles").add_child(proj)
	proj.global_position = global_position

#Projectiles energy spawn
func spawn_energy():
	var energy_item = projectile_scene.instantiate()
	energy_item.global_position = global_position 
	get_tree().current_scene.get_node("Projectiles").add_child(energy_item)
	energy_item.setup(stats.proj_sprite, 0, stats.primary_value, true)

#--Pokeball return--

#Animation
func capture_animation():
	set_process(false)
	
	if has_node("ShootTimer"):
		$ShootTimer.stop()
	
	var tween = create_tween()
	
	tween.tween_property(self, "modulate", Color(1, 0, 0), 0.2)
	
	tween.tween_interval(0.8)
	
	tween.tween_property(self, "modulate:a", 0, 0.2)
	tween.tween_callback(queue_free)
