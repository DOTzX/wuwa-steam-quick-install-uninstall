# Step 1: Initialization
$locale = (Get-Culture).Name
$isIndonesian = $locale -like "id-*"
Write-Host "=========================================================================" -ForegroundColor Blue
Write-Host "|                                                                       |" -ForegroundColor Blue
Write-Host "|  GitHub: https://github.com/DOTzX/wuwa-steam-quick-install-uninstall  |" -ForegroundColor Blue
Write-Host "|                                                                       |" -ForegroundColor Blue
Write-Host "=========================================================================" -ForegroundColor Blue
Write-Host ""

# Step 1.1: Helper function
function Get-ValidFolder {
    param (
        [string]$path,
        [string]$RequiredFile,
        [string]$SectionName
    )

    if ($SectionName.ToLower().Contains("launcher") -and (Test-Path (Join-Path $path "steam_appid.txt"))) {
        if ($isIndonesian) {
            Write-Host "[WARNING] Bukan folder game Wuthering Waves (${SectionName}):`n${path}" -ForegroundColor Yellow
        } else {
            Write-Host "[WARNING] Not Wuthering Waves (${SectionName}) game folder:`n${path}" -ForegroundColor Yellow
        }
    } elseif (Test-Path (Join-Path $path $RequiredFile)) {
        return $path
    } elseif (Test-Path $path) {
        if ($isIndonesian) {
            Write-Host "[WARNING] Bukan folder game Wuthering Waves (${SectionName}):`n${path}" -ForegroundColor Yellow
        } else {
            Write-Host "[WARNING] Not Wuthering Waves (${SectionName}) game folder:`n${path}" -ForegroundColor Yellow
        }
    } else {
        if ($isIndonesian) {
            Write-Host "[WARNING] Folder tidak ditemukan:`n${path}" -ForegroundColor Yellow
        } else {
            Write-Host "[WARNING] Folder is not exists:`n${path}" -ForegroundColor Yellow
        }
    }
}
function Get-InputValidFolder {
    param (
        [string]$RequiredFile,
        [string]$SectionName
    )

    while ($true) {
        do {
            if ($isIndonesian) {
                Write-Host "Harap masukkan lokasi folder Wuthering Waves (${SectionName}): " -ForegroundColor Blue -NoNewline
                $path = Read-Host
                $path = $path.Trim()
                $path = $path.TrimEnd('\','/')
                if ([string]::IsNullOrWhiteSpace($path)) {
                    Write-Host "[WARNING] Input tidak boleh kosong. Silakan masukkan jalur folder yang benar." -ForegroundColor Yellow
                }
            } else {
                Write-Host "Please enter the folder location of Wuthering Waves (${SectionName}): " -ForegroundColor Blue -NoNewline
                $path = Read-Host
                $path = $path.Trim()
                $path = $path.TrimEnd('\','/')
                if ([string]::IsNullOrWhiteSpace($path)) {
                    Write-Host "[WARNING] Input cannot be empty. Please enter a valid folder path." -ForegroundColor Yellow
                }
            }
        } while ([string]::IsNullOrWhiteSpace($path))

        if ($SectionName.ToLower().Contains("launcher") -and (Test-Path (Join-Path $path "steam_appid.txt"))) {
            if ($isIndonesian) {
                Write-Host "[WARNING] Bukan folder game Wuthering Waves (${SectionName}). Silakan coba lagi." -ForegroundColor Yellow
            } else {
                Write-Host "[WARNING] Not Wuthering Waves (${SectionName}) game folder. Please try again." -ForegroundColor Yellow
            }
        } elseif (Test-Path (Join-Path $path $RequiredFile)) {
            return $path
        } elseif (Test-Path $path) {
            if ($isIndonesian) {
                Write-Host "[WARNING] Bukan folder game Wuthering Waves (${SectionName}). Silakan coba lagi." -ForegroundColor Yellow
            } else {
                Write-Host "[WARNING] Not Wuthering Waves (${SectionName}) game folder. Please try again." -ForegroundColor Yellow
            }
        } else {
            if ($isIndonesian) {
                Write-Host "[WARNING] Folder tidak ditemukan. Silakan coba lagi." -ForegroundColor Yellow
            } else {
                Write-Host "[WARNING] Folder is not exists. Please try again." -ForegroundColor Yellow
            }
        }
    }
}

function Get-FileSystemType {
    param([string]$Path)
    try {
        $driveLetter = ([System.IO.Path]::GetPathRoot($Path))
        $volume = Get-Volume -FilePath $driveLetter -ErrorAction Stop
        return $volume.FileSystem
    } catch {
        return $null
    }
}

function Is-JunctionOrSymlink {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) { return $false }

    $attributes = (Get-Item $Path -Force).Attributes
    return ($attributes -band [IO.FileAttributes]::ReparsePoint)
}


# Step 1.2: Check if running as Administrator (required for creating Symbolic Link)
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    if ($isIndonesian) {
        Write-Host "[ERROR] Skrip ini harus dijalankan sebagai Administrator." -ForegroundColor Red
        Write-Host "Silakan klik kanan PowerShell dan pilih 'Run as administrator'." -ForegroundColor Yellow
    } else {
        Write-Host "[ERROR] This script must be run as Administrator." -ForegroundColor Red
        Write-Host "Please right-click PowerShell and choose 'Run as administrator'." -ForegroundColor Yellow
    }
    Pause
    exit
}

