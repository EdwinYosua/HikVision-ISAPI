# LOCAL CONFIG FOR TESTING
."$PSScriptRoot\config.ps1"
# CREDENTIAL BASED CONFIG ( FOR LATER )
# $Cred = Import-Clixml "E:\ISAPI\NVRConfig.xml"


$NVR_IP = $NVR_IP #$Cred.$NVR_IP
$User = $NVR_USER #$Cred.UserName
$Pass = $NVR_PASS #$Cred.GetNetworkCredential().Password


#for SingleNode count
function Get-XmlNodeValue {
    param (
        [Parameter(Mandatory)]
        [xml]$Xml,

        [Parameter(Mandatory)]
        [string]$XPath
    )

    # auto-detect namespace
    $namespace = $Xml.DocumentElement.NamespaceURI

    $ns = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $ns.AddNamespace("h", $namespace)

    $node = $Xml.SelectSingleNode($XPath, $ns)

    if ($null -eq $node) {
        return $null
    }

    return $node.InnerText
}

#for SelectNodes (multiple node) count
function Get-XmlNodeCount {
    param (
        [Parameter(Mandatory)]
        [xml]$Xml,

        [Parameter(Mandatory)]
        [string]$XPath
    )

    # auto-detect namespace
    $namespace = $Xml.DocumentElement.NamespaceURI

    $ns = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $ns.AddNamespace("h", $namespace)

    $nodes = $Xml.SelectNodes($XPath, $ns)

    if ($null -eq $nodes) {
        return $null
    }

    return $nodes.Count
}

#=================================================================> START GET DEVICE INFO
[xml]$getNvrDeviceInfo = curl.exe -sS --digest -u "$User`:$Pass" `
    "http://$NVR_IP/ISAPI/System/deviceInfo" `

$DeviceName = $getNvrDeviceInfo.deviceInfo.deviceName


#=================================================================> START GET DEVICE TOTAL CHANNEL
[xml]$getDeviceCapabilities = curl.exe -sS --digest -u "$User`:$Pass" `
    "http://$NVR_IP/ISAPI/System/capabilities" `

$totalChannels = Get-XmlNodeValue `
    -Xml $getDeviceCapabilities `
    -XPath "//h:RacmCap/h:inputProxyNums"

#=================================================================> START GET TTL USED CHANNELS
[xml]$getNvrChannels = curl.exe -sS --digest -u "$User`:$Pass" `
    "http://$NVR_IP/ISAPI/ContentMgmt/InputProxy/channels/status"

$ttlUsedChannels = ( (Get-XmlNodeCount `
            -Xml $getNvrChannels `
            -XPath "//h:InputProxyChannelStatus/h:id") )


#=================================================================> OUTPUT

Write-Host "$DeviceName XX.XX (Up X Days, Unused Channels $($totalChannels - $ttlUsedChannels) of $totalChannels)"


# $getNvrDeviceInfo.deviceInfo.ChildNodes # Show XML Tree Data