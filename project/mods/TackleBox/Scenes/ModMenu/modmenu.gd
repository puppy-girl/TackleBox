extends Node

onready var main_menu = get_parent()

var gdweave_directory = OS.get_executable_path() + "/../GDWeave"

func _initialise(loaded_mods):
	var mod_list = get_node("Panel/Panel2/ScrollContainer/VBoxContainer")
	
	if main_menu.loaded_mods:
		loaded_mods = main_menu.loaded_mods

	var mod_data = _get_mod_data()

	for mod in loaded_mods:
		var mod_panel = preload("res://mods/TackleBox/Scenes/ModPanel/modpanel.tscn").instance()
		
		var file = File.new()
		var config_path = gdweave_directory + "/configs/" + mod + ".json"
		
		var mod_name = mod_data[mod].name if mod_data[mod].name else mod
		var mod_description = mod_data[mod].description if mod_data[mod].description else "No description available."
		var mod_version = mod_data[mod].version if mod_data[mod].version else ""
		var mod_author = " by " + mod_data[mod].author if mod_data[mod].author else ""
		
		mod_panel.get_node("Panel/HBoxContainer/Label").bbcode_text = mod_name + " [color=#587758]" + mod_version + mod_author + "\n[color=#9d6d2f]" + mod_description
		
		if file.file_exists(config_path):
			mod_panel.get_node("Panel/HBoxContainer/VSeparator").visible = true
			
			var config_button = mod_panel.get_node("Panel/HBoxContainer/Button")
			config_button.visible = true
			config_button.connect("pressed", self, "_open_config", [mod])
		
		mod_list.add_child(mod_panel)

func _get_mod_data():
	var mod_data = {}
	var dir = Directory.new()
	
	if dir.open(gdweave_directory + "/mods/") == OK:
		dir.list_dir_begin(true, true)
		
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var manifest = File.new()
				var manifest_path = gdweave_directory + "/mods/" + file_name + "/manifest.json"
				
				var mod_id
				
				if (manifest.file_exists(manifest_path)):
					manifest.open(manifest_path, File.READ)
					var manifest_data = JSON.parse(manifest.get_as_text())
					if manifest_data.error == OK: mod_id = manifest_data.result.Id
					manifest.close()
				
				var mod_file = File.new()
				var mod_file_path = gdweave_directory + "/mods/" + file_name + "/mod.json"
				
				if (mod_file.file_exists(mod_file_path)):
					mod_file.open(mod_file_path, File.READ)
					var mod_file_data = JSON.parse(mod_file.get_as_text())
					if mod_file_data.error == OK: mod_data[mod_id] = mod_file_data.result
					mod_file.close()
			file_name = dir.get_next()
		dir.list_dir_end()
		
	return mod_data

func _open_config(id):
	if main_menu.get_node("mod_config"): return

	var mod_config = preload("res://mods/TackleBox/Scenes/ModConfig/modconfig.tscn").instance()
	main_menu.add_child(mod_config)
	mod_config._initialise(id)

func _close_mod_menu(): main_menu.get_node("mod_menu").visible = false
