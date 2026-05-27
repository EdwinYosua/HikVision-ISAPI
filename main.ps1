$nvrList = Import-Csv "$PSScriptRoot\nvr_config.csv"

foreach ($nvr in $nvrList) {

    # Write-Host "Connecting to $($nvr.IP)..."

    & "$PSScriptRoot\extractNVR.ps1" `
        -NVR_IP $nvr.IP `
        -User $nvr.Username `
        -Pass $nvr.Password `

    # Write-Host ""
}

