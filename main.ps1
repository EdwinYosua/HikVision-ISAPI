$nvrList = Import-Csv "E:\ISAPI\config.csv"

foreach ($nvr in $nvrList) {

    # Write-Host "Connecting to $($nvr.IP)..."

    & "E:\ISAPI\extractNVR.ps1" `
        -NVR_IP $nvr.IP `
        -User $nvr.Username `
        -Pass $nvr.Password `

    # Write-Host ""
}

