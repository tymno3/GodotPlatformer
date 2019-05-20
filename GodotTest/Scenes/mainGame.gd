extends KinematicBody2D

export(float) var runSpeed = 20
export(float) var xdecelG = 1
export(float) var xaccelG = 2
export(float) var xdecelA = .5
export(float) var xaccelA = 1
export(float) var velCap = 10

var move = 0.0
var velocity = Vector2()

export(float) var jumpHeight = 40
export(float) var jumpTime = 0.3

export(bool) var canIdle = true
export(bool) var canFall = true

func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#direction
	if(velocity.x > 0):
		$Sprite.flip_h = false
	if(velocity.x < 0):
		$Sprite.flip_h = true
	
	#velocity calculations
	# -y is up, +y is down
	var gravity = 2*jumpHeight/(jumpTime*jumpTime)
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	#------------------------------------------------------------------------------------------------------------------------
	#horizontal acceleration/deceleration
	#velocity multiplier
	velocity.x = move * runSpeed
	#max speed
	if(abs(move) >= velCap):
		if(sign(move) == 1):
			move = velCap
		else:
			move = -1*velCap
	#prevents weird values that oscillate around 0
	if(abs(move) < .5):
		move=0
			
	#ground
	if(is_on_floor() == true):
		#deceleration ground
		if(sign(move) != 0 ):
			if(sign(move) == 1 ):
				move -= xdecelG
			else:
				move += xdecelG		
		#acceleration ground
		#the sprite flips avoid the weird 1 frame direction issue with a direction change
		if(Input.is_action_pressed("ui_right")):
			move += xaccelG
			if(velocity.x == 0):
				$Sprite.flip_h = false
		if(Input.is_action_pressed("ui_left")):
			move -= xaccelG
			if(velocity.x == 0):
				$Sprite.flip_h = true
				
		#running animation
		if(velocity.x != 0):
			$AnimationPlayer.play("playerRun")
		#idling animation
		if(canIdle && velocity.x == 0):
				$AnimationPlayer.play("playerIdle")
				
	#air
	if(is_on_floor() == false):	
		#deceleration air
		if(sign(move) != 0):
			if(sign(move) == 1):
				move -= xdecelA
			else:
				move += xdecelA
		#acceleration air
		if(Input.is_action_pressed("ui_right")):
			move += xaccelA	
		if(Input.is_action_pressed("ui_left")):
			move -= xaccelA
	#----------------------------------------------------------------------------------------------------------------------	
	#other movement
	if(Input.is_action_just_pressed("jump") && is_on_floor() == true):
		$AnimationPlayer.play("playerJump")
		velocity.y = -2*jumpHeight/jumpTime
	#wall jump
	if(Input.is_action_just_pressed("jump") && is_on_floor() == false && is_on_wall() == true):
		$AnimationPlayer.play("playerFlip")
		velocity.y = -2*jumpHeight/jumpTime
	#falling animation
	if(is_on_floor() != true && velocity.y > 0):
		$AnimationPlayer.play("playerFalling")
	#----------------------------------------------------------------------------------------------------------------------
	#attack animations (NOT COMPLETE)
	if(Input.is_action_just_pressed("light attack")):
		#animation runs on a different frame system than the script
		#I set the canFall value in animation and it kept getting cancelled 
		#do state checks in script, not animation, as they are faster here (constant vs variable update)
		canFall = false
		#canIdle = false (PUT THIS IN ANIMATION PLAYER)
		$AnimationPlayer.play("playerLightAttack")
		print("Can idle is now ", canIdle)





#func _on_AnimationPlayer_animation_finished(anim_name):
#	canIdle = true
#	canFall = true


