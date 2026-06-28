' Crea un collegamento "Avvia Trascrittore.lnk" nella stessa cartella
' con icona di Windows incorporata. Doppio click = avvia l'app.
Dim oWS, sDir, oLink

Set oWS = WScript.CreateObject("WScript.Shell")
sDir    = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))

Set oLink = oWS.CreateShortcut(sDir & "Avvia Trascrittore.lnk")
oLink.TargetPath       = sDir & "Trascrittore.exe"
oLink.WorkingDirectory = sDir
oLink.Description      = "Trascrittore AI Portable — nessuna installazione"
oLink.IconLocation     = sDir & "Trascrittore.exe,0"
oLink.Save

MsgBox "Collegamento creato!" & Chr(10) & _
       "Usa 'Avvia Trascrittore.lnk' per avviare l'app.", _
       vbInformation, "Trascrittore AI"
