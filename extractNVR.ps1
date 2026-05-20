# LOCAL CONFIG FOR TESTING
# ."$PSScriptRoot\config.ps1"
# CREDENTIAL BASED CONFIG ( FOR LATER )
# $Cred = Import-Clixml "E:\ISAPI\NVRConfig.xml"

#VARIABLES
# $NVR_IP = $NVR_IP #$Cred.$NVR_IP
# $User = $NVR_USER #$Cred.UserName
# $Pass = $NVR_PASS #$Cred.GetNetworkCredential().Password


param(
    [string]$NVR_IP,
    [string]$User,
    [string]$Pass
)

# FUNCTIONS
#for SingleNode count
function Get-XmlNodeValue {

    param (
        [Parameter(Mandatory)]
        [xml]$Xml,

        [Parameter(Mandatory)]
        [string]$XPath
    )

    # AUTO DETECT NAMESPACE
    $NamespaceUri = $Xml.DocumentElement.NamespaceURI

    $ns = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $ns.AddNamespace("h", $NamespaceUri)

    $node = $Xml.SelectSingleNode($XPath, $ns)

    if ($null -eq $node) {
        return 0
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

    # AUTO DETECT NAMESPACE
    $NamespaceUri = $Xml.DocumentElement.NamespaceURI

    $ns = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
    $ns.AddNamespace("h", $NamespaceUri)

    $nodes = $Xml.SelectNodes($XPath, $ns)

    if ($null -eq $nodes) {
        return 0
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

$unUsedChannels = $totalChannels - $ttlUsedChannels

#=================================================================> OUTPUT

Write-Host "$DeviceName $NVR_IP (Up X Days, Unused Channels $unUsedChannels of $totalChannels)"


# $getNvrDeviceInfo.deviceInfo.ChildNodes # Show XML Tree Data