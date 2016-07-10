; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file Includes GUI Design
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

$hGUI_AttackOption = GUICreate("", $_GUI_MAIN_WIDTH - 40, $_GUI_MAIN_HEIGHT - 315, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $hGUI_SEARCH)
;GUISetBkColor($COLOR_WHITE, $hGUI_AttackOption)

$hGUI_AttackOption_TAB = GUICtrlCreateTab(0, 0, $_GUI_MAIN_WIDTH - 40, $_GUI_MAIN_HEIGHT - 315, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
$hGUI_AttackOption_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslated(600,28,"Search"))
#include "MBR GUI Design Child Attack - Options-Search.au3"
GUICtrlCreateTabItem("")
$hGUI_AttackOption_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslated(600,29,"Attack"))
#include "MBR GUI Design Child Attack - Options-Attack.au3"
GUICtrlCreateTabItem("")
$hGUI_AttackOption_TAB_ITEM3 = GUICtrlCreateTabItem(GetTranslated(600,30,"End Battle"))
#include "MBR GUI Design Child Attack - Options-EndBattle.au3"
GUICtrlCreateTabItem("")
$hGUI_AttackOption_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslated(600,32,"Trophy Settings"))
#include "MBR GUI Design Child Attack - Options-TrophySettings.au3"
GUICtrlCreateTabItem("")


;GUISetState()
