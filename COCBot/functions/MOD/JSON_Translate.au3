#include-once
#include "JSON.au3"

; these are some examples of ways you can use the translator functionality built into the JSON.au3 library

Func __JSONArrayConvert2($aIn)
	; convert a two-dimensional array into nested arrays
	Local $l = UBound($aIn, 1), $l2 = UBound($aIn, 2)
	Local $a[$l], $a2[$l2]

	For $i = 0 To $l - 1
		For $i2 = 0 To $l2 - 1
			$a2[$i2] = $aIn[$i][$i2]
		Next
		$a[$i] = $a2
	Next

	Return $a
EndFunc   ;==>__JSONArrayConvert2

Func __JSON_pack_translate($v, $type)
	; convert AutoIt-specific variable types to specially-formatted JSON objects
	Return _JSONObject('_autoItType_', $type, '_autoItValue_', String($v))
EndFunc   ;==>__JSON_pack_translate

Func fromDictionary($d)
	Local $a = _JSONArray(), $i = 0
	For $k In $d.keys()
		ReDim $a[$i + 2]
		$a[$i] = $k
		$a[$i + 1] = $d.item($k)
		$i += 2
	Next
	Return _JSONObjectFromArray($a)
EndFunc   ;==>fromDictionary

Func JSON_pack($holder, $k, $v)
	#forceref $holder, $k
	Select
		Case IsObj($v)
			If ObjName($v) == 'IDictionary' Then
				Return fromDictionary($v)
			EndIf

		Case IsArray($v)
			If UBound($v, 0) == 2 And Not _JSONIsObject($v) Then
				Return __JSONArrayConvert2($v)
			EndIf

		Case IsHWnd($v)
			; convert to object
			Return __JSON_pack_translate($v, 'hwnd')

		Case IsPtr($v)
			; convert to object
			Return __JSON_pack_translate($v, 'ptr')

		Case IsBinary($v)
			; convert to array of byte values
			Return __JSON_pack_translate($v, 'binary')

	EndSelect

	Return $v
EndFunc   ;==>JSON_pack

Func toDictionary(Const ByRef $a) ; to avoid unwanted mutation of booleans into numbers in the original array
	Local $d = ObjCreate('Scripting.Dictionary')
	For $i = 1 To UBound($a) - 1
		Local $key = $a[$i][0]
		If Not _JSONIsNull($key) Then
			$d.add($key, $a[$i][1])
		EndIf
	Next
	Return $d
EndFunc   ;==>toDictionary

Func JSON_unpack($holder, $k, $v)
	#forceref $holder, $k
	If _JSONIsObject($v) Then
		Local $d = toDictionary($v)
		If $d.count = 2 And $d.exists('_autoItType_') And $d.exists('_autoItValue_') Then
			Switch $d.item('_autoItType_')
				Case 'hwnd'
					Return HWnd($d.item('_autoItValue_'))
				Case 'binary'
					Return Binary($d.item('_autoItValue_'))
				Case 'ptr'
					Return Ptr($d.item('_autoItValue_'))
			EndSwitch
		EndIf
;~ return $d
	EndIf

	Return $v
EndFunc   ;==>JSON_unpack