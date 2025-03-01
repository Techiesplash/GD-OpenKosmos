GDPC                P                                                                         T   res://.godot/exported/133200997/export-1d7bd0d720a6796775185390fcec66b3-planet.scn   -      A      Ku.�&!\w�����    P   res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn`K      �
      _]Ki@�Et(�H(�;    ,   res://.godot/global_script_class_cache.cfg  @W      �      ��"��0ڵ��0�'    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�=            ：Qt�E�cO���       res://.godot/uid_cache.bin  �]      Z       ih��d��_��o��A    8   res://addons/debug_camera/scripts/DebugCamAutoload.gd           �      G�c�m\I�V���v�)    4   res://addons/debug_camera/scripts/DebugCamera2D.gd  �      B      <��Z�WW� 0):�    4   res://addons/debug_camera/scripts/DebugCamera3D.gd  �	      �      @�&1>P�o_����C1    ,   res://addons/debug_camera/scripts/plugin.gd �      �       ��@�ˡZo�,�$�k       res://icon.svg  Z      �      k����X3Y���f       res://icon.svg.import   �J      �       ���dO%n���$��       res://main.tscn.remap   �V      a       �J�Sw� ������       res://project.binary0^      �      �_х�@#�`Q��       res://src/Generator.gd  �       L      �W�ӑ쑜b��EQ���       res://src/WorldGenerator.gd p;            faj�v����M�Jd�t       res://src/planet.gd 0)      �      u3�;�|3A���8       res://src/planet.tscn.remap `V      c       �@Q�;>4 �5^�w�        res://src/util/SphereCoord2D.gd �      �      ~���t �U�v0-        res://src/util/SphereCoord3D.gd �      L      S�qdV�%\7-�0�k0    extends Node

var debug_cam_2d = preload("res://addons/debug_camera/scripts/DebugCamera2D.gd")
var debug_cam_3d = preload("res://addons/debug_camera/scripts/DebugCamera3D.gd")


func _ready() -> void:
	var cam_2d := debug_cam_2d.new()
	var cam_3d := debug_cam_3d.new()
	
	get_tree().current_scene.tree_exited.connect(_new_scene)
	
	if get_viewport().get_camera_2d() != null:
		get_tree().current_scene.add_child(cam_2d)
	elif get_viewport().get_camera_3d() != null:
		get_tree().current_scene.add_child(cam_3d)


func _new_scene():
	if get_tree() != null:
		await get_tree().node_added
		await get_tree().get_current_scene().ready
		_ready()
              extends Camera2D
class_name DebugCamera2D

# Lower cap for the `_zoom_level`.
@export var min_zoom := 0.5
# Upper cap for the `_zoom_level`.
@export var max_zoom := 2.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
@export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
@export var zoom_duration := 0.2

# The camera's target zoom level.
var _zoom_level : float = 1.0 :
	set(value):
		var tween = get_tree().create_tween()
		# We limit the value between `min_zoom` and `max_zoom`
		_zoom_level = clamp(value, min_zoom, max_zoom)
		tween.tween_property(self, "zoom", Vector2(_zoom_level, _zoom_level), zoom_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

var _previousPosition: Vector2 = Vector2(0, 0)
var _moveCamera: bool = false

var main_cam : Camera2D


func _ready() -> void:
	main_cam = get_viewport().get_camera_2d()


func _process(_delta: float) -> void:
	if !enabled:
		position = main_cam.global_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# zoom out
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_level = _zoom_level - zoom_factor
		# zoom in
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_level = _zoom_level + zoom_factor
	
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			_previousPosition = event.position
			_moveCamera = true
		else:
			_moveCamera = false
	elif event is InputEventMouseMotion && _moveCamera:
		position += (_previousPosition - event.position)
		_previousPosition = event.position
	
	# Toggle cameras
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_MINUS:
			var cam := main_cam
			cam.enabled = !cam.enabled
			enabled = !cam.enabled

              extends Camera3D
class_name DebugCamera3D


@export_range(0, 10, 0.01) var sensitivity : float = 3
@export_range(0, 1000, 0.1) var default_velocity : float = 5
@export_range(0, 10, 0.01) var speed_scale : float = 1.17
@export_range(1, 100, 0.1) var boost_speed_multiplier : float = 3.0
@export var max_speed : float = 1000
@export var min_speed : float = 0.2

@onready var _velocity = default_velocity

var main_cam : Camera3D


func _ready() -> void:
	main_cam = get_viewport().get_camera_3d()


func _process(delta: float) -> void:
	if !current:
		position = main_cam.global_position
		rotation = main_cam.global_rotation
		return
	
	var direction = Vector3(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_E)) - float(Input.is_physical_key_pressed(KEY_Q)), 
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	).normalized()
	
	if Input.is_physical_key_pressed(KEY_SHIFT): # boost
		translate(direction * _velocity * delta * boost_speed_multiplier)
	else:
		translate(direction * _velocity * delta)


func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x / 1000 * sensitivity
			rotation.x -= event.relative.y / 1000 * sensitivity
			rotation.x = clamp(rotation.x, PI/-2, PI/2)
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # increase fly velocity
				_velocity = clamp(_velocity * speed_scale, min_speed, max_speed)
			MOUSE_BUTTON_WHEEL_DOWN: # decrease fly velocity
				_velocity = clamp(_velocity / speed_scale, min_speed, max_speed)
	
	# Toggle cameras
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_MINUS:
			var cam := main_cam
			cam.current = !cam.current
			current = !cam.current

    @tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("DebugCam", "res://addons/debug_camera/scripts/DebugCamAutoload.gd")


func _exit_tree():
	remove_autoload_singleton("DebugCam")
      extends Object
class_name SphereCoord2D

var _lat: float = 0
var _long: float = 0
const PI_2: float = PI/2

func _sawtooth(value, v_min, v_max) -> float:
	var range_size = v_max - v_min
	var mod_value = fmod(value - v_min, range_size * 2)
	if mod_value > range_size:
		return v_max - (mod_value - range_size)
	else:
		return v_min + mod_value

var lat:
	get:
		return _lat
	set(value):
		_lat = value
		if _lat < -PI_2 or _lat > PI_2:
			long -= PI
			_lat = _sawtooth(_lat, -PI_2, PI_2)
			print("truncated lat to %s" % str(_lat))
			
var long:
	get:
		return _long
	set(value):
		_long = value
		if _long < -PI:
			_long = fmod(_long, PI)
		if _long > PI:
			_long = -fmod(_long, PI)
		
static var FORWARDS = new(0, 0)
static var BACKWARDS = new(PI, 0)
static var LEFT = new(-PI_2, 0)
static var RIGHT = new(PI_2, 0)
static var NORTH_POLE = new(0, PI_2)
static var SOUTH_POLE = new(0, -PI_2)
static var PRIME:
	get:
		return FORWARDS
		
func _init(lo, la):
	long = lo
	lat = la

func _to_string() -> String:
	var lat_deg = rad_to_deg(_lat)
	var long_deg = rad_to_deg(_long)

	var lat_abs = abs(lat_deg)
	var long_abs = abs(long_deg)

	var lat_d = int(lat_abs)
	var lat_m = int((lat_abs - lat_d) * 60)
	var lat_s = int(((lat_abs - lat_d) * 60 - lat_m) * 60)

	var long_d = int(long_abs)
	var long_m = int((long_abs - long_d) * 60)
	var long_s = int(((long_abs - long_d) * 60 - long_m) * 60)

	var lat_dir = "S"
	if _lat >= 0:
		lat_dir = "N"
	var long_dir = "W"
	if _long >= 0: 
		long_dir = "E"

	return "%° %' %\" %, %° %' %\" %" % [lat_d, lat_m, lat_s, lat_dir, 
	long_d, long_m, long_s, long_dir]

	
func to_direction() -> Vector3:
	var x: float = cos(_lat) * cos(_long)
	var z: float = cos(_lat) * sin(_long)
	var y: float = sin(_lat)
	return Vector3(x, y, z)
		
func direction() -> Vector3:
	# Convert latitude and longitude to spherical coordinates
	var x = cos(_lat) * cos(_long)
	var y = cos(_lat) * sin(_long)
	var z = sin(_lat)
	
	# Convert spherical coordinates to Cartesian coordinates
	var dir = Vector3(x, y, z)
	
	return dir
	
func add(coord: SphereCoord2D):
	# Update latitude and longitude
	lat += coord._lat
	long += coord._lat

func subtract(coord: SphereCoord2D):
	# Update latitude and longitude
	lat -= coord._lat
	long -= coord._lat
            extends SphereCoord2D
class_name SphereCoord3D
		
@export var altitude: float = 0
		
func _init(la, lo, al):
	lat = la
	long = lo
	altitude = al
	
static func from_vec3(v: Vector3) -> SphereCoord3D:
	return new(
		atan2(v.z, sqrt(v.x * v.x + v.y * v.y)),
		atan2(v.y, v.x),
		sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
	)

func _to_string() -> String:
	var lat_deg = rad_to_deg(_lat)
	var long_deg = rad_to_deg(_long)

	var lat_abs = abs(lat_deg)
	var long_abs = abs(long_deg)

	var lat_d = int(lat_abs)
	var lat_m = int((lat_abs - lat_d) * 60)
	var lat_s = int(((lat_abs - lat_d) * 60 - lat_m) * 60)

	var long_d = int(long_abs)
	var long_m = int((long_abs - long_d) * 60)
	var long_s = int(((long_abs - long_d) * 60 - long_m) * 60)

	var lat_dir = "S"
	if _lat >= 0:
		lat_dir = "N"
	var long_dir = "W"
	if _long >= 0: 
		long_dir = "E"

	return "%u, %° %' %\" %, %° %' %\" %" % [
		altitude, 
		lat_d, lat_m, lat_s, lat_dir, 
		long_d, long_m, long_s, long_dir
	]

func to_vector() -> Vector3:
	return to_direction() * altitude
	
func addv(pos: Vector3):
	add3d(from_vec3(pos))
	
func subtractv(pos: Vector3):
	subtract3d(from_vec3(pos))
		
func add3d(pos: SphereCoord3D):
	# Update latitude and longitude
	altitude += pos.altitude
	add(pos)

func subtract3d(pos: SphereCoord3D):
	# Update latitude and longitude
	altitude -= pos.altitude
	subtract(pos)
    extends Node

@export var generator: WorldGenerator

class Part:
	var positions: PackedVector3Array
	var colors: PackedColorArray
	var from_x: float
	var from_y: float
	var detail: float = 0

func create_part(detail: float, from_x: float, from_y: float, size_x: float, size_y: float) -> Part:
	var part: Part = Part.new()
	part.from_x = from_x
	part.from_y = from_y
	part.detail = detail
	var steps_long = int(abs(size_y) * detail)
	var steps_lat = int(abs(size_x) * detail)
	
	var step_long = size_y / steps_long
	var step_lat = size_x / steps_lat
	#var step_x = abs(from.x - to.x) / detail
	#var step_y = abs(from.y - to.y) / detail
	#var current: SphereCoord2D = SphereCoord2D.new(from.long, from.lat)
	#for x in Vector3(0.0, abs(size_long), 1.0/detail):
	#	current.long = from._long + x if size_long > 0 else -x
	#	for y in Vector3(0.0, abs(size_lat), 1.0/detail):
	#		current.lat = from._lat + y if size_lat > 0 else -y
	#		add_part_point(part, current);
	
	# Create the grid of triangles
	for i in range(steps_long):
		for j in range(steps_lat):
			var top_left = Vector2(from_x + i * step_long, from_y + j * step_lat)
			var top_right = Vector2(from_x + (i + 1) * step_long, from_y + j * step_lat)
			var bottom_left = Vector2(from_x + i * step_long, from_y + (j + 1)  * step_lat)
			var bottom_right = Vector2(from_x + (i + 1) * step_long, from_y + (j + 1) * step_lat)
			
			# Add two triangles for each grid square
			add_part_point(part, top_left)
			add_part_point(part, top_right)
			add_part_point(part, bottom_left)
			
			add_part_point(part, bottom_left)
			add_part_point(part, top_right)
			add_part_point(part, bottom_right)
	return part

var tristate: int = 0

func add_part_point(part: Part, coord: Vector2) -> void:
	tristate += 1
	var x: float = cos(coord.x) * cos(coord.y)
	var z: float = cos(coord.x) * sin(coord.y)
	var y: float = sin(coord.x)
	var vec2 = Vector2(x, z)
	var magnitude = generator.sample_position(vec2)
	var from_center = Vector3(x, y, z) * magnitude
	
	part.positions.push_back(from_center)
	part.colors.push_back(generator.sample_color(vec2))
	
	if tristate >= 3:
		tristate = 0
    extends Node3D

var mesh: Mesh = Mesh.new()
@export var material: StandardMaterial3D;

func get_fov_angle() -> float:
	return 90

func get_view_rotation() -> Vector3:
	return Vector3.FORWARD
	
func get_view_dist() -> float:
	return 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reprocess()
	
var long = 1
var lat = 1

var _detail: float = 70

@export var detail: float:
	set(value):
		_detail = value
	get:
		return _detail

func reprocess() -> void:
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	
	var part = $MeshGenerator.create_part(_detail, 0, 0, PI, PI)
	array[Mesh.ARRAY_VERTEX] = part.positions
	array[Mesh.ARRAY_COLOR] = part.colors

	
	var a_mesh = ArrayMesh.new()
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	a_mesh.surface_set_material(0, material)
	$MeshInstance3D.mesh = a_mesh
	long += 0.5
	lat += 0.1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
RSRC                    PackedScene            ��������                                            i      ..    WorldGenerator    resource_local_to_scene    resource_name    render_priority 
   next_pass    transparency    blend_mode 
   cull_mode    depth_draw_mode    no_depth_test    shading_mode    diffuse_mode    specular_mode    disable_ambient_light    disable_fog    vertex_color_use_as_albedo    vertex_color_is_srgb    albedo_color    albedo_texture    albedo_texture_force_srgb    albedo_texture_msdf    heightmap_enabled    heightmap_scale    heightmap_deep_parallax    heightmap_flip_tangent    heightmap_flip_binormal    heightmap_texture    heightmap_flip_texture    refraction_enabled    refraction_scale    refraction_texture    refraction_texture_channel    detail_enabled    detail_mask    detail_blend_mode    detail_uv_layer    detail_albedo    detail_normal 
   uv1_scale    uv1_offset    uv1_triplanar    uv1_triplanar_sharpness    uv1_world_triplanar 
   uv2_scale    uv2_offset    uv2_triplanar    uv2_triplanar_sharpness    uv2_world_triplanar    texture_filter    texture_repeat    disable_receive_shadows    shadow_to_opacity    billboard_mode    billboard_keep_scale    grow    grow_amount    fixed_size    use_point_size    point_size    use_particle_trails    proximity_fade_enabled    proximity_fade_distance    msdf_pixel_range    msdf_outline_size    distance_fade_mode    distance_fade_min_distance    distance_fade_max_distance    script    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    inner_radius    outer_radius    rings    ring_segments    interpolation_mode    interpolation_color_space    offsets    colors    noise_type    seed 
   frequency    offset    fractal_type    fractal_octaves    fractal_lacunarity    fractal_gain    fractal_weighted_strength    fractal_ping_pong_strength    cellular_distance_function    cellular_jitter    cellular_return_type    domain_warp_enabled    domain_warp_type    domain_warp_amplitude    domain_warp_frequency    domain_warp_fractal_type    domain_warp_fractal_octaves    domain_warp_fractal_lacunarity    domain_warp_fractal_gain 	   _bundled       Script    res://src/planet.gd ��������   Script    res://src/Generator.gd ��������   Script    res://src/WorldGenerator.gd ��������   !   local://StandardMaterial3D_5advn :
         local://TorusMesh_gnn6g u
         local://Gradient_xy6jl �
         local://FastNoiseLite_m0qju 0         local://PackedScene_esw6h f         StandardMaterial3D                       D      
   TorusMesh    D      	   Gradient    O         Q   !          @��=pͅ>�+?j�\?R   $      ��'6�;�>0F?  �?�NT?�w?��"<  �?��R>�$A?R�N5  �?y>G�
>}��=  �?  �?  �?  �?  �?D         FastNoiseLite    S         U      ŏq>D         PackedScene    h      	         names "         Planet    script 	   material    Node3D    MeshGenerator 
   generator    Node    MeshInstance3D    mesh    WorldGenerator    colors    noise    size    	   variants    	                                                                                      �?      node_count             nodes     .   ��������       ����                                  ����           @                     ����                        	   ����         
                            conn_count              conns               node_paths              editable_instances              version       D      RSRC               extends Node
