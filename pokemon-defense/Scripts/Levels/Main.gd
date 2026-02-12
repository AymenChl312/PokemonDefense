extends Node2D

# --- EXPORTS ---
@export var current_level: LevelData

# --- PRELOADS ---
var pokemon_base_scene = preload("res://Scenes/Pokemons/Pokemon.tscn")
var enemy_scene = preload("res://Scenes/Pokemons/EnemyPokemon.tscn")
var pkmn_button_scene = preload("res://Scenes/Levels/PokemonButton.tscn")
var projectile_scene = preload("res://Scenes/Pokemons/Projectile.tscn")
var mower_scene = preload("res://Scenes/Levels/Mower.tscn")

# Libraries
var master_library = preload("res://Data/Pokemons/MasterLibrary.tres")
var enemy_library = preload("res://Data/Pokemons/EnemyLibrary.tres")

# Parameters
var energy = 100
var occupied_cells = {} 
var selected_id = PkmnID.Name.NONE
const POKEBALL_ID = -2

#-- Set Up --

#Start
func _ready():
	
	$UI/PokemonPreview.visible = false
	$LosingZone.area_entered.connect(_on_losing_zone_area_entered)
	
	if current_level:
		$SpawnTimer.wait_time = current_level.level_start_time
		$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
		$SpawnTimer.start()
	
	generate_buttons()
	spawn_mowers()
	setup_natural_energy_timer()
	update_ui()

#Update
func update_ui():
	$UI/EnergyLabel.text = "PP: " + str(energy)
	check_buttons_affordability()


#--Pokemon Allies--

#See Pokemon on tile before placing
func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var local_mouse_pos = $Grid.to_local(mouse_pos)
	var map_pos = $Grid.local_to_map(local_mouse_pos)

	if is_valid_cell(map_pos):
		var tile_center_local = $Grid.map_to_local(map_pos)
		var tile_center_global = $Grid.to_global(tile_center_local)
		
		$HoverHighlight.visible = true
		$HoverHighlight.global_position = tile_center_global
		
		if selected_id != PkmnID.Name.NONE:
			$UI/PokemonPreview.visible = true
			$UI/PokemonPreview.global_position = tile_center_global
		else:
			$UI/PokemonPreview.visible = false
	else:
		$HoverHighlight.visible = false
		if selected_id != PkmnID.Name.NONE:
			$UI/PokemonPreview.visible = true
			$UI/PokemonPreview.global_position = mouse_pos
		else:
			$UI/PokemonPreview.visible = false

#Can the pokemon be placed ?
func is_valid_cell(map_pos):
	var source_id = $Grid.get_cell_source_id(map_pos)
	var is_free = not occupied_cells.has(map_pos)
	return source_id != -1 and is_free

#See mouse on tile and center it
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if selected_id != PkmnID.Name.NONE:
					place_pokemon(get_global_mouse_position())
			else:
				if selected_id != PkmnID.Name.NONE:
					var mouse_pos = get_global_mouse_position()
					var map_pos = $Grid.local_to_map($Grid.to_local(mouse_pos))
					
					if is_valid_cell(map_pos):
						place_pokemon(mouse_pos)
					
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_selection()

#Place pokemon
func place_pokemon(mouse_pos):
	var local_pos = $Grid.to_local(mouse_pos)
	var map_pos = $Grid.local_to_map(local_pos)
	
	if selected_id == POKEBALL_ID:
		if occupied_cells.has(map_pos):
			var pokemon_to_remove = occupied_cells[map_pos]
			
			if pokemon_to_remove.has_method("is_being_captured") and pokemon_to_remove.is_being_captured():
				return

			
			pokemon_to_remove.capture_animation()
			cancel_selection()
		return

	if is_valid_cell(map_pos):
		var new_pokemon = pokemon_base_scene.instantiate()
		new_pokemon.my_id = selected_id
		
		var tile_center_local = $Grid.map_to_local(map_pos)
		new_pokemon.global_position = $Grid.to_global(tile_center_local)
		add_child(new_pokemon)
			
		occupied_cells[map_pos] = new_pokemon
		new_pokemon.tree_exiting.connect(func(): if occupied_cells.get(map_pos) == new_pokemon: occupied_cells.erase(map_pos))
		
		energy -= master_library.database[selected_id].cost
		cancel_selection()
		update_ui()

