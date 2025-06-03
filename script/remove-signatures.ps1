# Ustawienie ścieżki do 7z.exe, zmień jeśli 7-Zip jest zainstalowany w innej lokalizacji
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Ścieżka do katalogu Maven Repository
$mavenRepoPath = "C:\xampp\htdocs\programs\demo\out\artifacts\demo_jar"

# Znajdź wszystkie pliki JAR w repozytorium Maven
$jarFiles = Get-ChildItem -Path $mavenRepoPath -Recurse -Include *.jar

# Usunięcie podpisów z plików JAR
foreach ($jar in $jarFiles) {
    Write-Output "Processing $($jar.FullName)"
    & $sevenZipPath d $jar.FullName 'META-INF/*.SF' 'META-INF/*.DSA' 'META-INF/*.RSA'
}
