extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("num1"):
		$"1".visible = !$"1".visible
		$"2".visible = !$"2".visible
		$"3".visible = !$"3".visible
		$"4".visible = !$"4".visible
		$"5".visible = !$"5".visible
		$"6".visible = !$"6".visible
		$"7".visible = !$"7".visible
		$"8".visible = !$"8".visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
