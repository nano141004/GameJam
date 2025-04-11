extends CharacterBody2D

@export var gravity = 2000
@export var run_speed = 200
@export var jump_speed = -520

var can_double_jump = false

@onready var animplayer = $Animation
@onready var jump_sfx = $Jump

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float):
	#game pause
	if get_parent().pause:
		animplayer.play("idle")
	
	#game running
	else: 
		velocity.y += delta * gravity

		if can_double_jump and Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
			can_double_jump = false
			jump_sfx.play()
		# First Jump
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
			can_double_jump = true
			jump_sfx.play()
		#if is_on_floor():
			#if Input.is_action_just_pressed('jump'):
				#velocity.y = jump_speed
		
		if not is_on_floor():
			animplayer.play("jump")
		else:
			animplayer.play("run")
		
		move_and_slide()
