class_name BattleEnemyAIPostCaptureReinforcementController
extends BattleEnemyAIPreReserveProgressionController

# Narrow post-first-Central timing correction. The already-active starting RED
# Armor keeps its immediate post-capture counterattack permission from the
# pre-reserve progression contract; only the dormant reinforcement pair is held
# for a deterministic full response window.

const POST_CAPTURE_REINFORCEMENT_DELAY: float = 15.0
const POST_CAPTURE_DELAY_EPSILON: float = 0.0001

var _post_capture_reinforcement_delay_active: bool = false
var _post_capture_reinforcement_delay_started_at: float = -1.0
var _reinforcement_activation_count: int = 0

func _process(delta: float) -> void:
	# Parent processing keeps RED intel, combat decisions, logistics and the
	# historical 150s fallback. Our _activate_reinforcements override below blocks
	# only the fixed-time call while a post-capture delay is already authoritative.
	super._process(delta)
	if not _initialized or _legacy_ci_disabled or _ci_smoke or _match_finished:
		return
	_update_post_capture_reinforcement_delay()

func _on_objective_state_changed(state: String, _progress: float) -> void:
	# BattleObjective emits state_changed("CAPTURED") before capture_completed.
	# The legacy base handler activated dormant reinforcements in that earlier
	# signal, which made a capture_completed-based delay impossible. Preserve the
	# objective-loss fact and immediate AI reassessment, but activation authority
	# is now the first PLAYER capture_completed event below.
	if state == "CAPTURED":
		_objective_lost = true
	_decision_accumulator = DECISION_INTERVAL

func _on_objective_captured() -> void:
	# Legacy `captured` is emitted after capture_completed when enabled. Never let
	# that compatibility signal create a second/same-frame reinforcement path.
	_objective_lost = true
	_decision_accumulator = DECISION_INTERVAL

func _on_central_capture_completed_for_progression(new_owner: String, previous_owner: String) -> void:
	var was_first_player_capture_complete: bool = _first_player_central_capture_completed
	super._on_central_capture_completed_for_progression(new_owner, previous_owner)
	if was_first_player_capture_complete or new_owner != BattleObjective.OWNER_PLAYER:
		return

	# If the 150s fallback already formally activated the pair before Central was
	# captured, Case A keeps them active and starts no second timer/activation.
	if _reinforcements_active:
		print("FRONTLINE_AI_POST_CAPTURE_REINFORCEMENT_DELAY_SKIPPED reason=already_active elapsed=%.2f" % _elapsed)
		return

	# Case B: first PLAYER Central capture while still dormant always owns a full
	# 15s response window. Crossing battle elapsed 150 during this window cannot
	# pre-empt it.
	_post_capture_reinforcement_delay_active = true
	_post_capture_reinforcement_delay_started_at = _elapsed
	print("FRONTLINE_AI_POST_CAPTURE_REINFORCEMENT_DELAY_STARTED delay=%.1f start=%.2f" % [POST_CAPTURE_REINFORCEMENT_DELAY, _post_capture_reinforcement_delay_started_at])

func _activate_reinforcements(reason: String) -> void:
	if _reinforcements_active:
		return

	# Once Case B starts, the old 150s fallback no longer has authority until the
	# full response window ends. No other normal activation reason is delayed.
	if reason == "fixed_time" and _post_capture_reinforcement_delay_active:
		print("FRONTLINE_AI_REINFORCEMENT_FIXED_TIME_DEFERRED elapsed=%.2f delay_remaining=%.2f" % [_elapsed, get_post_capture_reinforcement_delay_remaining_for_test()])
		return

	var was_active: bool = _reinforcements_active
	super._activate_reinforcements(reason)
	if not was_active and _reinforcements_active:
		_reinforcement_activation_count += 1
		print("FRONTLINE_AI_REINFORCEMENT_ACTIVATION_COUNT count=%d reason=%s" % [_reinforcement_activation_count, reason])

func _update_post_capture_reinforcement_delay() -> void:
	if not _post_capture_reinforcement_delay_active or _reinforcements_active:
		return
	if _post_capture_reinforcement_delay_started_at < 0.0:
		return
	var elapsed_since_capture: float = _elapsed - _post_capture_reinforcement_delay_started_at
	if elapsed_since_capture + POST_CAPTURE_DELAY_EPSILON < POST_CAPTURE_REINFORCEMENT_DELAY:
		return

	_post_capture_reinforcement_delay_active = false
	print("FRONTLINE_AI_POST_CAPTURE_REINFORCEMENT_DELAY_COMPLETE elapsed=%.2f" % _elapsed)
	_activate_reinforcements("post_capture_delay_complete")

func is_post_capture_reinforcement_delay_active_for_test() -> bool:
	return _post_capture_reinforcement_delay_active

func get_post_capture_reinforcement_delay_started_at_for_test() -> float:
	return _post_capture_reinforcement_delay_started_at

func get_post_capture_reinforcement_delay_remaining_for_test() -> float:
	if not _post_capture_reinforcement_delay_active or _post_capture_reinforcement_delay_started_at < 0.0:
		return 0.0
	return maxf(0.0, POST_CAPTURE_REINFORCEMENT_DELAY - (_elapsed - _post_capture_reinforcement_delay_started_at))

func get_reinforcement_activation_count_for_test() -> int:
	return _reinforcement_activation_count
