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

}