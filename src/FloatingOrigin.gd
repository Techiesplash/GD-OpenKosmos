extends Node3D

# Amount of distance before shifting
@export var threshold: float = 2000.0

# Reference to main camera
var camera: Camera3D

func _ready() -> void:
	camera = get_viewport().get_camera_3d()

# Function to contain origin shift logic
func shift_origin() -> void:
	# Shift everything by the offset of the camera's position
	global_transform.origin -= camera.global_transform.origin
	print("World shifted to " + str(global_transform.origin))

func _physics_process(delta: float) -> void:
	# Set the camera to check to be the current camera
	camera = get_viewport().get_camera_3d()
	# Check distance of world from camera and shift if greater than threshold
	if(camera.global_transform.origin.length() > threshold && camera != null):
		shift_origin()
