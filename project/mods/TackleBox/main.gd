extends Node

signal mod_config_updated(mod_id, config)

# When testing in the editor add your mod ID here for it to show up!
const DEFAULT_MODS := ["TackleBox"]
const ModMenu := preload("res://mods/TackleBox/scenes/mod_menu/mod_menu.tscn")
const ModsButton := preload("res://mods/TackleBox/scenes/mods_button.tscn")

var gdweave_directory := _get_gdweave_dir()
var mods_directory := gdweave_directory.plus_file("mods")
var configs_directory := gdweave_directory.plus_file("configs")
var gdweave_logs: String
var loaded_mods: Array

var _file := File.new()
var _dir := Directory.new()
var _mod_manifests: Dictionary
var _mod_configs: Dictionary
var _mod_data: Dictionary


func _init() -> void:
	_init_mod_manifests()
	_init_mod_configs()
	gdweave_logs = _get_gdweave_logs()
	loaded_mods = _get_loaded_mods()


func _ready() -> void:
	get_tree().connect("node_added", self, "_add_mod_menu")


# Returns the mod manifest for the given mod ID
# Keys are returned in snake_case
func get_mod_manifest(mod_id: String) -> Dictionary:
	if not mod_id in _mod_manifests:
		push_warning("No mod manifest for mod id " + mod_id)
		return {}

	return _mod_manifests[mod_id]


# Returns mod metadata for the given mod ID
# Keys are returned in snake_case
func get_mod_metadata(mod_id: String) -> Dictionary:
	if mod_id in _mod_data:
		return _mod_data[mod_id]

	if mod_id in _mod_manifests and "metadata" in _mod_manifests[mod_id]:
		return _mod_manifests[mod_id].metadata

	push_warning("No mod metadata for mod id " + mod_id)
	return {}


# Returns the config file for the given mod ID
func get_mod_config(mod_id: String) -> Dictionary:
	if not mod_id in _mod_configs:
		push_warning("No config data for mod id " + mod_id)
		return {}

	return _mod_configs[mod_id]


# Sets the config file for the given mod ID or creates a new one
func set_mod_config(mod_id: String, new_config: Dictionary) -> int:
	if mod_id.find("/") != -1 or mod_id.find("\\") != -1:
		return ERR_INVALID_PARAMETER

	if not new_config is Dictionary:
		return ERR_INVALID_DATA

	var config_file_path = configs_directory.plus_file(mod_id + ".json")

	var config_file_err := _file.open(config_file_path, File.WRITE)
	if config_file_err != OK:
		return config_file_err

	_file.store_string(JSON.print(new_config, "  "))
	_file.close()

	_mod_configs[mod_id] = new_config

	emit_signal("mod_config_updated", mod_id, new_config)

	return OK


func _get_gdweave_dir() -> String:
	var game_directory := OS.get_executable_path().get_base_dir()
	var default_directory := game_directory.plus_file("GDWeave")
	var folder_override: String
	var final_directory: String

	for argument in OS.get_cmdline_args():
		if argument.begins_with("--gdweave-folder-override="):
			folder_override = argument.trim_prefix("--gdweave-folder-override=").replace("\\", "/")

	if folder_override:
		var relative_path := game_directory.plus_file(folder_override)
		var is_relative := not ":" in relative_path and _file.file_exists(relative_path)

		final_directory = relative_path if is_relative else folder_override
	else:
		final_directory = default_directory

	return final_directory


func _init_mod_manifests() -> void:
	if not _dir.dir_exists(mods_directory):
		_dir.make_dir(mods_directory)

	if _dir.open(mods_directory) != OK:
		push_error("TackleBox could not open mods directory")
		return

	_dir.list_dir_begin(true, true)

	var file_name := _dir.get_next()
	while file_name != "":
		if not _dir.current_is_dir():
			file_name = _dir.get_next()
			continue

		var manifest_path := mods_directory.plus_file(file_name + "/manifest.json")
		var mod_id: String

		if _file.file_exists(manifest_path):
			_file.open(manifest_path, File.READ)

			var manifest_data := JSON.parse(_file.get_as_text())
			if manifest_data.error == OK and "Id" in manifest_data.result:
				mod_id = manifest_data.result.Id
				_mod_manifests[mod_id] = _snakeify_keys(manifest_data.result)

			_file.close()

		var mod_file_path := mods_directory.plus_file(file_name + "/mod.json")

		if _file.file_exists(mod_file_path):
			_file.open(mod_file_path, File.READ)

			var mod_file_data := JSON.parse(_file.get_as_text())
			if mod_file_data.error == OK and mod_file_data.result is Dictionary:
				_mod_data[mod_id] = mod_file_data.result

			_file.close()

		file_name = _dir.get_next()

	_dir.list_dir_end()


func _init_mod_configs() -> void:
	if not _dir.dir_exists(configs_directory):
		_dir.make_dir(configs_directory)
	
	if _dir.open(configs_directory) != OK:
		push_warning("TackleBox could not open configs directory")
		return

	_dir.list_dir_begin(true, true)

	var file_name := _dir.get_next()
	while file_name != "":
		var config_path := configs_directory.plus_file(file_name)
		var mod_id := file_name.replace(".json", "")

		_file.open(config_path, File.READ)

		var config_data := JSON.parse(_file.get_as_text())
		if config_data.error == OK and config_data.result is Dictionary:
			_mod_configs[mod_id] = config_data.result

		_file.close()

		file_name = _dir.get_next()

	_dir.list_dir_end()


func _get_gdweave_logs() -> String:
	var log_file_path := gdweave_directory.plus_file("GDWeave.log")

	if not _file.file_exists(log_file_path):
		push_error("TackleBox could not get the GDWeave log file: does not exist")
		return ""

	_file.open(log_file_path, File.READ)
	var logs := _file.get_as_text()
	_file.close()

	return logs


func _get_loaded_mods() -> Array:
	if OS.has_feature("editor"):
		return DEFAULT_MODS

	var mods := []

	var regex = RegEx.new()
	regex.compile("Loaded \\d+ mods: (?<mods>\\[.*\\])")

	var search: RegExMatch = regex.search(gdweave_logs)
	var loaded_mod_logs := JSON.parse(search.get_string("mods") if search else "")

	if loaded_mod_logs.error != OK:
		push_error("TackleBox could not parse loaded mods from the log file")
		return []

	return loaded_mod_logs.result


func _add_mod_menu(node: Node) -> void:
	if node.name == "main_menu" or node.name == "esc_menu":
		var mod_menu: Node = ModMenu.instance()
		mod_menu.visible = false

		node.add_child(mod_menu)

		var menu_list: Node = node.get_node("VBoxContainer")
		var button: Button = ModsButton.instance()
		var settings_button: Node = menu_list.get_node("settings")

		menu_list.add_child(button)
		menu_list.move_child(button, settings_button.get_index() + 1)

		if node.name == "main_menu":
			menu_list.margin_top -= 48
		else:
			menu_list.margin_top -= 24
			menu_list.margin_bottom += 24


func _snakeify_keys(input: Dictionary) -> Dictionary:
	var new_dictionary := {}

	for key in input:
		if input[key] is Dictionary:
			new_dictionary[_to_snake_case(key)] = _snakeify_keys(input[key])
		else:
			new_dictionary[_to_snake_case(key)] = input[key]

	return new_dictionary


func _to_snake_case(input: String) -> String:
	var regex = RegEx.new()
	regex.compile("([a-z])([A-Z])")
	return regex.sub(input, "$1_$2", true).to_lower()
