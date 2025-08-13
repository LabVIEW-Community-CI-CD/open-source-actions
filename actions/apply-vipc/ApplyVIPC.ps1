param(
    [string]$MinimumSupportedLVVersion,
    [string]$VIP_LVVersion,
    [string]$SupportedBitness,
    [string]$RelativePath,
    [string]$VIPCPath
)
$script = Join-Path $PSScriptRoot '..' '..' 'scripts' 'apply-vipc' 'ApplyVIPC.ps1'
& $script @PSBoundParameters
