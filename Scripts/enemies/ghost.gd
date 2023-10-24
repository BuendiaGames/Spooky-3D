extends CharacterBody3D

#Estas constantes tienen los rangos de movimiento del fantasma...

#Velocidad 
const MIN_SPD = 0.5
const MAX_SPD = 3.0
#Velocidad de giro (para cambiar de direccion)
const MIN_W = 5.0
const MAX_W = 30.0
#Tiempo que tarda en cambiar de decision
const MIN_T = 0.5
const MAX_T = 5

#Aceleracion de la velocidad lineal y angular
const ACCEL = 1.0

#Recuerda donde empezo y pone un threshold maximo donde no puede escapar
var initial_pos = Vector2.ZERO
var thres_dist = 7**2

#La velocidad y demas que tiene que alcanzar, para que sea una transicion 
#smooth. El angulo permite que gire suave
var target_angle = 0.0
var target_speed = 1.0
var target_w = 1.0

#Variables de estado, vel angular, velocidad y angulo
var lookingangle = 0.0
var speed = 1.0
var w = 1.0


func _ready():
	initial_pos = Vector3(position)
	$model/AnimationPlayer.play("walk")

func _physics_process(delta):
	#Actualiza nuestras variables hacia los valores deseados
	w = move_toward(w, target_w, delta*ACCEL)
	lookingangle = move_toward(lookingangle, target_angle, delta*w)
	speed = move_toward(speed, target_speed, delta*ACCEL)
	
	#La velocidad, rotada hacia donde el fantasma debe moverse
	velocity = speed * Vector3.FORWARD.rotated(Vector3.UP, lookingangle)
	
	#Poner el look direction como en el personaje
	#TODO (mejorable? sabemos el angulo...)
	var look_direction = Vector2(velocity.z, velocity.x)
	$model.rotation.y = look_direction.angle()
	
	move_and_slide()

#--- Timers 
#Cada vez que un timer hace tick, cambiar los parameteros 
#para mas aleatoriedad


func _on_angle_tick():
	
	#Usa este temporizador para controlar que el fantasma no se vaya de madre
	var dist2 = position.distance_squared_to(initial_pos)
	if dist2 < thres_dist:
		target_angle = -PI + 2*PI*randf()
	else:
		#Si se fue, traer de vuelta al redil
		teleport(initial_pos)

	$timer_rot.wait_time = randf_range(MIN_T, MAX_T)

#Velocidad
func _on_speed_tick():
	target_speed = randf_range(MIN_SPD, MAX_SPD)
	$timer_speed.wait_time = randf_range(MIN_T, MAX_T)

#Rotacion
func _on_rot_tick():
	target_w = randf_range(MIN_W, MAX_W)
	$timer_rot.wait_time = randf_range(MIN_T, MAX_T)

#TODO, primero hacer transparente, desactivar, y reiniciar
func teleport(pos):
	position = pos





