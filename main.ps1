# FOR DAILY NVR REPORTING
$nvrList = Import-Csv "$PSScriptRoot\nvr_config.csv"
foreach ($nvr in $nvrList) {
    & "$PSScriptRoot\extractNVR.ps1" `
        -NVR_IP $nvr.IP `
        -User $nvr.Username `
        -Pass $nvr.Password `
}


# #FOR LISTING ALL CCTV from LISTED NVR
# $nvrList = Import-Csv "$PSScriptRoot\nvr_config.csv"
# $OutputFile = "$PSScriptRoot\NVR_CCTV_Report.txt"
# if (Test-Path $OutputFile) { Remove-Item $OutputFile }
# foreach ($nvr in $nvrList) {
#     Write-Host "Connecting to $($nvr.IP)..."
#     & "$PSScriptRoot\extractCCTV.ps1" `
#         -NVR_IP $nvr.IP `
#         -User $nvr.Username `
#         -Pass $nvr.Password *>> $OutputFile
# }
# Write-Host "Report saved to: $OutputFile" -ForegroundColor Green


# #FOR LISTING ALL OFFLINE CCTV from LISTED NVR
# $nvrList = Import-Csv "$PSScriptRoot\nvr_config.csv"
# $OutputFile = "$PSScriptRoot\NVR_CCTV_Report.txt"
# if (Test-Path $OutputFile) { Remove-Item $OutputFile }
# foreach ($nvr in $nvrList) {
#     Write-Host "Connecting to $($nvr.IP)..."
#     & "$PSScriptRoot\extractOfflineCCTV.ps1" `
#         -NVR_IP $nvr.IP `
#         -User $nvr.Username `
#         -Pass $nvr.Password *>> $OutputFile
# }
# Write-Host "Report saved to: $OutputFile" -ForegroundColor Green