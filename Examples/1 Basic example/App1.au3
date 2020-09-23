
#include '..\..\Connector_Full.au3'

#include <GuiListView.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>

Global $DEBUG_CONNECTOR = 1; letting the connector show important messages in the console

Global $sThis_ID = 'App1'; Sender token
Global $sSend_ID = 'App2'; Recipient token

$aProgman = WinGetPos("[CLASS:Progman]")
Local $iLeft = StringRegExp($sThis_ID, '1$', 0) ? ($aProgman[2] / 2) - 585 : ($aProgman[2] / 2) + 5
Global $iRun = False, $ButtonStart, $ButtonStop, $ListViewOut, $ListViewIn

$Form1 = GUICreate("Form " & $sThis_ID, 574, 481, $iLeft, 111)
$GroupOut = GUICtrlCreateGroup("OUTBOX", 4, 8, 566, 197)
$ListViewOut = GUICtrlCreateListView("Type|Sent message|Type|Returned answer", 12, 28, 550, 169)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 75)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 165)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 75)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 205)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$GroupIn = GUICtrlCreateGroup("INBOX", 4, 212, 566, 209)
$ListViewIn = GUICtrlCreateListView("Sender|Type|Received message|Type|Returned response", 12, 232, 550, 181)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 50)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 75)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 75)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 4, 170)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonStart = GUICtrlCreateButton("Start sending", 100, 435, 180, 33)
$ButtonStop = GUICtrlCreateButton("Stop sending", 315, 435, 180, 33)
GUISetState(@SW_SHOW)

_Add_Member_Connector($sThis_ID); member registration
_Function_Receiver_Connector('_Receiver'); registers a function for handling incoming

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $ButtonStart
			AdlibRegister('_Send', 10)
		Case $ButtonStop
			AdlibUnRegister('_Send')
	EndSwitch
WEnd

Func _Send()
	Local Static $iTimer = 0
	Local Static $iRandom = 0

	If $iTimer And TimerDiff($iTimer) < $iRandom Then
		Return
	EndIf

	$iRandom = Random(1, 1000, 1)
	$iTimer = TimerInit()

	Local $vSendMessage
	; we generate test data randomly and with different types
	Local $iRnd = Random(11111, 99999, 1)
	Local $iRndType = Random(1, 10, 1)

	If $iRndType = 1 Then $vSendMessage = 'Message No.' & $iRnd
	If $iRndType = 2 Then $vSendMessage = $iRnd
	If $iRndType = 3 Then $vSendMessage = $iRnd + 2147472537
	If $iRndType = 4 Then $vSendMessage = $iRnd + Random(0, 0.9)
	If $iRndType = 5 Then $vSendMessage = Random(0, 1, 1) ? True : False
	If $iRndType = 6 Then $vSendMessage = StringToBinary($iRnd)
	If $iRndType = 7 Then $vSendMessage = $Form1
	If $iRndType = 8 Then $vSendMessage = Ptr(-1)
	If $iRndType = 9 Then $vSendMessage = Random(0, 1, 1) ? Default : Null
	If $iRndType = 10 Then $vSendMessage = _ArrCreator()

	Local $sSendType = VarGetType($vSendMessage), $vSendLV = $vSendMessage
	If IsKeyword($vSendMessage) And $vSendMessage = Null Then $vSendLV = 'Null'; for display in LIstView of the Keyword type with the Null parameter, so that there is no empty string

	; to output the array to $ ListViewOut
	If IsArray($vSendMessage) Then
		$sSendType &= _ArrayStringTypes($vSendMessage)
		$vSendLV = _ArrayStringVars($vSendMessage)
	EndIf

	_DelItemsLV($ListViewOut); restrict $ ListViewOut list if it's too big

	If VarGetType($vSendMessage) = 'Ptr' And HWnd($vSendMessage) Then $sSendType = 'hWnd'

	GUICtrlCreateListViewItem($sSendType & '|' & $vSendLV, $ListViewOut)

	Local $vResponse = _Send_Connector($vSendMessage, $sSend_ID);send message $ vSendMessage to $ sSend_ID
	Local $iErr = @error
	If $iErr Then
		Local $sRespType = 'Error'
		$vResponse = $iErr = 1 ? 'no recipient' : ($iErr = 2 ? 'the process did not start' : ($iErr = 3 ? 'there is no way' : ($iErr = 4 ? 'recipient thread is busy' : ($iErr = 5 ? 'DllCall error' : 'Apocalypse'))))
	Else
		Local $sRespType = VarGetType($vResponse)
	EndIf

	If IsKeyword($vResponse) And $vResponse = Null Then
		$vResponse = 'Null'
		$sRespType = 'Keyword'
	EndIf

	If IsArray($vResponse) Then
		$sRespType &= _ArrayStringTypes($vResponse)
		$vResponse = _ArrayStringVars($vResponse)
	EndIf

	If VarGetType($vResponse) = 'Ptr' And HWnd($vResponse) Then $sRespType = 'hWnd'

	Local $iLVLastInd = _GUICtrlListView_GetItemCount($ListViewOut) - 1
	_GUICtrlListView_AddSubItem($ListViewOut, $iLVLastInd, $sRespType, 2)
	_GUICtrlListView_AddSubItem($ListViewOut, $iLVLastInd, String($vResponse), 3)
	_GUICtrlListView_EnsureVisible($ListViewOut, $iLVLastInd)

