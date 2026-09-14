[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$LobbyGlb,
    [Parameter(Mandatory=$true)][string]$TemplePlace
)

$ErrorActionPreference = "Stop"

$ExpectedLobby = "F624C96AF9F67BB374FE36752331A26B59C4C7E7AA8B228223AE4C04919E981B"
$ExpectedTemple = "A3039361882632E857228411A0F36BBA9086A22A37080FA2034CE2B25921BB32"
$ExpectedLobbySize = 40984352
$ExpectedTempleSize = 13622440

function Assert-Candidate {
    param(
        [string]$Path,
        [string]$ExpectedHash,
        [Int64]$ExpectedSize,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label file not found: $Path"
    }

    $item = Get-Item -LiteralPath $Path
    if ($item.Length -ne $ExpectedSize) {
        throw "$Label size mismatch. Expected $ExpectedSize, got $($item.Length)."
    }

    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -ne $ExpectedHash) {
        throw "$Label SHA-256 mismatch. Expected $ExpectedHash, got $actual."
    }
}

Assert-Candidate -Path $LobbyGlb -ExpectedHash $ExpectedLobby -ExpectedSize $ExpectedLobbySize -Label "Lobby"
Assert-Candidate -Path $TemplePlace -ExpectedHash $ExpectedTemple -ExpectedSize $ExpectedTempleSize -Label "Temple"

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$target = Join-Path $env:TEMP "DungeonMMO_EnvironmentCandidates_$stamp"
New-Item -ItemType Directory -Path $target | Out-Null

$lobbyOut = Join-Path $target ([IO.Path]::GetFileName($LobbyGlb))
$templeOut = Join-Path $target ([IO.Path]::GetFileName($TemplePlace))
Copy-Item -LiteralPath $LobbyGlb -Destination $lobbyOut
Copy-Item -LiteralPath $TemplePlace -Destination $templeOut

Write-Host ""
Write-Host "Candidate fingerprints: PASS"
Write-Host "Staged Lobby: $lobbyOut"
Write-Host "Staged Temple: $templeOut"
Write-Host ""
Write-Host "No repository files were added, staged, committed, pushed, or published."
