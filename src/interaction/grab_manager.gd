extends RefCounted
## Shared desktop / XR manipulation. No physics impulses or cumulative scale drift.
var app
var sources: Dictionary = {}
var holds: Dictionary = {}
var owners: Dictionary = {}
var returning: Dictionary = {}
var panel_base := Transform3D.IDENTITY
var panel_source_base := Transform3D.IDENTITY
var panel_owner := ""
var system_owner := ""
var system_start := Vector3.ZERO
var system_hand_start := Vector3.ZERO

func setup(host) -> void:
	app = host

func feed(id: String, pose: Transform3D, ray_origin: Vector3, direction: Vector3, active: bool, tracked: bool, hit: Dictionary, direct := false) -> void:
	var old: Dictionary = sources.get(id, {"active": false, "armed": false})
	var was_active: bool = old.active
	var armed: bool = old.armed
	if not tracked:
		release(id)
		sources[id] = {"active": false, "armed": false, "pose": pose, "ray_origin": ray_origin, "direction": direction}
		return
	if not active:
		armed = true
	sources[id] = {"active":active,"armed":armed,"pose":pose,"ray_origin":ray_origin,"direction":direction}
	if active and not was_active and armed and not hit.is_empty():
		var action := int(hit.action)
		if action >= 0 and action < 8:
			if not owners.has(action):
				owners[action] = id
				returning.erase(action)
				holds[id] = {"action":action,"direct":direct,"offset":app.planets[action].global_position-pose.origin if direct else Vector3.ZERO}
				app._select_planet(action)
		elif action == 120:
			if system_owner.is_empty():
				owners[120] = id
				holds[id] = {"action":120}
				system_owner = id
				system_start = app.universe.global_position
				system_hand_start = pose.origin
				app._select_sun()
		elif action == 111:
			if not owners.has(111):
				owners[111] = id
				holds[id] = {"action":111}
				panel_owner = id
				panel_base = app.info_panel.global_transform
				panel_source_base = pose
		else:
			app._activate(action)
	if not active and was_active:
		release(id)

func release(id: String) -> void:
	if holds.has(id):
		var action := int(holds[id].action)
		if action < 8:
			owners.erase(action)
			returning[action] = true
		elif action == 120:
			owners.erase(120)
			system_owner = ""
		elif action == 111:
			owners.erase(111)
			panel_owner = ""
		holds.erase(id)

func release_all() -> void:
	for id in holds.keys():
		release(id)
	for id in sources.keys():
		sources[id].armed = false
		sources[id].active = false

func planet_is_held(index: int) -> bool:
	return owners.has(index)

func advance(delta: float) -> void:
	if not system_owner.is_empty() and sources.has(system_owner):
		# Sun grip translates the system only. No rotation/scale gesture or grab snap.
		var detached: Dictionary = {}
		for index in owners:
			if int(index)<8:
				detached[index] = app.planets[int(index)].global_transform
		var pose: Transform3D = sources[system_owner].pose
		var desired := system_start + pose.origin - system_hand_start
		app.universe.global_position = app.universe.global_position.lerp(desired,1.0-exp(-18.0*delta))
		for index in detached:
			app.planets[int(index)].global_transform = detached[index]
	if not panel_owner.is_empty() and sources.has(panel_owner):
		var pose: Transform3D = sources[panel_owner].pose
		app.info_panel.global_transform = pose * panel_source_base.affine_inverse() * panel_base
	for id in holds:
		var hold: Dictionary = holds[id]
		var action := int(hold.action)
		if action >= 8:
			continue
		var source: Dictionary = sources[id]
		var body: Node3D = app.planets[action]
		var pose: Transform3D = source.pose
		var target: Vector3 = pose.origin + hold.offset if hold.direct else source.ray_origin + source.direction * 0.22
		# Keep the inspected world visible in the hand, with readable minimum size.
		var base_radius := float(app.records[action].radius_ratio_earth)*0.0075
		var radius := clampf(base_radius * app.universe.global_basis.get_scale().x, 0.055, 0.10)
		var factor := radius/base_radius
		var rotation := pose.basis.orthonormalized()
		var desired := Transform3D(rotation.scaled(Vector3.ONE*factor),target)
		body.global_transform = body.global_transform.interpolate_with(desired,1.0-exp(-16.0*delta))

func orbit_planet(index: int, position: Vector3, delta: float) -> void:
	if planet_is_held(index):
		return
	var body: Node3D = app.planets[index]
	var desired := Transform3D(Basis.IDENTITY,position)
	if returning.has(index):
		body.transform = body.transform.interpolate_with(desired,1.0-exp(-7.0*delta))
		if body.position.distance_to(position)<0.002 and body.scale.distance_to(Vector3.ONE)<0.015:
			body.transform = desired
			returning.erase(index)
	else:
		body.transform = desired
