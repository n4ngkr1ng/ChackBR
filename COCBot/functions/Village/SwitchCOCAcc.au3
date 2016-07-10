; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchCocAcc
; Description ...: Switching COC accounts to play
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: chalicucu
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func SwitchCOCAcc($FirstSwitch = False)     ;change COC account
	If $FirstSwitch Then SetLog("First matching account and profile", $COLOR_GREEN);
	If $FirstSwitch Then
	    SetLog("First matching account and profile", $COLOR_GREEN);
	    SetLog("Ordered COC account: " & AccGetOrder() & " (" & AccGetStep() & ")", $COLOR_GREEN);
	    SetLog("Ordered bot profile: " & ProGetOrderName(), $COLOR_GREEN);
	    ;if $nCurCOCAcc = $anCOCAccIdx[$nCurCOCAcc - 1] And Not $FirstStart Then  ;Loopping 1 account, disable switching
	    $lnNextStep = AccGetNext()
	    If $nCurCOCAcc = $anCOCAccIdx[$lnNextStep] And Not $FirstStart Then  ;Loopping 1 account, disable switching
		 SetLog("Target account is current one. Nothing to do..", $COLOR_GREEN)
		 $nCurStep = $lnNextStep  ;but still move to next step
		 $iGoldLast = ""
		 $iElixirLast = ""
		 Return
	    EndIf
	    $nPreCOCAcc = $nCurCOCAcc
	    $nCurCOCAcc = $anCOCAccIdx[$lnNextStep]     ;target account
	Else
	    MinRemainTrainAcc()
	    $nCurCOCAcc = $nNextCoCAcc
	EndIf

    Local Const $XConnect = 431
    Local Const $YConnect = 434
    Local Const $ColorConnect = 4284458031      ;Connected Button: green
    Click(800, 585, 1, 0, "Click Setting")      ;Click setting
    If _Sleep(3000) Then Return
    If _ColorCheck(_GetPixelColor($XConnect, $YConnect, True), Hex($ColorConnect, 6), 20) Then       ;Green
        Click($XConnect, $YConnect, 1, 0, "Click Connected")      ;Click Connect
    EndIf

    If _Sleep(3000) Then Return
    Click($XConnect, $YConnect, 1, 0, "Click DisConnect")      ;Click DisConnect
    If _Sleep(8000) Then Return

    ;Click(383, 300 + 80*($nCurCOCAcc - 1), 1, 0, "Click Account " & $nCurCOCAcc)      ;Click Google Account
    ;need check acc clicked or not-------------------------

	Click(383, 370 - 70 * Int(($nTotalCOCAcc - 1)/2) + 70*($nCurCOCAcc - 1), 1, 0, "Click Account " & $nCurCOCAcc)      ;Click Google Account

    #CS Total three acc
    If $nCurCOCAcc = 1 Then     ;switch 1st and 3rd account : 1->3->2->1
        Click(383, 460, 1, 0, "Click Third Account")      ;Click Third Account
        $nCurCOCAcc = 3
        $TotalCamp = 220    ; Account TotalCamp
        _GUICtrlComboBox_SetCurSel($cmbProfile,1-1)
    ElseIf $nCurCOCAcc = 2 Then
        Click(383, 300, 1, 0, "Click First Account")      ;Click First Account
        $nCurCOCAcc = 1
        $TotalCamp = 220    ; Account TotalCamp
        _GUICtrlComboBox_SetCurSel($cmbProfile,4-1)
    Else
        Click(383, 380, 1, 0, "Click Second Account")      ;Click Second Account
        $nCurCOCAcc = 2
        $TotalCamp = 200    ; Account TotalCamp
        _GUICtrlComboBox_SetCurSel($cmbProfile,2-1)
    EndIf
     #CE

    If _Sleep(8000) Then Return
    Local $idx = 0
    While 1
        If _ColorCheck(_GetPixelColor($XConnect, $YConnect, True), Hex($ColorConnect, 6), 20) Then       ;Blue
            Setlog("Still current account. Wait for next switching", $COLOR_RED)
            If $idx >= 2 Then
				MatchProfile()
                ClickP($aAway, 1, 0, "#0167") ;Click Away
                If _Sleep(2000) Then Return
                ;SwitchCOCAcc()     ;force switch
                Return
            EndIf
		ElseIf _ColorCheck(_GetPixelColor($XConnect, $YConnect, True), Hex(4291299336, 6), 20) Then       ;red
			If _Sleep(4000) Then Return
			Setlog("Still disconnect button", $COLOR_RED)
		ElseIf _ColorCheck(_GetPixelColor($XConnect, $YConnect, True), Hex(4294309365, 6), 20) Then 	;not yet clicked google acc
			;Click(383, 300 + 80*($nCurCOCAcc - 1), 1, 0, "Click Account " & $nCurCOCAcc)      ;Click Google Account
			Click(383, 370 - 70 * Int(($nTotalCOCAcc - 1)/2) + 70*($nCurCOCAcc - 1), 1, 0, "Click Account " & $nCurCOCAcc)      ;Click Google Account
		Else	;4293454048
            Setlog("Changing to account [" & $nCurCOCAcc & "]", $COLOR_RED)
            ExitLoop
        EndIf
        $idx = $idx + 1
        If _Sleep(1000) Then Return
    WEnd
    ;If _Sleep(1000) Then Return
    $idx = 0
    While $idx <= 30
        If _ColorCheck(_GetPixelColor(443, 430, True), Hex(4284390935, 6), 20) Then
            Setlog("Load button appears", $COLOR_RED)
            ExitLoop
        Else
            Setlog("Wait!", $COLOR_RED)
            If _Sleep(1000) Then Return
			$idx = $idx + 1
			If $idx >= 31 Then
				ClickP($aAway, 1, 0, "#0167") ;Click Away
				Return False
			EndIf
        EndIf
    WEnd
    $idx = 0
    While _ColorCheck(_GetPixelColor(443, 430, True), Hex(4284390935, 6), 20) And $idx <= 40
        If _Sleep(1000) Then Return
        Click(443, 430, 1, 0, "Click Load")      ;Click Load
        $idx = $idx + 1
    WEnd
    If _Sleep(5000) Then Return
    Click(353, 180, 1, 0, "Click Text box")      ;Click Text box
    If _Sleep(2000) Then Return
    If SendText("CONFIRM") = 0 Then
        Setlog("Error sending CONFIRM text", $COLOR_RED)
        Return
    EndIf
    If _Sleep(3000) Then Return
    PureClick(463, 180, 1, 0, "Click CONFIRM")      ;Click CONFIRM
    If _Sleep(3000) Then Return
    ClickP($aAway, 1, 0, "#0167") ;Click Away

	$nCurStep = $lnNextStep
	;init for new acc
	Init4NewAcc($nPreCOCAcc)
	VillageReport()
