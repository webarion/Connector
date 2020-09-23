#include-once

; # ABOUT THE LIBRARY # =========================================================================================================
; Name .............: Connector
; Current version ..: 2.0.1
; AutoIt Version ...: 3.3.14.5
; Description ......: Serves for data exchange between processes
; Author ...........: Webarion
; Links: ...........: http://webarion.ru, http://f91974ik.bget.ru
; Note .............: Supported Data Types: String, Int32, Int64, Double, Bool, Binary, Hwnd, Ptr, Keyword, Array
; Limitations ......: nested arrays are not supported, inside arrays
; ===============================================================================================================================
; # О БИБЛИОТЕКЕ # ==============================================================================================================
; Название .........: Connector
; Текущая версия ...: 2.0.1
; AutoIt Версия ....: 3.3.14.5
; Описание .........: Служит для обмена данными между процессами
; Автор ............: Webarion
; Сылки: ...........: http://webarion.ru, http://f91974ik.bget.ru
; Примечание .......: поддерживаемые типы данных: String, Int32, Int64, Double, Bool, Binary, Hwnd, Ptr, Keyword, Array
; Ограничения ......: не поддерживаются вложенные массивы, внутри массивов
; ===============================================================================================================================

#CS History 2.x.x. Version history:
	v2.0.1
		Minor code corrections.
	v2.0.0
    The first version of this thread
    The method of sending and receiving data has been completely updated. All declared data types are transferred in a structure according to their size.
    Added connector collector Packager.au3, which allows you to compress the library script or select the required functionality.
    Support for 5-dimensional arrays in the default version.
    Added the ability to change the number of supported array dimensions through the Packager.au3 collector
#CE History

#CS History 2.x.x. История версий:
	v2.0.1
		Небольшие корректировки кода.
	v2.0.0
    Первая версия этой ветки
    Полностью обновлён способ отправки и получения данных. Все заявленные типы данных передаются в структуре,соответственно своему размеру.
    Добавлен сборщик коннектора Packager.au3, позволяющий сжать скрипт библиотеки или выбрать необходимый функционал.
    Поддержка пятимерных массивов в версии по умолчанию.
    Добавлена возможность изменить количество поддерживаемых измерений массива через сборщик Packager.au3
#CE History

#include <WinApi.au3>
#include <Constants.au3>

#Region User variables. Пользовательские переменные
Global $DEFAULT_GROUP_ID_CONNECTOR = '_sDhCe7VyS' ; Default group ID. ID группы по умолчанию
Global $TIME_WAIT_RECEIVER_CONNECTOR = 5 ; Receiver timeout in seconds (when forced to wait and run along the specified path). Время ожидания получателя в секундах(при принудительном ожидании и запуске по указанному пути)
Global $DEBUG_CONNECTOR = 0
#EndRegion User variables. Пользовательские переменные

#Region  Internal variables. Внутренние системные переменные
Global $sgDefault_Receiver_Function_CNMR = '' ; this function will receive a response from all participants. в эту функцию будет приходить ответ от всех участников
Global $agReceiver_Function_From_Name_CNMR[0][2] ; the names of the registered functions, which will receive a response from the specified participants. имена зарегистрированных функций, в которые будет приходить ответ ОТ указанных участников
Global $agReceiver_Function_For_Name_CNMR[0][2] ; the names of the registered functions that will be answered by the specified participants. имена зарегистрированных функций, в которые будет приходить ответ ДЛЯ указанных участников
Global $sgID_CNMR = _Unical_CNMR() ; Common identifier of all members of the connector . Общий идентификатор всех участников коннектора
Global $sgDefaultSender_CNMR ; default sender, first registered sender. отправитель по умолчанию, первый зарегистрированный отправитель
#EndRegion Internal variables. Внутренние системные переменные

GUIRegisterMsg(0x004A, "_WM_COPYDATA_CNMR")

#Region User functions. Пользовательские функции
; #USER FUNCTION# ===============================================================================================================
; Description....: Changes the default group ID
; Parameters ....: $sNewID_DefGroup - New unique ID of the default group
; Note ..........: after the function is executed, all operations that do not specify their group ID will interact with participants who only have this ID

; Описание ......: Изменяет идентификатор дефолтной группы
; Параметры .....: $sNewID_DefGroup - Новый уникальный идентификатор дефолтной группы
;	Примечание ....: После выполнения функции, все операции, в которых не указан ID своей группы, будут взаимодействовать с участниками, имеющими только этот ID
; ===============================================================================================================================
Func _Set_Default_Group_ID_Connector($sNewID_DefGroup)
	$DEFAULT_GROUP_ID_CONNECTOR = $sNewID_DefGroup
	Return 1
EndFunc   ;==>_Set_Default_Group_ID_Connector

; #USER FUNCTION# ===============================================================================================================
; Description....: Returns the default group ID
; Описание ......: Возвращает ID дефолтной группы
; ===============================================================================================================================
Func _Get_Default_UnicalID_Connector()
	Return $DEFAULT_GROUP_ID_CONNECTOR
EndFunc   ;==>_Get_Default_UnicalID_Connector

; #USER FUNCTION# ===============================================================================================================
; Description ...: Registers a chat participant
; Parameters ....: $sNameMember - Name of the new member
;                  $sIDGroup            - Name of the group in which this member will be registered

; Описание ......: Регистрирует участника общения
; Параметры .....: $sNameMember         - Имя нового участника
;                  $sIDGroup            - Название группы, в которой будет зарегистрирован этот участник
; ===============================================================================================================================
Func _Add_Member_Connector($sNameMember, $sIDGroup = $DEFAULT_GROUP_ID_CONNECTOR)
	Local $sTitleMember = _GetUnicalName_CNMR($sNameMember, $sIDGroup)
	If Not WinExists($sTitleMember) Then
		Local $hMember = GUICreate($sTitleMember)
		If Not $sgDefaultSender_CNMR Then $sgDefaultSender_CNMR = $sNameMember
		If WinExists($sTitleMember) Then
			Return 1
		EndIf
		#Region IDB_CNMR
		If $DEBUG_CONNECTOR Then
			_debErr_CNMR('CONNECTOR')
			_debErr_CNMR('Error', 'Failed to register a member: ' & $sNameMember)
			_debErr_CNMR('For the group', $sIDGroup)
			_debSys_CNMR('The event function', '_Add_Member_Connector')
			_debErr_CNMR()
		EndIf
		#EndRegion IDB_CNMR
		Return SetError(1, 0, 0)
	EndIf
	Return 0
EndFunc   ;==>_Add_Member_Connector

; #USER FUNCTION# ===============================================================================================================
; Description.....: Set the lead participant(sender)
; Parameters ....: $sNameMember - host name
; Note ..........: if the sender's name is not specified in the message being sent, the lead participant(sender) will always be,
;                : first registered via _Add_Member_Connector(...)
;                : but by applying this method, the lead participant becomes $sNameMember
;                : This feature is required for participants loaded in the same script, for example via #include,
;                : when there is a need to assign a default sender.
;                : If the participants are in different processes, then this is not necessary.

