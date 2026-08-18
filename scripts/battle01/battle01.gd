extends Node2D

const BUILD_ID: String = "BATTLE01_WALKING_SKELETON_V1"

@onready var status_label: Label = $HUD/Status

func _ready() -> void:
	status_label.text = "FRONTLINE / BATTLE01\n%s\nGodot 4.7.1 baseline" % BUILD_ID
	print("FRONTLINE_BOOT_OK build=%s" % BUILD_ID)
