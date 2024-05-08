extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	var enemies = get_children()
	
	# Screen Position of Enemies
	for i in enemies.size():	
		enemies[i].position = Vector2(screen_size.x*4/5, screen_size.y*(i+1)/4)
		
	# Enemy Animation Play
	for i in enemies:
		var anim = i.get_node("AnimatedSprite2D")
		anim.animation = "idle"
		anim.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
