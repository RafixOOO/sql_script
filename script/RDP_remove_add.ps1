# Ustawienie polityki wykonania skrypt�w na RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Lista użytkowników do edycji
$users = @("$env:COMPUTERNAME\AH", "$env:COMPUTERNAME\EG", "$env:COMPUTERNAME\GU", "$env:COMPUTERNAME\JL", "$env:COMPUTERNAME\LK", "$env:COMPUTERNAME\LL", "$env:COMPUTERNAME\LW", "$env:COMPUTERNAME\MS", "$env:COMPUTERNAME\MZ", "$env:COMPUTERNAME\PB", "$env:COMPUTERNAME\PM", "$env:COMPUTERNAME\PW", "$env:COMPUTERNAME\SK", "$env:COMPUTERNAME\TA", "$env:COMPUTERNAME\WD")  # <- Automatycznie bierze nazwę Twojego komputera

# Nazwa grupy
$group = "U�ytkownicy pulpitu zdalnego"  # lub "Użytkownicy pulpitu zdalnego" na polskim systemie

# Co zrobi�? ('remove' albo 'add')
$action = "add"

# Przetwarzanie
foreach ($user in $users) {
    if ($action -eq "remove") {
        try {
            Remove-LocalGroupMember -Group $group -Member $user -ErrorAction Stop
            Write-Host "Usuni�to u�ytkownika ${user} z grupy $group" -ForegroundColor Green
        } catch {
            Write-Host "B��d przy usuwaniu ${user}: $_" -ForegroundColor Red
        }
    }
    elseif ($action -eq "add") {
        try {
            Add-LocalGroupMember -Group $group -Member $user -ErrorAction Stop
            Write-Host "Dodano u�ytkownika ${user} do grupy $group" -ForegroundColor Green
        } catch {
            Write-Host "B��d przy dodawaniu ${user}: $_" -ForegroundColor Red
        }
    }
}
