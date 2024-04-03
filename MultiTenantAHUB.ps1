#Connect-AzAccount

$aztenants = Get-AzTenant
foreach ($aztenant in $aztenants){
$aztenantid = $aztenant.id
Set-AzContext -TenantId $aztenantid

$azSubs = Get-AzSubscription

foreach ($azSub in $azSubs){
    Set-AzContext -Subscription $azsub | Out-Null
    $azsubname = $azsub.Name
    $AzureVM = @()
    $AzureVMSS = @()

    foreach ($azVM in Get-AzVM){
        $sku = get-azvmsize  -vmname $azVM.Name -ResourceGroupName $azVM.ResourceGroupName | where {$_.Name -eq $azVM.HardwareProfile.VmSize}
        if ($sku.NumberofCores -lt 8){
        $cores = 8
        }
        else {
        $cores = $sku.NumberOfCores
        }
        
        $results = @{
            Tenant = $aztenantname
            Subscription = $azsubname
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
    
    foreach ($vmss in Get-Azvmss) {
    
    $vmsssku = get-azvmsize -Location $vmss.Location | where {$_.Name -eq $vmss.sku.Name}
    if ($vmsssku.NumberOfCores -lt 8){
    $vmsscores = 8
    }
    else {
    $vmsscores = $vmsssku.NumberOfCores
    }
    
    $vmssresults = @{
        Tenant = $aztenantname
        Subscription = $azsubname
        VMSS = $vmss.Name
        Cores = $vmsscores
        }
        if (!$vmss.VirtualMachineProfile.LicenseType) {
            $vmssresults += @{
                LicenseType = "No License"
            }
        }
        else {
            $vmssresults += @{
                LicenseType = $vmss.VirtualMachineProfile.LicenseType
            }
        }
        $AzureVMSS += $ServiceObject

}
    $AzureVM | Export-CSV -Path "c:\temp\AzVM-Licensing.csv" -NoTypeInformation -Force

}
}
