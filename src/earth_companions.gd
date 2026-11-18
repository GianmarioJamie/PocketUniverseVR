extends Node3D
## Original procedural miniatures. Distances, spacecraft sizes and time are illustrative.
var host
var worlds: Array[Node3D] = []
var clock := 0.0
const RECORDS := [
	{"name":"Moon", "kind":"EARTH'S NATURAL SATELLITE", "facts":"Diameter: about 3,475 km\nMean distance: about 384,400 km\nOrbital period: about 27.3 Earth days", "story":"The Moon turns once in the time it takes to orbit Earth, so we mostly see the same side."},
	{"name":"ISS", "kind":"INTERNATIONAL SPACE STATION", "facts":"Orbit: low Earth orbit\nOne orbit: about 90 minutes\nRole: crewed research laboratory", "story":"The station is an orbiting laboratory where people study science and living in space."},
	{"name":"Hubble", "kind":"SPACE TELESCOPE", "facts":"Orbit: low Earth orbit\nOne orbit: about 95 minutes\nLaunched: 1990", "story":"Hubble observes the universe above Earth's atmosphere, collecting ultraviolet, visible and near-infrared light."}
]

func setup(app) -> void:
	host = app
	for i in 3:
		var orbit := Node3D.new()
		add_child(orbit)
		orbit.rotation_degrees.z = [12.0,51.6,28.5][i]
		var radius: float = [0.038,0.018,0.026][i]
		host._ring(orbit,radius,Color("42716d"),0.00013)
		var body := Node3D.new()
		orbit.add_child(body)
		worlds.append(body)
		if i == 0:
			host._sphere(body,0.00205,host._material(Color("b7b9b9"),false))
		elif i == 1:
			_make_iss(body)
		else:
			_make_hubble(body)
		host.targets.append({"node":body,"radius":0.0035,"action":200+i})
	visible = false

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = host._material(color,false)
	mesh.position = pos
	parent.add_child(mesh)

func _make_iss(body: Node3D) -> void:
	_box(body,Vector3(0.006,0.0006,0.0006),Vector3.ZERO,Color("d6dde3"))
	_box(body,Vector3(0.0011,0.0011,0.004),Vector3.ZERO,Color("d6dde3"))
	for side in [-1,1]:
		for n in 2:
			_box(body,Vector3(0.0015,0.00015,0.005),Vector3(side*(0.002+n*0.002),0,0),Color("a86c2d"))

func _make_hubble(body: Node3D) -> void:
	var mesh := MeshInstance3D.new()
	var tube := CylinderMesh.new()
	tube.top_radius = 0.0012
	tube.bottom_radius = 0.0012
	tube.height = 0.005
	tube.radial_segments = 12
	mesh.mesh = tube
	mesh.material_override = host._material(Color("bfcbd2"),false)
	mesh.rotation.x = PI/2
	body.add_child(mesh)
	for side in [-1,1]:
		_box(body,Vector3(0.003,0.00015,0.003),Vector3(side*0.0028,0,0),Color("29589a"))

func advance(delta: float, active: bool, orbiting: bool) -> void:
	visible = active
	if not active:
		return
	if orbiting:
		clock += delta
	for i in worlds.size():
		var angle: float = clock*[0.35,0.9,0.65][i]+i*2.0
		var radius: float = [0.038,0.018,0.026][i]
		worlds[i].position = Vector3(cos(angle)*radius,0,sin(angle)*radius)
		worlds[i].rotation.y = -angle
