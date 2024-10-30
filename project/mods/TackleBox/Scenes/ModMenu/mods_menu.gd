extends Node

const MOD_PANEL = preload("res://mods/TackleBox/Scenes/ModMenu/mod_panel.tscn")
const MOD_CONFIG = preload("res://mods/TackleBox/Scenes/ModMenu/mod_config.tscn")

var _loaded_mods := [ "TackleBox" ] # Put your mod ID here when testing

onready var main_menu := get_parent()
onready var TackleBox := $"/root/TackleBox"


func _ready() -> void:
	if "loaded_mods" in Globals:
		_loaded_mods = Globals.loaded_mods
	
	var mod_list = $"Panel/Panel2/ScrollContainer/VBoxContainer"
	
	for mod_id in _loaded_mods:
		var mod_panel := MOD_PANEL.instance()
		
		var mod_data: Dictionary = TackleBox.get_mod_metadata(mod_id)
		
		var mod_name: String = mod_data.name if mod_data and mod_data.name else mod_id
		var mod_description: String = mod_data.description if mod_data and mod_data.description else "No description available."
		var mod_version: String = "v" + mod_data.version if mod_data and mod_data.version else ""
		var mod_author: String = " by " + mod_data.author if mod_data and mod_data.author else ""
		
		var mod_header := mod_name + " [color=#587758] " + mod_version + mod_author
		
		mod_panel.get_node("PanelContainer/HBoxContainer/ModInfo/ModName").bbcode_text = mod_header
		mod_panel.get_node("PanelContainer/HBoxContainer/ModInfo/ModDescription").text = mod_description
		
		if TackleBox.get_mod_config(mod_id):
			var config_button := mod_panel.get_node("PanelContainer/HBoxContainer/Button")
			config_button.visible = true
			config_button.connect("pressed", self, "_open_config", [mod_id])
		
		mod_list.add_child(mod_panel)


func _open_config(mod_id: String) -> void:
	if main_menu.has_node("mod_config"):
		return

	var mod_config := MOD_CONFIG.instance()
	main_menu.add_child(mod_config)
	mod_config.initialise(mod_id)


func _on_close_pressed() -> void:
	main_menu.get_node("mods_menu").visible = false