EndFunc     ;==> SwitchCOCAcc

Func AccGetNext()
	If $nCurStep >= $CoCAccNo - 1 Then
		Return 0
	Else
		Return $nCurStep + 1
	EndIf
EndFunc     ;==> AccGetNext

Func MatchProfile()
	If UBound($anBotProfileIdx) < $nTotalCOCAcc Then
		Setlog("Need set up correnspond profile first", $COLOR_RED)
		Return False
	ElseIf $anBotProfileIdx[$nCurCOCAcc - 1] - 1 < 0 Or $anBotProfileIdx[$nCurCOCAcc - 1] > _GUICtrlComboBox_GetCount($cmbProfile) Then
		Setlog("Wrong config correnspond profile: " & $anBotProfileIdx[$nCurCOCAcc - 1], $COLOR_RED)
		Return False
	EndIf
	_GUICtrlComboBox_SetCurSel($cmbProfile,$anBotProfileIdx[$nCurCOCAcc - 1] - 1)
	cmbProfile()
	Return True
EndFunc

Func Init4NewAcc($nPreCOCAcc, $FirstSwitch = False)
	$Is_ClientSyncError = False
	$Is_SearchLimit = False
	$quicklyfirststart = True
	$fullArmy = False
	$iGoldLast = "" 	;pushbullet init for last attack
	$iElixirLast = ""
	If Not $FirstSwitch Then
		$AccFirstStart[$nPreCOCAcc - 1] = False
		$FirstStart = $AccFirstStart[$nCurCOCAcc - 1]
	EndIf

	$AccTotalTrainedTroops[$nPreCOCAcc - 1] =$TotalTrainedTroops
	$TotalTrainedTroops = $AccTotalTrainedTroops[$nCurCOCAcc - 1]

	For $i = 0 To UBound($TroopName) - 1
		Execute("$AccDon" & $TroopName[$i] & "[" & String($nPreCOCAcc - 1) & "] = $Don" & $TroopName[$i])			;save previous donate troops no.
		Assign("Don" & $TroopName[$i], Execute("$AccDon" & $TroopName[$i] & "[" & String($nCurCOCAcc - 1) & "]"))	;set new donate troops no.
		Execute("$AccCur" & $TroopName[$i] & "[" & String($nPreCOCAcc - 1) & "] = $Cur" & $TroopName[$i])			;save previous current troops no.
		Assign("Cur" & $TroopName[$i], Execute("$AccCur" & $TroopName[$i] & "[" & String($nCurCOCAcc - 1) & "]"))	;set new current troops no.
		;SETLOG("AccCur" & $TroopName[$i] & "[" & String($nCurCOCAcc - 1) & "]............" & Execute("$AccCur" & $TroopName[$i] & "[" & String($nCurCOCAcc - 1) & "]"))
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		Execute("$AccDon" & $TroopDarkName[$i] & "[" & String($nPreCOCAcc - 1) & "] = $Don" & $TroopDarkName[$i])		;save previous donate troops no.
		Assign("Don" & $TroopDarkName[$i], Eval("AccDon" & $TroopDarkName[$i] & "[" & String($nCurCOCAcc - 1) & "]"))	;set new donate troops no.
		Execute("$AccCur" & $TroopDarkName[$i] & "[" & String($nPreCOCAcc - 1) & "] = $Cur" & $TroopDarkName[$i])		;save previous current troops no.
		Execute("$Cur" & $TroopDarkName[$i] & " = $AccCur" & $TroopDarkName[$i] & "[" & String($nCurCOCAcc - 1) & "]")	;set new current troops no.
		;SETLOG("AccCur" & $TroopDarkName[$i] & "[" & String($nCurCOCAcc - 1) & "]............" & Execute("$AccCur" & $TroopDarkName[$i] & "[" & String($nCurCOCAcc - 1) & "]"))
	Next

	MatchProfile()