; Описание ......: Установить ведущего участника(отправителя)
; Параметры .....: $sNameMember - имя ведущего
;	Примечание ....: Если в отправляемом сообщении не указано имя отправителя, то ведущим участником(отправителем), всегда будет являться,
;								 : первый зарегистрированный через _Add_Member_Connector(...)
;								 : но, применив этот метод, ведущим участником становится $sNameMember
;								 : Эта возможность, необходима для участников, загруженных в одном скрипте, например через #include,
;								 : когда есть необходимость назначить отправителя по умолчанию.
;								 : Если же участники находятся в разных процессах, то такой необходимости нет.
; ===============================================================================================================================
Func _Main_Member_Connector($sNameMember)
	$sgDefaultSender_CNMR = $sNameMember
	Return 1
EndFunc   ;==>_Main_Member_Connector

; #USER FUNCTION# ===============================================================================================================
; Description ...: checks the existence of a member in a particular gupp
; Parameters ....: $sName     - member name
;                  $sIDGroup  - name of the group

; Описание ......: проверяет существование участника в определённой гуппе
; Параметры .....: $sName			- имя участника
;                  $sIDGroup	- имя группы
; ===============================================================================================================================
Func _Is_Member_Connector($sName, $sIDGroup = $DEFAULT_GROUP_ID_CONNECTOR)
	Return WinExists(_GetUnicalName_CNMR($sName, $sIDGroup))
EndFunc   ;==>_Is_Member_Connector

; #USER FUNCTION# ===============================================================================================================
; Description ...: Returns the ID of all groups
; Parameters ....: $iTypeRet = 0 - give an array(by default), otherwise a string

; Описание ......: Возвращает ID всех групп
; Параметры .....: $iTypeRet = 0 - отдать массив(по умолчанию), иначе строку
; ===============================================================================================================================
Func _All_Groups_Connector($iTypeRet = 0)
	Return _List_Members_CNMR($iTypeRet)
EndFunc   ;==>_All_Groups_Connector

; #USER FUNCTION# ===============================================================================================================
; Description....: Returns a list of all participants, in all groups
; Parameters ....: $iTypeRet = 0 - give an array(by default), otherwise a string

; Описание ......: Возвращает список всех участников, во всех группах
; Параметры .....: $iTypeRet = 0 - отдать массив(по умолчанию), иначе строку
; ===============================================================================================================================
Func _All_Members_Connector($iTypeRet = 0)
	Return _List_Members_CNMR($iTypeRet, 1)
EndFunc   ;==>_All_Members_Connector

; #USER FUNCTION# ===============================================================================================================
; Description ...: Returns a list of members of the specified group
; Parameters ....: $sIDGroup - name of the group. If omitted, the list of group members is returned, by default
;                  $iTypeRet = 0 - return an array(by default), otherwise a string

; Описание ......: Возвращает список участников, указанной группы
; Параметры .....: $sIDGroup - имя группы. Если не указано, возвращается список участников группы, по умолчанию
;                  $iTypeRet = 0 - отдать массив(по умолчанию), иначе строку
; ===============================================================================================================================
Func _Members_Group_Connector($sIDGroup = $DEFAULT_GROUP_ID_CONNECTOR, $iTypeRet = 0)
	Return _List_Members_CNMR($iTypeRet, 2, $sIDGroup)
EndFunc   ;==>_Members_Group_Connector

; #USER FUNCTION# ================================================================================================================================================
; Description ...: Registers a function for all incoming messages
; Parameters ....: $sFuncName - function name
; Note ..........: applies to all participants registered in the same script.
;                : If, in the same script, _Add_Member_Connector('App-1') and _Add_Member_Connector('App-n')were applied
;                : then, all incoming messages for them will be sent to the function assigned by this method
;                : If you need to distribute incoming messages among participants in a single script, the receivers must be registered via _Function_For_Receiver_Connector(...)

; Описание ......: Регистрирует функцию для всех входящих сообщений
; Параметры .....: $sFuncName - имя функции
; Примечание ....: распространяется для всех участников, зарегистрированных в одном скрипте.
;                : Если, в одном скрипте, было применено _Add_Member_Connector('App-1') и _Add_Member_Connector('App-n')
;                : то, все входящие для них, будут приходить, в функцию, назначенную этим методом
;								 : Если необходимо распределить входящие по участникам в одном скрипте, приёмники нужно регистрировать через _Function_For_Receiver_Connector(...)
; ================================================================================================================================================================
Func _Function_Receiver_Connector($sFuncName)
	#Region IDB_CNMR
	If $sgDefault_Receiver_Function_CNMR And $DEBUG_CONNECTOR Then
		_debWar_CNMR('CONNECTOR')
		_debWar_CNMR('Warning', 'the default recipient function was re-registered')
		_debWar_CNMR('Old function', $sgDefault_Receiver_Function_CNMR & ' - no longer relevant')
		_debWar_CNMR('The actual receiver', $sFuncName)
		_debSys_CNMR('Default group', $DEFAULT_GROUP_ID_CONNECTOR)
		_debSys_CNMR('The current script', @ScriptFullPath)
		_debSys_CNMR('The event function', '_Function_Receiver_Connector')
		_debWar_CNMR()
	EndIf
	#EndRegion IDB_CNMR
	$sgDefault_Receiver_Function_CNMR = $sFuncName
EndFunc   ;==>_Function_Receiver_Connector

; #USER FUNCTION# ===============================================================================================================
; Description ...: Registers a function for incoming messages from a specific sender
; Parameters ....: $sFuncReceiverName  - function Name
;                  $sSenderName        - Name of the participant whose data will be sent to this function
;                  if there is no $sSenderName, the function is registered for all incoming calls

; Описание ......: Регистрирует функцию для входящих сообщений, ОТ определённого отправителя
; Параметры .....: $sFuncReceiverName  - Название функции
;                  $sSenderName        - Имя участника, данные от которого, будут отправлены в эту функцию
;									 если нет $sSenderName, то функция регистрируется для всех входящих
; ===============================================================================================================================
Func _Function_From_Sender_Connector($sFuncReceiverName, $sSenderName)
	If $sFuncReceiverName And $sSenderName Then
		For $i = 0 To UBound($agReceiver_Function_From_Name_CNMR) - 1
			If $sSenderName = $agReceiver_Function_From_Name_CNMR[$i][0] Then
				$agReceiver_Function_From_Name_CNMR[$i][1] = $sFuncReceiverName
				ExitLoop
			EndIf
		Next
		If $i >= UBound($agReceiver_Function_From_Name_CNMR) Then
			ReDim $agReceiver_Function_From_Name_CNMR[UBound($agReceiver_Function_From_Name_CNMR) + 1][2]
			$agReceiver_Function_From_Name_CNMR[UBound($agReceiver_Function_From_Name_CNMR) - 1][0] = $sSenderName
			$agReceiver_Function_From_Name_CNMR[UBound($agReceiver_Function_From_Name_CNMR) - 1][1] = $sFuncReceiverName
		EndIf
		Return 1
	EndIf
	Return 0
EndFunc   ;==>_Function_From_Sender_Connector

; #USER FUNCTION# =====================================================================================================================
; Description....: Registers a function for incoming messages, FOR a specific recipient
; Parameters ....: $sFuncReceiverName  - function Name
;                  $sReceiverName      - Name of the participant whose data will be sent to this function
; Note ....      : the function has the highest priority over _Function_Receiver_Connector and _Function_From_Sender_Connector

