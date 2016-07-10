;
; #FUNCTION# ====================================================================================================================
; Name ..........: WerFaultClose
; Description ...: Closes a WerFault message for given programm
; Syntax ........: WerFaultClose($programFile)
; Parameters ....: Full path or just program.exe of WerFault message to close
; Return values .: Number of windows closed
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkMainscreen, isProblemAffect
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func WerFaultClose($programFile, $tryCount = 0)

	Local $WinTitleMatchMode = Opt("WinTitleMatchMode", -3) ; Window Title exact match mode (case insensitive)
	Local $title = $programFile

	Local $iLastBS = StringInStr($title, "\", 0, -1)
	If $iLastBS > 0 Then $title = StringMid($title, $iLastBS + 1)

	Local $aList = WinList($title)
	Local $closed = 0
	Local $i

	SetDebugLog("Found " & $aList[0][0] & " WerFault Windows with title '" & $title & "'")

	For $i = 1 To $aList[0][0]

		Local $HWnD = $aList[$i][1]
		Local $pid = WinGetProcess($HWnD)

		Local $process = ProcessGetWmiProcess($pid)
		If IsObj($process) Then
			Local $werfault = $process.ExecutablePath
			$iLastBS = StringInStr($werfault, "\", 0, -1)
			$werfault = StringMid($werfault, $iLastBS + 1)

			If $werfault = "WerFault.exe" Then
				SetDebugLog("Found WerFault Process " & $pid)
				If WinClose($HWnD) Then
					SetDebugLog("Closed " & $werfault & " Window " & $HWnD)
					$closed += 1
				Else
					If WinKill($HWnD) Then
						SetDebugLog("Killed " & $werfault & " Window " & $HWnD)
						$closed += 1
					Else
						SetDebugLog("Cannot close " & $werfault & " Window " & $HWnD, $COLOR_RED)
					EndIf
				EndIf
			Else
				SetDebugLog("Process " & $pid & " is not WerFault, " & $process.CommandLine, $COLOR_RED)
			EndIf
		ELse
			SetDebugLog("Wmi Object for process " & $pid & " not found")
		EndIF

	Next


	Opt("WinTitleMatchMode", $WinTitleMatchMode)

	If $closed > 0 And $tryCount < 10 Then

		If _Sleep(1000) = False Then

			; recursive call, as more windows might popup
			$closed += WerFaultClose($programFile, $tryCount + 1)

		EndIF

	EndIf

	Return $closed

EndFunc   ;==>SendAdbCommand
