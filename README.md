# Tackle Box
A mod list and configuration editor for GDWeave-compatible mods in Webfishing! 🎣

Adds a button to Webfishing's main menu to view a list of the mods currently loaded by GDWeave. Mods with additional config files will have a config menu, allowing you to enable/disable features of a mod without touching a json file. Currently only true or false values are supported for Tackle Box's config editor but this is subject to change!

![Tackle Box's mod menu](https://github.com/user-attachments/assets/e25feb64-ca22-4edf-ab86-79a4ca6e558d)

## Installation
> [!IMPORTANT]  
> Tackle Box requires GDWeave v2.0.9 or later. If you haven't updated, get the [latest release](https://github.com/NotNite/GDWeave/releases/latest/).

[Download Tackle Box](https://github.com/puppy-girl/TackleBox/releases/latest/download/TackleBox.zip) and put the extracted mod folder into `GDWeave/mods`. Your `mods` folder should hold a `TackleBox` directory with all the mod files inside it ૮˶• ﻌ •˶ა

## For Mod Developers
Tackle Box can display additional metadata for loaded mods, as seen in-game! Tackle Box gets this information from a `mod.json` file in the mod directory, placed alongside `manifest.json`. If you'd like your mod to show richer information in Tackle Box just create a `mod.json` file with the following fields:
```json
{
    "name": "The name of your mod!",
    "version": "Your mod's current version, formatted as a string",
    "description": "A brief description of your mod, ideally below 75-80 characters",
    "author": "Your name! <3"
}
```
More fields will be added in future as the functionality of Tackle Box expands but mods won't be required to include or update the `mod.json` file.
