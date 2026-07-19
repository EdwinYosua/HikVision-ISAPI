# FOR DAILY NVR REPORTING
# $nvrList = Import-Csv "$PSScriptRoot\nvr_config.csv"

# foreach ($nvr in $nvrList) {

#     & "$PSScriptRoot\extractNVR.ps1" ` for Daily NVR
#         -NVR_IP $nvr.IP `
#         -User $nvr.Username `
#         -Pass $nvr.Password `

# }


#FOR LISTING ALL CCTV from LISTED NVR(.csv)
$nvrList = Import-Csv "$PSScriptRoot\nvr_config.csv"

# 1. Define the path for your output text file
$OutputFile = "$PSScriptRoot\NVR_CCTV_Report.txt"

# 2. (Optional) Clear the old output file before running 
if (Test-Path $OutputFile) { Remove-Item $OutputFile }

foreach ($nvr in $nvrList) {

    Write-Host "Connecting to $($nvr.IP)..."


    & "$PSScriptRoot\extractCCTV.ps1" `
        -NVR_IP $nvr.IP `
        -User $nvr.Username `
        -Pass $nvr.Password *>> $OutputFile

}


Write-Host "Report saved to: $OutputFile" -ForegroundColor Green