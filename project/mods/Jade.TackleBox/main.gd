class_name TackleBox
extends Node

signal mod_config_updated(mod_id, config)

const MODS_MENU = preload("res://mods/Jade.TackleBox/Scenes/ModMenu/mods_menu.tscn")
const MODS_BUTTON = preload("res://mods/Jade.TackleBox/Scenes/mods_button.tscn")

var gdweave_directory := OS.get_executable_path() + "/../GDWeave/"
var mods_directory := gdweave_directory + "mods/"
var configs_directory := gdweave_directory + "configs/"

var _file := File.new()
var _dir := Directory.new()
var _mod_data: Dictionary
var _config_data: Dictionary


func _init() -> void:
	_init_mod_data()
	_init_config_data()


func _ready() -> void:
	get_tree().connect("node_added", self, "_add_mod_menu")


# Returns mod data for the given mod ID
func get_mod_data(mod_id: String) -> Dictionary:
	if !mod_id in _mod_data:
		push_error("No mod data for mod id " + mod_id)
		return {}
	
	return _mod_data[mod_id]


# Returns the config file for the given mod ID
func get_mod_config(mod_id: String) -> Dictionary:
	if !mod_id in _config_data:
		push_error("No config data for mod id " + mod_id)
		return {}
	
	return _config_data[mod_id]


# Sets the config file for the given mod ID or creates a new one
func set_mod_config(mod_id: String, new_config: Dictionary) -> int:
	if mod_id.find("/") != -1 or mod_id.find("\\") != -1:
		return ERR_INVALID_PARAMETER
	
	if !new_config is Dictionary:
		return ERR_INVALID_DATA
	
	var config_file_path = configs_directory + mod_id + ".json"
	
	var config_file_err := _file.open(config_file_path, File.WRITE)
	if config_file_err != OK:
		return config_file_err
	
	_file.store_string(JSON.print(new_config, "  "))
	_file.close()
	
	_config_data[mod_id] = new_config
	
	emit_signal("mod_config_updated", mod_id, new_config)
	
	return OK


func _init_mod_data() -> void:
	if _dir.open(mods_directory) != OK:
		push_error("Could not open mods directory")
		return
	
	_dir.list_dir_begin(true, true)
	
	var file_name := _dir.get_next()
	while file_name != "":
		if !_dir.current_is_dir():
			file_name = _dir.get_next()
			continue
		
		var manifest_path := mods_directory + file_name + "/manifest.json"
		var mod_id: String
		
		if _file.file_exists(manifest_path):
			_file.open(manifest_path, File.READ)
			
			var manifest_data := JSON.parse(_file.get_as_text())
			if manifest_data.error == OK and "Id" in manifest_data.result:
				mod_id = manifest_data.result.Id
			
			_file.close()
		
		var mod_file_path := mods_directory + file_name + "/mod.json"
		
		if (_file.file_exists(mod_file_path)):
			_file.open(mod_file_path, File.READ)
			
			var mod_file_data := JSON.parse(_file.get_as_text())
			if mod_file_data.error == OK and mod_file_data.result is Dictionary:
				_mod_data[mod_id] = mod_file_data.result
			
			_file.close()
		
		file_name = _dir.get_next()
	
	_dir.list_dir_end()


func _init_config_data() -> void:
	if _dir.open(configs_directory) != OK:
		push_error("Could not open config directory")
		return
	
	_dir.list_dir_begin(true, true)
	
	var file_name := _dir.get_next()
	while file_name != "":
		var config_path := configs_directory + file_name
		var mod_id := file_name.replace(".json", "")
		
		_file.open(config_path, File.READ)
		
		var config_data := JSON.parse(_file.get_as_text())
		if config_data.error == OK and config_data.result is Dictionary:
			_config_data[mod_id] = config_data.result
		
		_file.close()
		
		file_name = _dir.get_next()
	
	_dir.list_dir_end()


func _add_mod_menu(node: Node) -> void:
	if node.name != "main_menu":
		return
	
	var mod_menu: Node = MODS_MENU.instance()
	mod_menu.visible = false
	
	node.add_child(mod_menu)
	
	var menu_list: Node = node.get_node("VBoxContainer")
	var button: Button = MODS_BUTTON.instance()
	
	menu_list.margin_top = -50
	menu_list.add_child(button)
	menu_list.move_child(button, 4)
