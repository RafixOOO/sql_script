@echo off
for /r %%i in (*.7z) do (
    del "%%i"
    echo Usunięto: "%%i"
)
echo Usunięto wszystkie pliki z rozszerzeniem .7z z bieżącego folderu i jego podfolderów.
pause