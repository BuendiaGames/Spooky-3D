extends CharacterBody3D

#Constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSECAM = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Get the spring arm that holds the camera
@onready var springarm = $springarm

func _physics_process(delta):
	
	#Get a vector (x,y) with the direction of the arrows
	#if a joystick is used this is a continuous variable
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#Direction relative to world
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#Direction rotated according to our camera view
	#var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, springarm.rotation.y)
	
	#If something was pressed (any coord of direction != 0)
	if direction:
		
		#TODO seems that model is facing backwards for our coordinate 
		#system. One should put it back. Maybe store the direction 
		#we are facing in a variable so we don't have use model rotation
		#in the velocity
		
		#Rotate our model
		$model.rotation.y += (delta * 2 *SPEED * direction.x)
		
		#Set velocity of our thing based on model's rotation
		velocity = SPEED * direction.rotated(Vector3.UP, $model.rotation.y)
		
		#Play animation
		$model/AnimationPlayer.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		$model/AnimationPlayer.play("idle")
	
	
	move_and_slide()

#Capture mouse 
func _unhandled_input(event):
	#Mouse motion
	if event is InputEventMouseMotion:
		#Capture relative movement in X and use for camera up/down
		springarm.rotation.x -= event.relative.y * MOUSECAM
		#Cap camera angles to not go below the ground...
		springarm.rotation_degrees.x = clamp(springarm.rotation_degrees.x, -60, 10)
		#Camera on the Y axis
		springarm.rotation.y -= event.relative.x * MOUSECAM
