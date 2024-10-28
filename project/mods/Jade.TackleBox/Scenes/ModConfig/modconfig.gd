extends Node

onready var options_list = get_node("Panel/config/ScrollContainer/VBoxContainer")

var gdweave_directory = OS.get_executable_path() + "/../GDWeave"

var config = {}
var options = {}

var mod_id: String = ""
onready var mod_title: Label = $Panel/config/ScrollContainer/VBoxContainer/Title

func _initialise(id, title):
	mod_id = id
	
	var config_file = File.new()
	var config_path = gdweave_directory + "/configs/" + mod_id + ".json"
	
	config_file.open(config_path, File.READ)
	var config_data = JSON.parse(config_file.get_as_text())
	if !config_data.error == OK: return
	
	config = config_data.result
	config_file.close()
	
	var regex = RegEx.new()
	regex.compile("([a-z])([A-Z])")
	
	mod_title.text = "Configuring " + title
	
	var close_tooltip = TooltipNode.new()
	$Panel/close.add_child(close_tooltip)
	
	close_tooltip.header = "Close without saving."
	close_tooltip.body = "Changed your mind? Yeah whatever close it already."

	close_tooltip.anchor_right = 1
	close_tooltip.anchor_bottom = 1
	
	for key in config.keys():
		if typeof(config[key]) != TYPE_BOOL: continue
		
		var line = HBoxContainer.new()
		line.rect_min_size.y = 40
		
		var label = Label.new()
		label.set("size_flags_horizontal", 3)
		label.text = regex.sub(key, "$1 $2", true) + ":"
		label.set("custom_colors/font_color", Color(0.37, 0.24, 0.11))
		line.add_child(label)
		
		var option = OptionButton.new()
		option.set("size_flags_horizontal", 3)
		option.set("size_flags_stretch_ratio", 0.75)
		
		option.add_item("Enabled")
		option.add_item("Disabled")
		option.selected = 0 if config[key] else 1
		
		options[key] = option
		
		line.add_child(option)
		options_list.add_child(line)

func _update_config(selected, key):
	config[key] = true if selected == 0 else false

	var config_file = File.new()
	var config_path = gdweave_directory + "/configs/" + mod_id + ".json"
	
	config_file.open(config_path, File.WRITE)
	config_file.store_string(JSON.print(config, "  "))
	config_file.close()

func _apply_changes():
	for key in options:		
		_update_config(options[key].selected, key)

func _on_apply_pressed():
	_apply_changes()
	queue_free()

func _on_restart_pressed():
	_apply_changes()
	
	# Commenting this out for now as it doesn't seem to be relaunching GDWeave.
	#OS.execute("cmd", ["/C", "start", OS.get_executable_path()], false)
	get_tree().quit()

func _on_close_pressed():
	queue_free()
