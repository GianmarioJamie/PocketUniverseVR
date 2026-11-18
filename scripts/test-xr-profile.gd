extends SceneTree
## Test-only runner: use real runtime trackers and separate scripted grab sources.
## It is excluded from exported APKs by export_presets.cfg.
var app: Node
var started := false
var ready_frames := 0
var last_state := ""
var interactive := false

func _initialize() -> void:
	interactive = "--interactive" in OS.get_cmdline_user_args()
	var boot: Node = load("res://scenes/boot.tscn").instantiate()
	root.add_child.call_deferred(boot)
	set_current_scene.call_deferred(boot)

func _process(_delta: float) -> bool:
	if not started:
		if current_scene==null or current_scene.scene_file_path!="res://scenes/main.tscn":
			return false
		app = current_scene
		if not app.input_focused:
			return false
		ready_frames+=1
		if ready_frames==15:
			started = true
			_check.call_deferred()
	elif interactive and is_instance_valid(app):
		var state := "selected=%d companion=%d paused=%s size=%.2f holds=%s" % [app.selected,app.companion_selected,str(app.paused),app.universe.scale.x,str(app.manipulation.holds.keys())]
		if state!=last_state:
			print("XR_FRONTEND_STATE ",state)
			last_state=state
	return false

func _check() -> void:
	var xr := XRServer.find_interface("OpenXR")
	assert(app.xr_active and xr.is_initialized())
	if xr.has_method("get_system_info"):
		print("XR_PROFILE_RUNTIME_INFO ",JSON.stringify(xr.get_system_info()))
	var actual_trackers: Array[XRHandTracker] = []
	for side in ["left","right"]:
		var tracker := XRServer.get_tracker("/user/hand_tracker/"+side) as XRHandTracker
		assert(tracker!=null and tracker.has_tracking_data,"Enable both hands in simulator")
		actual_trackers.append(tracker)
	print("XR_PROFILE_RUNTIME_HANDS count=",actual_trackers.size())
	var initial_distance: float=app.info_panel.global_position.distance_to(app.camera.global_position)
	var initial_drop: float=app.camera.global_position.y-app.universe.global_position.y
	assert(initial_distance<1.30 and initial_drop>0.45,"New default should start closer and lower relative to the HMD")
	print("XR_DEFAULT_LAYOUT_PASS card_distance=",initial_distance," system_drop=",initial_drop)
	app._test_manipulation()
	app._test_side_card()
	app._test_card_targets()
	app._test_sun_grab_and_recenter()
	app._activate(130)
	assert(app.journey.mode==1 and app.journey.target_action()==2)
	assert(app.info_panel.controls.has(130) and app.info_panel.controls.has(131))
	assert(app.info_panel.tour_instruction.text.contains("Earth"))
	app._activate(131)
	assert(app.journey.mode==0)
	print("XR_JOURNEY_CARD_PASS: tour start/free explore and spatial targets")
	var dock: Transform3D=app.card_distance_controls.global_transform
	var dock_local: Transform3D=app.card_distance_controls.transform
	var card_distance: float=app.info_panel.global_position.distance_to(app.camera.global_position)
	app._activate(140)
	assert(is_equal_approx(app.info_panel.global_position.distance_to(app.camera.global_position),card_distance-0.15))
	assert(app.card_distance_controls.global_transform.is_equal_approx(app.info_panel.global_transform*dock_local))
	assert(not app.card_distance_controls.global_transform.is_equal_approx(dock))
	app._activate(141)
	assert(app.card_distance_controls.global_transform.is_equal_approx(dock))
	print("XR_CARD_DISTANCE_PASS: side buttons follow the card while adjusting distance")
	print("XR_PROFILE_SCRIPTED_CHECKS_COMPLETE: grab/return, Earth companions, zoom, card, Sun")
	app._activate(118)
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	assert(not app.recenter_pending)
	assert(app.stage.global_position.distance_to(app.camera.global_position)<0.01)
	assert(app.stage.global_basis.y.is_equal_approx(Vector3.UP))
	assert(app.origin.current)
	var count := 0
	for i in app.hands.size():
		var hand: Dictionary = app.hands[i]
		var tracker := XRServer.get_tracker("/user/hand_tracker/"+hand.side) as XRHandTracker
		assert(tracker==actual_trackers[i],"Runtime tracker must never be replaced by this test")
		assert(tracker.has_tracking_data and hand.root.is_visible_in_tree())
		if app._joint_valid(tracker,0):
			var expected: Transform3D = app._adjust_hand_transform(tracker.get_hand_joint_transform(0),XRServer.get_reference_frame(),XRServer.world_scale)
			assert(hand.dots[0].transform.is_equal_approx(expected))
		count+=1
	print("XR_PROFILE_RECENTER_HANDS_PASS count=",count)
	print("XR_PROFILE_CHECKS_COMPLETE")
	if not interactive:
		app._exit_experience()
