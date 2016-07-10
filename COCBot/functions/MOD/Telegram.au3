; #FUNCTION# ====================================================================================================================
; Name ..........: Telegram
; Description ...: This function will report to your mobile phone your values and last attack
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: surbiks (2016-06)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
;Telegram[Surbiks]
#include <Array.au3>
#include <String.au3>

;------------------------ private functions ---------------------------------
Func _RemoteControlTelegram()

	Setlog("start processing telegram message.",$COLOR_GREEN)

	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$oHTTP.Open("Get", $TelegramUrl & $TelegramToken & "/getupdates" , False)
	$oHTTP.Send()
	$TelegramResult = $oHTTP.ResponseText

    Local $haveMessage = StringRegExp(StringUpper($TelegramResult), '"TEXT":"')
	If $haveMessage = 0 Then
		;Setlog("noting telegram message[1]",$COLOR_GREEN)
		Return
	EndIf

	Local $json = _JSONDecode($TelegramResult)
	Local $msg_count = UBound(_JSONGet($json,'result'))
	If $msg_count = 0 Then
		;Setlog("noting telegram message[2]",$COLOR_GREEN)
		Return
	EndIf

	Local $messages[$msg_count]
	Local $chat_ids[$msg_count]
	Local $update_ids[$msg_count]

	For $i = 0 To $msg_count - 1 Step 1
		$messages[$i]   = _JSONGet($json,'result.'&$i&'.message.text')
		$chat_ids[$i]   = _JSONGet($json,'result.'&$i&'.message.chat.id')
		$update_ids[$i]   = _JSONGet($json,'result.'&$i&'.update_id')
	Next

	Local $size = UBound($messages)

	If $size = 0 Then
		;Setlog("no message for process",$COLOR_GREEN)
		Return
	EndIf

	;SetLog(_ArrayToString($messages))
	;SetLog(_ArrayToString($chat_ids))
	;SetLog(_ArrayToString($update_ids))

	For $i = 0 To $size - 1 Step 1
		If $TelegramLastRemoteID = $update_ids[$i] Then
			;SetLog("Skipped Index : "&$i)
			ContinueLoop
		EndIf
		;SetLog("Index is : "&$i)
		_SaveChatIDs($chat_ids[$i])
		$TelegramLastRemoteID = $update_ids[$i]
		_UpdateRemoteOffset($TelegramLastRemoteID)
		_ProcessTelegramMessages($update_ids[$i],$chat_ids[$i],$messages[$i])
	Next
EndFunc   ;==>_RemoteControlTelegram

Func _PushTxtMessage($chat_id, $pMessage)
	If $TelegramEnabled = 1 And $pRemoteTelegram = 1 Then
		$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
		$oHTTP.Open("Post", $TelegramUrl & $TelegramToken & "/sendmessage", False)
		$oHTTP.SetRequestHeader("Content-Type", "application/json")
		Local $Date = @YEAR & '/' & @MON & '/' & @MDAY
	    Local $Time = @HOUR & ':' & @MIN
		Local $zaman = '[' & $Date & ' - ' & $Time & ']'
		local $json = '{"text":"' & $pMessage & '\n\n' & $zaman & '", "chat_id":' & $chat_id & '}}'
		$oHTTP.Send($json)
	EndIf
EndFunc   ;==>_PushTxtMessage

Func _PushLogFile($chat_id,$File, $Folder, $FileType, $body)
	If FileExists($sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File) Then
		Local $telegram_url = $TelegramUrl & $TelegramToken & "/sendDocument"
		Local $code = Run($pCurl & " -i -X POST " & $telegram_url & ' -F caption="'& $body &'" -F chat_id="' & $chat_id &' " -F document=@"' & $sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File  & '"', "", @SW_HIDE)
	Else
		;SetLog("Telegram: Unable to send file " & $File, $COLOR_RED)
		_PushTxtMessage($chat_id, $iOrigTelegram & " :\nUnable to Upload File" & "\n" & "Occured an error uploading file to Telegram server.")
	EndIf
EndFunc

