extends "res://ui/menus/run/character_selection.gd"

#testing
func _on_element_pressed(element: InventoryElement, _inventory_player_index: int)->void :
	var customize_stats_scene = "res://mods-unpacked/ProdigalTechie-Modato/scenes/customize_stats.tscn"
	var inventory_player_index = FocusEmulatorSignal.get_player_index(element)
	if inventory_player_index < 0:
		return 

	if element.is_random:
		var available_elements: = []
		
		for element in displayed_elements[0]:
			if not element.is_locked:
				available_elements.push_back(element)
		var character = Utils.get_rand_element(available_elements)
		_player_characters[inventory_player_index] = character
	elif element.is_special:
		return 
	else:
		_player_characters[inventory_player_index] = element.item

	_set_selected_element(inventory_player_index)
	
	get_tree().change_scene(customize_stats_scene)
