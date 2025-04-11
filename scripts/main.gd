extends Node2D

const player_start_pos = Vector2i(30, 225)

var speed: float
@export var start_speed = 1.0
@export var max_speed = 5
@export var accel = 7000

var screen_size : Vector2i
var platform_h : int

var score : float
var high_score = 0.0

var pause : bool

var oneeye = preload("res://scenes/oneeye.tscn")
var bat = preload("res://scenes/bat.tscn")
var monsters_generated : Array
var bat_h := [175, 224]
var monster

@onready var player = $Player
@onready var camera = $Camera
@onready var platform = $Platform
@onready var score_label = $HUD.get_node("Score")
@onready var pause_menu = $HUD.get_node("PauseMenu")
@onready var death_screen = $Death

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	print()
	platform_h = platform.get_node("Sprite2D5").get_node("Sprite2D").texture.get_height()
	death_screen.get_node("Restart").pressed.connect(restart)
	restart()

func restart():
	player.position = player_start_pos
	player.velocity = Vector2i(0, 0)
	platform.position = Vector2i(87, 272)
	camera.position = Vector2i(0, 0)
	score = 0
	update_score()
	pause = true
	pause_menu.show()
	$HUD.get_node("HighScore").text = "High Score: " + str(round(high_score))
	score_label.show()
	$HUD.get_node("HighScore").show()
	death_screen.hide()
	get_tree().paused = false

func update_score():
	score_label.text = "SCORE: " + str(round(score))
	
func add_monster(monster, x, y):
	monster.position = Vector2i(x, y)
	monster.body_entered.connect(player_hit)
	add_child(monster)
	monsters_generated.append(monster)
	
func dead():
	player.velocity = Vector2i(0, 0)
	pause = true
	speed = 0
	get_tree().paused = pause
	high_score_make()
	death_screen.get_node("HighScore").text = "High Score: " + str(round(high_score))
	death_screen.get_node("Score").text = "Score: " + str(round(score))
	death_screen.show()
	score_label.hide()

func player_hit(body):
	if body.name == "Player":
		dead()

func high_score_make():
	if score > high_score:
		high_score = score
	
func monster_generator():
	if monsters_generated.is_empty() or monster.position.x < score + randi_range(300, 500):
		#oneeye
		for i in range(randi() % int(round(speed)) + 1):
			monster = oneeye.instantiate()
			var monster_scale = monster.get_node("Animation").scale
			var monster_x = screen_size.x + round(score) + 190 + (i * 25)
			var monster_y = 228
			add_monster(monster, monster_x, monster_y)
		
		#bat
		if speed >= 2:
			if randi_range(0, 4) == 1:
				monster = bat.instantiate()
				var monster_x = screen_size.x + round(score) + 190 
				var monster_y = bat_h[randi() % bat_h.size()]
				add_monster(monster, monster_x, monster_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pause: 
		if Input.is_action_just_pressed('enter'):
			pause = false
			pause_menu.hide()
			$HUD.get_node("HighScore").hide()
	
	else: 
		#update speed
		if speed < max_speed:
			speed = start_speed + score/accel
		else:
			speed = max_speed
		
		#generate monsters
		monster_generator()
		
		#moving
		player.position.x += speed
		camera.position.x += speed
		
		#score
		score += speed
		update_score()
		
		#regenerate platform
		if camera.position.x - platform.position.x > screen_size.x * 1:
			platform.position.x += screen_size.x
			
		for monster in monsters_generated:
			if monster.position.x < (camera.position.x - screen_size.x):
				monster.queue_free()
				monsters_generated.erase(monster)