Func _PushImgFile($chat_id,$File, $Folder, $FileType, $body)
	If FileExists($sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File) Then
		Local $telegram_url = $TelegramUrl & $TelegramToken & "/sendPhoto"
		Local $code = Run($pCurl & " -i -X POST " & $telegram_url & ' -F caption="'& $body &'" -F chat_id="' & $chat_id &' " -F photo=@"' & $sProfilePath & "\" & $sCurrProfile & '\' & $Folder & '\' & $File  & '"', "", @SW_HIDE)
	Else
		;SetLog("Telegram: Unable to send file " & $File, $COLOR_RED)
		_PushTxtMessage($chat_id, $iOrigTelegram & " :\nUnable to Upload File" & "\n" & "Occured an error uploading file to Telegram server.")
	EndIf
EndFunc

Func _PushImgToAll($File, $Folder, $FileType, $body)
	;SetLog("Before : "&_ArrayToString($TelegramRequestScreenshotIDs))
	Local $sended
	For $i = 0 To UBound($TelegramRequestScreenshotIDs) - 1 Step 1
		If $TelegramRequestScreenshotIDs[$i] = 0 Then
			ContinueLoop
		EndIf
		_PushImgFile($TelegramRequestScreenshotIDs[$i], $File, $Folder, $FileType, $body)
		_ArrayAddCreate($sended,$i)
	Next

	For $i = 0 To UBound($sended) - 1 Step 1
		_ArrayDelete($TelegramRequestScreenshotIDs,$sended[$i])
	Next
	;SetLog("After : "&_ArrayToString($TelegramRequestScreenshotIDs))
EndFunc

Func _PushRImgToAll($File, $Folder, $FileType, $body)
	For $i = 0 To UBound($TelegramChatIDs) - 1 Step 1
		Local $chat_id = $TelegramChatIDs[$i]
		If $TelegramEnabled = 1 And $pRemoteTelegram = 1 Then
			_PushImgFile($chat_id, $File, $Folder, $FileType, $body)
		EndIf
	Next
EndFunc

Func _PushTxtToAll($pMessage)
	For $i = 0 To UBound($TelegramChatIDs) - 1 Step 1
		Local $chat_id = $TelegramChatIDs[$i]
		If $TelegramEnabled = 1 And $pRemoteTelegram = 1 Then
			_PushTxtMessage($chat_id, $pMessage)
		EndIf
	Next
EndFunc

Func _ProcessTelegramMessages($update_id,$chat_id,$message)
	;Setlog("Process : "&$update_id&" => "&$chat_id&" => "&$message,$COLOR_GREEN)
	;Return
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	local $instruction = StringUpper(StringStripWS($message, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))

	Switch $instruction
		Case "/START"
			$oHTTP.Open("Post", $TelegramUrl & $TelegramToken & "/sendmessage", False)
		    $oHTTP.SetRequestHeader("Content-Type", "application/json")
			local $json = '{"text": "Wellcom To Bot Controller.\nUse Keyboard or /Help Command.", "chat_id":'& $chat_id &', "reply_markup": {"keyboard": [["/Stats","/Screenshot","/LastRaidText","/LastRaid"],["/Stop","/Pause","/Restart","/Resume"],["/Help","/Unsubscribe","/Delete","/Log"]],"one_time_keyboard": false,"resize_keyboard": true}}'
			$oHTTP.Send($json)
			SetLog("Telegram: Your request has been received. Bot Started", $COLOR_GREEN)
		Case "/HELP"
			Local $txtHelp = "You can remotely control your bot sending commands following this syntax:\n\n"
			$txtHelp &= "\n" & "/Stats - send Village Statistics."
			$txtHelp &= "\n" & "/CampStatus - send Village current camp status."
			$txtHelp &= "\n" & "/Screenshot - send a screenshot from village."
			$txtHelp &= "\n" & "/LastRaidText - send the last raid loot values"
			$txtHelp &= "\n" & "/LastRaid - send the last raid loot screenshot"
			$txtHelp &= "\n" & "/Stop - stop the bot"
			$txtHelp &= "\n" & "/Pause - pause the bot"
			$txtHelp &= "\n" & "/Restart - restart the bot and Android emulator"
			$txtHelp &= "\n" & "/Resume - resume the bot"
			$txtHelp &= "\n" & "/Help - send this help message"
			$txtHelp &= "\n" & "/Unsubscribe - unsubscribe you and stop send message to you.(sending any message subscribe you again)"
			$txtHelp &= "\n" & "/Delete - delete all your previous message"
			$txtHelp &= "\n" & "/Log - send the current log file"
			$txtHelp &= "\n"
			_PushTxtMessage($chat_id, $txtHelp)
			SetLog("Telegram: Your request has been received. Help Command Send", $COLOR_GREEN)

		Case "/PAUSE"
			If $TPaused = False And $Runstate = True Then
				If ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = False And IsAttackPage() Then
					SetLog("Telegram: Unable to pause during attack", $COLOR_RED)
					_PushTxtMessage($chat_id, $iOrigTelegram & " :\nRequest to Pause.\nUnable to pause during attack, try again later.")
				ElseIf ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = True And IsAttackPage() Then
					ReturnHome(False, False)
					$Is_SearchLimit = True
					$Is_ClientSyncError = False
					UpdateStats()
					$Restart = True
					TogglePauseImpl("Push")
				Else
					TogglePauseImpl("Push")
				EndIf
			Else
				SetLog("Telegram: Your bot is currently paused, no action was taken", $COLOR_GREEN)
				_PushTxtMessage($chat_id, $iOrigTelegram & " :\nRequest to Pause.\nYour bot is currently paused, no action was taken.")
			EndIf
		Case "/RESUME"
			If $TPaused = True And $Runstate = True Then
				TogglePauseImpl("Push")
			Else
				SetLog("Telegram: Your bot is currently resumed, no action was taken", $COLOR_GREEN)
				_PushTxtMessage($chat_id,$iOrigTelegram & " :\nRequest to Resume.\nYour bot is currently resumed, no action was taken")
			EndIf
		Case "/DELETE"
			SetLog("Telegram: Your request has been received.", $COLOR_GREEN)
			_PushTxtMessage($chat_id,$iOrigTelegram & " :\Delete not avaible in Telegram API.")
		Case "/LOG"
			SetLog("Telegram: Your request has been received from " & $iOrigTelegram & ". Log is now sent", $COLOR_GREEN)
			_PushLogFile($chat_id,$sLogFName, "logs", "text/plain; charset=utf-8", $iOrigTelegram & " : Current Bot Log File.")
		Case "/LASTRAID"
			If $AttackFile <> "" Then
				_PushImgFile($chat_id,$AttackFile, "Loots", "image/jpeg", $iOrigTelegram & " : Last Raid.")
			Else
				_PushTxtMessage($chat_id, $iOrigTelegram & " :\n" & "There is no last raid screenshot.")
			EndIf
			SetLog("Telegram: Push Last Raid Snapshot...", $COLOR_GREEN)
		Case "/LASTRAIDTEXT"
			SetLog("Telegram: Your request has been received. Last Raid txt sent", $COLOR_GREEN)
			_PushTxtMessage($chat_id,$iOrigTelegram & " :\nLast Raid Text : \n[G]: " & _NumberFormat($iGoldLast) & "\n[E]: " & _NumberFormat($iElixirLast) & "\n[D]: " & _NumberFormat($iDarkLast) & "\n[T]: " & $iTrophyLast)
		Case "/STATS"
			SetLog("Telegram: Your request has been received. Statistics sent", $COLOR_GREEN)
			_PushTxtMessage($chat_id, $iOrigTelegram & " :\nStats Village Report\n\nAt Start\n[G]: " & _NumberFormat($iGoldStart) & "\n[E]: " & _NumberFormat($iElixirStart) & "\n[D]: " & _NumberFormat($iDarkStart) & "\n[T]: " & $iTrophyStart & "\n\nNow (Current Resources)\n[G]: " & _NumberFormat($iGoldCurrent) & "\n[E]: " & _NumberFormat($iElixirCurrent) & "\n[D]: " & _NumberFormat($iDarkCurrent) & "\n[T]: " & $iTrophyCurrent & "\n[GEM]: " & $iGemAmount & "\n\n[No. of Free Builders]: " & $iFreeBuilderCount & "\n[No. of Wall Up] : G: " & $iNbrOfWallsUppedGold & " , E: " & $iNbrOfWallsUppedElixir & "\n\nAttacked: " & GUICtrlRead($lblresultvillagesattacked) & "\nSkipped : " & $iSkippedVillageCount)
		Case "/SCREENSHOT"
			SetLog("Telegram: ScreenShot request received", $COLOR_GREEN)
			$TelegramRequestScreenshot = 1
			_ArrayAddCreate($TelegramRequestScreenshotIDs,$chat_id)
		Case "/RESTART"
			SetLog("Your request has been received. Bot and Android Emulator restarting...", $COLOR_GREEN)
			_PushTxtMessage($chat_id, $iOrigTelegram & " :\nRequest to Restart.\nYour bot and Android Emulator are now restarting.")
			SaveConfig()
			_Restart()
		Case "/STOP"
			SetLog("Your request has been received. Bot is now stopped", $COLOR_GREEN)
			If $Runstate = True Then
				_PushTxtMessage($chat_id, $iOrigTelegram & " :\nRequest to Stop.\nYour bot is now stopping.")
				btnStop()
			Else
				_PushTxtMessage($chat_id, $iOrigTelegram & " :\nRequest to Stop.\nYour bot is currently stopped, no action was taken.")
			EndIf
		Case "/UNSUBSCRIBE"
			_PushTxtMessage($chat_id, $iOrigTelegram & " :\nUnsubscribe from Bot.\nYou can send any message for subscribe again")
			_Unsubscribe($chat_id)
		Case "/CAMPSTATUS"
			If $CampStatus <> "" Then
				_PushTxtMessage($chat_id, $iOrigTelegram & " :\n" & $CampStatus)
			Else
				_PushTxtMessage($chat_id, $iOrigTelegram & " :\n" & "Camp Status need refresh,Try again after minutes.")
			EndIf
		Case Else
			Setlog("Unknown Command, Use Help",$COLOR_GREEN)
			_PushTxtMessage($chat_id,$iOrigTelegram & " :\nUnknown Command, Use /Help")
	EndSwitch
EndFunc

Func _SaveChatIDs($chat_id)

	;Setlog("Before : "&_ArrayToString($TelegramChatIDs),$COLOR_GREEN)
	Local $haveMessage = StringRegExp(StringUpper(_ArrayToString($TelegramChatIDs)), $chat_id)
	If $haveMessage = 0 Then
		_ArrayAdd($TelegramChatIDs,$chat_id)
	EndIf
	;Setlog("After : "&_ArrayToString($TelegramChatIDs),$COLOR_GREEN)

EndFunc

Func _Unsubscribe($chat_id)
	;Setlog("Before : "&_ArrayToString($TelegramChatIDs),$COLOR_GREEN)
	For $i = 0 To UBound($TelegramChatIDs) - 1 Step 1
		If $TelegramChatIDs[$i] = $chat_id Then
			_ArrayDelete($TelegramChatIDs,$i)
			ExitLoop
		EndIf
	Next
	;Setlog("After : "&_ArrayToString($TelegramChatIDs),$COLOR_GREEN)
EndFunc

Func _UpdateRemoteOffset($update_id)
	;Setlog("update offset : "&$update_id,$COLOR_GREEN)
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$oHTTP.Open("Get", $TelegramUrl & $TelegramToken & "/getupdates?offset=" & $update_id, False)
	$oHTTP.Send()
EndFunc

Func _Telegram($pMessage)
	_PushTxtToAll($pMessage)
EndFunc
;----------------------- public functions ----------------------------------------
Func PushMsgToTelegram($Message, $Source = "")
	Local $hBitmap_Scaled
	Local $Date1 = @YEAR & '/' & @MON & '/' & @MDAY
	Local $Time1 = @HOUR & ':' & @MIN
	Local $zaman = '[' & $Date1 & ' - ' & $Time1 & ']'
	Switch $Message
		Case "Restarted"
			If $TelegramEnabled = 1 And $pRemoteTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nBot restarted")
			EndIf
		Case "OutOfSync"
			If $TelegramEnabled = 1 And $pOOSTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nRestarted after Out of Sync Error,Attacking now")
			EndIf
		Case "LastRaid"
			_CaptureRegion(0, 0, $DEFAULT_WIDTH, $DEFAULT_HEIGHT - 45)
			;create a temporary file to send with telegram...
			Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
			Local $Time = @HOUR & "." & @MIN
			If $ScreenshotLootInfo = 1 Then
				$AttackFile = $Date & "__" & $Time & " " & "G" & $iGoldLast & " " & "E" & $iElixirLast & " " & "D" & $iDarkLast & " " & "T" & $iTrophyLast & " " & "S" & StringFormat("%3s", $SearchCount) & ".jpg" ; separator __ is need  to not have conflict with saving other files if $TakeSS = 1 and $chkScreenshotLootInfo = 0
			Else
				$AttackFile = $Date & "__" & $Time & ".jpg" ; separator __ is need  to not have conflict with saving other files if $TakeSS = 1 and $chkScreenshotLootInfo = 0
			EndIf
			$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, _GDIPlus_ImageGetWidth($hBitmap), _GDIPlus_ImageGetHeight($hBitmap)) ;resize image
			_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $dirLoots & $AttackFile)
			_GDIPlus_ImageDispose($hBitmap_Scaled)
			If $TelegramEnabled = 1 And $iAlertTLastRaidTxt = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nLast Raid txt\n[G]: " & _NumberFormat($iGoldLast) & "\n[E]: " & _NumberFormat($iElixirLast) & "\n[D]: " & _NumberFormat($iDarkLast) & "\n[T]: " & $iTrophyLast)
				If _Sleep($iDelayPushMsg1) Then Return
				SetLog("Telegram: Last Raid Text has been sent!", $COLOR_GREEN)
			EndIf
			If $TelegramEnabled = 1 And $pLastRaidImgTelegram = 1 Then
				;push the file
				SetLog("Telegram: Last Raid screenshot has been sent!", $COLOR_GREEN)
				_PushRImgToAll($AttackFile, "Loots", "image/jpeg", $iOrigTelegram & " : Last Raid image")
				;wait a second and then delete the file
				;If _Sleep($iDelayPushMsg1) Then Return
				;Local $iDelete = FileDelete($dirLoots & $AttackFile)
				;If Not ($iDelete) Then SetLog("Pushbullet: An error occurred deleting temporary screenshot file.", $COLOR_RED)
			EndIf
		Case "FoundWalls"
			If $TelegramEnabled = 1 And $pWallUpgradeTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nFound Wall level " & $icmbWalls + 4 & " Wall segment has been located.\nUpgrading")
			EndIf
		Case "SkipWalls"
			If $TelegramEnabled = 1 And $pWallUpgradeTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nCannot find Wall level " & $icmbWalls + 4 & " Skip upgrade")
			EndIf
		Case "AnotherDevice3600"
			If $TelegramEnabled = 1 And $pAnotherDeviceTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\n1. Another Device has connected, waiting " & Floor(Floor($sTimeWakeUp / 60) / 60) & " Hours " & Floor(Mod(Floor($sTimeWakeUp / 60), 60)) & " minutes " & Floor(Mod($sTimeWakeUp, 60)) & " seconds")
			EndIf
		Case "AnotherDevice60"
			If $TelegramEnabled = 1 And $pAnotherDeviceTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\n2. Another Device has connected, waiting " & Floor(Mod(Floor($sTimeWakeUp / 60), 60)) & " minutes " & Floor(Mod($sTimeWakeUp, 60)) & " seconds")
			EndIf
		Case "AnotherDevice"
			If $TelegramEnabled = 1 And $pAnotherDeviceTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\n3. Another Device has connected, waiting " & Floor(Mod($sTimeWakeUp, 60)) & " seconds")
			EndIf
		Case "TakeBreak"
			If $TelegramEnabled = 1 And $pTakeAbreakTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nChief, we need some rest.Village must take a break..")
			EndIf
		Case "CocError"
			If $TelegramEnabled = 1 And $pOOSTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nCoC Has Stopped Error")
			EndIf
		Case "Pause"
			If $TelegramEnabled = 1 And $pRemoteTelegram = 1 And $Source = "Push" Then
				_PushTxtToAll($iOrigTelegram & " :\nRequest to Pause,Your request has been received. Bot is now paused")
			EndIf
		Case "Resume"
			If $TelegramEnabled = 1 And $pRemoteTelegram = 1 And $Source = "Push" Then
				_PushTxtToAll($iOrigTelegram & " :\nRequest to Resume,Your request has been received. Bot is now resumed")
			EndIf
		Case "OoSResources"
			If $TelegramEnabled = 1 And $pOOSTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nDisconnected after " & StringFormat("%3s", $SearchCount) & " skip(s)\nCannot locate Next button, Restarting Bot")
			EndIf
		Case "MatchFound"
			If $TelegramEnabled = 1 And $pMatchFoundTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\n" & $sModeText[$iMatchMode] & " Match Found!\nafter" & StringFormat("%3s", $SearchCount) & " skip(s)\n[G]: " & _NumberFormat($searchGold) & "\n[E]: " & _NumberFormat($searchElixir) & "\n[D]: " & _NumberFormat($searchDark) & "\n[T]: " & $searchTrophy)
			EndIf
		Case "UpgradeWithGold"
			If $TelegramEnabled = 1 And $pWallUpgradeTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nUpgrade completed by using GOLD.\nComplete by using GOLD")
			EndIf
		Case "UpgradeWithElixir"
			If $TelegramEnabled = 1 And $pWallUpgradeTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nUpgrade completed by using ELIXIR.\nComplete by using ELIXIR")
			EndIf
		Case "NoUpgradeWallButton"
			If $TelegramEnabled = 1 And $pWallUpgradeTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nNo Upgrade Gold Button.\nCannot find gold upgrade button")
			EndIf
		Case "NoUpgradeElixirButton"
			If $TelegramEnabled = 1 And $pWallUpgradeTelegram = 1 Then
				_PushTxtToAll($iOrigTelegram & " :\nNo Upgrade Elixir Button.\nCannot find elixir upgrade button.")
			EndIf
		Case "RequestScreenshot"
			Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
			Local $Time = @HOUR & "." & @MIN
			_CaptureRegion(0, 0, $DEFAULT_WIDTH, $DEFAULT_HEIGHT)
			$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, _GDIPlus_ImageGetWidth($hBitmap), _GDIPlus_ImageGetHeight($hBitmap))
			Local $Screnshotfilename = "Screenshot_" & $Date & "_" & $Time & ".jpg"
			_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $dirTemp & $Screnshotfilename)
			_GDIPlus_ImageDispose($hBitmap_Scaled)
			_PushImgToAll($Screnshotfilename, "Temp", "image/jpeg", $iOrigTelegram & " : Screenshot of your village.")
			SetLog("Telegram: Screenshot sent!", $COLOR_GREEN)
			$TelegramRequestScreenshot = 0
			;wait a second and then delete the file
			;If _Sleep($iDelayPushMsg2) Then Return
			;Local $iDelete = FileDelete($dirTemp & $Screnshotfilename)
			;If Not ($iDelete) Then SetLog("Telegram: An error occurred deleting the temporary screenshot file.", $COLOR_RED)
		Case "CampFull"
			If $TelegramEnabled = 1 And $ichkAlertTCampFull = 1 Then
				If $ichkAlertTCampFullTest = 0 Then
					_PushTxtToAll($iOrigTelegram & " :\nYour Army Camps are now Full")
					$ichkAlertTCampFullTest = 1
				EndIf
			EndIf
	EndSwitch
