# Ustawienie polityki wykonania skryptÛw na RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Lista u≈ºytkownik√≥w do edycji
$users = @("$env:COMPUTERNAME\AH", "$env:COMPUTERNAME\EG", "$env:COMPUTERNAME\GU", "$env:COMPUTERNAME\JL", "$env:COMPUTERNAME\LK", "$env:COMPUTERNAME\LL", "$env:COMPUTERNAME\LW", "$env:COMPUTERNAME\MS", "$env:COMPUTERNAME\MZ", "$env:COMPUTERNAME\PB", "$env:COMPUTERNAME\PM", "$env:COMPUTERNAME\PW", "$env:COMPUTERNAME\SK", "$env:COMPUTERNAME\TA", "$env:COMPUTERNAME\WD")  # <- Automatycznie bierze nazwƒô Twojego komputera

# Nazwa grupy
$group = "Uøytkownicy pulpitu zdalnego"  # lub "U≈ºytkownicy pulpitu zdalnego" na polskim systemie

# Co zrobiÊ? ('remove' albo 'add')
$action = "add"

# Przetwarzanie
foreach ($user in $users) {
    if ($action -eq "remove") {
        try {
            Remove-LocalGroupMember -Group $group -Member $user -ErrorAction Stop
            Write-Host "UsuniÍto uøytkownika ${user} z grupy $group" -ForegroundColor Green
        } catch {
            Write-Host "B≥πd przy usuwaniu ${user}: $_" -ForegroundColor Red
        }
    }
    elseif ($action -eq "add") {
        try {
            Add-LocalGroupMember -Group $group -Member $user -ErrorAction Stop
            Write-Host "Dodano uøytkownika ${user} do grupy $group" -ForegroundColor Green
        } catch {
            Write-Host "B≥πd przy dodawaniu ${user}: $_" -ForegroundColor Red
        }
    }
}
