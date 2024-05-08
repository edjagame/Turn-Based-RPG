extends Node2D

class_name Player
@onready var health_bar = $MarginContainer/TextureProgressBar
@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@export var MAX_HEALTH: float
@export var attack: int
@export var defense: int
@export var speed: int
@export var unit_name: String
var actual_defense
var counter: int
var speed_gauge: int
var health: float
var moves


# Called when the node enters the scene tree for the first time.
func _ready():
	counter = 0
	speed_gauge = 0
	health = MAX_HEALTH
	actual_defense = defense
	if name == "Cleric":
		moves = ["Attack", "Heal", "Haste"]
	if name == "Orc":
		moves = ["Attack", "Guard", "Cleave"]
		
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar.value = health
	
