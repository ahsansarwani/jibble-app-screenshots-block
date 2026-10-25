Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class CaptureProtection
{
    [DllImport("user32.dll")]
    public static extern bool SetWindowDisplayAffinity(
        IntPtr hWnd,
        uint dwAffinity
    );

    public const uint WDA_NONE = 0x00000000;
    public const uint WDA_MONITOR = 0x00000001;
    public const uint WDA_EXCLUDEFROMCAPTURE = 0x00000011;
}
"@

# Get all connected monitors
$screens = [System.Windows.Forms.Screen]::AllScreens

Write-Host ""
Write-Host "Connected monitors:" -ForegroundColor Cyan

for ($i = 0; $i -lt $screens.Count; $i++) {
    $s = $screens[$i]

    Write-Host ""
    Write-Host "Monitor $i" -ForegroundColor Yellow
    Write-Host "  Device : $($s.DeviceName)"
    Write-Host "  Bounds : X=$($s.Bounds.X) Y=$($s.Bounds.Y) W=$($s.Bounds.Width) H=$($s.Bounds.Height)"
    Write-Host "  Primary: $($s.Primary)"
}

Write-Host ""
$choice = Read-Host "Enter the monitor number to protect"

if ($choice -notmatch '^\d+$' -or [int]$choice -ge $screens.Count) {
    Write-Host "Invalid monitor number." -ForegroundColor Red
    exit
}

$screen = $screens[[int]$choice]

Write-Host ""
Write-Host "Protecting $($screen.DeviceName)..." -ForegroundColor Green

# Create a borderless transparent form
$form = New-Object System.Windows.Forms.Form

$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual

$form.Location = New-Object System.Drawing.Point(
    $screen.Bounds.X,
    $screen.Bounds.Y
)

$form.Size = New-Object System.Drawing.Size(
    $screen.Bounds.Width,
    $screen.Bounds.Height
)

# Transparent window
$form.BackColor = [System.Drawing.Color]::Black
$form.TransparencyKey = [System.Drawing.Color]::Black

# Keep it above normal windows
$form.TopMost = $true

# Don't steal focus
$form.ShowInTaskbar = $false

# Make the form click-through
$form.Add_Shown({
    $hwnd = $form.Handle

    # WDA_MONITOR:
    # Window is visible normally but protected from screen capture.
    $result = [CaptureProtection]::SetWindowDisplayAffinity(
        $hwnd,
        [CaptureProtection]::WDA_MONITOR
    )

    if ($result) {
        Write-Host ""
        Write-Host "Capture protection enabled." -ForegroundColor Green
        Write-Host ""
        Write-Host "Monitor remains visible normally."
        Write-Host "Press CTRL+C or close this window to stop protection."
    }
    else {
        Write-Host ""
        Write-Host "Failed to enable capture protection." -ForegroundColor Red
    }
})

# Prevent the overlay from receiving mouse input
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class WindowStyle
{
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_TRANSPARENT = 0x20;
    public const int WS_EX_LAYERED = 0x80000;
    public const int WS_EX_TOOLWINDOW = 0x80;
}
"@

$form.Add_Load({
    $hwnd = $form.Handle

    $style = [WindowStyle]::GetWindowLong(
        $hwnd,
        [WindowStyle]::GWL_EXSTYLE
    )

    $style = $style `
        -bor [WindowStyle]::WS_EX_TRANSPARENT `
        -bor [WindowStyle]::WS_EX_LAYERED `
        -bor [WindowStyle]::WS_EX_TOOLWINDOW

    [WindowStyle]::SetWindowLong(
        $hwnd,
        [WindowStyle]::GWL_EXSTYLE,
        $style
    )
})

# Run the overlay
[System.Windows.Forms.Application]::Run($form)