; Описание ......: Регистрирует функцию для входящих сообщений, ДЛЯ определённого получателя
; Параметры .....: $sFuncReceiverName  - Название функции
;                  $sReceiverName      - Имя участника, данные для которого, будут отправлены в эту функцию
; Примечание ....: функция имеет самый высокий приоритет по отношению к _Function_Receiver_Connector и _Function_From_Sender_Connector
; =====================================================================================================================================
Func _Function_For_Receiver_Connector($sFuncReceiverName, $sReceiverName)
	If $sFuncReceiverName And $sReceiverName Then
		For $i = 0 To UBound($agReceiver_Function_For_Name_CNMR) - 1
			If $sReceiverName = $agReceiver_Function_For_Name_CNMR[$i][0] Then
				$agReceiver_Function_For_Name_CNMR[$i][1] = $sFuncReceiverName
				ExitLoop
			EndIf
		Next
		If $i >= UBound($agReceiver_Function_For_Name_CNMR) Then;
			ReDim $agReceiver_Function_For_Name_CNMR[UBound($agReceiver_Function_For_Name_CNMR) + 1][2]
			$agReceiver_Function_For_Name_CNMR[UBound($agReceiver_Function_For_Name_CNMR) - 1][0] = $sReceiverName
			$agReceiver_Function_For_Name_CNMR[UBound($agReceiver_Function_For_Name_CNMR) - 1][1] = $sFuncReceiverName
		EndIf
		Return 1
	EndIf
	Return 0
EndFunc   ;==>_Function_For_Receiver_Connector

; #USER FUNCTION# ===============================================================================================================
; Description ...: Sends a message by the specified ID
; Parameters ....: $vData Message
;                  $sReceiverName         - name of the recipient
;                  $sSenderName           - sender's name
;                  $sIDGroup              - recipient's group
;                  $iWaitForReceiver      - whether to wait for the recipient. 1 - wait for the time set in $TIME_WAIT_RECEIVER_CONNECTOR
;                  $sPathProcess          - path to the process
;                  $iCloseReceiverProcess - 1 if the user being accessed must log out after execution

; Описание ......: Отправляет сообщение по указанному идентификатору
; Параметры .....: $vData               	- Сообщение
;									 $sReceiverName					- Имя получателя
;								 	 $sSenderName       		- Имя отправителя
;									 $sIDGroup							- группа получателя
;									 $iWaitForReceiver			- ожидать ли получателя. 1 - ожидать заданное в $TIME_WAIT_RECEIVER_CONNECTOR время
;                  $sPathProcess        	- Путь к процессу
;									 $iCloseReceiverProcess	- 1 если участник, к которому обращаемся должен выйти из системы после выполнения
; ===============================================================================================================================
Func _Send_Connector($vData, $sReceiverName, $sSenderName = Default, $sIDGroup = Default, $iWaitForReceiver = 0, $sPathProcess = '', $iCloseReceiverProcess = 0)

	If $sSenderName = Default Then $sSenderName = $sgDefaultSender_CNMR
	If $sIDGroup = Default Then $sIDGroup = $DEFAULT_GROUP_ID_CONNECTOR

	_Add_Member_Connector($sSenderName, $sIDGroup)

	Local $sSenderTitle = _GetUnicalName_CNMR($sSenderName, $sIDGroup)
	Local $sReceiverTitle = _GetUnicalName_CNMR($sReceiverName, $sIDGroup)

	If $sPathProcess <> '' Then
		If Not FileExists($sPathProcess) Then
			#Region IDB_CNMR
			If $DEBUG_CONNECTOR Then
				_debErr_CNMR('CONNECTOR')
				_debErr_CNMR('Error', 'The specified path does not exist')
				_debWar_CNMR('Path', $sPathProcess)
				_debSys_CNMR('The event function', '_Send_Connector')
				_debErr_CNMR()
			EndIf
			#EndRegion IDB_CNMR
			Return SetError(3, 0, 0)
		Else
			; Если указан путь к процессу и он не запущен, то попытаемся его запустить
			If Not WinExists($sReceiverTitle) Then
				Local $sRun = (StringRegExp($sPathProcess, '\.au3$', 0)) ? @AutoItExe & ' /AutoIt3ExecuteScript "' & $sPathProcess & '"' : $sPathProcess
				Local $iPID = Run($sRun, '', '', 2 + 4)
				If Not ProcessWait($iPID, 10) Then
					#Region IDB_CNMR
					If $DEBUG_CONNECTOR Then
						_debErr_CNMR('CONNECTOR')
						_debErr_CNMR('Error', 'The specified recipient process could not be started ' & $sReceiverName)
						_debWar_CNMR('Through a process', $sPathProcess)
						_debSys_CNMR('The event function', '_Send_Connector')
						_debErr_CNMR()
					EndIf
					#EndRegion IDB_CNMR
					Return SetError(2, 0, 0)
				EndIf
				$iWaitForReceiver = 1
			EndIf
		EndIf
	EndIf

	Local $iErr
	If $iWaitForReceiver Then
		If Not WinWait($sReceiverTitle, '', $TIME_WAIT_RECEIVER_CONNECTOR) Then $iErr = 1
	Else
		If Not WinExists($sReceiverTitle) Then $iErr = 1
	EndIf

	If $iErr Then
		#Region IDB_CNMR
		If $DEBUG_CONNECTOR Then
			_debErr_CNMR('CONNECTOR')
			_debErr_CNMR('Error', 'The system does not have a member with the name ' & $sReceiverName)
			_debWar_CNMR('', 'To be able to communicate with this member, they must be registered')
			_debOky_CNMR('Example for the default group', "_Add_Member_Connector('" & $sReceiverName & "')")
			_debOky_CNMR('For certain groups', "_Add_Member_Connector('" & $sReceiverName & "', 'My Group')")
			_debSys_CNMR('The script that started Connector', @ScriptFullPath)
			_debSys_CNMR('The event function', '_Send_Connector')
			_debErr_CNMR()
		EndIf
		#EndRegion IDB_CNMR
		Return SetError(1, 0, 0)
	EndIf

	Local $hWndSender = WinGetHandle($sSenderTitle)
	Local $hWndReceiver = WinGetHandle($sReceiverTitle)

	; если отправитель и получатель зарегистрированы в одном процессе
	If WinGetProcess($hWndSender) = WinGetProcess($hWndReceiver) Then
		Return _Caller_CNMR($vData, $hWndReceiver, $hWndSender)
	EndIf

	Local $tStructData, $tCopyData, $tRetStruct

	$tStructData = _VarToStruct_CNMR($vData)

	$tRetStruct = DllStructCreate('ptr pRetData')

	$tCopyData = DllStructCreate('ulong_ptr pReturn;dword iSize;ptr pStr')
	DllStructSetData($tCopyData, 'pReturn', DllStructGetPtr($tRetStruct))
	DllStructSetData($tCopyData, 'iSize', DllStructGetSize($tStructData))
	DllStructSetData($tCopyData, 'pStr', DllStructGetPtr($tStructData))

	Local $aRet, $vReturn = 0
	$aRet = DllCall('user32.dll', 'lresult', 'SendMessageW', 'hwnd', $hWndReceiver, 'uint', 0x004A, 'hwnd', $hWndSender, 'ptr', DllStructGetPtr($tCopyData))
	$iErr = @error
	Local $iPID_Receiver = WinGetProcess($sReceiverTitle)
	If $iCloseReceiverProcess Then ProcessClose($iPID_Receiver) ; если есть команда завершить процесс, то завершаем его

	If IsArray($aRet) Then

		If $aRet[0] = 0 Then Return SetError(4, 0, 0)
		If $aRet[0] = 123120 Then Return SetError(6, 0, 0)

		Local $pRetData = Ptr(DllStructGetData($tRetStruct, 'pRetData'))

		Local $vReturn = _StructToVar_CNMR($pRetData, $iPID_Receiver)

	EndIf

	Return SetError(($iErr ? 5 : 0), 0, $vReturn)
