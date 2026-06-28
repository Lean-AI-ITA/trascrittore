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

---

---

# 🎙️ Video and Audio Transcriber — English

Automatically transcribe video and audio files to text using **OpenAI Whisper** AI, completely **offline** after the first installation. Supports Italian, English, and automatic language detection.

---

## 📁 Folder Contents

```
📁 Trascrittore/
├── INSTALLA_E_AVVIA.html        ← Open this to get started (guided wizard)
├── trascrittore.py              ← Main application
├── 0.CONTROLLO_PYTHON.bat       ← Check Python installation
├── 1.CREA_AMBIENTE_PULITO.bat   ← Create virtual environment
├── 2.INSTALLA_WHISPER.bat       ← Install AI engine
├── 3.AVVIO_TRASCRITTORE.bat     ← Launch the application
└── ffmpeg.exe                   ← Download required (see below)
```

---

## 🚀 Installation (first time only)

### Recommended — HTML Wizard

1. Open **`INSTALLA_E_AVVIA.html`** in any browser (Chrome, Edge, Firefox)
2. Follow the 6 guided steps — each step includes instructions and direct links
3. Estimated time: **5–15 minutes**

### Manual — run .bat files in order

| Step | File | What it does |
|------|------|--------------|
| 0 | `0.CONTROLLO_PYTHON.bat` | Checks if Python is installed |
| 1 | `1.CREA_AMBIENTE_PULITO.bat` | Creates an isolated virtual environment |
| 2 | `2.INSTALLA_WHISPER.bat` | Downloads and installs OpenAI Whisper |
| 3 | `3.AVVIO_TRASCRITTORE.bat` | Launches the application |

---

## 📋 Requirements

### Python 3.8+
- Download from: https://www.python.org/downloads/
- **Important:** during installation, check **"Add Python to PATH"**
- Restart your PC after installation

### FFmpeg
Required to extract audio from video files before transcription.

1. Download from: https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
2. Extract the zip
3. Copy **only** `ffmpeg.exe` from the `bin/` folder into the Transcriber folder

---

## ▶️ Daily use

After installation, just double-click to launch:

```
3.AVVIO_TRASCRITTORE.bat
```

### In the app:

1. Click **Sfoglia** (Browse) and select your video or audio file
2. Choose the language *(italiano, inglese, or automatico)*
3. Click **AVVIA TRASCRIZIONE** (Start Transcription)
4. The text file is automatically saved in the **`TRASCRIZIONI/`** folder

---

## 🎥 Supported formats

| Type | Formats |
|------|---------|
| **Video** | MP4, MOV, MKV, AVI, M4V, WMV |
| **Audio** | MP3, WAV, M4A, FLAC, AAC, OGG |

---

## 🌍 Supported languages

- 🇮🇹 **Italian** (default)
- 🇬🇧 **English**
- 🌐 **Automatic** — Whisper detects the language from the audio content

---

## ⚡ Performance notes

- The **first transcription** downloads the AI model (~150 MB) — this is expected and only happens once
- Subsequent transcriptions start immediately
- Longer files take more time (roughly 1 minute per 10 minutes of audio)
- The app works **completely offline** after the initial installation

---

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| `"python" not recognized` | Restart PC after installing Python |
| Virtual environment error | Delete the `trascrittore_env/` folder and re-run `1.CREA_AMBIENTE_PULITO.bat` |
| Empty transcription | Make sure the file has audio; test with an MP3 first |
| FFmpeg not found | Make sure `ffmpeg.exe` is in the same folder as `trascrittore.py` |
| SSL / download error | Check your internet connection during Whisper installation |

---

## 💾 USB Drive usage

The entire folder can be copied to a USB drive and used on any Windows PC:

1. **Copy the entire folder** from the USB drive to the Desktop of the target PC
2. Open `INSTALLA_E_AVVIA.html` and follow the wizard
3. The virtual environment (`trascrittore_env/`) is created locally on the PC

> Working directly from a USB drive is slower and may cause errors — always copy to the Desktop first.

---

## 🤖 Built with

