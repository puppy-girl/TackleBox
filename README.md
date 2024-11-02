# Tackle Box
A mod list and configuration editor for GDWeave mods in WEBFISHING! 🎣

Adds a "Mods" button to the main and escape menus to view a list of the mods currently loaded by GDWeave. If a mod fails to load it will be separated and labelled by Tackle Box to aid in discovering problems with installed mods.

Mods that come with additional config options will show a button to configure them, allowing you to enable/disable features of a mod or change a mod's behaviour without touching a json file!

![A screenshot of Tackle Box's mod menu](https://github.com/user-attachments/assets/1c2ae01c-2ce7-4381-bde9-cd82ed3ec238)

## Installation
> [!IMPORTANT]  
> Tackle Box requires GDWeave v2.0.9 or later. If you haven't updated, get the [latest release](https://github.com/NotNite/GDWeave/releases/latest/).

[Download Tackle Box](https://github.com/puppy-girl/TackleBox/releases/latest/download/TackleBox.zip) and put the extracted mod folder into `GDWeave/mods`. Your `mods` folder should hold a `TackleBox` directory with all the mod files inside it ૮˶• ﻌ •˶ა

## For Mod Developers
Tackle Box can display additional metadata for loaded mods, such as its current version, author, and a brief description! To include richer metadata with your mod for Tackle Box to display, add a `"Metadata"` key to your `manifest.json` with the following value:
```json
{
    "Name": "The name of your mod",
    "Author": "Your name goes here~!",
    "Version": "Your mod's current version formatted as a string",
    "Description": "A brief description of your mod"
}
```
For an example of what your manifest should look like, check out [Tackle Box's manifest](https://github.com/puppy-girl/TackleBox/blob/main/manifest.json)!

Additionally, as of version 0.2.0, Tackle Box comes with additional utilities for developers to take advantage of. To use Tackle Box's utilities in your code, add the following to the top of your script:

`onready var TackleBox := $"/root/TackleBox"`

To make sure Tackle Box is available for your mod to use, include `"TackleBox"` in the dependencies in your mod's `manifest.json`

### Signals

`signal mod_config_updated(mod_id, config)`

Emits a signal every time a mod's config is updated through Tackle Box's methods

### Methods

`get_mod_manifest(mod_id: String) -> Dictionary`

Returns the mod manifest for the given mod ID. Keys are returned in snake_case

`get_mod_metadata(mod_id: String) -> Dictionary`

Returns the mod metadata for the given mod ID. Keys are returned in snake_case

`get_mod_config(mod_id: String) -> Dictionary`

Returns the config for the given mod ID.

`set_mod_config(mod_id: String, new_config: Dictionary) -> int`

Sets the config for the given mod ID and creates a new config file if one doesn't exist; returns an error code if unable to write to the config
