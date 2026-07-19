param(
    [string]$NVR_IP,
    [string]$User,
    [string]$Pass
)

# =================================================================> START GET DEVICE INFO
[xml]$getNvrDeviceInfo = curl.exe -sS --digest -u "$User`:$Pass" "http://$NVR_IP/ISAPI/System/deviceInfo"
$DeviceName = $getNvrDeviceInfo.deviceInfo.deviceName

# =================================================================> START GET DEVICE TOTAL CHANNEL
[xml]$getDeviceCapabilities = curl.exe -sS --digest -u "$User`:$Pass" "http://$NVR_IP/ISAPI/System/capabilities"
$capNode = $getDeviceCapabilities.SelectSingleNode("//*[local-name()='RacmCap']/*[local-name()='inputProxyNums']")
$totalChannels = if ($capNode) { [int]$capNode.InnerText } else { 0 }

# =================================================================> START GET TTL USED CHANNELS (STATUS)
[xml]$getNvrChannelsStatus = curl.exe -sS --digest -u "$User`:$Pass" "http://$NVR_IP/ISAPI/ContentMgmt/InputProxy/channels/status"
$statusNodes = $getNvrChannelsStatus.SelectNodes("//*[local-name()='InputProxyChannelStatus']/*[local-name()='id']")
$ttlUsedChannels = if ($statusNodes) { $statusNodes.Count } else { 0 }

$unUsedChannels = $totalChannels - $ttlUsedChannels

# =================================================================> START GET CAMERA LIST (CONFIG + STATUS)
[xml]$getNvrChannelsConfig = curl.exe -sS --digest -u "$User`:$Pass" "http://$NVR_IP/ISAPI/ContentMgmt/InputProxy/channels"

$cameraList = @()
$configNodes = $getNvrChannelsConfig.SelectNodes("//*[local-name()='InputProxyChannel']")

if ($configNodes) {
    foreach ($node in $configNodes) {
        $camIdNode   = $node.SelectSingleNode("*[local-name()='id']")
        $camNameNode = $node.SelectSingleNode("*[local-name()='name']")
        $camIpNode   = $node.SelectSingleNode("*[local-name()='sourceInputPortDescriptor']/*[local-name()='ipAddress']")

        $camId   = if ($camIdNode)   { $camIdNode.InnerText.Trim() } else { "N/A" }
        $camName = if ($camNameNode) { $camNameNode.InnerText.Trim() -replace "[\r\n\t]", " " } else { "Unknown" }
        $camIp   = if ($camIpNode)   { $camIpNode.InnerText.Trim() } else { "N/A" }

       
        $statusNode = $getNvrChannelsStatus.SelectSingleNode("//*[local-name()='InputProxyChannelStatus'][*[local-name()='id']='$camId']")
        $onlineNode = if ($statusNode) { $statusNode.SelectSingleNode("*[local-name()='online']") } else { $null }

        $camStatus = if ($onlineNode) {
            if ($onlineNode.InnerText.Trim().ToLower() -eq "true") { "Online" } else { "Offline" }
        } else {
            "Unknown"
        }

        $cameraList += [PSCustomObject]@{
            ID     = [int]$camId
            Name   = $camName
            IP     = $camIp
            Status = $camStatus
        }
    }
}

# =================================================================> OUTPUT
$report = @()
$report += ""
$report += "==================== NVR SUMMARY ====================" 
$report += "Device: $DeviceName | IP: $NVR_IP"
$report += "Channels: Used $ttlUsedChannels | Unused $unUsedChannels | Total $totalChannels"
$report += "=====================================================" 
$report += ""

if ($cameraList.Count -gt 0) {
    $report += "Attached CCTV Cameras:"
    

    $tableString = $cameraList | Sort-Object ID | Format-Table -Property ID, Name, IP, Status -AutoSize | Out-String -Width 4096
    

    $report += $tableString.TrimEnd() 
} else {
    $report += "No attached CCTV cameras found." 
}
$report += ""


Write-Output $report