extends Node

var _mod_id: String
var _options := {}

onready var TackleBox := $"/root/TackleBox"


func initialise(mod_id: String) -> void:
	_mod_id = mod_id

	var mod_data: Dictionary = TackleBox.get_mod_metadata(mod_id)
	var mod_config: Dictionary = TackleBox.get_mod_config(mod_id)
	
	var mod_name: String = mod_data.name if mod_data and mod_data.name else mod_id
	$"%Title".text = "Configuring " + mod_name
	
	
	for key in mod_config.keys():
		if mod_config[key] is Array or mod_config[key] is Dictionary:
			return
		
		var line := HBoxContainer.new()
		line.rect_min_size.y = 40
		
		var label := Label.new()
		label.set("size_flags_horizontal", 3)
		label.text = key.capitalize().replace("_", " ") + ":"
		label.set("custom_colors/font_color", Color(0.37, 0.24, 0.11))
		
		line.add_child(label)
		
		if mod_config[key] is bool:
			var option := OptionButton.new()
			option.set("size_flags_horizontal", 3)
			option.set("size_flags_stretch_ratio", 0.75)
			
			option.add_item("Enabled")
			option.add_item("Disabled")
			option.selected = 0 if mod_config[key] else 1
			
			_options[key] = option
		
			line.add_child(option)
		else:
			var text_input := LineEdit.new()
			text_input.set("size_flags_horizontal", 3)
			text_input.set("size_flags_stretch_ratio", 0.75)
			
			text_input.set("custom_colors/font_color", Color(1, 0.93, 0.84))
			
			text_input.text = str(mod_config[key])
			
			_options[key] = text_input
			
			line.add_child(text_input)
		
		$"%VBoxContainer".add_child(line)


func _update_config() -> int:
	var mod_config: Dictionary = TackleBox.get_mod_config(_mod_id)
	
	for key in _options:
		if _options[key] is OptionButton:
			mod_config[key] = true if _options[key].selected == 0 else false
		elif _options[key] is LineEdit:
			mod_config[key] = _options[key].text if mod_config[key] is String else float(_options[key].text)
	
	return TackleBox.set_mod_config(_mod_id, mod_config)


func _on_apply_pressed() -> void:
	if _update_config() == OK:
		queue_free()


func _on_restart_pressed() -> void:
	if _update_config() == OK:
		get_tree().quit()
	
	# Commenting this out for now as it doesn't seem to be relaunching GDWeave.
	#OS.execute("cmd", ["/C", "start", OS.get_executable_path()], false)


func _on_close_pressed() -> void:
	queue_free()
