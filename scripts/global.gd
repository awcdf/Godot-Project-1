extends Node

signal coins_changed(total: int)
signal victory_reached

const COIN_SFX_PATH := "res://assets/audio/coin.mp3"
const JUMP_SFX_PATH := "res://assets/audio/jump.mp3"
const DEATH_SFX_PATH := "res://assets/audio/death.mp3"
const VICTORY_SFX_PATH := "res://assets/audio/victory.mp3"
const BGM_PATH := "res://assets/audio/bgm.mp3"

var _sfx_player: AudioStreamPlayer
var _jump_player: AudioStreamPlayer
var _death_player: AudioStreamPlayer
var _victory_player: AudioStreamPlayer
var _bgm_player: AudioStreamPlayer

var coins: int = 0
var total_coins: int = 0
var victory_emitted: bool = false

func _ready() -> void:
	_setup_audio()
	_play_bgm()

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

func play_coin_sfx() -> void:
	if _sfx_player and _sfx_player.stream:
		_sfx_player.play()

func play_jump_sfx() -> void:
	if _jump_player and _jump_player.stream:
		_jump_player.play()

func play_death_sfx() -> void:
	if _death_player and _death_player.stream:
		_death_player.play()

func play_victory_sfx() -> void:
	if _victory_player and _victory_player.stream:
		_victory_player.play()

func _setup_audio() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_jump_player = AudioStreamPlayer.new()
	_death_player = AudioStreamPlayer.new()
	_victory_player = AudioStreamPlayer.new()
	_bgm_player = AudioStreamPlayer.new()

	add_child(_sfx_player)
	add_child(_jump_player)
	add_child(_death_player)
	add_child(_victory_player)
	add_child(_bgm_player)

	_sfx_player.stream = load(COIN_SFX_PATH)
	_jump_player.stream = load(JUMP_SFX_PATH)
	_death_player.stream = load(DEATH_SFX_PATH)
	_victory_player.stream = load(VICTORY_SFX_PATH)
	_bgm_player.stream = load(BGM_PATH)

	# Mantem os sons tocando mesmo com pause (vitoria/morte)
	_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_jump_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_death_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_victory_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS

	_sfx_player.volume_db = 0.0
	_jump_player.volume_db = 0.0
	_death_player.volume_db = 0.0
	_victory_player.volume_db = 0.0
	_bgm_player.volume_db = 0.0
	_bgm_player.autoplay = false

func _play_bgm() -> void:
	if _bgm_player and _bgm_player.stream and not _bgm_player.playing:
		_bgm_player.play()
