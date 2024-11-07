package dgskin

import ("list")

name:        "drummania imitator"
gameVersion: "0.9.0"
skinVersion: "0.2.0"

// notes

// alternating
// 13 / 720 per 1 / 60 second for 4.0 speed
// 14 / 720 per 1 / 60 second for 4.0 speed
// 13.5 / 720 * 60 = 1.125 screens per second = 810 pixels per second

// 150 / 720 for judgement line height from centre to bottom
// 6 / 720 for judgement line thickness
// ~9 / 720 chip thickness at 4.0 speed
// ~6 / 720 chip thickness at 1.0 speed
// ~24 or 23 / 720 chip thickness at 20.0 speed
// formula is about 6 * (1 + (speed-1)/6) = 6 + (speed - 1) = 5 + speed

// region internal state

// inputs to be used as in gitadora's settings page
_#inputs: {
	speed:      number | *4.0
	laneLayout: *"A" | "B" | "C" | "D"
	shutter: {
		top:    #Percentage | *0
		bottom: #Percentage | *0
	}
	targetLinePosition:   #Percentage | *0
	targetEffectPosition: *"A" | "B"
}

// these are constants no matter what
_#constants: {
	// as in the default position with setting 0
	screen: {
		height:      720
		width:       1280
		aspectRatio: width / height
	}
	judgementLine: {
		position:  150 / screen.height // old 156, 0.216
		thickness: 6 / screen.height
		offset:    1 / screen.height
	}
	judgementText: {
		position: {
			A: 328 / screen.height // 0.455
			B: 90 / screen.height
		}
		offset: 32 / screen.height
	}
	chip: {}
	beatLine: {
		thickness: 1 / screen.height // 0.0015
		color:     "#808080e0"
	}
	measureLine: {
		thickness: 2 / screen.height // 0.003
		color:     "#e0e0e0e0"
	}
	background: {
		color: "#000"
	}
	border: {
		color: "#585858"
	}
}

// internal state data for use in the skin
// these are intermediates that cant be simply calculated from inputs or constants
// (aka has a long calc)
_#settings:
	lanes:
		[#Channel]:
			judgementText:
				offsetMult: int

_#settings: {
	lanes: {
		china:
			judgementText: offsetMult: *+2 | _
		hihat:
			judgementText: offsetMult: *+0 | _
		"hihat-pedal":
			judgementText: offsetMult: *-1 | _
		snare:
			judgementText: offsetMult: *+0 | _
		"high-tom":
			judgementText: offsetMult: *+1 | _
		bass:
			judgementText: offsetMult: *-1 | _
		"mid-tom":
			judgementText: offsetMult: *+1 | _
		"low-tom":
			judgementText: offsetMult: *+0 | _
		crash:
			judgementText: offsetMult: *+2 | _
		ride:
			judgementText: offsetMult: *+0 | _
	}
}

// endregion
// =============================================================================
// =============================================================================
// region program

// region functions

_#fn: {
	offset: {
		_#offset: int

		_#constants.judgementText.position[_#inputs.targetEffectPosition] +
		(_#constants.judgementText.offset * _#offset)
	}
	framerateToMs: {
		_#framerate: >1 & int

		1000 / _#framerate
	}
}

// endregion

// lane index
mania:
	lanes: {
		// open hand hihat position (remote stand required)
		// hihat: index: 4.25

		// ride after right crash
		ride: index: 9
	}

if (_#inputs.laneLayout == "B") {
	mania: lanes: "hihat-pedal": index: 3.5
	mania: lanes: "high-tom": index:    5.5
}
if (_#inputs.laneLayout == "C") {
	mania: lanes: "high-tom": index: 5.5
}
if (_#inputs.laneLayout == "D") {
	mania: lanes: "hihat-pedal": index: 4.5
}

// icon position
mania: {
	iconContainerPosition: _#constants.judgementLine.position - 0.1
	iconContainerHeight:   _#constants.judgementLine.position - iconContainerPosition
}

