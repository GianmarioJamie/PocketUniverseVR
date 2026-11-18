extends Node3D
## One small, movable information card. Static model previews; viewport redraws on changes only.
const SUN_PREVIEW = preload("res://assets/previews/sun.png")
const SIZE := Vector2(600,1080)
const METRES_PER_PIXEL := 0.00064
const ACCENT := Color("73e0cb")
const MUTED := Color("9bafc4")
var host
var viewport: SubViewport
var canvas: Panel
var heading: Label
var category: Label
var facts: Label
var story: Label
var preview: TextureRect
var status: Label
var image_note: Label
var tour_heading: Label
var tour_instruction: Label
var tour_stars: Array[Label] = []
var tour_state: Dictionary = {}
var controls: Dictionary = {}
var buttons: Dictionary = {}
var hover_action := -1
var desktop_dragging := false
var desktop_drag_offset := Vector2.ZERO
var preview_id := "sun"
var desktop_scale := 0.65
var desktop_distance_controls: VBoxContainer

func setup(app) -> void:
	host = app
	viewport = SubViewport.new()
	viewport.size = Vector2i(SIZE)
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	canvas = Panel.new()
	canvas.size = SIZE
	canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0b1828")
	style.border_color = Color("29485b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(24)
	canvas.add_theme_stylebox_override("panel",style)
	viewport.add_child(canvas)
	var handle := _button("POCKET UNIVERSE    •    GRAB / PINCH",Rect2(24,18,552,44),111,18)
	heading = _text("",Rect2(28,78,544,48),38,Color("edf6fc"))
	category = _text("",Rect2(28,128,544,26),17,ACCENT)
	preview = TextureRect.new()
	preview.position = Vector2(24,158)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = Vector2(552,134)
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(preview)
	image_note = _text("MODEL PREVIEW",Rect2(34,294,532,18),14,MUTED)
	facts = _text("",Rect2(28,320,544,100),21,Color("e1eaf3"))
	facts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story = _text("",Rect2(28,432,544,86),20,MUTED)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tour_heading = _text("THREE WONDERS",Rect2(28,532,410,24),17,ACCENT)
	for i in 3:
		tour_stars.append(_text("☆",Rect2(454+i*38,530,36,28),24,MUTED))
	tour_instruction = _text("",Rect2(28,560,544,58),18,Color("dfeaf5"))
	tour_instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button("Start journey",Rect2(24,626,270,40),130,19)
	_button("Explore freely",Rect2(306,626,270,40),131,19)
	show_tour({"heading":"THREE WONDERS", "instruction":"Follow a short journey, or explore at your own pace.", "stars":0, "primary_label":"Start journey", "primary_enabled":true, "free_enabled":false})
	status = _text("",Rect2(28,674,544,28),18,ACCENT)
	for i in 3:
		var names := ["Zoom -","Overview","Zoom +"]
		var actions := [113,102,114]
		_button(names[i],Rect2(24+i*188,716,176,48),actions[i],22)
	var names := ["Sun","Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune"]
	for i in 9:
		_button(names[i],Rect2(24+(i%3)*188,784+(i/3)*44,176,38),116 if i==0 else 299+i,20)
	for i in 3:
		var labels := ["Pause / Play","Time speed","Reset scene"]
		var actions := [100,101,112]
		_button(labels[i],Rect2(24+i*188,924,176,44),actions[i],19)
	_button("Recenter view",Rect2(24,982,270,50),118,23)
	_button("Exit",Rect2(306,982,270,50),119,23)
	var footer := _text("Sizes, distances and time adapted for exploration.",Rect2(28,1044,544,26),16,MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if host.xr_active:
		var surface := MeshInstance3D.new()
		var mesh := QuadMesh.new()
		mesh.size = SIZE*METRES_PER_PIXEL
		surface.mesh = mesh
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_texture = viewport.get_texture()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		surface.material_override = material
		add_child(surface)
		# The entire card is a grab surface; foreground buttons keep their own actions.
		host.targets.append({"node":self,"half_size":SIZE*METRES_PER_PIXEL*0.5,"radius":0.0,"action":111})
		for action in controls:
			var control: Control = controls[action]
			var target := Node3D.new()
			var rectangle := Rect2(control.position,control.size)
			var midpoint := rectangle.position+rectangle.size*0.5-SIZE*0.5
			target.position = Vector3(midpoint.x*METRES_PER_PIXEL,-midpoint.y*METRES_PER_PIXEL,0.003)
			add_child(target)
			host.targets.append({"node":target,"half_size":rectangle.size*METRES_PER_PIXEL*0.5,"radius":0.0,"action":action})
	else:
		# Reuse exactly the same card in the desktop preview.
		var layer := CanvasLayer.new()
		host.add_child(layer)
		canvas.reparent(layer)
		_build_desktop_distance_controls()
		_fit_desktop()
		host.get_viewport().size_changed.connect(_fit_desktop)
		handle.gui_input.connect(_handle_desktop_drag)
		canvas.gui_input.connect(_handle_desktop_drag)
	set_process(not host.xr_active)

func pick_surface(world_point: Vector3, grab_anywhere := false) -> Dictionary:
	if not is_visible_in_tree():
		return {}
	var point := to_local(world_point)
	var half_size := SIZE*METRES_PER_PIXEL*0.5
	if absf(point.z)>0.06 or absf(point.x)>half_size.x+0.02 or absf(point.y)>half_size.y+0.02:
		return {}
	var pixel := Vector2(point.x/METRES_PER_PIXEL+SIZE.x*0.5,-point.y/METRES_PER_PIXEL+SIZE.y*0.5)
	if not grab_anywhere:
		for action in controls:
			var control: Control = controls[action]
			if Rect2(control.position,control.size).has_point(pixel):
				return {"action":int(action),"distance":absf(point.z)}
	return {"action":111,"distance":0.03}

func _text(value: String, rect: Rect2, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	return label

func _button(value: String, rect: Rect2, action: int, font_size: int) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size",font_size)
	button.add_theme_color_override("font_color",Color("dfeaf5"))
	button.add_theme_color_override("font_disabled_color",Color("6d8396"))
	for state in ["normal","hover","pressed","focus","disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("101f2c") if state=="disabled" else (Color("142d40") if state=="normal" else Color("24534f"))
		style.set_corner_radius_all(9)
		style.set_border_width_all(1)
		style.border_color = Color("294b5d") if state in ["normal","disabled"] else ACCENT
		button.add_theme_stylebox_override(state,style)
	button.pressed.connect(_button_pressed.bind(action))
	canvas.add_child(button)
	controls[action] = button
	buttons[action] = button
	return button

func _button_pressed(action: int) -> void:
	if action!=111 and not buttons[action].disabled:
		host._activate(action)

func show_tour(state: Dictionary) -> void:
	if tour_state==state:
		return
	tour_state = state.duplicate(true)
	tour_heading.text = str(state.get("heading","THREE WONDERS"))
	tour_instruction.text = str(state.get("instruction",""))
	var completed := clampi(int(state.get("stars",0)),0,3)
	for i in tour_stars.size():
		tour_stars[i].text = "★" if i<completed else "☆"
		tour_stars[i].add_theme_color_override("font_color",ACCENT if i<completed else MUTED)
	buttons[130].text = str(state.get("primary_label","Start journey"))
	buttons[130].disabled = not bool(state.get("primary_enabled",true))
	buttons[131].disabled = not bool(state.get("free_enabled",false))
	for action in [130,131]:
		buttons[action].modulate = ACCENT if action==hover_action and not buttons[action].disabled else Color.WHITE
	_redraw()

func show_data(title: String, kind: String, numbers: String, description: String, image_id: String) -> void:
	heading.text = title
	category.text = kind
	facts.text = numbers
	story.text = description
	preview_id = image_id
	var path := "res://assets/previews/"+image_id+".png"
	preview.texture = SUN_PREVIEW if image_id=="sun" else (load(path) if ResourceLoader.exists(path) else null)
	image_note.text = "MODEL PREVIEW  •  ILLUSTRATIVE" if image_id in ["moon","iss","hubble"] else "MODEL PREVIEW"
	_redraw()

func show_status(value: String) -> void:
	if status.text!=value:
		status.text=value
		_redraw()

func set_hover(action: int) -> void:
	if action==hover_action:
		return
	for key in buttons:
		buttons[key].modulate=ACCENT if key==action and not buttons[key].disabled else Color.WHITE
	hover_action=action
	_redraw()

func _redraw() -> void:
	if host.xr_active:
		viewport.render_target_update_mode=SubViewport.UPDATE_ONCE

func _fit_desktop() -> void:
	var size: Vector2 = host.get_viewport().get_visible_rect().size
	if is_instance_valid(desktop_distance_controls):
		desktop_distance_controls.size = Vector2(44,100)
		desktop_distance_controls.position = Vector2(SIZE.x+24,(SIZE.y-100)*0.5)
	desktop_scale = minf(0.76,_desktop_max_scale())
	canvas.scale = Vector2.ONE*desktop_scale
	canvas.position = Vector2(size.x-24-(SIZE.x+68)*desktop_scale,25)
	canvas.position = canvas.position.clamp(Vector2.ZERO,_desktop_card_max_position())

func _build_desktop_distance_controls() -> void:
	desktop_distance_controls = VBoxContainer.new()
	desktop_distance_controls.add_theme_constant_override("separation",8)
	canvas.add_child(desktop_distance_controls)
	for i in 2:
		var button := Button.new()
		button.text = "+" if i==0 else "−"
		button.custom_minimum_size = Vector2(44,44)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size",26)
		button.add_theme_color_override("font_color",Color("dfeaf5"))
		for state in ["normal","hover","pressed","focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = Color("142d40") if state=="normal" else Color("24534f")
			style.border_color = Color("294b5d") if state=="normal" else ACCENT
			style.set_border_width_all(1)
			style.set_corner_radius_all(9)
			button.add_theme_stylebox_override(state,style)
		button.pressed.connect(_desktop_distance_pressed.bind(140+i))
		desktop_distance_controls.add_child(button)

func _desktop_distance_pressed(action: int) -> void:
	host._activate(action)

func _desktop_max_scale() -> float:
	var size: Vector2 = host.get_viewport().get_visible_rect().size
	return maxf(0.05,minf(0.9,minf((size.x-48)/(SIZE.x+68),(size.y-50)/SIZE.y)))

func _desktop_card_max_position() -> Vector2:
	var size: Vector2 = host.get_viewport().get_visible_rect().size
	return Vector2(maxf(0,size.x-(SIZE.x+68)*desktop_scale),maxf(0,size.y-SIZE.y*desktop_scale))

func adjust_desktop_distance(closer: bool) -> void:
	desktop_dragging = false
	var center := canvas.position+SIZE*desktop_scale*0.5
	var maximum := _desktop_max_scale()
	desktop_scale = clampf(desktop_scale*(1.1 if closer else 1.0/1.1),minf(0.35,maximum),maximum)
	canvas.scale = Vector2.ONE*desktop_scale
	canvas.position = (center-SIZE*desktop_scale*0.5).clamp(Vector2.ZERO,_desktop_card_max_position())

func _handle_desktop_drag(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		desktop_dragging = event.pressed
		if event.pressed:
			desktop_drag_offset = host.get_viewport().get_mouse_position()-canvas.position
		canvas.accept_event()

func _process(_delta: float) -> void:
	if not desktop_dragging:
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		desktop_dragging=false
		return
	var proposed: Vector2 = host.get_viewport().get_mouse_position()-desktop_drag_offset
	canvas.position = proposed.clamp(Vector2.ZERO,_desktop_card_max_position())
