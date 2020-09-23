
#include '..\..\Connector_Full.au3'

Global $DEBUG_CNMR = 1; letting the connector show important messages in the console

_Add_Member_Connector('App2'); member registration
_Function_Receiver_Connector('_Receiver'); registers a function for handling incoming

MsgBox(0, 'App2', 'Close this message to terminate App2')

Func _Receiver($vMsg, $sNameSender); Receive incoming function. Specified in _Function_Receiver_Connector
	Return 'Returned message';Returning the reply to the sender
EndFunc   ;==>_Receiver
