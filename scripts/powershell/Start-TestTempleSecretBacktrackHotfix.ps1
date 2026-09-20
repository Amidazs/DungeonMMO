# Starts Rojo sync for FIVE scripts only. NEVER publishes a Roblox place.
# The live current cloud TEST Temple must have been independently backed up.
param(
    [Parameter(Mandatory=$true)]
    [string]$CloudBackupFile
)
$ErrorActionPreference = 'Stop'
$repo = Join-Path $env:USERPROFILE 'Documents\Roblox\DungeonMMO_Phase4_HUD_Integration_v1'
$project = Join-Path $repo 'test-temple-secret-backtrack-hotfix.project.json'
$sourceCommit = '52222dbc92b3c266919212eadde6f5546101168f'
$targetPlaceId = '117293035754309'
$universeId = '10765241947'
if ((git -C $repo branch --show-current).Trim() -ne 'wip/phase-4-test-hud-integration-v1') {
    throw 'Wrong source branch.'
}
if ((git -C $repo status --porcelain | Out-String).Trim()) {
    throw 'Source worktree is not clean; refusing an ambiguous hotfix.'
}
$sourcePaths = @(
    'src/ServerScriptService/Dungeon/DungeonRuntime.server.luau',
    'src/ServerScriptService/Dungeon/DungeonEncounterFlow.luau',
    'src/ServerScriptService/Dungeon/DungeonEncounterSequencer.luau',
    'src/ServerScriptService/Dungeon/DungeonEncounterRuntimeController.luau',
    'src/ServerScriptService/Core/Services/DungeonSecretDiscoveryService.luau'
)
git -C $repo diff --quiet $sourceCommit HEAD -- $sourcePaths
if ($LASTEXITCODE -ne 0) {
    throw 'The five approved backtracking scripts changed since local acceptance.'
}
$cfg = Get-Content $project -Raw | ConvertFrom-Json
if (@($cfg.servePlaceIds).Count -ne 1 -or [string]$cfg.servePlaceIds[0] -ne $targetPlaceId) {
    throw 'Hotfix does not target exactly the TEST Temple place.'
}
foreach ($node in @($cfg.tree, $cfg.tree.ServerScriptService,
    $cfg.tree.ServerScriptService.Dungeon,
    $cfg.tree.ServerScriptService.Core,
    $cfg.tree.ServerScriptService.Core.Services)) {
    if ($node.'$ignoreUnknownInstances' -ne $true) {
        throw 'An unmanaged-instance preservation guard is missing.'
    }
}
if ($cfg.tree.PSObject.Properties.Name -contains 'Workspace' -or $cfg.tree.PSObject.Properties.Name -contains 'StarterPlayer' -or $cfg.tree.PSObject.Properties.Name -contains 'ReplicatedStorage') {
    throw 'Scripts-only project unexpectedly manages player UI or authored world.'
}
$backup = Get-Item -LiteralPath $CloudBackupFile -ErrorAction Stop
if ($backup.Extension -notin @('.rbxl', '.rbxlx') -or $backup.Length -lt 1000000 -or $backup.LastWriteTime -lt (Get-Date).AddHours(-4) -or $backup.FullName -like "$env:TEMP*") {
    throw 'Backup must be a FRESH (under 4 hours), non-TEMP cloud Temple rbxl/rbxlx at least 1 MB.'
}
$cloudStudio = @(Get-CimInstance Win32_Process -Filter "name='RobloxStudioBeta.exe'" |
    Where-Object {
        $_.CommandLine -like "*placeId:$targetPlaceId*" -and
        $_.CommandLine -like "*universeId:$universeId*"
    })
if ($cloudStudio.Count -ne 1) {
    throw 'Open the EXISTING cloud TEST Temple through Creator Dashboard > Edit in Studio, not a local candidate.'
}
$hash = (Get-FileHash -LiteralPath $backup.FullName -Algorithm SHA256).Hash
Write-Host ('VERIFIED FRESH BACKUP FILE: ' + $backup.FullName)
Write-Host ('BACKUP SHA256: ' + $hash)
Write-Host ('TEST Temple cloud Studio PID: ' + $cloudStudio[0].ProcessId)
Write-Host ('TEST Temple Place ID: ' + $targetPlaceId)
Write-Host 'Rojo must be connected in THIS cloud Temple Studio window, never Lobby or local candidate.'
Write-Host 'Review Rojo pending changes: only five named ServerScriptService scripts may update.'
Write-Host 'STOP if Rojo proposes a Workspace change, deletion, unknown script replacement, or mismatched target.'
Write-Host 'This command does not publish anything.'
rojo serve $project --port 34873