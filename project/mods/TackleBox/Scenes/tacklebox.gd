extends Node

onready var main_menu = get_parent()
onready var menu_list = main_menu.get_node("VBoxContainer")

var gdweave_directory = OS.get_executable_path() + "/../GDWeave"

var loaded_mods = [
	"Tacklebox\nYou're looking at me!"
]

func _ready():
	menu_list.margin_top = -50

	var mod_menu_button = Button.new()
	menu_list.add_child(mod_menu_button)
	menu_list.move_child(mod_menu_button, 4)
	
	mod_menu_button.add_to_group("menu_button")
	
	mod_menu_button.set("size_flags_vertical", Control.SIZE_EXPAND_FILL)
	
	mod_menu_button.text = "Mods"
	
	mod_menu_button.set("custom_colors/font_color", Color(0.42, 0.27, 0.13))
	mod_menu_button.set("custom_colors/font_color_hover", Color(1, 0.93, 0.84))
	mod_menu_button.set("custom_colors/font_color_pressed", Color(1, 0.93, 0.84))
	mod_menu_button.set("custom_colors/font_color_disabled", Color(1, 0.93, 0.84))
	
	mod_menu_button.set("custom_styles/normal", load("res://Assets/Themes/button_tan_normal.tres"))
	mod_menu_button.set("custom_styles/hover", load("res://Assets/Themes/button_tan_hover.tres"))
	mod_menu_button.set("custom_styles/pressed", load("res://Assets/Themes/button_tan_pressed.tres"))
	mod_menu_button.set("custom_styles/disabled", load("res://Assets/Themes/button_tan_pressed.tres"))
	
	var button_font = DynamicFont.new()
	button_font.font_data = load("res://Assets/Themes/accid___.ttf")
	button_font.size = 34
	mod_menu_button.add_font_override("font", button_font)
	
	mod_menu_button.connect("pressed", self, "_open_mod_menu")
	
	var mod_menu_tooltip = TooltipNode.new()
	mod_menu_button.add_child(mod_menu_tooltip)
	
	mod_menu_tooltip.header = "[color=#6a4420]Mods"
	mod_menu_tooltip.body = "View and configure installed mods!"

	mod_menu_tooltip.anchor_right = 1
	mod_menu_tooltip.anchor_bottom = 1
	
	var mod_menu = get_node("mod_menu")
	mod_menu.visible = false
	
	var mod_list = mod_menu.get_node("Panel/Panel2/ScrollContainer/VBoxContainer")
	
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
			mod_panel.get_node("Panel/HBoxContainer/Button").visible = true
		
		mod_list.add_child(mod_panel)
	
	call_deferred("remove_child", mod_menu)
	main_menu.call_deferred("add_child", mod_menu)

func _open_mod_menu(): main_menu.get_node("mod_menu").visible = true
func _close_mod_menu(): main_menu.get_node("mod_menu").visible = false

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
