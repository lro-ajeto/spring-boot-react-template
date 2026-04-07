$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Test-CommandExists {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Update-SessionPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $combined = @($machinePath, $userPath) -join ";"
    $segments = $combined.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) |
        ForEach-Object { $_.Trim() } |
        Select-Object -Unique
    $env:Path = ($segments -join ";")
}

function Get-JavaHomeCandidate {
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($registryPath in $registryPaths) {
        $match = Get-ChildItem $registryPath -ErrorAction SilentlyContinue |
            Get-ItemProperty -ErrorAction SilentlyContinue |
            Where-Object {
                $displayNameProperty = $_.PSObject.Properties["DisplayName"]
                $installLocationProperty = $_.PSObject.Properties["InstallLocation"]
                $displayName = if ($displayNameProperty) { $displayNameProperty.Value } else { $null }
                $installLocation = if ($installLocationProperty) { $installLocationProperty.Value } else { $null }
                $displayName -match "OpenJDK|Temurin|Java" -and
                -not [string]::IsNullOrWhiteSpace($installLocation) -and
                (Test-Path $installLocation)
            } |
            Select-Object -First 1

        if ($match) {
            return $match.PSObject.Properties["InstallLocation"].Value.TrimEnd("\")
        }
    }

    $javaCommand = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCommand -and $javaCommand.Source) {
        $javaBin = Split-Path -Parent $javaCommand.Source
        $javaHome = Split-Path -Parent $javaBin
        if (Test-Path (Join-Path $javaHome "bin\java.exe")) {
            return $javaHome
        }
    }

    $patterns = @(
        "C:\Program Files\Microsoft\jdk-21*",
        "C:\Program Files\Eclipse Adoptium\jdk-21*",
        "C:\Program Files\Java\jdk-21*"
    )

    $candidates = foreach ($pattern in $patterns) {
        Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue
    }

    return $candidates |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}

function Ensure-JavaHome {
    $javaHome = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
    if ([string]::IsNullOrWhiteSpace($javaHome) -or -not (Test-Path $javaHome)) {
        $candidate = Get-JavaHomeCandidate
        if (-not $candidate) {
            throw "Java blev installeret, men installationsmappen kunne ikke findes automatisk."
        }

        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $candidate, "User")
        $env:JAVA_HOME = $candidate
        Write-Host "JAVA_HOME sat til: $candidate"
    }
    else {
        $env:JAVA_HOME = $javaHome
    }

    $javaBin = Join-Path $env:JAVA_HOME "bin"
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $pathParts = @()
    if (-not [string]::IsNullOrWhiteSpace($userPath)) {
        $pathParts = $userPath.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) |
            ForEach-Object { $_.Trim() }
    }

    if ($pathParts -notcontains $javaBin) {
        $newUserPath = @($pathParts + $javaBin) -join ";"
        [System.Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
        Write-Host "Java bin er tilfoejet til brugerens PATH."
    }

    Update-SessionPath
}

Write-Step "Tjekker om Java 21 allerede er tilgaengelig"
$javaAvailable = Test-CommandExists "java"
$javacAvailable = Test-CommandExists "javac"

if (-not ($javaAvailable -and $javacAvailable)) {
    Write-Step "Java 21 mangler eller er ikke i PATH"

    if (-not (Test-CommandExists "winget")) {
        throw "winget blev ikke fundet. Installer Java 21 manuelt og koer scriptet igen."
    }

    Write-Step "Installerer Temurin JDK 21 via winget"
    winget install --id EclipseAdoptium.Temurin.21.JDK -e --accept-package-agreements --accept-source-agreements

    Update-SessionPath
}

Write-Step "Sikrer JAVA_HOME og PATH"
Ensure-JavaHome

Write-Step "Validerer installationen"
& java -version
& javac -version

Write-Host ""
Write-Host "Java 21 er klar." -ForegroundColor Green
Write-Host "Du kan nu starte projektet med:" -ForegroundColor Green
Write-Host ".\mvnw.cmd spring-boot:run" -ForegroundColor Yellow
