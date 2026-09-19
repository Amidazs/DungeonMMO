# Combined HUD + Temple candidate. This script NEVER publishes Roblox places.
# Prepare and open the TEST Temple candidate. Never publishes automatically.
param([switch]$SkipVersionHistory)
$ErrorActionPreference = 'Stop'
$repo = Join-Path $env:USERPROFILE 'Documents\Roblox\DungeonMMO_Phase4_HUD_Integration_v1'
$branch = 'wip/phase-4-test-hud-integration-v1'
$universe = '10765241947'
$dungeon = '117293035754309'
$lobby = '134132328219009'
if (!(Test-Path (Join-Path $repo 'test-temple-publish.project.json'))) {
    throw 'Phase 4 TEST Temple release project not found.'
}
Push-Location $repo
try {
    if ((git branch --show-current).Trim() -ne $branch) {
        throw "Wrong branch; expected $branch"
    }
    if ((git status --porcelain | Out-String).Trim()) {
        throw 'Uncommitted changes present. Refusing ambiguous release.'
    }
    git fetch --no-tags origin $branch | Out-Null
    if ($LASTEXITCODE -ne 0 -or
        (git rev-parse HEAD).Trim() -ne (git rev-parse FETCH_HEAD).Trim()) {
        throw 'Local HEAD differs from approved remote branch.'
    }
    $folder = Join-Path $env:TEMP 'DungeonMMO_TestTemple_HUD_ReleaseCandidate'
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    $place = Join-Path $folder 'test-temple-hud-publish.rbxl'
    rojo build test-temple-publish.project.json -o $place | Out-Null
    if ($LASTEXITCODE -ne 0 -or !(Test-Path $place)) {
        throw 'TEST Temple build failed.'
    }
    $sha = (git rev-parse HEAD).Trim()
    $fileHash = (Get-FileHash $place -Algorithm SHA256).Hash
    $studio = Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Roblox\Versions') -Filter RobloxStudioBeta.exe -Recurse -File | Select-Object -First 1 -ExpandProperty FullName
    if (!$studio) { throw 'Roblox Studio executable missing.' }
    $history = "https://create.roblox.com/dashboard/creations/experiences/$universe/places/$dungeon/version-history"
    Write-Host ('TEST Dungeon ONLY: ' + $dungeon)
    Write-Host ('Lobby to preserve: ' + $lobby)
    Write-Host ('Source commit: ' + $sha)
    Write-Host ('Candidate: ' + $place)
    Write-Host ('Candidate SHA256: ' + $fileHash)
    Write-Host 'No Roblox cloud place was changed.'
    if (!$SkipVersionHistory) { Start-Process $history }
    Start-Process -FilePath $studio -ArgumentList @('--task','EditFile','--localPlaceFile',('"' + $place + '"'))
    Write-Host 'Opened the TEST Temple candidate WITH the restored HUD in Studio.'
    Write-Host 'STOP: Before publishing, open the CURRENT cloud TEST Dungeon and Save to File as a dated rollback backup.'
    Write-Host 'Git source checkpoints do NOT back up cloud models, terrain or DataStores.'
    Write-Host 'Do not publish until the cloud place backup and target place ID are verified.'
    Write-Host 'Then in the local candidate: File > Publish to Roblox As...'
    Write-Host ('Choose experience ' + $universe + ', existing Dungeon place ' + $dungeon + ', then Overwrite.')
    Write-Host 'DO NOT select the Lobby, create a new place, or publish to PROD.'
} finally {
    Pop-Location
}
