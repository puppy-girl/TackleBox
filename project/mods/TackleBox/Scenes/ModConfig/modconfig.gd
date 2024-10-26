extends Node

onready var options_list = get_node("Panel/config/ScrollContainer/VBoxContainer")

var gdweave_directory = OS.get_executable_path() + "/../GDWeave"

var config = {}

func _initialise(id):
	var config_file = File.new()
	var config_path = gdweave_directory + "/configs/" + id + ".json"
	
	config_file.open(config_path, File.READ)
	var config_data = JSON.parse(config_file.get_as_text())
	if !config_data.error == OK: return
	
	config = config_data.result
	config_file.close()
	
	var regex = RegEx.new()
	regex.compile("([a-z])([A-Z])")
	
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
		
		option.connect("item_selected", self, "_update_config", [id, key])
		
		line.add_child(option)
		
		options_list.add_child(line)

func _update_config(selected, id, key):
	config[key] = true if selected == 0 else false

	var config_file = File.new()
	var config_path = gdweave_directory + "/configs/" + id + ".json"
	
	config_file.open(config_path, File.WRITE)
	config_file.store_string(JSON.print(config, "  "))
	config_file.close()

func _on_close_pressed():
	queue_free()
