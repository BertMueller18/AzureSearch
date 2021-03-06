function Get-AzureStorageKey {
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true, HelpMessage='Service name.')]
    [Alias('ServiceName')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${StorageAccountName},

    [Parameter(Position=1, ValueFromPipelineByPropertyName=$true, HelpMessage='Subscription name.')]
    [ValidateNotNullOrEmpty()]
    [string]
    ${SubscriptionName},

    [Parameter(HelpMessage='In-memory profile.')]
    [Microsoft.Azure.Common.Authentication.Models.AzureSMProfile]
    ${Profile})

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
            
            Select-AzureSubscription -SubscriptionName $SubscriptionName -ErrorAction Stop
        }

        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Azure\Get-AzureStorageKey', [System.Management.Automation.CommandTypes]::Cmdlet)
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
}
<#

.ForwardHelpTargetName Azure\Get-AzureStorageKey
.ForwardHelpCategory Cmdlet

#>

