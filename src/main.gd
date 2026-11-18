extends Node3D
## Same content and actions for desktop preview and standalone OpenXR.
const ACCENT := Color("73e0cb")
const MUTED := Color("91a7be")
const ORBIT_RADII := [0.16, 0.22, 0.29, 0.36, 0.49, 0.75, 0.96, 1.06]
const START_ANGLES := [0.8, 3.3, 2.4, 5.5, 0.3, 3.5, 1.5, 5.3]
const CARD_DISTANCE_STEP := 0.15
const CARD_DISTANCE_MIN := 0.55
const CARD_DISTANCE_MAX := 2.60
const GrabManager = preload("res://src/interaction/grab_manager.gd")
const SideCard = preload("res://src/side_card.gd")
const EarthCompanions = preload("res://src/earth_companions.gd")
const GuidedJourney = preload("res://src/guided_journey.gd")
var journey: Node
var journey_sun_halo: MeshInstance3D
var manipulation = GrabManager.new()
var earth_companions: Node3D
var info_panel: Node3D
var planet_labels: Array[Label3D] = []
var grab_halos: Array[MeshInstance3D] = []
var system_home := Transform3D.IDENTITY
var panel_home := Transform3D.IDENTITY
var desktop_drag := false
var desktop_plane_point := Vector3.ZERO
var desktop_plane_normal := Vector3.BACK
var desktop_hit: Dictionary = {}
var companion_selected := -1
var records: Array = []
var planets: Array[Node3D] = []
var orbit_lines: Array[MeshInstance3D] = []
var targets: Array[Dictionary] = []
var sim_time := 0.0
var speed := 1.0
var paused := false
var selected := -1
var hovered := -1
var xr_active := false
var origin: XROrigin3D
var camera: Camera3D
var universe: Node3D
var stage: Node3D
var info_3d: Label3D
var status_3d: Label3D
var sun_highlight: MeshInstance3D
var selection_ring: MeshInstance3D
var desk_ui: CanvasLayer
var hands: Array[Dictionary] = []
var frames := 0
var smoke_test := false
var yaw := 0.0
var pitch := 0.55
var zoom := 2.8
var recenter_pending := false
var exit_requested := false
var input_focused := true
var card_distance_controls: Node3D
var card_distance_hover := -1

func _ready() -> void:
	records = JSON.parse_string(FileAccess.get_file_as_string("res://data/planets.json"))
	smoke_test = "--smoke-test" in OS.get_cmdline_user_args()
	var xr := XRServer.find_interface("OpenXR")
	xr_active = xr != null and xr.is_initialized() and not "--desktop" in OS.get_cmdline_user_args()
	get_viewport().use_xr = xr_active
	_setup_camera()
	_setup_environment()
	stage = Node3D.new()
	add_child(stage)
	universe = Node3D.new()
	stage.add_child(universe)
	universe.position = Vector3(0, -0.53, -1.35)
	_build_solar_system()
	_build_spatial_ui()
	manipulation.setup(self)
	earth_companions = EarthCompanions.new()
	planets[2].add_child(earth_companions)
	earth_companions.setup(self)
	journey = GuidedJourney.new()
	add_child(journey)
	journey.changed.connect(info_panel.show_tour)
	info_panel.show_tour(journey.state())
	system_home = universe.transform
	panel_home = info_panel.transform
	if xr_active:
		_setup_hands()
		input_focused = xr.get_session_state()==OpenXRInterface.SESSION_STATE_FOCUSED
		get_viewport().msaa_3d = Viewport.MSAA_2X
		if xr.has_signal("session_focussed"):
			xr.connect("session_focussed", _on_session_focus)
		if xr.has_signal("session_visible"):
			xr.connect("session_visible", _on_session_unfocus)
		if xr.has_signal("pose_recentered"):
			xr.connect("pose_recentered", _request_recenter_view)
	else:
		_build_desktop_ui()
		get_viewport().msaa_3d = Viewport.MSAA_4X
		_update_desktop_camera()
	_select_planet(2 if "--show-earth" in OS.get_cmdline_user_args() else -1)
	if "--show-sun" in OS.get_cmdline_user_args():
		_select_sun()
	if "--show-journey" in OS.get_cmdline_user_args():
		_activate(130)
	if "--exit-test" in OS.get_cmdline_user_args():
		_activate.call_deferred(119)
	print("POCKET_UNIVERSE_READY mode=", "XR" if xr_active else "DESKTOP", " planets=", records.size())

func _setup_camera() -> void:
	origin = XROrigin3D.new()
	add_child(origin)
	origin.current = true
	if xr_active:
		camera = XRCamera3D.new()
		origin.add_child(camera)
	else:
		camera = Camera3D.new()
		add_child(camera)
		camera.fov = 45
	camera.near = 0.02
	camera.far = 100
	camera.current = true

func _setup_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("050c18")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("a9bed9")
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, -35, 0)
	fill.light_energy = 1.0
	add_child(fill)
	# One batched star mesh: no individual star nodes or lights.
	var stars := ImmediateMesh.new()
	stars.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261118
	for i in 500:
		var p := Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()*30.0
		var r := rng.randf_range(0.012, 0.035)
		var right := p.cross(Vector3.UP).normalized()*r
		var up := p.normalized().cross(right).normalized()*r
		stars.surface_set_color(Color("6084a6") if i%4 else Color("c4e2e8"))
		for v in [p-right-up,p+right-up,p+right+up,p-right-up,p+right+up,p-right+up]:
			stars.surface_add_vertex(v)
	stars.surface_end()
	var star_node := MeshInstance3D.new()
	star_node.mesh = stars
	var mat := _material(Color.WHITE)
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	star_node.material_override = mat
	add_child(star_node)

func _material(color: Color, unshaded := true) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	if unshaded:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat

