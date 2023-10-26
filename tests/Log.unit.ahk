﻿#Requires AutoHotkey v2.0

#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

#Include .\..\Log.ahk

Yunit.Use(YunitWindow).Test(TestLog)

class TestLog
{
	class_is_properly_setup()
	{
		static props := Map(
			'MODE', 'class doesnt have mode variable',
			'window', 'class doesnt have window variable',
			'lv', 'class doesnt have the list view control variable'
		)

		for prop,errMsg in props
			Yunit.Assert(Log.HasOwnProp(prop), errMsg)
	}

	window_is_properly_setup()
	{
		static ctrls := Map(
			'LogView', 'the gui does not have a list view',
			'Save', 'window doesnt have save button',
			'Clear', 'window doesnt have clear button',
		)
		Yunit.Assert(WinExist(Log.window.Hwnd), 'the window does not exist')
		Yunit.Assert(Log.window is Gui, 'the variable window is not a gui object')

		for ctrl,errMsg in ctrls
			Yunit.Assert(Log.window[ctrl], errMsg)
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
		Log.Add('this is a test', STATUS_PASS)
		Yunit.Assert(Log.lv.GetCount() = 1, 'more items than expected')
		Yunit.Assert(Log.lv.GetText(1, 2) == 'this is a test', 'row does not contain the expected value')
	}

	test_method()
	{
		Log.Test()
		Yunit.Assert(Log.lv.GetCount() = 4, 'no items were added')
	}

	clear_method()
	{
		Log.Test()
		Yunit.Assert(Log.lv.GetCount() > 0, 'no items were added')
		Log.Clear()
		Yunit.Assert(Log.lv.GetCount() = 0, 'items were not cleared')
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

class DebuggingModes
{
	; begin()
	; {

	; }

	end()
	{
		Log.Clear()
		Log.Hide()
	}

	debugging_none()
	{
		Log.MODE := DEBUG_OFF
		Log.Test()
		Yunit.Assert(Log.lv.GetCount() = 0, 'unexpected number of lines')
	}

	debugging_info_and_pass()
	{
		Log.MODE := DEBUG_INFO
		Log.Test()
		Yunit.Assert(Log.lv.GetCount() = 2, 'unexpected number of lines')

		expected := 'Info`nPass'
		Yunit.Assert(ListViewGetContent('col2', Log.lv) == expected, 'the expected text was not found')

	}

	debugging_warnings()
	{
		Log.MODE := DEBUG_WARNINGS
		Log.Test()
		Yunit.Assert(Log.lv.GetCount() = 1, 'unexpected number of lines')

		expected := 'Warning'
		Yunit.Assert(ListViewGetContent('col2', Log.lv) == expected, 'the expected text was not found')
	}

	debugging_errors()
	{
		Log.MODE := DEBUG_ERRORS
		Log.Test()
		Yunit.Assert(Log.lv.GetCount() = 1, 'unexpected number of lines')

		expected := 'Failure'
		Yunit.Assert(ListViewGetContent('col2', Log.lv) == expected, 'the expected text was not found')

	}

	debugging_all()
	{
		Log.MODE := DEBUG_ALL
		Log.Test()
		Yunit.Assert(Log.lv.GetCount() = 4, 'unexpected number of lines')

		expected := 'Info`nPass`nWarning`nFailure'
		Yunit.Assert(ListViewGetContent('col2', Log.lv) == expected, 'the expected text was not found')
	}
}
}