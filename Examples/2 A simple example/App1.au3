
#include '..\..\Connector_Full.au3'

Global $DEBUG_CNMR = 1; letting the connector show important messages in the console

Global $sThis_ID = 'App1'; Sender token
Global $sSend_ID = 'App2'; Recipient token

_Add_Member_Connector($sThis_ID); participant registration
_Function_Receiver_Connector('_Receiver'); registers a function for handling incoming

Local $sMsg = 'Hello!'
Local $vResponse = _Send_Connector($sMsg, $sSend_ID); sends message to $ sMsg, for $ sSend_ID
If @error = 1 Then
	MsgBox(0, $sThis_ID, 'Run the sender script ' & $sSend_ID & ' without closing this window')
Else
	MsgBox(0, 'Answer from ' & $sSend_ID, 'To your message: ' & $sMsg & @CRLF & 'Received a response: ' & $vResponse)
EndIf

Func _Receiver($vMsg, $sNameSender); Receive incoming function. Specified in _Function_Receiver_Connector
	Return 'Good day!'; Returning the reply to the sender
EndFunc   ;==>_Receiver


