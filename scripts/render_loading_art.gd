extends SceneTree
var target: SubViewport
func _initialize() -> void:
	target=SubViewport.new()
	target.size=Vector2i(1024,512)
	target.disable_3d=true
	target.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(target)
	var background:=ColorRect.new()
	background.size=Vector2(1024,512)
	background.color=Color("071221")
	target.add_child(background)
	var icon:=TextureRect.new()
	icon.texture=load("res://assets/icon.svg")
	icon.position=Vector2(432,38)
	icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	icon.size=Vector2(160,160)
	target.add_child(icon)
	var title:=Label.new()
	title.text="Pocket Universe VR"
	title.position=Vector2(0,236)
	title.size=Vector2(1024,90)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",58)
	title.add_theme_color_override("font_color",Color("edf6fc"))
	target.add_child(title)
	var subtitle:=Label.new()
	subtitle.text="Loading your pocket universe…"
	subtitle.position=Vector2(0,354)
	subtitle.size=Vector2(1024,42)
	subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size",24)
	subtitle.add_theme_color_override("font_color",Color("73e0cb"))
	target.add_child(subtitle)
	_save.call_deferred()
func _save() -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	print("Loading art: ",target.get_texture().get_image().save_png("res://assets/loading.png"))
	quit()
