import tkinter as tk
from tkinter import filedialog, messagebox
import threading
import os
from pathlib import Path
import subprocess
import time

# ── Design tokens (AI-Native UI dark theme) ────────────────────────────────
BG        = "#0F0F23"
SURFACE   = "#1A1A35"
SURFACE2  = "#22223F"
BORDER    = "#2E2E5A"
ACCENT    = "#F97316"
ACCENT_DIM= "#C2580E"
GREEN     = "#22C55E"
RED       = "#EF4444"
YELLOW    = "#F59E0B"
FG        = "#F8FAFC"
FG_MUTED  = "#8B8BA8"
FG_DIM    = "#555578"
FONT_MAIN = ("Segoe UI", 10)
FONT_SM   = ("Segoe UI", 9)
FONT_LG   = ("Segoe UI", 13, "bold")
FONT_XL   = ("Segoe UI", 15, "bold")
FONT_MONO = ("Consolas", 9)
RADIUS    = 8


def rounded_rect(canvas, x1, y1, x2, y2, r, **kwargs):
    pts = [
        x1+r, y1,   x2-r, y1,
        x2,   y1,   x2,   y1+r,
        x2,   y2-r, x2,   y2,
        x2-r, y2,   x1+r, y2,
        x1,   y2,   x1,   y2-r,
        x1,   y1+r, x1,   y1,
        x1+r, y1,
    ]
    return canvas.create_polygon(pts, smooth=True, **kwargs)


class ModernButton(tk.Canvas):
    def __init__(self, parent, text, command=None, style="primary",
                 width=180, height=40, font=None, **kwargs):
        super().__init__(parent, width=width, height=height,
                         bg=BG, highlightthickness=0, **kwargs)
        self.command   = command
        self.text      = text
        self.style     = style
        self.w         = width
        self.h         = height
        self._font     = font or ("Segoe UI", 10, "bold")
        self._enabled  = True
        self._draw("normal")
        self.bind("<Enter>",           lambda e: self._draw("hover"))
        self.bind("<Leave>",           lambda e: self._draw("normal"))
        self.bind("<ButtonPress-1>",   lambda e: self._draw("press"))
        self.bind("<ButtonRelease-1>", self._click)

    def _colors(self, state):
        if not self._enabled:
            return FG_DIM, SURFACE, BORDER
        if self.style == "primary":
            base, text = ACCENT, "#fff"
            if state == "hover": base = "#FF8C3A"
            if state == "press": base = ACCENT_DIM
            return text, base, base
        if self.style == "ghost":
            base, text = SURFACE2, FG_MUTED
            if state == "hover": text = FG; base = BORDER
            if state == "press": base = SURFACE
            return text, base, BORDER
        if self.style == "danger":
            base, text = "#2D1515", RED
            if state == "hover": base = "#3D1A1A"
            return text, base, RED
        return FG, SURFACE2, BORDER

    def _draw(self, state):
        self.delete("all")
        text_c, fill, outline = self._colors(state)
        rounded_rect(self, 2, 2, self.w-2, self.h-2, RADIUS,
                     fill=fill, outline=outline)
        self.create_text(self.w//2, self.h//2, text=self.text,
                         fill=text_c, font=self._font)

    def _click(self, e):
        self._draw("hover")
        if self._enabled and self.command:
            self.command()

    def set_enabled(self, val):
        self._enabled = val
        self._draw("normal")

    def configure_text(self, text):
        self.text = text
        self._draw("normal")


class PulseIndicator(tk.Canvas):
    def __init__(self, parent, **kwargs):
        super().__init__(parent, width=12, height=12,
                         bg=SURFACE, highlightthickness=0, **kwargs)
        self._running = False
        self._step    = 0

    def start(self):
        self._running = True
        self._animate()

    def stop(self):
        self._running = False
        self.delete("all")

    def _animate(self):
        if not self._running:
            return
        self._step = (self._step + 1) % 20
        t = abs(self._step - 10) / 10
        r = int(249 + (34-249)*t)
        g = int(115 + (197-115)*t)
        b = int(22  + (94-22)*t)
        color = f"#{r:02x}{g:02x}{b:02x}"
        self.delete("all")
        self.create_oval(2, 2, 10, 10, fill=color, outline="")
        self.after(80, self._animate)