- [OpenAI Whisper](https://github.com/openai/whisper) — AI transcription engine
- [FFmpeg](https://ffmpeg.org/) — audio/video conversion
- [Python](https://www.python.org/) + [Tkinter](https://docs.python.org/3/library/tkinter.html) — graphical interface

---

---

## 💻 Requisiti di sistema

| Requisito | Minimo | Consigliato |
|-----------|--------|-------------|
| Sistema Operativo | Windows 10 | Windows 11 |
| RAM | 4 GB | 8 GB |
| Spazio disco libero | 1 GB | 2 GB |
| Connessione internet | Solo installazione | — |

---

## ⏱️ Tempi di elaborazione stimati

| Tipo file | Durata file | Tempo stimato |
|-----------|-------------|---------------|
| Audio breve | 1–3 min | 1–2 min |
| Audio medio | 5–10 min | 2–4 min |
| Audio lungo | 10–30 min | 3–8 min |
| Video breve | 1–5 min | 2–4 min |
| Video medio | 5–15 min | 4–8 min |
| Video lungo | 15–30 min | 5–12 min |

> Il primo utilizzo è più lento perché il modello AI viene caricato per la prima volta. I tempi dipendono anche dalla potenza del PC.

---

## 💡 Suggerimenti per risultati ottimali

**Qualità audio**
- Usa file con audio chiaro e senza rumore di fondo
- Verifica che il volume del file sia adeguato prima di trascrivere
- Per file italiani seleziona sempre la lingua "Italiano" — non "Automatico"

**Gestione file**
- Per video molto lunghi, dividili in segmenti più corti
- Preferisci formati comuni: MP4, MP3, WAV
- Non chiudere il programma durante l'elaborazione

**Cosa evitare**
- Interrompere il processo di trascrizione a metà
- File corrotti o con audio molto basso
- Avviare più trascrizioni contemporaneamente

---

## 📂 Nota pratica — cartelle create automaticamente

Dopo aver eseguito tutti i passaggi di installazione, troverai due cartelle create automaticamente:

```
trascrittore_env/     ← ambiente virtuale con tutte le dipendenze
TRASCRIZIONI/         ← dove vengono salvati i file di testo trascritti
```

**Se devi ricominciare da zero:** cancella entrambe le cartelle e riesegui i `.bat` dall'inizio (passo 1 → passo 2 → passo 3).

**Se l'installazione è già completa:** basta avviare direttamente `3.AVVIO_TRASCRITTORE.bat` — non serve rieseguire i passi precedenti ogni volta.

---

## 📋 Struttura completa della cartella

```
📁 Trascrittore/
├── 📄 INSTALLA_E_AVVIA.html
├── 📄 0.CONTROLLO_PYTHON.bat
├── 📄 1.CREA_AMBIENTE_PULITO.bat
├── 📄 2.INSTALLA_WHISPER.bat
├── 📄 3.AVVIO_TRASCRITTORE.bat
├── 📄 trascrittore.py
├── 📄 ffmpeg.exe
├── 📁 trascrittore_env/        ← creata automaticamente
└── 📁 TRASCRIZIONI/            ← creata automaticamente
    ├── 📄 video1_trascrizione.txt
    └── 📄 audio1_trascrizione.txt
```

---

## System Requirements (English)

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Operating System | Windows 10 | Windows 11 |
| RAM | 4 GB | 8 GB |
| Free disk space | 1 GB | 2 GB |
| Internet connection | Installation only | — |

---

## ⏱️ Estimated processing times (English)

| File type | File duration | Estimated time |
|-----------|---------------|----------------|
| Short audio | 1–3 min | 1–2 min |
| Medium audio | 5–10 min | 2–4 min |
| Long audio | 10–30 min | 3–8 min |
| Short video | 1–5 min | 2–4 min |
| Medium video | 5–15 min | 4–8 min |
| Long video | 15–30 min | 5–12 min |

> The first run is slower because the AI model loads for the first time. Times also depend on your PC's processing power.

---

## 💡 Tips for best results (English)

**Audio quality**
- Use files with clear audio and minimal background noise
- Check the file volume is adequate before transcribing
- For Italian files always select "Italiano" — not "Automatico"

**File management**
- For very long videos, split them into shorter segments
- Prefer common formats: MP4, MP3, WAV
- Do not close the app during processing

**What to avoid**
- Interrupting the transcription mid-process
- Corrupted files or files with very low audio
- Running multiple transcriptions at the same time

---

## 📂 Practical note — auto-created folders (English)

After completing the installation steps, two folders are created automatically:

```
trascrittore_env/     ← virtual environment with all dependencies
TRASCRIZIONI/         ← where transcribed text files are saved
```

**If you need to start over:** delete both folders and re-run the `.bat` files from the beginning (step 1 → step 2 → step 3).

**If installation is already complete:** just launch `3.AVVIO_TRASCRITTORE.bat` directly — no need to repeat the previous steps every time.
