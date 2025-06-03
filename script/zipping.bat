@echo off
setlocal enabledelayedexpansion

rem Wybór folderu za pomocą UI
for /f "delims=" %%I in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $folder = New-Object System.Windows.Forms.FolderBrowserDialog; $folder.SelectedPath = 'C:\'; $folder.Description = 'Wybierz folder'; $folder.ShowDialog() | Out-Null; $folder.SelectedPath"') do set "selected_folder=%%I"

if "%selected_folder%"=="" (
    echo Nie wybrano folderu.
    exit /b 1
)

cd /d "%selected_folder%"

rem Iteracja przez foldery
for /d %%F in (*) do (
    rem Pobranie hasła i nazwy archiwum
    for /f "tokens=1,2 delims=_" %%A in ("%%F") do (
        set folder_name=%%F
        set password=!folder_name:~0,4!
        set archive_name=%%B
        
        rem Kompresja folderu i ustawienie hasła
        7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p"!password!" "%%F\!archive_name!.zip" "%%F\*"
    )
)

echo Kompresowanie zakończone.

endlocal