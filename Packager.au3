
; # О СКРИПТЕ # ==============================================================================================================
; Название .........: Packager
; Текущая версия ...: 1.0.0
; AutoIt Версия ....: 3.3.14.5
; Описание .........: Helps to compress the connector library, or build it according to individual preferences
; Автор ............: Webarion
; Сылки: ...........: http://webarion.ru, http://f91974ik.bget.ru
; ============================================================================================================================

#include <dev.au3>

#include <Array.au3>

Global $sgPathConnector = @ScriptDir & '\Connector_Full.au3'; path to full connector script

If Not FileExists($sgPathConnector) Then
	ConsoleWrite('-Not found ' & $sgPathConnector & @CRLF)
	Exit
EndIf

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

$Form1_1 = GUICreate("Connector assembler", 351, 280, -1, -1)
$Group1 = GUICtrlCreateGroup("Connector assembly method", 8, 8, 333, 217)
$Checkbox1 = GUICtrlCreateCheckbox("Remove debug output system", 24, 26, 281, 21)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox2 = GUICtrlCreateCheckbox("Delete system function descriptions", 24, 46, 281, 21)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox3 = GUICtrlCreateCheckbox("Remove custom function descriptions", 24, 66, 277, 21)
$Checkbox4 = GUICtrlCreateCheckbox("Delete individual comments", 24, 86, 281, 21)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox5 = GUICtrlCreateCheckbox("Minimize system function names", 24, 106, 281, 21)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox6 = GUICtrlCreateCheckbox("Minimize variable names", 24, 126, 281, 21)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox7 = GUICtrlCreateCheckbox("Compress the script as much as possible", 24, 146, 277, 21)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox8 = GUICtrlCreateCheckbox("Don't support passing arrays", 24, 168, 277, 17)
$Label1 = GUICtrlCreateLabel("Supported number of array dimensions:", 24, 192, 264, 17)
$Input1 = GUICtrlCreateInput("5", 289, 189, 41, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))

$Button2 = GUICtrlCreateButton("[-]", 312, 16, 26, 26, $BS_CENTER)
GUICtrlSetFont(-1, 8, 800, 0, "Calibri")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button1 = GUICtrlCreateButton("Assemble the connector", 70, 234, 209, 33)
GUISetState(@SW_SHOW)


Global $Input = $Input1

GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")
Local $iTrig = 0
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			GUICtrlSetState($Button1, $GUI_DISABLE)
			Global $sgTimer = 0
			AdlibRegister('_Timer1',50)
			_Packer()
			AdlibUnRegister('_Timer1')
			GUICtrlSetState($Button1, $GUI_ENABLE)
			GUICtrlSetData($Button1, 'Assemble the connector')
			$sgTimer = 0
		Case $Button2
			If $iTrig=0 Then
				GUICtrlSetData($Button2, "[+]")
				$iTrig = 1
			ElseIf $iTrig=1 Then
				GUICtrlSetData($Button2, "[0]")
				$iTrig = 2
			ElseIf $iTrig = 2 Then
				GUICtrlSetData($Button2, "[-]")
				$iTrig = 0
			EndIf

			If $iTrig = 1 Or $iTrig = 2 Then
				For $i = 1 To 8
					Execute('GUICtrlSetState($Checkbox' & $i & ', ' & ($iTrig = 1 ? $GUI_UNCHECKED : $GUI_CHECKED)& ')')
				Next
			EndIf

			If Not $iTrig Then
				Local $aStst = [$GUI_CHECKED,$GUI_CHECKED,$GUI_UNCHECKED,$GUI_CHECKED,$GUI_CHECKED,$GUI_CHECKED,$GUI_CHECKED,$GUI_UNCHECKED]
				For $i = 1 To 8
					Execute('GUICtrlSetState($Checkbox' & $i & ', ' & $aStst[$i-1] & ')')
				Next
			EndIf

		Case $Checkbox8
			If GUICtrlRead($Checkbox8) = 1 Then
				GUICtrlSetState($Label1, $GUI_DISABLE)
				GUICtrlSetState($Input1, $GUI_DISABLE)
			Else
				GUICtrlSetState($Label1, $GUI_ENABLE)
				GUICtrlSetState($Input1, $GUI_ENABLE)
			EndIf
	EndSwitch
