extends Area2D

@export var opening_time: float = 0.2
@export var reward_scene: PackedScene = preload("res://scenes/pistolas_infernos.tscn")

const TEXTURE_CLOSED := "res://assets/sprits/bau_closed.png"
const TEXTURE_OPENING := "res://assets/sprits/bau_opening.png"
const TEXTURE_OPEN := "res://assets/sprits/bau_open.png"
const SFX_OPEN_PATH := "res://assets/audio/bau.mp3"

@onready var sprite: Sprite2D = $Sprite2D

var _player_in_range: bool = false
var _is_open: bool = false
var _is_locked: bool = false
var _reward_shown: bool = false
var _sfx_player: AudioStreamPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_set_texture(TEXTURE_CLOSED)
	_setup_sfx()
	Global.register_chest()

func _process(_delta: float) -> void:
	if _player_in_range and not _is_open and not _is_locked:
		if Input.is_key_pressed(KEY_E):
			_open_chest()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if _is_open:
			_close_and_lock()

func _open_chest() -> void:
	_is_open = true
	_set_texture(TEXTURE_OPENING)
	_play_open_sfx()
	if opening_time > 0.0:
		await get_tree().create_timer(opening_time).timeout
	_set_texture(TEXTURE_OPEN)
	Global.add_chest()
	_show_reward()

func _close_and_lock() -> void:
	_is_open = false
	_is_locked = true
	_set_texture(TEXTURE_CLOSED)

func _set_texture(path: String) -> void:
	if not sprite:
		return
	var tex := load(path)
	if tex:
		sprite.texture = tex

func _setup_sfx() -> void:
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	_sfx_player.stream = load(SFX_OPEN_PATH)
	_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS

func _play_open_sfx() -> void:
	if _sfx_player and _sfx_player.stream:
		_sfx_player.play()

func _show_reward() -> void:
	if _reward_shown:
		return
	_reward_shown = true
	if not reward_scene:
		return
	var reward := reward_scene.instantiate()
	get_tree().current_scene.add_child(reward)
