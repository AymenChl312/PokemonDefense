extends Button

var pkmn_id: PkmnID.Name

func setup(data: PokemonData):
	pkmn_id = data.pkmn_name
	icon = data.sprite
	text = data.pkmn_name_string
