; #FUNCTION# ====================================================================================================================
; Name ..........: protectionAntiBot
; Description ...: Contains functions to protect against Super Cell Anti-Bot detection
; Syntax ........:
; Parameters ....:
; Return values .: None
; Author ........: LunaEclipse(April, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#include <Date.au3>

Func CloseCOCAndWait($timeRemaining, $forceClose = False)

	Local $tempCloseCoC = 0 
	
	; Random Stay connect on Game or Close the Game while Training
	If ($ichkCloseTraining = 1 and $RandomCloseTraining = 1 and $RandomCloseTraining2 = 1) then Return  
		
	; Randomly choose whether to actually exit COC or do nothing (time out)
	
	; Random Close or Leave 
	If $RandomCoCOpen = 1 then 
		if $debugSetlog = 1 then  Setlog("Random Close or Leave ...", $COLOR_RED)
		$tempCloseCoC = Random(0,1,1)
		if $debugSetlog = 1 then  Setlog("$tempCloseCoC: " & $tempCloseCoC)
	EndIf 
	
	If ($forceClose and $CloseCoCGame = 1) or ($forceClose and $RandomCoCOpen = 1 and $tempCloseCoC = 1 ) Then
		; Force close the bot
		; Find and wait for the confirmation of exit "okay" button
		Local $counter = 0
		While 1
			checkObstacles()
			AndroidBackButton()

			; Wait for window to open
			If _Sleep($iDelayAttackDisable1000) Then Return
			; Confirm okay to exit
			If ClickOkay("ExitCoCokay", True) = True Then ExitLoop

			If $counter > 10 Then
				If $debugImageSave = 1 Then DebugImageSave("CheckAttackDisableFailedButtonCheck_")
				Setlog("Can not find Okay button to exit CoC, Forcefully Closing CoC", $COLOR_RED)

				CloseCoC()
				ExitLoop
			EndIf
			$counter += 1
		WEnd
		; Short wait for CoC to exit
		If _Sleep(1500) Then Return
		; Pushbullet Msg
		PushMsg("TakeBreak")
		; Log off CoC for set time
		WaitnOpenCoC($timeRemaining * 1000, True)
	Else
		; Nothing is needed here for timeout, as WaitnOpenCoC will stop the bot from doing anything so it will timeout naturally
		; Pushbullet Msg
		PushMsg("TakeBreak")
		; Just wait without close the CoC
		WaitnOpenCoC($timeRemaining * 1000, True, False)
	EndIf

EndFunc   ;==>CloseCOCAndWait

Func calculateDailyAttackLimit()
	Local $result = Random(_Min($rangeAttacksStart, $rangeAttacksEnd), _Max($rangeAttacksStart, $rangeAttacksEnd), 1)

	Return $result
EndFunc   ;==>calculateDailyAttackLimit

Func calculateSleepStart()
	; Calculate a random offset for the start time
	Local $sleepOffset = Random(-30, 30, 1)
	; Create the start time string
	Local $dateString = @YEAR & "/" & @MON & "/" & @MDAY & " " & StringFormat("%02i", $sleepStart) & ":00:00"

	; Check if we are past the start hour and need to add one day
	If (@HOUR = $sleepStart - 1 And @MIN >= 30) Or @HOUR >= $sleepStart Then $dateString = _DateAdd("D", 1, $dateString)

	; Add the offset to the start time
	Return _DateAdd("n", $sleepOffset, $dateString)
EndFunc   ;==>calculateSleepStart

Func calculateSleepEnd()
	; Calculate a random offset for the end time
	Local $sleepOffset = Random(-30, 30, 1)
	; Create the end time string
	Local $dateString = @YEAR & "/" & @MON & "/" & @MDAY & " " & StringFormat("%02i", $sleepEnd) & ":00:00"

	; Check if we are past the start hour and need to add one day
	If (@HOUR = $sleepEnd - 1 And @MIN >= 30) Or @HOUR >= $sleepEnd Then $dateString = _DateAdd("D", 1, $dateString)

	; Add the offset to the end time
	Return _DateAdd("n", $sleepOffset, $dateString)
EndFunc   ;==>calculateSleepEnd

Func calculateTimeRemaining($compareTime, $currentTime = _NowCalc())
	; Calculate how many seconds remain until it will stop sleeping
	Local $result = _DateDiff("s", $currentTime, $compareTime)

	; Returns the amount of time until sleeping ends in seconds
	Return $result
EndFunc   ;==>calculateTimeRemaining

Func isTimeAfter($compareTime, $currentTime = _NowCalc())
	; Check to see if the amount of seconds remaining is less than 0
	Local $result = _DateDiff("s", $currentTime, $compareTime) < 0

	Return $result
EndFunc   ;==>isTimeAfter

Func isTimeBefore($compareTime, $currentTime = _NowCalc())
	; Check to see if the amount of seconds remaining is greater than 0
	Local $result = _DateDiff("s", $currentTime, $compareTime) > 0

	Return $result
EndFunc   ;==>isTimeBefore

Func isTimeInRange($startTime, $endTime)
	Local $currentTime = _NowCalc()
	; Calculate if time until start time is less than 0 and time until end time is greater than 0
	Local $result = isTimeAfter($startTime, $currentTime) And isTimeBefore($endTime, $currentTime)

	; Returns whether the current time is within the range
	Return $result
EndFunc   ;==>isTimeInRange

Func checkRemainingTraining()
	Local $AddRandomTIme = Random($minTrainAddition, $maxTrainAddition, 1)
	Local $iMaxTimeSleep = 0
	If $ichkCloseTraining = 0 Then Return
	If $ArmyCapacity > 90 Then
		Setlog( "Skip CCWT, Troops is Over " & $ArmyCapacity & "% Done", $COLOR_BLUE)
		Return
	EndIf
	; Get the time remaining in minutes
	If $iTotalCountSpell = 0 Then
		Local $iRemainingTimeTroops = RemainTrainTime(True, False) ; Not necessary "read" the Spells
	Else
		Local $iRemainingTimeTroops = RemainTrainTime(True, True)
	EndIf
	; Request CC troops
	If $canRequestCC = True Then 
		Setlog( "CCWT: Try Request troops before sleep", $COLOR_BLUE)
		RequestCC()
	EndIf
	; Check if the Remaining time is less than 5 minutes
	If $iRemainingTimeTroops < 5 Then 
		Setlog( "Skip CCWT, Time < 5 Min [ Calculated: " & ( $iRemainingTimeTroops ) & " Min ]", $COLOR_BLUE)
		Return
	Else
		; check for max logout time ( config from user )
		IF $TrainLogoutMaxTime = 1 Then
			$iMaxTimeSleep = Number($TrainLogoutMaxTimeTXT)
			If $iRemainingTimeTroops > $iMaxTimeSleep Then
				Setlog( "Calculated CCWT Time: " & $iRemainingTimeTroops & " Min [Adjusted " & ( $iMaxTimeSleep + $AddRandomTIme ) & " Min]", $COLOR_BLUE)
				$iRemainingTimeTroops = $iMaxTimeSleep
			Endif
		Endif
	Endif
	; Add random additional time from $minTrainAddition minute to $maxTrainAddition minutes
	$iRemainingTimeTroops += $AddRandomTIme
	; Convert remaining time to seconds and close COC and wait for that length of time
	CloseCOCAndWait($iRemainingTimeTroops * 60, True)
EndFunc   ;==>checkRemainingTraining

Func checkSleep()
	Local $result = False

	; Check to see if we have calculated a random daily attack limit
	If $dailyAttackLimit = 0 Then
		If $debugSetLog = 1 Then SetLog("Calculating Daily Attack Limit because there is no limit set!", $COLOR_MAROON)
		$dailyAttackLimit = calculateDailyAttackLimit()
	EndIf
	; Lets reset the daily attacks as we don't know when they were supposed to finish
	If $dailyAttacks > 0 And $nextSleepEnd = -999 Then
		If $debugSetLog = 1 Then SetLog("Resetting Daily Attack Count because there is no time for when it finished!", $COLOR_MAROON)
		$dailyAttacks = 0
	EndIf
	; Calculate the new start time if none is stored
	If $nextSleepStart = -999 Then
		If $debugSetLog = 1 Then SetLog("There is no sleep start time stored, calculating it now...", $COLOR_MAROON)
		$nextSleepStart = calculateSleepStart()
	EndIf
	; Calculate the new end time if none is stored
	If $nextSleepEnd = -999 Then
		If $debugSetLog = 1 Then SetLog("There is no sleep end time stored, calculating it now...", $COLOR_MAROON)
		$nextSleepEnd = calculateSleepEnd()
	EndIf
	; If the end time is before the start time, subtract 1 day
	If isTimeBefore($nextSleepStart, $nextSleepEnd) Then
		$nextSleepStart = _DateAdd("D", -1, $nextSleepStart)
		If $debugSetLog = 1 Then SetLog("Start time adjusted because its after the finish time!", $COLOR_MAROON)
	EndIf

	; Check to see if its withing sleeping times
	If isTimeInRange($nextSleepStart, $nextSleepEnd) Then
		$result = True
	ElseIf isTimeAfter($nextSleepEnd) Then
		If $debugSetLog = 1 Then SetLog("Calculating new sleep times!", $COLOR_MAROON)
		; Calculate the new start and end times because the current end time has been passed
		$nextSleepStart = calculateSleepStart()
		$nextSleepEnd = calculateSleepEnd()

		; Reset the number of attacks for the day
		$dailyAttackLimit = calculateDailyAttackLimit()
		$dailyAttacks = 0
	EndIf

	Return $result
EndFunc   ;==>checkSleep

Func RemainTrainTime($Troops = True, $Spells = True)

	; Lets open the ArmyOverView Window (this function will check if we are on Main Page and wait for the window open returning True or False)
	If openArmyOverview() Then

		Local $aRemainTrainTroopTimer = 0
		Local $aRemainTrainSpellsTimer = 0
		Local $ResultTroopsHour, $ResultTroopsMinutes
		Local $ResultSpellsHour, $ResultTroopsMinutes

		Local $ResultTroops = getRemainTrainTimer(688, 176)
		Local $ResultSpells = getRemainTrainTimer(363, 423)

		If $Troops = True Then
			If StringInStr($ResultTroops, "h") > 1 Then
				$ResultTroopsHour = StringSplit($ResultTroops, "h", $STR_NOCOUNT)
				; $ResultTroopsHour[0] will be the Hour and the $ResultTroopsHour[1] will be the Minutes with the "m" at end
				$ResultTroopsMinutes = StringTrimRight($ResultTroopsHour[1], 1) ; removing the "m"
				$aRemainTrainTroopTimer = (Number($ResultTroopsHour[0]) * 60) + Number($ResultTroopsMinutes)
			Else
				$aRemainTrainTroopTimer = Number(StringTrimRight($ResultTroops, 1)) ; removing the "m"
			EndIf
		EndIf

		If $Spells = True Then
			If StringInStr($ResultSpells, "h") > 1 Then
				$ResultSpellsHour = StringSplit($ResultSpells, "h", $STR_NOCOUNT)
				; $ResultSpellsHour[0] will be the Hour and the $ResultSpellsHour[1] will be the Minutes with the "m" at end
				$ResultTroopsMinutes = StringTrimRight($ResultSpellsHour[1], 1) ; removing the "m"
				$aRemainTrainSpellsTimer = (Number($ResultSpellsHour[0]) * 60) + Number($ResultTroopsMinutes)
			Else
				$aRemainTrainSpellsTimer = Number(StringTrimRight($ResultSpells, 1)) ; removing the "m"
			EndIf
		EndIf

		; Verify the higest value to return in minutes
		If $aRemainTrainTroopTimer > $aRemainTrainSpellsTimer Then
			Return $aRemainTrainTroopTimer
		Else
			Return $aRemainTrainSpellsTimer
		EndIf
	Else
		SetLog("Can not read the remaining Troops&Spells time!", $COLOR_RED)
		Return 0
	EndIf

EndFunc   ;==>RemainTrainTime
