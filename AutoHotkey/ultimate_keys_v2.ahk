; --------------------------- INITIAL OPTIONS ---------------------------
; REMOVED: #NoEnv
#SingleInstance Force
ListLines(false)
; REMOVED: SetBatchLines -1
SendMode("Input") ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)
KeyHistory(0)
#WinActivateForce
#Warn
ProcessSetPriority("H")

SetWinDelay(-1)
SetControlDelay(-1)

if not A_IsAdmin
	Run("*RunAs `"" A_ScriptFullPath "`"")

; ************************** HOTSTRINGS **************************
; Insert Gmail Address
:o:@@::ifalaleev49@gmail.com

; Insert Username
:o:jkw::jokerwrld

; ************************** HOTKEYS **************************
; --------------------------- POWER OPTIONS ---------------------------
; Win+LShift+F1 - Hibernate
#<+F1::
{ ; V1toV2: Added bracket
	DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
return

; Win+LShift+F2 - Sleep
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+F2::
{ ; V1toV2: Added bracket
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
return

; Win+LShift+F3 - Reboot
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+F3::
{ ; V1toV2: Added bracket
	Shutdown(2)
return

; Win+LShift+F4 - Shutdown
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+F4::
{ ; V1toV2: Added bracket
	Shutdown(8)
return

; --------------------------- RUN APPS ---------------------------
; Win+C - Open Chrome
} ; V1toV2: Added Bracket before hotkey or Hotstring
#C::
{ ; V1toV2: Added bracket
	Run("chrome.exe")
return

; Win+V - Open VSCode
} ; V1toV2: Added Bracket before hotkey or Hotstring
#V::
{ ; V1toV2: Added bracket
	Run("$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\Code.exe")
return

; Win+E - Open Explorer
} ; V1toV2: Added Bracket before hotkey or Hotstring
#E::
{ ; V1toV2: Added bracket
	Run("explorer.exe")
return

; Win+T - Open Telegram
} ; V1toV2: Added Bracket before hotkey or Hotstring
#T::
{ ; V1toV2: Added bracket
	Run("$env:USERPROFILE\AppData\Roaming\Telegram Desktop\Telegram.exe")
return

; Ctrl+Alt+T - Open Windows Terminal
} ; V1toV2: Added Bracket before hotkey or Hotstring
^!T::
{ ; V1toV2: Added bracket
	Run("wt.exe")
return

; Win+LShift+W - Close Active Window
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+W::
{ ; V1toV2: Added bracket
	PostMessage(0x112, 0xF060, , , "A")
return

; --------------------------- NAVIGATING WINDOWS ---------------------------
; >>>>>>> MULTI-MONITOR SCOPE
; Win+LShift+H - Move Window to Left Monitor
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+H::
{ ; V1toV2: Added bracket
	Send("#+{Left}")
return

; Win+LShift+L - Move Window to Right Monitor
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+L::
{ ; V1toV2: Added bracket
	Send("#+{Right}")
return

; >>>>>>> MULTI-VIRTUAL-DESKTOP SCOPE
; Win+LShift+Ctrl+H - Switch to Left Virtual Desktop
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+^H::
{ ; V1toV2: Added bracket
	Send("`"#^{Left}`"")
return

; Win+LShift+Ctrl+L - Swithc to Right Virtual Desktop
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+^L::
{ ; V1toV2: Added bracket
	Send("`"#^{Right}`"")
return

; >>>>>>> PER-MONITOR SCOPE
; Win+Ctrl+N - Move Window to Bottom-Left Corner
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^N::
#Numpad1::
{ ; V1toV2: Added bracket
	MoveIt(1)
return

; Win+Ctrl+J - Move Window to Bottom Side
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^J::
#Down::
{ ; V1toV2: Added bracket
	MoveIt(2)
return

; Win+Ctrl+M - Move Window to Bottom-Right Corner
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^M::
#Numpad3::
{ ; V1toV2: Added bracket
	MoveIt(3)
return

; Win+Ctrl+H - Move Window to Left Side
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^H::
#Left::
{ ; V1toV2: Added bracket
	MoveIt(4)
return

; Win+LShift+K - Maximize/Restore Window Toggle
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+K::
{ ; V1toV2: Added bracket
	MoveIt(5)
return

; Win+Ctrl+L - Move Window to Right Side
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^L::
#Right::
{ ; V1toV2: Added bracket
	MoveIt(6)
return

; Win+Ctrl+U - Move Window to Top-Left Corner
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^U::
#Numpad7::
{ ; V1toV2: Added bracket
	MoveIt(7)
return

; Win+Ctrl+K - Move Window to Top Side
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^K::
#Up::
{ ; V1toV2: Added bracket
	MoveIt(8)
return

; Win+Ctrl+I - Move Window to Top-Right Corner
} ; V1toV2: Added Bracket before hotkey or Hotstring
#^I::
#Numpad9::
{ ; V1toV2: Added bracket
	MoveIt(9)
return

; >>>>>>> PER-WINDOW SCOPE
; LShift+Ctrl+H - Swich Window Tab Left
} ; V1toV2: Added Bracket before hotkey or Hotstring
<+^H::
{ ; V1toV2: Added bracket
Send("^+{Tab}")
return

; LShift+Ctrl+L - Swich Window Tab Right
} ; V1toV2: Added Bracket before hotkey or Hotstring
<+^L::
{ ; V1toV2: Added bracket
Send("^{Tab}")
return

; --------------------------- KEYBOARD LAYOUT OPTIONS ---------------------------
; Win+LShift+E - Set English Layout
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+E::
{ ; V1toV2: Added bracket
   SetDefaultKeyboard(0x0409)
return

; Win+LShift+R - Set Russian Layout
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+R::
{ ; V1toV2: Added bracket
   SetDefaultKeyboard(0x0419)
return

; Win+LShift+U - Set Ukranian Layout
} ; V1toV2: Added Bracket before hotkey or Hotstring
#<+U::
{ ; V1toV2: Added bracket
   SetDefaultKeyboard(0x0422)
return

; --------------------------- FUNCTIONS SECTION ---------------------------
; >>>>>>> Move Windows Across Monitors
} ; Added bracket before function
MoveIt(Q)
{
  ; Get the windows pos
	WinGetPos(&X, &Y, &W, &H, "A")
	M := WinGetMinMax("A")

  ; Calculate the top center edge
  CX := X + W/2
  CY := Y + 10

;  MsgBox, X: %X% Y: %Y% W: %W% H: %H% CX: %CX% CY: %CY%
  Count := MonitorGetCount()
  num := "1"
  Loop Count
  {
    MonitorGetWorkArea(num, &MonLeft, &MonTop, &MonRight, &MonBottom)

    if( CX >= MonLeft && CX <= MonRight && CY >= MonTop && CY <= MonBottom )
    {
		MW := (MonRight - MonLeft)
		MH := (MonBottom - MonTop)
		MHW := (MW / 2)
		MHH := (MH / 2)
		MMX := MonLeft + MHW
		MMY := MonTop + MHH

		if( M != 0 )
			WinRestore("A")

		if( Q == 1 )
			WinMove(MonLeft, MMY, MHW, MHH, "A")
		if( Q == 2 )
			WinMove(MonLeft, MMY, MW, MHH, "A")
		if( Q == 3 )
			WinMove(MMX, MMY, MHW, MHH, "A")
		if( Q == 4 )
			WinMove(MonLeft, MonTop, MHW, MH, "A")
		if( Q == 5 )
		{
			if( M == 0 )
				WinMaximize("A")
			else
				WinRestore("A")
		}
		if( Q == 6 )
			WinMove(MMX, MonTop, MHW, MH, "A")
		if( Q == 7 )
			WinMove(MonLeft, MonTop, MHW, MHH, "A")
		if( Q == 8 )
			WinMove(MonLeft, MonTop, MW, MHH, "A")
		if( Q == 9 )
			WinMove(MMX, MonTop, MHW, MHH, "A")
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
	Lan%LocaleID% := Buffer(4, 0) ; V1toV2: if 'Lan%LocaleID%' is a UTF-16 string, use 'VarSetStrCapacity(&Lan%LocaleID%, 4)'
	NumPut("UPtr", LocaleID, Lan%LocaleID%)
	DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "UPtr", Lan%LocaleID%, "UInt", SPIF_SENDWININICHANGE)
	owindows := WinGetList(,,,)
	awindows := Array()
	windows := owindows.Length
	For v in owindows
	{   awindows.Push(v)
	}
	Loop awindows.Length {
		PostMessage(0x50, 0, Lan, , "ahk_id " awindows[A_Index])
	}
}