param (
    [string[]] $DHCPServer,
    [string[]] $ScopeID,
    [string] $OutputPath,
    [bool] $NoClobber = $false
)

$myScopes = @()
ForEach ($server in $DHCPServer) {
    $myScopes += Get-DhcpServerv4Scope -ComputerName $server -ScopeId $ScopeID | Select-Object Name, ScopeId
}
$myScopes = $myScopes | Select-Object * -Unique

ForEach ($scope in $myScopes) {
    Write-Output "Processing $($scope.ScopeID)..."
    $myLeases = @()
        ForEach ($myServer in $DHCPServer) {
            $myLeases += Get-DhcpServerv4Lease -ComputerName $myServer -ScopeId $scope.ScopeID | Select-Object IPAddress,AddressState,ClientID,HostName,Description
        }
    $myLeases| Select-Object * -Unique | Export-Csv -NoTypeInformation -Path (Join-Path $outputPath -ChildPath  "Leases_$($scope.ScopeID).csv") -NoClobber:$NoClobber
}