package dgskin

// region types

#Percentage: <=100 & >=0

#Vec2: {
	x?: number
	y?: number
}
#Rectangle: {
	#Vec2
	width?:  number
	height?: number
}
#Proportion: <=1 & >=0

#AnchorTarget: "laneContainer" | "modeText" | "positionIndicator" |
		"songInfoPanel" | "video"
#Anchor: "topLeft" | "topCentre" | "topRight" |
	"centreLeft" | "centre" | "centreRight" |
	"bottomLeft" | "bottomCentre" | "bottomRight"
#Axes: "x" | "y" | "both"

#Color: =~"^#([0-9a-fA-F]{3,4}|([0-9a-fA-F]{2}){3,4})$"

#Texture: {
	file?:           string
	fragmentShader?: =~"sh_.*\\.fs"
	fill?:           "fill" | "fit" | "stretch"
	crop?:           #Rectangle
	blend?:          "additive" | "mixture"
	wrapModeS?:      "none" | "clampToEdge" | "clampToBorder" | "repeat"
	wrapModeT?:      "none" | "clampToEdge" | "clampToBorder" | "repeat"
	filteringMode?:  "linear" | "nearest"
	aspectRatio?:    number
	animateX?:       number
	animateY?:       number
	frameCount?:     int
	frameDuration?:  number // milliseconds per frame
	alpha?:          number
	scaleX?:         number
	scaleY?:         number
	color?:          #Color
} | string

#Element: {
	#Rectangle
	anchorTarget?:     #AnchorTarget
	origin?:           #Anchor
	anchor?:           #Anchor
	scale?:            number
	relativePosition?: #Vec2
	relativeSizeAxes?: #Axes
	fillMode?:         "stretch" | "fill" | "fit"
	fillAspectRatio?:  number
}

//

#channels: [
	"snare",
	"bass",
	"hihat",
	"crash",
	"open-hihat",
	"half-hihat",
	"ride",
	"ride-bell",
	"sidestick",
	"high-tom",
	"mid-tom",
	"low-tom",
	"hihat-pedal",
	"splash",
	"china",
	"rim",
]

#Channel: or(#channels)

#judgements: [
	"earlyMiss",
	"lateMiss",
	"miss",
	"earlyBad",
	"lateBad",
	"bad",
	"earlyGood",
	"lateGood",
	"good",
	"earlyPerfect",
	"latePerfect",
	"perfect",
]

#Judgement: or(#judgements)

#coarseJudgements: [
	"perfect",
	"good",
	"bad",
	"miss",
]

#CoarseJudgement: or(#coarseJudgements)

//

#JudgementDisplay: {
	chips?:        bool
	textures?:     bool
	hideHitChips?: bool
	errorNumbers?: {
		show?:         bool
		showFastSlow?: bool
		fastColor?:    #Color
		slowColor?:    #Color
		singleLane?:   #Channel
		y?:            number
	}
	[#CoarseJudgement]: #Texture
}

#ManiaLane: {
	index?: number
	width?: number
	leftBorder?: {
		texture?: #Texture
		width?:   number
		color?:   #Color
	}
	judgementTextPosition?: #Proportion
	color?:                 #Color

	adornment?:  #Texture
	chip?:       #Texture
	icon?:       #Texture
	attack?:     #Texture
	background?: #Texture

	// secondary?: #ManiaLaneSecondary | [...#ManiaLaneSecondary]
	secondary?: [...#ManiaLaneSecondary]
}

#ManiaLaneSecondary: {
	channel?: #Channel

	color?: #Color

	adornment?: #Texture
	chip?:      #Texture
}

//

#noteheads: [
	for head in [
		"Black",
		"XBlack",
		"CircleX",
		"CircledBlackLarge",
		"XOrnate",
		"XOrnateEllipse",
		"DiamondWhite",
		"DiamondBlack",
	] {
		"notehead\(head)"
	},
]

#Notation: {
	zoomMultiplier?:        number
	cursorInset?:           number
	smoothScroll?:          bool
	noteSpacingMultiplier?: >=0

	notationColor?:          #Color
	noteColor?:              #Color
	leftNoteColor?:          #Color
	rightNoteColor?:         #Color
	staffLineColor?:         #Color
	playfieldBackground?:    #Color
	inputDisplayBackground?: #Color
	songInfoPanel?: {
		#Element
		layout?: "default" | "vertical"
	}
	measureLines?:     bool
	measureLineColor?: #Color
	channels?: [#Channel]: {
		color?:                 #Color
		leftColor?:             #Color
		rightColor?:            #Color
		accentColor?:           #Color
		ghostColor?:            #Color
		stickingColorNotehead?: bool
		position?:              int
		notehead?:              or(#noteheads)
	}
}

#Mania: {
	scrollMultiplier?: number

	ghostNoteWidth?: #Proportion
	judgementLine?: {
		texture?:   #Texture
		color?:     #Color
		position?:  #Proportion
		thickness?: #Proportion
		offset?:    number
	}
	chipThickness?:        #Proportion
	beatLineColor?:        #Color
	backgroundColor?:      #Color
	backgroundFontColor?:  #Color
	borderColor?:          #Color
	beatLineThickness?:    #Proportion
	measureLineColor?:     #Color
	measureLineThickness?: #Proportion
	// TODO: TEMP
	iconContainerHeight?:   number
	iconContainerPosition?: number
	iconAnimation:          "expand" | "bounceDown" | "dtxBounceDown"

	shutter?: {
		texture?: #Texture
		height?:  #Proportion
	}
	songInfoPanel?: {
		#Element
		layout?: "default" | "vertical"
	}
	hitErrorDisplay?: {
		#Element
		layout?: "default" | "vertical" | "horizontal"
	}
	positionIndicator?: {
		#Element
		afterColor?:  #Color
		beforeColor?: #Color
		cursorColor?: #Color
	}
	practiceInfoPanel?: #Element
	laneContainer?:     #Element
	video?:             #Element

	judgements?: #JudgementDisplay
	lanes?: [#Channel]: #ManiaLane
}

// endregion

// region schema

gameVersion?: string
name?:        string
description?: string
comments?:    string
skinVersion?: string
notation?:    #Notation
mania?:       #Mania
hitColors: close({[#Judgement]: #Color})
// hitColors?: close({
// 	for judgement in #judgements {
// 		(judgement)?: #Color
// 	}
// })
// "$schema": string

// endregion
