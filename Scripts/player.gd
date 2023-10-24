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
	
	#Vector (x,y) con la direccion de las flechas. Con un joystick es continua
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#Si pulsamos algo, input_dir !=0 y andamos
	if input_dir:
		#Rotar nuestro input en la direccion donde mira la camara
		#que viene dada por el springarm
		var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, springarm.rotation.y)
		
		#Normalizar velocidad (evita diagonales mas rapidas)
		velocity = direction.normalized() * SPEED
		
		#Obtener el angulo de la velocidad para poner el muñeco mirando a donde debe 
		var look_direction = Vector2(velocity.z, velocity.x)
		$model.rotation.y = look_direction.angle()
		
		#TODO usar el move toward para que vaya rotando suavemente tal vez
		
		#Animacion
		$model/AnimationPlayer.play("walk")
	else:
		
		#Elimina la velocidad
		velocity.x = 0.0
		velocity.z = 0.0
		$model/AnimationPlayer.play("idle")
	
	#Haz el movimiento
	move_and_slide()

#Capture mouse 
func _unhandled_input(event):
	#Captura el raton
	if event is InputEventMouseMotion:
		#Captura movimiento relativo en el eje Y de la pantalla para la camara
		springarm.rotation.x -= event.relative.y * MOUSECAM
		#Pon un limite para evitar ir bajo el suelo
		springarm.rotation_degrees.x = clamp(springarm.rotation_degrees.x, -60, 10)
		#El otro eje de la camara
		springarm.rotation.y -= event.relative.x * MOUSECAM
