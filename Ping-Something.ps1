function Ping-Localhost {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][PSCustomObject] $Env
    )


    process {
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        ping localhost

        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

    }
    
}