# Step 1.3: Load configuration
$jsonPath = Join-Path $HOME "wuwa-steam-quick-install-uninstall.config"
$jsonData = if (Test-Path $jsonPath) {
    Write-Host "[LOAD] Load file... ${jsonPath}" -ForegroundColor Green
    Get-Content -Raw $jsonPath | ConvertFrom-Json
} else {
    [PSCustomObject]@{
        OfficialPath = ""
        SteamPath = ""
    }
}

# Step 2: Get valid folder paths
$officialPath = if ($jsonData -and $jsonData.PSObject.Properties.Name -contains 'OfficialPath' -and $jsonData.OfficialPath -and (Get-ValidFolder $jsonData.OfficialPath "Wuthering Waves.exe" "Official launcher")) {
    Write-Host "[LOAD] Official Path: $($jsonData.OfficialPath)" -ForegroundColor Green
    $jsonData.OfficialPath
} else {
    Get-InputValidFolder "Wuthering Waves.exe" "Official launcher"
}

$steamPath = if ($jsonData -and $jsonData.PSObject.Properties.Name -contains 'SteamPath' -and $jsonData.SteamPath -and (Get-ValidFolder $jsonData.SteamPath "steam_appid.txt" "Steam")) {
    Write-Host "[LOAD] Steam Path: $($jsonData.SteamPath)" -ForegroundColor Green
    $jsonData.SteamPath
} else {
    Get-InputValidFolder "steam_appid.txt" "Steam"
}

# Step 2.1: Check if both paths are on NTFS volumes
$officialFS = Get-FileSystemType $officialPath
$steamFS = Get-FileSystemType $steamPath

if (($officialFS -ne "NTFS") -or ($steamFS -ne "NTFS")) {
    if ($isIndonesian) {
        Write-Host "[ERROR] Salah satu atau kedua folder bukan berada di partisi NTFS." -ForegroundColor Red
        Write-Host "Pastikan Wuthering Waves dan Steam terpasang di drive berformat NTFS." -ForegroundColor Yellow
    } else {
        Write-Host "[ERROR] One or both folders are not located on an NTFS volume." -ForegroundColor Red
        Write-Host "Please ensure both Wuthering Waves and Steam are installed on NTFS-formatted drives." -ForegroundColor Yellow
    }
    Pause
    exit
}

# Step 2.2: Save configuration
$jsonData.OfficialPath = $officialPath
$jsonData.SteamPath = $steamPath
$jsonData | ConvertTo-Json -Depth 2 | Set-Content -Path $jsonPath

