class_name BattlePreBattleStagingRuntimeController
extends BattlePreBattleStagingController

func _ready() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--battle01-ci-"):
			_staging_active = false
			_battle_elapsed = 0.0
			print("FRONTLINE_PRE_BATTLE_STAGING_LEGACY_CI_BYPASS arg=%s" % argument)
			return
	super._ready()
