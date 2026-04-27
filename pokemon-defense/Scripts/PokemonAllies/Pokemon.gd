extends StaticBody2D 

@export var my_id: PkmnID.Name 
var stats: PokemonData 
var health: int 
var projectile_scene = preload("res://Scenes/Pokemons/Projectile.tscn") 
var _is_capturing: bool = false
var _is_evolving: bool = false

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
	
	match stats.pkmn_type:
		PokemonData.Type.ATTACK:
			$LineDetector.target_position.x = stats.range_tiles * 128 
			$LineDetector.enabled = true 
		PokemonData.Type.EXPLODE:
			$LineDetector.target_position.x = 64 
			$LineDetector.enabled = true
		PokemonData.Type.DEFEND:
			$LineDetector.enabled = false
		PokemonData.Type.PRODUCE:
			$LineDetector.enabled = false 
			$ShootTimer.start() 

#--Attacks-- 

#Attack enemies 
func _process(_delta): 
	if _is_capturing or _is_evolving: return
	
	if stats.pkmn_type == PokemonData.Type.ATTACK or stats.pkmn_type == PokemonData.Type.EXPLODE: 
		if $LineDetector.is_colliding(): 
			var target = $LineDetector.get_collider()
			
			if target and target.is_in_group("Enemies"):
				var grid = get_tree().current_scene.get_node("Grid")
				var enemy_tile = grid.local_to_map(grid.to_local(target.global_position))
				if enemy_tile.x <= 15:
					if $ShootTimer.is_stopped(): 
						$ShootTimer.start() 
					return
		if stats.pkmn_type != PokemonData.Type.PRODUCE:
			$ShootTimer.stop()

#Speed attack enemies 
func _on_action_timeout(): 
	if stats.pkmn_type == PokemonData.Type.ATTACK: 
		handle_attack_logic()
		$ShootTimer.start() 
	elif stats.pkmn_type == PokemonData.Type.PRODUCE: 
		spawn_energy()
		$ShootTimer.start() 
	elif stats.pkmn_type == PokemonData.Type.EXPLODE:
		explode()

# Projectiles logic
func handle_attack_logic():
	if not $LineDetector.is_colliding(): return
	
	#Breath mode
	if stats.attack_mode == PokemonData.AttackMode.BREATH:
		spawn_breath()
		return

	#Multi shoot (File indienne / Horizontale)
	for i in range(stats.projectile_count):
		spawn_projectile(Vector2.ZERO, 1, stats.primary_value)
		# Petit délai si plusieurs projectiles pour qu'ils ne se chevauchent pas
		if stats.projectile_count > 1:
			await get_tree().create_timer(0.15).timeout
	
	#Multi lane
	if stats.multi_lane:
		spawn_projectile(Vector2(0, -128))
		spawn_projectile(Vector2(0, 128))
	
	#Backwards
	if stats.shoots_backward:
		# Utilise secondary_value pour les dégâts vers l'arrière
		spawn_projectile(Vector2.ZERO, -1, stats.secondary_value)

#Breath attacks
func spawn_breath():
	var proj = projectile_scene.instantiate()
	var offset_x = stats.range_tiles * 64
	
	proj.setup(stats.proj_sprite, 0, stats.primary_value)
	
	#--- CORRECTION ICI ---
	# On ajoute d'abord à la scène pour que get_tree() ne soit pas nul
	get_tree().current_scene.get_node("Projectiles").add_child(proj)
	proj.global_position = global_position + Vector2(offset_x, 0)

	# PUIS on active le mode souffle
	if proj.has_method("set_as_breath"):
		proj.set_as_breath(0.8)

#--Damage 

#Receive damage 
func receive_damage(amount): 
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
func spawn_projectile(offset = Vector2.ZERO, direction = 1, p_damage = 0.0): 
	var proj = projectile_scene.instantiate() 
	var final_damage = p_damage if p_damage > 0 else stats.primary_value
	
	proj.setup(stats.proj_sprite, stats.proj_speed * direction, final_damage) 
	
	if proj.has_method("set_slow_effect"):
		proj.set_slow_effect(stats.is_slow, stats.secondary_value)
		
	get_tree().current_scene.get_node("Projectiles").add_child(proj) 
	proj.global_position = global_position + offset

#Projectiles energy spawn 
func spawn_energy():
	var energy_item = projectile_scene.instantiate()
	energy_item.global_position = global_position
	get_tree().current_scene.get_node("Projectiles").add_child(energy_item)
	energy_item.setup(stats.proj_sprite, 0, stats.primary_value, true)

#--Explosion--

func explode():
	var explosion_radius = stats.range_tiles * 128
	var enemies = get_tree().get_nodes_in_group("Enemies")
	
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) <= explosion_radius:
			if enemy.has_method("receive_damage"):
				enemy.receive_damage(stats.primary_value)
	queue_free()

#--Pokeball return-- 

#Animation 
func capture_animation(): 
	_is_capturing = true
	set_process(false) 
	
	if has_node("ShootTimer"): 
		$ShootTimer.stop() 
	
	var tween = create_tween() 
	tween.tween_property(self, "modulate", Color(1, 0, 0), 0.2) 
	tween.tween_interval(0.8) 
	tween.tween_property(self, "modulate:a", 0, 0.2) 
	tween.tween_callback(queue_free)

#--Evolution

#Evolution animation
func play_evolution_glow():
	_is_evolving = true
	set_process(false)
	$ShootTimer.stop() 
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(10, 10, 10), 1.0)
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 1.0)
	
	await tween.finished