EndFunc   ;==>_Send

Func _Receiver($vMsg, $sNameSender); Receive incoming function. Specified in _Function_Receiver_Connector
	Local $sType = VarGetType($vMsg), $vTextLVIn = String($vMsg), $vTextLVOut = $vTextLVIn
	If IsKeyword($vMsg) And $vMsg = Null Then $vTextLVIn = 'Null'

	If IsArray($vMsg) Then
		$sType &= _ArrayStringTypes($vMsg)
		$vTextLVIn = _ArrayStringVars($vMsg)
	EndIf

	$vTextLVOut = $vTextLVIn

	If $sType = 'String' Then
		$vTextLVIn = $vMsg
		$vMsg = 'Answer to ' & $vMsg
		$vTextLVOut = $vMsg
	EndIf

	_DelItemsLV($ListViewIn)

	If VarGetType($vMsg) = 'Ptr' And HWnd($vMsg) Then $sType = 'hWnd'

	GUICtrlCreateListViewItem($sNameSender & '|' & $sType & '|' & $vTextLVIn & '|' & $sType & '|' & $vTextLVOut, $ListViewIn)
	_GUICtrlListView_EnsureVisible($ListViewIn, _GUICtrlListView_GetItemCount($ListViewIn) - 1)
	Return $vMsg; Returning the reply to the sender
EndFunc   ;==>_Receiver


Func _ArrCreator($n=3)
	Local $aRet[$n]
	For $i=1 To $n
		$iRnd = Random(0, 2, 1)
		Local $aArr[3] = ["'" & _RndStr(Random(2,4,1)) & "'", Random(0, 1, 1) ? False : True, Random(0, 9, 1)]
		$aRet[$i-1] = $aArr[$iRnd]
	Next
	Return $aRet
EndFunc

Func _RndStr($i=1)
	Local $sRet
	For $k=1 to $i
		$sRet &= Chr(Random(65, 90, 1))
	Next
	Return $sRet
EndFunc

Func _DelItemsLV($ID)
	If _GUICtrlListView_GetItemCount($ID) > 50 Then
		_GUICtrlListView_DeleteItem($ID, 0)
	EndIf
EndFunc   ;==>_DelItemsLV

Func _ArrayStringTypes($aArray)
	Local $sTypes = '('
	For $i = 0 To UBound($aArray) - 1
		Local $sType = VarGetType($aArray[$i])
		$sTypes &= ($i ? ',' : '') & StringLower(StringLeft($sType, 1))
	Next
	Return $sTypes & ')'
EndFunc   ;==>_ArrayStringTypes

Func _ArrayStringVars($aArray)
	Local $sVars = '['
	For $i = 0 To UBound($aArray) - 1
		$sVars &= ($i ? ', ' : '') & $aArray[$i]
	Next
	Return $sVars & ']'
EndFunc   ;==>_ArrayStringVars
