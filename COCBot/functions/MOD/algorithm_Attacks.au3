; #FUNCTION# ====================================================================================================================
; Name ..........: algorith_AllTroops
; Description ...: This file contens all functions to attack algorithm will all Troops , using Barbarians, Archers, Goblins, Giants and Wallbreakers as they are available
; Syntax ........: algorithm_AllTroops()
; Parameters ....: None
; Return values .: None
; Author ........: LunaEclipse (January, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $PixelMine[0]
Global $PixelElixir[0]
Global $PixelDarkElixir[0]
Global $PixelNearCollector[0]

; Wrapper function to support CSV so no modifications need to be made to CSV
Func Luna_SetSlotSpecialTroops()
	; Just call the new getHeroes() function
	getHeroes()
EndFunc

Func Luna_CloseBattle($overrideStarCheck = False)
	If Not $overrideStarCheck Then
		For $i = 1 To 30
			If _ColorCheck(_GetPixelColor($aWonOneStar[0], $aWonOneStar[1], True), Hex($aWonOneStar[2], 6), $aWonOneStar[3]) = True Then ExitLoop ; exit if not 'no star'
			If _SleepAttack($iDelayalgorithm_AllTroops2) Then Return
		Next
	EndIf
	If IsAttackPage() Then ClickP($aSurrenderButton, 1, 0, "#0030") ; Click Surrender
	If _SleepAttack($iDelayalgorithm_AllTroops3) Then Return

	If IsEndBattlePage() Then
		ClickP($aConfirmSurrender, 1, 0, "#0031") ; Click Confirm
		If _SleepAttack($iDelayalgorithm_AllTroops1) Then Return
	EndIf
EndFunc   ;==>CloseBattle

Func getHeroes() ; Get information about your heroes
	Local $aDeployButtonPositions = getUnitLocationArray()

	$King = $aDeployButtonPositions[$eKing]
	$Queen = $aDeployButtonPositions[$eQueen]
	$Warden = $aDeployButtonPositions[$eWarden]
	$CC = $aDeployButtonPositions[$eCastle]

	If $debugSetlog = 1 Then
		SetLog("Use king  SLOT n° " & $King, $COLOR_PURPLE)
		SetLog("Use queen SLOT n° " & $Queen, $COLOR_PURPLE)
		SetLog("Use Warden SLOT n° " & $Warden, $COLOR_PURPLE)
		SetLog("Use CC SLOT n° " & $CC, $COLOR_PURPLE)
	EndIf
EndFunc   ;==>getHeroes

Func useHeroesAbility() ; Use the heroes abilities if appropriate
	;Activate KQ's power
	If ($checkKPower Or $checkQPower) And $iActivateKQCondition = "Manual" Then
		SetLog("Waiting " & $delayActivateKQ / 1000 & " seconds before activating Hero abilities", $COLOR_BLUE)

		If _SleepAttack($delayActivateKQ) Then Return

		If $checkKPower Then
			SetLog("Activating King's power", $COLOR_BLUE)

			SelectDropTroop($King)
			$checkKPower = False
		EndIf

		If $checkQPower Then
			SetLog("Activating Queen's power", $COLOR_BLUE)

			SelectDropTroop($Queen)
			$checkQPower = False
		EndIf
	EndIf
EndFunc   ;==>useHeroesAbility

Func useTownHallSnipe() ; End battle after a town hall snipe
	SwitchAttackTHType()

	If $zoomedin = True Then
		ZoomOut()
		$zoomedin = False
		$zCount = 0
		$sCount = 0
	EndIf

	If ($THusedKing = 1 Or $THusedQueen = 1) And ($ichkSmartZapSaveHeroes = 1 Or $ichkSmartZap = 0) Then
		SetLog("King and/or Queen dropped, close attack")
		If $ichkSmartZap = 1 Then SetLog("Skipping SmartZap to protect your royals!", $COLOR_FUCHSIA)
	ElseIf IsAttackPage() And Not SmartZap() And $THusedKing = 0 And $THusedQueen = 0 Then
		Setlog("Wait few sec before close attack")
		If _SleepAttack(Random(2, 5, 1) * 1000) Then Return ; wait 2-5 second before exit if king and queen are not dropped
	EndIf

	Luna_CloseBattle()
EndFunc   ;==>useTownHallSnipe

Func useSmartDeploy() ; Gets infomation about the red area for Smart Deploy
	Local $hTimer = TimerInit()

	_CaptureRegion2()
	_GetRedArea()

	If ($iChkSmartAttack[$iMatchMode][0] = 1 Or $iChkSmartAttack[$iMatchMode][1] = 1 Or $iChkSmartAttack[$iMatchMode][2] = 1) And Not ($iMatchMode = $DB And $iChkDeploySettings[$DB] = $eSmartSave) Then
		SetLog("Calculating Smart Attack Strategy", $COLOR_BLUE)
		SetLog("Locating Mines, Collectors & Drills", $COLOR_BLUE)

		ReDim $PixelMine[0]
		ReDim $PixelElixir[0]
		ReDim $PixelDarkElixir[0]
		ReDim $PixelNearCollector[0]

		$hTimer = TimerInit()

		; If drop troop near gold mine
		If ($iChkSmartAttack[$iMatchMode][0] = 1) Then
			$PixelMine = GetLocationMine()
			If (IsArray($PixelMine)) Then
				_ArrayAdd($PixelNearCollector, $PixelMine)
			EndIf
		EndIf

		; If drop troop near elixir collector
		If ($iChkSmartAttack[$iMatchMode][1] = 1) Then
			$PixelElixir = GetLocationElixir()
			If (IsArray($PixelElixir)) Then
				_ArrayAdd($PixelNearCollector, $PixelElixir)
			EndIf
		EndIf

		; If drop troop near dark elixir drill
		If ($iChkSmartAttack[$iMatchMode][2] = 1) Then
			$PixelDarkElixir = GetLocationDarkElixir()
			If (IsArray($PixelDarkElixir)) Then
				_ArrayAdd($PixelNearCollector, $PixelDarkElixir)
			EndIf
		EndIf

		SetLog("Located  (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds) :")
		SetLog("[" & UBound($PixelMine) & "] Gold Mines")
		SetLog("[" & UBound($PixelElixir) & "] Elixir Collectors")
		SetLog("[" & UBound($PixelDarkElixir) & "] Dark Elixir Drill/s")

		$iNbrOfDetectedMines[$iMatchMode] += UBound($PixelMine)
		$iNbrOfDetectedCollectors[$iMatchMode] += UBound($PixelElixir)
		$iNbrOfDetectedDrills[$iMatchMode] += UBound($PixelDarkElixir)

		UpdateStats()
	EndIf
EndFunc   ;==>useSmartDeploy

Func getNumberOfSides() ; Returns the number of sides to attack from
	Local $nbSides = 0

	Switch $iChkDeploySettings[$iMatchMode]
		Case $eOneSide
			SetLog("Attacking on a single side.", $COLOR_BLUE)
			$nbSides = 1
		Case $eTwoSides
			SetLog("Attacking on two sides.", $COLOR_BLUE)
			$nbSides = 2
		Case $eThreeSides
			SetLog("Attacking on three sides.", $COLOR_BLUE)
			$nbSides = 3
		Case $eAllSides
			SetLog("Attacking on all sides.", $COLOR_BLUE)
			$nbSides = 4
	    Case $eSmartSave
			$nbSides = 4
		Case $eMultiFinger
			$nbSides = 4
		Case $eCustomDeploy
			$nbSides = 1
	EndSwitch

	Return $nbSides
EndFunc   ;==>getNumberOfSides

Func getDeploymentInfo($nbSides, $overrideMode = -1) ; Returns the Deployment array for LaunchTroops
	If ($iMatchMode = $LB And $iChkDeploySettings[$LB] = $eCustomDeploy And $overrideMode = -1) Or ($iMatchMode = $LB And $overrideMode = $eCustomDeploy) Then ; Customized side wave deployment for Custom Deploy
        Local $listInfoDeploy = deployUISettingsToArray($nbSides)
		If $debugSetlog = 1 Then SetLog("List Deploy for Customized Side attack", $COLOR_PURPLE)
    ElseIf ($iMatchMode = $DB And $iChkDeploySettings[$DB] = $eSmartSave And $overrideMode = -1) Or ($iMatchMode = $DB And $overrideMode = $eSmartSave) Then ; Save Troops For Collectors Style
	    Local $listInfoDeploy = deployArraySetSides($DEFAULT_SAVE_TROOPS_DEPLOY, $nbSides)
        If $debugSetlog = 1 Then SetLog("List Deploy for Save Troops attacks", $COLOR_PURPLE)
	ElseIf ($iMatchMode = $DB And $iChkDeploySettings[$iMatchMode] = $eMultiFinger And $overrideMode = -1) Or ($iMatchMode = $DB And $overrideMode = $eMultiFinger) Then ; Multi Finger deployment
		Local $listInfoDeploy = deployArraySetSides($DEFAULT_FOUR_FINGER_DEPLOY, $nbSides)
		If $debugSetlog = 1 Then SetLog("List Deploy for Four Finger attack", $COLOR_PURPLE)
	Else
		Local $listInfoDeploy = deployArraySetSides($DEFAULT_ORIGINAL_DEPLOY, $nbSides)
		If $debugSetlog = 1 Then SetLog("List Deploy for Standard attacks", $COLOR_PURPLE)
	EndIf

	Return $listInfoDeploy
EndFunc   ;==>getDeploymentInfo

Func dropRemainingTroops($nbSides, $overrideSmartDeploy = -1) ; Uses any left over troops
	SetLog("Dropping left over troops", $COLOR_BLUE)

	For $x = 0 To 1
		PrepareAttack($iMatchMode, True) ; Check remaining quantities
		For $i = $eBarb To $eLava ; Loop through all troop types
			LaunchTroops($i, $nbSides, 0, 1, 0, $overrideSmartDeploy)
			CheckHeroesHealth()

			If _SleepAttack($iDelayalgorithm_AllTroops5) Then Return
		Next
	Next
EndFunc   ;==>dropRemainingTroops

Func deployTroops($nbSides) ; This function is the branch point to new deployments in different files
	Local $listInfoDeploy = getDeploymentInfo($nbSides)

	Switch $iMatchMode
		Case $DB
			Switch $iChkDeploySettings[$DB]
				Case $eSmartSave
					launchSaveTroopsForCollectors($listInfoDeploy, $CC, $King, $Queen, $Warden)
				Case $eMultiFinger
					launchMultiFinger($listInfoDeploy, $CC, $King, $Queen, $Warden)
				Case Else
					launchStandard($listInfoDeploy, $CC, $King, $Queen, $Warden)
			EndSwitch
		Case $LB
			Switch $iChkDeploySettings[$LB]
				Case $eCustomDeploy
					launchCustomDeploy($listInfoDeploy, $CC, $King, $Queen, $Warden)
				Case Else
					launchStandard($listInfoDeploy, $CC, $King, $Queen, $Warden)
			EndSwitch
	EndSwitch
EndFunc   ;==>deployTroops

Func algorithm_AtkTroops() ; Attack Algorithm for all existing troops
	If $debugSetlog = 1 Then Setlog("algorithm_AllTroops", $COLOR_PURPLE)

	getHeroes()
	If _SleepAttack($iDelayalgorithm_AllTroops1) Then Return

    If $iMatchMode = $TS or ($chkATH = 1 And SearchTownHallLoc()) Then
		useTownHallSnipe()

		; Only quit if the attack was a town hall snipe
		; This allows a standard attack to continue after destroying an outside town hall
		If $iMatchMode = $TS Then Return
	EndIf

	Local $nbSides = getNumberOfSides()
	If $nbSides = 0 Then Return ; No sides set, so lets just quit

	If (($iChkRedArea[$iMatchMode]) And $iChkDeploySettings[$iMatchMode] < $eMultiFinger) Or ($iMatchMode = $DB And $iChkDeploySettings[$iMatchMode] = $eSmartSave) Then
		useSmartDeploy()
	EndIf
	If _SleepAttack($iDelayalgorithm_AllTroops2) Then Return

	deployTroops($nbSides)
EndFunc   ;==>algorithm_AllTroops
