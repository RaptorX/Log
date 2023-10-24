#Requires Autohotkey v2.0+

#Include .\lib\Log.h.ahk

class Log
{
	static MODE := DEBUG_OFF
	static window := Gui('+AlwaysOnTop +ToolWindow', 'Log')

	static __New() {
		if VerCompare(A_OSVersion, '10.0.22621') = -1
			icons := [297,132,237,278]
		else
			icons := [301,132,237,278]

		Log.window.OnEvent('Close', (*)=> Log.window.Hide())

		il := IL_Create(4)
		for icon in icons
			IL_Add(il, 'shell32.dll', icon)

		Log.window.AddListView('vLogView xm w500 h600', ['id','Log'])
		Log.window['LogView'].SetImageList(il)

		xLoc := 75*2 + log.window.MarginX
		Log.window.AddButton('vSave x+-' xLoc ' y+m w75', 'Save Logs').OnEvent('Click', (*) => Log.Save())
		Log.window.AddButton('vClear x+m w75', 'Clear logs').OnEvent('Click', (*) => Log.Clear())

	}
	static Show(opts := 'x' A_ScreenWidth - 535 ' NoActivate') => Log.window.Show(opts)
	static Clear() => Log.window['LogView'].Delete()
	static Hide() => Log.window.Hide()
}