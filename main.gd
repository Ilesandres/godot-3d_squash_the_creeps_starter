extends Node

@export var mob_scene: PackedScene
@export var player_scene: PackedScene
@export var heart_scene: PackedScene # <--- Escena del Corazón (Power-up)

# --- Nueva variable para el tiempo de vida del corazón ---
@export var heart_lifespan: float = 15.0 # Segundos que el corazón espera antes de desaparecer

@onready var start_menu = $UI_Manager/StartMenu
@onready var game_over_screen = $UI_Manager/GameOverScreen
@onready var mob_timer = $MobTimer
@onready var heart_timer = $HeartTimer
@onready var lives_label = $UI_Manager/LivesLabel
@onready var score_label = $UI_Manager/ScoreLabel

var player: CharacterBody3D

func _ready():
	start_game_setup()

func start_game_setup():
	game_over_screen.hide()
	start_menu.show()
	mob_timer.stop()
	heart_timer.stop()
	
	lives_label.hide()
	score_label.hide()
	
	spawn_player()

func start_game():
	start_menu.hide()
	game_over_screen.hide()
	
	player.show()
	
	lives_label.show()
	score_label.show()
	
	score_label.reset_score()
	
	mob_timer.start()
	heart_timer.start()

func end_game():
	mob_timer.stop()
	heart_timer.stop()
	
	if is_instance_valid(player):
		player.hide()
	
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("powerups", "queue_free")
	
	start_menu.hide()
	lives_label.hide()
	score_label.hide()
	game_over_screen.show()

func spawn_player():
	if is_instance_valid(player):
		player.queue_free()
	
	player = player_scene.instantiate() as CharacterBody3D
	add_child(player)
	
	player.hit.connect(_on_player_hit)
	player.lives_changed.connect(_on_player_lives_changed)
	
	player.reset_health()
	
	player.position = $Ground.position + Vector3(0, 1, 0)
	
func _on_player_lives_changed(new_lives: int):
	lives_label.update_lives(new_lives)
	
	if new_lives <= 0:
		end_game()

func _on_player_hit():
	if is_instance_valid(player):
		get_tree().call_group("mobs", "queue_free")
		get_tree().call_group("powerups", "queue_free")
		
		player.stop_movement()
		
		mob_timer.start()
		heart_timer.start()
		
func _on_mob_timer_timeout():
	if not is_instance_valid(player):
		return
		
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	
	var player_position = player.position
	
	mob.initialize(mob_spawn_location.position, player_position)
	add_child(mob)
	
	mob.squashed.connect(score_label._on_mob_squashed.bind())

func _on_heart_timer_timeout():
	if not is_instance_valid(player):
		return
		
	var heart = heart_scene.instantiate() as Area3D
	
	var spawn_location = get_node("SpawnPath/SpawnLocation")
	
	spawn_location.progress_ratio = randf_range(0.3, 0.8)
	
	heart.global_position = spawn_location.position + Vector3(0, 0.5, 0)
	
	if heart.has_method("set_lifespan"):
		heart.set_lifespan(heart_lifespan)
		
	add_child(heart)
	
	heart_timer.wait_time = randf_range(5.0, 10.0)
	heart_timer.start()

func _on_play_button_pressed():
	start_game()

func _on_retry_button_pressed():
	spawn_player()
	start_game()

func _on_main_button_pressed():
	start_game_setup()

func _unhandled_input(event):
	pass
