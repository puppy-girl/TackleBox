extends Node

onready var main_menu = get_parent()
onready var menu_list = main_menu.get_node("VBoxContainer")

var gdweave_directory = OS.get_executable_path() + "/../GDWeave"

# main_menu.loaded_mods will contain loaded mods inserted by GDWeave
var loaded_mods = [
	"Tackle Box"
]

func _ready():
	menu_list.margin_top = -50

	# Add a button underneath settings for the mod menu
	var mod_menu_button = Button.new()
	menu_list.add_child(mod_menu_button)
	menu_list.move_child(mod_menu_button, 4)
	
	mod_menu_button.add_to_group("menu_button")
	
	mod_menu_button.set("size_flags_vertical", Control.SIZE_EXPAND_FILL)
	
	mod_menu_button.text = "Mods"
	
	mod_menu_button.set("custom_colors/font_color", Color(0.42, 0.27, 0.13))
	mod_menu_button.set("custom_colors/font_color_focus", Color(0.42, 0.27, 0.13))
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
	
	# Append the mod menu to the main menu node
	var mod_menu = preload("res://mods/Jade.TackleBox/Scenes/ModMenu/modmenu.tscn").instance()
	mod_menu.visible = false
	main_menu.call_deferred("add_child", mod_menu)
	mod_menu.call_deferred("_initialise", loaded_mods)

func _open_mod_menu(): main_menu.get_node("mod_menu").visible = true