EndFunc   ;==>Init4NewAcc

Func AccGetStep()
	Local $orderstr = ""
	;Local $lnacc = $nCurCOCAcc
	$orderstr = String($anCOCAccIdx[0])
	For $i = 1 To $CoCAccNo - 1
		;$lnacc = $anCOCAccIdx[$i]
		$orderstr &= "->" & String($anCOCAccIdx[$i])
	Next
	$orderstr &= "->" & String($anCOCAccIdx[0]) & "->..."
	Return $orderstr
EndFunc   ;==> AccGetStep

Func AccGetOrder()
	Local $orderstr = ""
	For $i = 0 to $CoCAccNo - 1
		$orderstr &= String($anCOCAccIdx[$i])
	Next

	Return $orderstr
EndFunc   ;==> AccGetOrder

Func ProGetOrderName()
	Local $orderstr = ""
	For $i = 0 to $CoCAccNo - 1
		$orderstr &= String($anBotProfileIdx[$anCOCAccIdx[$i] - 1])
	Next
	Local $comboBoxArray = _GUICtrlComboBox_GetListArray($cmbProfile)
	$orderstr &= " (" & $comboBoxArray[$anBotProfileIdx[$anCOCAccIdx[0] - 1]]	; need check ubound
	For $i = 1 to $CoCAccNo - 1
		If $anBotProfileIdx[$anCOCAccIdx[$i] - 1] > Ubound($comboBoxArray) - 1 Then
			$orderstr &= ", [Wrong profile index: " & $anBotProfileIdx[$anCOCAccIdx[$i] - 1] & "]"
		Else
			$orderstr &= ", " & $comboBoxArray[$anBotProfileIdx[$anCOCAccIdx[$i] - 1]]
		EndIf
	Next
	$orderstr &= ")"
	Return $orderstr
