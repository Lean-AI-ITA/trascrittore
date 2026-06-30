# Trascrittore AI — Portable

Trascrivi video e audio in testo con intelligenza artificiale, **offline dopo la prima installazione**. Funziona su qualsiasi PC Windows senza preparazione: scarica e configura tutto da solo.

---

## Download

**[⬇ Scarica ZIP](https://github.com/lean-ai-ita/trascrittore/archive/refs/heads/portable.zip)**

Estrai lo zip, apri la cartella ed è pronto.

---

## Come si usa

Doppio click su **`AVVIA.hta`** — fine.

Non serve installare niente prima. Non serve aprire terminali. Non serve cercare file su internet. L'applicazione fa tutto da sola.

---

## Cosa succede al primo avvio

Quando clicchi su `AVVIA.hta` per la prima volta, si apre una finestra grafica che esegue in sequenza:

**Passo 1/5 — Python**
Controlla se Python è già installato sul PC. Se non c'è, lo scarica e lo installa in silenzio (~25 MB, 1-2 minuti).

**Passo 2/5 — Ambiente virtuale**
Crea una cartella isolata con tutte le dipendenze del trascrittore, separata dal resto del PC.

**Passo 3/5 — faster-whisper (~200 MB, 2-5 min)**
Installa il motore AI di trascrizione. Durante l'installazione vedi scorrere i pacchetti scaricati e una barra che avanza in tempo reale.

**Passo 4/5 — FFmpeg (~80 MB, 1-2 min)**
Scarica il convertitore audio/video necessario per i file MP4, MOV, MKV ecc. Il progresso è visibile in MB: `12 MB / 80 MB (15%)`.

**Passo 5/5 — Modello Whisper base (~150 MB, 1-3 min)**
Scarica il modello di intelligenza artificiale. Il progresso è visibile in MB: `47 MB / 150 MB (31%)`.

Al termine, il trascrittore si apre automaticamente.

**Tempo totale prima installazione: circa 10-20 minuti** (dipende dalla connessione internet).

---

## Avvii successivi

Dal secondo avvio in poi, `AVVIA.hta` riconosce che tutto è già installato e apre direttamente il trascrittore in pochi secondi.

---

## Utilizzo del trascrittore

1. Clicca **Sfoglia** e seleziona un file video o audio
2. Scegli la lingua (Italiano, Inglese, o Automatico)
3. Clicca **AVVIA TRASCRIZIONE**
4. Il testo viene salvato automaticamente nella cartella `TRASCRIZIONI/`

---

## Formati supportati

| Video | Audio |
|-------|-------|
| MP4, MOV, MKV, AVI, M4V, WMV | MP3, WAV, M4A, FLAC, AAC, OGG |

---

## Requisiti

| | Minimo | Consigliato |
|-|--------|-------------|
| Sistema operativo | Windows 10 | Windows 11 |
| RAM | 4 GB | 8 GB |
| Spazio disco libero | **1 GB** durante installazione | **1,5 GB** per lavorare comodi |
| Internet | Solo durante la prima installazione | — |
| CPU | Qualsiasi (anche vecchi PC) | — |

### Dettaglio spazio disco

| Cosa occupa spazio | Dimensione |
|--------------------|------------|
| Ambiente Python (`trascrittore_env/`) | ~500 MB |
| Modello Whisper base (`models/`) | ~150 MB |
| FFmpeg (`ffmpeg.exe`) | ~80 MB |
| File temporanei durante installazione | ~300 MB (poi cancellati) |
| **Totale a regime** | **~730 MB** |

> Durante l'installazione servono circa **1 GB libero** perché i file temporanei e i file finali coesistono. Dopo l'installazione i temporanei vengono cancellati.

---

## Cosa occupa spazio e dove

Tutto rimane nella cartella dove si trova `AVVIA.hta`:

```
TrascrittoreAI/
├── AVVIA.hta                   ← l'unica cosa da cliccare
├── ffmpeg.exe                  ← scaricato automaticamente (~80 MB)
├── trascrittore_env/           ← ambiente Python (~500 MB)
├── models/                     ← modello Whisper (~150 MB)
├── TRASCRIZIONI/               ← i tuoi file di testo (dimensione variabile)
└── _sistema/
    └── trascrittore_portable.py
```

**Per disinstallare: cancella la cartella.** Nessuna traccia nel registro di Windows, nessun file in `Program Files`. L'unica eccezione è Python stesso, se il programma lo ha installato: rimane in `%LocalAppData%\Programs\Python` e va rimosso da Impostazioni → App se non lo si vuole più.

---

## Uso da chiavetta USB

La cartella può essere copiata su una chiavetta e portata su altri PC. Su ogni nuovo PC, al primo avvio `AVVIA.hta` rileva cosa manca e lo scarica automaticamente. I download non si ripetono finché la cartella rimane intatta.

> Consiglio: copia la cartella dal USB al Desktop prima di usarla. Lavorare direttamente dalla chiavetta è più lento e può causare errori di scrittura.

---

## Problemi comuni

**L'installazione si blocca subito / "non risponde"**
L'antivirus potrebbe bloccare i file temporanei creati in `%TEMP%`. Aggiungi la cartella alle esclusioni dell'antivirus e riprova.

**"Python installato ma non trovato nel PATH"**
Riavvia il PC e riapri `AVVIA.hta`. Il PATH si aggiorna solo dopo il riavvio.

**Download FFmpeg fallito**
Il trascrittore continua comunque, ma potrà trascrivere solo file audio (MP3, WAV). Per aggiungere FFmpeg dopo, riavvia `AVVIA.hta`: rileva che manca e lo riscarica.

**Trascrizione vuota o silenziosa**
Il file probabilmente non ha traccia audio. Prova ad aprirlo con un player per verificare.

**Prima trascrizione molto lenta**
Il modello AI viene caricato in memoria per la prima volta. Le trascrizioni successive sono più rapide.
