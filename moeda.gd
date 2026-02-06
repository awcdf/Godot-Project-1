extends Area2D

func _ready():
	Global.register_coin()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		Global.add_coin(1)
		queue_free()
	