EndFunc   ;==>PushMsgToTelegram

;----------------------- telegram utils function ---------------------------------
Func _ArrayAddCreate(ByRef $avArray, $sValue)
    If IsArray($avArray) Then
        ReDim $avArray[UBound($avArray) + 1]
        $avArray[UBound($avArray) - 1] = $sValue
        SetError(0)
        Return 1
    ElseIf Not IsArray($avArray) Then
        Dim $avArray[1]
        $avArray[0] = $sValue
        Return 2
    Else
        SetError(1)
        Return 0
    EndIf
EndFunc   ;==>_ArrayAddCreate

Func _JSONGet($json, $path, $seperator = ".")
	Local $seperatorPos,$current,$next,$l
	$seperatorPos = StringInStr($path, $seperator)
	If $seperatorPos > 0 Then
		$current = StringLeft($path, $seperatorPos - 1)
		$next = StringTrimLeft($path, $seperatorPos + StringLen($seperator) - 1)
	Else
		$current = $path
		$next = ""
	EndIf

	If _JSONIsObject($json) Then
		$l = UBound($json, 1)
		For $i = 0 To $l - 1
			If $json[$i][0] == $current Then
				If $next == "" Then
					return $json[$i][1]
				Else
					return _JSONGet($json[$i][1], $next, $seperator)
				EndIf
			EndIf
		Next
	ElseIf IsArray($json) And UBound($json, 0) == 1 And UBound($json, 1) > $current Then
		If $next == "" Then
			return $json[$current]
		Else
			return _JSONGet($json[$current], $next, $seperator)
		EndIf
	EndIf
	return $_JSONNull
EndFunc		;==>_JSONGet

;Telegram