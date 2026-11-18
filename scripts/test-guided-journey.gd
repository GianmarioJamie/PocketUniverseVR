extends SceneTree
var app: Node

func _initialize() -> void:
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(app)
	_run.call_deferred()

func _hold(action: int, pose: Transform3D) -> void:
	app.manipulation.feed("journey_test",pose,pose.origin,Vector3.FORWARD,false,true,{})
	app.manipulation.feed("journey_test",pose,pose.origin,Vector3.FORWARD,true,true,{"action":action},true)

func _run() -> void:
	await process_frame
	app.set_process(false)
	var tour: Node = app.journey
	assert(tour.mode==0 and tour.stars==0)
	assert(app.info_panel.buttons.has(130) and app.info_panel.buttons.has(131))
	var placement: Transform3D = app.universe.transform
	app._activate(130)
	assert(tour.mode==1 and tour.stop==0 and app.universe.transform.is_equal_approx(placement))
	app._activate(130)
	assert(tour.stop==0,"Disabled Next must not skip discoveries in XR")
	app._activate(302)
	app._process(0.016)
	assert(tour.stars==0,"Selecting a planet name does not count as grabbing")
	var pose := Transform3D(Basis.IDENTITY,app.planets[2].global_position)
	_hold(2,pose)
	app._process(0.016)
	assert(not app.planet_labels[2].visible)
	assert(app.earth_companions.find_children("*","Label3D",true,false).is_empty())
	for i in 3:
		var matches: Array = app.targets.filter(func(target): return target.action==200+i)
		assert(matches.size()==1 and matches[0].node==app.earth_companions.worlds[i],"Only the actual Moon/spacecraft should be targets")
	print("EARTH_CLEAN_PASS: no labels or floating tabs, all three companion bodies selectable")
	app._activate(201)
	assert(tour.stars==0,"ISS is not the Moon task")
	app._activate(200)
	assert(tour.stars==1 and tour.waiting and tour.sound_count==1)
	app._activate(200)
	assert(tour.stars==1 and tour.sound_count==1,"No repeated reward")
	app._activate(130)
	assert(tour.stop==1 and not tour.waiting)
	app._process(0.016)
	assert(tour.stars==1)
	app.manipulation.release_all()
	pose.origin=app.planets[5].global_position
	_hold(5,pose)
	app._process(0.016)
	assert(tour.stars==2 and tour.waiting and tour.sound_count==2)
	app._activate(130)
	assert(tour.stop==2 and tour.target_action()==120)
	app.manipulation.release_all()
	app.paused=false
	pose.origin=app.universe.global_position
	_hold(120,pose)
	app._process(0.016)
	app._place_content_in_front(Transform3D(Basis.IDENTITY,Vector3(0.4,0.2,0.1)))
	app._process(0.016)
	assert(not tour.sun_moved and tour.stars==2,"Recenter cannot earn the movement star")
	pose.origin=app.universe.global_position
	_hold(120,pose)
	app._process(0.016)
	pose.origin+=Vector3(0.08,0,0.02)
	app.manipulation.feed("journey_test",pose,pose.origin,Vector3.FORWARD,true,true,{})
	app._process(0.5)
	assert(tour.sun_moved and tour.stars==2,"Move the Sun, then pause")
	app._activate(100)
	app._process(0.016)
	assert(tour.stars==3 and tour.mode==2 and tour.sound_count==3)
	app._process(0.016)
	assert(tour.sound_count==3)
	assert(app.info_panel.buttons[130].text=="Start again")
	assert(app.info_panel.tour_stars.all(func(star): return star.text=="★"))
	if "--capture-journey" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://builds/screenshots/journey-complete-v060.png")
	app._activate(131)
	assert(tour.mode==0 and tour.stars==3)
	assert(app.manipulation.system_owner=="journey_test","Free explore does not drop a held object")
	app._activate(130)
	assert(tour.stars==0 and tour.stop==0 and tour.mode==1)
	app._activate(131)
	assert(tour.mode==0 and tour.target_action()==-1)
	app.manipulation.release_all()
	# The same journey must also work with one hand or a desktop mouse.
	app._activate(130)
	pose.origin=app.planets[2].global_position
	_hold(2,pose)
	app._process(0.016)
	app.manipulation.release_all()
	app._process(0.016)
	assert(app.planet_labels[2].visible)
	assert(app.info_panel.buttons[130].text=="Discover Moon")
	assert(not app.info_panel.buttons[130].disabled)
	app._activate(130)
	assert(tour.stars==1 and app.info_panel.heading.text=="Moon")
	app._activate(131)
	for stream in tour.chimes:
		assert(stream.data.size()>10000 and stream.mix_rate==22050)
	assert(tour.player.volume_db<=-18.0)
	print("JOURNEY_FLOW_PASS: real grab/selection sequence, no skips, three rewards, restart/free explore, recenter not counted")
	app._reset_space()
	app._place_content_in_front(Transform3D.IDENTITY)
	app._activate(130)
	await process_frame
	for i in 8:
		app._select_planet(i)
		await process_frame
		_check_text()
	app._select_sun()
	await process_frame
	_check_text()
	print("JOURNEY_LAYOUT_PASS: descriptions, instructions, controls and generated chimes")
	if "--capture-journey" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		image.save_png("res://builds/screenshots/journey-v060.png")
		print("JOURNEY_SCREENSHOT_SAVED")
	quit()

func _check_text() -> void:
	for label in [app.info_panel.facts,app.info_panel.story,app.info_panel.tour_instruction]:
		var max_height := 100.0 if label==app.info_panel.facts else (86.0 if label==app.info_panel.story else 58.0)
		assert(label.get_minimum_size().y<=max_height,"Text does not fit: "+label.text)
