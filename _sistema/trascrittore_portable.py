import tkinter as tk
from tkinter import filedialog, messagebox
import threading
import os
import sys
from pathlib import Path
import subprocess
import time

# ── Design tokens ────────────────────────────────────────────────────────────
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
FONT_XL   = ("Segoe UI", 15, "bold")
FONT_MONO = ("Consolas", 9)
RADIUS    = 8


def get_base_dir():
    """Root del pacchetto portable (cartella sopra _sistema/)."""
    if getattr(sys, "frozen", False):
        return Path(sys.executable).parent
    # Lo script sta in _sistema/, saliamo di un livello
    return Path(__file__).parent.parent


def get_ffmpeg():
    """Cerca ffmpeg nell'ordine: accanto all'exe → PATH."""
    local = get_base_dir() / "ffmpeg.exe"
    if local.exists():
        return str(local)
    return "ffmpeg"  # prova dal PATH


def get_model_dir():
    """Cartella modelli inclusa nell'app."""
    return get_base_dir() / "models"


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
        self.command  = command
        self.text     = text
        self.style    = style
        self.w        = width
        self.h        = height
        self._font    = font or ("Segoe UI", 10, "bold")
        self._enabled = True
        self._draw("normal")
        self.bind("<Enter>",           lambda e: self._draw("hover"))
        self.bind("<Leave>",           lambda e: self._draw("normal"))
        self.bind("<ButtonPress-1>",   lambda e: self._draw("press"))
        self.bind("<ButtonRelease-1>", self._click)

    def _colors(self, state):
        if not self._enabled:
            return FG_DIM, SURFACE, BORDER
        if self.style == "primary":
            base = ACCENT
            if state == "hover": base = "#FF8C3A"
            if state == "press": base = ACCENT_DIM
            return "#fff", base, base
        if self.style == "ghost":
            base, text = SURFACE2, FG_MUTED
            if state == "hover": text = FG; base = BORDER
            if state == "press": base = SURFACE
            return text, base, BORDER
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
        self.delete("all")
        self.create_oval(2, 2, 10, 10, fill=f"#{r:02x}{g:02x}{b:02x}", outline="")
        self.after(80, self._animate)


