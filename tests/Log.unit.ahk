#Requires AutoHotkey v2.0

#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

#Include .\..\Log.ahk

Yunit.Use(YunitWindow).Test(TestLog)

class TestLog
{
	class_is_properly_setup()
	{
		Yunit.Assert(Log.HasOwnProp('MODE'),'class doesnt have mode variable')
		Yunit.Assert(Log.HasOwnProp('window'),'class doesnt have window variable')
	}

	window_is_properly_setup()
	{
		Yunit.Assert(WinExist(Log.window.Hwnd), 'the window does not exist')
		Yunit.Assert(Log.window is Gui, 'the variable window is not a gui object')
		Yunit.Assert(Log.window['LogView'], 'the gui does not have a list view')
		Yunit.Assert(Log.window['Save'],'window doesnt have save button')
		Yunit.Assert(Log.window['Clear'],'window doesnt have clear button')
		; Yunit.Assert(Log.HasOwnProp('sb'),'window doesnt have status bar')
	}

class Methods
{
	begin()
	{
		Log.MODE := DEBUG_ALL
		Log.Show()
	}

	end()
	{
		Log.Clear()
		Log.Hide()
	}

	show_method()
	{
		static WS_VISIBLE := 0x10000000

		Yunit.Assert(WinGetStyle(Log.window) & WS_VISIBLE, 'the window is not visible')
	}

	hide_method()
	{
		static WS_VISIBLE := 0x10000000

		Log.Hide()
		Yunit.Assert(WinGetStyle(Log.window) & ~WS_VISIBLE, 'the window is still visible')
	}

	add_method()
	{
		static lv := Log.window['LogView']

		Log.Add('this is a test', STATUS_PASS)
		Yunit.Assert(lv.GetCount() = 1, 'more items than expected')
		Yunit.Assert(lv.GetText(1, 2) == 'this is a test', 'row does not contain the expected value')
	}

	clear_method()
	{
		static lv := Log.window['LogView']

		Log.Test()
		Yunit.Assert(lv.GetCount() > 0, 'no items were added')
		Log.Clear()
		Yunit.Assert(lv.GetCount() = 0, 'items were not cleared')
	}

	save_method()
	{
		Log.Test()
		sFile := Log.Save('saved.log')
		Yunit.Assert(FileExist(sFile), 'file was not saved')

		line_count := StrSplit(FileRead(sFile), '`n').Length
		FileDelete sFile
		Yunit.Assert(line_count = 4, 'unexpected file length')
	}
}
}