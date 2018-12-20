function Backup-Database {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {

    }

    process {

        Write-Host $Settings.env.name '  ----  '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='


        $username = $Settings.db.userName
        $password = $Settings.db.password
        
        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
        $mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

        $backupFile = "{0}\{1}-{2}.bak" -f $Settings.db.backupDirectory, $Settings.db.name, $(get-date -f yyyy-MM-dd)

        Backup-SqlDatabase -ServerInstance $Settings.db.serverInstance -Database $Settings.db.name -BackupFile $backupFile -Credential $mycreds -Verbose
    }
}
function Close-DBConnections {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin { 
    }
    
    process {

        Write-Host $Settings.env.name '  ----  '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        $db = $Settings.db.name

        $query = @"
    declare @execSql varchar(1000), @databaseName varchar(100)
    -- Set the database name for which to kill the connections
    set @databaseName = '${db}'
    set @execSql = ''
    select @execSql = @execSql + 'kill ' + convert(char(10), spid) + ' '
    from master.dbo.sysprocesses
    where   db_name(dbid) = @databaseName
        and
        DBID <> 0
        and
        spid <> @@spid
    exec(@execSql)
    GO
"@

        # Kill all DB connections
        Invoke-Sqlcmd -ServerInstance $Settings.db.serverInstance -Username $Settings.db.userName -Password $Settings.db.password -Query $query -Verbose
    }
    end {
        Write-Host $Settings.env.name '  ----  '$PSCmdlet.MyInvocation.MyCommand.Name ' Complete ================='
        Write-Host $Settings.env.name ('  DB connections closed for {0}:{1}' -f $Settings.db.serverInstance, $Settings.db.name)
    }

}
function ConvertTo-PSObject {
 
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string] $JsonStr
    )
       
    process {

        $json = ConvertFrom-Json $JsonStr
        Write-Output $json

    }
}
Function Copy-Installer {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {
    
    }

    process {

        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        $sourceInstallerFolder = "{0}\{1}\{1}.{2}_DevQA" -f 
        $Settings.sched.sourceInstallerFolder,
        $Settings.env.release,
        $Settings.env.build
        
        $targetReleaseInstallerFolder = "{0}\{1}" -f $Settings.sched.targetInstallerFolder, $Settings.env.release
        $targetBuildInstallerFolder = "{0}\{1}.{2}_DevQA" -f
        $targetReleaseInstallerFolder,
        $Settings.env.release,
        $Settings.env.build
        

        # Setup directories
        try {
            New-Item -ItemType Directory -Force -Path $targetReleaseInstallerFolder
            Write-Host Made Directory $targetReleaseInstallerFolder
        }
        catch {
            Write-Host Folder $targetReleaseInstallerFolder already exists
        }
        try {
            New-Item -ItemType Directory -Force -Path $targetBuildInstallerFolder
            Write-Host Made Directory $targetBuildInstallerFolder
        }
        catch {
            Write-Host Folder $targetBuildInstallerFolder already exists
        }
        
        # Copy installer locally
        try {
            
            Write-Host "sourceInstallerFolder:" $sourceInstallerFolder
            
            Copy-Item -Path "$sourceInstallerFolder\*" -Destination $targetBuildInstallerFolder -Recurse -force -Verbose
            
            Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
            Write-Host $Settings.env.name '  Copy Complete'
        }
        catch {
            
            Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
            Write-Host $Settings.env.name '   Problem copying'
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host $Settings.env.name "   " $ErrorMessage
            Write-Host $Settings.env.name "   " $FailedItem
        }
        
    }
}
function Edit-AppServicesConfig {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {
        
    }

    process {
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        $confFile = "{0}\SchedAppServices\VizuALL.ServiceHost.exe.config" -f $Settings.sched.installDirectory

        
        Write-Host "   " $confFile
        
        $doc = (Get-Content $confFile) -as [Xml]
        $obj = $doc.configuration.appSettings.add | Where-Object {$_.Key -eq 'Server'}
        $obj.value = $Settings.db.serverInstance
        $obj = $doc.configuration.appSettings.add | Where-Object {$_.Key -eq 'Database'}
        $obj.value = $Settings.db.name
        $doc.Save($confFile)
    }

    end {

        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        Write-Host $Settings.env.name "  SQL Instance: " $Settings.db.serverInstance
        Write-Host $Settings.env.name "  DB Name: "  $Settings.db.name
    }

}
function Edit-WebServicesConfig {
      
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {
    
    }

    process {
        
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        $confFile = "{0}\ScheduALLWebServiceAPI\web.config" -f $Settings.sched.installDirectory
        Write-Host "   " $confFile
        
        $doc = (Get-Content $confFile) -as [Xml]
        $obj = $doc.configuration.appSettings.add | Where-Object {$_.Key -eq 'Server'}
        $obj.value = $Settings.db.serverInstance
        $obj = $doc.configuration.appSettings.add | Where-Object {$_.Key -eq 'Database'}
        $obj.value = $Settings.db.name
        $doc.Save($confFile)
    }

    end {

        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        Write-Host $Settings.env.name "  SQL Instance: " $Settings.db.serverInstance
        Write-Host $Settings.env.name "  DB Name: " $Settings.db.name

    }

    
}
function Get-EnvironmentConfigByName {
    param(
        [parameter(Mandatory = $true, ParameterSetName = "pipe", ValueFromPipeline)] [string] $jsonStr,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $mongoHost,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $mongoDB,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $mongoCollection,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $mongoName
                       
    )
    
    if ($PSCmdlet.ParameterSetName -eq "pipe") {
        $obj = ConvertFrom-Json $jsonStr
        
    }
    else {
        $obj = @{
            mongo = @{
                Host       = $mongoHost
                DB         = $mongoDB
                Collection = $mongoCollection
                Name       = $mongoName

            }
    
        }
    }

    Connect-Mdbc $obj.mongo.Host $obj.mongo.DB $obj.mongo.Collection

    $data = Get-MdbcData (New-MdbcQuery name -EQ $obj.mongo.Name)
 
    return $data

}
# #################################################################################  
# ##  
# ## Server Health Check  
# ## Created by Sravan Kumar S   
# ## Date : 3 Mar 2014  
# ## Version : 1.0  
# ## Email: sravankumar.s@outlook.com    
# ## This scripts check the server Avrg CPU and Memory utlization along with C drive  
# ## disk utilization and sends an email to the receipents included in the script 
# ################################################################################  
 
