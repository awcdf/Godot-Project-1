extends Control

const GAME_SCENE_PATH := "res://scenes/mundo.tscn"

@onready var play_button: Button = $VBox/PlayButton
@onready var options_button: Button = $VBox/OptionsButton
@onready var quit_button: Button = $VBox/QuitButton
@onready var main_menu: VBoxContainer = $VBox
@onready var options_panel: Panel = $OptionsPanel
@onready var options_main: VBoxContainer = $OptionsPanel/OptionsMain
@onready var audio_button: Button = $OptionsPanel/OptionsMain/AudioButton
@onready var video_button: Button = $OptionsPanel/OptionsMain/VideoButton
@onready var language_button: Button = $OptionsPanel/OptionsMain/LanguageButton
@onready var back_button: Button = $OptionsPanel/OptionsMain/BackButton

@onready var audio_panel: Panel = $OptionsPanel/AudioPanel
@onready var audio_back_button: Button = $OptionsPanel/AudioPanel/AudioVBox/AudioBackButton
@onready var master_slider: HSlider = $OptionsPanel/AudioPanel/AudioVBox/MasterSlider
@onready var bgm_slider: HSlider = $OptionsPanel/AudioPanel/AudioVBox/BgmSlider
@onready var sfx_slider: HSlider = $OptionsPanel/AudioPanel/AudioVBox/SfxSlider

@onready var video_panel: Panel = $OptionsPanel/VideoPanel
@onready var video_back_button: Button = $OptionsPanel/VideoPanel/VideoVBox/VideoBackButton

@onready var language_panel: Panel = $OptionsPanel/LanguagePanel
@onready var language_back_button: Button = $OptionsPanel/LanguagePanel/LanguageVBox/LanguageBackButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	audio_button.pressed.connect(_on_audio_pressed)
	video_button.pressed.connect(_on_video_pressed)
	language_button.pressed.connect(_on_language_pressed)
	back_button.pressed.connect(_on_back_pressed)
	audio_back_button.pressed.connect(_on_sub_back_pressed)
	video_back_button.pressed.connect(_on_sub_back_pressed)
	language_back_button.pressed.connect(_on_sub_back_pressed)
	master_slider.value_changed.connect(_on_master_changed)
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	play_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not options_panel.visible and play_button.has_focus():
		_on_play_pressed()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	options_panel.visible = true
	main_menu.visible = false
	_show_options_main()

func _on_back_pressed() -> void:
	options_panel.visible = false
	main_menu.visible = true
	play_button.grab_focus()

func _on_audio_pressed() -> void:
	_show_audio()

func _on_video_pressed() -> void:
	_show_video()

func _on_language_pressed() -> void:
	_show_language()

func _on_sub_back_pressed() -> void:
	_show_options_main()

func _on_master_changed(value: float) -> void:
	var db := linear_to_db(clamp(value, 0.0, 1.0))
	AudioServer.set_bus_volume_db(0, db)

func _on_bgm_changed(value: float) -> void:
	Global.set_bgm_volume_linear(value)

func _on_sfx_changed(value: float) -> void:
	Global.set_sfx_volume_linear(value)

func _show_options_main() -> void:
	options_main.visible = true
	audio_panel.visible = false
	video_panel.visible = false
	language_panel.visible = false
	_set_main_focus_enabled(true)
	_set_sub_focus_enabled(false)
	audio_button.grab_focus()

func _show_audio() -> void:
	options_main.visible = false
	audio_panel.visible = true
	video_panel.visible = false
	language_panel.visible = false
	_set_main_focus_enabled(false)
	_set_sub_focus_enabled(true)
	master_slider.grab_focus()

func _show_video() -> void:
	options_main.visible = false
	audio_panel.visible = false
	video_panel.visible = true
	language_panel.visible = false
	_set_main_focus_enabled(false)
	_set_sub_focus_enabled(true)
	video_back_button.grab_focus()

func _show_language() -> void:
	options_main.visible = false
	audio_panel.visible = false
	video_panel.visible = false
	language_panel.visible = true
	_set_main_focus_enabled(false)
	_set_sub_focus_enabled(true)
	language_back_button.grab_focus()

func _set_main_focus_enabled(enabled: bool) -> void:
	var mode := Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	audio_button.focus_mode = mode
	video_button.focus_mode = mode
	language_button.focus_mode = mode
	back_button.focus_mode = mode
	play_button.focus_mode = mode
	options_button.focus_mode = mode
	quit_button.focus_mode = mode

func _set_sub_focus_enabled(enabled: bool) -> void:
	var mode := Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	master_slider.focus_mode = mode
	bgm_slider.focus_mode = mode
	sfx_slider.focus_mode = mode
	audio_back_button.focus_mode = mode
	video_back_button.focus_mode = mode
	language_back_button.focus_mode = mode
