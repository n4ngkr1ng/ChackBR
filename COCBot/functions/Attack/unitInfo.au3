; #FUNCTION# ====================================================================================================================
; Name ..........: unitInfo.au3
; Description ...: Gets various information about units such as the number, location on the bar, clan castle spell type etc...
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........: @LunaEclipse
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getDeploymentFileTroopName($kind)
    ; Troop string as an array
	; This order must exactly match the troops enum from MBR Global Variables.au3
	Local $result[$eDeployUnused + 1] = [	"$eBarb", _
						"$eArch", _
						"$eGiant", _
						"$eGobl", _
						"$eWall", _
						"$eBall", _
						"$eWiza", _
						"$eHeal", _
						"$eDrag", _
						"$ePekk", _
						"$eMini", _
						"$eHogs", _
						"$eValk", _
						"$eGole", _
						"$eWitc", _
						"$eLava", _
						"$eBowl", _
						"$eKing", _
						"$eQueen", _
						"$eWarden", _
						"$eCastle", _
						"$eLSpell", _
						"$eHSpell", _
						"$eRSpell", _
						"$eJSpell", _
						"$eFSpell", _
						"$ePSpell", _
						"$eESpell", _
						"$eHaSpell", _
						"$eDeployWait", _
						"$eDeployUnused"]

	Return $result[$kind]
EndFunc   ;==>getDeploymentFileTroopName

Func getTranslatedTroopName($kind)
	;Troop string as an array
	;This order must exactly match the troops enum from MBR Global Variables.au3
	Local $result[$eHaSpell + 1] = [("Barbarians"), _
					("Archers"), _
					("Giants"), _
					("Goblins"), _
					("Wall Breakers"), _
					("Balloons"), _
					("Wizards"), _
					("Healers"), _
					("Dragons"), _
					("Pekkas"), _
					("Minions"), _
					("Hog Riders"), _
					("Valkyries"), _
					("Golems"), _
					("Witches"), _
					("Lava Hounds"), _
					("Bowlers"), _
					("King"), _
					("Queen"), _
					("Grand Warden"), _
					("Clan Castle"), _
					("Lightning Spell"), _
					("Healing Spell"), _
					("Rage Spell"), _
					("Jump Spell"), _
					("Freeze Spell"), _
					("Poison Spell"), _
					("Earthquake Spell"), _
					("Haste Spell")]

	Return $result[$kind]
EndFunc   ;==>getTranslatedTroopName

Func getTranslatedTroopName_Bkp($kind)
	;Troop string as an array
	;This order must exactly match the troops enum from MBR Global Variables.au3
	Local $result[$eHaSpell + 1] = [GetTranslated(604,  1, "Barbarians"), _
					GetTranslated(604,  2, "Archers"), _
					GetTranslated(604,  3, "Giants"), _
					GetTranslated(604,  4, "Goblins"), _
					GetTranslated(604,  5, "Wall Breakers"), _
					GetTranslated(604,  7, "Balloons"), _
					GetTranslated(604,  8, "Wizards"), _
					GetTranslated(604,  9, "Healers"), _
					GetTranslated(604, 10, "Dragons"), _
					GetTranslated(604, 11, "Pekkas"), _
					GetTranslated(604, 13, "Minions"), _
					GetTranslated(604, 14, "Hog Riders"), _
					GetTranslated(604, 15, "Valkyries"), _
					GetTranslated(604, 16, "Golems"), _
					GetTranslated(604, 17, "Witches"), _
					GetTranslated(604, 18, "Lava Hounds"), _
					GetTranslated(604, 19, "Bowlers"), _
					GetTranslated(610, 65, "King"), _
					GetTranslated(610, 67, "Queen"), _
					GetTranslated(610, 69, "Grand Warden"), _
					GetTranslated(610, 56, "Clan Castle"), _
					GetTranslated(605,  1, "Lightning Spell"), _
					GetTranslated(605,  2, "Healing Spell"), _
					GetTranslated(605,  3, "Rage Spell"), _
					GetTranslated(605,  4, "Jump Spell"), _
					GetTranslated(605,  5, "Freeze Spell"), _
					GetTranslated(605,  6, "Poison Spell"), _
					GetTranslated(605,  7, "Earthquake Spell"), _
					GetTranslated(605,  8, "Haste Spell")]

	Return $result[$kind]
