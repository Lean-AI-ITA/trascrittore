# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec per Trascrittore AI Portable

import sys
from pathlib import Path

block_cipher = None

a = Analysis(
    ['trascrittore_portable.py'],
    pathex=[],
    binaries=[
        ('ffmpeg.exe', '.'),          # ffmpeg accanto all'exe
    ],
    datas=[
        ('models/', 'models/'),       # modelli AI pre-scaricati
    ],
    hiddenimports=[
        'faster_whisper',
        'ctranslate2',
        'tokenizers',
        'huggingface_hub',
        'av',
        'tqdm',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['torch', 'torchvision', 'torchaudio'],  # non servono con faster-whisper
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='Trascrittore',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,          # nessuna finestra cmd nera
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='Trascrittore',    # cartella output: dist/Trascrittore/
)
