extends KinematicBody

var camera_angle = 0
var isFlying = false;
var isWalking = false;
puppet var isHater = false;
var isAlive = true;

var walkingTick = 0;
var mouse_sensitivity = 0.3;

const SPEED = 5;
var acceleration = 20
var gravity = -20
var timeFallen = 0;

var move_dir = Vector3()
var velocity = Vector3()
var aim = Basis()

puppet var puppet_pos = Vector3()
puppet var puppet_vel = Vector3()
puppet var puppet_aim = Basis()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#while(get_node("/root/gamestate").hater_id != null): #if hater id not inizalized yet, wait
	#	pass
		
		
	if is_network_master():
		if(isHater): #if we are the hater
			print("You are the Hater!")
		else:
			print("You are NOT the Hater!")
		
		$Head/Camera.current = true
		$MeshInstance.visible = false
		$Mask.visible = false
	else:
		var player_id = get_network_master()
		puppet_pos = translation # Just making sure we initilize it
		
		
	if(isHater):
		pass
		#$MeshInstance.get_surface_material(0).albedo_color(Color.black)
		#$MeshInstance.material_override.albedo_color = Color.black
	else:
		$Mask.visible = false;
		#$MeshInstance.get_surface_material(0).albedo_color(Color.white)
		#$MeshInstance.material_override.albedo_color = Color.white
	
		
func _input(event):
	if event is InputEventMouseMotion && is_network_master():
		rotate_y(deg2rad(-event.relative.x*mouse_sensitivity));
		var change = -event.relative.y * mouse_sensitivity;
		if (change + camera_angle) < 90 and (change + camera_angle) > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			$Light.rotate_x(deg2rad(change))
			camera_angle += change
			
	if(Input.is_action_just_pressed("quit")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
		
	#print(aim.get_euler().y)
	#transform.basis = Basis()
	#rotate_object_local(Vector3(0, 1, 0), aim.get_euler().y)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_network_master():
		
		move_dir = Vector3()
		var speed = SPEED;
		
		aim = $Head/Camera.get_global_transform().basis
		
		if Input.is_action_pressed("up"):
			move_dir  -= aim.z
		if Input.is_action_pressed("down"):
			move_dir  += aim.z;	
		if Input.is_action_pressed("left"):
			move_dir -= aim.x;
		if Input.is_action_pressed("right"):
			move_dir  += aim.x;		
		if Input.is_action_pressed("move_sprint"):
			speed = 20
		if Input.is_action_just_pressed("ui_page_up") or Input.is_action_just_pressed("ui_up"):
			isFlying = !isFlying
		if Input.is_action_just_pressed("toggle_flashlight"):
			$Light.visible = !$Light.visible
			
		if(move_dir != Vector3(0,0,0)):
			isWalking = true;
		else:
			isWalking = false;
			
		if(!isFlying):
			move_dir.y = 0
		else:
			timeFallen = 0	
			
		velocity = move_dir.normalized() * speed
		
		if(!isFlying):
			timeFallen += delta
			velocity.y += (gravity/2)*timeFallen*timeFallen
			if(is_on_floor()):
				timeFallen = 0
			
		move_and_slide(velocity, Vector3.UP)

		rset_unreliable("puppet_pos", translation)
		rset_unreliable("puppet_vel", velocity)
		rset_unreliable("puppet_aim", aim)
		
		#global_transform.basis.x 
		#global_rotate(Vector3(0,1,0), 50);
		#rotate_object_local(Vector3(0, 1, 0), 50)
		#transform.rotated(Vector3(0,1,0),50)
		#print(rotation)
	else:
		# If we are not the ones controlling this player, 
		# sync to last known position and velocity
		
		#position = puppet_pos
		#velocity = puppet_vel
		#print(translation)
		translation = puppet_pos;
		
		transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), puppet_aim.get_euler().y)
		
	
	translation += velocity * delta
	
	if not is_network_master():
		# It may happen that many frames pass before the controlling player sends
		# their position again. If we don't update puppet_pos to position after moving,
		# we will keep jumping back until controlling player sends next position update.
		# Therefore, we update puppet_pos to minimize jitter problems
		puppet_pos = translation
	
func _process(delta):
	if(isWalking && is_on_floor()):
		walkingTick += 0.2
		$Head/Camera.translation = $Head/Camera.translation + (Vector3(0, sin(walkingTick)/30,0)) 
