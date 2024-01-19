; --------------------------- INITIAL OPTIONS ---------------------------
#SingleInstance Force
ListLines(false)
SendMode("Input") ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)
KeyHistory(0)
#WinActivateForce
#Warn
ProcessSetPriority("H")

SetWinDelay(-1)
SetControlDelay(-1)

; ************************** GLOBAL VARIABLES **************************
Global USERPROFILE := EnvGet("USERPROFILE")
Global APPS := USERPROFILE "\scoop\apps\"

; ************************** HOTSTRINGS **************************
; Insert Gmail Address
:o:@@::ifalaleev49@gmail.com

; Insert Username
:o:jkw::jokerwrld

; --------------------------- POWER OPTIONS ---------------------------
; Win+LShift+F1 - Hibernate
#<+F1::
{
	DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
return
}

; Win+LShift+F2 - Sleep
#<+F2::
{
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
return
}

; Win+LShift+F3 - Reboot
#<+F3::
{
	Shutdown(2)
return

; Win+LShift+F4 - Shutdown
}
#<+F4::
{
	Shutdown(8)
return
}

; --------------------------- RUN APPS ---------------------------
; Win+C - Open Chrome
#C::
{
	Run(APPS "googlechrome\current\chrome.exe")
return
}

; Win+V - Open VSCode
#V::
{
	Run(APPS "vscode\current\Code.exe")
return
}

; Win+E - Open Explorer
#E::
{
	Run("explorer.exe")
return
}

; Win+T - Open Telegram
#T::
{
	Run(APPS "telegram\current\Telegram.exe")
return
}

; Ctrl+Alt+T - Open Windows Terminal
^!T::
{
	Run("wt.exe")
return
}

; Win+LShift+W - Close Active Window
#<+W::
{
	PostMessage(0x112, 0xF060, , , "A")
return
}

; --------------------------- NAVIGATING WINDOWS ---------------------------
; >>>>>>> MULTI-MONITOR SCOPE
; Win+LShift+H - Move Window to Left Monitor
#<+H::
{
	Send("#+{Left}")
return
}

; Win+LShift+L - Move Window to Right Monitor
#<+L::
{
	Send("#+{Right}")
return
}

; >>>>>>> MULTI-VIRTUAL-DESKTOP SCOPE
; Win+LShift+Ctrl+H - Switch to Left Virtual Desktop
#<+^H::
{
	Send("`"#^{Left}`"")
return
}

; Win+LShift+Ctrl+L - Swithc to Right Virtual Desktop
#<+^L::
{
	Send("`"#^{Right}`"")
return
}

; >>>>>>> PER-MONITOR SCOPE
; Win+Ctrl+N - Move Window to Bottom-Left Corner
#^N::
#Numpad1::
{
	MoveIt(1)
return
}

; Win+Ctrl+J - Move Window to Bottom Side
#^J::
#Down::
{
	MoveIt(2)
return
}

; Win+Ctrl+M - Move Window to Bottom-Right Corner
#^M::
#Numpad3::
{
	MoveIt(3)
return
}

; Win+Ctrl+H - Move Window to Left Side
#^H::
#Left::
{
	MoveIt(4)
return
}

; Win+LShift+K - Maximize/Restore Window Toggle
#<+K::
{
	MoveIt(5)
return
}

; Win+Ctrl+L - Move Window to Right Side
#^L::
#Right::
{
	MoveIt(6)
return
}

; Win+Ctrl+U - Move Window to Top-Left Corner
#^U::
#Numpad7::
{
	MoveIt(7)
return
}

; Win+Ctrl+K - Move Window to Top Side
#^K::
#Up::
{
	MoveIt(8)
return
}

; Win+Ctrl+I - Move Window to Top-Right Corner
#^I::
#Numpad9::
{
	MoveIt(9)
return
}

; >>>>>>> PER-WINDOW SCOPE
; LShift+Ctrl+H - Swich Window Tab Left
<+^H::
{
	Send("^+{Tab}")
return
}

; LShift+Ctrl+L - Swich Window Tab Right
<+^L::
{
	Send("^{Tab}")
return
}

; --------------------------- KEYBOARD LAYOUT OPTIONS ---------------------------
; Win+LShift+E - Set English Layout
#<+E::
{
   SetDefaultKeyboard(0x0409)
return
}

; Win+LShift+R - Set Russian Layout
#<+R::
{
   SetDefaultKeyboard(0x0419)
return
}

; Win+LShift+U - Set Ukranian Layout
#<+U::
{
   SetDefaultKeyboard(0x0422)
return
}

; --------------------------- FUNCTIONS SECTION ---------------------------
; >>>>>>> Move Windows Across Monitors
MoveIt(Q)
{
  ; Get the windows pos
	WinGetPos(&X, &Y, &W, &H, "A")
	M := WinGetMinMax("A")

  ; Calculate the top center edge
  CX := X + W/2
  CY := Y + 10

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
	DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "UPtr", LocaleID, "UInt", SPIF_SENDWININICHANGE)
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