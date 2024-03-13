extends KinematicBody2D

var player_speed
var standing_height

export (int) var GRAVITY = 2000

export (int) var normal_speed = 400
export (int) var crouch_speed = 200
export (int) var jump_speed = -600
export (int) var dash_speed = 1500

export (float) var dt_window = 0.2
export (float) var dash_duration = 0.1
export (int) var air_jump = 1

const UP = Vector2(0,-1)
var velocity = Vector2()

# Mempermudah memanggil child node
onready var sprite = $AnimatedSprite
onready var cshape = $CollisionShape2D
onready var dash_timer = $DashTimer
onready var dt_timer = $DoubleTapTimer
onready var ray_cast = $RayCast2D
onready var audio = $AudioStreamPlayer2D

# Preload sprite dan collision shape untuk berdiri dan jongkok
var standing_sprite = preload("res://assets/kenney_platformercharacters/PNG/Player/Poses/player_stand.png")
var crouching_sprite = preload("res://assets/kenney_platformercharacters/PNG/Player/Poses/player_duck.png")
var standing_cshape = preload("res://resource/Player_standing_cshape.tres")
var crouching_cshape = preload("res://resource/Player_crouching_cshape.tres")
var walk_sfx = preload("res://assets/sound/walk.wav")
var jump_sfx = preload("res://assets/sound/jump.wav")
var dash_sfx = preload("res://assets/sound/dash.wav")

var dt_left = false
var dt_right = false
var is_dashing = false
var is_crouching = false
var speed_transition = 10
var animation
var is_idle = true

func _ready():
	player_speed = normal_speed
	standing_height = 2 * standing_cshape.get_extents().y
	animation = "idle"

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	get_input(delta)
	
	velocity = move_and_slide(velocity, UP)

func get_input(delta):
	velocity.x = 0
	if is_idle:
		animation = "idle"
		
	check_jump()
	
	check_dash()
	
	if Input.is_action_just_pressed("ui_left"):
		dt_left = true
		dt_timer.start(dt_window)
		
	if Input.is_action_just_pressed("ui_right"):
		dt_right = true
		dt_timer.start(dt_window)
		
	dash(delta)
	
	if is_on_floor() and Input.is_action_pressed("ui_down"):
		animation = "crouch"
		crouch()
	if Input.is_action_just_released("ui_down"):
		animation = "idle"
		stand()
	
	if Input.is_action_pressed("ui_right"):
		if is_on_floor() and not is_crouching:
			animation = "walk"
		velocity.x += player_speed
		sprite.flip_h = false
		
	if Input.is_action_pressed("ui_left"):
		if is_on_floor() and not is_crouching:
			animation = "walk"
		velocity.x -= player_speed
		sprite.flip_h = true
	
	if sprite.animation != animation:
		sprite.play(animation)

func crouch():
	is_crouching = true
	#sprite.texture = crouching_sprite
	cshape.shape = crouching_cshape
	cshape.position.y = -36
	player_speed = crouch_speed

func stand():
	is_crouching = false
	#sprite.texture = standing_sprite
	cshape.shape = standing_cshape
	cshape.position.y = -45
	player_speed = normal_speed

func check_jump():
	if is_on_floor():
		air_jump = 1 #reset num of air jumps
	if Input.is_action_just_pressed("ui_up"):
		animation = "jump"
		audio.stream = jump_sfx
		audio.play()
		delay_animation()
		if is_on_floor():
			velocity.y = jump_speed
		if not is_on_floor() and air_jump > 0:
			velocity.y = jump_speed
			air_jump -= 1

func check_dash():
	if dt_left and Input.is_action_just_pressed("ui_left"):
		animation = "dash"
		audio.stream = dash_sfx
		audio.play()
		delay_animation()
		dt_left = false
		is_dashing = true
		dash_timer.start(dash_duration)
	if dt_right and Input.is_action_just_pressed("ui_right"):
		animation = "dash"
		audio.stream = dash_sfx
		audio.play()
		delay_animation()
		dt_right = false
		is_dashing = true
		dash_timer.start(dash_duration)

# Memakai fungsi interpolasi agar perubahan speed halus
func dash(delta):
	if is_dashing:
		player_speed = player_speed + (dash_speed - player_speed) * (speed_transition * delta)
	if not is_dashing and player_speed > normal_speed:
		player_speed = player_speed + (normal_speed - player_speed) * (speed_transition * delta)

func _on_DashTimer_timeout():
	is_dashing = false

func _on_DoubleTapTimer_timeout():
	dt_left = false
	dt_right = false

func delay_animation():
	$AnimationTimer.start(.5)
	is_idle = false

func _on_AnimationTimer_timeout():
	is_idle = true
