# Drum Game drummania skin

This is a skin for [Drum Game](https://github.com/Jumprocks1/drum-game) that mimics drummania as closely as possible.

![Preview](preview.png?raw=true)

## Usage
1. Install [Drum Game](https://github.com/Jumprocks1/drum-game)
2. Create a folder `skins/dg-drummania-skin` in your resources folder

### Basic (speed 4.0, no customisation)
3. Put `skin.json` from the Releases in the folder
4. Find a DTXMania drummania skin and copy the `Graphics` folder into the `dg-drummania-skin` folder

### Intermediate (customise your skin)
This is for when you want to customise the skin with the same settings as drummania.

3. Install the [CUE language tooling](https://github.com/cue-lang/cue)
4. Clone this repo into the `dg-drummania-skin` folder with `git clone https://github.com/de-odex/dg-drummania-skin`
5. Create a `custom.cue` file in the `dg-drummania-skin` folder and put this text inside, changing the values to what you like:
```cue
package dgskin

_#inputs: {
	speed:                4.0  // your speed (0.5 to 20.0)
	targetLinePosition:   0    // your target line position (0 to 100)
	targetEffectPosition: "A"  // your target effect position (A, B)
	laneLayout:           "A"  // your lane layout (A, B, C, D)
	shutter:
		top: 0
		bottom: 0
}
```
6. Compile the skin with `cue export -fo ./skin.json`

### Advanced (change anything about the skin)
This will be an upcoming feature for this skin.