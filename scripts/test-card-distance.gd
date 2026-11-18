extends SceneTree
var app: Node

func _initialize() -> void:
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(app)
	_run.call_deferred()

func _run() -> void:
	await process_frame
	app.set_process(false)
	app.xr_active=true
	app._build_card_distance_controls()
	var dock: Transform3D=app.card_distance_controls.global_transform
	var dock_local: Transform3D=app.card_distance_controls.transform
	assert(app.card_distance_controls.get_parent()==app.info_panel)
	for i in 2:
		var button: Node3D=app.card_distance_controls.get_child(i)
		assert(button.get_child(1).text==["+","−"][i])
		assert(app.info_panel.to_local(button.global_position).x>0.24,"Distance buttons must sit outside the right edge")
		var normal: Vector3=button.global_basis.z
		assert(app._pick(button.global_position+normal*0.2,-normal).get("action",-1)==140+i)
		assert(app._pick_near(button.global_position+normal*0.02).get("action",-1)==140+i)
	var earth_pose := Transform3D(Basis.IDENTITY,app.planets[2].global_position)
	app.manipulation.feed("world",earth_pose,earth_pose.origin,Vector3.FORWARD,false,true,{})
	app.manipulation.feed("world",earth_pose,earth_pose.origin,Vector3.FORWARD,true,true,{"action":2},true)
	var card_pose: Transform3D=app.info_panel.global_transform
	app.manipulation.feed("card",card_pose,card_pose.origin,Vector3.FORWARD,false,true,{})
	app.manipulation.feed("card",card_pose,card_pose.origin,Vector3.FORWARD,true,true,{"action":111},true)
	card_pose.origin+=Vector3(0.12,0.04,0.02)
	card_pose.basis=card_pose.basis*Basis.from_euler(Vector3(0.1,-0.15,0.05))
	app.manipulation.feed("card",card_pose,card_pose.origin,Vector3.FORWARD,true,true,{})
	app.manipulation.advance(1.0)
	assert(not app.card_distance_controls.global_transform.is_equal_approx(dock))
	assert(app.card_distance_controls.global_transform.is_equal_approx(app.info_panel.global_transform*dock_local))
	var body_before: Transform3D=app.planets[2].global_transform
	var universe_before: Transform3D=app.universe.global_transform
	var direction: Vector3=(app.info_panel.global_position-app.camera.global_position).normalized()
	var distance: float=app.info_panel.global_position.distance_to(app.camera.global_position)
	var basis: Basis=app.info_panel.global_basis
	app._activate(140)
	assert(is_equal_approx(app.info_panel.global_position.distance_to(app.camera.global_position),distance-0.15))
	assert(app.info_panel.global_basis.is_equal_approx(basis))
	assert((app.info_panel.global_position-app.camera.global_position).normalized().dot(direction)>0.999)
	assert(app.manipulation.panel_owner.is_empty() and app.manipulation.planet_is_held(2))
	assert(app.planets[2].global_transform.is_equal_approx(body_before))
	assert(app.universe.global_transform.is_equal_approx(universe_before))
	assert(app.card_distance_controls.global_transform.is_equal_approx(app.info_panel.global_transform*dock_local))
	for i in 40:
		app._activate(140)
	assert(is_equal_approx(app.info_panel.global_position.distance_to(app.camera.global_position),0.55))
	for i in 40:
		app._activate(141)
	assert(is_equal_approx(app.info_panel.global_position.distance_to(app.camera.global_position),2.60))
	assert(app.card_distance_controls.global_transform.is_equal_approx(app.info_panel.global_transform*dock_local))
	for i in 2:
		var button: Node3D=app.card_distance_controls.get_child(i)
		assert(app._pick(button.global_position+button.global_basis.z*0.2,-button.global_basis.z).get("action",-1)==140+i)
	app._reset_space()
	assert(app.info_panel.transform.is_equal_approx(app.panel_home))
	app._place_content_in_front(Transform3D(Basis.from_euler(Vector3(0,0.5,0)),Vector3(0.4,1.6,-0.2)))
	assert(app.info_panel.transform.is_equal_approx(app.panel_home))
	assert(app.card_distance_controls.transform.is_equal_approx(dock_local))
	var before_focus: Transform3D=app.info_panel.global_transform
	app._on_session_unfocus()
	app._activate(140)
	assert(app.info_panel.global_transform.is_equal_approx(before_focus))
	app._on_session_focus()
	app.xr_active=false
	var row_position: Vector2=app.info_panel.desktop_distance_controls.position
	assert(app.info_panel.desktop_distance_controls.get_parent()==app.info_panel.canvas)
	var controls_before: Vector2=app.info_panel.desktop_distance_controls.global_position
	app.info_panel.canvas.position+=Vector2(-70,20)
	assert(app.info_panel.desktop_distance_controls.global_position.is_equal_approx(controls_before+Vector2(-70,20)))
	var scale_before: float=app.info_panel.desktop_scale
	app.info_panel.desktop_distance_controls.get_child(1).pressed.emit()
	assert(app.info_panel.desktop_scale<scale_before)
	assert(app.info_panel.desktop_distance_controls.position.is_equal_approx(row_position))
	assert(app.info_panel.canvas.position.x+app.info_panel.canvas.size.x*app.info_panel.desktop_scale<app.info_panel.desktop_distance_controls.global_position.x)
	assert(app.info_panel.desktop_distance_controls.get_child(0).text=="+")
	assert(app.info_panel.desktop_distance_controls.get_child(1).text=="−")
	print("CARD_DISTANCE_PASS: buttons follow card grab/rotation/zoom, ray/near targets, distance limits, reset/recenter and desktop dragging")
	print("ATTACHED_CARD_BUTTONS_PASS: constant local offset in VR and desktop, after moving and rotating the card")
	if "--capture-card-distance" in OS.get_cmdline_user_args():
		app._reset_space()
		app._place_content_in_front(Transform3D.IDENTITY)
		app.card_distance_controls.visible=false
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://builds/screenshots/card-distance-v066.png")
	quit()