class TrascrittorePortable:
    def __init__(self, root):
        self.root = root
        self.root.title("Trascrittore AI — Portable")
        self.root.geometry("760x640")
        self.root.minsize(680, 580)
        self.root.configure(bg=BG)

        self.base_dir           = get_base_dir()
        self.cartella_out       = self.base_dir / "TRASCRIZIONI"
        self.cartella_out.mkdir(exist_ok=True)
        self.file_path          = tk.StringVar()
        self.lingua_var         = tk.StringVar(value="italiano")
        self._track_w           = 0

        self._build_ui()
        self._startup_check()

    # ── STARTUP CHECK ─────────────────────────────────────────────────────────

    def _startup_check(self):
        """Verifica ffmpeg e modello all'avvio."""
        ffmpeg_ok = Path(get_ffmpeg()).exists() or self._cmd_exists("ffmpeg")
        # Cerca model.bin in qualsiasi sottocartella (supporta vecchio e nuovo formato HF hub)
        model_ok  = bool(list(get_model_dir().rglob("model.bin"))) if get_model_dir().exists() else False

        if ffmpeg_ok:
            self._log("FFmpeg trovato", "ok")
        else:
            self._log("ffmpeg.exe non trovato nella cartella!", "error")

        if model_ok:
            self._log("Modello AI (base) trovato — pronto offline", "ok")
        else:
            self._log("Modello AI non trovato — verra' scaricato al primo uso (~150 MB)", "warn")

        self._log("Pronto — seleziona un file e premi AVVIA", "ok")
        self._log(f"Trascrizioni salvate in: {self.cartella_out}", "muted")

    @staticmethod
    def _cmd_exists(cmd):
        try:
            subprocess.run([cmd, "-version"], capture_output=True, timeout=5)
            return True
        except Exception:
            return False

    # ── UI BUILD ──────────────────────────────────────────────────────────────

    def _build_ui(self):
        # Header
        hdr = tk.Frame(self.root, bg=SURFACE, height=56)
        hdr.pack(fill=tk.X)
        hdr.pack_propagate(False)
        inn = tk.Frame(hdr, bg=SURFACE)
        inn.pack(fill=tk.BOTH, expand=True, padx=20)
        tk.Label(inn, text="◉", font=("Segoe UI", 18),
                 fg=ACCENT, bg=SURFACE).pack(side=tk.LEFT, pady=12)
        tk.Label(inn, text="  Trascrittore AI  —  Portable",
                 font=FONT_XL, fg=FG, bg=SURFACE).pack(side=tk.LEFT, pady=12)

        # Language pill
        pill = tk.Frame(inn, bg=SURFACE2, padx=10, pady=4)
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

        tk.Frame(self.root, bg=ACCENT, height=2).pack(fill=tk.X)

        body = tk.Frame(self.root, bg=BG)
        body.pack(fill=tk.BOTH, expand=True, padx=24, pady=20)

        self._build_dropzone(body)
        self._build_actions(body)
        self._build_progress(body)
        self._build_log(body)

        ft = tk.Frame(self.root, bg=SURFACE, height=30)
        ft.pack(fill=tk.X, side=tk.BOTTOM)
        ft.pack_propagate(False)
        tk.Label(ft, text="Versione Portable — nessuna installazione richiesta  ·  OpenAI Whisper",
                 font=("Segoe UI", 8), fg=FG_DIM, bg=SURFACE
                 ).pack(side=tk.RIGHT, padx=16, pady=7)

    def _build_dropzone(self, parent):
        outer = tk.Frame(parent, bg=BORDER, pady=1)
        outer.pack(fill=tk.X, pady=(0, 14))
        inn = tk.Frame(outer, bg=SURFACE, padx=16, pady=14)
        inn.pack(fill=tk.X)
        tk.Label(inn, text="FILE DA TRASCRIVERE",
                 font=("Segoe UI", 8, "bold"), fg=FG_DIM, bg=SURFACE
                 ).pack(anchor="w", pady=(0, 6))
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
            command=self.apri_cartella,
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
        self.prog_pct = tk.Label(top, text="",
                                 font=("Segoe UI", 9, "bold"), fg=ACCENT, bg=SURFACE)
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

    def _set_progress(self, pct, label=""):
        self.prog_label.config(text=label or "Elaborazione...")
        self.prog_pct.config(text=f"{pct}%" if pct else "")
        if self._track_w > 4:
            self.prog_fill.place(x=0, y=0, height=6,
                                 width=int(self._track_w * pct / 100))
        self.root.update_idletasks()

    # ── ACTIONS ───────────────────────────────────────────────────────────────

    def apri_cartella(self):
        try:
            os.startfile(str(self.cartella_out))
        except Exception:
            self._log("Impossibile aprire la cartella", "error")

    def scegli_file(self):
        path = filedialog.askopenfilename(
            title="Seleziona un file video o audio",
            filetypes=[
                ("File video", "*.mp4 *.mov *.mkv *.avi *.m4v *.wmv"),
                ("File audio", "*.mp3 *.wav *.m4a *.flac *.aac *.ogg"),
                ("Tutti i file", "*.*"),
            ])
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
        self._set_progress(0, "Avvio...")
        self.pulse.start()
        flag = {"italiano": "🇮🇹", "inglese": "🇬🇧", "automatico": "🌐"}
        lingua = self.lingua_var.get()
        self._log(f"{flag.get(lingua,'')} Lingua: {lingua.upper()}", "accent")
        threading.Thread(target=self._esegui, daemon=True).start()

    # ── CORE ─────────────────────────────────────────────────────────────────

    def _run_ffmpeg(self, args):
        cmd = [get_ffmpeg()] + args
        return subprocess.run(cmd, capture_output=True, timeout=600).returncode == 0

    def _to_wav(self, src, dst):
        return self._run_ffmpeg([
            "-i", src, "-vn",
            "-acodec", "pcm_s16le", "-ar", "16000", "-ac", "1",
            "-y", dst])

    def _esegui(self):
        try:
            file_path = self.file_path.get()
            file_obj  = Path(file_path)
            ext       = file_obj.suffix.lower()

            self.log(f"File: {file_obj.name}")

            is_video = ext in {".mp4", ".mov", ".mkv", ".avi", ".m4v", ".wmv"}
            is_audio = ext in {".mp3", ".wav", ".m4a", ".flac", ".aac", ".ogg"}

            if not (is_video or is_audio):
                self.log("❌ Formato non supportato!")
                messagebox.showerror("Errore", "Formato file non supportato!")
                return

            # Converti in WAV
            self._set_progress(10, "Preparazione audio...")
            tmp_wav = None
            if is_video or ext != ".wav":
                tmp_wav   = self.base_dir / f"_tmp_{int(time.time())}.wav"
                self.log("Conversione audio in corso...")
                if not self._to_wav(file_path, str(tmp_wav)):
                    self.log("❌ FFmpeg fallito — verifica che ffmpeg.exe sia nella cartella")
                    return
                self.log("✅ Audio pronto")
                audio_path = tmp_wav
            else:
                audio_path = file_obj

            # Carica modello faster-whisper
            self._set_progress(30, "Caricamento modello AI...")
            self.log("Caricamento modello faster-whisper...")
            from faster_whisper import WhisperModel

            model_dir = get_model_dir()
            # Usa sempre download_root=models/ così faster-whisper trova il modello
            # sia in vecchio formato (models/base/) che in nuovo HF hub
            if list(model_dir.rglob("model.bin")) if model_dir.exists() else False:
                self.log(f"Modello locale: {model_dir}")
            else:
                self.log("⚠ Modello non trovato localmente — scarico (~150 MB)...")
            model = WhisperModel("base", device="cpu", compute_type="int8",
                                 download_root=str(model_dir))

            self.log("✅ Modello caricato")

            # Trascrizione
            self._set_progress(50, "Trascrizione in corso...")
            self.log("Trascrizione — attendere...")

            lang_map = {"italiano": "it", "inglese": "en", "automatico": None}
            language = lang_map.get(self.lingua_var.get())

            segments, info = model.transcribe(
                str(audio_path),
                language=language,
                beam_size=5,
                vad_filter=True,
            )

            self._set_progress(70, "Assemblaggio testo...")
            testo = " ".join(seg.text.strip() for seg in segments).strip()

            # Pulizia
            if tmp_wav and tmp_wav.exists():
                try:
                    tmp_wav.unlink()
                except Exception:
                    pass

            self._set_progress(85, "Salvataggio...")

            if not testo:
                self.log("⚠ Trascrizione vuota — il file potrebbe non avere audio")
                messagebox.showwarning("Attenzione", "Trascrizione vuota!")
                return

            out = self.cartella_out / f"{file_obj.stem}_trascrizione.txt"
            out.write_text(testo, encoding="utf-8")

            self._set_progress(100, "Completato!")
            self.log(f"✅ Salvato: {out.name}")
            self.log(f"Caratteri: {len(testo)}")
            preview = testo[:160] + "..." if len(testo) > 160 else testo
            self.log(f"Anteprima: {preview}")
            self.log("🎉 TRASCRIZIONE COMPLETATA!")

            messagebox.showinfo(
                "Completato",
                f"Trascrizione salvata!\n\n{out}\n\nCaratteri: {len(testo)}"
            )

        except ImportError:
            self.log("❌ faster-whisper non trovato nell'app — reinstalla la versione portable")
            messagebox.showerror("Errore", "Componente mancante. Ricostruisci l'app portable.")
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
    TrascrittorePortable(root)
    root.mainloop()
