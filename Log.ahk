#Requires Autohotkey v2.0+

#Include .\lib\Log.h.ahk


;; /todo: allow setting headers for listview/
;; /todo: allow tab delimited info/
class Log
{
	static MODE := DEBUG_ALL
	static window := Gui('+AlwaysOnTop +ToolWindow', 'Log')
	static lv := ''

	static __New() {
		if VerCompare(A_OSVersion, '10.0.22621') = -1
			icons := [297,132,237,278]
		else
			icons := [301,132,237,278]

		Log.window.OnEvent('Close', (*)=> Log.window.Hide())

		il := IL_Create(4)
		for icon in icons
			IL_Add(il, 'shell32.dll', icon)

		Log.lv := Log.window.AddListView('vLogView xm w500 h600', ['id','Log'])
		Log.lv.SetImageList(il)

		xLoc := 75*2 + log.window.MarginX
		Log.window.AddButton('vSave x+-' xLoc ' y+m w75', 'Save Logs').OnEvent('Click', (*) => Log.Save())
		Log.window.AddButton('vClear x+m w75', 'Clear logs').OnEvent('Click', (*) => Log.Clear())

	}

	static Add(message, icon?) {
		if Log.MODE = DEBUG_OFF
			return

		switch icon
		{
		case STATUS_INFO,STATUS_PASS:
			if Log.MODE & DEBUG_INFO = 0
				return
		case STATUS_WARN:
			if Log.MODE & DEBUG_WARNINGS = 0
				return
		case STATUS_FAIL:
			if Log.MODE & DEBUG_ERRORS = 0
				return
		}

		row := Log.lv.Add('Icon' (icon??''), Log.lv.GetCount() + 1, message)
		Log.lv.Modify(row, 'Vis'), Log.lv.ModifyCol(1)

		OutputDebug message
	}

	static Show(opts?)
	{
		xLoc := 500 + log.window.MarginX*2 + 15
		opts := opts ?? 'x' A_ScreenWidth-xLoc ' NoActivate'
		Log.window.Show(opts)
	}
	static Clear() => Log.lv.Delete()
	static Hide() => Log.window.Hide()

	static Save(fPath?) {
		if !fPath := fPath ?? FileSelect('S24')
			return MsgBox('No file selected', 'Error', 'IconX')

		hFile := FileOpen(fPath, 'w-')

		hFile.Write(ListViewGetContent('', Log.lv))
		hFile.Close()

		return fPath
	}

	static Test() {
		Log.Clear()
		Log.Add('Info', STATUS_INFO)
		Log.Add('Pass', STATUS_PASS)
		Log.Add('Warning', STATUS_WARN)
		Log.Add('Failure', STATUS_FAIL)
		Log.Show()
	}
}