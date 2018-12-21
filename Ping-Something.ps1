function Ping-Localhost {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][PSCustomObject] $Env
    )


    process {
    
        Write-Output $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        ping localhost | Write-Output

        Write-Output $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

    }
    
}