# $ServerListFile = "C:\ServerList.txt"   
# $ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue  
# $Result = @()  
# ForEach($computername in $ServerList)  
# { 
 
# $AVGProc = Get-WmiObject -computername $computername win32_processor |  
# Measure-Object -property LoadPercentage -Average | Select Average 
# $OS = gwmi -Class win32_operatingsystem -computername $computername | 
# Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }} 
# $vol = Get-WmiObject -Class win32_Volume -ComputerName $computername -Filter "DriveLetter = 'C:'" | 
# Select-object @{Name = "C PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } } 
   
# $result += [PSCustomObject] @{  
#         ServerName = "$computername" 
#         CPULoad = "$($AVGProc.Average)%" 
#         MemLoad = "$($OS.MemoryUsage)%" 
#         CDrive = "$($vol.'C PercentFree')%" 
#     } 
 
#     $Outputreport = "<HTML><TITLE> Server Health Report </TITLE> 
#                      <BODY background-color:peachpuff> 
#                      <font color =""#99000"" face=""Microsoft Tai le""> 
#                      <H2> Server Health Report </H2></font> 
#                      <Table border=1 cellpadding=0 cellspacing=0> 
#                      <TR bgcolor=gray align=center> 
#                        <TD><B>Server Name</B></TD> 
#                        <TD><B>Avrg.CPU Utilization</B></TD> 
#                        <TD><B>Memory Utilization</B></TD> 
#                        <TD><B>C Drive Utilizatoin</B></TD></TR>" 
                         
#     Foreach($Entry in $Result)  
     
#         {  
#           if((($Entry.CpuLoad) -or ($Entry.memload)) -ge "80")  
#           {  
#             $Outputreport += "<TR bgcolor=red>"  
#           }  
#           else 
#            { 
#             $Outputreport += "<TR>"  
#           } 
#           $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.CPULoad)</TD><TD align=center>$($Entry.MemLoad)</TD><TD align=center>$($Entry.Cdrive)</TD></TR>"  
#         } 
#      $Outputreport += "</Table></BODY></HTML>"  
#         }  
  
