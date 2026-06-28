Dim sDir, shell
sDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
Set shell = CreateObject("WScript.Shell")
shell.Run "powershell -sta -NonInteractive -ExecutionPolicy Bypass -File """ & sDir & "_sistema\_setup.ps1""", 7, False