class_name WorldGenerator

@export var colors: Gradient

@export var noise: Noise

@export var size: float

func get_material() -> Material:
	return StandardMaterial3D.new()

func sample_position(coord: Vector2) -> float:
	var x = sin(coord.x)
	var y = sin(coord.y)
	return 8 + (noise.get_noise_2d(x * size, y * size) * 80)

var last = 0;

func sample_color(coord: Vector2) -> Color:
	var pos = sample_position(coord)
	#if pos != last:
	#	print("Pos change: " + str(pos))
	last = pos
	return colors.sample(randf())
GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://jqkulfiwac0x"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 RSRC                    PackedScene            ��������                                            N      resource_local_to_scene    resource_name    render_priority 
   next_pass    transparency    blend_mode 
   cull_mode    depth_draw_mode    no_depth_test    shading_mode    diffuse_mode    specular_mode    disable_ambient_light    disable_fog    vertex_color_use_as_albedo    vertex_color_is_srgb    albedo_color    albedo_texture    albedo_texture_force_srgb    albedo_texture_msdf    heightmap_enabled    heightmap_scale    heightmap_deep_parallax    heightmap_flip_tangent    heightmap_flip_binormal    heightmap_texture    heightmap_flip_texture    refraction_enabled    refraction_scale    refraction_texture    refraction_texture_channel    detail_enabled    detail_mask    detail_blend_mode    detail_uv_layer    detail_albedo    detail_normal 
   uv1_scale    uv1_offset    uv1_triplanar    uv1_triplanar_sharpness    uv1_world_triplanar 
   uv2_scale    uv2_offset    uv2_triplanar    uv2_triplanar_sharpness    uv2_world_triplanar    texture_filter    texture_repeat    disable_receive_shadows    shadow_to_opacity    billboard_mode    billboard_keep_scale    grow    grow_amount    fixed_size    use_point_size    point_size    use_particle_trails    proximity_fade_enabled    proximity_fade_distance    msdf_pixel_range    msdf_outline_size    distance_fade_mode    distance_fade_min_distance    distance_fade_max_distance    script    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    size    subdivide_width    subdivide_height    subdivide_depth 	   _bundled       PackedScene    res://src/planet.tscn �so��   Script 3   res://addons/debug_camera/scripts/DebugCamera3D.gd ��������   !   local://StandardMaterial3D_3gvwi �         local://BoxMesh_s78ku �         local://PackedScene_pbtfg �         StandardMaterial3D             	                   B         BoxMesh    B         PackedScene    M      	         names "   
      Node3D    Spaceballs the Test 	   material    MeshInstance3D    mesh    DebugCamera3D 
   transform    script 	   Camera3D    DirectionalLight3D    	   variants                                         �?              �?              �?        ��@            HQ?�}N?�}�2g�m�>A~F?C ?�����!?                  node_count             nodes     -   ��������        ����                ���                                  ����                           ����                           	   	   ����                   conn_count              conns               node_paths              editable_instances              version       B      RSRC             [remap]

