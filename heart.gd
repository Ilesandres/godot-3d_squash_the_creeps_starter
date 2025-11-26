extends Area3D

@export var life_amount: int = 1

signal collected

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D):
	if body is CharacterBody3D and body.is_in_group("player"):
		
		if body.has_method("add_life"):
			body.add_life(life_amount)
			
		collected.emit()
		queue_free() 
