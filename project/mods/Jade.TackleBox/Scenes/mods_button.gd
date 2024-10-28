class_name ModsButton
extends GenericUIButton


func _on_mods_pressed() -> void:
	get_parent().get_parent().get_node("mods_menu").visible = true
	return