# $Outputreport | out-file C:\Scripts\Test.htm  
# Invoke-Expression C:\Scripts\Test.htm 
# ##Send email functionality from below line, use it if you want    
# $smtpServer = "yoursmtpserver.com" 
# $smtpFrom = "fromemailaddress@test.com" 
# $smtpTo = "receipentaddress@test.com" 
# $messageSubject = "Servers Health report" 
# $message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
# $message.Subject = $messageSubject 
# $message.IsBodyHTML = $true 
# $message.Body = "<head><pre>$style</pre></head>" 
# $message.Body += Get-Content C:\scripts\test.htm 
# $smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
# $smtp.Send($message)
# #################################################################################  
# ##  
# ## Server Health Check  
# ## Created by Sravan Kumar S   
# ## Date : 3 Mar 2014  
# ## Version : 1.0  
# ## Email: sravankumar.s@outlook.com    
# ## This scripts check the server Avrg CPU and Memory utlization along with C drive  
# ## disk utilization and sends an email to the receipents included in the script 
# ################################################################################  
 
# $ServerListFile = "C:\Servers.txt"   
# $ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue  
# $Result = @()  
# ForEach($computername in $ServerList)  
# { 
 
# $AVGProc = Get-WmiObject -computername $computername win32_processor |  
# Measure-Object -property LoadPercentage -Average | Select Average 
# $OS = gwmi -Class win32_operatingsystem -computername $computername | 
# Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }} 
# $vol = Get-WmiObject -Class win32_Volume -ComputerName $computername -Filter "DriveLetter = 'C:'" | 
# Select-object @{Name = "C PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } } 
   
# $result += [PSCustomObject] @{  
#         ServerName = "$computername" 
#         CPULoad = "$($AVGProc.Average)%" 
#         MemLoad = "$($OS.MemoryUsage)%" 
#         CDrive = "$($vol.'C PercentFree')%" 
#     } 
 
#     $Outputreport = "<HTML><TITLE> Server Health Report </TITLE> 
#                      <BODY background-color:peachpuff> 
#                      <font color =""#99000"" face=""Microsoft Tai le""> 
#                      <H2> Server Health Report </H2></font> 
#                      <Table border=1 cellpadding=0 cellspacing=0> 
#                      <TR bgcolor=gray align=center> 
#                        <TD><B>Server Name</B></TD> 
#                        <TD><B>Avrg.CPU Utilization</B></TD> 
#                        <TD><B>Memory Utilization</B></TD> 
#                        <TD><B>C Drive Utilizatoin</B></TD></TR>" 
                         
#     Foreach($Entry in $Result)  
     
#         {  
#           if((($Entry.CpuLoad) -or ($Entry.memload)) -ge "80")  
#           {  
#             $Outputreport += "<TR bgcolor=red>"  
#           }  
#           else 
#            { 
#             $Outputreport += "<TR>"  
#           } 
#           $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.CPULoad)</TD><TD align=center>$($Entry.MemLoad)</TD><TD align=center>$($Entry.Cdrive)</TD></TR>"  
#         } 
#      $Outputreport += "</Table></BODY></HTML>"  
#         }  
  
