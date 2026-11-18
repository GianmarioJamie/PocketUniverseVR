extends Node3D
## Visible loading scene while resources and the experience initialize.
const EXPERIENCE_PATH := "res://scenes/main.tscn"
var camera: Camera3D
var loading_origin: XROrigin3D
var experience: Node3D
var started := false
var loading_started_ms := 0
var xr_active := false

func _ready() -> void:
	# Android's global output log is a license display supported by Godot.
	# Full dependency notices also ship in assets/licenses inside the APK.
	print(Engine.get_license_text())
	var xr := XRServer.find_interface("OpenXR")
	xr_active = xr != null and xr.is_initialized() and not "--desktop" in OS.get_cmdline_user_args()
	get_viewport().use_xr = xr_active
	if DisplayServer.get_name()=="headless":
		# CI uses the same main scene; no waits on a GPU draw in headless mode.
		experience = load(EXPERIENCE_PATH).instantiate()
		get_tree().root.add_child.call_deferred(experience)
		get_tree().set_current_scene.call_deferred(experience)
		queue_free()
		return
	_setup_loading_view()
	_begin.call_deferred()

func _setup_loading_view() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color("071221")
	environment.environment=env
	add_child(environment)
	if xr_active:
		loading_origin = XROrigin3D.new()
		add_child(loading_origin)
		loading_origin.current=true
		camera=XRCamera3D.new()
		loading_origin.add_child(camera)
	else:
		camera=Camera3D.new()
		add_child(camera)
	camera.current=true
	var screen:=MeshInstance3D.new()
	var mesh:=QuadMesh.new()
	mesh.size=Vector2(1.6,0.8)
	screen.mesh=mesh
	screen.position=Vector3(0,0,-1.3)
	var material:=StandardMaterial3D.new()
	material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture=load("res://assets/loading.png")
	screen.material_override=material
	camera.add_child(screen)

func _begin() -> void:
	await RenderingServer.frame_post_draw
	loading_started_ms=Time.get_ticks_msec()
	print("LOADING_SCREEN_VISIBLE: Pocket Universe VR")
	if "--capture-loading" in OS.get_cmdline_user_args():
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://builds/screenshots/loading.png")
		get_tree().quit()
		return
	var result:=ResourceLoader.load_threaded_request(EXPERIENCE_PATH)
	if result!=OK:
		push_error("Unable to load Pocket Universe VR")
		return
	started=true

func _process(_delta: float) -> void:
	if not started:
		return
	var status:=ResourceLoader.load_threaded_get_status(EXPERIENCE_PATH)
	if status==ResourceLoader.THREAD_LOAD_FAILED or status==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		started=false
		push_error("Pocket Universe VR loading failed")
		return
	if status!=ResourceLoader.THREAD_LOAD_LOADED:
		return
	started=false
	var scene:=ResourceLoader.load_threaded_get(EXPERIENCE_PATH) as PackedScene
	experience=scene.instantiate()
	experience.visible=false
	get_tree().root.add_child(experience)
	experience.set_process(false)
	if not xr_active:
		experience.desk_ui.visible=false
		experience.info_panel.canvas.visible=false
	if xr_active:
		loading_origin.current=true
	camera.make_current()
	_finish.call_deferred()

func _finish() -> void:
	# Keep a rendered loading frame until preparation and card texture are complete.
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var remaining_ms:=850-(Time.get_ticks_msec()-loading_started_ms)
	if remaining_ms>0:
		await get_tree().create_timer(float(remaining_ms)/1000.0).timeout
	camera.current=false
	if xr_active:
		experience.origin.current=true
	experience.camera.make_current()
	experience.visible=true
	if xr_active:
		experience._recenter_stage()
		experience.frames=8
	else:
		experience.desk_ui.visible=true
		experience.info_panel.canvas.visible=true
	experience.set_process(true)
	get_tree().current_scene=experience
	print("LOADING_COMPLETE")
	queue_free()
