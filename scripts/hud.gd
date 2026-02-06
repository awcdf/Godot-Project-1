extends CanvasLayer

@onready var coin_label: Label = $CoinLabel
@onready var victory_panel: Panel = $VictoryPanel
@onready var restart_button: Button = $VictoryPanel/RestartButton

func _ready():
	# 🔑 MUITO IMPORTANTE: HUD continua ativo mesmo com pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	victory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS

	coin_label.text = "Moedas: %d/%d" % [Global.coins, Global.total_coins]

	Global.coins_changed.connect(_on_coins_changed)
	Global.victory_reached.connect(_on_victory)

	victory_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)

func _on_coins_changed(_total: int) -> void:
	coin_label.text = "Moedas: %d/%d" % [Global.coins, Global.total_coins]

func _on_victory() -> void:
	Global.play_victory_sfx()
	victory_panel.visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.reset()
	get_tree().reload_current_scene()
