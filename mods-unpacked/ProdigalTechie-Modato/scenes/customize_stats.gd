extends "res://mods-unpacked/ProdigalTechie-Modato/extensions/ui/menus/run/character_selection.gd"

onready var _character_panel:ItemPanelUI = $MarginContainer / VBoxContainer / DescriptionContainer / CharacterPanel
onready var _weapons:ScrollContainer = $MarginContainer / VBoxContainer / ScrollContainer
onready var _stats:GridContainer = $MarginContainer / VBoxContainer / DescriptionContainer / GridContainer
onready var _continue:Button = $MarginContainer / VBoxContainer / Button

var current_stat

func _ready()->void :
	_character_panel.set_data(RunData.current_character)
	_weapons.hide()
	
	#add customizeable stats
	for effect in RunData.current_character.effects:
#		print(effect.serialize())
		
		var new_stat_label = Label.new()
		new_stat_label.text = str(effect.key)
		_stats.add_child(new_stat_label)
		
		var new_stat = LineEdit.new()
		new_stat.connect("text_changed", self, "on_stat_changed", [effect])
		new_stat.text = str(effect.value)
		_stats.add_child(new_stat)
	
	#continue button
	# warning-ignore:return_value_discarded
	_continue.text = "CONTINUE"
	_continue.connect("button_up", self, "on_continue_pressed")

func manage_back(event:InputEvent)->void :
	if event.is_action_pressed("ui_cancel"):
		RunData.apply_weapon_selection_back()

func update_info_panel(_item_info:ItemParentData)->void :
	pass

func is_char_screen()->bool:
	return false

func is_locked_elements_displayed()->bool:
	return false

func on_stat_changed(newValue:String, effect)->void :
	#customize stat
	var oldValue = effect.value
	effect.value = int(newValue)
	var perm_only = effect.text_key.to_upper() == "EFFECT_GAIN_STAT_FOR_EVERY_PERM_STAT"
	var stat_link = "EFFECT_GAIN_STAT_FOR_EVERY_STAT"
	
	if effect.custom_key != "":
		RunData.effects[effect.custom_key].erase([effect.key, oldValue])
		RunData.effects[effect.custom_key].push_back([effect.key, effect.value])
	elif effect.key == "effect_reduce_stat_gains" or effect.key == "effect_increase_stat_gains":
		RunData.effects["gain_" + effect.stat_displayed] = effect.value
	elif effect.text_key == stat_link:
		RunData.effects["stat_links"].erase([effect.key, oldValue, effect.stat_scaled, effect.nb_stat_scaled, perm_only])
		RunData.effects["stat_links"].push_back([effect.key, effect.value, effect.stat_scaled, effect.nb_stat_scaled, perm_only])
	elif effect.key == "EFFECT_WEAPON_CLASS_BONUS":
		RunData.effects["weapon_class_bonus"].erase([effect.set_id, effect.stat_name, oldValue])
		RunData.effects["weapon_class_bonus"].push_back([effect.set_id, effect.stat_name, effect.value])
	elif effect.key == "weapon_slot":
		RunData.effects["weapon_slot"] = 6 #set to default
		RunData.effects["weapon_slot"] += effect.value
	else:
		RunData.effects[effect.key] = int(newValue)
	
	update_info_panel(RunData.current_character)
	_character_panel.set_data(RunData.current_character)
	
func on_continue_pressed()->void :
	if RunData.effects["weapon_slot"] == 0:
		var _error = get_tree().change_scene(MenuData.difficulty_selection_scene)
	else :
		var _error = get_tree().change_scene(MenuData.weapon_selection_scene)