# $Outputreport | out-file C:\Scripts\Test.htm  
# Invoke-Expression C:\Scripts\Test.htm 
# ##Send email functionality from below line, use it if you want    
# $smtpServer = "USWeb01" 
# $smtpFrom = "edward.meier@netinsight.net" 
# $smtpTo = "edward.meier@netinsight.net"
# $messageSubject = "Servers Health report" 
# $message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
# $message.Subject = $messageSubject 
# $message.IsBodyHTML = $true 
# $message.Body = "<head><pre>$style</pre></head>" 
# $message.Body += Get-Content C:\scripts\test.htm 
# $smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
# $smtp.Send($message)
function Get-Metrics {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {

    }

    process {
        Write-Host $Settings.env.name '  ----  '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        # Get Build from DB
        $BuildQuery = ("[Schedwin].[sp_GetDataBuildNumber]")
        $Build = (Invoke-Sqlcmd -ServerInstance $Settings.db.serverInstance -Username $Settings.db.userName -Password $Settings.db.password -Database $Settings.db.name -Query $BuildQuery -Verbose)        
        foreach($row in $build)
        {
            $Build = $row.Item(0).ToString()
        }   

        $formatedBuild = ("{0}.{1}.{2}" -f $Build.Substring(0,1), $Build.Substring(2,2), $Build.Substring(4,3))
        Write-Host $Settings.env.name  "- Database Release/Build: " $formatedBuild
        
        $dbname = $Settings.db.name

        $SchemaQuery = @"
        DECLARE @schemaNumber int
        EXECUTE schedwin.sp_SchemaNumber @schemaNumber = @schemanumber OUTPUT
        SELECT @schemaNumber as schemaNumber
"@
        # Get schema        
        $Schema = (Invoke-Sqlcmd -ServerInstance $Settings.db.serverInstance -Username $Settings.db.userName -Password $Settings.db.password -Database $Settings.db.name -Query $SchemaQuery -Verbose)
        
        foreach($row in $Schema)
        {
            $SchemaNumber = $row.Item(0).ToString()
        }   
        Write-Host $Settings.env.name " - Database Schema Number: " $SchemaNumber
        
        # Get version of main executable
        $sched = "{0}\Schedwin\Schedwin.exe" -f $Settings.sched.installDirectory
        $schedVer = (Get-Item $sched).VersionInfo.FileVersion

        Write-Host $Settings.env.name " - File System Release/Build: " $schedVer
    }
}

  
#        function Get-Cpu{ 
#                  param( 
#                  $computername =$env:computername 
#                  ) 
#                  $os = gwmi win32_perfformatteddata_perfos_processor -ComputerName $computername| ? {$_.name -eq "_total"} | select -ExpandProperty PercentProcessorTime  -ea silentlycontinue 
#                  if(($os -match '\d+') -or ($os -eq '0')){ 
#                  $results =new-object psobject 
#                  $results |Add-Member noteproperty Cputil  $os 
#                  $results |Add-Member noteproperty ComputerName  $computername  
#                  $results | Select-Object computername,Cputil 
#                  } 
#                  else{ 
#                  $results =new-object psobject 
#                  $results |Add-Member noteproperty Cputil  "Na" 
#                  $results |Add-Member noteproperty ComputerName  $computername  
#                  $results | Select-Object computername,Cputil 
#                  } 
#                  }  
 
 
#  $infcpu =@() 
 
  #######################cpu function end################# 
 
#  #server location  
#   $servers = Get-Content -Path C:\servers.txt 
 
#  foreach($server in $servers){ 
 
#  $infcpu += get-Cpu  $server  
#  } 
 
