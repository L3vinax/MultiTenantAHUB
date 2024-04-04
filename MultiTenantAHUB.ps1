#Connect-AzAccount
$azSubs = Get-AzSubscription

$AzureVM = @()

foreach ($azSub in $azSubs){
    Set-AzContext -Subscription $azsub | Out-Null
    $tenantid = (Get-AzContext).Tenant.Id
    $tenantName = (Get-azTenant | where-object Id -eq $tenantid).Name


    foreach ($azVM in Get-AzVM){
        $sku = get-azvmsize  -vmname $azVM.Name -ResourceGroupName $azVM.ResourceGroupName | where {$_.Name -eq $azVM.HardwareProfile.VmSize}
        if ($sku.NumberofCores -lt 8){
        $cores = 8
        }
        else {
        $cores = $sku.NumberOfCores
        }
        
        $results = @{
            Tenant = $tenantName
            Subscription = $azsub.Name
            VMName = $azVM.Name
            Cores = $cores
            

        }
        if (!$azVM.LicenseType) {
            $results += @{
                LicenseType = "No License"
            }
        }
        else {
            $results += @{
                LicenseType = $azVM.LicenseType
            }
        }
        $ServiceObject = New-Object -TypeName PSObject -Property $results
        $AzureVM += $ServiceObject
    }
    
}    
    $AzureVM | Export-CSV -Path "c:\temp\AzVM-Licensing.csv" -NoTypeInformation -Force
