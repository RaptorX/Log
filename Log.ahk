#Requires Autohotkey v2.0+

#Include .\lib\Log.h.ahk

class Log
{
	static mode := DEBUG_ALL
	static window := Gui('+AlwaysOnTop +ToolWindow', 'Log')
	static lv := ''
	static headers {
		get {
			hdrs := []
			loop Log.lv.GetCount('col')
				hdrs.Push(Log.lv.GetText(0, A_Index))

			return hdrs
		}

		set {
			loop Log.lv.GetCount('col')
				Log.lv.DeleteCol(1)

			Value.InsertAt(1, 'id')
			for header in Value
				Log.lv.InsertCol(A_Index+1, '', header)
		}
	}
	static update {
		set {
			if Value
				Log.lv.Opt('+Redraw')
			else
				Log.lv.Opt('-Redraw')
		}
	}
	static visible {
		set {
			if Value
				Log.Show()
			else
				Log.Hide()
		}
	}

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

	__New(icon?, messages*) => Log.Add(icon, messages*)

	static Add(icon?, messages*) {
		if Log.mode = DEBUG_OFF
			return

		icon := icon ?? DEBUG_ICON_INFO
		; icon must be one of the valid icons
		if Type(icon) != 'Integer'
		|| icon ~= '(' DEBUG_ICON_FAIL '|' DEBUG_ICON_INFO '|' DEBUG_ICON_PASS '|' DEBUG_ICON_WARN ')' = 0
			throw ValueError('Expected an Icon Number but got a ' Type(icon), A_ThisFunc, 'icon')

		; message must be an array
		if Type(messages) != 'Array'
			throw ValueError('Expected an Array but got a ' Type(messages), A_ThisFunc, 'messages*')

		if messages.Length+1 != Log.headers.Length
			throw Error('Expected ' Log.headers.Length ' fields but got ' messages.Length, A_ThisFunc, 'messages*')

		switch icon
		{
		case DEBUG_ICON_INFO,DEBUG_ICON_PASS:
			if Log.mode & DEBUG_INFO = 0
				return
		case DEBUG_ICON_WARN:
			if Log.mode & DEBUG_WARNINGS = 0
				return
		case DEBUG_ICON_FAIL:
			if Log.mode & DEBUG_ERRORS = 0
				return
		}
		row := Log.lv.Add('Icon' icon, Log.lv.GetCount() + 1, messages*)
		Log.lv.Modify(row, 'Vis'), Log.lv.ModifyCol(1)

		message := ''
		for msg in messages
			message .= msg '`t'

		OutputDebug Trim(message) '`n'
	}

	static Show(opts?)
	{
		xLoc := 500 + log.window.MarginX*2 + 15
		opts := opts ?? 'x' A_ScreenWidth-xLoc ' NoActivate'
		Log.lv.Opt('-Redraw')
		loop Log.lv.GetCount('col')
			Log.lv.ModifyCol(A_Index, 'AutoHDR')
		Log.lv.Opt('+Redraw')
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

	static Test(visible := true) {
		if Log.headers.Length != 2
			Log.headers := ['Log']
		Log.Clear()
		Log.Add(DEBUG_ICON_INFO, 'Info')
		Log.Add(DEBUG_ICON_PASS, 'Pass')
		Log.Add(DEBUG_ICON_WARN, 'Warning')
		Log.Add(DEBUG_ICON_FAIL, 'Failure')

		if visible
			Log.Show()
	}
}