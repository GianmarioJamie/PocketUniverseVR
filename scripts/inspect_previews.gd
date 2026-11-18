extends SceneTree
var target: SubViewport
func _initialize() -> void:
	target=SubViewport.new()
	target.size=Vector2i(1104,780)
	target.disable_3d=true
	target.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(target)
	var bg:=ColorRect.new()
	bg.size=Vector2(1104,780)
	bg.color=Color("071221")
	target.add_child(bg)
	var ids: Array[String]=["mercury","venus","earth","mars","jupiter","saturn","uranus","neptune","sun","moon","iss","hubble"]
	for i in ids.size():
		var image:=TextureRect.new()
		image.texture=load("res://assets/previews/"+ids[i]+".png")
		image.position=Vector2((i%4)*276,(i/4)*260+35)
		image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		image.size=Vector2(552,240)
		image.scale=Vector2(0.5,0.5)
		image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		target.add_child(image)
		var label:=Label.new()
		label.text=ids[i].to_upper()
		label.position=Vector2((i%4)*276+15,(i/4)*260+5)
		label.add_theme_font_size_override("font_size",20)
		target.add_child(label)
	_save.call_deferred()
func _save() -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	print("Preview sheet: ",target.get_texture().get_image().save_png("res://builds/screenshots/previews-v050.png"))
	quit()
