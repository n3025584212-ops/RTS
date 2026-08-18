# BATTLE01_RECON_CONTACT_RULES_V1

STATUS=FROZEN_FOR_IMPLEMENTATION
ENGINE=Godot 4.7.1

## Intel states

- UNSEEN: enemy exact location and combat body are hidden.
- CONTACT: enemy presence is detected but exact Formation identity/HP is not exposed.
- CONFIRMED: enemy Formation is identified and may be used as a direct combat target.
- LAST_KNOWN: direct contact is lost; the last observed world position remains as a stale marker.

## Detection rules

- Every BLUE observer uses its FormationDefinition.detection_range.
- Recon has the longest current Battle01 detection range and therefore creates earlier contacts.
- A target inside any living observer's detection radius can progress UNSEEN/LAST_KNOWN -> CONTACT -> CONFIRMED.
- CONTACT requires continuous detection for 0.75 seconds before becoming CONFIRMED.
- Enemy firing forces immediate CONFIRMED exposure for 2.0 seconds.
- Losing all detection after CONTACT or CONFIRMED creates LAST_KNOWN at the last observed position.
- Reacquiring a LAST_KNOWN target returns to CONTACT and requires confirmation again unless firing reveal is active.

## Combat integration

- BLUE direct-fire combat targeting is allowed only while the RED target is CONFIRMED.
- RED does not receive omniscient information from this player-intel tracker; enemy AI knowledge remains a separate future system.
- This V1 intentionally does not implement terrain LOS, smoke occlusion, stealth modifiers, sensor classes, minimap fog rendering, or AI knowledge.
