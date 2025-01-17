# Usage: scoop import <path/url to scoopfile.json> [options]
# Summary: Imports apps, buckets and configs from a Scoopfile in JSON format
# Help: To replicate a Scoop installation from a file stored on Desktop, run
#      scoop import Desktop\scoopfile.json
#
# Options:
#   -r, --reset                     Reset the app after installation

. "$PSScriptRoot\..\lib\getopt.ps1"
. "$PSScriptRoot\..\lib\manifest.ps1"

$opt, $scoopfile, $err = getopt $args 'r' 'reset'
if ($err) { "scoop import: $err"; exit 1 }

$reset = $opt.r -or $opt.reset
$import = $null
$bucket_names = @()
$def_arch = Get-DefaultArchitecture

if (Test-Path $scoopfile) {
    $import = parse_json $scoopfile
} elseif ($scoopfile -match '^(ht|f)tps?://|\\\\') {
    $import = url_manifest $scoopfile
}

if (!$import) { abort 'Input file not a valid JSON.' }

foreach ($item in $import.config.PSObject.Properties) {
    set_config $item.Name $item.Value | Out-Null
    Write-Host "'$($item.Name)' has been set to '$($item.Value)'"
}

foreach ($item in $import.buckets) {
    add_bucket $item.Name $item.Source | Out-Null
    $bucket_names += $item.Name
}

foreach ($item in $import.apps) {
    $instArgs = @()
    $holdArgs = @()
    $info = $item.Info -Split ', '
    if ('Global install' -in $info) {
        $instArgs += '--global'
        $holdArgs += '--global'
    }
    if ('64bit' -in $info -and '64bit' -ne $def_arch) {
        $instArgs += '--arch', '64bit'
    } elseif ('32bit' -in $info -and '32bit' -ne $def_arch) {
        $instArgs += '--arch', '32bit'
    } elseif ('arm64' -in $info -and 'arm64' -ne $def_arch) {
        $instArgs += '--arch', 'arm64'
    }

    $app = ""
    if ($item.Source -in $bucket_names) {
        $app += "$($item.Source)/"
    }
    $app += $item.Name
    if ($item.Version) {
        $app += "@$($item.Version)"
    }

    & "$PSScriptRoot\scoop-install.ps1" $app @instArgs

    if ($reset) {
        & "$PSScriptRoot\scoop-reset.ps1" $app
    }

    if ('Held package' -in $info) {
        & "$PSScriptRoot\scoop-hold.ps1" $item.Name @holdArgs
    }
}
