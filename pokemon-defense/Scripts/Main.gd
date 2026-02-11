extends Node2D

var carapuce_scene = preload("res://Scenes/Carapuce.tscn")
var enemy_scene = preload("res://Scenes/EnemyPokemon.tscn")
var selected_pokemon_scene = null
var energy = 100
var occupied_cells = {} 

func _ready():
	update_ui()
	$PokemonPreview.visible = false
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var local_mouse_pos = $Grid.to_local(mouse_pos)
	var map_pos = $Grid.local_to_map(local_mouse_pos)

	if is_valid_cell(map_pos):
		var tile_center_local = $Grid.map_to_local(map_pos)
		var tile_center_global = $Grid.to_global(tile_center_local)
		
		$HoverHighlight.visible = true
		$HoverHighlight.global_position = tile_center_global
		
		if selected_pokemon_scene != null:
			$PokemonPreview.visible = true
			$PokemonPreview.global_position = tile_center_global
		else:
			$PokemonPreview.visible = false
	else:
		$HoverHighlight.visible = false
		if selected_pokemon_scene != null:
			$PokemonPreview.visible = true
			$PokemonPreview.global_position = mouse_pos
		else:
			$PokemonPreview.visible = false

func is_valid_cell(map_pos):
	var source_id = $Grid.get_cell_source_id(map_pos)
	var is_free = not occupied_cells.has(map_pos)
	return source_id != -1 and is_free

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if selected_pokemon_scene != null:
				place_pokemon(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_selection()

func place_pokemon(mouse_pos):
	var local_pos = $Grid.to_local(mouse_pos)
	var map_pos = $Grid.local_to_map(local_pos)
	
	if is_valid_cell(map_pos):
		var tile_center_local = $Grid.map_to_local(map_pos)
		var new_pokemon = selected_pokemon_scene.instantiate()
		
		new_pokemon.global_position = $Grid.to_global(tile_center_local)
		add_child(new_pokemon)
		
		occupied_cells[map_pos] = new_pokemon
		
		energy -= 50
		selected_pokemon_scene = null
		update_ui()

func cancel_selection():
	selected_pokemon_scene = null
	$PokemonPreview.visible = false

func _on_carapuce_button_pressed():
	if energy >= 50:
		selected_pokemon_scene = carapuce_scene
		$PokemonPreview.texture = preload("res://Assets/Carapuce.png")

func update_ui():
	$UI/EnergyLabel.text = "PP: " + str(energy)

func _on_spawn_timer_timeout():
	var random_row = randi() % 5
	spawn_enemy(random_row)

func spawn_enemy(row_index):
	var new_enemy = enemy_scene.instantiate()
	
	var start_row_offset = 3 
	
	var map_pos = Vector2i(18, row_index + start_row_offset)
	var spawn_pos_local = $Grid.map_to_local(map_pos)
	
	new_enemy.global_position = $Grid.to_global(spawn_pos_local)
	$Enemies.add_child(new_enemy)