// icon size
mania:
	lanes:
		[#Channel]:
			_icon=icon: {
				if _icon.crop.width > _icon.crop.height {
					fill: "fit"
				}
			}

// icon animation
mania:
	iconAnimation: "dtxBounceDown"

// judgement text position
mania:
	lanes:
		[channel=#Channel]:
			judgementTextPosition: number | *(_#fn.offset & {_, _#offset: _#settings.lanes[channel].judgementText.offsetMult})

// set filtering mode and blend
mania:
	judgements:
		[#CoarseJudgement]:
			filteringMode: "linear"

mania:
	lanes:
		[#Channel]:
			chip:
				filteringMode: "nearest"

// endregion
// =============================================================================
// =============================================================================
// region mania values
// TODO: refactor this heavily
// TODO: make the lanes portion more compact by utilising CUE to its potential
// TODO: refactor lanes to instead use an intermediate object

mania: {
	scrollMultiplier: _#inputs.speed / 810 * _#constants.screen.height
	ghostNoteWidth:   0.6
	judgementLine: {
		texture: {
			file: "Graphics/ScreenPlayDrums hit-bar.png"
			crop: {
				y:      1
				height: 5
				width:  8
			}
			fill:      "stretch"
			wrapModeS: "repeat"
		}
		position: _#constants.judgementLine.position +
				(_#inputs.targetLinePosition * _#constants.judgementLine.offset)
		thickness: _#constants.judgementLine.thickness
	}
	chipThickness:        (5 + _#inputs.speed) / _#constants.screen.height
	beatLineThickness:    _#constants.beatLine.thickness
	measureLineThickness: _#constants.measureLine.thickness
	beatLineColor:        _#constants.beatLine.color
	measureLineColor:     _#constants.measureLine.color
	backgroundColor:      _#constants.background.color
	borderColor:          _#constants.border.color

	shutter: {
		texture: {
			file: "Graphics/7_shutter.png"
		}
		height: _#inputs.shutter.bottom / 100
	}

	laneContainer: {
		relativeSizeAxes: "both"
		fillMode:         "fit"
		fillAspectRatio: {
			(list.Sum([for channel, lane in mania.lanes {
				lane.width + lane.leftBorder.width
			}]) + 2) / _#constants.screen.width * _#constants.screen.aspectRatio
		}
		relativePosition: {
			// TODO: refactor to use a "lane width" instead of undoing the calculation
			x: 295/_#constants.screen.width + (fillAspectRatio * 9 / 16 / 2)
			y: 0
		}
		origin: "topCentre"
	}
	hitErrorDisplay: {
		anchorTarget: "laneContainer"
		origin:       "centre"
		width:        200.0
		height:       40.0
		y:            -50
		anchor:       "bottomCentre"
		layout:       "horizontal"
	}
	video: {
		anchorTarget: "songInfoPanel"
		origin:       "topLeft"
		anchor:       "bottomLeft"
		width:        _#constants.screen.width * 0.3
		height:       _#constants.screen.height * 0.3
		y:            5
	}
	songInfoPanel: {
		layout:       "vertical"
		anchorTarget: "positionIndicator"
		origin:       "topLeft"
		anchor:       "topRight"
		x:            5
		y:            5
	}

	judgements: {
		chips:    false
		textures: true
		errorNumbers: {
			show:         true
			showFastSlow: false

			// elementData: {
			// 	anchorTarget: "laneContainer"
			// 	origin:       "bottomCentre"
			// 	relativePosition: {
			// 		x: 0.32
			// 		y: 0.7
			// 	}
			// }
		}
		[#CoarseJudgement]: {
			crop: {
				height: 170
				width:  250
			}
			animateY:      170
			frameCount:    24
			frameDuration: 14
			scaleX:        0.45
			scaleY:        0.45
			fill:          "fill"
			file:          "Graphics/7_judge strings.png"
		}
		perfect: crop: x: 0
		good: crop: x:    250
		bad: crop: x:     750
		miss: crop: x:    1000
	}

	lanes: {
		_channel=[#Channel]: {
			// TODO: secondaries
			if (_channel.leftBorder.texture.crop.x != _|_) {
				leftBorder: texture: {
					crop: {
						width:  _channel.leftBorder.width
						height: _#constants.screen.height
					}
					file:  "Graphics/7_Paret.png"
					fill:  "stretch"
					alpha: 0.8
				}
			}
			if (_channel.background.crop.x != _|_) {
				background: {
					crop: {
						width:  _channel.width
						height: _#constants.screen.height
					}
					file: "Graphics/7_Paret.png"
					fill: "stretch"
				}
			}
			if (_channel.icon.crop.x != _|_) {
				icon: {
					file: "Graphics/7_pads.png"
				}
			}
			if (_channel.chip.crop.x != _|_) {
				chip: {
					crop: {
						height: 12
						width:  _channel.width
						y:      26
					}
					file: "Graphics/7_chips_drums.png"
					fill: "stretch"
				}
			}
			if (_channel.adornment.crop.x != _|_) {
				adornment: {
					crop: {
						height: 64
						y:      128
					}
					file:          "Graphics/7_chips_drums.png"
					animateY:      64
					frameCount:    8
					frameDuration: 70
				}
			}

			background:
				alpha: 0.8

			attack: {
				file:          "Graphics/ScreenPlayDrums chip fire.png"
				frameCount:    12
				frameDuration: (1000 / 45)
				animateX:      150
				fill:          "fill"
				blend:         "additive"
				crop: {
					width:  150
					height: 150
				}
			}
		}

		// pedals
		"hihat-pedal": {
			width: 50
			leftBorder: {
				width: 1
				texture:
					crop:
						x: 122
			}
			background:
				crop:
					x: 123
			icon: {
				crop: {
					x:      118
					y:      192
					width:  50
					height: 56
				}
			}
			chip: {
				crop: {
					width: 50
					x:     664
				}
			}
			adornment: {
				crop: {
					width: 58
					x:     660
				}
			}
			secondary: [
				{
					chip: {
						crop: {
							height: 12
							width:  48
							x:      485
							y:      26
						}
						file: "Graphics/7_chips_drums.png"
						fill: "stretch"
					}
					adornment: {
						crop: {
							height: 64
							width:  58
							x:      480
							y:      128
						}
						file:          "Graphics/7_chips_drums.png"
						filteringMode: "linear"
						animateY:      64
						frameCount:    8
						frameDuration: 70
					}
				},
			]
		}
		bass: {
			width: 62
			leftBorder: {
				width: 7
				texture:
					crop:
						x: 279
			}
			background: {
				crop: {
					x: 286
				}
			}
			icon: {
				crop: {
					x:      16
					y:      192
					width:  62
					height: 56
				}
			}
			chip: {
				// color:          "#8b70ff"
				// fragmentShader: "sh_chip.fs"
				crop: {
					width: 62
					x:     4
				}
			}
			adornment: {
				crop: {
					width: 70
					x:     0
				}
			}
		}

		// drums
		snare: {
			width: 56
			leftBorder: {
				width: 1
				texture:
					crop:
						x: 173
			}
			background: {
				color: "#000"
				fill:  "stretch"
			}
			icon: {
				crop: {
					x:      23
					y:      96
					width:  56
					height: 64
				}
			}
			chip: {
				// color:          "#ffc808"
				// fragmentShader: "sh_chip.fs"
				crop: {
					width: 56
					x:     130
				}
			}
		}
		"high-tom": {
			width: 48
			leftBorder: {
				width: 1
				texture:
					crop:
						x: 230
			}
			background: {
				color: "#000"
				fill:  "stretch"
			}
			icon: {
				crop: {
					x:      112
					y:      96
					width:  48
					height: 64
				}
			}
			chip: {
				crop: {
					width: 48
					x:     194
				}
			}
		}
		"mid-tom": {
			width: 48
			leftBorder: {
				width: 1
				texture:
					crop:
						x: 348
			}
			background: {
				color: "#000"
				fill:  "stretch"
			}
			icon: {
				crop: {
					x:      214
					y:      96
					width:  48
					height: 64
				}
			}
			chip: {
				crop: {
					width: 48
					x:     250
				}
			}
		}
		"low-tom": {
			width: 48
			leftBorder: {
				width: 1
				texture:
					crop:
						x: 397
			}
			background: {
				color: "#000"
				fill:  "stretch"
			}
			icon: {
				crop: {
					x:      309
					y:      96
					width:  48
					height: 64
				}
			}
			chip: {
				crop: {
					width: 48
					x:     306
				}
			}
			adornment: {
				crop: {
					width: 56
					x:     302
				}
			}
		}

		// cymbals
		china: {
			width: 65
			leftBorder: {
				width: 3
				texture:
					crop:
						x: 0
			}
			background: {
				crop: {
					x: 3
				}
			}
			icon: {
				crop: {
					x:      35
					y:      0
					width:  65
					height: 64
				}
			}
			adornment: {
				crop: {
					width: 74
					x:     538
				}
			}
			chip: {
				crop: {
					width: 65
					x:     543
				}
			}
			secondary: [
				{
					channel: "splash"
					adornment: {
						crop: {
							height: 64
							width:  48
							x:      612
							y:      128
						}
						file:          "Graphics/7_chips_drums.png"
						animateY:      64
						frameCount:    8
						frameDuration: 70
					}
					chip: {
						crop: {
							height: 12
							width:  46
							x:      75
							y:      26
						}
						scaleX: 0.8
						file:   "Graphics/7_chips_drums.png"
						fill:   "stretch"
					}
				},
			]
		}
		hihat: {
			width: 48
			leftBorder: {
				width: 6
				texture:
					crop:
						x: 68
			}
			background: {
				color: "#000"
				fill:  "stretch"
			}
			icon: {
				crop: {
					x:      129
					y:      0
					width:  48
					height: 64
				}
			}
			adornment: {
				crop: {
					width: 56
					x:     70
				}
			}
			chip: {
				crop: {
					width: 48
					x:     74
				}
			}
			secondary: [
				{
					chip: {
						crop: {
							height: 12
							width:  38
							x:      617
							y:      26
						}
						file:   "Graphics/7_chips_drums.png"
						fill:   "stretch"
						scaleX: 38 / 46
					}
					adornment: {
						crop: {
							height: 64
							width:  48
							x:      612
							y:      128
						}
						file:          "Graphics/7_chips_drums.png"
						animateY:      64
						frameCount:    8
						frameDuration: 70
					}
				},
			]

		}
		crash: {
			width: 66
			leftBorder: {
				width: 6
				texture:
					crop:
						x: 446
			}
			background: {
				crop: {
					x: 452
				}
			}
			icon: {
				crop: {
					x:      204
					y:      0
					width:  66
					height: 64
				}
			}
			chip: {
				crop: {
					width: 66
					x:     362
				}
			}
			adornment: {
				crop: {
					width: 74
					x:     358
				}
			}
		}
		ride: {
			width: 40
			leftBorder: {
				width: 1
				texture:
					crop:
						x: 518
			}
			color: "#11A8CD"
			background: {
				color: "#000"
				fill:  "stretch"
			}
			icon: {
				crop: {
					x:      204
					y:      0
					width:  66
					height: 64
				}
			}
			chip: {
				crop: {
					width: 40
					x:     436
				}
			}
			secondary: [
				{
					channel: "ride-bell"
					adornment: {
						crop: {
							height: 64
							width:  48
							x:      432
							y:      128
						}
						file:          "Graphics/7_chips_drums.png"
						scaleX:        1.25
						scaleY:        1.25
						animateY:      64
						frameCount:    8
						frameDuration: 70
					}
					chip: {
						crop: {
							height: 12
							width:  38
							x:      437
							y:      26
						}
						file: "Graphics/7_chips_drums.png"
						fill: "stretch"
						// scaleX: 0.8
					}
				},
			]
		}
	}
}

// endregion
// =============================================================================
// =============================================================================
// region notation values

notation: {
	notationColor:          "#e0e0e0"
	staffLineColor:         "#454545"
	playfieldBackground:    "#1f1f1f"
	inputDisplayBackground: "#282828"
	measureLines:           true
	channels: {
		"high-tom": {
			color: "#4fa8e1"
		}
		"mid-tom": {
			color: "#95a94e"
		}
		"low-tom": {
			color: "#da7d9b"
		}
	}
}

// endregion
