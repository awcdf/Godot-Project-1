extends CanvasLayer

const MENU_SCENE_PATH := "res://scenes/menu.tscn"

@onready var coin_label: Label = $CoinLabel
@onready var victory_panel: Panel = $VictoryPanel
@onready var restart_button: Button = $VictoryPanel/Card/Buttons/RestartButton
@onready var menu_button: Button = $VictoryPanel/Card/Buttons/MenuButton
@onready var message_label: Label = $VictoryPanel/Card/MessageLabel
@onready var current_time_value: Label = $VictoryPanel/Card/StatsGrid/CurrentTimeValue
@onready var best_time_value: Label = $VictoryPanel/Card/StatsGrid/BestTimeValue
@onready var run_deaths_value: Label = $VictoryPanel/Card/StatsGrid/RunDeathsValue
@onready var total_deaths_value: Label = $VictoryPanel/Card/StatsGrid/TotalDeathsValue
@onready var coins_value: Label = $VictoryPanel/Card/StatsGrid/CoinsValue
@onready var chests_value: Label = $VictoryPanel/Card/StatsGrid/ChestsValue

func _ready():
	# 🔑 MUITO IMPORTANTE: HUD continua ativo mesmo com pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	victory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_button.process_mode = Node.PROCESS_MODE_ALWAYS

	coin_label.text = "Moedas: %d/%d" % [Global.coins, Global.total_coins]

	Global.coins_changed.connect(_on_coins_changed)
	Global.victory_reached.connect(_on_victory)

	victory_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_coins_changed(coins: int, total: int) -> void:
	coin_label.text = "Moedas: %d/%d" % [coins, total]

func _on_victory() -> void:
	Global.play_victory_sfx()
	victory_panel.visible = true
	get_tree().paused = true
	_update_victory_stats()
	_animate_victory_stats()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.reset(true)
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	Global.reset(true)
	Global.stop_run()
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _update_victory_stats() -> void:
	current_time_value.text = Global.format_time(Global.run_time)
	if Global.best_time < 0.0:
		best_time_value.text = "--:--.---"
	else:
		best_time_value.text = Global.format_time(Global.best_time)
	run_deaths_value.text = str(Global.run_deaths)
	total_deaths_value.text = str(Global.total_deaths)
	coins_value.text = "%d/%d" % [Global.coins, Global.total_coins]
	chests_value.text = "%d/%d" % [Global.chests_opened, Global.total_chests]
	message_label.text = _get_victory_message()

func _animate_victory_stats() -> void:
	var duration := 0.45
	var target_time := Global.run_time
	var target_best_time := Global.best_time
	var target_run_deaths := Global.run_deaths
	var target_total_deaths := Global.total_deaths
	var target_coins := Global.coins
	var target_total_coins := Global.total_coins
	var target_chests := Global.chests_opened
	var target_total_chests := Global.total_chests

	# Start from zero for a satisfying count-up effect.
	current_time_value.text = Global.format_time(0.0)
	best_time_value.text = "--:--.---" if target_best_time < 0.0 else Global.format_time(0.0)
	run_deaths_value.text = "0"
	total_deaths_value.text = "0"
	coins_value.text = "0/%d" % target_total_coins
	chests_value.text = "0/%d" % target_total_chests

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(_set_time_value, 0.0, target_time, duration)
	if target_best_time >= 0.0:
		tween.tween_method(_set_best_time_value, 0.0, target_best_time, duration)
	tween.tween_method(_set_run_deaths_value, 0, target_run_deaths, duration)
	tween.tween_method(_set_total_deaths_value, 0, target_total_deaths, duration)
	tween.tween_method(_set_coins_value, 0, target_coins, duration)
	tween.tween_method(_set_chests_value, 0, target_chests, duration)

func _set_time_value(value: float) -> void:
	current_time_value.text = Global.format_time(value)

func _set_best_time_value(value: float) -> void:
	best_time_value.text = Global.format_time(value)

func _set_run_deaths_value(value: int) -> void:
	run_deaths_value.text = str(value)

func _set_total_deaths_value(value: int) -> void:
	total_deaths_value.text = str(value)

func _set_coins_value(value: int) -> void:
	coins_value.text = "%d/%d" % [value, Global.total_coins]

func _set_chests_value(value: int) -> void:
	chests_value.text = "%d/%d" % [value, Global.total_chests]

func _get_victory_message() -> String:
	var all_coins := Global.total_coins > 0 and Global.coins >= Global.total_coins
	if Global.last_victory_new_record:
		return "Novo recorde!"
	if all_coins and Global.run_deaths == 0:
		return "Perfeito!"
	if all_coins:
		return "Quase la!"
	return "Boa!"
