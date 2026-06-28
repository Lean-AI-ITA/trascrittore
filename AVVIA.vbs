' Apre l'installer HTML — non serve piu toccare questo file
Dim sDir, shell
sDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
Set shell = CreateObject("WScript.Shell")
shell.Run "mshta """ & sDir & "AVVIA.hta""", 1, False