EndFunc   ;==>_Send_Connector
#EndRegion User functions. Пользовательские функции


#Region Internal functions. Внутренние системные функции

; #SYSTEM FUNCTION# ===========================================================================================================
; Description ...: The recipient. Triggered when a message arrives
; Описание ......: Получатель. Срабатывает, когда приходит сообщение
; =============================================================================================================================
Func _WM_COPYDATA_CNMR($hWndThisReceiver, $msgID, $hWndSender, $lParam)
	Local $sReceiverFunc, $vRetData
	Local $tCopyData, $pData
	$tCopyData = DllStructCreate('ulong_ptr pRet;dword iSize;ptr pData', $lParam)
	$pReturn = DllStructGetData($tCopyData, 'pRet')
	$pData = DllStructGetData($tCopyData, 'pData')
	Local $vTextSender = _StructToVar_CNMR($pData)
	$vRetData = _Caller_CNMR($vTextSender, $hWndThisReceiver, $hWndSender)
	$tStructReturn = _VarToStruct_CNMR($vRetData)
	Local $Return = _WriteProcessMemory_CNMR(WinGetProcess($hWndSender), $pReturn, DllStructGetPtr($tStructReturn))
	If $Return Then Return $Return
	Return 123120
EndFunc   ;==>_WM_COPYDATA_CNMR


; #SYSTEM FUNCTION# =============================================================================================================
; Description .: Returns a structure created from a variable
; Описание ....: Возвращает структуру, созданную из переменной
; ===============================================================================================================================
Func _VarToStruct_CNMR($vData)

	Local $iType = _VarToType_CNMR($vData), $iLen = ''
	Local $sStartStruct = 'align 1;dword;uint;'
	If $iType > 0 And $iType < 10 Then ; обрабатываем всё, кроме массива

		Local $sVarStruct = $sStartStruct & 'byte;'
		Switch $iType
			Case 1, 6
				$sVarStruct &= 'uint;'
		EndSwitch
		$sVarStruct &= _VarToStrStruct_CNMR($vData); & ';'
		Local $tStructVar = DllStructCreate($sVarStruct)
		DllStructSetData($tStructVar, 3, $iType)
		Switch $iType
			Case 1, 6
				DllStructSetData($tStructVar, 4, _VarLen_CNMR($vData))
				DllStructSetData($tStructVar, 5, _VarStructVar_CNMR($vData))
			Case Else
				DllStructSetData($tStructVar, 4, _VarStructVar_CNMR($vData))
		EndSwitch
		DllStructSetData($tStructVar, 2, DllStructGetSize($tStructVar))
		Return $tStructVar
	EndIf
#Region ARR_CNMR
	; Создаём структуру для массива.
	; Схема структуры:
	; [Тип(byte)|Кол.измер.(byte)|Кол.элем.в каждом измер.(d1(uint),d2,..)|Шаблон типов(на каждый тип 4 бит)(t1(uint содержит 8 типов),t2,..)|Длины строковых элем.(l1(uint),l2,...)|Непосредственные данные массива]
	; Пример:
	;	структура и данные для массива: ['qwe'   ,1  ,True  ,'asdfg' , Default] - массив
	; [byte;byte;uint;uint ;uint;uint; wchar[3];int;binary;wchar[5]; byte   ] - структура
	;	[10  ;1   ;5   ;75033;3   ;5   ; qwe     ;1  ;1     ;asdfg   ;1       ] - данные, записываемые в структуру, описывающие массив
	; 10 - означает, что последующая структура, описывает массив
	; 1 - это одномерный массив
	;	5 - количество элементов в первой мерности массива
	; - 75033 - каждые 4 бита этого числа указывают на тип элемента массива. В шестнадцатиричной системе более понятно - например Hex(75033)=12519, а это (1=String,2=Int,5=Bool,1=String,9=Keyword)
	; - 3 - длина первой строки 'qwe' в массиве
	; - 5 - длина второй строки 'asdfg' в массиве
	; - qwe - этот элемент и далее, непосредственные данные массива
If $iType = 10 Then
	Local $iDimsArr = UBound($vData, 0), $iMainCicle = UBound($vData, 1), $iOffset = 0

	Local $sMainArrStruct = $sStartStruct & 'byte;byte;', $sStructLens, $sStructArrData
	Local $aMainArrData[4 + $iDimsArr] = [0, 0, 10, $iDimsArr], $aArrLine[0], $aDataLens[0], $aTypes[0], $aCounts[0], $aDims[0], $aVarInfo
	Local $vArrDataItem
	For $i = 1 To $iDimsArr
		$sMainArrStruct &= 'uint;'
		Local $iDimCount = UBound($vData, $i)
		_ArrayAdd_CNMR($aCounts, $iDimCount)
		_ArrayAdd_CNMR($aDims, 0)
		$aMainArrData[3 + $i] = $iDimCount
		If $i > 1 Then $iMainCicle *= $iDimCount
	Next

	For $m = 0 To $iMainCicle - 1
		$sArrData = '$vData'
		For $r = 0 To UBound($aDims) - 1
			$sArrData &= '[' & $aDims[$r] & ']'
		Next
		$vArrDataItem = Execute($sArrData)
		$iType = _VarToType_CNMR($vArrDataItem)
		$iLen = _VarLen_CNMR($vArrDataItem)

		$sStructArrData &= _VarToStrStruct_CNMR($vArrDataItem) & ';'

		_ArrayAdd_CNMR($aArrLine, _VarStructVar_CNMR($vArrDataItem))
		If $iLen Then
			$sStructLens &= 'uint;'
			_ArrayAdd_CNMR($aDataLens, $iLen)
		EndIf
		$iOffset = BitOR(BitShift($iOffset, -4), $iType)
		If BitAND($iOffset, -268435456 ) Then ; Dec('F0000000')
			_ArrayAdd_CNMR($aMainArrData, $iOffset)
			$sMainArrStruct &= 'uint;'
			$iOffset = 0
		EndIf
		For $i = 0 To $iDimsArr - 1
			If $i < 1 Then
				$aDims[0] += 1
			ElseIf $aDims[$i - 1] > $aCounts[$i - 1] - 1 Then
				$aDims[$i - 1] = 0
				$aDims[$i] += 1
			EndIf
		Next
	Next
	If $iOffset Then
		_ArrayAdd_CNMR($aMainArrData, $iOffset)
		$sMainArrStruct &= 'uint;'
	EndIf
	$sMainArrStruct &= $sStructLens & StringTrimRight($sStructArrData, 1)
	For $i = 0 To UBound($aDataLens) - 1
		_ArrayAdd_CNMR($aMainArrData, $aDataLens[$i])
	Next
	For $i = 0 To UBound($aArrLine) - 1
		_ArrayAdd_CNMR($aMainArrData, $aArrLine[$i])
	Next

	Local $tStructArr = DllStructCreate($sMainArrStruct)
	For $i = 0 To UBound($aMainArrData) - 1
		DllStructSetData($tStructArr, $i + 1, $aMainArrData[$i])
	Next

	DllStructSetData($tStructArr, 2, DllStructGetSize($tStructArr)); добавляем размер всей структуры
	Return $tStructArr
	EndIf
	#EndRegion ARR_CNMR
	ConsoleWrite('- Connector(_VarToStruct_CNMR): data type ' & VarGetType($vData) & ' not support!' & @CRLF)
	Return SetError(1, 0, 0)
