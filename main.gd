extends Node

@export var mob_scene: PackedScene
@export var player_scene: PackedScene

@onready var start_menu = $UI_Manager/StartMenu
@onready var game_over_screen = $UI_Manager/GameOverScreen
@onready var mob_timer = $MobTimer

var player: CharacterBody3D

func _ready():
	start_game_setup()

func start_game_setup():
	game_over_screen.hide()
	start_menu.show()
	mob_timer.stop()
	
	spawn_player()

func start_game():
	start_menu.hide()
	game_over_screen.hide()
	
	player.show()
	
	$UI_Manager/ScoreLabel.reset_score()
	
	mob_timer.start()


func end_game():
	mob_timer.stop()
	
	player.hide()
	
	get_tree().call_group("mobs", "queue_free")
	
	start_menu.hide()
	game_over_screen.show()

func spawn_player():
	if is_instance_valid(player):
		player.queue_free()
	
	player = player_scene.instantiate() as CharacterBody3D
	add_child(player)
	
	player.hit.connect(_on_player_hit)
	
	player.position = $Ground.position + Vector3(0, 1, 0)
	
func _on_play_button_pressed(): 
	start_game()

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	var player_position = player.position
	
	mob.initialize(mob_spawn_location.position, player_position)
	add_child(mob)
	
	mob.squashed.connect($UI_Manager/ScoreLabel._on_mob_squashed.bind())

func _on_player_hit(): 
	end_game()

func _on_retry_button_pressed(): 
	spawn_player()
	
	start_game()

func _unhandled_input(event):
	pass
