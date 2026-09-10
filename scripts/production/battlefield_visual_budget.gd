extends RefCounted
## Distance-tier budget policy for production battlefield visuals.
## Near is deliberately left untouched so the local Hero Shot quality remains the floor.

const NEAR_END_M := 220.0
const MID_END_M := 470.0
const FAR_BEGIN_M := 170.0
const FAR_END_M := 1050.0

static func apply_mid(root: Node, keep_shadow: bool = false) -> void:
	_apply_geometry(root, 0.0, MID_END_M, keep_shadow, false)

static func apply_far(root: Node) -> void:
	_apply_geometry(root, FAR_BEGIN_M, FAR_END_M, false, true)

static func apply_far_always_visible(root: Node) -> void:
	_apply_geometry(root, 0.0, FAR_END_M, false, true)

static func _apply_geometry(root: Node, begin_m: float, end_m: float, keep_shadow: bool, disable_gi: bool) -> void:
	if root is GeometryInstance3D:
		_configure(root as GeometryInstance3D, begin_m, end_m, keep_shadow, disable_gi)
	for child in root.find_children("*", "GeometryInstance3D", true, false):
		_configure(child as GeometryInstance3D, begin_m, end_m, keep_shadow, disable_gi)

static func _configure(instance: GeometryInstance3D, begin_m: float, end_m: float, keep_shadow: bool, disable_gi: bool) -> void:
	instance.visibility_range_begin = begin_m
	instance.visibility_range_end = end_m
	instance.visibility_range_begin_margin = 12.0
	instance.visibility_range_end_margin = 24.0
	if not keep_shadow:
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if disable_gi:
		instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