EndFunc   ;==> ProGetOrderName

Func AccStartInit()
	Local $initAccTrain[$nTotalCOCAcc]	; = [0,0,0]
	For $i = 0 to $nTotalCOCAcc - 1
		$initAccTrain[$i] = 0
	Next

	For $i = 0 To UBound($TroopName) - 1
		Execute("$AccDon" & $TroopName[$i] & " = $initAccTrain")		;reset donate troops no.
		Execute("$AccCur" & $TroopName[$i] & " = $initAccTrain")		;reset current troops no.
	Next
	For $i = 0 To UBound($TroopDarkName) - 1
		Execute("$AccDon" & $TroopDarkName[$i] & " = $initAccTrain")	;reset donate troops no.
		Execute("$AccCur" & $TroopDarkName[$i] & " = $initAccTrain")	;reset current troops no.
	Next

	For $i = 0 To UBound($AccFirstStart) - 1
		$AccFirstStart[$i] = True
	Next
	$AccTotalTrainedTroops = $initAccTrain
EndFunc   ;==> AccStartInit

Func ReorderAcc($cfgStr, $GUIconfig = False)
	Local $reorderstr = "", $lbWrongCfg = False
	Local $lsNewOrd = StringStripWS($cfgStr, $STR_STRIPALL)

	If $CoCAccNo <> StringLen($lsNewOrd) Then $nCurStep = StringLen($lsNewOrd) - 1

	$CoCAccNo = StringLen($lsNewOrd)		;new number of step to switch
	Redim $anCOCAccIdx[$CoCAccNo]

	For $i = 0 to $CoCAccNo - 1
		If Number(StringMid($lsNewOrd, $i + 1, 1)) > 0 And  Number(StringMid($lsNewOrd, $i + 1, 1)) <= $nTotalCOCAcc Then
			$anCOCAccIdx[$i] = Number(StringMid($lsNewOrd, $i + 1, 1))
		Else
			SetLog("Wrong acc number: " & StringMid($lsNewOrd, $i + 1, 1), $COLOR_RED)
			$lbWrongCfg = True
			If $i <> 0 Then
				$anCOCAccIdx[$i] = $anCOCAccIdx[$i - 1]
			Else
				$anCOCAccIdx[$i] = $nCurCOCAcc		;please don't :D
			EndIf
		EndIf
		$reorderstr &= String($anCOCAccIdx[$i])
	Next
	IniWriteS($profile, "switchcocacc", "order", $reorderstr)
	SetLog("Reordered COC account: [" & $reorderstr & "]: " & AccGetStep(), $COLOR_RED)
	If $lbWrongCfg Or Not $GUIconfig Then
		If IsDeclared("txtAccBottingOrder") Then GUICtrlSetData($txtAccBottingOrder, $reorderstr)
	EndIf
	Return $reorderstr
EndFunc   ;==> ReorderAcc

Func AddAcc($accIdx)		;add one account to order list
	Local $newAcc = Number(StringLeft($accIdx, 1))
	If $newAcc > 0 And $newAcc <= $nTotalCOCAcc Then
		For $i = 0 To $CoCAccNo - 1
			If $anCOCAccIdx[$i] = $newAcc Then
				Return "Account " & $newAcc & " already in playing list"
			EndIf
		Next
		$CoCAccNo += 1
		Redim $anCOCAccIdx[$CoCAccNo]
		$anCOCAccIdx[$CoCAccNo - 1] = $newAcc
		AccSaveConfig()
		Return "Account " & $newAcc & " was added to playing list"
	EndIf
EndFunc   ;==> AddAcc

Func RemAcc($accIdx)		;remove account from order list
	Local $newAcc = Number(StringLeft($accIdx, 1))
	If $newAcc > 0 And $newAcc <= $nTotalCOCAcc Then
		For $i = 0 To $CoCAccNo - 1
			If $anCOCAccIdx[$i] = $newAcc Then
				For $j = $i To $CoCAccNo - 2
					$anCOCAccIdx[$j] = $anCOCAccIdx[$j + 1]
				Next
				$CoCAccNo -= 1
				Redim $anCOCAccIdx[$CoCAccNo]
		AccSaveConfig()
				Return "Account " & $newAcc & " was removed from playing list"
			EndIf
		Next
		Return "Account " & $newAcc & " is not in playing list"
	EndIf
 EndFunc   ;==> RemAcc

