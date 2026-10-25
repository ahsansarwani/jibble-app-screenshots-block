Monitor Privacy — Windows

A PowerShell-based experiment exploring Windows display capture protection using the Windows API SetWindowDisplayAffinity().

Monitor Privacy is designed for dual-monitor setups where a user wants to experiment with making a selected monitor's overlay appear blank in supported screen captures while keeping the display usable normally.

[!CAUTION]
Educational purposes only. This project is provided for learning, experimentation, and personal research. It is not a guaranteed security or anti-surveillance solution. Capture protection can vary depending on Windows versions, graphics drivers, and the capture method used.

Features

Detects connected monitors.

Lets you select a monitor by its displayed index.

Creates a borderless, transparent, click-through overlay.

Experiments with Windows' SetWindowDisplayAffinity() API.

Can be launched using PowerShell or an optional BAT file.

Does not require modifying Windows system files.

How It Works

The script uses Windows Forms to create an overlay spanning the selected monitor and calls the Windows API SetWindowDisplayAffinity() with the WDA_MONITOR flag.

This API allows Windows to apply capture restrictions to the specified top-level window under supported conditions.

Important: The API protects the window, not the entire physical monitor or every application displayed behind it. Because the overlay is transparent, this implementation does not guarantee that the underlying monitor contents will appear black in screenshots.

Requirements

Windows with PowerShell

.NET Windows Forms support

A multi-monitor setup for testing monitor selection

Permission to run local PowerShell scripts

Installation

Download or clone this repository.

Save Protect-Monitor.ps1 to a folder of your choice.

Open PowerShell in that folder.

Run the script with a process-scoped execution policy override:

Set-ExecutionPolicy -Scope Process Bypass
.\Protect-Monitor.ps1

The execution policy change applies only to the current PowerShell process.

Selecting a Monitor

The script lists connected monitors with their index, device name, resolution, position, and primary-display status.

Example:

Monitor 0
  Device : \\.\DISPLAY1
  Bounds : X=0 Y=0 W=1920 H=1080
  Primary: True

Monitor 1
  Device : \\.\DISPLAY2
  Bounds : X=1920 Y=0 W=2560 H=1440
  Primary: False

Enter the index corresponding to the monitor you want to test. Monitor ordering can vary between systems, so verify the displayed information before selecting.

Optional: Launch Using a BAT File

Create Start-MonitorProtection.bat in the same directory as the PowerShell script:

@echo off
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Protect-Monitor.ps1"

Double-click the BAT file to launch the script.

To run it at login, you can place a shortcut to the BAT file in the Windows Startup folder, accessible with:

shell:startup

Automatic startup does not improve the protection itself. The script must be running for its overlay to exist.

Limitations

No universal screenshot blocking: The script does not disable Windows screenshots system-wide.

No guaranteed black output: The implementation does not reliably make all content on the selected monitor black in screenshots.

Capture method dependent: Results may differ across Snipping Tool, Print Screen, screen recorders, GPU-based capture, remote desktop software, and other APIs.

Not DRM: SetWindowDisplayAffinity() is not a security boundary against a determined attacker.

External capture remains possible: A camera or separate capture device can still record the display.

Not a substitute for access control: Do not rely on this project to protect highly confidential information.

Troubleshooting

The overlay appears, but screenshots still show the desktop

This is a known limitation of the approach. The API's capture affinity applies to the overlay window itself, not automatically to all windows beneath it. The script cannot guarantee that the whole monitor will be excluded.

The wrong monitor is selected

Rerun the script and check the monitor index, device name, and bounds before making a selection.

The script does not launch

Confirm that Windows PowerShell and Windows Forms are available and that the script was saved with the .ps1 extension.

Disclaimer

This software is provided "as is," without warranty of any kind, express or implied. The author makes no guarantee that the software will work on every Windows configuration or prevent screenshots, recordings, or other forms of capture.

Use this project only on systems you own or are authorized to administer. You are responsible for evaluating its behavior and suitability for your environment.