WEnd

Func _Timer1()
	Local $sAnimate = _Copier('-', $sgTimer) & '>' & _Copier('-', 12 - $sgTimer)

	GUICtrlSetData($Button1, $sAnimate)
	$sgTimer +=1
	If $sgTimer>12 Then $sgTimer = 0
EndFunc

Func _Copier($sData, $iCount)
	Return StringReplace(StringFormat('%' & $iCount & 's', ''), ' ', $sData, 0, 2)
EndFunc   ;==>_Copier_CNMR

Func _WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Switch BitAND($wParam, 0xFFFF)
		Case $Input
			Switch BitShift($wParam, 16)
				Case $EN_CHANGE
					Local $Data = GUICtrlRead($Input)
					If $Data > 255 Then $Data = 255
					GUICtrlSetData($Input, $Data)
			EndSwitch
		Case Else
			If Not GUICtrlRead($Input) Then GUICtrlSetData($Input, 5)
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_COMMAND

Func _Packer()

	$hFile = FileOpen($sgPathConnector, 0)
	If $hFile = -1 Then
		MsgBox(4096, 'Error', 'Unable to open file ' & $sgPathConnector)
		Return SetError(1, 0, 0)
	EndIf
	$sTextConnector = FileRead($hFile)
	FileClose($hFile)

	Local $sSystemFuncMarker = '_CNMR'
	Local $sUserFuncMarker = '_Connector'

	Local $sNewTextConnector = $sTextConnector

	; улаляем систему вывода информации
	If GUICtrlRead($Checkbox1) = 1 Then
		$sTextConnector = StringRegExpReplace($sTextConnector, '(?sm)^\h*#Region\h+IDB_CNMR.+?#EndRegion\h+IDB_CNMR.*?\v*$', '')
	EndIf

	; удаляем описание системных функций
	If GUICtrlRead($Checkbox2) = 1 Then
		$sTextConnector = StringRegExpReplace($sTextConnector, '(?s);\h?\#SYSTEM FUNCTION\#.+?;\h*=+\v', '')
	EndIf

	; удаляем описание пользовательских функций
	If GUICtrlRead($Checkbox3) = 1 Then
		$sTextConnector = StringRegExpReplace($sTextConnector, '(?s);\h?\#USER FUNCTION\#.+?;\h*=+\v', '')
	EndIf

	; удаляем остальные комментарии и лишние переносы
	If GUICtrlRead($Checkbox4) = 1 Then
		Local $aTextConnector = StringSplit($sTextConnector, @CRLF, 2)
		Local $n = 0, $iS1 = 0, $iS2 = 0
		$sTextConnector = ''
		For $i = 0 To UBound($aTextConnector) - 1
			If StringInStr($aTextConnector[$i], '$DEFAULT_GROUP_ID_CONNECTOR') Then $n = 1
			If StringInStr($aTextConnector[$i], '; #USER FUNCTION# =') Or StringInStr($aTextConnector[$i], '; #SYSTEM FUNCTION# =') Then $iS1 = 1
			If Not StringRegExp($aTextConnector[$i], "'.*;.*'" & '|".*;.*"', 0) And $n And Not $iS1 Then
				$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], ';.*$', '')
			EndIf
			$sTextConnector &= $aTextConnector[$i] & @CRLF
			If StringInStr($aTextConnector[$i], '; ===') Then $iS1 = 0
		Next
		$sTextConnector = StringRegExpReplace($sTextConnector, '(?si)#CS History.+?#CE History', '')
		$sTextConnector = StringRegExpReplace($sTextConnector, '([\r\n]+\h*[\r\n]){1,}', @CRLF)
		$sTextConnector = StringRegExpReplace($sTextConnector, 'EndFunc', 'EndFunc' & @CRLF)
	EndIf

	; работаем массивы
	If GUICtrlRead($Checkbox8) = 1 Then ; не поддерживать
		$sTextConnector = StringRegExpReplace($sTextConnector, '(?sm)^\h*#Region\h+ARR_CNMR.+?#EndRegion\h+ARR_CNMR.*?\v*$', '')
	Else ; поддерживать
		If Not GUICtrlRead($Input1) Then GUICtrlSetData($Input1, 5)
		$sArrCreat = 'Func _ArrCreator_CNMR($a)' & @CRLF & @TAB & 'Local $i = UBound($a)'
		$sArrDxAdd = 'Func _ArrDxAdd_CNMR(ByRef $r, $a, $v)' & @CRLF & @TAB & 'Local $i = UBound($a)'
		Local $sTm1 = 'Dim $r', $sTm2 = '$r'
		For $i = 1 To GUICtrlRead($Input1)
			$sTm1 &= '[$a[' & $i - 1 & ']]'
			$sTm2 &= '[$a[' & $i - 1 & ']]'
			$sArrCreat &= @CRLF & @TAB & @TAB & 'If $i = ' & $i & ' Then ' & $sTm1
			$sArrDxAdd &= @CRLF & @TAB & @TAB & 'If $i = ' & $i & ' Then ' & $sTm2 & ' = $v'
		Next
		Local $sEnd = @CRLF & @TAB & 'Return $r' & @CRLF & 'EndFunc'
		$sArrCreat &= $sEnd
		$sArrDxAdd &= $sEnd
		$sTextConnector = StringRegExpReplace($sTextConnector, '(?si)Func\h+_ArrCreator_CNMR\h*\(.+?EndFunc?', $sArrCreat)
		$sTextConnector = StringRegExpReplace($sTextConnector, '(?si)Func\h+_ArrDxAdd_CNMR\h*\(.+?EndFunc?', $sArrDxAdd)
	EndIf

	; минимизация имён системных функций
	If GUICtrlRead($Checkbox5) = 1 Then
		Local $aFunc_GUIRegisterMsg = StringRegExp($sTextConnector, 'GUIRegisterMsg\h*\(\h*\w+?\h*,\h*"(\w+?)"\h*\)', 1)
		Local $aNamesFunc = StringRegExp($sTextConnector, 'Func\h+(\w+_CNMR)\h*\(', 3)
		If IsArray($aNamesFunc) And UBound($aNamesFunc) > 0 Then
			For $i = 0 To UBound($aNamesFunc) - 1
				Local $sNewFuncName = 'F' & $i & '_CNMR'
				If IsArray($aFunc_GUIRegisterMsg) And UBound($aFunc_GUIRegisterMsg) > 0 Then
					For $j = 0 To UBound($aFunc_GUIRegisterMsg) - 1
						If $aFunc_GUIRegisterMsg[$j] = $aNamesFunc[$i] Then
							$sTextConnector = StringRegExpReplace($sTextConnector, '(?s)(.*?GUIRegisterMsg\h*\(\h*\w+?\h*,\h*")' & $aNamesFunc[$i] & '("\h*\).*)', '$1' & $sNewFuncName & '$2');функ
						EndIf
					Next
				EndIf
				$sTextConnector = StringRegExpReplace($sTextConnector, '(?s)(.*?;\h*#\h*SYSTEM FUNCTION\h*#\h*=.+?:\h*)(' & $aNamesFunc[$i] & ')(.+?;\h*=)', '$1' & $sNewFuncName & '$3');функ в комм
				$sTextConnector = StringRegExpReplace($sTextConnector, $aNamesFunc[$i] & '\h*\(', $sNewFuncName & '(')
			Next
		EndIf
	EndIf


	; минимизация имён переменных
	If GUICtrlRead($Checkbox6) = 1 Then
		Local $sException = '$PROCESS_ALL_ACCESS', $aException = ['StringRegExpReplace', 'StringRegExp']
		Local $aGlobalVars = StringRegExp($sTextConnector, '(?s)\h*Global\h+(\$\w+)', 3)
		Local $sGlobalVars = _ArrayToString($aGlobalVars, ' ')
		Local $aTextFunc = StringRegExp($sTextConnector, '(?s)Func.+?EndFunc', 3)
		For $i = 0 To UBound($aTextFunc) - 1
			Local $sTextFunc = $aTextFunc[$i]
			Local $aVars = StringRegExp($sTextFunc, '(?s)\$\w+', 3)
			$aVars = _ArrayUnique($aVars)
			Local $aLensArr[0][2]
			For $r = 1 To UBound($aVars) - 1
				ReDim $aLensArr[UBound($aLensArr) + 1][2]
				$aLensArr[UBound($aLensArr) - 1][0] = StringLen($aVars[$r])
				$aLensArr[UBound($aLensArr) - 1][1] = $aVars[$r]
			Next
			_ArraySort($aLensArr, 1)
			Local $aVars[0]
			For $r = 0 To UBound($aLensArr) - 1
				ReDim $aVars[UBound($aVars) + 1]
				$aVars[UBound($aVars) - 1] = $aLensArr[$r][1]
			Next
			For $j = 0 To UBound($aVars) - 1
				If Not StringInStr($sGlobalVars, $aVars[$j]) Then
					Local $k = $j < 10 ? 1 : ($j < 255 ? 2 : ($j < 4095 ? 3 : 4))
					Local $sSm = Hex($j, $k)

					If Not StringInStr($sException, $aVars[$j]) Then; исключаемые из замены переменные
						For $e = 0 To UBound($aException) - 1
							; заменяем переменные, кроме находящихся, внутри кавычек регулярок
							If Not StringRegExp($sTextFunc, $aException[$e] & '\h*\(.+(?:' & "'" & '|")?.+?\' & $aVars[$j] & '.+?(?:' & "'" & '|")?', 0) Then $sTextFunc = StringReplace($sTextFunc, $aVars[$j], '$' & $sSm)
						Next
					EndIf

				EndIf
			Next
			$sTextConnector = StringReplace($sTextConnector, $aTextFunc[$i], $sTextFunc)
		Next
		Local $aGlobalVars = StringRegExp($sTextConnector, '(?si)\h*Global\h+(\$\w+_CNMR)', 3)
		$aGlobalVars = _ArrayUnique($aGlobalVars)
		For $j = 1 To UBound($aGlobalVars) - 1
			Local $k = $j < 10 ? 1 : ($j < 255 ? 2 : ($j < 4095 ? 3 : 4))
			Local $sSm = Hex($j, $k)
			$sTextConnector = StringReplace($sTextConnector, $aGlobalVars[$j], '$' & $j & '_CNMR')
		Next
	EndIf

	; максимально сжимаем скрипт
	If GUICtrlRead($Checkbox7) = 1 Then
		Local $aTextConnector = StringSplit($sTextConnector, @CRLF, 2)
		Local $n = 0
		$sTextConnector = ''
		For $i = 0 To UBound($aTextConnector) - 1

			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*=\h*', '=')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\+\h*', '+')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*-\h*', '-')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\*\h*', '*')

			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\(\h*', '(')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\)\h*', ')')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*,\h*', ',')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*&\h*', '&')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\[\h*', '[')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\]\h*', ']')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\<\h*', '<')
			$aTextConnector[$i] = StringRegExpReplace($aTextConnector[$i], '\h*\>\h*', '>')

			$sTextConnector &= $aTextConnector[$i] & @CRLF
			$sTextConnector = StringRegExpReplace($sTextConnector, '(\v+\h*)', @CRLF)

		Next
	EndIf

	If $sNewTextConnector = $sTextConnector Then
		ConsoleWrite('! Recording failed. Data is identical' & @CRLF)
		Return SetError(2, 0, 0)
	EndIf

	; Запись
	Local $sPathConnectorMin = @ScriptDir & '\Connector.au3'
	$hFile = FileOpen($sPathConnectorMin, 8 + 2)
	If $hFile = -1 Then
		MsgBox(4096, 'Error', 'Unable to open file ' & $sPathConnectorMin)
		Exit
	EndIf
	FileWrite($hFile, $sTextConnector)
	FileClose($hFile)

	ConsoleWrite('+ The connector is assembled into a script ' & $sPathConnectorMin & @CRLF)
	GUICtrlSetData($Button1, '------------')
	MsgBox(0, 'Connector Packager', 'The connector is assembled into a script ' & $sPathConnectorMin)

EndFunc   ;==>_Packer









