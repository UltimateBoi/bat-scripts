# Enable Dark Mode for Apps and System
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0

# Set a dark accent color (e.g., black)
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -Name AccentColor -Value 0x000000
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name ColorPrevalence -Value 1

# Enable accent color on Start and taskbar
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name EnableTransparency -Value 1

# Refresh theme settings
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters

Stop-Process -Name explorer -Force
Start-Process explorer.exe

Write-Host "Dark Mode with taskbar styling applied. You may need to restart Explorer or sign out/in to see full effect."