#Cancel Pokemon Selection
func cancel_selection():
	selected_id = PkmnID.Name.NONE
	$UI/PokemonPreview.visible = false

#Spawn Mowers
func spawn_mowers():
	var start_row_offset = 2
	for i in range(5):
		var mower = mower_scene.instantiate()
		var map_pos = Vector2i(3, i + start_row_offset) 
		var spawn_pos = $Grid.map_to_local(map_pos)
		
		mower.global_position = $Grid.to_global(spawn_pos)
		add_child(mower)

#--Pokemon Enemies--

#Spawn Enemies
func _on_spawn_timer_timeout():
	if current_level and current_level.possible_enemies.size() > 0:
		var random_row = randi() % 5
		var random_index = randi() % current_level.possible_enemies.size()
		var enemy_id = current_level.possible_enemies[random_index]
		
		spawn_enemy(random_row, enemy_id)
		
		if $SpawnTimer.wait_time != current_level.spawn_interval:
			$SpawnTimer.wait_time = current_level.spawn_interval

#Spawn Enemies
func spawn_enemy(row_index, enemy_id):
	var new_enemy = enemy_scene.instantiate()
	new_enemy.my_id = enemy_id
	
	var start_row_offset = 2 
	var map_pos = Vector2i(18, row_index + start_row_offset)
	var spawn_pos_local = $Grid.map_to_local(map_pos)
	
	new_enemy.global_position = $Grid.to_global(spawn_pos_local)
	$Enemies.add_child(new_enemy)
	
#Enemies in game over area
func _on_losing_zone_area_entered(area):
	if area.is_in_group("Enemies"):
		trigger_game_over()

#Game Over
func trigger_game_over():
	get_tree().paused = true
	
	$UI/GameOverScreen.visible = true
	print("Game Over ! Un ennemi a franchi la ligne.")

#--Energy--

#Natural energy coord spawn
func setup_natural_energy_timer():
	var timer = Timer.new()
	timer.name = "NaturalEnergyTimer"
	add_child(timer)
	timer.timeout.connect(_on_natural_energy_timeout)
	timer.start(randf_range(5.0, 15.0))

#Natural energy time spawn
func _on_natural_energy_timeout():
	spawn_natural_energy()
	$NaturalEnergyTimer.start(randf_range(5.0, 15.0))

#Natural energy spawn
func spawn_natural_energy():
	var energy_item = projectile_scene.instantiate()
	var screen_size = get_viewport_rect().size
	
	var spawn_x = randf_range(500, screen_size.x - 400)
	energy_item.global_position = Vector2(spawn_x, -50)
	
	var target_y = randf_range(250, screen_size.y - 250)
	
	var energy_data = master_library.database[PkmnID.Name.TOURNEGRIN]
	
	get_tree().current_scene.get_node("Projectiles").add_child(energy_item)
	
	energy_item.setup_natural(energy_data.proj_sprite, energy_data.primary_value, target_y)

#--UI--

#Buttons Pokemon
func generate_buttons():
	for id in master_library.database:
		var item = pkmn_button_scene.instantiate()
		var data = master_library.database[id]
		
		item.setup(data)
		
		item.get_node("MainButton").button_down.connect(func(): _on_pokemon_selected(id))
		
		$UI/ButtonContainer.add_child(item)

#Hover button
func _on_button_hovered(text, p_visible):
	$UI/InfoPanel.visible = p_visible
	$UI/InfoPanel/InfoText.text = text

#Pokemon can be bought
func check_buttons_affordability():
	for btn in $UI/ButtonContainer.get_children():
		if btn.has_method("update_affordability"):
			btn.update_affordability(energy)

#Pokemon hover selection
func _on_pokemon_selected(id):
	if energy >= master_library.database[id].cost:
		selected_id = id
		$UI/PokemonPreview.texture = master_library.database[id].sprite
		$UI/PokemonPreview.visible = true
		
#Pokeball button
func _on_pokeball_selected():
	selected_id = POKEBALL_ID
	$UI/PokemonPreview.texture = preload("res://Assets/UI/Pokeball.png") 
	$UI/PokemonPreview.visible = true

#Restart Game Over button
func _on_restart_button_down():
	get_tree().paused = false
	get_tree().reload_current_scene()
