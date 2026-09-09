extends Resource
## Reusable displacement profile in metres. Evaluate at every mesh vertex and
## grounding query; changing route placement never separates detail from the road.
@export var track_half_spacing := 1.30
@export var track_half_width := .38
@export var rut_depth := .24
@export var tread_pitch := .32
@export var tread_depth := .034
@export var berm_height := .050

func displacement(lateral: float, distance_along: float) -> float:
	var wheel_distance := minf(absf(lateral-track_half_spacing),absf(lateral+track_half_spacing))
	var rut := 1.-smoothstep(.25,.72,wheel_distance)
	var imprint := 1.-smoothstep(track_half_width*.64,track_half_width,wheel_distance)
	# Alternating chevrons are physically pressed into the same terrain surface.
	# 8 cm vertices resolve the 32 cm pitch; compressed ridges remain above the cuts.
	var side := signf(lateral)
	var phase := distance_along+absf(lateral-side*track_half_spacing)*.46
	var bar_distance := absf(fposmod(phase,tread_pitch)-tread_pitch*.5)
	var bars := 1.-smoothstep(tread_pitch*.13,tread_pitch*.32,bar_distance)
	var berm := exp(-pow((wheel_distance-.58)/.17,2.))*berm_height
	var travelled := smoothstep(-15.,-8.,distance_along)*(1.-smoothstep(23.,30.,distance_along))
	return -rut*rut_depth*(1.-smoothstep(24.,30.,distance_along))+travelled*(berm-imprint*bars*tread_depth)
