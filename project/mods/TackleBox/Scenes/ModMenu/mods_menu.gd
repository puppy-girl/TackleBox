extends Node

const ModPanel := preload("res://mods/TackleBox/Scenes/ModMenu/mod_panel.tscn")
const ModConfig := preload("res://mods/TackleBox/Scenes/ModMenu/mod_config.tscn")

onready var TackleBox := $"/root/TackleBox"
onready var main_menu := get_parent()
onready var mod_list := $"Panel/Panel2/ScrollContainer/VBoxContainer"


func _ready() -> void:
	var loaded_mods := []
	var invalid_mods := []
	
	for mod_id in TackleBox._mod_manifests:
		if TackleBox.loaded_mods.has(mod_id):
			loaded_mods.push_back(mod_id)
		else:
			invalid_mods.push_back(mod_id)
	
	for mod_id in loaded_mods:
		var mod_panel := ModPanel.instance()
		mod_panel.name = mod_id
		
		var mod_data: Dictionary = TackleBox.get_mod_metadata(mod_id)
		
		var mod_name: String = mod_data.name if mod_data and mod_data.name else mod_id
		var mod_description: String = mod_data.description if mod_data and mod_data.description else "No description available."
		var mod_version: String = "v" + mod_data.version if mod_data and mod_data.version else ""
		var mod_author: String = " by " + mod_data.author if mod_data and mod_data.author else ""
		
		var mod_header := mod_name + " [color=#587758] " + mod_version + mod_author
		
		mod_panel.get_node("HBoxContainer/ModInfo/ModName").bbcode_text = mod_header
		mod_panel.get_node("HBoxContainer/ModInfo/ModDescription").text = mod_description
		
		var mod_icon_path: String = "res://mods/" + mod_id + "/icon.png"
		if ResourceLoader.exists(mod_icon_path):
			var mod_icon := mod_panel.get_node("HBoxContainer/TextureRect")
			
			mod_icon.texture = load(mod_icon_path)
			mod_icon.visible = true
		
		mod_list.add_child(mod_panel)
	
	if invalid_mods.size() == 0:
		return
	
	var separator := TextureRect.new()
	separator.texture = load("res://Assets/Textures/UI/knot_sep.png")
	separator.stretch_mode = 4
	mod_list.add_child(separator)
	
	var regex := RegEx.new()
	
	for mod_id in invalid_mods:
		var mod_panel := ModPanel.instance()
		
		var mod_data: Dictionary = TackleBox.get_mod_metadata(mod_id)
		
		regex.compile("\\[WRN\\] (?<warning>.*" + mod_id + ".*)")
		var search: RegExMatch = regex.search(TackleBox.gdweave_logs)
		var warning: String = search.get_string("warning") if search else "Mod failed to load"
		
		var dir := OS.get_executable_path().get_base_dir() + "/"
		if OS.has_feature("Windows"):
			dir = dir.replace("/", "\\")
		warning = warning.replace(dir, "")
		
		mod_panel.get_node("HBoxContainer/ModInfo/ModName").bbcode_text = mod_id
		mod_panel.get_node("HBoxContainer/ModInfo/ModDescription").text = warning + "\n"
		
		mod_panel.self_modulate = Color(1, 1, 1, 0.75)
		
		var copy_logs_button := Button.new()
		copy_logs_button.text = "Copy Logs to Clipboard"
		copy_logs_button.rect_min_size = Vector2(360, 40)
		copy_logs_button.size_flags_horizontal = 2
		copy_logs_button.margin_top = 20
		copy_logs_button.set_script(load("res://Scenes/Menus/Main Menu/ui_generic_button.gd"))
		copy_logs_button.connect("pressed", self, "_on_copy_pressed", [TackleBox.gdweave_logs, copy_logs_button])
		mod_panel.get_node("HBoxContainer/ModInfo").add_child(copy_logs_button)
		
		mod_list.add_child(mod_panel)


func _show_config_buttons() -> void:
	for panel in mod_list.get_children():
		if panel.name in TackleBox.loaded_mods and TackleBox.get_mod_config(panel.name):
			var config_button: Button = panel.get_node("HBoxContainer/Button")
			config_button.visible = true
			config_button.connect("pressed", self, "_open_config", [panel.name])


func _open_config(mod_id: String) -> void:
	if main_menu.has_node("mod_config"):
		return

	var mod_config := ModConfig.instance()
	main_menu.add_child(mod_config)
	mod_config.initialise(mod_id)


func _on_close_pressed() -> void:
	main_menu.get_node("mods_menu").visible = false


func _on_copy_pressed(content: String, button: Button) -> void:
	OS.clipboard = content
	button.set_text("Copied!")
