extends Node

signal turn_finished
signal action_selected

@onready var turn = []
@onready var enemies = $EnemyGroup.get_children()
@onready var players = $PlayerGroup.get_children()
@onready var battlers = enemies + players
@onready var rng = RandomNumberGenerator.new()
@onready var display_text = $GUI/HBoxContainer/MarginContainer/MarginContainer/HandlerText
@onready var action_buttons = $GUI/HBoxContainer/VBoxContainer
@onready var move1 = action_buttons.get_node("Move1")
@onready var move2 = action_buttons.get_node("Move2")
@onready var move3 = action_buttons.get_node("Move3")
var in_action = false
var action: String
# Called when the node enters the scene tree for the first time.
func _ready():
	for battler in battlers:
		battler.get_node("AnimatedSprite2D").play("idle")
	display_text.text = "A wild %s and %s have appeared!" % [enemies[0].unit_name, enemies[1].unit_name]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if enemies.size() == 0:
		display_text.text = "You win! 2200 gil obtained."
		get_tree().paused = true
	if players.size() == 0:
		display_text.text = "Your party has been defeated..."
		action_buttons.hide()
		get_tree().paused = true
		
		
	if in_action == false:
		# Turn queue
		if turn.size() == 0:
			for battler in battlers:
				battler.speed_gauge += battler.speed
				if battler.speed_gauge >= 100:
					battler.speed_gauge -= 100
					turn.push_back(battler)
	
		if turn.size() > 0:
			
			var battler = turn.pop_front()
			in_action = true
			if battler in enemies:
				enemy_action(battler)
			elif battler in players:
				player_action(battler)
			else:
				in_action = false

		
func enemy_action(battler):
	var moves = battler.moves
	var selector = randi_range(0,battler.moves.size()-1)
	var enemy_target = enemies[randi_range(0,enemies.size()-1)]
	var player_target = players[randi_range(0,players.size()-1)]
	match moves[selector]:
		"Attack":
			attack(battler, player_target)
		"Heal":
			heal(battler, enemy_target)
		"Burn":
			burn(battler)
		_:
			print("This shouldn't happen.")
	await get_tree().create_timer(2).timeout
	battler.counter += 1
	in_action = false
	
func player_action(battler):
	
	if battler.defense != battler.actual_defense:
		battler.defense = battler.actual_defense
	
	var moves = battler.moves
	move1.text = moves[0]
	move2.text = moves[1]
	move3.text = moves[2]
	action_buttons.show()
	move1.show(); move2.show(); move3.show();
	move1.grab_focus()
	
	await action_selected
	
	match action:
		"Attack":
			attack(battler, await selector(enemies))
		"Guard":
			guard(battler)
		"Haste":
			haste(battler, await selector(players))
		"Heal":
			heal(battler, await selector(players))
		"Cleave":
			cleave(battler)
		_:
			display_text.text = "An unexpected error occurred."
	
	action_buttons.hide()
	await get_tree().create_timer(2).timeout
	battler.counter += 1
	in_action = false
	
	
func attack(attacker, defender):
	var atk = attacker.attack
	var def = defender.defense
	var crit = 1.5 if randf() <= 0.9 else 1
	var damage = atk * atk/(atk+def) * randf_range(0.8,1.2) * crit
	display_text.text = " %s attacked %s for %d damage!" % [attacker.unit_name, defender.unit_name, damage]
	if crit == 1.5:
		display_text.text += " A critical hit!"
	damage(defender, damage)
	
	attacker.anim.animation = "attack"
	attacker.anim.play()

func heal(healer, target):
	var heal_amount = healer.defense * 2 * randf_range(0.9,1.1)
	target.health += heal_amount
	
	if target.health > target.MAX_HEALTH:
		target.health = target.MAX_HEALTH
		
	display_text.text = " %s healed %s for %d health!" % [healer.unit_name, target.unit_name, heal_amount]
	
	healer.anim.animation = "heal"
	healer.anim.play()
	
func burn(battler):
	display_text.text = ""
	var atk = battler.attack
	if battler in enemies:
		for player in players:
			var damage = atk * atk/(atk+player.defense) * randf_range(0.8,1.2) * 0.7
			display_text.text += " %s casts FIRA on %s for %d damage!" % [battler.unit_name, player.unit_name, damage]
			damage(player, damage)
			
	battler.anim.animation = "attack"
	battler.anim.play()
			
func damage(battler, damage):
	
	battler.health -= damage
	battler.health_bar.value = battler.health
	if battler.health <= 0:
		display_text.text += " %s has been defeated in battle!" % battler.unit_name
		battler.queue_free()
		enemies.erase(battler)
		players.erase(battler)
		battlers.erase(battler)
		
	battler.anim_player.play("hurt")

func guard(battler):
	battler.defense = battler.defense * 2 * randf_range(0.8,1.2)
	display_text.text = " %s braced themselves and increased their defense!" % battler.unit_name
	battler.anim_player.play("buffed")

func haste(caster, battler):
	turn.push_front(battler)
	display_text.text = " %s has sped up %s!" % [caster.unit_name, battler.unit_name]
	
	caster.anim.animation = "heal"
	caster.anim.play()
	battler.anim_player.play("buffed")
	
func cleave(battler):
	display_text.text = ""
	var atk = battler.attack
	if battler in players:
		for enemy in enemies:
			var damage = atk * atk/(atk+enemy.defense) * randf_range(0.8,1.2) * 0.8
			display_text.text += " %s cleaves  %s for %d damage!" % [battler.unit_name, enemy.unit_name, damage]
			damage(enemy, damage)

func _on_move_1_pressed():
	var move1 = action_buttons.get_node("Move1")
	action = move1.text
	action_selected.emit()

func _on_move_2_pressed():
	var move2 = action_buttons.get_node("Move2")
	action = move2.text
	action_selected.emit()

func _on_move_3_pressed():
	var move3 = action_buttons.get_node("Move3")
	action = move3.text
	action_selected.emit()

func selector(side):
	var buttons = [move1, move2, move3]
	for button in buttons:
		button.text = ""
		button.hide()
	for i in range(side.size()):
		buttons[i].text = side[i].unit_name
		buttons[i].show()
	
	buttons[0].grab_focus()
	
	await action_selected
	
	for battler in side:
		if battler.unit_name == action:
			return battler
	
