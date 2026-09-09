extends Resource
## Metre-scale compacted track bed. The broad depression and short tread marks
## have separate shapes, avoiding a continuous trench with a raised rim.
@export var track_half_spacing := 1.30
@export var track_half_width := .43
@export var rut_depth := .105
@export var tread_pitch := .32
@export var tread_depth := .020
@export var berm_height := .035

func displacement(lateral: float, distance_along: float) -> float:
	var drift := .08*sin(distance_along*.23)
	var wheel_distance := absf(absf(lateral-drift)-track_half_spacing)
	var bed := 1.-smoothstep(.24,.80,wheel_distance)
	var pressed := 1.-smoothstep(.27,track_half_width,wheel_distance)
	var wetness := .62+.38*(.5+.5*sin(distance_along*.31+sin(distance_along*.77)))
	var phase := distance_along+absf(lateral-signf(lateral)*track_half_spacing)*.35
	var bar_distance := absf(fposmod(phase,tread_pitch)-tread_pitch*.5)
	var bar := 1.-smoothstep(.025,.080,bar_distance)
	var broken_shoulder := .25+.75*pow(.5+.5*sin(distance_along*.57),2.)
	var shoulder := exp(-pow((wheel_distance-.69)/.24,2.))*berm_height*broken_shoulder
	var extent := smoothstep(-45.,-35.,distance_along)*(1.-smoothstep(25.,36.,distance_along))
	return extent*(-bed*rut_depth*wetness+shoulder-pressed*bar*tread_depth)
