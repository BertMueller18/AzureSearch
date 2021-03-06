function Get-AzureStorageAccount {
[CmdletBinding()]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true, HelpMessage='Storage Account Name.')]
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


        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Azure\Get-AzureStorageAccount', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters | % {
            $key = Get-AzureStorageKey -StorageAccountName $_.StorageAccountName
            $ctx = New-AzureStorageContext -StorageAccountName $_.StorageAccountName -StorageAccountKey $key.primary
            $subs = Get-AzureSubscription -Current

            $_ | Add-Member -MemberType NoteProperty -Name Ctx -Value $ctx -PassThru -force |
                 Add-Member -MemberType NoteProperty -Name 'SubscriptionName' -Value $subs.SubscriptionName  -PassThru -force
        }}
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

.ForwardHelpTargetName Azure\Get-AzureStorageAccount
.ForwardHelpCategory Cmdlet

#>