extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var collisionNode = StaticBody.new()
	#self.add_child(collisionNode)
	var cnt = 0;
	

	var image = Image.new()
	image.load("res://terrain_data/detail.png")
	print("yeee")
	image.lock()
	print(image.get_pixel(256,256).gray())
	
	var count: int = 64;
	var noise: float = 5.0;
	var planeSize: int = 256;
	var imageWidth: int = image.get_width();
	
	for x in range(0,count):
		for z in range(0,count):
			var basis = Basis()
			var x2 = x+rng.randf_range(-noise, noise)
			var z2 = z+rng.randf_range(-noise, noise)
			#print(image.get_pixel(clamp(int(x2*(256/count)*2),0,512),clamp(int(z2*(256/count)*2),0,512)).gray())
			

			if(image.get_pixel(clamp(int(x2*(256/count)*2),0,512),clamp(int(z2*(256/count)*2),0,512)).gray() > 0.25):
				
				
				var translation = Vector3(x2*(256/count),0,z2*(256/count))
				var scale: float = rng.randf_range(0.7, 1.3)
				
				basis.rotated(Vector3.UP, rng.randf_range(-180, 180))
	
				self.multimesh.set_instance_transform(cnt, Transform(basis, translation))
	
			cnt += 1
			
	image.unlock()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