class TrascrittoreVideoAudio:
    def __init__(self, root):
        self.root = root
        self.root.title("Trascrittore AI")
        self.root.geometry("760x620")
        self.root.minsize(680, 560)
        self.root.configure(bg=BG)

        self.cartella_trascrizioni = Path("TRASCRIZIONI")
        self.cartella_trascrizioni.mkdir(exist_ok=True)
        self.file_path  = tk.StringVar()
        self.lingua_var = tk.StringVar(value="italiano")
        self._track_w   = 0

        self._build_ui()
        self._log("Pronto — seleziona un file video o audio", "ok")
        self._log(f"Trascrizioni salvate in: {self.cartella_trascrizioni}", "muted")

    # ── UI BUILD ──────────────────────────────────────────────────────────────

    def _build_ui(self):
        # Header
        hdr = tk.Frame(self.root, bg=SURFACE, height=56)
        hdr.pack(fill=tk.X)
        hdr.pack_propagate(False)

        inner = tk.Frame(hdr, bg=SURFACE)
        inner.pack(fill=tk.BOTH, expand=True, padx=20)

        tk.Label(inner, text="◉", font=("Segoe UI", 18),
                 fg=ACCENT, bg=SURFACE).pack(side=tk.LEFT, pady=12)
        tk.Label(inner, text="  Trascrittore AI", font=FONT_XL,
                 fg=FG, bg=SURFACE).pack(side=tk.LEFT, pady=12)

        # Language selector (top-right)
        pill = tk.Frame(inner, bg=SURFACE2, padx=10, pady=4)
        pill.pack(side=tk.RIGHT, pady=14)
        tk.Label(pill, text="Lingua:", font=FONT_SM,
                 fg=FG_MUTED, bg=SURFACE2).pack(side=tk.LEFT)
        om = tk.OptionMenu(pill, self.lingua_var, "italiano", "inglese", "automatico")
        om.config(bg=SURFACE2, fg=FG, font=FONT_SM, relief="flat",
                  borderwidth=0, highlightthickness=0,
                  activebackground=BORDER, activeforeground=FG)
        om["menu"].config(bg=SURFACE2, fg=FG, font=FONT_SM,
                          activebackground=ACCENT, activeforeground="#fff")
        om.pack(side=tk.LEFT, padx=(4, 0))

        # Accent stripe
        tk.Frame(self.root, bg=ACCENT, height=2).pack(fill=tk.X)

        # Body
        body = tk.Frame(self.root, bg=BG)
        body.pack(fill=tk.BOTH, expand=True, padx=24, pady=20)

        self._build_dropzone(body)
        self._build_actions(body)
        self._build_progress(body)
        self._build_log(body)

        # Footer
        ft = tk.Frame(self.root, bg=SURFACE, height=30)
        ft.pack(fill=tk.X, side=tk.BOTTOM)
        ft.pack_propagate(False)
        tk.Label(ft, text="Powered by OpenAI Whisper  ·  funziona offline",
                 font=("Segoe UI", 8), fg=FG_DIM, bg=SURFACE
                 ).pack(side=tk.RIGHT, padx=16, pady=7)

    def _build_dropzone(self, parent):
        outer = tk.Frame(parent, bg=BORDER, pady=1)
        outer.pack(fill=tk.X, pady=(0, 14))
        inn = tk.Frame(outer, bg=SURFACE, padx=16, pady=14)
        inn.pack(fill=tk.X)

        tk.Label(inn, text="FILE DA TRASCRIVERE",
                 font=("Segoe UI", 8, "bold"),
                 fg=FG_DIM, bg=SURFACE).pack(anchor="w", pady=(0, 6))

        row = tk.Frame(inn, bg=SURFACE)
        row.pack(fill=tk.X)

        ef = tk.Frame(row, bg=BORDER, padx=1, pady=1)
        ef.pack(side=tk.LEFT, fill=tk.X, expand=True)
        self.entry = tk.Entry(ef, textvariable=self.file_path,
                              font=FONT_MAIN, bg=SURFACE2, fg=FG,
                              insertbackground=ACCENT, relief="flat", bd=6)
        self.entry.pack(fill=tk.X)

        self.btn_sfoglia = ModernButton(
            row, "Sfoglia", command=self.scegli_file,
            style="ghost", width=100, height=36)
        self.btn_sfoglia.pack(side=tk.RIGHT, padx=(10, 0))

        tk.Label(inn,
                 text="Video: MP4  MOV  MKV  AVI  M4V  WMV   ·   "
                      "Audio: MP3  WAV  M4A  FLAC  AAC  OGG",
                 font=("Segoe UI", 8), fg=FG_DIM, bg=SURFACE
                 ).pack(anchor="w", pady=(8, 0))

    def _build_actions(self, parent):
        row = tk.Frame(parent, bg=BG)
        row.pack(fill=tk.X, pady=(0, 14))

        self.btn_avvia = ModernButton(
            row, "▶  AVVIA TRASCRIZIONE",
            command=self.avvia_trascrizione,
            style="primary", width=220, height=44,
            font=("Segoe UI", 11, "bold"))
        self.btn_avvia.pack(side=tk.LEFT)

        self.btn_cartella = ModernButton(
            row, "Apri cartella trascrizioni",
            command=self.apri_cartella_trascrizioni,
            style="ghost", width=210, height=44)
        self.btn_cartella.pack(side=tk.LEFT, padx=(12, 0))

    def _build_progress(self, parent):
        pf = tk.Frame(parent, bg=SURFACE, pady=12, padx=16)
        pf.pack(fill=tk.X, pady=(0, 14))

        top = tk.Frame(pf, bg=SURFACE)
        top.pack(fill=tk.X, pady=(0, 8))

        self.pulse = PulseIndicator(top)
        self.pulse.pack(side=tk.LEFT)

        self.prog_label = tk.Label(top, text="In attesa...",
                                   font=FONT_SM, fg=FG_MUTED, bg=SURFACE)
        self.prog_label.pack(side=tk.LEFT, padx=(6, 0))

        self.prog_pct = tk.Label(top, text="", font=("Segoe UI", 9, "bold"),
                                 fg=ACCENT, bg=SURFACE)
        self.prog_pct.pack(side=tk.RIGHT)

        track = tk.Frame(pf, bg=BORDER, height=6)
        track.pack(fill=tk.X)
        track.pack_propagate(False)
        self.prog_fill = tk.Frame(track, bg=ACCENT, height=6, width=0)
        self.prog_fill.place(x=0, y=0, height=6)
        track.bind("<Configure>", lambda e: setattr(self, "_track_w", e.width))

    def _build_log(self, parent):
        hdr = tk.Frame(parent, bg=BG)
        hdr.pack(fill=tk.X, pady=(0, 6))
        tk.Label(hdr, text="LOG", font=("Segoe UI", 8, "bold"),
                 fg=FG_DIM, bg=BG).pack(side=tk.LEFT)
        tk.Button(hdr, text="Pulisci", font=("Segoe UI", 8),
                  fg=FG_DIM, bg=BG, relief="flat", bd=0,
                  activebackground=BG, activeforeground=FG_MUTED,
                  cursor="hand2",
                  command=lambda: self.log_text.delete(1.0, tk.END)
                  ).pack(side=tk.RIGHT)

        outer = tk.Frame(parent, bg=BORDER, pady=1)
        outer.pack(fill=tk.BOTH, expand=True)
        inn = tk.Frame(outer, bg=SURFACE2)
        inn.pack(fill=tk.BOTH, expand=True, padx=1, pady=1)

        self.log_text = tk.Text(
            inn, font=FONT_MONO, bg=SURFACE2, fg=FG_MUTED,
            relief="flat", bd=8, wrap=tk.WORD,
            insertbackground=ACCENT, selectbackground=BORDER,
            selectforeground=FG)
        sb = tk.Scrollbar(inn, orient="vertical", command=self.log_text.yview,
                          bg=SURFACE2, troughcolor=SURFACE2,
                          activebackground=BORDER)
        self.log_text.configure(yscrollcommand=sb.set)
        sb.pack(side=tk.RIGHT, fill=tk.Y)
        self.log_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.log_text.tag_config("ok",      foreground=GREEN)
        self.log_text.tag_config("error",   foreground=RED)
        self.log_text.tag_config("warn",    foreground=YELLOW)
        self.log_text.tag_config("accent",  foreground=ACCENT)
        self.log_text.tag_config("muted",   foreground=FG_DIM)
        self.log_text.tag_config("default", foreground=FG_MUTED)

    # ── HELPERS ───────────────────────────────────────────────────────────────

    def _log(self, msg, tag="default"):
        ts = time.strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{ts}] ", "muted")
        self.log_text.insert(tk.END, msg + "\n", tag)
        self.log_text.see(tk.END)
        self.root.update_idletasks()

    def log(self, msg):
        if any(msg.startswith(p) for p in ("✅", "🎉")):
            self._log(msg, "ok")
        elif msg.startswith("❌"):
            self._log(msg, "error")
        elif msg.startswith("⚠"):
            self._log(msg, "warn")
        else:
            self._log(msg)

    def aggiorna_progresso(self, pct):
        labels = {10: "Estrazione audio...", 30: "Caricamento modello AI...",
                  50: "Trascrizione in corso...", 80: "Finalizzazione...",
                  100: "Completato!"}
        self.prog_label.config(text=labels.get(pct, "Elaborazione..."))
        self.prog_pct.config(text=f"{pct}%")
        if self._track_w > 4:
            self.prog_fill.place(x=0, y=0, height=6,
                                 width=int(self._track_w * pct / 100))
        self.root.update_idletasks()

    # ── ACTIONS ───────────────────────────────────────────────────────────────

    def apri_cartella_trascrizioni(self):
        try:
            os.startfile(str(self.cartella_trascrizioni))
            self._log("Cartella trascrizioni aperta", "ok")
        except Exception:
            self._log("Impossibile aprire la cartella", "error")

    def scegli_file(self):
        path = filedialog.askopenfilename(
            title="Seleziona un file video o audio",
            filetypes=[("File video", "*.mp4 *.mov *.mkv *.avi *.m4v *.wmv"),
                       ("File audio", "*.mp3 *.wav *.m4a *.flac *.aac *.ogg"),
                       ("Tutti i file", "*.*")])
        if path:
            self.file_path.set(path)
            name = os.path.basename(path)
            size = os.path.getsize(path) / (1024 * 1024)
            self._log(f"File: {name}  ({size:.1f} MB)", "accent")

    def avvia_trascrizione(self):
        if not self.file_path.get():
            messagebox.showwarning("Attenzione", "Seleziona prima un file!")
            return
        self.btn_avvia.set_enabled(False)
        self.btn_sfoglia.set_enabled(False)
        self.prog_label.config(text="Avvio...")
        self.prog_pct.config(text="")
        self.pulse.start()
        lingua = self.lingua_var.get()
        flag = {"italiano": "🇮🇹", "inglese": "🇬🇧", "automatico": "🌐"}
        self._log(f"{flag.get(lingua,'')} Lingua: {lingua.upper()}", "accent")
        threading.Thread(target=self.elabora_trascrizione, daemon=True).start()

    # ── CORE (logic unchanged) ────────────────────────────────────────────────

    def estrai_audio_da_video(self, video_path, audio_path):
        try:
            cmd = ["ffmpeg", "-i", video_path, "-vn",
                   "-acodec", "pcm_s16le", "-ar", "16000", "-ac", "1",
                   "-y", audio_path]
            return subprocess.run(cmd, capture_output=True,
                                  timeout=300).returncode == 0
        except Exception as e:
            self.log(f"❌ Errore FFmpeg: {e}")
            return False

    def converti_audio(self, audio_input, audio_output):
        try:
            cmd = ["ffmpeg", "-i", audio_input,
                   "-acodec", "pcm_s16le", "-ar", "16000", "-ac", "1",
                   "-y", audio_output]
            return subprocess.run(cmd, capture_output=True,
                                  timeout=300).returncode == 0
        except Exception as e:
            self.log(f"❌ Errore conversione: {e}")
            return False

    def elabora_trascrizione(self):
        try:
            file_path = self.file_path.get()
            file_obj  = Path(file_path)
            ext       = file_obj.suffix.lower()

            self.log(f"File: {file_obj.name}")
            self.log(f"Formato: {ext.upper()}")

            is_video = ext in {".mp4", ".mov", ".mkv", ".avi", ".m4v", ".wmv"}
            is_audio = ext in {".mp3", ".wav", ".m4a", ".flac", ".aac", ".ogg"}

            if not (is_video or is_audio):
                self.log("❌ Formato non supportato!")
                messagebox.showerror("Errore", "Formato file non supportato!")
                return

            audio_path = None
            if is_video:
                self.log("1. Estrazione audio dal video...")
                self.aggiorna_progresso(10)
                audio_path = file_obj.parent / f"_tmp_{int(time.time())}.wav"
                if not self.estrai_audio_da_video(file_path, str(audio_path)):
                    self.log("❌ Impossibile estrarre audio — verifica ffmpeg.exe")
                    return
                self.log("✅ Audio estratto")
            else:
                self.log("1. Preparazione audio...")
                self.aggiorna_progresso(10)
                if ext == ".wav":
                    audio_path = file_obj
                    self.log("✅ WAV — uso direttamente")
                else:
                    audio_path = file_obj.parent / f"_tmp_{int(time.time())}.wav"
                    if not self.converti_audio(file_path, str(audio_path)):
                        self.log("❌ Impossibile convertire audio")
                        return
                    self.log("✅ Audio convertito")

            if not (audio_path and audio_path.exists()):
                self.log("❌ File audio non creato")
                return

            size_mb = audio_path.stat().st_size / (1024*1024)
            self.log(f"Dimensione audio: {size_mb:.2f} MB")
            if size_mb < 0.1:
                self.log("⚠ File audio molto piccolo")

            self.log("2. Caricamento modello Whisper AI...")
            self.aggiorna_progresso(30)
            import whisper
            model = whisper.load_model("base")
            self.log("✅ Modello caricato")

            self.log("3. Trascrizione in corso — attendere...")
            self.aggiorna_progresso(50)
            lang_map = {"italiano": "it", "inglese": "en", "automatico": None}
            result = model.transcribe(
                str(audio_path),
                language=lang_map.get(self.lingua_var.get()),
                verbose=False, no_speech_threshold=0.6)
            self.aggiorna_progresso(80)

            testo = result["text"].strip()
            if not testo:
                self.log("⚠ Trascrizione vuota — il file potrebbe non avere audio")
                messagebox.showwarning("Attenzione", "Trascrizione vuota!")
                return

            out = self.cartella_trascrizioni / f"{file_obj.stem}_trascrizione.txt"
            out.write_text(testo, encoding="utf-8")

            try:
                if audio_path != file_obj:
                    os.remove(audio_path)
            except Exception:
                pass

            self.aggiorna_progresso(100)
            self.log(f"✅ Salvato: {out.name}")
            self.log(f"Caratteri: {len(testo)}")
            preview = testo[:160] + "..." if len(testo) > 160 else testo
            self.log(f"Anteprima: {preview}")
            self.log("🎉 TRASCRIZIONE COMPLETATA!")

            messagebox.showinfo("Completato",
                f"Trascrizione salvata!\n\n{out}\n\nCaratteri: {len(testo)}")

        except ImportError:
            self.log("❌ Whisper non installato — esegui 2.INSTALLA_WHISPER.bat")
            messagebox.showerror("Errore",
                "Whisper non installato!\nEsegui 2.INSTALLA_WHISPER.bat")
        except Exception as e:
            self.log(f"❌ {e}")
            messagebox.showerror("Errore", str(e))
        finally:
            self.pulse.stop()
            self.btn_avvia.set_enabled(True)
            self.btn_sfoglia.set_enabled(True)


if __name__ == "__main__":
    root = tk.Tk()
    root.resizable(True, True)
    try:
        root.iconbitmap(default="")
    except Exception:
        pass
    TrascrittoreVideoAudio(root)
    root.mainloop()
