function New-AzureVM {
[CmdletBinding(DefaultParameterSetName='ExistingService')]
param(
    [Parameter(ParameterSetName='ExistingService', Mandatory=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='Service Name')]
    [Parameter(ParameterSetName='CreateService', Mandatory=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='Service Name')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${ServiceName},

    [Parameter(ParameterSetName='CreateService', ValueFromPipelineByPropertyName=$true, HelpMessage='Required if AffinityGroup is not specified. The data center region where the cloud service will be created.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${Location},

    [Parameter(ParameterSetName='CreateService', ValueFromPipelineByPropertyName=$true, HelpMessage='Required if Location is not specified. The name of an existing affinity group associated with this subscription.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${AffinityGroup},

    [Parameter(ParameterSetName='CreateService', ValueFromPipelineByPropertyName=$true, HelpMessage='The label may be up to 100 characters in length. Defaults to Service Name.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${ServiceLabel},

    [Parameter(ParameterSetName='CreateService', ValueFromPipelineByPropertyName=$true, HelpMessage='Dns address to which the cloud service’’s IP address resolves when queried using a reverse Dns query.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${ReverseDnsFqdn},

    [Parameter(ParameterSetName='CreateService', ValueFromPipelineByPropertyName=$true, HelpMessage='A description for the cloud service. The description may be up to 1024 characters in length.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${ServiceDescription},

    [Parameter(ParameterSetName='ExistingService', ValueFromPipelineByPropertyName=$true, HelpMessage='Deployment Label. Will default to service name if not specified.')]
    [Parameter(ParameterSetName='CreateService', ValueFromPipelineByPropertyName=$true, HelpMessage='Deployment Label. Will default to service name if not specified.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${DeploymentLabel},

    [Parameter(ParameterSetName='CreateService', ValueFromPipelineByPropertyName=$true, HelpMessage='Deployment Name. Will default to service name if not specified.')]
    [Parameter(ParameterSetName='ExistingService', ValueFromPipelineByPropertyName=$true, HelpMessage='Deployment Name. Will default to service name if not specified.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${DeploymentName},

    [Parameter(ParameterSetName='ExistingService', HelpMessage='Virtual network name.')]
    [Parameter(ParameterSetName='CreateService', HelpMessage='Virtual network name.')]
    [string]
    ${VNetName},

    [Parameter(ParameterSetName='ExistingService', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='DNS Settings for Deployment.')]
    [Parameter(ParameterSetName='CreateService', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='DNS Settings for Deployment.')]
    [ValidateNotNullOrEmpty()]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.DnsServer[]]
    ${DnsSettings},

    [Parameter(ParameterSetName='ExistingService', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='ILB Settings for Deployment.')]
    [Parameter(ParameterSetName='CreateService', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='ILB Settings for Deployment.')]
    [ValidateNotNullOrEmpty()]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.InternalLoadBalancerConfig]
    ${InternalLoadBalancerConfig},

    [Parameter(ParameterSetName='ExistingService', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='List of VMs to Deploy.')]
    [Parameter(ParameterSetName='CreateService', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='List of VMs to Deploy.')]
    [ValidateNotNullOrEmpty()]
    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVM[]]
    ${VMs},

    [Parameter(HelpMessage='Waits for VM to boot')]
    [ValidateNotNullOrEmpty()]
    [switch]
    ${WaitForBoot},

    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='The name of the reserved IP.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${ReservedIPName},

    [Parameter(HelpMessage='In-memory profile.')]
    [Microsoft.Azure.Common.Authentication.Models.AzureSMProfile]
    ${Profile},

    [Parameter(HelpMessage='Subscription name.')]
    [string]
    ${SubscriptionName}
    
    )

begin
{
    try {
        $outBuffer = $null
        $defaultSubscription = Get-AzureSubscription -Default

        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }

        if ($PSBoundParameters['SubscriptionName'])
        {
            $null = $PSBoundParameters.Remove('SubscriptionName')
            
            if ($defaultSubscription.SubscriptionName -ne $SubscriptionName) {
                Select-AzureSubscription -SubscriptionName $SubscriptionName -ErrorAction Stop}
        }

        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Azure\New-AzureVM', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        Select-AzureSubscription -SubscriptionName $defaultSubscription.SubscriptionName
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Azure\New-AzureVM
.ForwardHelpCategory Cmdlet

#>

}