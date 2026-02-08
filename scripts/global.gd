extends Node

signal coins_changed(coins: int, total: int)
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

var run_time: float = 0.0
var best_time: float = -1.0
var run_deaths: int = 0
var total_deaths: int = 0
var run_active: bool = false
var last_victory_new_record: bool = false
var chests_opened: int = 0
var total_chests: int = 0

func _ready() -> void:
	_setup_audio()
	_play_bgm()

func _process(delta: float) -> void:
	if run_active and not get_tree().paused:
		run_time += delta

func reset_level_state() -> void:
	coins = 0
	total_coins = 0
	victory_emitted = false
	chests_opened = 0
	total_chests = 0
	emit_signal("coins_changed", coins, total_coins)

func reset(reset_run: bool = false) -> void:
	reset_level_state()
	if reset_run:
		reset_run_state()

func reset_run_state() -> void:
	run_time = 0.0
	run_deaths = 0
	run_active = true
	victory_emitted = false
	last_victory_new_record = false

func stop_run() -> void:
	run_active = false

func ensure_run_started() -> void:
	if not run_active:
		reset_run_state()

func register_coin(amount: int = 1):
	total_coins += amount
	# 🔄 Atualiza HUD imediatamente (evita 0/0 no início)
	emit_signal("coins_changed", coins, total_coins)

func register_chest(amount: int = 1) -> void:
	total_chests += amount

func add_chest(amount: int = 1) -> void:
	chests_opened += amount

func add_coin(amount: int = 1):
	if victory_emitted:
		return

	coins += amount
	emit_signal("coins_changed", coins, total_coins)

	if total_coins > 0 and coins >= total_coins:
		victory_emitted = true
		run_active = false
		last_victory_new_record = _update_best_time()
		emit_signal("victory_reached")

func register_death() -> void:
	run_deaths += 1
	total_deaths += 1

func format_time(seconds: float) -> String:
	var total_ms := int(round(seconds * 1000.0))
	var ms := total_ms % 1000
	var total_s := total_ms / 1000
	var s := total_s % 60
	var m := total_s / 60
	return "%02d:%02d.%03d" % [m, s, ms]

func _update_best_time() -> bool:
	if best_time < 0.0 or run_time < best_time:
		best_time = run_time
		return true
	return false

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

func set_bgm_volume_linear(value: float) -> void:
	if _bgm_player:
		_bgm_player.volume_db = linear_to_db(clamp(value, 0.0, 1.0))

func set_sfx_volume_linear(value: float) -> void:
	var db := linear_to_db(clamp(value, 0.0, 1.0))
	if _sfx_player:
		_sfx_player.volume_db = db
	if _jump_player:
		_jump_player.volume_db = db
	if _death_player:
		_death_player.volume_db = db
	if _victory_player:
		_victory_player.volume_db = db

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
