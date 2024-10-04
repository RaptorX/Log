#Requires Autohotkey v2.0+

#Include .\inc\log.h.ahk

/**
 *
 * @param {Number|MSG_INFO|MSG_WARN|MSG_FAIL|MSG_ERROR|MSG_DEBUG} MSG_TYPE type of message that will be logged
 * @param {String} MESSAGE custom message that explains the failure
 * @param {Number|String} DATE can be YYYYMMDDHHMMSS or yyyy-MM-dd HH:mm:ss
 * @param {Number|String} WHAT defines what has failed
 * @param {Number|String} LINE line number of the file where the failure occurred
 * @param {Number|String} FILE file where the failure occurred
 */
class Log
{
	/** @type {DEBUG_OFF|DEBUG_INFO|DEBUG_WARNINGS|DEBUG_RESULTS|DEBUG_ERRORS|DEBUG_ALL} */
	static MODE        := DEBUG_OFF

	/** @type {DEBUG_OFF|DEBUG_WINDOW|DEBUG_SCREENSHOT} */
	static OPTIONS     := DEBUG_OFF
	static FILE        := 'logs\errors.log'
	static IMGPATH     := 'logs\imgs'
	static SCFOLDER    := A_MyDocuments '\..\Pictures\Screenshots'
	static DATE_FORMAT := 'yyyy-MM-dd HH:mm:ss'
	static DELIMITER   := '`t'

	static window      := Gui('-MaximizeBox -MinimizeBox')
	static lv          := Log.window.AddListView('w700 r20', ['Date','Type','Message','What','Line','File', 'Stack'])

	static __New()
	{
		Log.window.OnEvent('Close', (*)=>(Log.lv.Opt('-Redraw'), Log.window.Hide()))
		Log.window.SetFont('s10', 'consolas')
		
		Log.lv.headers := ['Date','Type','Message','What','Line','File', 'Stack']
		list := IL_Create(5)
		Log.lv.icons := Map(
			MSG_INFO , 282,
			MSG_WARN , 80,
			MSG_FAIL , 208,
			MSG_ERROR, 85,
			MSG_DEBUG, 77,
		)
		Log.lv.SetImageList(list)
		for type, icon in Log.lv.icons
			Log.lv.icons[type] := IL_Add(list, "C:\Windows\system32\imageres.dll", icon)
		Log.lv.icons[MSG_PASS] := IL_Add(list, "C:\Windows\system32\shell32.dll", 301)

		for header in Log.lv.headers
		{
			if header != 'Stack'
				continue

			stack_col := A_Index
			break
		}

		Log.lv.OnEvent('DoubleClick', (*)=>Log.ShowStack(ListViewGetContent('col' stack_col, Log.lv)))
		Log.lv.Opt('-Redraw')

		if FileExist(Log.FILE)
			return

		DirCreate Log.IMGPATH

		line := ''
		for header in Log.lv.headers
			line .= header . Log.DELIMITER
		line := RTrim(line, Log.DELIMITER)

		FileAppend line '`n', Log.FILE, 'utf-8'
	}

