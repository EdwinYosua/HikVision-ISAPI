# LOCAL CONFIG FOR TESTING
."$PSScriptRoot\config.ps1"
# CREDENTIAL BASED CONFIG ( FOR LATER )
# $Cred = Import-Clixml "E:\ISAPI\NVRConfig.xml"

#VARIABLES
$NVR_IP = $NVR_IP #$Cred.$NVR_IP
$User = $NVR_USER #$Cred.UserName
$Pass = $NVR_PASS #$Cred.GetNetworkCredential().Password


# FUNCTIONS
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
        return $null   # better than 0 for text values
    }

    return $node.InnerText
}
# function Get-XmlNodeValue {

#     param (
#         [Parameter(Mandatory)]
#         [xml]$Xml,

#         [Parameter(Mandatory)]
#         [string]$XPath,

#         [string]$NamespaceUri = "http://www.hikvision.com/ver20/XMLSchema"
#     )

#     $ns = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
#     $ns.AddNamespace("h", $NamespaceUri)

#     $node = $Xml.SelectSingleNode($XPath, $ns)

#     if ($null -eq $node) {
#         return 0
#     }

#     return $node.InnerText
# }
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
        return 0
    }

    return $nodes.Count
}
# function Get-XmlNodeCount {
    
#     param (
#         [Parameter(Mandatory)]
#         [xml]$Xml,

#         [Parameter(Mandatory)]
#         [string]$XPath,

#         [string]$NamespaceUri = "http://www.hikvision.com/ver20/XMLSchema"
#     )

#     $ns = New-Object System.Xml.XmlNamespaceManager($Xml.NameTable)
#     $ns.AddNamespace("h", $NamespaceUri)

#     $nodes = $Xml.SelectNodes($XPath, $ns)

#     if ($null -eq $nodes) {
#         return 0
#     }

#     return $nodes.Count
# }

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

# create namespace manager
# $ns = New-Object System.Xml.XmlNamespaceManager($getNvrChannels.NameTable)
# $ns.AddNamespace("hik", "http://www.hikvision.com/ver20/XMLSchema")

# count all <id> nodes
# $ttlUsedChannels = ((
#         $getNvrChannels.SelectNodes("//hik:InputProxyChannelStatus/hik:id", $ns)
#     ).Count ) - $totalChannels

# Create namespace manager
# $ns = New-Object System.Xml.XmlNamespaceManager($getDeviceCapabilities.NameTable)
# $ns.AddNamespace("hik", "http://www.hikvision.com/ver20/XMLSchema")

# # Extract total channels
# $totalChannels = $getDeviceCapabilities.SelectSingleNode(
#     "//h:RacmCap/h:inputProxyNums",
#     $ns
# ).InnerText



#=================================================================> OUTPUT

Write-Host "$DeviceName XX.XX (Up X Days, Unused Channels $($totalChannels - $ttlUsedChannels) of $totalChannels)"


# $getNvrDeviceInfo.deviceInfo.ChildNodes # Show XML Tree Data