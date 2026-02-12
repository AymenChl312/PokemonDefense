extends HBoxContainer

var data: PokemonData
var is_affordable: bool = false

#--Set Up--

#Start
func setup(p_data: PokemonData):
	data = p_data
	$MainButton/Icon.texture = data.icon_sprite
	$MainButton/CostLabel.text = str(data.cost) +" PP"
	$DescPanel/DescLabel.text = data.pkmn_name_string + ":\n" + data.pkmn_description

#Update energy
func update_affordability(current_energy: int):
	if not data: return
	
	is_affordable = current_energy >= data.cost
	
	if is_affordable:
		$MainButton.modulate = Color.WHITE
	else:
		$MainButton.modulate = Color(0.3, 0.3, 0.3)
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
