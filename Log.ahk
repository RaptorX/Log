#Requires Autohotkey v2.0+

#Include .\lib\Log.h.ahk

class Log
{
	static MODE := DEBUG_OFF
	static window := Gui('+AlwaysOnTop +ToolWindow', 'Log')
}