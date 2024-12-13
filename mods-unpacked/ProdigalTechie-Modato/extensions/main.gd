extends "res://main.gd"


const LOG_ID = "ProdigalTechie-Modato:Main"

# Called when the node enters the scene tree for the first time.
func _on_EntitySpawner_players_spawned(players: Array)->void :
	_players = players
	_camera.targets = players
	_floating_text_manager.players = _players

	
	EffectBehaviorService.update_active_effect_behaviors()

	if _players.size() > 1:
		_damage_vignette.active = false

	_players_ui.clear()
	for i in _players.size():
		var effects = RunData.get_player_effects(i)

		var player_ui: = PlayerUIElements.new()
		var player_idx_string = str(i + 1)

		player_ui.player_index = i
		player_ui.player_life_bar = get_node("%%PlayerLifeBarContainerP%s/PlayerLifeBarP%s" % [player_idx_string, player_idx_string])
		player_ui.player_life_bar_container = get_node("%%PlayerLifeBarContainerP%s" % player_idx_string)
		player_ui.hud_container = get_node("%%LifeContainerP%s" % player_idx_string)
		player_ui.life_bar = get_node("%%UILifeBarP%s" % player_idx_string)
		player_ui.life_label = get_node("%%UILifeBarP%s/MarginContainer/LifeLabel" % player_idx_string)
		player_ui.xp_bar = get_node("%%UIXPBarP%s" % player_idx_string)
		player_ui.level_label = get_node("%%UIXPBarP%s/MarginContainer/LevelLabel" % player_idx_string)
		player_ui.gold = get_node("%%UIGoldP%s" % player_idx_string)

		_players_ui.push_back(player_ui)

		player_ui.update_hud(_players[i])
		player_ui.hud_visible = true
		player_ui.set_hud_position(i)

		_players[i].get_life_bar_remote_transform().remote_path = player_ui.player_life_bar_container.get_path()
		_players[i].current_stats.health = max(1, _players[i].max_stats.health * (effects["hp_start_wave"] / 100.0)) as int

		if effects["hp_start_next_wave"] != 100:
			_players[i].current_stats.health = max(1, _players[i].max_stats.health * (effects["hp_start_next_wave"] / 100.0)) as int
			effects["hp_start_next_wave"] = 100

		_players[i].check_hp_regen()

		_on_player_health_updated(_players[i], _players[i].current_stats.health, _players[i].max_stats.health)

		var _error_player_hp = _players[i].connect("health_updated", self, "_on_player_health_updated")
		var _error_hp_text = _players[i].connect("healed", _floating_text_manager, "_on_player_healed")
		var _error_died = _players[i].connect("died", self, "_on_player_died")
		var _error_took_damage = _players[i].connect("took_damage", _screenshaker, "_on_player_took_damage")
		var _error_on_healed = _players[i].connect("healed", self, "on_player_healed")
		var _error_on_wanted_to_spawn_gold = _players[i].connect("wanted_to_spawn_gold", self, "on_player_wanted_to_spawn_gold")

		var things_to_process_player_container: UIThingsToProcessPlayerContainer = _things_to_process_player_containers[i]
		things_to_process_player_container.show()
		var _error_ui_upgrades_mouse_entered = things_to_process_player_container.upgrades.connect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
		var _error_ui_upgrades_mouse_exited = things_to_process_player_container.upgrades.connect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")
		var _error_ui_consumables_mouse_entered = things_to_process_player_container.consumables.connect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
		var _error_ui_consumables_mouse_exited = things_to_process_player_container.consumables.connect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")

		connect_visual_effects(_players[i])

		var pct_val = RunData.get_player_effect("gain_pct_gold_start_wave", i)
		var apply_pct_gold_wave = pct_val > 0

		if apply_pct_gold_wave:
			var val = RunData.get_player_gold(i) * (pct_val / 100.0)
			RunData.add_gold(val, i)
			if pct_val > 0:
				RunData.add_tracked_value(i, "item_piggy_bank", val)

		for stat_link in RunData.get_player_effect("stat_links", i):
			if stat_link[2] == "living_enemy":
				_update_stats_on_enemies_changed_timer = Timer.new()
				_update_stats_on_enemies_changed_timer.wait_time = 1.0
				_update_stats_on_enemies_changed_timer.one_shot = true
				add_child(_update_stats_on_enemies_changed_timer)

	var temp_stats_updated: = false
	for player_index in _players.size():
		var effects = RunData.get_player_effects(player_index)
		if effects["stats_next_wave"].size() > 0:
			for stat_next_wave in effects["stats_next_wave"]:
				TempStats.add_stat(stat_next_wave[0], stat_next_wave[1], player_index)
				temp_stats_updated = true
			effects["stats_next_wave"].clear()

		if check_half_health_stats(player_index):
			temp_stats_updated = true

	if temp_stats_updated:
		RunData.emit_stats_updated()

	DebugService.log_run_info()
	RunData.reset_weapons_dmg_dealt()
	RunData.reset_weapons_tracked_value_this_wave()
	RunData.reset_cache()

# Allow harvesting to grow infinitely
func _on_HarvestingTimer_timeout()->void :
	for player_index in RunData.get_player_count():
		var harvesting_stat = Utils.get_stat("stat_harvesting", player_index)
		if harvesting_stat <= 0:
			continue
		
		var harvesting_growth = RunData.get_player_effect("harvesting_growth", player_index)
		var val = ceil(harvesting_stat * (harvesting_growth / 100.0))

		var has_crown = false
		var crown_value = 0

		var items = RunData.get_player_items(player_index)
		for item in items:
			if item.my_id == "item_crown":
				has_crown = true
				crown_value = item.effects[0].value
				break

		if has_crown:
			RunData.add_tracked_value(player_index, "item_crown", ceil(harvesting_stat * (crown_value / 100.0)) as int)

		if val > 0:
			RunData.add_stat("stat_harvesting", val, player_index)
	RunData.emit_stats_updated()
