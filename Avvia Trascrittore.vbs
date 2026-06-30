Dim p, sh
p = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
Set sh = CreateObject("WScript.Shell")
sh.Run "mshta.exe """ & p & "_sistema\AVVIA.hta""", 1, False
