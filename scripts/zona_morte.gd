extends Area2D


func _on_body_entered(body: Node2D) -> void:
	get_tree().paused = false
	Global.play_death_sfx()
	Global.reset()
	get_tree().reload_current_scene()