EndFunc   ;==>_VarToStruct_CNMR

; #SYSTEM FUNCTION# =============================================================================================================
; Description .: Returns a variable from the structure
; Описание ....: Возвращает переменную из структуры
; ===============================================================================================================================
Func _StructToVar_CNMR($pPtrContainer, $iPID = 0)
	Local $tStructContainer, $iType, $iLen, $hProcess

	If $iPID Then $hProcess = _OpenProcess_CNMR($iPID)
	If @error Then Return SetError(@error, 1, 0)

	Local $tStructTmp = _StructCreator_CNMR($hProcess, $pPtrContainer, 'align 1;dword;uint')
	Local $iSize = DllStructGetData($tStructTmp, 2); размер всей структуры в байтах

	$pPtrContainer += DllStructGetSize($tStructTmp)
	$tStructContainer = _StructCreator_CNMR($hProcess, $pPtrContainer, 'byte[' & $iSize & ']')
	$pPtrContainer = DllStructGetPtr($tStructContainer)

	If $hProcess Then _CloseProcess_CNMR($hProcess)

	$tStructTmp = DllStructCreate('byte', $pPtrContainer)
	$iType = DllStructGetData($tStructTmp, 1); тип данных

	If $iType > 0 And $iType < 10 Then ; работаем над всем, что не массив
		Switch $iType
			Case 1, 6 ; если строка, или бинарные данные
				$pPtrContainer += 1 ; DllStructGetSize($tStructTmp)
				$tStructTmp = DllStructCreate('align 1;uint', $pPtrContainer)
				$iLen = DllStructGetData($tStructTmp, 1)
		EndSwitch
		$pPtrContainer += DllStructGetSize($tStructTmp)
		$sStructTmp = 'align 1;' & _TypeTosStruct_CNMR($iType, $iLen)
		$tStructTmp = DllStructCreate($sStructTmp, $pPtrContainer)
		Local $vRetData = _sDataStructToVariant_CNMR(DllStructGetData($tStructTmp, 1), $iType)
		Return $vRetData
	EndIf
#Region ARR_CNMR
	If $iType = 10 Then ; если тип является массивом, извлекаем его из памяти

		$pPtrContainer += 1

		Local $tStructTmp = DllStructCreate('align 1;byte', $pPtrContainer)
		Local $iDims = DllStructGetData($tStructTmp, 1); количество измерений массива
		$pPtrContainer += DllStructGetSize($tStructTmp)

		$sStructTmp = 'align 1;' & StringTrimRight(_Copier_CNMR('uint;', $iDims), 1)
		Local $tStructTmp = DllStructCreate($sStructTmp, $pPtrContainer)

		Local $aCounts[0]
		$iLen = 1
		For $i = 1 To $iDims ; определяем количество элементов в каждом измерении
			_ArrayAdd_CNMR($aCounts, DllStructGetData($tStructTmp, $i))
			$iLen *= $aCounts[$i - 1] ; количество всех элементов
		Next

		Local $iBitsItems = Ceiling($iLen / 8); количество элементов отведённое на шаблон типов(1 тип в массиве, 4 бит. 1 uint содержит типы 8-ми элементов массива)

		$pPtrContainer += DllStructGetSize($tStructTmp)

		$sStructTmp = 'align 1;' & StringTrimRight(_Copier_CNMR('uint;', $iBitsItems), 1)
		$tStructTmp = DllStructCreate($sStructTmp, $pPtrContainer)

		Local $aTmpl[0]
		For $i = 1 To $iBitsItems ; получаем из памяти битовый шаблон типов
			_ArrayAdd_CNMR($aTmpl, DllStructGetData($tStructTmp, $i))
		Next

		; извлекаем типы элементов массива
		Local $aTypes[0], $iIsLens = 0, $sStructLens, $iOffset
		For $i = 0 To UBound($aTmpl) - 1
			For $b = 1 To 8
				$iOffset = Dec(StringMid(Hex($aTmpl[$i], 8), $b, 1))
				If $iOffset Then
					_ArrayAdd_CNMR($aTypes, $iOffset)
					Switch $iOffset
						Case 1, 6
							$iIsLens += 1
					EndSwitch
				EndIf
			Next
		Next

		; получаем длины строковых и бинарных элементов
		If $iIsLens Then
			$pPtrContainer += DllStructGetSize($tStructTmp)
			$sStructTmp = 'align 1;' & StringTrimRight(_Copier_CNMR('uint;', $iIsLens), 1)
			$tStructTmp = DllStructCreate($sStructTmp, $pPtrContainer)
			Local $aLens[0]
			For $i = 0 To $iIsLens - 1
				_ArrayAdd_CNMR($aLens, DllStructGetData($tStructTmp, $i + 1))
			Next

		EndIf

		; собираем структуру для чтения элементов массива
		$n = 0
		$sStructTmp = 'align 1;'
		For $i = 0 To UBound($aTypes) - 1
			$iType = $aTypes[$i]
			Switch $iType
				Case 1, 6 ; если строка или бинарные данные
					$sStructTmp &= _TypeTosStruct_CNMR($iType, $aLens[$n]) & ';'
					$n += 1
				Case Else
					$sStructTmp &= _TypeTosStruct_CNMR($iType) & ';'
			EndSwitch
		Next

		$pPtrContainer += DllStructGetSize($tStructTmp)

		$sStructTmp = StringTrimRight($sStructTmp, 1)
		$tStructTmp = DllStructCreate($sStructTmp, $pPtrContainer)

		Local $aData[0]
		For $i = 0 To UBound($aTypes) - 1 ; извлекаем данные
			Local $sData = DllStructGetData($tStructTmp, $i + 1)
			_ArrayAdd_CNMR($aData, _sDataStructToVariant_CNMR($sData, $aTypes[$i]))
		Next

		$tStructTmp = 0 ; освобождаем структуры, все данные из них уже получены
		$tStructContainer = 0

		Local $aRet = _ArrCreator_CNMR($aCounts)

		Local $aDims[0]
		For $i = 1 To $iDims
			_ArrayAdd_CNMR($aDims, 0)
		Next

		For $m = 0 To $iLen - 1
			_ArrDxAdd_CNMR($aRet, $aDims, $aData[$m])
			For $i = 0 To $iDims - 1
				If $i < 1 Then
					$aDims[0] += 1
				ElseIf $aDims[$i - 1] > UBound($aRet, $i) - 1 Then
					$aDims[$i - 1] = 0
					$aDims[$i] += 1
				EndIf
			Next
		Next
		Return $aRet
	EndIf
	#EndRegion ARR_CNMR
	ConsoleWrite('- Connector(_StructToVar_CNMR): data type with number ' & $iType & ' not support!' & @CRLF)
	Return SetError(1, 0, 0)
EndFunc   ;==>_StructToVar_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: clones the string $sData, $iCount once
; Описание ....: клонирует строку $sData, $iCount раз
; =============================================================================================================================
Func _Copier_CNMR($sData, $iCount)
	Return StringReplace(StringFormat('%' & $iCount & 's', ''), ' ', $sData, 0, 2)
