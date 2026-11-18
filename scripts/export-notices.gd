extends SceneTree
## Regenerate from the installed engine so attribution matches the build.
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/licenses")
	FileAccess.open("res://assets/licenses/GODOT_LICENSE.txt", FileAccess.WRITE).store_string(Engine.get_license_text())
	var notices := {
		"engine": Engine.get_version_info(),
		"copyrights": Engine.get_copyright_info(),
		"licenses": Engine.get_license_info()
	}
	FileAccess.open("res://assets/licenses/GODOT_THIRD_PARTY.json", FileAccess.WRITE).store_string(JSON.stringify(notices, "\t"))
	print("LICENSE_NOTICES_EXPORTED")
	quit()
