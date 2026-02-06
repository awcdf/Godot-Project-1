extends Node

signal coins_changed(total: int)
signal victory_reached

var coins: int = 0
var total_coins: int = 0
var victory_emitted: bool = false

func reset():
	coins = 0
	total_coins = 0
	victory_emitted = false
	emit_signal("coins_changed", coins)

func register_coin(amount: int = 1):
	total_coins += amount
	# 🔄 Atualiza HUD imediatamente (evita 0/0 no início)
	emit_signal("coins_changed", coins)

func add_coin(amount: int = 1):
	if victory_emitted:
		return

	coins += amount
	emit_signal("coins_changed", coins)

	if total_coins > 0 and coins >= total_coins:
		victory_emitted = true
		emit_signal("victory_reached")
