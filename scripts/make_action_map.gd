extends SceneTree
func _initialize() -> void:
	var map := OpenXRActionMap.new()
	map.create_default_action_sets()
	var result := ResourceSaver.save(map, "res://assets/openxr_action_map.tres")
	print("Saved OpenXR action map: ", result)
	quit(result)
