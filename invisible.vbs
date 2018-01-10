Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run "dir /s", 0, 1
Set WinScriptHost = Nothing
