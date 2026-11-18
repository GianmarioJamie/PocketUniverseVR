extends SceneTree
var app: Node
var tracker: XRHandTracker
var center := Vector3.ZERO

func _initialize() -> void:
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(app)
	_run.call_deferred()

func _fingers(pinch: bool, fist: bool) -> void:
	for i in 26:
		tracker.set_hand_joint_flags(i,XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)
		tracker.set_hand_joint_transform(i,Transform3D(Basis.IDENTITY,center))
	var gap := 0.005 if pinch else 0.03
	tracker.set_hand_joint_transform(5,Transform3D(Basis.IDENTITY,center+Vector3(gap,0,0)))
	tracker.set_hand_joint_transform(10,Transform3D(Basis.IDENTITY,center-Vector3(gap,0,0)))
	for joint in [15,20]:
		tracker.set_hand_joint_transform(joint,Transform3D(Basis.IDENTITY,center+Vector3(0,0.0 if fist else 0.15,0)))
	app._update_hands(1.0)

func _run() -> void:
	await process_frame
	app.set_process(false)
	var old_panel: Node = app.info_panel
	var old_mode: bool = app.xr_active
	app.xr_active=true
	var card: Node3D = app.SideCard.new()
	app.stage.add_child(card)
	card.position=Vector3(-2.0,0.1,-0.8)
	card.rotation_degrees=Vector3(10,30,-8)
	card.setup(app)
	app.xr_active=old_mode
	app.info_panel=card
	var normal: Vector3=card.global_basis.z
	for pixel in [Vector2(300,42),Vector2(300,230),Vector2(300,462),Vector2(7,540),Vector2(300,1055),Vector2(592,1073)]:
		var local := Vector3((pixel.x-300)*0.00064,-(pixel.y-540)*0.00064,0)
		var world: Vector3=card.to_global(local)
		assert(app._pick(world+normal*0.2,-normal).get("action",-1)==111)
		assert(app._pick_near(world).get("action",-1)==111)
	for action in card.controls:
		var control: Control=card.controls[action]
		var midpoint: Vector2=control.position+control.size*0.5
		var point: Vector3=card.to_global(Vector3((midpoint.x-300)*0.00064,-(midpoint.y-540)*0.00064,0.02))
		assert(app._pick_near(point).get("action",-1)==action,"Pinch must keep button priority")
		assert(app._pick_near(point,true).get("action",-1)==111,"Closed-hand grab must work over every button")
	assert(card.pick_surface(card.to_global(Vector3(0.3,0,0))).is_empty())
	app._setup_hands()
	tracker=XRHandTracker.new()
	tracker.name="/user/hand_tracker/left"
	tracker.hand=XRPositionalTracker.TRACKER_HAND_LEFT
	tracker.has_tracking_data=true
	XRServer.add_tracker(tracker)
	var pause_button: Control=card.controls[100]
	var pixel: Vector2=pause_button.position+pause_button.size*0.5
	var world: Vector3=card.to_global(Vector3((pixel.x-300)*0.00064,-(pixel.y-540)*0.00064,0.02))
	center=(app.origin.global_transform*XRServer.get_reference_frame()).affine_inverse()*world/XRServer.world_scale
	var paused_before: bool=app.paused
	_fingers(false,false)
	_fingers(true,false)
	assert(app.paused!=paused_before and app.manipulation.panel_owner.is_empty(),"Near button pinch should click, not drag")
	_fingers(false,false)
	var before: Transform3D=card.global_transform
	var paused_after: bool=app.paused
	_fingers(false,true)
	app.manipulation.advance(1.0)
	assert(app.manipulation.panel_owner=="left" and app.paused==paused_after)
	assert(card.global_transform.is_equal_approx(before),"Card grab must not snap")
	center+=Vector3(0.10,0.04,0)
	_fingers(false,true)
	app.manipulation.advance(1.0)
	assert(card.global_position.distance_to(before.origin+Vector3(0.10,0.04,0))<0.002)
	_fingers(true,true)
	_fingers(false,true)
	assert(app.manipulation.panel_owner=="left","Opening index pinch should not release a fist grab")
	_fingers(false,false)
	assert(app.manipulation.panel_owner.is_empty())
	_fingers(false,true)
	assert(app.manipulation.panel_owner=="left")
	tracker.has_tracking_data=false
	app._update_hands(1.0)
	assert(app.manipulation.panel_owner.is_empty())
	XRServer.remove_tracker(tracker)
	app.info_panel=old_panel
	print("WHOLE_CARD_GRAB_PASS: all surface regions, rotated card, every button, near pinch priority, closed-hand drag, no snap, release and tracking loss")
	quit()