EndFunc   ;==>_Copier_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: returns the length of a variable based on its type (for a structure)
; Описание ....: возвращает длину переменной, исходя из её типа (для структуры)
; =============================================================================================================================
Func _VarLen_CNMR($vVar)
	Local $iType = _VarToType_CNMR($vVar)
	If $iType = 1 Then Return StringLen($vVar)
	If $iType = 6 Then Return BinaryLen($vVar)
	Return 0
EndFunc   ;==>_VarLen_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: prepares a variable for writing to the structure
; Описание ....: подготавливает переменную для записи в структуру
; =============================================================================================================================
Func _VarStructVar_CNMR($vVar)
	Local $iType = _VarToType_CNMR($vVar)
	If $iType = 5 Then $vVar = ($vVar = True) ? 1 : 0
	If $iType = 9 Then $vVar = ($vVar = Default) ? 1 : 0
	Return $vVar
EndFunc   ;==>_VarStructVar_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: returns the type of the variable
; Описание ....: возвращает тип переменной
; =============================================================================================================================
Func _VarToType_CNMR($vVar)
	Local $sVarTypes = 'String-Int32--Int64--Double-Bool---Binary-Hwnd---Ptr----KeywordArray'
	Local $sType = VarGetType($vVar)
	Local $iPos = StringInStr($sVarTypes, $sType, 1)
	If Not $iPos Then
		ConsoleWrite('! Тип ' & $sType & ' не поддерживается' & @CRLF)
		Return SetError(1, 0, 0)
	EndIf
	$iType = StringReplace((($iPos - 1) / 7) + 1, '-', '')
	If $iType = 8 And HWnd($vVar) Then $iType = 7
	Return $iType
EndFunc   ;==>_VarToType_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: returns a representation of the structure based on the type
; Описание ....: возвращает представление структуры исходя из типа
; =============================================================================================================================
Func _TypeTosStruct_CNMR($iType, $iLen = 0)
	Local $aStruct[10] = ['wchar', 'int', 'int64', 'double', 'boolean', 'byte', 'hwnd', 'ptr', 'byte', 'array']
	If $iType < 1 Or $iType > UBound($aStruct) Then
		ConsoleWrite('! Тип с номером ' & $iType & 'не поддерживается' & @CRLF)
		Return SetError(1, 0, 0)
	EndIf
	$sRetStruct = $aStruct[$iType - 1]
	Switch $iType
		Case 1, 6
			If $iLen > 1 Then $sRetStruct &= '[' & $iLen & ']'
	EndSwitch
	Return $sRetStruct
EndFunc   ;==>_TypeTosStruct_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: returns a representation of the structure based on a variable
; Описание ....: возвращает представление структуры исходя из переменной
; =============================================================================================================================
Func _VarToStrStruct_CNMR($vVar)
	Local $aStruct[10] = ['wchar', 'int', 'int64', 'double', 'boolean', 'byte', 'hwnd', 'ptr', 'byte', 'array']
	Local $iType = _VarToType_CNMR($vVar)
	$sRetStruct = $aStruct[$iType - 1]
	Local $sLen = ''
		If $iType = 1 Then $sLen = '[' & StringLen($vVar) & ']'
		If $iType = 6 Then $sLen &= '[' & BinaryLen($vVar) & ']'
	Return $sRetStruct & $sLen
EndFunc   ;==>_VarToStrStruct_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: returns a variable based on data extracted from the structure and the specified type
; Описание ....: возвращает переменную, исходя из данных извлечённых из структуры и указанного типа
; =============================================================================================================================
Func _sDataStructToVariant_CNMR($sData, $iType)
	Local $aConv = [String($sData), Number($sData), Number($sData), Number($sData), (($sData = 1) ? True : False), Binary($sData), HWnd($sData), Ptr($sData), (($sData = 1) ? Default : Null)]
	If $iType > UBound($aConv) + 1 Then SetError(1, 0, 0)
	Return $aConv[$iType - 1]
EndFunc   ;==>_sDataStructToVariant_CNMR

#Region ARR_CNMR
; #SYSTEM FUNCTION# ===========================================================================================================
; Description ....: adds $vVar to the end of a one-dimensional array
; Описание ....: добавляет $vVar в конец одномерного массива
; =============================================================================================================================
Func _ArrayAdd_CNMR(ByRef $aArray, $vVar)
	ReDim $aArray[UBound($aArray) + 1]
	$aArray[UBound($aArray) - 1] = $vVar
	Return $aArray
EndFunc   ;==>_ArrayAdd_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: creates an x-dimensional array based on parameters
; Note ........: 5-dimensional arrays are supported by default. If necessary, reduce or increase the number of dimensions
;              : array, run Packager.au3, specify the required number of dimensions, and assemble the connector

; Описание ....: создаёт x-мерный массив, исходя из параметров
; Примечание ..: по умолчанию поддерживаются 5-мерные массивы. При необходимости уменьшить или увеличить количество измерений
;              : массива, запустите Packager.au3, укажите необходимое количество измерений и соберите коннектор
; =============================================================================================================================
Func _ArrCreator_CNMR($a)
	Local $i = UBound($a)
		If $i = 1 Then Dim $r[$a[0]]
		If $i = 2 Then Dim $r[$a[0]][$a[1]]
		If $i = 3 Then Dim $r[$a[0]][$a[1]][$a[2]]
		If $i = 4 Then Dim $r[$a[0]][$a[1]][$a[2]][$a[3]]
		If $i = 5 Then Dim $r[$a[0]][$a[1]][$a[2]][$a[3]][$a[4]]
	Return $r
EndFunc   ;==>_ArrCreator_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description .: adds data to an x-dimensional array
; Описание ....: добавляет данные в x-мерный массив
; =============================================================================================================================
Func _ArrDxAdd_CNMR(ByRef $r, $a, $v)
	Local $i = UBound($a)
		If $i = 1 Then $r[$a[0]] = $v
		If $i = 2 Then $r[$a[0]][$a[1]] = $v
		If $i = 3 Then $r[$a[0]][$a[1]][$a[2]] = $v
		If $i = 4 Then $r[$a[0]][$a[1]][$a[2]][$a[3]] = $v
		If $i = 5 Then $r[$a[0]][$a[1]][$a[2]][$a[3]][$a[4]] = $v
	Return $r
EndFunc   ;==>_ArrDxAdd_CNMR
#EndRegion ARR_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description....: Opens the process
; Описание ......: Открывает процесс
; =============================================================================================================================
Func _OpenProcess_CNMR($iPID)
	Local $hProcess = _WinAPI_OpenProcess($PROCESS_ALL_ACCESS, False, $iPID)
	If @error Then Return SetError(@error, 1, 0)
	Return $hProcess
EndFunc   ;==>_OpenProcess_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description....: closes the process
; Описание ......: Закрывает процесс
; =============================================================================================================================
Func _CloseProcess_CNMR($hProcess)
	_WinAPI_CloseHandle($hProcess)
	If @error Then Return SetError(@error, 1, 0)
	Return 1
EndFunc   ;==>_CloseProcess_CNMR

; #SYSTEM FUNCTION# ============================================================================================================
; Description .: Creates a structure, depending on the conditions
; Описание ....: Создаёт структуру, в зависимости от условий
; ===============================================================================================================================
Func _StructCreator_CNMR($hProcess, $pPtrContainer, $sStructContainer)
	Local $tStructContainer
	If $hProcess Then
		$tStructContainer = _ReadProcessMemory_CNMR($hProcess, $pPtrContainer, $sStructContainer)
	Else
		$tStructContainer = DllStructCreate($sStructContainer, $pPtrContainer)
	EndIf
	Return $tStructContainer