Func ReorderCurPro($cfgStr)
	;reorder profile for current playing accounts
	Local $reorderstr = "", $lsPlaying = ""
	For $i = 1 to $CoCAccNo
		If Number(StringMid($cfgStr, $i, 1)) > 0 And Number(StringMid($cfgStr, $i, 1)) <= _GUICtrlComboBox_GetCount($cmbProfile) Then
			$anBotProfileIdx[$anCOCAccIdx[$i - 1] - 1] = Number(StringMid($cfgStr, $i, 1))
		Else
			SetLog("Wrong profile " & $i & ": [" & $StringMid($cfgStr, $i, 1) & "]", $COLOR_RED)
		EndIf
		$lsPlaying &= String($anBotProfileIdx[$anCOCAccIdx[$i - 1] - 1])
	Next

	For $i = 0 To UBound($anBotProfileIdx) - 1
		$reorderstr &= String($anBotProfileIdx[$i])
	Next
	IniWriteS($profile, "switchcocacc", "profile", $reorderstr)
	GUICtrlSetData($txtProfileIdxOrder, $reorderstr)

	SetLog("Reordered Bot profile for playing: " & $lsPlaying, $COLOR_RED)
	Local $comboBoxArray = _GUICtrlComboBox_GetListArray($cmbProfile)
	$lsPlaying = "([" & $anCOCAccIdx[0] & "]" & $comboBoxArray[$anBotProfileIdx[$anCOCAccIdx[0] - 1]]
	For $i = 1 to $CoCAccNo - 1
		$lsPlaying &= ", [" & $anCOCAccIdx[$i] & "]" & $comboBoxArray[$anBotProfileIdx[$anCOCAccIdx[$i] - 1]]
	Next
	$lsPlaying &= ")"
	SetLog($lsPlaying, $COLOR_RED)
	Return $lsPlaying
EndFunc   ;==> ReorderCurPro

Func ReorderAllPro($cfgStr, $GUIconfig = false)
	;reorder profile for all accounts
	Local $reorderstr = ""
	For $i = 1 to $nTotalCOCAcc
		If Number(StringMid($cfgStr, $i, 1)) > 0 And Number(StringMid($cfgStr, $i, 1)) <= _GUICtrlComboBox_GetCount($cmbProfile) Then
			$anBotProfileIdx[$i - 1] = Number(StringMid($cfgStr, $i, 1))
		Else
			If $anBotProfileIdx[$i - 1] > 0 And $anBotProfileIdx[$i - 1] <= _GUICtrlComboBox_GetCount($cmbProfile) Then
				SetLog("Wrong Config Profile: " & StringMid($cfgStr, $i, 1) & ". Keep Current", $COLOR_RED)
			Else
				$anBotProfileIdx[$i - 1] = 1
				SetLog("Wrong Config Profile: " & StringMid($cfgStr, $i, 1) & ". Set default 1", $COLOR_RED)
			EndIf
		EndIf
		$reorderstr &= String($anBotProfileIdx[$i - 1])
	Next

	IniWriteS($profile, "switchcocacc", "profile", $reorderstr)
	If $reorderstr <> $cfgStr  Or Not $GUIconfig Then
		If IsDeclared("txtProfileIdxOrder") Then GUICtrlSetData($txtProfileIdxOrder, $reorderstr)
	EndIf
	Local $comboBoxArray = _GUICtrlComboBox_GetListArray($cmbProfile)
	 If  _GUICtrlComboBox_GetCount($cmbProfile) = 0 Then Return "Set up profiles!"
	$reorderstr &= " ([1]" & $comboBoxArray[$anBotProfileIdx[0]]
	For $i = 1 to $nTotalCOCAcc - 1
		$reorderstr &= ", [" & ($i + 1) & "]" & $comboBoxArray[$anBotProfileIdx[$i]]
	Next
	$reorderstr &= ")"
	SetLog("Reordered Bot profile for all accounts: " & $reorderstr, $COLOR_RED)

	Return $reorderstr
