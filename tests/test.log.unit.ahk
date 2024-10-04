#Requires AutoHotkey v2.0

#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>

#Include .\..\Log.ahk

Yunit.Use(YunitWindow).Test(LOG_TESTS)

class LOG_TESTS
{
	static CreateLogs(asError := false)
	{
		Log(MSG_INFO,  asError ? Error('this is an info message')    : 'this is an info message')
		Log(MSG_WARN,  asError ? Error('this is a warning message')  : 'this is a warning message')
		Log(MSG_PASS,  asError ? Error('this is a passing message')  : 'this is a passing message')
		Log(MSG_FAIL,  asError ? Error('this is a failure message')  : 'this is a failure message')
		Log(MSG_ERROR, asError ? Error('this is an error message')   : 'this is an error message')
		Log(MSG_DEBUG, asError ? Error('this is a debug message')    : 'this is a debug message')
	}

	class T1•MODES
	{
		begin() => Yunit.Assert(FileExist(Log.FILE), 'Log file not found')
		end(){
			line := ''
			for header in Log.lv.headers
				line .= header . Log.DELIMITER
			line := RTrim(line, Log.DELIMITER)

			f := FileOpen(Log.FILE, 'w')
			f.Write(line '`n')
			f.Close()
		}

		t1•DEBUG_OFF()
		{
			Log.MODE := DEBUG_OFF
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 1, 'Invalid number of lines: ' cnt '. Expected 1' )
		}

		t2•DEBUG_INFO()
		{
			Log.MODE := DEBUG_INFO
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 2, 'Invalid number of lines: ' cnt '. Expected 2' )
		}

		t3•DEBUG_WARNINGS()
		{
			Log.MODE := DEBUG_WARNINGS
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 3, 'Invalid number of lines: ' cnt '. Expected 3' )
		}

		t4•DEBUG_FAILURES()
		{
			Log.MODE := DEBUG_RESULTS
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 5, 'Invalid number of lines: ' cnt '. Expected 5' )
		}

		t5•DEBUG_ERRORS()
		{
			Log.MODE := DEBUG_ERRORS
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 6, 'Invalid number of lines: ' cnt '. Expected 6' )
		}

		t6•DEBUG_ALL()
		{
			Log.MODE := DEBUG_ALL
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 7, 'Invalid number of lines: ' cnt '. Expected 7' )
		}

		t7•DEBUG_WINDOW()
		{
			Log.MODE    := DEBUG_ALL 
			Log.OPTIONS := DEBUG_WINDOW
			Log_Tests.CreateLogs(true)

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 7, 'Invalid number of lines: ' cnt '. Expected 7' )
			Log.OPTIONS := DEBUG_OFF
		}
	}

	class T2•CUSTOM_MODES
	{
		begin() => Yunit.Assert(FileExist(Log.FILE), 'Log file not found')
		end(){
			line := ''
			for header in Log.lv.headers
				line .= header . Log.DELIMITER
			line := RTrim(line, Log.DELIMITER)

			f := FileOpen(Log.FILE, 'w')
			f.Write(line '`n')
			f.Close()
		}

		t1•INFO_WARN()
		{
			Log.MODE := MSG_INFO | MSG_WARN
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 3, 'Invalid number of lines: ' cnt '. Expected 3' )
		}

		t2•INFO_WARN_FAIL()
		{
			Log.MODE := MSG_INFO | MSG_WARN | MSG_FAIL
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 4, 'Invalid number of lines: ' cnt '. Expected 4' )
		}

		t3•WARN_FAIL()
		{
			Log.MODE := MSG_WARN | MSG_FAIL
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 3, 'Invalid number of lines: ' cnt '. Expected 3' )
		}

		t4•WARN_FAIL_ERROR()
		{
			Log.MODE := MSG_WARN | MSG_FAIL | MSG_ERROR
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 4, 'Invalid number of lines: ' cnt '. Expected 4' )
		}

		t5•WARN_FAIL_ERROR_DEBUG()
		{
			Log.MODE := MSG_WARN | MSG_FAIL | MSG_ERROR | MSG_DEBUG
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 5, 'Invalid number of lines: ' cnt '. Expected 5' )
		}

		t6•FAIL_INFO()
		{
			Log.MODE := MSG_FAIL | MSG_INFO
			Log_Tests.CreateLogs()

			loop read Log.FILE
				cnt := A_Index

			Yunit.Assert(cnt = 3, 'Invalid number of lines: ' cnt '. Expected 3' )
		}

	}

	class T3•HANDLING_ERRORS
	{
		t1•invalid_parameters()
		{
			try Yunit.Assert(Log('test', 'test'), 'Expected TypeError')
			catch TypeError as e
				Yunit.Assert(e.message = 'Expected an integer but got: String', 'Invalid error message')

			try Yunit.Assert(Log(18, 'test'), 'Expected ValueError')
			catch ValueError as e
				Yunit.Assert(e.message = 'Invalid message type', 'Invalid error message')

			try Yunit.Assert(Log(MSG_INFO, {}), 'Expected TypeError')
			catch TypeError as e
				Yunit.Assert(e.message = 'Expected a string but got: Object', 'Invalid error message')

			try Yunit.Assert(Log(MSG_INFO, 'this is a test', {}), 'Expected TypeError')
			catch TypeError as e
				Yunit.Assert(e.message = 'Expected a string but got: Object', 'Invalid error message')

			try Yunit.Assert(Log(MSG_INFO, 'this is a test', '2024-08-08'), 'Expected ValueError')
			catch ValueError as e
				Yunit.Assert(e.message = 'Invalid date format. Expected YYYYMMDDHHMMSS.','Invalid error message')

			try Yunit.Assert(Log(MSG_INFO, 'this is a test', A_Now, {}), 'Expected TypeError')
			catch TypeError as e
				Yunit.Assert(e.message = 'Expected a string but got: Object', 'Invalid error message')

			try Yunit.Assert(Log(MSG_INFO, 'this is a test', A_Now, 'this is a test', {}), 'Expected TypeError')
			catch TypeError as e
				Yunit.Assert(e.message = 'Expected an integer but got: Object', 'Invalid error message')

			try Yunit.Assert(Log(MSG_INFO, 'this is a test', A_Now, 'this is a test', 1, {}), 'Expected TypeError')
			catch TypeError as e
				Yunit.Assert(e.message = 'Expected a string but got: Object', 'Invalid error message')
		}
	}
}