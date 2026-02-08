extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	get_tree().paused = false
	Global.register_death()
	Global.play_death_sfx()
	Global.reset()
	get_tree().reload_current_scene()
