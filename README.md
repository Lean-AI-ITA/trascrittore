# 🎙️ Trascrittore Video e Audio

Trascrivi automaticamente video e audio in testo usando l'intelligenza artificiale **OpenAI Whisper**, completamente **offline** dopo la prima installazione. Supporta italiano, inglese e riconoscimento automatico della lingua.

---

## 📁 Contenuto della cartella

```
📁 Trascrittore/
├── INSTALLA_E_AVVIA.html        ← Apri questo per iniziare (wizard guidato)
├── trascrittore.py              ← Applicazione principale
├── 0.CONTROLLO_PYTHON.bat       ← Verifica installazione Python
├── 1.CREA_AMBIENTE_PULITO.bat   ← Crea l'ambiente virtuale
├── 2.INSTALLA_WHISPER.bat       ← Installa il motore AI
├── 3.AVVIO_TRASCRITTORE.bat     ← Avvia l'applicazione
└── ffmpeg.exe                   ← Da scaricare (vedi sotto)
```

---

## 🚀 Installazione (prima volta)

### Metodo consigliato — Wizard HTML

1. Apri **`INSTALLA_E_AVVIA.html`** in qualsiasi browser (Chrome, Edge, Firefox)
2. Segui i 6 passi guidati — ogni passo ha istruzioni e link diretti
3. Tempo stimato: **5–15 minuti**

### Metodo manuale — file .bat in sequenza

Esegui i file nell'ordine indicato dal numero:

| Passo | File | Cosa fa |
|-------|------|---------|
| 0 | `0.CONTROLLO_PYTHON.bat` | Verifica se Python è installato |
| 1 | `1.CREA_AMBIENTE_PULITO.bat` | Crea l'ambiente virtuale isolato |
| 2 | `2.INSTALLA_WHISPER.bat` | Scarica e installa OpenAI Whisper |
| 3 | `3.AVVIO_TRASCRITTORE.bat` | Avvia l'applicazione |

---

## 📋 Requisiti

### Python 3.8+
- Scarica da: https://www.python.org/downloads/
- **Importante:** durante l'installazione spunta **"Add Python to PATH"**
- Dopo l'installazione, riavvia il PC

### FFmpeg
Necessario per convertire i video in audio prima della trascrizione.

1. Scarica da: https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
2. Estrai lo zip
3. Copia **solo** `ffmpeg.exe` dalla cartella `bin/` nella cartella del Trascrittore

---

## ▶️ Utilizzo quotidiano

Dopo l'installazione, per avviare il trascrittore basta fare doppio click su:

```
3.AVVIO_TRASCRITTORE.bat
```

### Nell'interfaccia:

1. Clicca **Sfoglia** e seleziona il tuo file video o audio
2. Scegli la lingua *(italiano, inglese, o automatico)*
3. Clicca **AVVIA TRASCRIZIONE**
4. Il file di testo viene salvato automaticamente nella cartella **`TRASCRIZIONI/`**

---

## 🎥 Formati supportati

| Tipo | Formati |
|------|---------|
| **Video** | MP4, MOV, MKV, AVI, M4V, WMV |
| **Audio** | MP3, WAV, M4A, FLAC, AAC, OGG |

---

## 🌍 Lingue supportate

- 🇮🇹 **Italiano** (predefinito)
- 🇬🇧 **Inglese**
- 🌐 **Automatico** — Whisper rileva la lingua dal contenuto

---

## ⚡ Note sulle prestazioni

- La **prima trascrizione** scarica il modello AI (~150 MB) — è normale che sia più lenta
- Le trascrizioni successive partono immediatamente
- File più lunghi richiedono più tempo (circa 1 minuto per ogni 10 minuti di audio)
- Il programma funziona **completamente offline** dopo l'installazione iniziale

---

## 🔧 Risoluzione problemi

| Problema | Soluzione |
|----------|-----------|
| `"python" non riconosciuto` | Riavvia il PC dopo aver installato Python |
| Errore ambiente virtuale | Cancella la cartella `trascrittore_env/` e riesegui `1.CREA_AMBIENTE_PULITO.bat` |
| Trascrizione vuota | Verifica che il file abbia audio; prova prima con un MP3 |
| FFmpeg non trovato | Assicurati che `ffmpeg.exe` sia nella stessa cartella di `trascrittore.py` |
| Errore SSL / download | Controlla la connessione internet durante l'installazione di Whisper |

---

## 💾 Uso da chiavetta USB

La cartella può essere copiata su una chiavetta USB e usata su qualsiasi PC Windows:

1. **Copia l'intera cartella** dalla chiavetta sul Desktop del PC di destinazione
2. Apri `INSTALLA_E_AVVIA.html` e segui il wizard
3. L'ambiente virtuale (`trascrittore_env/`) viene creato localmente sul PC

> Lavorare direttamente dalla chiavetta è più lento e può causare errori — copia sempre prima sul Desktop.

---

## 🤖 Tecnologie utilizzate

- [OpenAI Whisper](https://github.com/openai/whisper) — motore di trascrizione AI
- [FFmpeg](https://ffmpeg.org/) — conversione audio/video
- [Python](https://www.python.org/) + [Tkinter](https://docs.python.org/3/library/tkinter.html) — interfaccia grafica
