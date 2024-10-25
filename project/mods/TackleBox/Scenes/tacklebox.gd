extends Node

onready var main_menu = get_parent()
onready var menu_list = main_menu.get_node("VBoxContainer")

var loaded_mods = [
	"TackleBox\nYou're looking at me!",
	"Test\nA test mod."
]

func _ready():
	menu_list.margin_top = -50

	var mod_menu_button = Button.new()
	menu_list.add_child(mod_menu_button)
	menu_list.move_child(mod_menu_button, 4)
	
	mod_menu_button.connect("mouse_entered", self, "main_menu._hover_button", [mod_menu_button])
	mod_menu_button.connect("mouse_exited", self, "main_menu._exit_button", [mod_menu_button])
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
	
	for mod in loaded_mods:
		var mod_panel = preload("res://mods/TackleBox/Scenes/ModPanel/modpanel.tscn").instance()
		mod_panel.get_node("Panel/HBoxContainer/Label").bbcode_text = mod
		mod_list.add_child(mod_panel)
	
	call_deferred("remove_child", mod_menu)
	main_menu.call_deferred("add_child", mod_menu)

func _open_mod_menu(): main_menu.get_node("mod_menu").visible = true
func _close_mod_menu(): main_menu.get_node("mod_menu").visible = false
