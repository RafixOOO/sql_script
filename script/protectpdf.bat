@echo off
setlocal enabledelayedexpansion

rem Zmapowanie lokalizacji sieciowej
net use Z: \\srv-dc0\Kadry_place

rem Wybór folderu za pomocą UI
for /f "delims=" %%I in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $folder = New-Object System.Windows.Forms.FolderBrowserDialog; $folder.SelectedPath = 'C:\'; $folder.Description = 'Wybierz folder'; $folder.ShowDialog() | Out-Null; $folder.SelectedPath"') do set "selected_folder=%%I"

if "%selected_folder%"=="" (
    echo Nie wybrano folderu.
    goto Cleanup
)

cd /d "%selected_folder%"

rem Iteracja przez foldery
for /d %%F in (*) do (
    rem Ustawianie hasła dla plików PDF
    for %%P in ("%%F\*.pdf") do (
        set folder_name=%%F
        set password=!folder_name:~0,4!
        pdftk "%%P" output "%%~dpP\%%~nP_protected.pdf" user_pw !password!
    )
)

echo Ustawianie haseł zakończone.

:Cleanup
rem Odmontowanie lokalizacji sieciowej po zakończeniu
net use Z: /delete /yes

endlocal