EndFunc   ;==>_StructCreator_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description ...: Reads process memory
; Описание ......: Читает память процесса
; =============================================================================================================================
Func _ReadProcessMemory_CNMR($hProcess, $pPointer, $sStructTag)
	Local $stStruct, $iSize, $pStruct, $iRead
	If Not $hProcess Then Return SetError(@error, 1, 0)
	$stStruct = DllStructCreate($sStructTag)
	$iSize = DllStructGetSize($stStruct)
	$pStruct = DllStructGetPtr($stStruct)
	_WinAPI_ReadProcessMemory($hProcess, $pPointer, $pStruct, $iSize, $iRead)
	Return SetError(@error, $iRead, $stStruct)
EndFunc   ;==>_ReadProcessMemory_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description....: Writes to process memory
; Описание ......: Пишет в память процесса
; =============================================================================================================================
Func _WriteProcessMemory_CNMR($iPID, $pPointer, $ptPtr)
	Local $hProcess, $stData, $iSize, $pData, $bWrite, $iWriten
	$hProcess = _WinAPI_OpenProcess($PROCESS_ALL_ACCESS, False, $iPID)
	If @error Then Return SetError(@error, 1, 0)
	$stData = DllStructCreate('ptr')
	$iSize = DllStructGetSize($stData)
	$pData = DllStructGetPtr($stData)
	DllStructSetData($stData, 1, $ptPtr)
	$bWrite = _WinAPI_WriteProcessMemory($hProcess, $pPointer, $pData, $iSize, $iWriten)
	_WinAPI_CloseHandle($hProcess)
	Return SetError(@error, $iWriten, $bWrite)
EndFunc   ;==>_WriteProcessMemory_CNMR

; #SYSTEM FUNCTION# ===========================================================================================================
; Description ...: Accessing the recipient function
; Описание ......: Обращение к функции получателя
; =============================================================================================================================
Func _Caller_CNMR($vTextSender, $hWndReceiver, $hWndSender)
	Local $aTitleSender = StringSplit(WinGetTitle($hWndSender), $sgID_CNMR, 3); по hwnd отправителя, получаем его имя и группу
	Local $aTitleReceiver = StringSplit(WinGetTitle($hWndReceiver), $sgID_CNMR, 3); по hwnd получателя, получаем его имя и группу

	Local $sReceiverFunc = $sgDefault_Receiver_Function_CNMR
	Local $vCallReturn

	If UBound($agReceiver_Function_From_Name_CNMR) > 0 Then
		For $i = 0 To UBound($agReceiver_Function_From_Name_CNMR) - 1
			If $agReceiver_Function_From_Name_CNMR[$i][0] = $aTitleSender[0] Then
				$sReceiverFunc = $agReceiver_Function_From_Name_CNMR[$i][1]
				ExitLoop
			EndIf
		Next
	EndIf

	If UBound($agReceiver_Function_For_Name_CNMR) > 0 Then
		For $i = 0 To UBound($agReceiver_Function_For_Name_CNMR) - 1
			If $agReceiver_Function_For_Name_CNMR[$i][0] = $aTitleReceiver[0] Then
				$sReceiverFunc = $agReceiver_Function_For_Name_CNMR[$i][1]
				ExitLoop
			EndIf
		Next
	EndIf

	If Not $sReceiverFunc Then
		#Region IDB_CNMR
		If $DEBUG_CONNECTOR Then
			_debWar_CNMR('CONNECTOR')
			_debWar_CNMR('Warning', 'there is an incoming message from «' & $aTitleSender[0] & '» for «' & $aTitleReceiver[0])
			_debWar_CNMR('Content', String($vTextSender))
			_debWar_CNMR('', 'but, there is nowhere to send it, since the recipient has not registered any message receivers')
			_debOky_CNMR('Registration methods', "_Function_Receiver_Connector('_Receiver') - all incoming messages for group members by default will be sent to the _Receiver function")
			_debOky_CNMR('', "_Function_From_Sender_Connector('_Receiver', 'App1') - all incoming messages from App1, which is in the default group, will be sent to _Receiver")
			_debOky_CNMR('', "_Function_For_Sender_Connector('_Receiver', 'App1') - all incoming messages for App1, which is in the default group, will be sent to _Receiver")
			_debOky_CNMR('Для группы', "_Function_Receiver_Connector('_Receiver','MyGroup') - all incoming messages for members in the MyGroup group will be sent to _Receiver")
			_debOky_CNMR('', "_Function_From_Sender_Connector('_Receiver', 'App1','MyGroup') - all incoming messages from App1 that is in the group, 'MyGroup', will be sent to Function")
			_debOky_CNMR('', "_Function_For_Sender_Connector('_Receiver', 'App1','MyGroup') - all incoming messages for App1 in the'MyGroup' group will be sent to Function")
			_debWar_CNMR()
		EndIf
		#EndRegion IDB_CNMR
	Else

		Local $iErr, $sParams, $aParams = ['', '$vTextSender', '$aTitleSender[0]', '$aTitleReceiver[0]']

		For $i = 0 To UBound($aParams) - 1
			$sParams &= $i > 1 ? ',' & $aParams[$i] : $aParams[$i]
			$vCallReturn = Execute($sReceiverFunc & '(' & $sParams & ')')
			If Not @error Then
				$iErr = 0
				ExitLoop
			EndIf
			$iErr = 1
		Next
		#Region IDB_CNMR
		If $iErr And $DEBUG_CONNECTOR Then
			_debWar_CNMR('CONNECTOR')
			_debWar_CNMR('', 'there is an incoming message from «' & $aTitleSender[0] & '» for «' & $aTitleReceiver[0] & '»')
			_debWar_CNMR('Content', String($vTextSender))
			_debWar_CNMR('', 'Missing registered function ' & $sReceiverFunc & ', or it has exceeded the number of incoming parameters')
			_debOky_CNMR('', 'Parameters must be from 0 to 3')
			_debOky_CNMR('Examples:', 'Func _Receiver() - without receiving data')
			_debOky_CNMR('', 'Func _Receiver($vData, $sSender, $sReceiver) - get (data, sender`s name, recipient`s name)')
			_debWar_CNMR()
		EndIf
		#EndRegion IDB_CNMR
	EndIf

	Return $vCallReturn

EndFunc   ;==>_Caller_CNMR

; #SYSTEM FUNCTION# =============================================================================================================
; Description ....: Returns a unique name. Consists of a name and a unique identifier.
; Parameters .....: $ sName - The name of the participant for which you want to get its unique identifier
;                   $sIDGroup - this member's group
; Note            : This method does not register a unique name, only returns

; Описание ......: Возвращает уникальное имя. Состоит из имени и уникального идентификатора.
; Параметры .....: $sName - Имя участника, для которого нужно получить его уникальный идентификатор
;                  $sIDGroup - группа этого участника
; Примечание     : В этом методе уникальное имя не регистрируется, только возвращается
; ===============================================================================================================================
Func _GetUnicalName_CNMR($sName, $sIDGroup = $DEFAULT_GROUP_ID_CONNECTOR)
	Return $sName & $sgID_CNMR & $sIDGroup
EndFunc   ;==>_GetUnicalName_CNMR