func _sphere(parent: Node3D, radius: float, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius*2.0
	mesh.radial_segments = 32
	mesh.rings = 16
	node.mesh = mesh
	node.material_override = mat
	parent.add_child(node)
	return node

func _ring(parent: Node3D, radius: float, color: Color, width := 0.001) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - width
	mesh.outer_radius = radius + width
	mesh.rings = 96
	mesh.ring_segments = 6
	node.mesh = mesh
	node.material_override = _material(color)
	parent.add_child(node)
	return node

func _label(parent: Node3D, text: String, pos: Vector3, size := 24, color := Color.WHITE) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.0016
	label.position = pos
	label.modulate = color
	label.outline_size = 2
	label.no_depth_test = false
	parent.add_child(label)
	return label

func _build_solar_system() -> void:
	var sun := _sphere(universe,0.085,_material(Color("ffd18a")))
	targets.append({"node":sun,"radius":0.095,"action":120})
	sun_highlight = _ring(universe,0.108,ACCENT,0.002)
	sun_highlight.visible = false
	journey_sun_halo = _ring(universe,0.117,Color("ffd780"),0.0015)
	journey_sun_halo.visible = false
	var sunlight := OmniLight3D.new()
	sunlight.light_color = Color("ffe6ba")
	sunlight.light_energy = 0.7
	sunlight.omni_range = 2.5
	universe.add_child(sunlight)
	_ring(universe,0.10,Color("9a784e"),0.001)
	for i in records.size():
		var d: Dictionary = records[i]
		var body := Node3D.new()
		universe.add_child(body)
		planets.append(body)
		var radius := float(d.radius_ratio_earth)*0.0075
		var mat := ShaderMaterial.new()
		mat.shader = load("res://assets/planet.gdshader")
		mat.set_shader_parameter("base_color",Color(d.color))
		mat.set_shader_parameter("kind", i)
		_sphere(body,radius,mat)
		if i == 5:
			for n in 7:
				var ring := _ring(body, radius*(1.4+n*0.12),Color("a08f74").lerp(Color("ddd3b5"),n/7.0),0.002)
				ring.rotation_degrees.z = 25
		var label := _label(body,d.name,Vector3(0,radius+0.025,0),18,MUTED)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.pixel_size = 0.0015 if xr_active else 0.0025
		orbit_lines.append(_ring(universe,ORBIT_RADII[i],Color("294052"),0.0015))
		planet_labels.append(label)
		var halo := _ring(body,maxf(radius+0.009,0.028),ACCENT,0.0012)
		halo.visible = false
		grab_halos.append(halo)
		targets.append({"node":body,"radius":maxf(radius,0.036),"action":i})
	selection_ring = _ring(universe,0.04,ACCENT,0.0015)
	selection_ring.visible = false

func _build_spatial_ui() -> void:
	info_panel = SideCard.new()
	stage.add_child(info_panel)
	info_panel.position = Vector3(0.95,0.10,-0.70)
	info_panel.rotation.y = -atan2(info_panel.position.x,-info_panel.position.z)
	info_panel.setup(self)
	if xr_active:
		_build_card_distance_controls()
	info_3d = Label3D.new()
	info_3d.visible = false
	info_panel.add_child(info_3d)
	status_3d = Label3D.new()
	status_3d.visible = false
	info_panel.add_child(status_3d)

func _build_card_distance_controls() -> void:
	# Outside the card's surface, but attached so move/rotate/recenter stay together.
	card_distance_controls = Node3D.new()
	info_panel.add_child(card_distance_controls)
	card_distance_controls.transform = Transform3D(Basis.IDENTITY,Vector3(0.29,0,0.03))
	for i in 2:
		var button := _spatial_button(["+","−"][i],Vector3(0,(0.5-i)*0.10,0),140+i,0.09,card_distance_controls)
		var text := button.get_child(1) as Label3D
		text.font_size = 26
		text.pixel_size = 0.0011

func _move_card_distance(closer: bool) -> void:
	if not input_focused or recenter_pending:
		return
	if not manipulation.panel_owner.is_empty():
		manipulation.release(manipulation.panel_owner)
	var offset := info_panel.global_position-camera.global_position
	var distance := offset.length()
	var direction := offset/distance if distance>0.001 else -camera.global_basis.z
	var desired := clampf(distance+(-CARD_DISTANCE_STEP if closer else CARD_DISTANCE_STEP),CARD_DISTANCE_MIN,CARD_DISTANCE_MAX)
	info_panel.global_position = camera.global_position+direction*desired
	if not xr_active:
		info_panel.adjust_desktop_distance(closer)

func _spatial_button(text: String, pos: Vector3, action: int, width: float, parent: Node3D = null) -> Node3D:
	var root := Node3D.new()
	if parent == null:
		parent = info_panel
	parent.add_child(root)
	root.position = pos
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(width,0.055,0.008)
	mesh.mesh = box
	mesh.material_override = _material(Color("132a3b"))
	root.add_child(mesh)
	_label(root,text,Vector3(0,0,0.006),18,Color("d3eee9"))
	targets.append({"node":root,"radius":0.0,"half_size":Vector2(width/2,0.0275),"action":action})
	return root

func _build_desktop_ui() -> void:
	desk_ui = CanvasLayer.new()
	add_child(desk_ui)
	var top := VBoxContainer.new()
	top.position = Vector2(32,28)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desk_ui.add_child(top)
	_ui_label(top,"P O C K E T   U N I V E R S E",15,ACCENT)
	_ui_label(top,"Eight worlds. One small universe.",26)
	_ui_label(top,"Drag a world to inspect. Right-drag to look. Scroll to zoom.",15,MUTED)

func _ui_label(parent: Node, text: String, size: int, color := Color("edf4f8")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	parent.add_child(label)
	return label

func _select_planet(index: int) -> void:
	sun_highlight.visible = false
	companion_selected = -1
	selected = index
	if index < 0:
		_present_card("Your pocket universe", "EXPLORE AT YOUR OWN PACE", "8 worlds  •  1 star\nSelect a world or its name below.", "Grab / Pinch a planet to inspect it. Release to return it. Grab / Pinch a free area to move this card.", "sun")
	else:
		var d: Dictionary = records[index]
		var period := "%.1f days" % float(d.orbital_period_days)
		if float(d.orbital_period_days)>730:
			period = "%.1f Earth years" % (float(d.orbital_period_days)/365.256)
		var details := "Diameter: %s km\nFrom Sun: %s million km\nOne year: %s" % [_number(d.diameter_km),_number(d.distance_million_km),period]
		_present_card(d.name, "ROCKY PLANET" if index<4 else "GIANT PLANET", details, d.fact, d.id)

func _present_card(title: String, kind: String, facts: String, description: String, image_id: String) -> void:
	info_3d.text = "%s / %s\n%s\n%s" % [title.to_upper(),kind,facts,description]
	info_panel.show_data(title,kind,facts,description,image_id)

func _number(value: float) -> String:
	if value == floor(value):
		return "%d" % int(value)
	return "%.1f" % value

func _activate(action: int) -> void:
	if "--trace-input" in OS.get_cmdline_user_args():
		print("INPUT_ACTION ", action)
	if action >= 0 and action < 8:
		_select_planet(action)
	elif action == 100:
		paused = not paused
	elif action == 101:
		speed = 4.0 if speed == 1.0 else (0.25 if speed == 4.0 else 1.0)
	elif action == 102:
		_select_planet(-1)
	elif action == 112:
		_reset_space()
	elif action == 113 or action == 114:
		_zoom_system(0.8 if action==113 else 1.25)
	elif action == 116:
		_select_sun()
	elif action == 118:
		_request_recenter_view()
	elif action == 119:
		_exit_experience()
	elif action == 120:
		_select_sun()
	elif action == 130:
		if journey.can_discover_moon():
			_select_companion(0)
		else:
			journey.primary()
	elif action == 131:
		journey.explore_freely()
	elif action == 140 or action == 141:
		_move_card_distance(action==140)
	elif action >= 300 and action < 308:
		_select_planet(action-300)
	elif action >= 200 and action <= 202:
		_select_companion(action-200)

func _process(delta: float) -> void:
	if not input_focused:
		return
	frames += 1
	if xr_active and frames == 8:
		_recenter_stage()
	if not paused:
		sim_time += minf(delta,0.1)*speed
	for i in planets.size():
		# Deliberately compressed periods preserve ordering while remaining observable.
		var period := 18.0 * pow(float(records[i].orbital_period_days)/88.0,0.28)
		var angle: float = START_ANGLES[i] + sim_time*TAU/period
		manipulation.orbit_planet(i,Vector3(cos(angle)*ORBIT_RADII[i],0,sin(angle)*ORBIT_RADII[i]),delta)
		planets[i].get_child(0).rotation.y += delta*0.15
	if selected >= 0:
		selection_ring.visible = true
		selection_ring.position = planets[selected].position
		selection_ring.basis = planets[selected].basis
		var r := float(records[selected].radius_ratio_earth)*0.0075+0.012/maxf(planets[selected].global_basis.get_scale().x,0.01)
		selection_ring.scale *= r/0.04
	else:
		selection_ring.visible = false
	var status := "%s  ·  %.2f× time" % ["Paused" if paused else "Orbiting",speed]
	status_3d.text = status
	info_panel.show_status(status + "  •  %.2f× size" % universe.scale.x)
	if xr_active:
		_update_hands(delta)
	else:
		_update_desktop_grab()
		var mouse := get_viewport().get_mouse_position()
		var hit := _pick(camera.project_ray_origin(mouse),camera.project_ray_normal(mouse))
		hovered = int(hit.get("action",-1))
	manipulation.advance(delta)
	info_panel.set_hover(111 if not manipulation.panel_owner.is_empty() else hovered)
	if is_instance_valid(card_distance_controls) and card_distance_hover!=hovered:
		card_distance_hover=hovered
		for i in 2:
			var button := card_distance_controls.get_child(i)
			var material: StandardMaterial3D=button.get_child(0).material_override
			material.albedo_color=Color("24534f") if hovered==140+i else Color("132a3b")
	var inspecting_earth: bool = manipulation.planet_is_held(2) or manipulation.returning.has(2) or journey.show_earth_neighbourhood()
	earth_companions.advance(delta,inspecting_earth,not paused)
	if not inspecting_earth and companion_selected >= 0:
		_select_planet(2)
	journey.observe(manipulation.planet_is_held(2),manipulation.planet_is_held(5),not manipulation.system_owner.is_empty(),universe.global_position,paused)
	var journey_target: int = journey.target_action()
	journey_sun_halo.visible = journey_target==120
	for i in planet_labels.size():
		planet_labels[i].visible = not (i==2 and manipulation.planet_is_held(2))
		var factor: float = maxf(planets[i].global_basis.get_scale().x,0.01)
		planet_labels[i].scale = Vector3.ONE/factor
		planet_labels[i].pixel_size = 0.0009 if manipulation.planet_is_held(i) else (0.0015 if xr_active else 0.0025)
		planet_labels[i].position.y = float(records[i].radius_ratio_earth)*0.0075 + 0.025/factor
		grab_halos[i].visible = (hovered==i or journey_target==i) and not manipulation.planet_is_held(i)
	if "--inspect-earth" in OS.get_cmdline_user_args() and frames == 10:
		_preview_earth()
	if "--capture" in OS.get_cmdline_user_args() and frames == 60:
		_capture.call_deferred()
	if "--recenter-test" in OS.get_cmdline_user_args():
		if frames == 30:
			_activate(118)
		if frames == 45 and not recenter_pending:
			assert(stage.global_position.distance_to(camera.global_position)<0.01)
			assert(stage.global_basis.y.is_equal_approx(Vector3.UP))
			assert(universe.position.is_equal_approx(system_home.origin))
			assert(origin.current)
			var tracked_count := 0
			for hand in hands:
				var hand_tracker := XRServer.get_tracker("/user/hand_tracker/"+hand.side) as XRHandTracker
				if hand_tracker!=null and hand_tracker.has_tracking_data:
					tracked_count+=1
					assert(hand.root.is_visible_in_tree())
					if _joint_valid(hand_tracker,0):
						var raw := hand_tracker.get_hand_joint_transform(0)
						var expected := _adjust_hand_transform(raw,XRServer.get_reference_frame(),XRServer.world_scale)
						assert(hand.dots[0].transform.is_equal_approx(expected))
			assert(tracked_count>0,"Enable hand inputs in the simulator for this check")
			print("XR_HANDS_AFTER_RECENTER_PASS count=",tracked_count)
			print("XR_RECENTER_TEST_PASS")
			_exit_experience()
	if smoke_test and frames == 15:
		_run_smoke_test()

func _recenter_stage() -> void:
	stage.global_position = camera.global_position
	stage.rotation.y = camera.global_rotation.y

func _update_desktop_camera() -> void:
	var target := Vector3(0.32,-0.52,-1.35)
	camera.position = target+Vector3(sin(yaw)*cos(pitch),sin(pitch),cos(yaw)*cos(pitch))*zoom
	camera.look_at(target)

func _unhandled_input(event: InputEvent) -> void:
	if xr_active:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var hit := _pick(camera.project_ray_origin(event.position),camera.project_ray_normal(event.position))
			if not hit.is_empty():
				_begin_desktop_grab(hit,event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.shift_pressed:
				_activate(114)
			else:
				zoom = maxf(1.8,zoom-0.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.shift_pressed:
				_activate(113)
			else:
				zoom = minf(4.5,zoom+0.15)
		_update_desktop_camera()
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		yaw -= event.relative.x*0.005
		pitch = clampf(pitch+event.relative.y*0.004,0.15,1.25)
		_update_desktop_camera()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_activate(100)
		elif event.keycode == KEY_ESCAPE:
			_select_planet(-1)
		elif event.keycode >= KEY_1 and event.keycode <= KEY_8:
			_select_planet(event.keycode-KEY_1)

func _pick(ray_origin: Vector3, direction: Vector3) -> Dictionary:
	var closest := INF
	var result: Dictionary = {}
	for item in targets:
		var node: Node3D = item.node
		if not node.is_visible_in_tree():
			continue
		var dist := -1.0
		if item.has("half_size"):
			var local_origin := node.to_local(ray_origin)
			var local_dir := node.global_basis.inverse()*direction
			if absf(local_dir.z)>0.001:
				dist = -local_origin.z/local_dir.z
				var pos := local_origin+local_dir*dist
				if absf(pos.x)>item.half_size.x or absf(pos.y)>item.half_size.y:
					dist = -1
		else:
			var offset := ray_origin-node.global_position
			var b := offset.dot(direction)
			var radius: float = item.radius*node.global_basis.get_scale().x
			if int(item.action)<8:
				radius = maxf(float(records[int(item.action)].radius_ratio_earth)*0.0075*node.global_basis.get_scale().x,0.036)
			var disc: float = b*b-offset.length_squared()+radius*radius
			if disc >= 0:
				dist = -b-sqrt(disc)
		if dist>0 and dist<closest:
			closest = dist
			result = {"action":item.action,"distance":dist}
	return result

func _setup_hands() -> void:
	for side in ["left","right"]:
		var aim := XRController3D.new()
		aim.tracker = side+"_hand"
		aim.pose = "aim"
		origin.add_child(aim)
		var joint_root := Node3D.new()
		origin.add_child(joint_root)
		var dots: Array[MeshInstance3D] = []
		var mat := _material(ACCENT)
		for i in 26:
			dots.append(_sphere(joint_root,0.004,mat))
		var ray_mesh := ImmediateMesh.new()
		var ray := MeshInstance3D.new()
		ray.mesh = ray_mesh
		ray.material_override = mat
		add_child(ray)
		var cursor := _sphere(self,0.008,_material(ACCENT))
		hands.append({"side":side,"aim":aim,"dots":dots,"root":joint_root,"ray":ray,"ray_mesh":ray_mesh,"cursor":cursor,"pinched":false,"armed":false,"direction":Vector3.FORWARD,"grasped":false,"grab_mode":""})

func _update_hands(delta: float) -> void:
	if not input_focused:
		return
	var tracking_frame := XRServer.get_reference_frame()
	var tracking_scale := XRServer.world_scale
	for hand in hands:
		var tracker := XRServer.get_tracker("/user/hand_tracker/"+hand.side) as XRHandTracker
		var tracked := tracker != null and tracker.has_tracking_data
		hand.root.visible = tracked
		var aim: XRController3D = hand.aim
		var aim_valid := aim.get_is_active() and aim.get_has_tracking_data()
		var pointing := false
		var pinch := false
		var fist := false
		var hand_pose := Transform3D.IDENTITY
		var hand_position_valid := false
		var ray_origin := Vector3.ZERO
		var direction := Vector3.FORWARD
		if tracked:
			for i in 26:
				var valid := (tracker.get_hand_joint_flags(i)&XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)!=0
				hand.dots[i].visible = valid
				if valid:
					hand.dots[i].transform = _adjust_hand_transform(tracker.get_hand_joint_transform(i),tracking_frame,tracking_scale)
			var thumb_valid := (tracker.get_hand_joint_flags(5)&XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)!=0
			var index_valid := (tracker.get_hand_joint_flags(10)&XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)!=0
			if thumb_valid and index_valid:
				var thumb: Vector3 = tracker.get_hand_joint_transform(5).origin
				var index: Vector3 = tracker.get_hand_joint_transform(10).origin
				var separation := thumb.distance_to(index)
				pinch = separation < (0.04 if hand.pinched else 0.025)
				ray_origin = origin.to_global(_adjust_hand_transform(Transform3D(Basis.IDENTITY,(thumb+index)*0.5),tracking_frame,tracking_scale).origin)
				hand_pose = origin.global_transform * _adjust_hand_transform(tracker.get_hand_joint_transform(0),tracking_frame,tracking_scale)
				hand_pose.origin = ray_origin
				hand_position_valid = true
				# A curled middle + ring finger supports a natural closed-hand grab.
				if _joint_valid(tracker,1) and _joint_valid(tracker,15) and _joint_valid(tracker,20):
					var wrist: Vector3 = tracker.get_hand_joint_transform(1).origin
					var limit := 0.085 if hand.grasped else 0.065
					fist = tracker.get_hand_joint_transform(15).origin.distance_to(wrist)<limit and tracker.get_hand_joint_transform(20).origin.distance_to(wrist)<limit
				var shoulder := camera.global_position+camera.global_basis*Vector3(-0.16 if hand.side=="left" else 0.16,-0.18,0)
				direction = (ray_origin-shoulder).normalized()
				pointing = true
		# A palm facing the headset can already signal a reserved OS gesture.
		# Keep valid joints visible; suspend only interaction until focus is lost.
		if _system_gesture_active(hand.side):
			_suspend_hand_input(hand)
			manipulation.feed(hand.side,hand_pose,ray_origin,direction,false,false,{})
			continue
		if aim_valid:
			ray_origin = aim.global_position
			direction = -aim.global_basis.z
			pointing = true
			pinch = pinch or aim.get_float("trigger")>0.7 or aim.is_button_pressed("trigger_click")
			fist = fist or aim.get_float("grip")>0.75
			if not hand_position_valid:
				hand_pose = aim.global_transform
		hand.ray.visible = pointing
		hand.cursor.visible = pointing
		if not pointing:
			hand.pinched = false
			hand.armed = false
			hand.grasped = false
			hand.grab_mode = ""
			manipulation.feed(hand.side,hand_pose,ray_origin,direction,false,false,{})
			continue
		# A released gesture must be observed after tracking resumes.
		if not pinch:
			hand.armed = true
		hand.direction = Vector3(hand.direction).slerp(direction,1.0-exp(-18.0*delta)).normalized()
		direction = hand.direction
		var hit := _pick(ray_origin,direction)
		var near_hit := _pick_near(hand_pose.origin,fist and hand.grab_mode!="pinch")
		if not near_hit.is_empty():
			hit = near_hit
		hovered = int(hit.get("action",-1))
		# Latch the initial gesture: opening a pinch must release even if other fingers stay curled.
		if not pinch and not fist:
			hand.grab_mode = ""
		var gesture := pinch or (fist and not near_hit.is_empty())
		if hand.grab_mode=="pinch":
			gesture = pinch
		elif hand.grab_mode=="fist":
			gesture = fist
		if gesture and hand.grab_mode.is_empty():
			hand.grab_mode = "fist" if fist and near_hit.get("action",-1)==111 else ("pinch" if pinch else "fist")
		manipulation.feed(hand.side,hand_pose,ray_origin,direction,gesture,true,hit,not near_hit.is_empty())
		var ray_end := ray_origin+direction*float(hit.get("distance",1.5))
		hand.cursor.position = ray_end
		hand.cursor.scale = Vector3.ONE*(1.4 if not hit.is_empty() else 0.6)
		var lines: ImmediateMesh = hand.ray_mesh
		lines.clear_surfaces()
		lines.surface_begin(Mesh.PRIMITIVE_LINES)
		lines.surface_add_vertex(ray_origin)
		lines.surface_add_vertex(ray_end)
		lines.surface_end()
		hand.pinched = pinch
		hand.grasped = fist

func _system_gesture_active(side: String) -> bool:
	var aim_tracker := XRServer.get_tracker("/user/fbhandaim/"+side) as XRPositionalTracker
	if aim_tracker==null:
		return false
	if side=="left":
		return bool(aim_tracker.get_input("menu_gesture")) or bool(aim_tracker.get_input("menu_pressed"))
	return bool(aim_tracker.get_input("system_gesture"))

func _hide_hand(hand: Dictionary) -> void:
	hand.root.visible = false
	_suspend_hand_input(hand)

func _suspend_hand_input(hand: Dictionary) -> void:
	hand.ray.visible = false
	hand.cursor.visible = false
	hand.pinched = false
	hand.armed = false
	hand.grasped = false
	hand.grab_mode = ""

func _on_session_unfocus() -> void:
	input_focused = false
	manipulation.release_all()
	desktop_drag = false
	for hand in hands:
		_hide_hand(hand)
	hovered = -1
	info_panel.set_hover(-1)
	# Stop simulation/input, while the XR viewport keeps rendering the scene.
	set_process(false)

func _on_session_focus() -> void:
	input_focused = true
	set_process(true)

func _run_smoke_test() -> void:
	assert(planets.size()==8)
	assert(is_equal_approx(float(records[2].radius_ratio_earth),1.0))
	for i in 8:
		_activate(i)
		assert(selected==i)
		assert(records[i].name in info_3d.text.capitalize() or records[i].name.to_upper() in info_3d.text)
	# Probe a real planet ray away from the Sun and other orbital positions.
	var earth := planets[2].global_position
	var hit := _pick(earth+Vector3(0,2,0), Vector3.DOWN)
	assert(hit.get("action", -1) == 2)
	var before := sim_time
	_activate(100)
	_process(0.25)
	assert(sim_time==before)
	_activate(100)
	_activate(101)
	assert(speed==4.0)
	_activate(102)
	assert(selected==-1)
	_test_hand_selection()
	_test_manipulation()
	_test_side_card()
	_test_card_targets()
	_test_sun_grab_and_recenter()
	_test_hand_reference_frame_and_card_clearance()
	_test_outer_orbit_clearance()
	print("SMOKE_TEST_PASS: orbits, selection, pinch, tracking loss, grab/return, button zoom limits, Sun info/grab, recenter, panel, Earth companions")
	get_tree().quit()

func _capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://builds/screenshots"))
	get_viewport().get_texture().get_image().save_png("res://builds/screenshots/" + ("xr-readback.png" if xr_active else "desktop.png"))
	print("SCREENSHOT_SAVED")
	get_tree().quit()

func _test_hand_selection() -> void:
	_setup_hands()
	camera.transform = Transform3D.IDENTITY
	var tracker := XRHandTracker.new()
	tracker.name = "/user/hand_tracker/left"
	tracker.hand = XRPositionalTracker.TRACKER_HAND_LEFT
	tracker.has_tracking_data = true
	XRServer.add_tracker(tracker)
	var shoulder := Vector3(-0.16,-0.18,0)
	var center := shoulder.lerp(planets[2].global_position,0.25)
	for i in 26:
		tracker.set_hand_joint_flags(i, XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)
		tracker.set_hand_joint_transform(i,Transform3D(Basis.IDENTITY,center))
	for joint in [15,20]:
		tracker.set_hand_joint_transform(joint,Transform3D(Basis.IDENTITY,center+Vector3(0,0.14,0)))
	tracker.set_hand_joint_transform(5,Transform3D(Basis.IDENTITY,center+Vector3(0.03,0,0)))
	tracker.set_hand_joint_transform(10,Transform3D(Basis.IDENTITY,center-Vector3(0.03,0,0)))
	_update_hands(1.0)
	tracker.set_hand_joint_transform(5,Transform3D(Basis.IDENTITY,center+Vector3(0.005,0,0)))
	tracker.set_hand_joint_transform(10,Transform3D(Basis.IDENTITY,center-Vector3(0.005,0,0)))
	_update_hands(1.0)
	assert(selected==2, "Synthetic hand pinch must select Earth")
	assert(manipulation.planet_is_held(2))
	# Opening the pinch releases even while middle/ring remain curled.
	tracker.set_hand_joint_transform(5,Transform3D(Basis.IDENTITY,center+Vector3(0.03,0,0)))
	tracker.set_hand_joint_transform(10,Transform3D(Basis.IDENTITY,center-Vector3(0.03,0,0)))
	for joint in [15,20]:
		tracker.set_hand_joint_transform(joint,Transform3D(Basis.IDENTITY,center))
	_update_hands(1.0)
	assert(not manipulation.planet_is_held(2), "Opening the original pinch must release")
	tracker.set_hand_joint_transform(5,Transform3D(Basis.IDENTITY,center+Vector3(0.005,0,0)))
	tracker.set_hand_joint_transform(10,Transform3D(Basis.IDENTITY,center-Vector3(0.005,0,0)))
	_update_hands(1.0)
	assert(manipulation.planet_is_held(2))
	var meta_aim := XRPositionalTracker.new()
	meta_aim.name = "/user/fbhandaim/left"
	meta_aim.set_input("menu_gesture",true)
	meta_aim.set_input("menu_pressed",false)
	XRServer.add_tracker(meta_aim)
	var turned_palm := Transform3D(Basis.from_euler(Vector3(0,PI,0)),center)
	tracker.set_hand_joint_transform(0,turned_palm)
	_update_hands(1.0)
	assert(not manipulation.planet_is_held(2) and hands[0].root.visible)
	assert(hands[0].dots[0].visible)
	assert(hands[0].dots[0].transform.is_equal_approx(_adjust_hand_transform(turned_palm,XRServer.get_reference_frame(),XRServer.world_scale)))
	assert(not hands[0].ray.visible and not hands[0].cursor.visible)
	meta_aim.set_input("menu_gesture",false)
	_update_hands(1.0)
	assert(not manipulation.planet_is_held(2),"Returning from OS gesture requires an open hand")
	# The right-hand OS gesture uses a distinct tracker input.
	var right_meta := XRPositionalTracker.new()
	right_meta.name = "/user/fbhandaim/right"
	right_meta.set_input("system_gesture",true)
	XRServer.add_tracker(right_meta)
	assert(_system_gesture_active("right"))
	var right_hand := XRHandTracker.new()
	right_hand.name = "/user/hand_tracker/right"
	right_hand.hand = XRPositionalTracker.TRACKER_HAND_RIGHT
	right_hand.has_tracking_data = true
	right_hand.set_hand_joint_flags(0,XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)
	right_hand.set_hand_joint_transform(0,turned_palm)
	XRServer.add_tracker(right_hand)
	_update_hands(1.0)
	assert(hands[1].root.visible and hands[1].dots[0].visible)
	assert(not hands[1].ray.visible and not hands[1].cursor.visible)
	XRServer.remove_tracker(right_hand)
	XRServer.remove_tracker(right_meta)
	_on_session_unfocus()
	assert(not input_focused and not is_processing())
	for hand in hands:
		assert(not hand.root.visible and not hand.ray.visible and not hand.cursor.visible)
	_update_hands(1.0)
	assert(not manipulation.planet_is_held(2))
	_on_session_focus()
	assert(input_focused and is_processing())
	XRServer.remove_tracker(meta_aim)
	print("PALM_VISIBILITY_PASS: both turned palms stay visible with valid tracking; OS gestures block interaction only")
	print("FOCUS_SYSTEM_GESTURE_PASS: hands hidden on actual focus loss, released grabs, no OS gesture activation, re-arm required")
	tracker.has_tracking_data = false
	_update_hands(1.0)
	assert(not hands[0].armed and not hands[0].cursor.visible)
	XRServer.remove_tracker(tracker)

func _joint_valid(tracker: XRHandTracker, joint: int) -> bool:
	return (tracker.get_hand_joint_flags(joint)&XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)!=0

func _pick_near(point: Vector3, grab_card_anywhere := false) -> Dictionary:
	var card_hit: Dictionary = info_panel.pick_surface(point,grab_card_anywhere)
	if not card_hit.is_empty():
		return card_hit
	var best := INF
	var result: Dictionary = {}
	for item in targets:
		var action := int(item.action)
		if action >= 8 and action not in [120,111,140,141]:
			continue
		var node: Node3D = item.node
		if not node.is_visible_in_tree():
			continue
		if item.has("half_size"):
			var local := node.to_local(point)
			if absf(local.x) < item.half_size.x+0.02 and absf(local.y)<item.half_size.y+0.02 and absf(local.z)<0.06:
				var distance := node.global_position.distance_to(point)
				if distance<best:
					best=distance
					result={"action":action,"distance":0.03}
		else:
			var radius: float = item.radius*node.global_basis.get_scale().x+0.025
			if action<8:
				radius = maxf(float(records[action].radius_ratio_earth)*0.0075*node.global_basis.get_scale().x,0.036)+0.025
			var distance := point.distance_to(node.global_position)
			if distance<radius and distance<best:
				best=distance
				result={"action":action,"distance":distance}
	return result

func _select_companion(index: int) -> void:
	if not earth_companions.visible:
		return
	companion_selected = index
	selected = 2
	var d: Dictionary = EarthCompanions.RECORDS[index]
	var image_id: String = ["moon","iss","hubble"][index]
	_present_card(d.name,d.kind,d.facts,d.story,image_id)
	journey.select_companion(index,manipulation.planet_is_held(2))

func _reset_space() -> void:
	journey.reset_motion()
	manipulation.release_all()
	desktop_drag = false
	universe.transform = system_home
	info_panel.transform = panel_home
	if not xr_active:
		info_panel._fit_desktop()
	_select_planet(-1)

func _input(event: InputEvent) -> void:
	if not xr_active and event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed:
		desktop_drag = false
		manipulation.release("desktop")
		if manipulation.sources.has("desktop"):
			manipulation.sources.desktop.active = false
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_R:
		_request_recenter_view()

func _begin_desktop_grab(hit: Dictionary, mouse: Vector2) -> void:
	var ray_origin := camera.project_ray_origin(mouse)
	var direction := camera.project_ray_normal(mouse)
	var pose := Transform3D(camera.global_basis,ray_origin+direction*float(hit.distance))
	desktop_plane_point = pose.origin
	desktop_plane_normal = camera.global_basis.z
	desktop_hit = hit
	manipulation.feed("desktop",pose,ray_origin,direction,false,true,hit,true)
	manipulation.feed("desktop",pose,ray_origin,direction,true,true,hit,true)
	desktop_drag = manipulation.holds.has("desktop")

func _update_desktop_grab() -> void:
	if not desktop_drag:
		return
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse)
	var direction := camera.project_ray_normal(mouse)
	var denominator := direction.dot(desktop_plane_normal)
	if absf(denominator)<0.001:
		return
	var distance := (desktop_plane_point-ray_origin).dot(desktop_plane_normal)/denominator
	var pose := Transform3D(camera.global_basis,ray_origin+direction*distance)
	manipulation.feed("desktop",pose,ray_origin,direction,true,true,desktop_hit,true)

func _preview_earth() -> void:
	var position := camera.global_position-camera.global_basis.z*0.75-camera.global_basis.x*0.18
	var pose := Transform3D(Basis.IDENTITY,position)
	planets[2].global_position = position
	manipulation.feed("preview",pose,position,Vector3.FORWARD,false,true,{},true)
	manipulation.feed("preview",pose,position,Vector3.FORWARD,true,true,{"action":2},true)

func _test_manipulation() -> void:
	manipulation.release_all()
	var original := planets[2].global_position
	var pose := Transform3D(Basis.IDENTITY,original)
	manipulation.feed("test",pose,original,Vector3.FORWARD,false,true,{})
	manipulation.feed("test",pose,original,Vector3.FORWARD,true,true,{"action":2},true)
	pose.origin += Vector3(0.1,0.2,0.05)
	manipulation.feed("test",pose,pose.origin,Vector3.FORWARD,true,true,{})
	manipulation.advance(1.0)
	assert(manipulation.planet_is_held(2))
	assert(planets[2].global_position.distance_to(pose.origin)<0.01)
	earth_companions.advance(0.2,true,true)
	assert(earth_companions.visible and earth_companions.worlds.size()==3)
	_select_companion(1)
	assert("ISS" in info_3d.text)
	manipulation.feed("test",pose,pose.origin,Vector3.FORWARD,false,false,{})
	assert(not manipulation.planet_is_held(2) and manipulation.returning.has(2))
	var destination := Vector3(0.1,0,0.2)
	for i in 180:
		destination.x += 0.00001
		manipulation.orbit_planet(2,destination,1.0/60)
	assert(planets[2].position.distance_to(destination)<0.002)
	assert(planets[2].scale.distance_to(Vector3.ONE)<0.015)
	# Button zoom preserves position/orientation, clamps size, and ignores removed gestures.
	var base := universe.transform
	_activate(114)
	assert(is_equal_approx(universe.scale.x,1.25))
	assert(universe.position.is_equal_approx(base.origin))
	assert(universe.basis.orthonormalized().is_equal_approx(base.basis.orthonormalized()))
	_activate(113)
	assert(universe.transform.is_equal_approx(base))
	for i in 30:
		_activate(114)
	assert(is_equal_approx(universe.scale.x,2.5))
	for i in 30:
		_activate(113)
	assert(is_equal_approx(universe.scale.x,0.45))
	var before := universe.transform
	manipulation.feed("old",pose,pose.origin,Vector3.FORWARD,false,true,{})
	manipulation.feed("old",pose,pose.origin,Vector3.FORWARD,true,true,{"action":110})
	pose.origin+=Vector3.ONE
	manipulation.feed("old",pose,pose.origin,Vector3.FORWARD,true,true,{})
	manipulation.advance(0.1)
	assert(universe.transform.is_equal_approx(before))
	assert(not manipulation.holds.has("old"))
	_activate(116)
	assert("SUN" in info_3d.text and "helium" in info_3d.text)
	assert(sun_highlight.visible)
	var sun_hit := _pick(universe.global_position+Vector3(0,1,0),Vector3.DOWN)
	assert(sun_hit.get("action",-1)==120)
	_select_planet(2)
	assert(not sun_highlight.visible)
	manipulation.release_all()
	# Ray targets must follow the zoomed world scale.
	earth_companions.visible = false
	var earth := planets[2].global_position
	var normal := universe.global_basis.y.normalized()
	var hit := _pick(earth+normal*2.0,-normal)
	assert(hit.get("action",-1)==2)
	var panel_before := info_panel.global_position
	manipulation.feed("panel",pose,pose.origin,Vector3.FORWARD,false,true,{})
	manipulation.feed("panel",pose,pose.origin,Vector3.FORWARD,true,true,{"action":111})
	pose.origin += Vector3(0.1,0.1,0)
	manipulation.feed("panel",pose,pose.origin,Vector3.FORWARD,true,true,{})
	manipulation.advance(0.1)
	assert(info_panel.global_position.distance_to(panel_before+Vector3(0.1,0.1,0))<0.002)
	_reset_space()
	assert(manipulation.holds.is_empty())
	assert(universe.transform.is_equal_approx(system_home))

func _zoom_system(multiplier: float) -> void:
	# Resize about the Sun. A planet already held in the hand stays in that hand.
	var detached: Dictionary = {}
	for index in manipulation.owners:
		if int(index)<8:
			detached[index] = planets[int(index)].global_transform
	var factor := clampf(universe.scale.x*multiplier,0.45,2.5)
	universe.scale = Vector3.ONE*factor
	for index in detached:
		planets[int(index)].global_transform = detached[index]

func _select_sun() -> void:
	_select_planet(-1)
	sun_highlight.visible = true
	_present_card("Sun", "OUR STAR", "Age: about 4.5 billion years\nComposition: hydrogen and helium\nFrom Earth: about 150 million km", "The Sun's gravity holds our solar system together. Its energy makes life on Earth possible.", "sun")

func _test_side_card() -> void:
	for i in 8:
		_select_planet(i)
		assert(info_panel.heading.text==records[i].name)
		assert(info_panel.preview.texture!=null)
		assert(info_panel.preview_id==records[i].id)
	_select_sun()
	assert(info_panel.preview_id=="sun" and info_panel.preview.texture!=null)
	for i in 3:
		earth_companions.visible=true
		_select_companion(i)
		assert(info_panel.preview.texture!=null)
	var pose := Transform3D(Basis.IDENTITY,planets[2].global_position)
	manipulation.feed("world",pose,pose.origin,Vector3.FORWARD,false,true,{})
	manipulation.feed("world",pose,pose.origin,Vector3.FORWARD,true,true,{"action":2},true)
	var panel_pose := Transform3D(Basis.IDENTITY,info_panel.global_position)
	manipulation.feed("card",panel_pose,panel_pose.origin,Vector3.FORWARD,false,true,{})
	manipulation.feed("card",panel_pose,panel_pose.origin,Vector3.FORWARD,true,true,{"action":111},true)
	pose.origin+=Vector3(0.1,0.05,0)
	panel_pose.origin+=Vector3(0.1,0,0)
	manipulation.feed("world",pose,pose.origin,Vector3.FORWARD,true,true,{})
	manipulation.feed("card",panel_pose,panel_pose.origin,Vector3.FORWARD,true,true,{})
	manipulation.advance(1.0)
	assert(manipulation.planet_is_held(2) and manipulation.panel_owner=="card")
	assert(planets[2].global_position.distance_to(pose.origin)<0.002)
	assert(info_panel.global_position.distance_to(panel_pose.origin)<0.002)
	manipulation.release("card")
	assert(manipulation.planet_is_held(2))
	_activate(113)
	assert(manipulation.planet_is_held(2))
	_activate(301)
	assert(info_panel.heading.text=="Venus" and manipulation.planet_is_held(2))
	_reset_space()
	print("SIDE_CARD_PASS: all previews, simultaneous planet/card grab, independent card release, zoom and navigation while holding")

func _test_card_targets() -> void:
	# The 3D ray targets must match every visible 2D button even after card rotation.
	var start := targets.size()
	var old_mode := xr_active
	xr_active = true
	var test_card := SideCard.new()
	stage.add_child(test_card)
	test_card.position = Vector3(-2.0,0.1,-0.8)
	test_card.rotation_degrees = Vector3(10,30,-8)
	test_card.setup(self)
	xr_active = old_mode
	var normal := test_card.global_basis.z
	for i in range(start+1,targets.size()):
		var item: Dictionary = targets[i]
		var position: Vector3 = item.node.global_position
		var hit := _pick(position+normal*0.2,-normal)
		assert(hit.get("action",-1)==item.action,"Side card button ray target mismatch")
	var blank := test_card.to_global(Vector3(-0.18,0.2,0))
	assert(_pick(blank+normal*0.2,-normal).get("action",-1)==111)
	targets.resize(start)
	test_card.free()
	print("CARD_TARGETS_PASS: drag handle, all buttons, rotated card and background occlusion")

func _request_recenter_view() -> void:
	if recenter_pending:
		return
	recenter_pending = true
	manipulation.release_all()
	desktop_drag = false
	if xr_active:
		# Stage reference space: align tracking origin to current HMD position + yaw.
		# Keep head tilt; the experience remains level instead of pitching with the head.
		XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT,false)
		await get_tree().process_frame
		await get_tree().process_frame
		_place_content_in_front(camera.global_transform)
	else:
		yaw=0.0
		pitch=0.55
		zoom=2.8
		_place_content_in_front(Transform3D.IDENTITY)
		info_panel._fit_desktop()
		_update_desktop_camera()
	recenter_pending = false
	print("VIEW_RECENTERED")

func _place_content_in_front(head: Transform3D) -> void:
	journey.reset_motion()
	manipulation.release_all()
	var current_scale := universe.scale.x
	stage.global_transform = Transform3D(Basis.from_euler(Vector3(0,head.basis.get_euler().y,0)),head.origin)
	universe.transform = system_home
	universe.scale = Vector3.ONE*current_scale
	info_panel.transform = panel_home
	manipulation.returning.clear()
	for i in planets.size():
		var period := 18.0*pow(float(records[i].orbital_period_days)/88.0,0.28)
		var angle: float = START_ANGLES[i]+sim_time*TAU/period
		planets[i].transform = Transform3D(Basis.IDENTITY,Vector3(cos(angle)*ORBIT_RADII[i],0,sin(angle)*ORBIT_RADII[i]))

func _exit_experience() -> void:
	manipulation.release_all()
	desktop_drag = false
	exit_requested = true
	print("EXIT_EXPERIENCE_REQUESTED")
	get_tree().quit()

func _test_sun_grab_and_recenter() -> void:
	_reset_space()
	var base := universe.global_transform
	var pose := Transform3D(Basis.IDENTITY,universe.global_position+Vector3(0,0,0.1))
	manipulation.feed("sun",pose,pose.origin,Vector3.FORWARD,false,true,{})
	manipulation.feed("sun",pose,pose.origin,Vector3.FORWARD,true,true,{"action":120})
	manipulation.advance(1.0)
	assert(universe.global_transform.is_equal_approx(base),"Grabbing Sun must not snap system")
	pose.origin+=Vector3(0.2,0.1,0.05)
	pose.basis=Basis.from_euler(Vector3(0.3,0.2,0.1))
	manipulation.feed("sun",pose,pose.origin,Vector3.FORWARD,true,true,{})
	manipulation.advance(1.0)
	assert(universe.global_position.distance_to(base.origin+Vector3(0.2,0.1,0.05))<0.002)
	assert(universe.global_basis.is_equal_approx(base.basis),"Sun grab must not rotate the system")
	manipulation.release("sun")
	var released := universe.global_transform
	manipulation.advance(1.0)
	assert(universe.global_transform.is_equal_approx(released),"Sun release keeps placement")
	assert(manipulation.system_owner.is_empty())
	var world_pose := Transform3D(Basis.IDENTITY,planets[2].global_position)
	manipulation.feed("other",world_pose,world_pose.origin,Vector3.FORWARD,false,true,{})
	manipulation.feed("other",world_pose,world_pose.origin,Vector3.FORWARD,true,true,{"action":2},true)
	manipulation.feed("sun",pose,pose.origin,Vector3.FORWARD,false,true,{})
	manipulation.feed("sun",pose,pose.origin,Vector3.FORWARD,true,true,{"action":120})
	pose.origin.x+=0.1
	manipulation.feed("sun",pose,pose.origin,Vector3.FORWARD,true,true,{})
	manipulation.advance(1.0)
	assert(planets[2].global_position.distance_to(world_pose.origin)<0.002)
	manipulation.feed("sun",pose,pose.origin,Vector3.FORWARD,false,false,{})
	assert(manipulation.system_owner.is_empty() and manipulation.planet_is_held(2))
	manipulation.release_all()
	_select_sun()
	assert(info_panel.preview.texture==SideCard.SUN_PREVIEW)
	var sun_image: Image = info_panel.preview.texture.get_image()
	if sun_image.is_compressed():
		sun_image.decompress()
	var center_color: Color = sun_image.get_pixel(sun_image.get_width()/2,sun_image.get_height()/2)
	assert(center_color.r-center_color.g>0.1 and center_color.g>center_color.b,"Sun preview must be the warm Sun image, not Saturn")
	assert(info_panel.controls.has(118) and info_panel.controls.has(119))
	_zoom_system(1.25)
	var time_before := sim_time
	var paused_before := paused
	var head := Transform3D(Basis.from_euler(Vector3(-0.2,PI/2,0.12)),Vector3(1.2,1.6,-0.7))
	_place_content_in_front(head)
	assert(stage.global_position.is_equal_approx(head.origin))
	assert(stage.global_basis.y.is_equal_approx(Vector3.UP),"Recenter must leave world level")
	assert(is_equal_approx(stage.global_rotation.y,head.basis.get_euler().y))
	assert(universe.position.is_equal_approx(system_home.origin))
	assert(info_panel.transform.is_equal_approx(panel_home))
	assert(is_equal_approx(universe.scale.x,1.25))
	assert(sim_time==time_before and paused==paused_before)
	assert(manipulation.holds.is_empty())
	stage.transform=Transform3D.IDENTITY
	_reset_space()
	print("SUN_RECENTER_PASS: no-snap translation, stable release, explicit Sun preview, new buttons, head-relative level recenter preserving zoom/time")

func _adjust_hand_transform(raw: Transform3D, reference: Transform3D, world_scale: float) -> Transform3D:
	# Same conversion used by XRPose.get_adjusted_transform(): joints are raw tracking poses.
	var adjusted := raw
	adjusted.origin *= world_scale
	return reference*adjusted

func _test_hand_reference_frame_and_card_clearance() -> void:
	var raw_hand := Transform3D(Basis.from_euler(Vector3(0.1,0.3,0)),Vector3(0.25,1.35,-0.45))
	var reference := Transform3D(Basis.from_euler(Vector3(0,-PI/2,0)),Vector3(-1,-1.6,0.2))
	var adjusted := _adjust_hand_transform(raw_hand,reference,1.0)
	assert(adjusted.origin.is_equal_approx(reference*raw_hand.origin))
	assert(adjusted.basis.is_equal_approx(reference.basis*raw_hand.basis))
	assert(adjusted.origin.distance_to(raw_hand.origin)>1.0,"Regression: unadjusted hands would remain outside the recentered view")
	assert(_adjust_hand_transform(raw_hand,Transform3D.IDENTITY,1.0).is_equal_approx(raw_hand))
	var scaled := _adjust_hand_transform(raw_hand,reference,2.0)
	assert(scaled.origin.is_equal_approx(reference*(raw_hand.origin*2.0)))
	_reset_space()
	var max_orbit_x := 0.0
	var max_body_radius := 0.085
	for i in records.size():
		max_orbit_x=maxf(max_orbit_x,ORBIT_RADII[i]+float(records[i].radius_ratio_earth)*0.0075)
		max_body_radius=maxf(max_body_radius,float(records[i].radius_ratio_earth)*0.0075)
		for child in planets[i].get_children():
			if child is MeshInstance3D and child.mesh is TorusMesh:
				max_body_radius=maxf(max_body_radius,child.mesh.outer_radius)
	var half_width: float=SideCard.SIZE.x*SideCard.METRES_PER_PIXEL*0.5
	var left_edge := info_panel.position.x-absf(info_panel.basis.x.x)*half_width
	var half_height: float=SideCard.SIZE.y*SideCard.METRES_PER_PIXEL*0.5
	var bottom_edge := info_panel.position.y-absf(info_panel.basis.y.y)*half_height-absf(info_panel.basis.x.y)*half_width
	var system_top := universe.position.y+max_body_radius
	assert(left_edge>max_orbit_x+0.06 or bottom_edge>system_top+0.06,"Initial card must stay clear of planets and Saturn rings")
	print("HANDS_CARD_PASS: recentered/scaled joints, identity tracking, default card clear of initial orbits")

func _test_outer_orbit_clearance() -> void:
	# Bounding spheres prove separation at every orbital phase and shared zoom.
	# Measure the meshes, including Saturn's ring thickness and inclination.
	var bounds: Array[float] = []
	for i in range(4,8):
		var radius := 0.0
		for child in planets[i].get_children():
			if child is MeshInstance3D:
				if child.mesh is SphereMesh:
					radius=maxf(radius,child.mesh.radius)
				elif i==5 and child.mesh is TorusMesh:
					radius=maxf(radius,child.mesh.outer_radius)
		bounds.append(radius)
	for i in 3:
		var gap: float=ORBIT_RADII[i+5]-ORBIT_RADII[i+4]-bounds[i]-bounds[i+1]
		assert(gap>0.02,"Adjacent outer planets/rings need 2cm of clearance")
	print("OUTER_ORBITS_PASS: Jupiter, Saturn rings, Uranus and Neptune separated at all orbital phases")
