param (
    [string[]] $DHCPServer,
    [string[]] $ScopeID,
    [string] $OutputPath,
    [bool] $NoClobber = $false,
    [bool] $OnlyActiveLeases = $false
)

# Initalize var for holding the scopes
$myScopes = @()
# For each server specified in the DHCPServer parameter
ForEach ($server in $DHCPServer) {
    ## Get the scopes where IDs are like the data entered in the ScopeID parameter
    ## We do this as a loop because Microsoft DHCP servers can be "clustered" and may not have the same data
    $myScopes += Get-DhcpServerv4Scope -ComputerName $server | Where-Object {$_.ScopeId -like $ScopeID} | Select-Object Name, ScopeId
}
# Remove duplicate entries from the scopes list
$myScopes = $myScopes | Select-Object * -Unique

# For each scope to be exported
ForEach ($scope in $myScopes) {
    ## Give output stating current scope
    Write-Output "Processing $($scope.ScopeID)..."
    ## Initalize var for holding the leases in this scope
    $myLeases = @()
    ## For each server specified in the DHCPServer parameter
    ForEach ($myServer in $DHCPServer) {
        ### Get the lease data for the current scope on the current server
        ### Again, we do this as a loop because Microsoft DHCP servers can be "clustered" and may not have the same data
        $myLeases += Get-DhcpServerv4Lease -ComputerName $myServer -ScopeId $scope.ScopeID | Select-Object IPAddress,AddressState,ClientID,HostName,Description
    }
    ## If OnlyActiveLeases are desired, select only active leases from the results
    If ($OnlyActiveLeases) {$myLeases = $myLeases | Where-Object {$_.AddressState -eq "Active"}}
    ## Remove duplicate lease entries and export the lease data to CSV in the path selected in the OutputPathparameter
    $myLeases | Select-Object * -Unique | Export-Csv -NoTypeInformation -Path (Join-Path $outputPath -ChildPath  "Leases_$($scope.ScopeID).csv") -NoClobber:$NoClobber
}
