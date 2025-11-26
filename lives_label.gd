extends Label

var current_lives = 0

# Función que será llamada desde player.gd
func update_lives(new_lives: int):
	current_lives = new_lives
	
	# Creamos una representación visual con corazones
	var hearts_string = ""
	for i in range(current_lives):
		hearts_string += "❤️ "
	
	# Asigna el texto a la etiqueta
	text = "Lives: " + hearts_string

# ¡FUNCIÓN reset_lives() ELIMINADA!ww
