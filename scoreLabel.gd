extends Label

var score = 0

func _ready() -> void:
	# Asegúrate de que el score se muestre correctamente al inicio
	text = "Score: %s" % score

func reset_score():
	score = 0
	text = "Score: %s" % score

func _on_mob_squashed():
	score += 1
	text = "Score: %s" % score
