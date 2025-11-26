extends CharacterBody3D

signal hit
signal lives_changed(new_lives)

@export var max_lives: int = 5 
var current_lives: int = 0
@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16


var target_velocity = Vector3.ZERO

func _ready():
	add_to_group("player") 
	reset_health()

func stop_movement():
	target_velocity = Vector3.ZERO
	velocity = Vector3.ZERO

func reset_health():
	current_lives = max_lives
	lives_changed.emit(current_lives)

func add_life(amount: int = 1):
	if current_lives < max_lives:
		current_lives += amount
		lives_changed.emit(current_lives)
		print("¡Vida obtenida! Vidas restantes: %s" % current_lives)
	else:
		print("Vidas al máximo. No se puede sumar más.")


func lose_life():
	current_lives -= 1
	lives_changed.emit(current_lives)
	
	if current_lives <= 0:
		die() 
	else:
		hit.emit()


func die():
	queue_free()

func _physics_process(delta):
	var direction = Vector3.ZERO
	if direction != Vector3.ZERO:
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1

	if Input.is_action_pressed("move_right"):
		direction.x = direction.x + 1
	if Input.is_action_pressed("move_left"):
		direction.x = direction.x - 1
	if Input.is_action_pressed("move_back"):
		direction.z = direction.z + 1
	if Input.is_action_pressed("move_forward"):
		direction.z = direction.z - 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)

		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				target_velocity.y = bounce_impulse
				break

	velocity = target_velocity
	move_and_slide()
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse


func _on_mob_detector_body_entered(body):
	lose_life()
