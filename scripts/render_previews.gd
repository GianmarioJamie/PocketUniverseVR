extends SceneTree
## Render original project models into static preview PNGs. No runtime preview cost.
var viewport: SubViewport
var studio: Node3D
var model: Node3D
var builder
var entries: Array = []
var tick := 0
var index := 0

func _initialize() -> void:
	builder = load("res://src/main.gd").new()
	entries = JSON.parse_string(FileAccess.get_file_as_string("res://data/planets.json"))
	entries.append({"id":"sun","name":"Sun","color":"#ffb845"})
	entries.append({"id":"moon","name":"Moon","color":"#a9acb3"})
	entries.append({"id":"iss","name":"ISS","color":"#eeeeee"})
	entries.append({"id":"hubble","name":"Hubble","color":"#eeeeee"})
	viewport = SubViewport.new()
	viewport.size = Vector2i(552,240)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	studio = Node3D.new()
	viewport.add_child(studio)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("0a1928")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("b8cce0")
	env.ambient_light_energy = 0.5
	environment.environment = env
	studio.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25,-25,0)
	light.light_energy = 1.4
	studio.add_child(light)
	var camera := Camera3D.new()
	camera.position = Vector3(0,0.5,5.8)
	camera.fov = 30
	studio.add_child(camera)
	camera.rotation.x = -atan(0.5/5.8)
	camera.current = true
	viewport.msaa_3d = Viewport.MSAA_4X
	_render_all.call_deferred()

func _next_model() -> void:
	if is_instance_valid(model):
		model.free()
	model = Node3D.new()
	studio.add_child(model)
	model.rotation_degrees.y = 30
	var d: Dictionary = entries[index]
	if index < 8:
		var material := ShaderMaterial.new()
		material.shader = load("res://assets/planet.gdshader")
		material.set_shader_parameter("base_color",Color(d.color))
		material.set_shader_parameter("kind",index)
		builder._sphere(model,0.95,material)
		if index == 5:
			for n in 7:
				var ring: Node3D = builder._ring(model,1.3+n*0.1,Color("baaa87"),0.025)
				ring.rotation_degrees.z = 24
			model.rotation_degrees.x = 18
	elif d.id == "sun":
		var material := ShaderMaterial.new()
		var shader := Shader.new()
		shader.code = "shader_type spatial; render_mode unshaded; void fragment(){float v=0.5+0.18*sin(UV.x*80.0+sin(UV.y*47.0)*3.0)*sin(UV.y*64.0)+0.15*sin(UV.y*20.0);ALBEDO=mix(vec3(1.0,0.28,0.035),vec3(1.0,0.86,0.32),v); }"
		material.shader = shader
		builder._sphere(model,1.0,material)
	elif d.id == "moon":
		builder._sphere(model,0.95,builder._material(Color(d.color),false))
	else:
		var companions = load("res://src/earth_companions.gd").new()
		companions.host = builder
		if d.id == "iss": companions._make_iss(model)
		else: companions._make_hubble(model)
		model.scale = Vector3.ONE*240
		model.rotation_degrees = Vector3(-30,15,-20)
		companions.free()

func _render_all() -> void:
	for i in entries.size():
		index = i
		_next_model()
		# Await completed draws, not a count of CPU process callbacks.
		# This avoids saving the previous model with threaded rendering enabled.
		await process_frame
		await RenderingServer.frame_post_draw
		await process_frame
		await RenderingServer.frame_post_draw
		var path: String = "res://assets/previews/"+entries[index].id+".png"
		var result := viewport.get_texture().get_image().save_png(path)
		print("Preview ",entries[index].id," result=",result)
	builder.free()
	quit()
