
#include '..\..\Connector_Full.au3'

Global $DEBUG_CNMR = 1;letting the connector show important messages in the console

Global $sSend_ID = 'App2'; Recipient token

_Add_Member_Connector('App1'); participant registration
_Function_Receiver_Connector('_Receiver'); registers a function for handling incoming

Local $sMsg = 'Send message'
Local $sReturn

$sReturn = _Send_Connector($sMsg, $sSend_ID, Default, Default, 0, @ScriptDir & '\' & $sSend_ID & '.au3', 1); run the script, get the answer, and close it
MsgBox(0, 'Answer to the first request', 'To your message: ' & $sMsg & @CRLF & 'Received a response: ' & $sReturn & IsMember('au3'))

$sReturn = _Send_Connector($sMsg, $sSend_ID, Default, Default, 0, @ScriptDir & '\' & $sSend_ID & '.exe', 1); run the program, get the answer, and close it
MsgBox(0, 'Answer to the second request', 'To your message: ' & $sMsg & @CRLF & 'Received a response: ' & $sReturn & IsMember('exe'))

$sReturn = _Send_Connector($sMsg, $sSend_ID, Default, Default, 0, @ScriptDir & '\' & $sSend_ID & '.au3'); just run the script, we get the answer
MsgBox(0, 'Answer to the third request', 'To your message: ' & $sMsg & @CRLF & 'Received a response: ' & $sReturn & IsMember('au3'))

Func IsMember($iT='')
	Return _Is_Member_Connector($sSend_ID) ? @CRLF & 'Script ' & $sSend_ID & '.' & $iT & ' was not completed' : @CRLF & 'Script ' & $sSend_ID & '.' & $iT & ' was forcibly terminated'
EndFunc   ;==>IsMember
