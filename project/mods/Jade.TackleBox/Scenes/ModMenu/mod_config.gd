extends Node

var _mod_id: String
var _options := {}

onready var options_list := $"Panel/config/ScrollContainer/VBoxContainer"
onready var mod_title := $"Panel/config/ScrollContainer/VBoxContainer/Title"
onready var TackleBox := $"/root/JadeTackleBox"


func initialise(mod_id: String) -> void:
	_mod_id = mod_id

	var mod_data: Dictionary = TackleBox.get_mod_metadata(mod_id)
	var mod_config: Dictionary = TackleBox.get_mod_config(mod_id)
	
	var mod_name: String = mod_data.name if mod_data and mod_data.name else mod_id
	mod_title.text = "Configuring " + mod_name
	
	var config_key_regex := RegEx.new()
	config_key_regex.compile("([a-z])([A-Z])")
	
	for key in mod_config.keys():
		# Tackle Box currently only supports boolean config options
		if typeof(mod_config[key]) != TYPE_BOOL: continue
		
		var line := HBoxContainer.new()
		line.rect_min_size.y = 40
		
		var label := Label.new()
		label.set("size_flags_horizontal", 3)
		label.text = config_key_regex.sub(key, "$1 $2", true) + ":"
		label.set("custom_colors/font_color", Color(0.37, 0.24, 0.11))
		line.add_child(label)
		
		var option := OptionButton.new()
		option.set("size_flags_horizontal", 3)
		option.set("size_flags_stretch_ratio", 0.75)
		
		option.add_item("Enabled")
		option.add_item("Disabled")
		option.selected = 0 if mod_config[key] else 1
		
		_options[key] = option
		
		line.add_child(option)
		options_list.add_child(line)


func _update_config() -> int:
	var mod_config: Dictionary = TackleBox.get_mod_config(_mod_id)
	
	for key in _options:
		mod_config[key] = true if _options[key].selected == 0 else false
	
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