EndFunc   ;==> ReorderAllPro

Func InitOrder()
	Local $lsconfig, $lbWrongCfg = false
	InireadS($lsconfig,$profile, "switchcocacc", "order", "000")
	If $lsconfig = "000" Then	;first set up (if user not define)
		$lsconfig = ""
		For $i = 1 To $nTotalCOCAcc
			$lsconfig &= String($i)
		Next
		IniWriteS($profile, "switchcocacc", "order", $lsconfig)
	EndIf
	$CoCAccNo = StringLen($lsconfig)
	Redim $anCOCAccIdx[$CoCAccNo]
	For $i = 1 To $CoCAccNo
		If Number(StringMid($lsconfig, $i, 1)) > 0 And Number(StringMid($lsconfig, $i, 1)) <= $nTotalCOCAcc Then
			$anCOCAccIdx[$i - 1] = Number(StringMid($lsconfig, $i, 1))
		Else
			SetLog("Wrong Config Account " & $i & ": " & StringMid($lsconfig, $i, 1) & ". Set as 1 [1st account]", $COLOR_RED)
			$anCOCAccIdx[$i - 1] = 1		;set default
			$lbWrongCfg = True
		EndIf
	Next
	If $lbWrongCfg Then
		$lbWrongCfg = False
		AccSaveConfig()
	Else
		If IsDeclared("txtAccBottingOrder") Then GUICtrlSetData($txtAccBottingOrder, $lsconfig)
	EndIf
	InireadS($lsconfig,$profile, "switchcocacc", "profile", "00000000")
	If $lsconfig = "00000000" Then	;first set up
		$lsconfig = "12345678"
		IniWriteS($profile, "switchcocacc", "profile", $lsconfig)
	EndIf
	For $i = 1 To $nTotalCOCAcc
		If Number(StringMid($lsconfig, $i, 1)) > 0  And Number(StringMid($lsconfig, $i, 1)) <= _GUICtrlComboBox_GetCount($cmbProfile) Then
			$anBotProfileIdx[$i - 1] = Number(StringMid($lsconfig, $i, 1))
		Else
			SetLog("Wrong Config Profile " & $i & ": " & StringMid($lsconfig, $i, 1) & ". Set as 1 [1st profile]", $COLOR_RED)
			$anBotProfileIdx[$i - 1] = 1		;set default
			$lbWrongCfg = True
		EndIf
	Next
	If $lbWrongCfg Then
		$lbWrongCfg = False
		ProSaveConfig()
	Else
		If IsDeclared("txtProfileIdxOrder") Then GUICtrlSetData($txtProfileIdxOrder, $lsconfig)		;StringLeft($lsconfig, $nTotalCOCAcc))
	EndIf

EndFunc   ;==> InitOrder

Func MapAccPro($imapstr) ; $mapstr = <Account No>-<Profile No> , ie: 1-9, account 1 use profile 9 (digit only)
	Local $mapstr = StringStripWS($imapstr, $STR_STRIPALL)
	Local $lnAcno = Number(StringLeft($mapstr, 1))
	Local $lnProNo = Number(StringMid($mapstr, 3, 1))
	If (0 < $lnAcno And $lnAcno <= $nTotalCOCAcc) _
		And (0 < $lnProNo And $lnProNo <= _GUICtrlComboBox_GetCount($cmbProfile)) Then
		$anBotProfileIdx[$lnAcno - 1] = $lnProNo
		SetLog("Mapping success account " & $lnAcno & " to profile " & $lnProNo, $COLOR_RED)
		ProSaveConfig()
		Return True
	EndIf
	Return False
EndFunc

Func AccSaveConfig()
	Local $reorderstr = ""
	For $i = 1 to $CoCAccNo
		$reorderstr &= String($anCOCAccIdx[$i - 1])
	Next
	IniWriteS($profile, "switchcocacc", "order", $reorderstr)
	If IsDeclared("txtAccBottingOrder") Then GUICtrlSetData($txtAccBottingOrder, $reorderstr)
