Dim sDir, shell
sDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
Set shell = CreateObject("WScript.Shell")
shell.Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & sDir & "_sistema\_setup.ps1""", 0, False
