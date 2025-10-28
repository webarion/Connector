# Connector - AutoIt Inter-Process Communication Library

## 🚀 What is this?
A IPC (Inter-Process Communication) library for AutoIt that enables seamless data exchange between different processes and applications on the same machine.

## ✨ Core Features
- **Multi-type Support**: String, Int32, Int64, Double, Bool, Binary, Hwnd, Ptr, Keyword, Arrays (up to 5D)
- **Group Management**: Organize processes into communication groups
- **Flexible Routing**: Send messages to specific receivers or broadcast to groups
- **Auto Process Launch**: Automatically start recipient processes if needed
- **Debug System**: Built-in comprehensive debugging capabilities

## 🏗️ How it Works
Each process registers as a "member" with a unique name and optional group ID. The library uses Windows' WM_COPYDATA messaging system with structured memory allocation for efficient data transfer. Members can communicate across different processes while maintaining data type integrity.

## 💻 Quick Start

```autoit
#include "Connector.au3"

; Register as a member
_Add_Member_Connector("MyApp")

; Set up message handler
_Function_Receiver_Connector("OnIncomingMessage")

; Send message to another process
$response = _Send_Connector("Hello World!", "OtherApp")

Func OnIncomingMessage($data, $sender, $receiver)
    ConsoleWrite("Received from " & $sender & ": " & $data & @CRLF)
    Return "Response data"
EndFunc
