extends CharacterBody3D

@export var speed: float = 5.0 #Modficar Velcidad Jugador
@export var mouse_sens: float = 0.002 #Modficar sensibilidad raton
@export var gravity: float = 9.8 #Modficar gravidad (Mas alta mas rapdio cae)
@export var jump_force: float = 6.0 #Modficar fuerza de salto

@onready var camara = $Camera3D # LLmamda a la Camara
@onready var anim = $AnimationPlayer # LLmamda a la Animaciones

var rot_x: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rot_x = camara.rotation.x
	camara.current = is_multiplayer_authority()


#-------------------------------------MovimientoJugador----------------------------------------
func _physics_process(delta):  # Funciones de Fisicas, Caminar, Caerse, saltar etc
	if is_multiplayer_authority():
		#---------Caminar---------
		var input_dir := Vector2.ZERO
		
		if Input.is_action_pressed("w"):
			input_dir.y += 1
		if Input.is_action_pressed("s"):
			input_dir.y -= 1
		if Input.is_action_pressed("a"):
			input_dir.x += 1
		if Input.is_action_pressed("d"):
			input_dir.x -= 1

		input_dir = input_dir.normalized()

		var direction := transform.basis * Vector3(input_dir.x, 0, input_dir.y)

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		#---------Gravedad---------
		if not is_on_floor():
			velocity.y -= gravity * delta
		#---------Saltar---------
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_force

		
		#---------Animaciones---------
		if not is_on_floor(): # Acciones al no tocar superficie
			if velocity.y > 0:
				if anim.current_animation != "Jump":   
					anim.play("Jump") #si el personaje sube la cordenada Y ejecutar animacion Jump
			elif velocity.y < 0:
				if anim.current_animation != "Fall":
					anim.play("Fall") #si el personaje baja la cordenada Y ejecutar animacion Fall

		elif input_dir != Vector2.ZERO: # Acciones cuando toca superficie pero hay velocidad  
			if anim.current_animation != "Run":
				anim.play("Run")
		else: # Acciones cuando toca superficie pero no hay velocidad  
			if anim.current_animation != "Idle":
				anim.play("Idle")

		move_and_slide()
#-------------------------------------Multijugador----------------------------------------

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	


#-------------------------------------MovimientoCamara----------------------------------------
func _input(event):

	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sens)

		rot_x -= event.relative.y * mouse_sens
		rot_x = clamp(rot_x, -1.2, 1.2)

		camara.rotation.x = rot_x
