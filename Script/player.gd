extends CharacterBody2D

# Movement constants
const SPEED: float = 250.0
const MAX_JUMP_VELOCITY: float = -1000.0
const MIN_JUMP_VELOCITY: float = -150.0
const CHARGE_TIME: float = 1.0
const JUMP_HORIZONTAL_FORCE: float = 250.0
const WALL_KNOCKBACK_FORCE: float = 200.0

# Camera grid control
const ROOM_SIZE: Vector2 = Vector2(1920, 1080)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

# UI labels (ganti path jika perlu)
@onready var jump_label: Label = get_tree().get_root().get_node("Game/UI Layer/label_jump")
@onready var time_label: Label = get_tree().get_root().get_node("Game/UI Layer/timestamp")


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://MainMenu.tscn")  # ganti dengan path Main Menu kamu

# State variables
var jump_charge_time: float = 0.0
var is_charging_jump: bool = false
var facing_direction: int = 1

var jump_count: int = 0
var has_started_timer: bool = false
var time_since_first_jump: float = 0.0

# Kamera ruangan
var current_room: Vector2 = Vector2.ZERO
var target_camera_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	camera.make_current()
	_update_camera_room(true)
	jump_label.text = "TOTAL JUMP: 0"
	time_label.text = "TIME: 00:00.0"

func _physics_process(delta: float) -> void:
	# Tambah gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Input arah
	var direction: int = 0
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		direction += 1

	# Flip sprite arah hadap
	if direction != 0:
		facing_direction = direction
		sprite.flip_h = facing_direction < 0

	# Jump charge
	if is_on_floor():
		if Input.is_action_pressed("ui_accept"):
			is_charging_jump = true
			jump_charge_time += delta
			jump_charge_time = clamp(jump_charge_time, 0, CHARGE_TIME)
			velocity.x = 0
		elif Input.is_action_just_released("ui_accept") and is_charging_jump:
			var charge_ratio: float = jump_charge_time / CHARGE_TIME
			velocity.y = lerp(MIN_JUMP_VELOCITY, MAX_JUMP_VELOCITY, charge_ratio)

			if direction == 0:
				velocity.x = facing_direction * (JUMP_HORIZONTAL_FORCE * 1.5)
			else:
				velocity.x = direction * JUMP_HORIZONTAL_FORCE

			# Hitung lompatan dan mulai timer
			jump_count += 1
			jump_label.text = "TOTAL JUMP: " + str(jump_count)

			if not has_started_timer:
				has_started_timer = true

			jump_charge_time = 0.0
			is_charging_jump = false
		else:
			jump_charge_time = 0.0
			is_charging_jump = false
	else:
		jump_charge_time = 0.0
		is_charging_jump = false

	# Gerak horizontal saat di tanah
	if is_on_floor() and not is_charging_jump:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Timer jalan terus setelah lompat pertama
	if has_started_timer:
		time_since_first_jump += delta

		# Format waktu MM:SS.ss
		var minutes = int(time_since_first_jump) / 60
		var seconds = int(time_since_first_jump) % 60
		var centiseconds = int((time_since_first_jump - int(time_since_first_jump)) * 100)

		time_label.text = "TIME: %02d:%02d.%02d" % [minutes, seconds, centiseconds]

		
	# Knockback saat tabrak dinding
	if not is_on_floor():
		for i in range(get_slide_collision_count()):
			var collision := get_slide_collision(i)
			if collision != null:
				var normal = collision.get_normal()
				if abs(normal.x) > 0.9:
					velocity.x = normal.x * WALL_KNOCKBACK_FORCE
					velocity.y *= 0.9

	# Animasi
	if not is_on_floor():
		sprite.play("jump")
	elif is_charging_jump:
		sprite.play("charge")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("Idle")

	# Kamera update
	_update_camera_room()
	_move_camera()

func _update_camera_room(force: bool = false) -> void:
	var player_pos: Vector2 = global_position
	var new_room: Vector2 = Vector2(
		floor(player_pos.x / ROOM_SIZE.x),
		floor(player_pos.y / ROOM_SIZE.y)
	)

	if force or (new_room != current_room):
		current_room = new_room
		target_camera_pos = current_room * ROOM_SIZE + ROOM_SIZE / 2.0

func _move_camera() -> void:
	camera.global_position = target_camera_pos
