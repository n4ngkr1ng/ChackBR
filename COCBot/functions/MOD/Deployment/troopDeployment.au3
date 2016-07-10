; #FUNCTION# ====================================================================================================================
; Name ..........: troopDeployment
; Description ...: Contains functions for various troop deployments
; Syntax ........:
; Parameters ....:
; Return values .: None
; Author ........: LunaEclipse(May, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; Randomize a drop point based on which side its on
Func calculateRandomDropPoint($dropPoint, $randomX = 0, $randomY = 0)
	Local $aResult[2] = [$dropPoint[0], $dropPoint[1]]

	Switch calculateSideFromXY($dropPoint[0], $dropPoint[1])
		Case $sideBottomRight
			$aResult[0] = $dropPoint[0] + Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] + Random(0, Abs($randomY), 1)
		Case $sideTopLeft
			$aResult[0] = $dropPoint[0] - Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] - Random(0, Abs($randomY), 1)
		Case $sideBottomLeft
			$aResult[0] = $dropPoint[0] - Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] + Random(0, Abs($randomY), 1)
		Case $sideTopRight
			$aResult[0] = $dropPoint[0] + Random(0, Abs($randomX), 1)
			$aResult[1] = $dropPoint[1] - Random(0, Abs($randomY), 1)
		Case Else
	EndSwitch

	If $debugSetLog = 1 Then SetLog("Coordinate (x,y): " & $aResult[0] & "," & $aResult[1])
	Return $aResult
EndFunc   ;==>calculateRandomDropPoint

; Convert X,Y coords to a point array
Func convertToPoint($x = 0, $y = 0)
	Local $aResult[2] = [0, 0]

	$aResult[0] = $x
	$aResult[1] = $y

	Return $aResult
EndFunc   ;==>convertToPoint

; Adds a new drop vector to the list of already existing vectors
Func addVector(ByRef $vectorArray, $waveNumber, $sideNumber, $startPoint, $endPoint, $dropPoints)
	Local $aDropPoints[$dropPoints][2]

	Local $m = ($endPoint[1] - $startPoint[1]) / ($endPoint[0] - $startPoint[0])
	Local $c = $startPoint[1] - ($m * $startPoint[0])
	Local $stepX = ($endPoint[0] - $startPoint[0]) / ($dropPoints - 1)

	$aDropPoints[0][0] = $startPoint[0]
	$aDropPoints[0][1] = $startPoint[1]

	For $i = 1 to $dropPoints - 2
		$aDropPoints[$i][0] = Round($startPoint[0] + ($i * $stepX))
		$aDropPoints[$i][1] = Round(($m * $aDropPoints[$i][0]) + $c)
	Next

	$aDropPoints[$dropPoints - 1][0] = $endPoint[0]
	$aDropPoints[$dropPoints - 1][1] = $endPoint[1]

	$vectorArray[$waveNumber][$sideNumber] = $aDropPoints
EndFunc   ;==>addVector

; Drop the number of spells specified on the specified location, will use clan castle spells if you have it.
Func dropSpell($x, $y, $spell = -1, $number = 1) ; Drop Spell
	If $spell = -1 Then Return False

	Local $result = False
	Local $aDeployButtonPositions = getUnitLocationArray()
	Local $barPosition = $aDeployButtonPositions[$spell]
	Local $barCCSpell = $aDeployButtonPositions[$eCCSpell]
	Local $spellCount = unitCount($spell)
	Local $ccSpellCount = unitCount($eCCSpell)
	Local $totalSpells = $spellCount + $ccSpellCount

	If $totalSpells < $number Then
		SetLog("Only " & $totalSpells & " " & getTranslatedTroopName($spell) & " available.  Waiting for " & $number & ".")
		Return $result
	EndIf

	; Check to see if we have a spell in the CC and it hasn't be used
	If $barCCSpell <> -1 And getCCSpellType() = $spell And $totalSpells >= $number Then
		If _SleepAttack(100) Then Return

		If _SleepAttack($iDelayLaunchTroop21) Then Return
		SelectDropTroop($barCCSpell) ; Select Clan Castle Spell
		SetLog("Dropping " & getTranslatedTroopName($spell) & " in the Clan Castle" & " on button " & ($barCCSpell + 1) & " at " & $x & "," & $y, $COLOR_BLUE)
		AttackClick($x, $y, $ccSpellCount, 100, 0)
		$number -= $ccSpellCount

		If $barPosition <> -1 And $number > 0 And $spellCount >= $number Then ; Need to use standard spells as well as clan castle spell.
			If _SleepAttack(100) Then Return
			If $debugSetlog = 1 Then SetLog("Dropping " & getTranslatedTroopName($spell) & " in slot " & $barPosition, $COLOR_BLUE)

			If _SleepAttack($iDelayLaunchTroop21) Then Return
			SelectDropTroop($barPosition) ; Select Spell
			If _SleepAttack($iDelayLaunchTroop23) Then Return

			SetLog("Dropping " & $number & " " & getTranslatedTroopName($spell) & " on button " & ($barPosition + 1) & " at " & $x & "," & $y, $COLOR_BLUE)
			AttackClick($x, $y, $number, 100, 0)
		EndIf

		$result = True
	ElseIf $barPosition <> -1 And $spellCount >= $number Then ; Check to see if we have a spell trained
		If _SleepAttack(100) Then Return

		SelectDropTroop($barPosition) ; Select Spell
		SetLog("Dropping " & $number & " " & getTranslatedTroopName($spell) & " on button " & ($barPosition + 1) & " at " & $x & "," & $y, $COLOR_BLUE)
		AttackClick($x, $y, $number, 100, 0)

		$result = True
	EndIf

	Return $result
