; --------------------------- INITIAL OPTIONS ---------------------------
#NoEnv
#SingleInstance Force
ListLines Off
SetBatchLines -1
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%
#KeyHistory 0
#WinActivateForce
#Warn
Process, Priority,, H

SetWinDelay -1
SetControlDelay -1

if not A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%"

; ************************** HOTSTRINGS **************************
; Insert Gmail Address
:o:@@::ifalaleev49@gmail.com

; Insert Username
:o:jkw::jokerwrld

; ************************** HOTKEYS **************************
; --------------------------- POWER OPTIONS ---------------------------
; Win+LShift+F1 - Hibernate
#<+F1::
	DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
return

; Win+LShift+F2 - Sleep
#<+F2::
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
return

; Win+LShift+F3 - Reboot
#<+F3::
	Shutdown, 2
return

; Win+LShift+F4 - Shutdown
#<+F4::
	Shutdown, 8
return

; --------------------------- RUN APPS ---------------------------
; Win+C - Open Chrome
#C::
	Run, chrome.exe
return

; Win+V - Open VSCode
#V::
	Run, $env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\Code.exe
return

; Win+E - Open Explorer
#E::
	Run, explorer.exe
return

; Win+T - Open Telegram
#T::
	Run, $env:USERPROFILE\AppData\Roaming\Telegram Desktop\Telegram.exe
return

; Ctrl+Alt+T - Open Windows Terminal
^!T::
	Run, wt.exe
return

; Win+LShift+W - Close Active Window
#<+W::
	PostMessage, 0x112, 0xF060,,, A
return

; --------------------------- NAVIGATING WINDOWS ---------------------------
; >>>>>>> MULTI-MONITOR SCOPE
; Win+LShift+H - Move Window to Left Monitor
#<+H::
	Send #+{Left}
return

; Win+LShift+L - Move Window to Right Monitor
#<+L::
	Send #+{Right}
return

; >>>>>>> MULTI-VIRTUAL-DESKTOP SCOPE
; Win+LShift+Ctrl+H - Switch to Left Virtual Desktop
#<+^H::
	Send	"#^{Left}"
return

; Win+LShift+Ctrl+L - Swithc to Right Virtual Desktop
#<+^L::
	Send	"#^{Right}"
return

; >>>>>>> PER-MONITOR SCOPE
; Win+Ctrl+N - Move Window to Bottom-Left Corner
#^N::
#Numpad1::
	MoveIt(1)
return

; Win+Ctrl+J - Move Window to Bottom Side
#^J::
#Down::
	MoveIt(2)
return

; Win+Ctrl+M - Move Window to Bottom-Right Corner
#^M::
#Numpad3::
	MoveIt(3)
return

; Win+Ctrl+H - Move Window to Left Side
#^H::
#Left::
	MoveIt(4)
return

; Win+LShift+K - Maximize/Restore Window Toggle
#<+K::
	MoveIt(5)
return

; Win+Ctrl+L - Move Window to Right Side
#^L::
#Right::
	MoveIt(6)
return

; Win+Ctrl+U - Move Window to Top-Left Corner
#^U::
#Numpad7::
	MoveIt(7)
return

; Win+Ctrl+K - Move Window to Top Side
#^K::
#Up::
	MoveIt(8)
return

; Win+Ctrl+I - Move Window to Top-Right Corner
#^I::
#Numpad9::
	MoveIt(9)
return

; >>>>>>> PER-WINDOW SCOPE
; LShift+Ctrl+H - Swich Window Tab Left
<+^H::
send, ^+{Tab}
return

; LShift+Ctrl+L - Swich Window Tab Right
<+^L::
send, ^{Tab}
return

; --------------------------- KEYBOARD LAYOUT OPTIONS ---------------------------
; Win+LShift+E - Set English Layout
#<+E::
   SetDefaultKeyboard(0x0409)
return

; Win+LShift+R - Set Russian Layout
#<+R::
   SetDefaultKeyboard(0x0419)
return

; Win+LShift+U - Set Ukranian Layout
#<+U::
   SetDefaultKeyboard(0x0422)
return

; --------------------------- FUNCTIONS SECTION ---------------------------
; >>>>>>> Move Windows Across Monitors
MoveIt(Q)
{
  ; Get the windows pos
	WinGetPos,X,Y,W,H,A,,,
	WinGet,M,MinMax,A

  ; Calculate the top center edge
  CX := X + W/2
  CY := Y + 10

;  MsgBox, X: %X% Y: %Y% W: %W% H: %H% CX: %CX% CY: %CY%
  SysGet, Count, MonitorCount
  num = 1
  Loop, %Count%
  {
    SysGet, Mon, MonitorWorkArea, %num%

    if( CX >= MonLeft && CX <= MonRight && CY >= MonTop && CY <= MonBottom )
    {
		MW := (MonRight - MonLeft)
		MH := (MonBottom - MonTop)
		MHW := (MW / 2)
		MHH := (MH / 2)
		MMX := MonLeft + MHW
		MMY := MonTop + MHH

		if( M != 0 )
			WinRestore,A

		if( Q == 1 )
			WinMove,A,,MonLeft,MMY,MHW,MHH
		if( Q == 2 )
			WinMove,A,,MonLeft,MMY,MW,MHH
		if( Q == 3 )
			WinMove,A,,MMX,MMY,MHW,MHH
		if( Q == 4 )
			WinMove,A,,MonLeft,MonTop,MHW,MH
		if( Q == 5 )
		{
			if( M == 0 )
				WinMaximize,A
			else
				WinRestore,A
		}
		if( Q == 6 )
			WinMove,A,,MMX,MonTop,MHW,MH
		if( Q == 7 )
			WinMove,A,,MonLeft,MonTop,MHW,MHH
		if( Q == 8 )
			WinMove,A,,MonLeft,MonTop,MW,MHH
		if( Q == 9 )
			WinMove,A,,MMX,MonTop,MHW,MHH
        return
    }
    num += 1
  }
return
}

; >>>>>>> Switch Keyboard Layout
SetDefaultKeyboard(LocaleID){
	Global
	SPI_SETDEFAULTINPUTLANG := 0x005A
	SPIF_SENDWININICHANGE := 2
	Lan := DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", LocaleID), "Int", 0)
	VarSetCapacity(Lan%LocaleID%, 4, 0)
	NumPut(LocaleID, Lan%LocaleID%)
	DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "UPtr", &Lan%LocaleID%, "UInt", SPIF_SENDWININICHANGE)
	WinGet, windows, List
	Loop %windows% {
		PostMessage 0x50, 0, %Lan%, , % "ahk_id " windows%A_Index%
	}
}