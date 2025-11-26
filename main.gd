extends Node

@export var mob_scene: PackedScene

# Referencias a los nodos de la UI para mayor claridad
@onready var start_menu = $UI_Manager/StartMenu
@onready var game_over_screen = $UI_Manager/GameOverScreen
@onready var mob_timer = $MobTimer
@onready var player = $Player

func _ready():
	# 1. Al iniciar, solo mostramos el menú de inicio y ocultamos el resto.
	start_game_setup()

# --- Funciones de Flujo de Juego ---

func start_game_setup():
	# Oculta todos los elementos de UI de juego/fin
	game_over_screen.hide()
	# Muestra el menú inicial
	start_menu.show()
	# Detiene la generación de mobs y pausa el jugador (si tienes lógica de pausa)
	mob_timer.stop()
	player.position = $Ground.position + Vector3(0, 1, 0) # Mueve el jugador a una posición segura inicial

func start_game():
	# 2. Inicia el juego
	start_menu.hide()
	game_over_screen.hide()
	
	# Reinicia el puntaje (ya se reinicia en ScoreLabel, pero aquí lo confirmamos)
	# $UI_Manager/ScoreLabel.score = 0
	# $UI_Manager/ScoreLabel.text = "Score: 0"
	
	# Reinicia la generación de mobs y hace visible al jugador si es necesario
	mob_timer.start()


func end_game():
	# 3. Fin de Partida (Game Over)
	mob_timer.stop()
	# Elimina todos los mobs existentes (opcional, pero recomendable)
	get_tree().call_group("mobs", "queue_free") 
	
	start_menu.hide()
	game_over_screen.show()

# --- Conexiones de Señales (Callbacks) ---

func _on_play_button_pressed(): # Conectado al botón 'Play' del StartMenu
	start_game()

func _on_mob_timer_timeout():
	# Lógica para generar Mobs (tu código actual)
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	var player_position = player.position
	
	mob.initialize(mob_spawn_location.position, player_position)
	add_child(mob)
	mob.squashed.connect($UI_Manager/ScoreLabel._on_mob_squashed.bind())

func _on_player_hit(): # Conectado a la señal 'hit' del Player
	end_game()

func _on_retry_button_pressed(): # Conectado al botón 'Retry' del GameOverScreen
	player.position = $Ground.position + Vector3(0, 1, 0)
	player.reset_health()
	$UI_Manager/ScoreLabel.reset_score()
	
	#get_tree().reload_current_scene()

func _unhandled_input(event):
	pass
