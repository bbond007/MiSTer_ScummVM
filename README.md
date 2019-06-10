# MiSTer_ScummVM
ScummVM installer and 2.0.0 build for the MiSTer platform.

Install instructions:
Run ScummVM_Installer.sh

Suggested settings for full-screen video:

MiSTer.INI:

[MENU]
vga_scaler=1
video_mode=6

ScummVM_2_0_0.sh:

echo "Setting Video mode..."
vmode -r 640 480 rgb16

ScummVM/Options:

Graphics Mode: <default>
Render Mode: <default>
[X] Aspect ratio correction
[ ] Fullscreen mode