EndFunc   ;==>getTranslatedTroopName_Bkp

Func getTroopNumber($TroopEnumString)
	Local $result
	; Return must be a string because it doesn't work if the function returns numeric 0, because this is the same as Return False
	If StringLeft($TroopEnumString, 1) = "$" Then
		$result = Eval(StringRight($TroopEnumString, StringLen($TroopEnumString) - 1))
	Else
		$result = Eval($TroopEnumString)
	EndIf

	Return String($result)
EndFunc   ;==>getTroopNumber

Func unitLocation($kind) ; Gets the location of the unit type on the bar.
	Local $return = -1
	Local $i = 0

	; This loops through the bar array but allows us to exit as soon as we find our match.
	While $i < UBound($atkTroops)
		; $atkTroops[$i][0] holds the unit ID for that position on the deployment bar.
		If $atkTroops[$i][0] = $kind Then
			$return = $i
			ExitLoop
		EndIf

		$i += 1
	WEnd

	; This returns -1 if not found on the bar, otherwise the bar position number.
	Return $return
EndFunc   ;==>unitLocation

Func getUnitLocationArray() ; Gets the location on the bar for every type of unit.
	Local $result[$eCCSpell + 1] = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]

	; Loop through all the bar and assign it position to the respective unit.
	For $i = 0 To UBound($atkTroops) - 1
		If Number($atkTroops[$i][0]) <> -1 Then
			$result[Number($atkTroops[$i][0])] = $i
			If $debugSetlog = 1 Then 
				If Number($atkTroops[$i][0]) = $eCCSpell Then
					SetLog("Clan Castle Spell (" & getTranslatedTroopName($CCSpellType) & ") on button location number " & $i)
				Else
					SetLog(getTranslatedTroopName(Number($atkTroops[$i][0])) & " on button location number " & $i)
				EndIf
			EndIf
		EndIf
	Next

	; Return the positions as an array.
	Return $result
EndFunc   ;==>getUnitLocationArray

Func getCCSpellType() ; Returns the type of spell currently in the clan castle.
	Local $barLocation = unitLocation($eCCSpell)
	Local $unitText = getTranslatedTroopName($CCSpellType)

	; $barLocation is -1 if there is no entry on the deployment bar allocated as a clan castle spell.
	If $barLocation <> -1 Then
		If $debugSetlog = 1 Then SetLog($unitText & " found in the clan castle", $COLOR_PURPLE)
	Else
		If $debugSetlog = 1 Then SetLog("No clan castle spell found", $COLOR_PURPLE)
	EndIf

	return $CCSpellType
EndFunc   ;==>getCCSpellType

Func unitCount($kind) ; Gets a count of the number of units of the type specified.
	Local $numUnits = 0
	Local $unitText = getTranslatedTroopName($kind)
	Local $barLocation = unitLocation($kind)

	; $barLocation is -1 if the unit/spell type is not found on the deployment bar.
	If $barLocation <> -1 Then
		$numUnits = $atkTroops[unitLocation($kind)][1]
		If $debugSetlog = 1 Then SetLog($numUnits & " " & $unitText & " in slot " & $barLocation, $COLOR_PURPLE)
	EndIf

	Return $numUnits
EndFunc   ;==>unitCount

Func unitCountArray() ; Gets a count of the number of units for every type of unit.
	Local $result[$eCCSpell + 1] = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]

	; Loop through all the bar and assign its unit count to the respective unit.
	For $i = 0 To UBound($atkTroops) - 1
		If Number($atkTroops[$i][1]) > 0 Then
			$result[Number($atkTroops[$i][0])] = $atkTroops[$i][1]
			If $debugSetlog = 1 And Number($atkTroops[$i][0]) < $eCCSpell _ 
				And $atkTroops[$i][1] <> "" And Number($atkTroops[$i][1]) > 0 Then
					SetLog("Total of " & $result[Number($atkTroops[$i][1])] & " " & getTranslatedTroopName(Number($atkTroops[$i][0])) & " remaining.")			
			EndIf
		EndIf
	Next

	; Return the positions as an array.
	Return $result
EndFunc   ;==>unitCountArray
