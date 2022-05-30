Add-Type -AssemblyName System.IO.Compression.FileSystem

$reg = reg query "HKEY_CURRENT_USER\Software\Google\Chrome\BLBeacon" /v version
$values = $reg.Get(2).Split(" ")
$version = ""

foreach($value in $values) {
    if ($value.Contains(".")) {
        $version = $value
        continue 
    }
}

$version = $version.Substring(0, $version.IndexOf("."))

Write-Host("Se detecto la version $version...")

$request = Invoke-WebRequest("https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$version")
$current_version = $request.Content

Write-Host("La version a descargar es $current_version")

Invoke-WebRequest -Uri "https://chromedriver.storage.googleapis.com/$current_version/chromedriver_win32.zip" -OutFile chromedriver.zip

Write-Host("Descarga finalizada. Descomprimiendo archivo")

if(test-path "$pwd\chromedriver.exe") {
    Remove-Item "$pwd\chromedriver.exe" 
}
[System.IO.Compression.ZipFile]::ExtractToDirectory("$pwd\chromedriver.zip", $pwd)


Write-Host("Archivo descomprimido. Comenzando copia")

$files = Get-ChildItem -Filter chromedriver.exe -Recurse -ErrorAction SilentlyContinue -Force

foreach($item in $files) {
    $folder = $item.DirectoryName
    if (-not $folder.Equals($pwd.ToString())) {
        Write-Host("   Copiando a $folder")
        Copy-Item "chromedriver.exe" $folder
    }
}

Remove-Item "$pwd\chromedriver.exe" 
Remove-Item "$pwd\chromedriver.zip"

Write-Host("ChromeDriver actualizado...")

