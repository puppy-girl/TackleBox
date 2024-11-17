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
		if mod_config[key] is Dictionary:
			return

		var line := HBoxContainer.new()
		line.rect_min_size.y = 40

		var label := Label.new()
		label.set("size_flags_horizontal", 3)
		label.set("size_flags_vertical", 3)
		label.anchor_top = 0
		label.text = key.capitalize().replace("_", " ") + ":"
		label.set("custom_colors/font_color", Color(0.37, 0.24, 0.11))

		line.add_child(label)

		if mod_config[key] is bool:
			var dropdown := DropdownOption.new(["Enabled", "Disabled"], 0 if mod_config[key] else 1)
			_options[key] = dropdown
			line.add_child(dropdown)
		elif mod_config[key] is String or mod_config[key] is int or mod_config[key] is float:
			var text_input := TextInputOption.new(str(mod_config[key]))
			_options[key] = text_input
			line.add_child(text_input)
		elif mod_config[key] is Array:
			var array_container := ArrayOption.new(mod_config[key])
			_options[key] = array_container
			line.add_child(array_container)

		$"%VBoxContainer".add_child(line)


class DropdownOption:
	extends OptionButton

	func _init(options: Array, selected_index: int) -> void:
		self.set("size_flags_horizontal", 3)
		self.set("size_flags_stretch_ratio", 0.75)

		for option in options:
			self.add_item(option)

		self.selected = selected_index


class TextInputOption:
	extends LineEdit

	func _init(default_value: String) -> void:
		self.set("size_flags_horizontal", 3)
		self.set("size_flags_stretch_ratio", 0.75)

		self.text = default_value


class ArrayOption:
	extends VBoxContainer

	func _init(initial_values: Array) -> void:
		self.set("size_flags_horizontal", 3)
		self.set("size_flags_stretch_ratio", 0.75)

		var array_add = HBoxContainer.new()
		array_add.set("size_flags_horizontal", 3)

		var input = LineEdit.new()
		input.set("size_flags_horizontal", 3)
		array_add.add_child(input)

		var append = Button.new()
		append.text = "+"
		append.connect("pressed", self, "add_value", [input])
		array_add.add_child(append)

		self.add_child(array_add)

		for value in initial_values:
			append_row(str(value))

	func append_row(value: String) -> void:
		var array_content = HBoxContainer.new()
		array_content.name = value

		var content_value = LineEdit.new()
		content_value.name = "value"
		content_value.set("size_flags_horizontal", 3)
		content_value.text = str(value)
		content_value.editable = false
		array_content.add_child(content_value)

		var remove = Button.new()
		remove.text = "–"
		remove.connect("pressed", self, "remove_row", [array_content])
		array_content.add_child(remove)

		self.add_child(array_content)

	func add_value(input) -> void:
		if input.text.replace(" ", "").length() == 0:
			return

		append_row(input.text)
		input.text = ""

	func remove_row(row) -> void:
		self.get_child(row.get_index()).queue_free()


func _update_config() -> int:
	var mod_config: Dictionary = TackleBox.get_mod_config(_mod_id)

	for key in _options:
		if _options[key] is DropdownOption:
			mod_config[key] = true if _options[key].selected == 0 else false

		elif _options[key] is TextInputOption:
			mod_config[key] = (
				_options[key].text
				if mod_config[key] is String
				else float(_options[key].text)
			)

		elif _options[key] is ArrayOption:
			var values := []
			var initial := true
			for row in _options[key].get_children():
				if initial:
					initial = false
					continue

				values.append(row.get_node("value").text)
			mod_config[key] = values

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
