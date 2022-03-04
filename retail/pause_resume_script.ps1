#should auto for this.
az login

#for powershell...
Connect-AzAccount -DeviceCode
$subs = Get-AzSubscription | Select-Object -ExpandProperty Name

if($subs.GetType().IsArray -and $subs.length -gt 1)
{
    $subOptions = [System.Collections.ArrayList]::new()
    for($subIdx=0; $subIdx -lt $subs.length; $subIdx++)
    {
        $opt = New-Object System.Management.Automation.Host.ChoiceDescription "$($subs[$subIdx])", "Selects the $($subs[$subIdx]) subscription."   
        $subOptions.Add($opt)
    }
    $selectedSubIdx = $host.ui.PromptForChoice('Enter the desired Azure Subscription for this lab','Copy and paste the name of the subscription to make your choice.', $subOptions.ToArray(),0)
    $selectedSubName = $subs[$selectedSubIdx]
    Write-Host "Selecting the $selectedSubName subscription"
    Select-AzSubscription -SubscriptionName $selectedSubName
    az account set --subscription $selectedSubName
}

#Getting User Inputs
$rgName = read-host "Enter the resource Group Name";
$location = (Get-AzResourceGroup -Name $rgName).Location
$init =  (Get-AzResourceGroup -Name $rgName).Tags["DeploymentId"]
$random =  (Get-AzResourceGroup -Name $rgName).Tags["UniqueId"]
$suffix = "$random-$init"     
$synapseWorkspaceName = "synapseretail$init$random"
$sqlPoolName = "RetailDW"
$app_retaildemo_name = "retaildemo-app-$suffix";
$title    = 'Choices'
$question = 'What would you like to do with the environment?'
$choices  = '&Pause', '&Resume'

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
if($decision -eq 0)
{

write-host "Stopping SQL pool"
install-module Az.Synapse -f
#stop SQL
az synapse sql pool pause --name $SQLPoolName --resource-group $rgName --workspace-name $synapseWorkspaceName

write-host "Stopping Web apps"
#stop web apps
az webapp stop  --name $app_retaildemo_name --resource-group $rgName

write-host "Pause operation successfull"
}

else
{

#Resume SQL
write-host "Starting Sql Pool"
az synapse sql pool resume --name $SQLPoolName --resource-group $rgName --workspace-name $synapseWorkspaceName

#start web apps
write-host "Starting web apps"
az webapp start  --name $app_retaildemo_name --resource-group $rgName

write-host "Resume operation successfull"
}