	/**
	 *
	 * @param {MSG_INFO|MSG_WARN|MSG_FAIL|MSG_ERROR|MSG_DEBUG} MSG_TYPE type of message that will be logged
	 * @param {String|Error}  MESSAGE custom message that explains the failure
	 * @param {Number|String} DATE can be YYYYMMDDHHMMSS or yyyy-MM-dd HH:mm:ss
	 * @param {Number|String} WHAT defines what has failed
	 * @param {Number|String} LINE line number of the file where the failure occurred
	 * @param {Number|String} FILE file where the failure occurred
	 */
	__New(MSG_TYPE, MESSAGE, DATE?, WHAT?, LINE?, FILE?, STACK?)
	{
		static template := '{2}{1}{3}{1}{4}{1}{5}{1}{6}{1}{7}{1}{8}'

		if !(MSG_TYPE is Integer)
			throw TypeError('Expected an integer but got: ' type(MSG_TYPE), A_ThisFunc, 'MSG_TYPE')
		if !(MSG_TYPE ~= MSG_INFO '|' MSG_WARN '|' MSG_PASS '|' MSG_FAIL '|' MSG_ERROR '|' MSG_DEBUG)
			throw ValueError('Invalid message type', A_ThisFunc, 'MSG_TYPE: ' MSG_TYPE)
		if IsSet(DATE) && !(DATE is String)
			throw TypeError('Expected a string but got: ' type(DATE), A_ThisFunc, 'DATE')
		if IsSet(DATE) && !(DATE ~= '\d{14}')
			throw ValueError('Invalid date format. Expected YYYYMMDDHHMMSS.',A_ThisFunc,'DATE: ' DATE)
		if IsSet(WHAT) && !(WHAT is String)
			throw TypeError('Expected a string but got: ' type(WHAT), A_ThisFunc, 'WHAT')
		if IsSet(LINE) && !(LINE is Integer)
			throw TypeError('Expected an integer but got: ' type(LINE), A_ThisFunc, 'LINE')
		if IsSet(FILE) && !(FILE is String)
			throw TypeError('Expected a string but got: ' type(FILE), A_ThisFunc, 'FILE')

		if MESSAGE is Error
		{
			WHAT    := MESSAGE.What
			LINE    := MESSAGE.Line
			FILE    := MESSAGE.File
			STACK   := RegExReplace(MESSAGE.Stack, '\R', '¶')
			MESSAGE := MESSAGE.Message
		}
		else if !(MESSAGE is String)
			throw TypeError('Expected a string but got: ' Type(MESSAGE), A_ThisFunc, 'MESSAGE')

		if Log.MODE = DEBUG_OFF
		|| Log.MODE & MSG_TYPE = false
			return

		FORMATTED_DATE := DATE ?? FormatTime(A_Now, Log.DATE_FORMAT)
		FORMATTED_DATE := FORMATTED_DATE ~= '\d{14}' ? FormatTime(FORMATTED_DATE, Log.DATE_FORMAT) : FORMATTED_DATE

		switch MSG_TYPE
		{
		case MSG_INFO:  MSG_TYPE_STR := 'INFO'
		case MSG_WARN:  MSG_TYPE_STR := 'WARN'
		case MSG_PASS:  MSG_TYPE_STR := 'PASS'
		case MSG_FAIL:  MSG_TYPE_STR := 'FAIL'
		case MSG_ERROR: MSG_TYPE_STR := 'ERROR'
		case MSG_DEBUG: MSG_TYPE_STR := 'DEBUG'
		default:
			MSG_TYPE_STR := 'INFO'
		}

		if Log.MODE & MSG_DEBUG
			OutputDebug MESSAGE '`n'


		line := Format(
			template,
			Log.DELIMITER,
			FORMATTED_DATE,
			MSG_TYPE_STR,
			MESSAGE,
			WHAT ?? '',
			LINE ?? '',
			FILE ?? '',
			STACK ?? ''
		)
		Log.lv.Add('Vis Icon' Log.lv.icons[MSG_TYPE], StrSplit(line, Log.DELIMITER)*)

		if Log.OPTIONS & DEBUG_WINDOW
			Log.Show()

		if MSG_TYPE = MSG_ERROR
		&& Log.OPTIONS & DEBUG_SCREENSHOT
		{
			indx := RegRead('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer', 'ScreenshotIndex', 1)
			screenshot := Format( Log.SCFOLDER '\*({}).png', indx)

			Sleep 500
			Send '#{PrintScreen}'
			while !FileExist(screenshot)
				Sleep 10

			FileMove screenshot, Log.IMGPATH '\error-' indx '.png'
		}

		FileAppend line '`n', Log.FILE, 'utf-8'
	}

	static Show(opts?)
	{
		for header in Log.lv.headers
		{
			switch header
			{
			case 'Message':
				options := 150
			case 'Stack':
				options := 0
			default:
				options := 'AutoHdr'
			}
			Log.lv.ModifyCol(A_Index, options)
		}
		Log.lv.Opt('+Redraw')
		Log.window.Show('hide')
		Log.window.GetPos(,,, &h)
		Log.window.Show(opts??'x' A_ScreenWidth - (700+log.window.MarginX*3) ' y' (A_ScreenHeight/2) - (h/2))
	}
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