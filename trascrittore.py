import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import threading
import os
import sys
from pathlib import Path
import subprocess
import time

class TrascrittoreVideoAudio:
    def __init__(self, root):
        self.root = root
        self.root.title("Trascrittore Video e Audio - ITALIANO")
        self.root.geometry("700x550")
        
        # Crea la cartella TRASCRIZIONI nella directory corrente
        self.cartella_trascrizioni = Path("TRASCRIZIONI")
        self.cartella_trascrizioni.mkdir(exist_ok=True)
        
        self.setup_ui()
        self.log("✅ Pronto - Seleziona un file video o audio")
        self.log("🌍 LINGUA IMPOSTATA: ITALIANO")
        self.log(f"📁 Trascrizioni salvate in: {self.cartella_trascrizioni}")
        
    def setup_ui(self):
        main_frame = ttk.Frame(self.root, padding="15")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        title_label = ttk.Label(main_frame, text="TRASCRITTORE VIDEO e AUDIO - ITALIANO", font=("Arial", 16, "bold"))
        title_label.pack(pady=(0, 20))
        
        file_frame = ttk.LabelFrame(main_frame, text="Selezione File", padding="10")
        file_frame.pack(fill=tk.X, pady=(0, 15))
        
        self.file_path = tk.StringVar()
        
        entry_frame = ttk.Frame(file_frame)
        entry_frame.pack(fill=tk.X)
        
        ttk.Entry(entry_frame, textvariable=self.file_path, width=60).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        ttk.Button(entry_frame, text="Sfoglia", command=self.scegli_file).pack(side=tk.RIGHT)
        
        # Pulsante per aprire cartella trascrizioni
        ttk.Button(main_frame, text="📁 APRI CARTELLA TRASCRIZIONI", command=self.apri_cartella_trascrizioni).pack(pady=5)
        
        # Frame per le opzioni
        opzioni_frame = ttk.LabelFrame(main_frame, text="Opzioni Trascrizione", padding="10")
        opzioni_frame.pack(fill=tk.X, pady=(0, 15))
        
        # Selezione lingua
        lingua_frame = ttk.Frame(opzioni_frame)
        lingua_frame.pack(fill=tk.X, pady=5)
        
        ttk.Label(lingua_frame, text="Lingua:").pack(side=tk.LEFT)
        self.lingua_var = tk.StringVar(value="italiano")
        lingua_combo = ttk.Combobox(lingua_frame, textvariable=self.lingua_var, 
                                   values=["italiano", "inglese", "automatico"], 
                                   state="readonly", width=15)
        lingua_combo.pack(side=tk.LEFT, padx=(10, 0))
        
        self.btn_avvia = ttk.Button(main_frame, text="AVVIA TRASCRIZIONE", command=self.avvia_trascrizione)
        self.btn_avvia.pack(pady=10)
        
        # Progress bar
        self.progress_label = ttk.Label(main_frame, text="Progresso: 0%")
        self.progress_label.pack()
        
        self.progress = ttk.Progressbar(main_frame, mode='determinate')
        self.progress.pack(fill=tk.X, pady=(0, 15))
        
        # Info supporto formati
        info_frame = ttk.LabelFrame(main_frame, text="Formati Supportati", padding="5")
        info_frame.pack(fill=tk.X, pady=(0, 15))
        
        info_text = tk.Text(info_frame, height=3, wrap=tk.WORD, font=("Consolas", 8), bg=self.root.cget('bg'), relief='flat')
        info_text.insert(tk.END, "🎥 Video: MP4, MOV, MKV, AVI, M4V, WMV\n🎵 Audio: MP3, WAV, M4A, FLAC, AAC, OGG\n🌍 Lingua: Italiano (predefinita)\n📝 Output: File di testo nella cartella TRASCRIZIONI")
        info_text.config(state=tk.DISABLED)
        info_text.pack(fill=tk.X)
        
        log_frame = ttk.LabelFrame(main_frame, text="Log", padding="10")
        log_frame.pack(fill=tk.BOTH, expand=True)
        
        self.log_text = tk.Text(log_frame, height=15, wrap=tk.WORD, font=("Consolas", 9))
        
        scrollbar = ttk.Scrollbar(log_frame, orient="vertical", command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=scrollbar.set)
        
        self.log_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def log(self, message):
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        self.root.update()
    
    def aggiorna_progresso(self, percentuale):
        self.progress['value'] = percentuale
        self.progress_label['text'] = f"Progresso: {percentuale}%"
        self.root.update()
    
    def apri_cartella_trascrizioni(self):
        """Apre la cartella delle trascrizioni"""
        try:
            os.startfile(str(self.cartella_trascrizioni))
            self.log("📁 Cartella trascrizioni aperta")
        except:
            self.log("❌ Impossibile aprire la cartella")
    
    def scegli_file(self):
        file_path = filedialog.askopenfilename(
            title="Seleziona un file video o audio",
            filetypes=[
                ("File video", "*.mp4 *.mov *.mkv *.avi *.m4v *.wmv"),
                ("File audio", "*.mp3 *.wav *.m4a *.flac *.aac *.ogg"),
                ("Tutti i file", "*.*")
            ]
        )
        if file_path:
            self.file_path.set(file_path)
            self.log(f"📁 File selezionato: {os.path.basename(file_path)}")
    
    def avvia_trascrizione(self):
        if not self.file_path.get():
            messagebox.showwarning("Attenzione", "Seleziona prima un file!")
            return
        
        self.btn_avvia.config(state="disabled")
        self.progress['value'] = 0
        self.progress_label['text'] = "Progresso: 0%"
        
        lingua_scelta = self.lingua_var.get()
        self.log(f"🌍 Lingua selezionata: {lingua_scelta.upper()}")
        self.log("Avvio trascrizione...")
        
        thread = threading.Thread(target=self.elabora_trascrizione)
        thread.daemon = True
        thread.start()
    
    def estrai_audio_da_video(self, video_path, audio_path):
        """Estrae audio da video usando FFmpeg"""
        try:
            cmd = [
                'ffmpeg', '-i', video_path,
                '-vn',                    # No video
                '-acodec', 'pcm_s16le',   # Codec audio
                '-ar', '16000',           # Sample rate 16kHz
                '-ac', '1',               # Mono
                '-y',                     # Overwrite
                audio_path
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            return result.returncode == 0
        except Exception as e:
            self.log(f"❌ Errore FFmpeg: {str(e)}")
            return False
    
    def converti_audio(self, audio_input, audio_output):
        """Converte audio in formato compatibile con Whisper"""
        try:
            cmd = [
                'ffmpeg', '-i', audio_input,
                '-acodec', 'pcm_s16le',   # Codec audio
                '-ar', '16000',           # Sample rate 16kHz
                '-ac', '1',               # Mono
                '-y',                     # Overwrite
                audio_output
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            return result.returncode == 0
        except Exception as e:
            self.log(f"❌ Errore conversione audio: {str(e)}")
            return False
    
    def elabora_trascrizione(self):
        try:
            file_path = self.file_path.get()
            file_obj = Path(file_path)
            estensione = file_obj.suffix.lower()
            
            self.log(f"📂 File: {file_obj.name}")
            self.log(f"📊 Tipo: {estensione}")
            
            # Determina se è video o audio
            is_video = estensione in ['.mp4', '.mov', '.mkv', '.avi', '.m4v', '.wmv']
            is_audio = estensione in ['.mp3', '.wav', '.m4a', '.flac', '.aac', '.ogg']
            
            if not (is_video or is_audio):
                self.log("❌ Formato file non supportato!")
                messagebox.showerror("Errore", "Formato file non supportato!")
                return
            
            audio_path = None
            
            if is_video:
                self.log("1. Estrazione audio dal video...")
                self.aggiorna_progresso(10)
                
                audio_path = file_obj.parent / f"temp_audio_{int(time.time())}.wav"
                
                if not self.estrai_audio_da_video(file_path, str(audio_path)):
                    self.log("❌ ERRORE: Impossibile estrarre audio dal video")
                    self.log("💡 Verifica che ffmpeg.exe sia nella cartella")
                    return
                
                self.log("✅ Audio estratto correttamente")
                
            elif is_audio:
                self.log("1. Conversione audio per Whisper...")
                self.aggiorna_progresso(10)
                
                # Se è già WAV e nei parametri giusti, usa direttamente
                if estensione == '.wav':
                    audio_path = file_obj
                    self.log("✅ File audio WAV - uso direttamente")
                else:
                    audio_path = file_obj.parent / f"temp_audio_{int(time.time())}.wav"
                    if not self.converti_audio(file_path, str(audio_path)):
                        self.log("❌ ERRORE: Impossibile convertire audio")
                        return
                    self.log("✅ Audio convertito correttamente")
            
            # Controlla se il file audio è stato creato
            if audio_path and audio_path.exists():
                size_mb = audio_path.stat().st_size / (1024 * 1024)
                self.log(f"📊 Dimensione file audio: {size_mb:.2f} MB")
                if size_mb < 0.1:
                    self.log("⚠️  Attenzione: file audio molto piccolo, potrebbe essere vuoto")
            else:
                self.log("❌ File audio non creato")
                return
            
            self.log("2. Caricamento modello Whisper...")
            self.aggiorna_progresso(30)
            
            import whisper
            model = whisper.load_model("base")
            self.log("✅ Modello caricato")
            
            self.log("3. Trascrizione in corso...")
            self.log("🕒 Questo potrebbe richiedere alcuni minuti...")
            self.aggiorna_progresso(50)
            
            # Imposta la lingua in base alla selezione
            lingua_scelta = self.lingua_var.get()
            if lingua_scelta == "italiano":
                language = "it"
                self.log("🇮🇹 Trascrizione in ITALIANO...")
            elif lingua_scelta == "inglese":
                language = "en"
                self.log("🇬🇧 Trascrizione in INGLESE...")
            else:
                language = None
                self.log("🌍 Riconoscimento lingua automatico...")
            
            # Trascrizione con lingua specificata
            result = model.transcribe(
                str(audio_path),
                language=language,
                verbose=True,
                no_speech_threshold=0.6
            )
            
            self.aggiorna_progresso(80)
            
            # Controlla se la trascrizione ha contenuto
            testo_trascritto = result["text"].strip()
            if not testo_trascritto:
                self.log("❌ ATTENZIONE: Trascrizione vuota!")
                self.log("💡 Possibili cause:")
                self.log("   - File senza audio")
                self.log("   - Audio troppo basso")
                self.log("   - Formato audio non supportato")
                messagebox.showwarning("Attenzione", "Trascrizione vuota! Il file potrebbe non avere audio.")
                return
            
            # Crea il nome del file usando il nome originale
            nome_file = file_obj.stem
            output_file = self.cartella_trascrizioni / f"{nome_file}_trascrizione.txt"
            
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(testo_trascritto)
            
            # Pulizia file temporanei
            try:
                if audio_path != file_obj:  # Non eliminare il file originale
                    os.remove(audio_path)
            except:
                pass
            
            self.aggiorna_progresso(100)
            
            self.log(f"💾 File salvato: {output_file.name}")
            self.log(f"📝 Caratteri trascritti: {len(testo_trascritto)}")
            self.log(f"📁 Posizione: {self.cartella_trascrizioni}")
            
            # Anteprima del testo
            anteprima = testo_trascritto[:200] + "..." if len(testo_trascritto) > 200 else testo_trascritto
            self.log(f"📄 Anteprima: {anteprima}")
            
            self.log("🎉 TRASCRIZIONE COMPLETATA!")
            
            messagebox.showinfo("Completato", 
                              f"Trascrizione salvata in:\n{output_file}\n\n"
                              f"Caratteri: {len(testo_trascritto)}\n"
                              f"Cartella: {self.cartella_trascrizioni}")
            
        except ImportError as e:
            self.log("❌ ERRORE: Whisper non installato correttamente")
            self.log("💡 Esegui 2.INSTALLA_WHISPER.bat")
            messagebox.showerror("Errore", "Whisper non installato!\nEsegui 2.INSTALLA_WHISPER.bat")
        
        except Exception as e:
            self.log("❌ ERRORE: " + str(e))
            messagebox.showerror("Errore", str(e))
        
        finally:
            self.btn_avvia.config(state="normal")

if __name__ == "__main__":
    root = tk.Tk()
    app = TrascrittoreVideoAudio(root)
    root.mainloop()