#  $infcpu 
  
 
# Get-cpu -computername vdocker2 
function Get-Sample {

    process {

        $settings = @{
            "name"     = "vdocker2-WebAPI"
            "sched"    = @{
                "sourceInstallerFolder" = "\\\\vizstorage1\\PublicBuilds\\Internal"
                "targetInstallerFolder" = "C:\\ScheduAllInstallers"
                "installDirectory"      = "C:\\ScheduALL5"
                "endpointUrl"           = "http://vdocker2/webapp/api"
                "userName"              = "supervisor"
                "password"              = "password"
            }
         
            "env"      = @{
                "name"         = "vdocker2"
                "server"       = ""
                "release"      = "531"
                "build"        = "109"
                "instance"     = "0"
                "schemaNumber" = ""
            }
            "db"       = @{
                "provider"        = "SQL"
                "serverInstance"  = "vDocker2"
                "name"            = "WebAPI_Auto"
                "data"            = "Schedwin\\Data"
                "userName"        = "sa"
                "password"        = "sapassword101!"
                "backupDirectory" = "C:\\DatabaseBackups"
                "backupName"      = "WebAPI_Auto_Baseline.bak"
            }
            "services" = @{
                "schedWinService" = "ScheduALL Application Services"
            }
            "configs"  = @{
                "schedAppServicesConfig" = "SchedAppServices\\VizuALL.ServiceHost.exe.config"
                "schedWebServicesConfig" = "ScheduALLWebServiceAPI\\web.config"
            }
            "webapi"   = @{
                "endpointUrl" = "http://vDocker2/ScheduALLWebServiceAPI/SchedWebServiceAPI.asmx"
                "userName"    = "supervisor"
                "password"    = "password"
            }
        
        }

        $jsonStr = ConvertTo-Json $settings
        Write-Output $jsonStr
    }

}
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
function Reset-CircuitsDB {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {
        
    }

    process {
   
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        $db = $Settings.db.name

    $query = @"
    USE ${db}
    DELETE Schedwin.INTEROPLISTENERLOG
    DELETE Schedwin.INTEROPMESSAGELOG
    DELETE Schedwin.INTEROPPAYLOAD
    DELETE SCHEDWIN.SEVT_EX
    DELETE SCHEDWIN.SEVT_AUX
    DELETE SCHEDWIN.SEVT_CAP_CHANGE
    DELETE SCHEDWIN.SEVT
    DELETE SCHEDWIN.WO
    DELETE SCHEDWIN.WO_USER
    DELETE SCHEDWIN.TRAIL
    UPDATE SCHEDWIN.CONTROL SET SESSIONID = 1 WHERE RECID = 500
    UPDATE SCHEDWIN.CONTROL SET WONUM = 1 WHERE RECID = 501
    UPDATE SCHEDWIN.CONTROL SET SEQNUM = 1 WHERE RECID = 502
"@

        # Reset CIrcuits DB
        Invoke-Sqlcmd -ServerInstance $Settings.db.serverInstance -Username $Settings.db.userName -Password $Settings.db.password -Query $query
    }

    end {
        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        Write-Host $Settings.env.name ("  Database Reset for {0} : {1} : {2}" -f $Settings.env.name, $Settings.db.serverInstance, $Settings.db.name)
    }
}
Function Restore-Database {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )
    
    begin {
    }
    
    process {

        Write-Host $Settings.env.name '  ----  '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        $dbserverInstance = $Settings.db.serverInstance
        $dbname = $Settings.db.name
        $backupFile = "{0}\{1}" -f $Settings.db.backupDirectory, $Settings.db.backupName

        try{
        
            $username = $Settings.db.userName
            $password = $Settings.db.password
            
            $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
            $mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)
            
            Restore-SqlDatabase -ServerInstance "${dbserverInstance}" -Database "${dbname}" -BackupFile "${backupFile}" -ReplaceDatabase -Credential $mycreds -Verbose 
        }
        catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host $ErrorMessage
        Write-Host $FailedItem
        }
    }

}
function Restore-DBUsers {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {

    }

    process {

        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        $db = $Settings.db.name

        $query = 
        @"
    /*--
    ENHANCED SCRIPT FOR RESTORED DATABASES
    This script syncs the users logins when database is restored from a different server and corrects some permissions if needed.
    Schedwin, Scheduser, and Schedguest must already be created as users accounts.
    MAKE SURE YOUR DATABASE IS SET BEFORE RUNING THIS SCRIPT AND LOGGED IN AS SA ACCOUNT!!!!!
    Date:10/29/2013
    Author:DJ
    --*/
    use ${db}

    PRINT 'Script for Restored Databases'
    PRINT '-------------------------------------------------'
    IF DB_NAME() = 'master'--Check for Master
        PRINT 'Current Database is invalid! Must pick the database you want to check.'
    ELSE
        BEGIN
        --Perform Checks
        --Check SCHEDWIN permissions and correct if needed
        IF EXISTS (SELECT *
        FROM sys.server_principals
        WHERE name = N'schedwin')
            BEGIN
            EXEC sp_change_users_login @Action = 'Update_One', @UserNamePattern = 'Schedwin', @LoginName = 'Schedwin'
            PRINT 'SCHEDWIN synced.'
            --Check for Sys Admin 
            IF IS_SRVROLEMEMBER('sysadmin','schedwin') = 1
                    PRINT 'WARNING! SCHEDWIN is set to SYSTEM ADMIN!'
            --Check for DataReader Role
            IF IS_ROLEMEMBER('db_datareader','schedwin') = 1
                    PRINT 'SCHEDWIN DataReader Role is OK.'
                ELSE
                    BEGIN
                EXEC sp_addrolemember N'db_datareader', N'schedwin'
                PRINT 'DataReader Role added to SCHEDWIN.'
            END
            --Check for DataWriter Role
            IF IS_ROLEMEMBER('db_datawriter','schedwin') = 1
                    PRINT 'SCHEDWIN DataWriter Role is OK.'
                ELSE
                    BEGIN
                EXEC sp_addrolemember N'db_datawriter', N'schedwin'
                PRINT 'DataWriter Role added to SCHEDWIN.'
            END
            --Check for DB Owner Role
            IF IS_ROLEMEMBER('db_owner','schedwin') = 1
                    PRINT 'SCHEDWIN DB Owner is OK.'
                ELSE
                    BEGIN
                EXEC sp_addrolemember N'db_owner', N'schedwin'
                PRINT 'DB Owner role added to SCHEDWIN.'
            END

        END
        ELSE 
            PRINT 'SCHEDWIN user not found. Please Create SCHEDWIN user.'

        PRINT '-------------------------------------------------'

        --Check SCHEDUSER permissions and correct if needed
        IF EXISTS (SELECT *
        FROM sys.server_principals
        WHERE name = N'scheduser')
            BEGIN
            EXEC sp_change_users_login @Action = 'Update_One', @UserNamePattern = 'scheduser', @LoginName = 'scheduser'
            PRINT 'SCHEDUSER synced.'
            --Check for Sys Admin 
            IF IS_SRVROLEMEMBER('sysadmin','scheduser') = 1
                    PRINT 'WARNING! scheduser is set to SYSTEM ADMIN!'
            --Check for DataReader Role
            IF IS_ROLEMEMBER('db_datareader','scheduser') = 1
                    PRINT 'SCHEDUSER DataReader Role is OK.'
                ELSE
                    BEGIN
                EXEC sp_addrolemember N'db_datareader', N'scheduser'
                PRINT 'DataReader Role added to SCHEDUSER.'
            END
            --Check for DataWriter Role
            IF IS_ROLEMEMBER('db_datawriter','scheduser') = 1
                    PRINT 'SCHEDUSER DataWriter Role is OK.'
                ELSE
                    BEGIN
                EXEC sp_addrolemember N'db_datawriter', N'scheduser'
                PRINT 'DataWriter Role added to SCHEDUSER.'
            END
        END
        ELSE 
            PRINT 'SCHEDUSER user not found. Please create SCHEDUSER user.'

        PRINT '-------------------------------------------------'

        --Check SCHEDUSER permissions and correct if needed
        IF EXISTS (SELECT *
        FROM sys.server_principals
        WHERE name = N'schedguest')
            BEGIN
            EXEC sp_change_users_login @Action = 'Update_One', @UserNamePattern = 'schedguest', @LoginName = 'schedguest'
            PRINT 'SCHEDGUEST synced.'
            --Check for Sys Admin 
            IF IS_SRVROLEMEMBER('sysadmin','schedguest') = 1
                    PRINT 'WARNING! SCHEDGUEST is set to SYSTEM ADMIN!'
                ELSE
                --Check for DataReader Role
                IF IS_ROLEMEMBER('db_datareader','schedguest') = 1
                    PRINT 'SCHEDGUEST DataReader Role is OK.'
                ELSE
                    BEGIN
                EXEC sp_addrolemember N'db_datareader', N'schedguest'
                PRINT 'DataReader Role added to SCHEDGUEST.'
            END
        END
        ELSE 
            PRINT 'SCHEDGUEST user not found. Please create SCHEDGUEST user.'
    END
    PRINT '-------------------------------------------------'
    PRINT 'Done.'
    
"@ 

    
        # Kill all DB connections
        try {
            
            $response = (Invoke-Sqlcmd -ServerInstance $Settings.db.serverInstance -Username $Settings.db.userName -Password $Settings.db.password -Query $query -Verbose).value_data
    
            Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
            Write-Host $Settings.env.name "  Response: " $response
            Write-Host $Settings.env.name ("  Users Reattached for {0}:{1}" -f $Settings.db.serverInstance, $Settings.db.name)
        } 
        catch {
            Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
            Write-Host $Settings.env.name "  Response: " $response
            Write-Host $Settings.env.name ("  Problem with re-attaching users on {0}:{1}" -f $Settings.db.serverInstance, $Settings.db.name)
        }

    }
}
Function Start-ESSInstaller {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {

    }

    process{

        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        $InstallerLoc = "{0}\{1}\{1}.{2}_DevQA\SchedESS.exe" -f
            $Settings.sched.targetInstallerFolder,
            $Settings.env.release,
            $Settings.env.build
        

            $Switches = "/s /hide_usd /v`"/qn /Liwrmo!vepacu C:\temp\install.log`""
        
        # # Run Installer
        Write-Host ("   Upgrade to {0}.{1} instance {2}" -f 
            $Settings.env.release, 
            $Settings.env.build,
            $Settings.env.instance)

        Write-Host ("   With command: {0} {1}" -f $InstallerLoc, $Switches)
        
        $Installer = Start-Process -FilePath $InstallerLoc -ArgumentList $Switches -Wait -PassThru
    }

    end {
        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        Write-Host ("   The exit code is {0}" -f $Installer.ExitCode)

        if ($Installer.ExitCode -eq 0) {
            Write-Host "   Installation successful"
        }
        else {
            Write-Host "   Installation Failed"
        }
    }
  
}
function Start-IIS {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    process {
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
    
        iisreset $Settings.env.name /START

        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

    }
}
Function Start-ScheduAllInstaller {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {
    
    }

    process {
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        $InstallerLoc = "{0}\{1}\{1}.{2}_DevQA\Sched{1}{2}.exe" -f 
        $Settings.sched.targetInstallerFolder,
        $Settings.env.release,
        $Settings.env.build
    
        # # Build install command
        if ($Settings.env.instance -eq '0') {
            $Switches = "/s /hide_usd /v`"/qn /Liwrmo!vepacu C:\temp\install.log`""
        }
        else {
            $Switches = "/s /hide_usd /instance={0} /v`"/qn /Liwrmo!vepacu C:\temp\install.log`"" -f $Settings.env.instance
        }

        # # Run Installer
        Write-Host $Settings.env.name ("  Upgrade to {0}.{1} instance {2}" -f 
        $Settings.env.release,
        $Settings.env.build,
        $Settings.env.instance)

        Write-Host $Settings.env.name ("  With command: {0} {1}" -f $InstallerLoc, $Switches)
    
        $Installer = Start-Process -FilePath $InstallerLoc -ArgumentList $Switches -Wait -PassThru

    }

    end {
        
        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        Write-Host $Settings.env.name ("  The exit code is {0}" -f $Installer.ExitCode)
        if ($Installer.ExitCode -eq 0) {
            Write-Host $Settings.env.name "  Installation successful"
        }
        else {
            Write-Host $Settings.env.name "  Installation Failed"
        }
    }
}
function Start-SchedWinService {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

  
    begin {
    
    }

    process {
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        Start-Service $Settings.services.schedWinService

        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

    }
    

}
Function Start-SmokeTest {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][PSCustomObject] $Webapi
    )

    begin {
    
    }
 
    process {
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

    
        $hdrs = @{}
        $hdrs.Add("User-Agent", "Super Agent/0.0.1")
        $hdrs.Add("Content-Type", "application/x-www-form-urlencoded")

        $endpointUrl = $webapi.endpointUrl + "/Login";
    
        $login = @{
            Name     = $Webapi.userName
            Password = $Webapi.password
        }

        $response = Invoke-WebRequest -Uri $endpointUrl -Method Post -Body $login -ContentType 'application/x-www-form-urlencoded' -Headers $hdrs -UseBasicParsing
    }
    end {

        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        if ($response.Content -like "*<Response>Logged In</Response>*") {
            Write-Host $Settings.env.name "  Successfully Logged In"
        }
        else {
            Write-Host $Settings.env.name "  Failed Log In" 
            Write-Host $Settings.env.name  "  " $response.Content   
        }
    }
}
Function Start-WebAPIInstaller {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )

    begin {
    
    }

    process{
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        $InstallerLoc = "{0}\{1}\{1}.{2}_DevQA\SchedWebAPI.exe" -f
            $Settings.sched.targetInstallerFolder,
            $Settings.env.release,
            $Settings.env.build
        
        if ($Settings.env.instance -eq '0') {
            $Switches = "/s /hide_usd /v`"/qn /Liwrmo!vepacu C:\temp\install.log`""
        }
        else {
            $Switches = "/s /hide_usd /instance={0} /v`"/qn /Liwrmo!vepacu C:\temp\install.log`"" -f $Settings.env.instance
        }
        
        # # Run Installer
        Write-Host $Settings.env.name ("   Upgrade to {0}.{1} instance {2}" -f 
            $Settings.env.release, 
            $Settings.env.build,
            $Settings.env.instance)

        Write-Host $Settings.env.name ("   With command: {0} {1}" -f $InstallerLoc, $Switches)
        
        $Installer = Start-Process -FilePath $InstallerLoc -ArgumentList $Switches -Wait -PassThru
    }

    end {
        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        Write-Host $Settings.env.name ("  The exit code is {0}" -f $Installer.ExitCode)

        if ($Installer.ExitCode -eq 0) {
            Write-Host $Settings.env.name "  Installation successful"
        }
        else {
            Write-Host $Settings.env.name "  Installation Failed"
        }
    }
  
}
Function Start-WebAPIUninstaller {
    param(
        [parameter(Mandatory = $true, ParameterSetName = "pipe", ValueFromPipeline)] [string] $jsonStr,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $release,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $build,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $instance,
        [parameter(Mandatory = $true, ParameterSetName = "args")] [string] $targetInstallerFolder
    )


    if ($PSCmdlet.ParameterSetName -eq "pipe") {
        $obj = ConvertFrom-Json $jsonStr
        
    }
    else {
        $obj = @{
            env = @{
                release         = $release
                serverInstance  = $serverInstance
                build           = $build
                instance        = $instance
            }
            sched = @{
                targetInstallerFolder = $targetInstallerFolder          
            }
        }
    }

    
    $release                = $obj.env.release;
    $serverInstance         = $obj.env.serverInstance;
    $build                  = $obj.env.build;
    $instance               = $obj.env.instance;
    $targetInstallerFolder  = $obj.sched.targetInstallerFolder;

    Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
    
    # # Build install command
    $InstallerLoc = "${targetInstallerFolder}\${release}\${release}.${build}_DevQA\SchedWebAPI.exe" 
        
    if (${instance} -eq '0') {
        $Switches = " /x /s /instance=0 /v/qn"
    }
    else {
        $Switches = " /x /s /instance=${instance} /v/qn"    
    }


    # # Run Installer
    Write-Host "   Uninstalling SchedWebAPI $release.$build instance $instance" 
    Write-Host "   With command: " $InstallerLoc $Switches
    
    $Installer = Start-Process -FilePath $InstallerLoc -ArgumentList $Switches -Wait -PassThru

    Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
    Write-Host "T   he exit code is $($Installer.ExitCode)"
    if ($Installer.ExitCode -eq 0) {
        Write-Host "   Uninstall successful"
    }
    else {
        Write-Host "   Uninstall Failed"
    }

}
function Stop-IIS {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][PSCustomObject] $Settings
    )
    
    begin {
    
    }

    process {
    
        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        iisreset $Settings.env.name /STOP

        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

    }
    
}
function Stop-SchedWinService {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )
   
    begin {
    
    }

    process {

        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        try {
            Stop-Service $Settings.services.schedWinService
            Write-Host $Settings.env.name "  " $Settings.services.schedWinService "   Service Stopped"
            Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        }
        catch {
            Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
            Write-Host $Settings.env.name "  Unable to Stop Service {0}. It may not be running." -f $Settings.services.schedWinService
        }
    }    
}
Function Update-Database {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCustomObject] $Settings
    )
   
    begin {
        
    }
    
    process {

        Write-Host $Settings.env.name '  ----  Start '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='

        # DB update
        $cmd = ("{0}\SchedTools\SchedTools.ConsoleHost.exe" -f $Settings.sched.installDirectory)
        $package = $settings.sched.installDirectory + "\SchedTools\Package"
        $manifest = $settings.sched.installDirectory + "\SchedTools\Package\manifest.xml"
        $data = $settings.sched.installDirectory + "\" + $settings.db.data

        $parms = ("-provider:{0} -username:{1} -password:{2} -server:{3} -database:{4} -package:{5} -manifest:{6} -data:{7} -update -force" -f
        $Settings.db.provider,
        $Settings.db.userName,
        $Settings.db.password,
        $Settings.db.serverInstance,
        $Settings.db.name,
        $package,
        $manifest,
        $data)

        Write-Host $Settings.env.name "  Updating Database: $cmd $parms"

        & more 
        $process = Start-Process $cmd $parms -NoNewWindow -Wait -PassThru
    }

    end {
        Write-Host $Settings.env.name '  ----  End '$PSCmdlet.MyInvocation.MyCommand.Name ' ================='
        Write-Host $Settings.env.name ("  The exit code is {0}" -f $process.ExitCode)
        
        if ($process.ExitCode -eq 0) {
            Write-Host $Settings.env.name "  Update successful"
        }
        else {
            Write-Host $Settings.env.name "  Update Failed"
        }
    }
}
Export-ModuleMember '*'