EndFunc   ;==>dropSpell

; Drop the number of units specified on the specified location, even allows for random variation if specified.
Func dropUnit($x, $y, $unit = -1, $number = 1, $randomX = 0, $randomY = 0) ; Drop Unit
	If $unit = -1 Then Return False

	Local $result = False
	Local $barPosition = unitLocation($unit)
	Local $unitCount = unitCount($unit)
	Local $currentDropPoint[2] = [$x, $y]
	Local $dropPoint

	If $barPosition <> -1 And $unitCount >= $number Then ; Check to see if we have any units to drop
		If _SleepAttack(100) Then Return
		If $unitCount < $number Then $number = $unitCount

		If _SleepAttack($iDelayLaunchTroop21) Then Return
		SelectDropTroop($barPosition) ; Select Troop
		If _SleepAttack($iDelayLaunchTroop23) Then Return

		For $i = 1 to $number
			$dropPoint = calculateRandomDropPoint($currentDropPoint, $randomX, $randomY)
			AttackClick($dropPoint[0], $dropPoint[1], 1, SetSleep(0), 0)
		Next

		$result = True
	EndIf

	Return $result
EndFunc   ;==>dropUnit

; Drop the troops from a single point on a single side
Func sideSingle($dropSide, $dropAmount, $useDelay = False)
	Local $delay = ($useDelay = True) ? SetSleep(0): 0

	AttackClick($dropSide[2][0], $dropSide[2][1], $dropAmount, $delay, 0)
EndFunc   ;==>sideSingle

; Drop the troops from two points on a single side
Func sideDouble($dropSide, $dropAmount, $useDelay = False)
	Local $delay = ($useDelay = True) ? SetSleep(0): 0
	Local $half = Ceiling($dropAmount / 2)

	AttackClick($dropSide[1][0], $dropSide[1][1], $half, 0, 0)
	AttackClick($dropSide[3][0], $dropSide[3][1], $dropAmount - $half, $delay, 0)
EndFunc   ;==>sideDouble

; Drop the troops from a single point on all sides at once
Func multiSingle($totalDrop, $useDelay = False)
	Local $dropAmount = Ceiling($totalDrop / 4)

	; Progressively adjust the drop amount
	sideSingle($TopLeft, $dropAmount)
	$totalDrop -= $dropAmount
	$dropAmount = Ceiling($totalDrop / 3)

	; Progressively adjust the drop amount
	sideSingle($TopRight, $dropAmount)
	$totalDrop -= $dropAmount
	$dropAmount = Ceiling($totalDrop / 2)

	; Progressively adjust the drop amount
	sideSingle($BottomRight, $dropAmount)
	$totalDrop -= $dropAmount

	; Drop whatever is left
	sideSingle($BottomLeft, $totalDrop, True)
EndFunc   ;==>multiSingle

; Drop the troops from two points on all sides at once
Func multiDouble($totalDrop, $useDelay = False)
	Local $dropAmount = Ceiling($totalDrop / 4)

	; Progressively adjust the drop amount
	sideDouble($TopLeft, $dropAmount)
	$totalDrop -= $dropAmount
	$dropAmount = Ceiling($totalDrop / 3)

	; Progressively adjust the drop amount
	sideDouble($TopRight, $dropAmount)
	$totalDrop -= $dropAmount
	$dropAmount = Ceiling($totalDrop / 2)

	; Progressively adjust the drop amount
	sideDouble($BottomRight, $dropAmount)
	$totalDrop -= $dropAmount

	; Drop whatever is left
	sideDouble($BottomLeft, $totalDrop, True)
EndFunc   ;==>multiDouble

; Drop the troops in a standard drop along a vector
Func standardSideDrop($dropVectors, $waveNumber, $sideIndex, $currentSlot, $troopsPerSlot, $useDelay = False)
	Local $delay = ($useDelay = True) ? SetSleep(0): 0
	Local $dropPoints

	$dropPoints = $dropVectors[$waveNumber][$sideIndex]
	If $currentSlot < UBound($dropPoints) Then AttackClick($dropPoints[$currentSlot][0], $dropPoints[$currentSlot][1], $troopsPerSlot, 0, 0)
EndFunc   ;==>standardSideDrop

; Drop the troops in a standard drop from two points along vectors at once
Func standardSideTwoFingerDrop($dropVectors, $waveNumber, $sideIndex, $currentSlot, $troopsPerSlot, $useDelay = False)
	standardSideDrop($dropVectors, $waveNumber, $sideIndex, $currentSlot, $troopsPerSlot)
	standardSideDrop($dropVectors, $waveNumber, $sideIndex + 1, $currentSlot + 1, $troopsPerSlot, $useDelay)
EndFunc   ;==>twoFingerStandardSideDrop
