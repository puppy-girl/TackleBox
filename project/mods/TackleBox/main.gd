extends Node

const TACKLEBOX = preload("res://mods/TackleBox/Scenes/tacklebox.tscn")

func _ready():
	get_tree().connect("node_added", self, "_init_tacklebox")
	
func _init_tacklebox(node: Node):
	if node.name == "main_menu": node.add_child(TACKLEBOX.instance())