# Step 3: Define functions
function DoFuncRemoveSymLink {
    $paksPath = Join-Path $steamPath "Client\Content\Paks"
    $savedPath = Join-Path $steamPath "Client\Saved"
    $isNotExists = $false

    if (-not (Test-Path $savedPath)) {
        if ($isIndonesian) {
            Write-Host "[WARNING] Folder tidak ditemukan:`n${savedPath}" -ForegroundColor Yellow
        } else {
            Write-Host "[WARNING] Folder is not exists:`n${savedPath}" -ForegroundColor Yellow
        }
        $isNotExists = $true
    } else {
        $isSavedLink = Is-JunctionOrSymlink $savedPath
        
        if (-not ($isSavedLink)) {
            if ($isIndonesian) {
                Write-Host "[ERROR] Folder berikut bukanlah junction/symlink:`n${savedPath}" -ForegroundColor Red
            } else {
                Write-Host "[ERROR] This folder is not junction/symlink:`n${savedPath}" -ForegroundColor Red
            }
            return
        }
    }

    if (-not (Test-Path $paksPath)) {
        if ($isIndonesian) {
            Write-Host "[WARNING] Folder tidak ditemukan:`n${paksPath}" -ForegroundColor Yellow
        } else {
            Write-Host "[WARNING] Folder is not exists:`n${paksPath}" -ForegroundColor Yellow
        }
        $isNotExists = $true
    } else {
        $isPaksLink = Is-JunctionOrSymlink $paksPath
        
        if (-not ($isPaksLink)) {
            if ($isIndonesian) {
                Write-Host "[ERROR] Folder berikut bukanlah junction/symlink:`n${paksPath}" -ForegroundColor Red
            } else {
                Write-Host "[ERROR] This folder is not junction/symlink:`n${paksPath}" -ForegroundColor Red
            }
            return
        }
    }

    cmd /c rmdir "$savedPath"
    cmd /c rmdir "$paksPath"

    if ($isNotExists) {
        if ($isIndonesian) {
            Write-Host "[INFO] Kamu dapat mengabaikan pesan diatas." -ForegroundColor Green
        } else {
            Write-Host "[INFO] You can ignore message above." -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host ""
    if ($isIndonesian) {
        Write-Host " [INFO] Sekarang kamu dapat menguninstall Wuthering Waves pada Steam dengan aman." -ForegroundColor Green
    } else {
        Write-Host " [INFO] Now you can safely uninstall Wuthering Waves from Steam." -ForegroundColor Green
    }
    Write-Host ""
}
function DoFuncCreateSymLink {
    $savedTarget = Join-Path $steamPath "Client\Saved"
    $savedSource = Join-Path $officialPath "Client\Saved"

    $paksTarget = Join-Path $steamPath "Client\Content\Paks"
    $paksSource = Join-Path $officialPath "Client\Content\Paks"

    if (-not (Test-Path $savedSource)) {
        if ($isIndonesian) {
            Write-Host "[ERROR] Folder tidak ditemukan:`n${savedSource}" -ForegroundColor Red
        } else {
            Write-Host "[ERROR] Folder is not exists:`n${savedSource}" -ForegroundColor Red
        }
        return
    }

    if (-not (Test-Path $paksSource)) {
        if ($isIndonesian) {
            Write-Host "[ERROR] Folder tidak ditemukan:`n${paksSource}" -ForegroundColor Red
        } else {
            Write-Host "[ERROR] Folder is not exists:`n${paksSource}" -ForegroundColor Red
        }
        return
    }

    $contentDir = Join-Path $steamPath "Client\Content"
    if (-not (Test-Path $contentDir)) {
        New-Item -ItemType Directory -Path $contentDir -Force | Out-Null
    }

    try {
        if (-not (Test-Path $savedTarget)) {
            New-Item -ItemType SymbolicLink -Path $savedTarget -Target $savedSource | Out-Null
        } else {
            if ($isIndonesian) {
                Write-Host "[WARNING] Folder telah ada:`n${savedTarget}" -ForegroundColor Yellow
            } else {
                Write-Host "[WARNING] Folder already exists:`n${savedTarget}" -ForegroundColor Yellow
            }
        }
        if (-not (Test-Path $paksTarget)) {
            New-Item -ItemType SymbolicLink -Path $paksTarget -Target $paksSource | Out-Null
        } else {
            if ($isIndonesian) {
                Write-Host "[WARNING] Folder telah ada:`n${paksTarget}" -ForegroundColor Yellow
            } else {
                Write-Host "[WARNING] Folder already exists:`n${paksTarget}" -ForegroundColor Yellow
            }
        }

        Write-Host ""
        if ($isIndonesian) {
            Write-Host " [INFO] Sekarang kamu dapat menginstall Wuthering Waves pada Steam." -ForegroundColor Green
        } else {
            Write-Host " [INFO] You can now install Wuthering Waves on Steam." -ForegroundColor Green
        }
        Write-Host ""
    } catch {
        Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
        if ($isIndonesian) {
            Write-Host "Gagal membuat symlink untuk folder" -ForegroundColor Red
        } else {
            Write-Host "Failed to create symlink" -ForegroundColor Red
        }
    }
}
function DoFuncInfoText {
    Write-Host ""
    if ($isIndonesian) {
        Write-Host " [INFO] Harap pastikan launcher resmi sudah siap untuk memulai game, dan telah menyelesaikan Update." -ForegroundColor Green
    } else {
        Write-Host " [INFO] Please make sure official Launcher ready to start the game and has finished updating." -ForegroundColor Green
    }
    Write-Host ""
}

# Step 4: Ask yes/no questions
Write-Host ""
while ($true) {
    do {
        if ($isIndonesian) {
            Write-Host "Launcher resmi sudah siap untuk memulai game, dan telah menyelesaikan Update ? (y/n/yes/no) " -ForegroundColor Blue -NoNewline
            $q1 = Read-Host
            $q1 = $q1.Trim()
            if ([string]::IsNullOrWhiteSpace($q1)) {
                Write-Host "[WARNING] Input tidak boleh kosong. Harap jawab dengan y/n atau yes/no." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Is the Official Launcher ready to start the game and has finished updating? (y/n/yes/no) " -ForegroundColor Blue -NoNewline
            $q1 = Read-Host
            $q1 = $q1.Trim()
            if ([string]::IsNullOrWhiteSpace($q1)) {
                Write-Host "[WARNING] Input cannot be empty. Please answer with y/n or yes/no." -ForegroundColor Yellow
            }
        }
    } while ([string]::IsNullOrWhiteSpace($q1))

    $q1 = $q1.ToLower()
    if ($q1 -in @('y','yes')) {
        $isAlternativeQuestion = $false
        while ($true) {
            if ($isAlternativeQuestion) {
                if ($isIndonesian) {
                    $theQuestion = "y/yes = Hapus Junction/Symlink | n/no = Buat Symlink | alt = Alternative Question:"
                } else {
                    $theQuestion = "y/yes = Remove Junction/Symlink | n/no = Create Symlink | alt = Alternative Question:"
                }
            } else {
                if ($isIndonesian) {
                    $theQuestion = "Wuthering Waves masih terinstall pada Steam ? (y/n/yes/no; alt)"
                } else {
                    $theQuestion = "Is Wuthering Waves still installed on Steam ? (y/n/yes/no; alt)"
                }
            }

            do {
                Write-Host "${theQuestion} " -ForegroundColor Blue -NoNewline
                $q2 = Read-Host
                $q2 = $q2.Trim()
                if ([string]::IsNullOrWhiteSpace($q2)) {
                    if ($isIndonesian) {
                        Write-Host "[WARNING] Input tidak boleh kosong. Harap jawab dengan y/n atau yes/no atau a/alt." -ForegroundColor Yellow
                    } else {
                        Write-Host "[WARNING] Input cannot be empty. Please answer with y/n or yes/no or a/alt." -ForegroundColor Yellow
                    }
                }
            } while ([string]::IsNullOrWhiteSpace($q2))

            $q2 = $q2.ToLower()
            if ($q2 -in @('y','yes')) {
                Write-Host ""
                DoFuncRemoveSymLink
                Write-Host ""
                break 2
            } elseif ($q2 -in @('n','no')) {
                Write-Host ""
                DoFuncCreateSymLink
                Write-Host ""
                break 2
            } elseif ($q2 -in @('a','alt')) {
                $isAlternativeQuestion = (-not ($isAlternativeQuestion))
            } else {
                if ($isIndonesian) {
                    Write-Host "[WARNING] Jawaban tidak valid. Harap jawab dengan y/n atau yes/no atau a/alt." -ForegroundColor Yellow
                } else {
                    Write-Host "[WARNING] Invalid answer. Please answer with y/n or yes/no or a/alt." -ForegroundColor Yellow
                }
            }
        }
    } elseif ($q1 -in @('n','no')) {
        Write-Host ""
        DoFuncInfoText
        Write-Host ""
        break
    } else {
        if ($isIndonesian) {
            Write-Host "[WARNING] Jawaban tidak valid. Harap jawab dengan y/n atau yes/no." -ForegroundColor Yellow
        } else {
            Write-Host "[WARNING] Invalid answer. Please answer with y/n or yes/no." -ForegroundColor Yellow
        }
    }
}
