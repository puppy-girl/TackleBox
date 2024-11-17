extends GenericUIButton


func _on_mods_pressed() -> void:
	var mods_menu = $"../../mods_menu"
	mods_menu.visible = true
	mods_menu.show_config_buttons()