path="res://.godot/exported/133200997/export-1d7bd0d720a6796775185390fcec66b3-planet.scn"
             [remap]

path="res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn"
               list=Array[Dictionary]([{
"base": &"Camera2D",
"class": &"DebugCamera2D",
"icon": "",
"language": &"GDScript",
"path": "res://addons/debug_camera/scripts/DebugCamera2D.gd"
}, {
"base": &"Camera3D",
"class": &"DebugCamera3D",
"icon": "",
"language": &"GDScript",
"path": "res://addons/debug_camera/scripts/DebugCamera3D.gd"
}, {
"base": &"Object",
"class": &"SphereCoord2D",
"icon": "",
"language": &"GDScript",
"path": "res://src/util/SphereCoord2D.gd"
}, {
"base": &"SphereCoord2D",
"class": &"SphereCoord3D",
"icon": "",
"language": &"GDScript",
"path": "res://src/util/SphereCoord3D.gd"
}, {
"base": &"Node",
"class": &"WorldGenerator",
"icon": "",
"language": &"GDScript",
"path": "res://src/WorldGenerator.gd"
}])
 <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
              �so��   res://src/planet.tscn��sQ�;	   res://icon.svg�D/i�2Y   res://main.tscn      ECFG      application/config/name         OpenSpacePrototype     application/run/main_scene         res://main.tscn    application/config/features$   "         4.2    Forward Plus       application/config/icon         res://icon.svg     autoload/DebugCam@      6   *res://addons/debug_camera/scripts/DebugCamAutoload.gd     editor_plugins/enabled4   "      %   res://addons/debug_camera/plugin.cfg        file_customization/folder_colors(            
   res://src/        red           