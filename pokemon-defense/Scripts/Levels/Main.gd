extends Node2D

# --- EXPORTS ---
@export var current_level: LevelData

# --- PRELOADS ---
var pokemon_base_scene = preload("res://Scenes/Pokemons/Pokemon.tscn")
var enemy_scene = preload("res://Scenes/Pokemons/EnemyPokemon.tscn")
var pkmn_button_scene = preload("res://Scenes/Levels/PokemonButton.tscn")

# Libraries
var master_library = preload("res://Data/Pokemons/MasterLibrary.tres")
var enemy_library = preload("res://Data/Pokemons/EnemyLibrary.tres")

# Parameters
var energy = 100
var occupied_cells = {} 
var selected_id = PkmnID.Name.NONE

func _ready():
	update_ui()
	$PokemonPreview.visible = false
	
	if current_level:
		$SpawnTimer.wait_time = current_level.level_start_time
		$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
		$SpawnTimer.start()
	
	generate_buttons()


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
			$PokemonPreview.visible = true
			$PokemonPreview.global_position = tile_center_global
		else:
			$PokemonPreview.visible = false
	else:
		$HoverHighlight.visible = false
		if selected_id != PkmnID.Name.NONE:
			$PokemonPreview.visible = true
			$PokemonPreview.global_position = mouse_pos
		else:
			$PokemonPreview.visible = false

func is_valid_cell(map_pos):
	var source_id = $Grid.get_cell_source_id(map_pos)
	var is_free = not occupied_cells.has(map_pos)
	return source_id != -1 and is_free

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

func place_pokemon(mouse_pos):
	var local_pos = $Grid.to_local(mouse_pos)
	var map_pos = $Grid.local_to_map(local_pos)
	
	if is_valid_cell(map_pos):
		var new_pokemon = pokemon_base_scene.instantiate()
		new_pokemon.my_id = selected_id
		
		var tile_center_local = $Grid.map_to_local(map_pos)
		new_pokemon.global_position = $Grid.to_global(tile_center_local)
		add_child(new_pokemon)
			
		occupied_cells[map_pos] = new_pokemon
		
		new_pokemon.tree_exiting.connect(func(): occupied_cells.erase(map_pos))
		
		
		energy -= master_library.database[selected_id].cost
			
		cancel_selection()
		update_ui()

func cancel_selection():
	selected_id = PkmnID.Name.NONE
	$PokemonPreview.visible = false

func update_ui():
	$UI/EnergyLabel.text = "PP: " + str(energy)

func _on_spawn_timer_timeout():
	if current_level and current_level.possible_enemies.size() > 0:
		var random_row = randi() % 5
		var random_index = randi() % current_level.possible_enemies.size()
		var enemy_id = current_level.possible_enemies[random_index]
		
		spawn_enemy(random_row, enemy_id)
		
		if $SpawnTimer.wait_time != current_level.spawn_interval:
			$SpawnTimer.wait_time = current_level.spawn_interval

func spawn_enemy(row_index, enemy_id):
	var new_enemy = enemy_scene.instantiate()
	new_enemy.my_id = enemy_id
	
	var start_row_offset = 3 
	var map_pos = Vector2i(18, row_index + start_row_offset)
	var spawn_pos_local = $Grid.map_to_local(map_pos)
	
	new_enemy.global_position = $Grid.to_global(spawn_pos_local)
	$Enemies.add_child(new_enemy)

func generate_buttons():
	for id in master_library.database:
		var btn = pkmn_button_scene.instantiate()
		var data = master_library.database[id]
		
		btn.setup(data)
		btn.button_down.connect(func(): _on_pokemon_selected(id))
		
		$UI/ButtonContainer.add_child(btn)

func _on_pokemon_selected(id):
	if energy >= master_library.database[id].cost:
		selected_id = id
		$PokemonPreview.texture = master_library.database[id].sprite
		$PokemonPreview.visible = true