; #SYSTEM FUNCTION# =============================================================================================================
; Description : System method, returns data about members and groups, depending on the input parameters
; Parameters .: $iTypeRet = 0 - give an array, otherwise a string
;               $iTypeDat = 0 - returns IDs of all groups
;                           1 - returns a list of all members of all groups
;                           2 - returns a list of all members of one group
;               $sIDGroup - group identifier, if $ iTypeDat = 2

; Описание ......: Системный метод, возвращает данные об участниках и группах, в зависимости от входящих параметров
; Параметры .....: $iTypeRet = 0 - отдать массив, иначе строку
; 								 $iTypeDat = 0 - возвращает ID всех групп
; 														 1 - возвращает список всех участников всех групп
; 														 2 - возвращает список всех участников одной группы
;									 $sIDGroup - идентификатор группы, при параметре $iTypeDat = 2
; ===============================================================================================================================
Func _List_Members_CNMR($iTypeRet = 0, $iTypeDat = 0, $sIDGroup = $DEFAULT_GROUP_ID_CONNECTOR)
	Local $sGroups, $sPatFrm, $aGroups
	Local $isGroup = ($iTypeDat = 2) ? $sIDGroup : '.+'
	Local $aListGroup = WinList('[REGEXPTITLE:.+' & $sgID_CNMR & $isGroup & '$]')
	Local $sSearcGroup
	For $i = $aListGroup[0][0] To 1 Step (-1)
		If $iTypeDat = 0 Then $sSearcGroup = StringRegExpReplace($aListGroup[$i][0], '.+' & $sgID_CNMR & '(.+)$', '$1')
		$sSearcGroup = ($iTypeDat = 0) ? StringRegExpReplace($aListGroup[$i][0], '.+' & $sgID_CNMR & '(.+)$', '$1') : StringRegExpReplace($aListGroup[$i][0], $sgID_CNMR & '.+$', '')
		If Not StringRegExp($sGroups, $sSearcGroup, 0) Then
			$sGroups &= $sPatFrm & $sSearcGroup
			$sPatFrm = '|'
		EndIf
	Next
	If $iTypeRet Then Return $sGroups
	$aGroups = StringSplit($sGroups, '|', 2)
	If UBound($aGroups) > 0 Then Return $aGroups
	Return 0
EndFunc   ;==>_List_Members_CNMR

#Region IDB_CNMR
; #SYSTEM FUNCTION# =============================================================================================================
; Title ......: _deb..._ CNMR
; Description : Methods for outputting debugger messages
; Author .....: Webarion

; Название ......: _deb..._CNMR
; Описание ......: Методы вывода сообщений отладчика
; Автор .........: Webarion
; ===============================================================================================================================
Func _debOky_CNMR($sTit = '', $sText = '')
	_debTxt_CNMR($sTit, $sText, 2)
EndFunc   ;==>_debOky_CNMR

Func _debSys_CNMR($sTit = '', $sText = '')
	_debTxt_CNMR($sTit, $sText, 3)
EndFunc   ;==>_debSys_CNMR

Func _debWar_CNMR($sTit = '', $sText = '')
	_debTxt_CNMR($sTit, $sText, 4)
EndFunc   ;==>_debWar_CNMR

Func _debErr_CNMR($sTit = '', $sText = '')
	_debTxt_CNMR($sTit, $sText, 5)
EndFunc   ;==>_debErr_CNMR

Func _debTxt_CNMR($sTitle = '', $sText = '', $iType = 1, $sFrmRow = '*', $sFrmCol = '|')
	Local $sPatMsg = ' +>-!'
	Local $sType = StringMid($sPatMsg, $iType, 1)
	If Not IsDeclared('aDBT_CNMR') Then Global $aDBT_CNMR[0][3]
	If Not IsDeclared('iDBL_CNMR') Then Global $iDBL_CNMR[2]
	ReDim $aDBT_CNMR[UBound($aDBT_CNMR) + 1][3]
	Local $iCount = UBound($aDBT_CNMR) - 1
	If $iDBL_CNMR[0] < StringLen($sTitle) Then $iDBL_CNMR[0] = StringLen($sTitle)
	If $iDBL_CNMR[1] < StringLen($sText) Then $iDBL_CNMR[1] = StringLen($sText)
	$aDBT_CNMR[$iCount][0] = $iType
	$aDBT_CNMR[$iCount][1] = $sTitle
	$aDBT_CNMR[$iCount][2] = $sText
	If $sTitle Or $sText Then Return
	Local $sLine
	For $i = 0 To UBound($aDBT_CNMR, 1) - 2
		$sType = StringMid($sPatMsg, $aDBT_CNMR[$i][0], 1) & '   ' & ($i = 0 ? $sFrmRow : $sFrmCol)
		$sTitle = _SimClone_CNMR(' ', $iDBL_CNMR[0] - StringLen($aDBT_CNMR[$i][1])) & $aDBT_CNMR[$i][1]
		$sText = $aDBT_CNMR[$i][2] & _SimClone_CNMR(' ', $iDBL_CNMR[1] - StringLen($aDBT_CNMR[$i][2])) & ' ' & $sFrmCol
		$iMaxLen = $iDBL_CNMR[0] + $iDBL_CNMR[1]
		$iD = Mod($iMaxLen, 2) ? '' : $sFrmRow
		If $i = 0 Then
			$sTitle = ' ~ ' & $aDBT_CNMR[$i][1] & ' ~ '
			Local $r = _SimClone_CNMR($sFrmRow, (($iMaxLen - StringLen($aDBT_CNMR[$i][1]) + 2) / 2) - 1)
			$sLine &= $sType & $r & $sTitle & $r & $iD & @CRLF
		Else
			$sLine &= $sType & ' ' & $sTitle & ' : ' & $sText & @CRLF
		EndIf
	Next
	$sType = StringMid($sPatMsg, $aDBT_CNMR[UBound($aDBT_CNMR) - 1][0], 1) & '   ' & $sFrmRow
	$sLine &= $sType & _SimClone_CNMR($sFrmRow, $iMaxLen + StringLen($sType) + 1);закрывающий разделитель
	ConsoleWrite($sLine & @CRLF & @CRLF)
	Dim $aDBT_CNMR[0][3], $iDBL_CNMR[2]
EndFunc   ;==>_debTxt_CNMR

Func _SimClone_CNMR($iSim, $iLen)
	Return StringReplace(StringFormat('%' & $iLen & 's', ''), ' ', $iSim)
EndFunc   ;==>_SimClone_CNMR
; ===============================================================================================================================
#EndRegion IDB_CNMR

; #SYSTEM FUNCTION# =============================================================================================================
; Description : Returns a globally unique identifier
; Описание ......: Возвращает глобальный уникальный идентификатор
; ===============================================================================================================================
Func _Unical_CNMR()
	Local $sDefRet = 'CNMR369'
	Local $oService = ObjGet('winmgmts:\\.\root\cimv2')
	If Not IsObj($oService) Then Return $sDefRet
	Local $oItems, $sUnicID = ''
	$oItems = $oService.ExecQuery('SELECT * FROM Win32_ComputerSystemProduct')
	If Not IsObj($oItems) Then Return $sDefRet
	For $Property In $oItems
		$sUnicID &= $Property.IdentifyingNumber
		$sUnicID &= $Property.SKUNumber
	Next
	If Not StringStripWS($sUnicID, 8) Then Return $sDefRet
	Return StringTrimLeft($sUnicID, 2)
EndFunc   ;==>_Unical_CNMR
#EndRegion Internal functions. Внутренние системные функции