EndFunc   ;==> AccSaveConfig

Func ProSaveConfig()
	;save profiles for all accounts
	Local $reorderstr = ""
	For $i = 1 to $nTotalCOCAcc
		$reorderstr &= String($anBotProfileIdx[$i - 1])
	Next
	IniWriteS($profile, "switchcocacc", "profile", $reorderstr)
	If IsDeclared("txtProfileIdxOrder") Then GUICtrlSetData($txtProfileIdxOrder, $reorderstr)
EndFunc   ;==> ProSaveConfig

Func ReCfgTotalAcc($anewTotal)
	Local $newTotal = Int($anewTotal)
	If $newTotal <= 0 Or $newTotal > 8 Then
		SetLog("Wrong config total account: " & $newTotal, $COLOR_RED)
		MsgBox($MB_SYSTEMMODAL, "Alarm!", "Wrong config total account. Only from 1 -> 8 accepted", 10)
		Return False
	EndIf
	If $newTotal <> $nTotalCOCAcc Then
		SetLog("Total account changed: " & $nTotalCOCAcc & " -> " & $newTotal, $COLOR_RED)
		$nTotalCOCAcc = $newTotal
		Redim $anBotProfileIdx[$nTotalCOCAcc]
		InitOrder()
		Redim $AccDonBarb[$nTotalCOCAcc], $AccDonArch[$nTotalCOCAcc], $AccDonGiant[$nTotalCOCAcc], $AccDonGobl[$nTotalCOCAcc], $AccDonWall[$nTotalCOCAcc], $AccDonBall[$nTotalCOCAcc], $AccDonWiza[$nTotalCOCAcc], $AccDonHeal[$nTotalCOCAcc]
		Redim $AccDonMini[$nTotalCOCAcc], $AccDonHogs[$nTotalCOCAcc], $AccDonValk[$nTotalCOCAcc], $AccDonGole[$nTotalCOCAcc], $AccDonWitc[$nTotalCOCAcc], $AccDonLava[$nTotalCOCAcc], $AccDonDrag[$nTotalCOCAcc], $AccDonPekk[$nTotalCOCAcc]
		Redim $AccBarbComp[$nTotalCOCAcc], $AccArchComp[$nTotalCOCAcc], $AccGoblComp[$nTotalCOCAcc], $AccGiantComp[$nTotalCOCAcc], $AccWallComp[$nTotalCOCAcc], $AccWizaComp[$nTotalCOCAcc], $AccMiniComp[$nTotalCOCAcc], $AccHogsComp[$nTotalCOCAcc]
		Redim $AccDragComp[$nTotalCOCAcc], $AccBallComp[$nTotalCOCAcc], $AccPekkComp[$nTotalCOCAcc], $AccHealComp [$nTotalCOCAcc], $AccValkComp[$nTotalCOCAcc], $AccGoleComp[$nTotalCOCAcc], $AccWitcComp[$nTotalCOCAcc], $AccLavaComp[$nTotalCOCAcc]
		Redim $AccCurBarb[$nTotalCOCAcc],  $AccCurArch[$nTotalCOCAcc],  $AccCurGiant[$nTotalCOCAcc], $AccCurGobl[$nTotalCOCAcc],  $AccCurWall[$nTotalCOCAcc],  $AccCurBall[$nTotalCOCAcc],  $AccCurWiza[$nTotalCOCAcc],  $AccCurHeal[$nTotalCOCAcc]
		Redim $AccCurMini[$nTotalCOCAcc],  $AccCurHogs[$nTotalCOCAcc],  $AccCurValk[$nTotalCOCAcc], $AccCurGole[$nTotalCOCAcc],  $AccCurWitc[$nTotalCOCAcc],  $AccCurLava[$nTotalCOCAcc],  $AccCurDrag[$nTotalCOCAcc],  $AccCurPekk[$nTotalCOCAcc]
		Redim $AccFirstStart[$nTotalCOCAcc]
		Redim $AccTotalTrainedTroops[$nTotalCOCAcc]
	EndIf
	IniWrite($profile, "switchcocacc" , "totalacc" , $nTotalCOCAcc)
	Return True
EndFunc
