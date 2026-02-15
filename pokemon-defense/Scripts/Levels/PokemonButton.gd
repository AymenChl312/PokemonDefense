extends HBoxContainer

var data: PokemonData
var is_affordable: bool = false
var is_on_cooldown: bool = false
var current_cooldown_time: float = 0.0

#--Set Up--

#Start
func setup(p_data: PokemonData):
	data = p_data
	$MainButton/Icon.texture = data.icon_sprite
	$MainButton/CostLabel.text = str(data.cost)
	$DescPanel/DescLabel.text = data.pkmn_name_string + ":\n" + data.pkmn_description
	
	$MainButton/CooldownOverlay.max_value = data.cooldown
	$MainButton/CooldownOverlay.value = 0
	$MainButton/CooldownOverlay.visible = false

#Pokemon buy Cooldown
func _process(delta):
	if is_on_cooldown:
		current_cooldown_time -= delta
		$MainButton/CooldownOverlay.value = current_cooldown_time
		
		if current_cooldown_time <= 0:
			is_on_cooldown = false
			$MainButton/CooldownOverlay.visible = false
			update_affordability(get_tree().current_scene.energy)

#Start Cooldown
func start_cooldown():
	is_on_cooldown = true
	current_cooldown_time = data.cooldown
	$MainButton/CooldownOverlay.visible = true
	$MainButton/CooldownOverlay.value = data.cooldown

#Update pokemon buy
func update_affordability(current_energy: int):
	if not data: return
	
	is_affordable = current_energy >= data.cost and not is_on_cooldown
	
	if is_affordable:
		$MainButton.modulate = Color.WHITE
	else:
		$MainButton.modulate = Color(0.4, 0.4, 0.4)
		$MainButton/Glow.visible = false

#--Inputs--

#Info pressed
func _on_info_button_pressed():
	$DescPanel.visible = !$DescPanel.visible

#Hover enter
func _on_main_button_mouse_entered():
	if is_affordable:
		$MainButton/Glow.visible = true

#Hover exit
func _on_main_button_mouse_exited():
	$MainButton/Glow.visible = false
