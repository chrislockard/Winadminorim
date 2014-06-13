<# 
Copyright (C) 2014 Christopher Lockard

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

FileName: Winadminorim.ps1
Created: 2012-Feb
Author: Christopher Lockard
============================================
Purpose: Winadminorim will hopefully make your Windows administrative life easier.  

v1.2
Added Function servs to enumerate services, service startup name, service display name, and service status
Added Function contains - will list file name, number of occurrences, and line number for the argument you pass
Function shares - enumerates shares and group privileges on those shares

v1.1
Refactored and updated hostinfo() so command results can be piped to other cmdlets and/or exported to text.

v1.0
General Release.  Includes the following functions:
hi <hostname/ip or blank> - (short for "hostinfo") return network, hardware, logical disk, 
                       and user session information for the specified host
top <hostname/ip or blank> - (poorly) mimic the "top" command from the UNIX ecosystem on a local or remote host.
sei <hostname/ip or blank> - gets service information from the local or remote host
pri <hostname/ip or blank> - gets process information from the local or remote host
uptime <hostname/ip or blank> - returns hostname and uptime in d,h,m,s.  Can be passed a list of servers
                              to return uptime for a collection.
dcs - list top-level domain controller information
SysLog  <hostname/ip> <# of log entries desired> - newest # of system log entries
SysLogg <hostname/ip> <# of log entries desired> - newest # of system log entries grouped by eventid
AppLog  <hostname/ip> <# of log entries desired> - newest # of application log entries
AppLogg <hostname/ip> <# of log entries desired> - newest # of application log entries grouped by eventid
SecLog  <hostname/ip> <# of log entries desired> - newest # of security log entries
SecLogg <hostname/ip> <# of log entries desired> - newest # of security log entries grouped by eventid

INSTALLATION:
1. Save this file somewhere convenient, preferably without spaces in the path (e.g. C:\Users\Scripts\Winadminorim.ps1)
2. Open a Powershell console
3. Type "$profile" (without quotes) and note the location provided.  On this host,
the $profile variable returned this directory:
C:\Users\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
4. Type "notepad $profile" (without quotes)
5. If on a Vista, 7, 2008 or later host, click "OK" at the warning message.  Notepad should come up with a blank 
file.  This is OK.  Type the following into this blank file:

#Load Winadminorim
. C:\Users\Scripts\Winadminorim.ps1 #If this is where you placed the Winadminorim.ps1 file. 

NOTE THE PERIOD (.) at the start of the directory listing.  THIS IS IMPORTANT!
6. Save this file as whatever filename the $profile variable from step 3 returned.
Now, when you start a Powershell session, Winadminorim will be loaded by default.  
ANY CHANGES TO WINADMINORIM REQUIRE A NEW POWERSHELL SESSION TO BE STARTED!
#>

#Aliases.  Unless you know what you're doing, do not modify these!
sal d Get-Date
sal gel Get-EventLog
sal hi hostinfo
sal psv PSVer
sal pri procinfo
sal sei gs

<#-----------------------------------------------------------------------------
Function: 
hi($strComputer)

Usage: 
hi <hostname/ip or leave blank for localhost>

Purpose: 
return system information from several disparate functions in one location
for easier troubleshooting.

Notes: 
To get host info for a list of servers, save a .txt (for this example, the 
text file will be called Servers.txt and is placed in current directory) 
with each servername on a separate line.  Then, from the PS command line, 
type each line below (commands are in angular brackets, eg <command>):

$listServers = Get-Content .\Servers.txt <enter>
foreach($i in $listServers) { hi $i } <enter>

To-Do:
Add real-time updating
-------------------------------------------------------------------------------#>
Function hostinfo($strComputer)
{
    if(!$strComputer) {
        hostinfo localhost        
    } else {
        #v1.1 - Moved the formatting to variables so they can be piped through to other commands
        $txtCompName    = $strComputer.ToUpper()
        $txtHostBar     = "`n============================================================================"
        $txtHostUL      = "____________________________________________________________________________`n"
        
        #======================       
        #HOSTNAME
        #______________________
        $Host.UI.RawUI.BackgroundColor = 6
        $Host.UI.RawUI.ForegroundColor = 5
        "$txtHostBar"
        "$txtCompName"
        "$txtHostUL"
        
        #Nework Information
        #------------------
        $datHostName    = (Get-WmiObject Win32_ComputerSystem -ComputerName $strComputer).Name
        $datHostOS      = (Get-WmiObject Win32_OperatingSystem -ComputerName $strComputer).Caption
        $datNetHostDom  = (Get-WmiObject Win32_ComputerSystem -ComputerName $strComputer).Domain
        $datIP = Get-WmiObject Win32_NetworkAdapterConfiguration -Namespace "root\cimv2" `
                 -ComputerName $strComputer -filter "IpEnabled = TRUE"
        $strNetInfo     = "Network Information"
        $strNetUL       = "-------------------"
        $strHostName    = "Host Name           :"
        $strHostOS      = "Host OS             :"
        $strNetHeader   = "Network Adapter #"
        $strNetHeaderUL = "--------------------"
        $strNetHostDom  = "Host Domain         :"
        $strNetHostIP   = "IP Address          :"
        $strNetGate     = "Default Gateway     :"
        $strNetDHCP     = "DHCP Enabled        :"
        $strNetMAC      = "MAC Address         :"
        
        "$strNetInfo"
        "$strNetUL"
        $Host.UI.RawUI.BackgroundColor = 5
        $Host.UI.RawUI.ForegroundColor = 6             
        
        "$strHostName $datHostName"
        "$strHostOS $datHostOS`n"
        
        ForEach($itemIP in $datIP) {
            #Get Interface Configuration
            $intIndex       = $itemIP.Index
            $datNetHostIP   = $itemIP.IpAddress
            $datNetGate     = $itemIP.DefaultIPGateway
            $datNetDHCP     = $itemIP.DHCPEnabled
            $datNetMAC      = $itemIP.MacAddress
            
            #Output Interface Configuration
            "$strNetHeader$intIndex"
            "$strNetHeaderUL"
            "$strNetHostDom $datNetHostDom"
            "$strNetHostIP $datNetHostIP"
            "$strNetGate $datNetGate"
            "$strNetDHCP $datNetDHCP"
            "$strNetMAC $datNetMAC`n`n"
        }
        
        
        #Hardware Information
        #----------------------
        $datHWManu      = (Get-WmiObject Win32_ComputerSystem -ComputerName $strComputer).Manufacturer
        $datHWModel     = (Get-WmiObject Win32_ComputerSystem -ComputerName $strComputer).Model
        $datHWMem       = Get-WmiObject -ComputerName $strComputer -query "SELECT TotalPhysicalMemory from Win32_ComputerSystem" `
                          | % {$_.TotalPhysicalMemory / 1GB}
        $datHWLastBoot  = (Get-WmiObject -ComputerName $strComputer -Query "SELECT LastBootUpTime FROM Win32_OperatingSystem").LastBootUpTime
        $dateYears      = $datHWLastBoot.substring(0,4)
        $dateMonths     = $datHWLastBoot.substring(4,2)
        $dateDays       = $datHWLastBoot.substring(6,2)
        $dateHours      = $datHWLastBoot.substring(8,2)
        $dateMins       = $datHWLastBoot.substring(10,2)
        $dateSeconds    = $datHWLastBoot.substring(12,2)
        $dateDiff       = New-TimeSpan $(Get-Date -Year $dateYears -Month $dateMonths -Day $dateDays -Hour $dateHours -Minute $dateMins -Second $dateSeconds)$(Get-Date)
        $d              = $dateDiff.days
        $h              = $dateDiff.hours
        $m              = $dateDiff.minutes
        $s              = $dateDiff.seconds
        $datHWUptime    = "$d Days $h Hours $m Min $s Sec"
        Get-WmiObject Win32_Processor -ComputerName $strComputer | % {$datHWDataWidth = $_.DataWidth}
        
        $strHWInfo      = "Hardware Information"
        $strHWUL        = "--------------------"
        $strHWManu      = "Manufacturer        :"
        $strHWModel     = "Model               :" 
        $strHWMem       = "Phyiscal Memory (GB):"
        $strInfo        = "" | select ServerName, Uptime
        $strInfo.servername = $strComputer
        $strHWUptime    = "Host Uptime         :"
        $strHWDataWidth = "Data With           :"
        
        $Host.UI.RawUI.BackgroundColor = 6
        $Host.UI.RawUI.ForegroundColor = 5
        "$strHWInfo"
        "$strHWUL"
        $Host.UI.RawUI.BackgroundColor = 5
        $Host.UI.RawUI.ForegroundColor = 6 
        
        "$strHWManu $datHWManu"
        "$strHWModel $datHWModel"
        "$strHWMem $datHWMem"
        "$strHWUptime $datHWUptime"
        "$strHWDataWidth $datHWDataWidth`n`n"
        
        #Logical Disk Information
        #This portion from poshtips.com/2009/12/01/tweaking-wmi-data-with-format-table-options-in-powershell/
        #Note, this only contains information on local disks. Remove the 
        # Where DriveType = 3 to list information for all disks (CD/DVD, floppy, etc)
        #---------------------------------
        $strDiskInfo    = "Logical Disk Information"
        $strDiskUL      = "------------------------"
        $Host.UI.RawUI.BackgroundColor = 6
        $Host.UI.RawUI.ForegroundColor = 5
        "$strDiskInfo"
        "$strDiskUL" 
        $Host.UI.RawUI.BackgroundColor = 5
        $Host.UI.RawUI.ForegroundColor = 6 
        
        $strDisk = Get-WmiObject -ComputerName $strComputer -query "SELECT * from Win32_LogicalDisk WHERE DriveType=3" 
        $strDisk | Format-Table -Auto DeviceID, VolumeName, `
            @{Label="FreeSpace(GB)"; `
            Alignment="right"; `
            Expression={"{0:N2}" -f ($_.FreeSpace/1GB)}}, `
            @{Label="Size(GB)"; `
            Alignment="right"; `
            Expression={"{0:N2}" -f ($_.size/1GB)}} `
        
        #User Session Information
        #-------------------------
        $strUSInfo      = "User Session Information"
        $strUSUL        = "------------------------"
        
        $Host.UI.RawUI.BackgroundColor = 6
        $Host.UI.RawUI.ForegroundColor = 5
        "$strUSInfo"
        "$strUSUL"
        $Host.UI.RawUI.BackgroundColor = 5
        $Host.UI.RawUI.ForegroundColor = 6
        
        $sessions = query session /server:$strComputer
        $sessions | Format-Table -Auto UserName
    }
}

<#-----------------------------------------------------------------------------
Function: 
servs($strComputer)

Usage: 
servs <hostname/ip or blank for localhost>

Purpose: 
Enumerate services running on the host and the account that starts them

Notes: 
To filter services by a certain type, append the pipe and findstr utility
servs | findstr "Running"
or, for a differently formatted output that can be piped to other powershell
commands, try this:
servs | Select-String Running

To-Do:
-------------------------------------------------------------------------------#>
Function servs($strComputer){
    if(!$strComputer) {
        Get-WmiObject -Class Win32_Service -ComputerName . | select DisplayName, StartName, Name, State
    }
    else {
        Get-WmiObject -Class Win32_Service -ComputerName $strComputer | select DisplayName, Name, StartName, State
    }
}

<#-----------------------------------------------------------------------------
Function: 
contains()

Usage: 
contains <type of file> <text to search for> <host to find on>
<type of file> - this is the type of file to search for (e.g. *.txt, *.*)
<text to search for> - this is the pattern you want to search for (e.g. 127.0.0.1)
<host to find on> - Remote host to search for the string on. Leave this blank to
                    search on the localhost.

Purpose: 
locate files that contain certain text, and where within those files the text is.
THIS FUNCTION SEARCHES RECURSIVELY FROM THE BASE DIRECTORY.

Notes: 
To filter services by a certain type, append the pipe and findstr utility
servs | findstr "Running"
or, for a differently formatted output that can be piped to other powershell
commands, try this:
servs | Select-String Running

This function can be piped out to a text file, for instance:
contains *.txt hi >> output.txt
This will search recursively from the current directory for all files that contain
"hi" (without quotes) and output the results to a file called output.txt in the 
same directory.

!Currently this only works on the C$ of remote hosts!

To-Do:
-------------------------------------------------------------------------------#>
Function contains(){
    if($args[2] -ne $null) {
        $strHost    = $args[2]
        $strSearch  = $args[1]
        $strFiles   = $args[0]
        $strRunning = "Still Running."
        $Job = Start-Job -ScriptBlock { Get-ChildItem "\\$strHost\C$\" -r -i $strFiles | Select-String $strSearch `
        | Group-Object Filename | Select-Object Name, Group, `
        @{Expression={ $_.Group | foreach { $_.LineNumber }}; Label="Line Numbers"}, Count }
        
        while($Job.JobState -ne "Completed") {
        #Add progress bar code here
        }
        
        Switch($Job.JobState)
        {
            "Completed" { Receive-Job -job $Job }
            "Running"   { $strRunnin }
        }
    }
    else {
        Get-ChildItem -r -i $args[0] | Select-String $args[1] | Group-Object Filename `
        | Select-Object Name, Group, @{Expression={ $_.Group | foreach {$_.LineNumber}`
        }; Label="Line Numbers"}, Count
    }
}
<#-----------------------------------------------------------------------------
Function: 
shares()

Usage: 
shares <hostname/ip or blank for localhost>
Results of this function can be piped or saved in variables to obtain share 
information for a large group of servers.  For Example:

$strServers = Get-Content .\servers.txt
$strOutput  = foreach($i in $strServers) { shares $i }
$strOutput > ServerShares.txt

These commands will determine the share information for each server in 
servers.txt (with each server NetBIOS name on a separate line) and 
store that information in $strOutput which can then be piped to an
output file called ServerShares.txt

Purpose: 
Enumerate shares and permissions on those shares for $args[0]

Notes: 
Credit for the Translate-AccessMask and Translate-AceType functions goes to
user "Shay" in the PowerShell-Users Google Group (scriptolog@gmail.com)

To-Do:
-------------------------------------------------------------------------------#>
Function shares() {
<#
    .SYNOPSIS
    The "Shares" function returns the Windows shares on either the localhost, or 
    hosts specified as arguments.
    You can run shares against multiple remote hosts by saving the names of the 
    remote hosts, one host per line, in a text file, then assigning the contents
    of that file to a variable, then running a foreach() loop on that variable.
    
    .DESCRIPTION
    Shares will enumerate the shares and permissions on these shares for a specified
    host by using the Get-WmiObject -Class Win32_Share function
    
    .PARAMETER <Remote Host>
    Specify the <Remote Host> by NetBIOS name or IP address.
    
    .EXAMPLE
    shares 
    
    .EXAMPLE
    shares remotehost01
    
    .EXAMPLE
    $strServers = Get-Content .\servers.txt
    $strOutput  = foreach($i in $strServers) { shares $i }
    $strOutput > ServerShares.txt
    
    .LINK
    http://www.dagorim.com
#>
    if($args[0] -eq $null) {
        $strComputer = "localhost"
    } else { $strComputer = $args[0] }
    
    $strCompUL    = "=" * $strComputer.length
    $strComputer
    $strCompUL
    
    $strShareDesc = Get-WmiObject Win32_Share -ComputerName $strComputer -ErrorAction `
    silentlycontinue
    
    $shares = Get-WmiObject -Class Win32_Share -ComputerName $strComputer -ErrorAction `
    silentlycontinue | select -ExpandProperty Name
    
    ForEach($share in $shares) {
        $strShare   = $share
        $strShareUL = "-" * $strShare.length
        $strShare
        $strShareUL
        (Get-Acl -ErrorAction silentlycontinue \\$strComputer\$share).Access
    }
    $strComputer += " Shares:"
    $strCompUL = "=" * $strComputer.length
    $strComputer
    $strCompUL
    $strShareDesc
}
<#-----------------------------------------------------------------------------
Function: 
top($strComputer)

Usage: 
top <hostname/ip or blank for localhost>

Purpose: 
Poorly mimic the "top" command from the UNIX ecosystem.

Notes: 

To-Do:
Add total/used/free memory in GB and percentage
Add real-time updating
-------------------------------------------------------------------------------#>
Function top($strComputer)
{
    if(!$strComputer) {
        Get-Process
    }
    else {
        Get-Process -ComputerName $strComputer
    }
}

#Get Service information on local or remote computer
Function gs($strComputer)
{
    if(!$strComputer) {
        Get-Service
    }
    else {
        Get-Service -ComputerName $strComputer
    }
}

#Get Process information on local or remote computer
Function procinfo($strComputer)
{
    if (!$strComputer) {
        procinfo .
    }
    else {
        
        $colItems = Get-WmiObject -Class "Win32_Process" -Namespace "root\cimv2" -ComputerName $strComputer
        
        #Write-Host $objItem.Name, $objItem.WorkingSetSize
        $owners = @{}
        gwmi Win32_Process -ComputerName $strComputer | % {$owners[$_.handle] = $_.getowner().user}
        Get-Process | select processname, Id, @{l="Owner";e={$owners[$_.id.tostring()]}}
    }            
}

<#-----------------------------------------------------------------------------
Function: 
uptime($strComputer)

Usage: 
uptime <hostname/ip>

Purpose: 
Get uptime of remote computer

Notes: 
To get the uptime for a list of servers, save a .txt (for this example, the 
text file will be called Servers.txt and in current directory) with each servername on
a separate line.  Then, from the PS command line, type each line below without
the hashbang (#) (commands are in angular brackets, eg <command>):

$listServers = Get-Content .\Servers.txt <enter>
foreach($i in $listServers) { uptime $i } <enter>

To-Do:
Add CLI argument option to export results to CSV.  
-------------------------------------------------------------------------------#>
Function uptime($strComputer)
{
    $strServerName = $strComputer
    if($strServerName -eq $Null) {
        $strServerName = $env:COMPUTERNAME
    }
    
    $timeVal       = (Get-WmiObject -ComputerName $strServerName -Query "SELECT LastBootUpTime FROM Win32_OperatingSystem").LastBootUpTime
    $dateYears     = $timeVal.substring(0,4)
    $dateMonths    = $timeVal.substring(4,2)
    $dateDays      = $timeVal.substring(6,2)
    $dateHours     = $timeVal.substring(8,2)
    $dateMins      = $timeVal.substring(10,2)
    $dateSeconds   = $timeVal.substring(12,2)
    $dateDiff      = New-TimeSpan $(Get-Date -Year $dateYears -Month $dateMonths -Day $dateDays -Hour $dateHours -Minute $dateMins -Second $dateSeconds)$(Get-Date)  
    
    $strInfo       = "" | select ServerName, Uptime
    $strInfo.servername = $strServerName
    $d             = $dateDiff.days
    $h             = $dateDiff.hours
    $m             = $dateDiff.minutes
    $s             = $dateDiff.seconds
    $info          = "$d Days $h Hours $m Min $s Sec"
    
    #comma-delimited
    "$strComputer, $Info"
}

<#-----------------------------------------------------------------------------
Function: 
User($strComputer)

Usage: 
User <username>

Purpose: 
List the AD components that see this user.

Notes: 

To-Do:
Lots.  Separate and make this information meaningful
-------------------------------------------------------------------------------#>
Function User($strName) 
{
    if(!$strName) {
        $Host.UI.RawUI.BackgroundColor = 0
        $Host.UI.RawUI.ForegroundColor = 14
        Write-Host "Usage: PS$: user <username>"
        $Host.UI.RawUI.BackgroundColor = 5
        $Host.UI.RawUI.ForegroundColor = 6
    }
    
    $strFilter = "(&(objectCategory=User)(samAccountName=$strName))"
    
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.Filter = $strFilter 
    
    $Host.UI.RawUI.BackgroundColor = 0
    $Host.UI.RawUI.ForegroundColor = 3
    $objPath = $objSearcher.FindOne()
    $objUser = $objPath.GetDirectoryEntry()
    $objUser.memberOf
    
    
    $Host.UI.RawUI.BackgroundColor = 5
    $Host.UI.RawUI.ForegroundColor = 6
}

<#-----------------------------------------------------------------------------
Function Collection: 
SysLog($strComputer, $sysLogNum)
SysLogg($strComputer, $sysLoggNum)


Usage: 
SysLog  <hostname/ip> <# of log entries desired>
SysLogg <hostname/ip> <# of log entries desired>
AppLog  <hostname/ip> <# of log entries desired>
AppLogg <hostname/ip> <# of log entries desired>
SecLog  <hostname/ip> <# of log entries desired>
SecLogg <hostname/ip> <# of log entries desired>

Purpose: 
Save time and keystrokes when looking up sys, app, or security log info
*Logg functions return log entries grouped by SUM of eventids by name

Notes: 
Use a PERIOD (.) for localhost in place of <hostname/ip>

To-Do:
Add real-time updating
-------------------------------------------------------------------------------#>
Function SysLog($strComputer, $sysLogNum)
{
    Get-EventLog -ComputerName $strComputer system -newest $sysLogNum 
}

Function SysLogg($strComputer, $sysLoggNum)
{
    Get-EventLog -ComputerName $strComputer system -newest $sysLoggNum | Group-Object eventid | Sort-Object Name
}

Function AppLog($strComputer, $appLogNum)
{
    Get-EventLog -ComputerName $strComputer application -newest $appLogNum
}

Function AppLogg($strComputer, $appLoggNum)
{
    Get-EventLog -ComputerName $strComputer application -newest $appLoggNum | Group-Object eventid | Sort-Object Name
}

Function SecLog($strComputer, $secLogNum)
{
    Get-EventLog -ComputerName $strComputer security -newest $secLogNum
}

Function SecLogg($strComputer, $secLoggNum)
{
    Get-EventLog -ComputerName $strComputer security -newest $secLoggNum | Group-Object eventid | Sort-Object Name
}

#shhhhhhhhhhh
#Nick Girard
Function pi
{
    $Host.UI.RawUI.BackgroundColor = 4
    $Host.UI.RawUI.ForegroundColor = 14
    Write-Host 3.14159265358979323846
    $Host.UI.RawUI.BackgroundColor = 5
    $Host.UI.RawUI.ForegroundColor = 6
}

#Echo the top-level domain controllers seen by this host
Function dcs
{
    $Host.UI.RawUI.BackgroundColor = 6
    $Host.UI.RawUI.ForegroundColor = 5
    Get-WmiObject Win32_ntdomain
    $Host.UI.RawUI.BackgroundColor = 5
    $Host.UI.RawUI.ForegroundColor = 6
}

#Echo the Powershell Version
Function PSVer
{
    $Host.UI.RawUI.BackgroundColor = 6
    $Host.UI.RawUI.ForegroundColor = 5
    echo $PSVersionTable
    $Host.UI.RawUI.BackgroundColor = 5
    $Host.UI.RawUI.ForegroundColor = 6
}
<#
Winadminorim Function
#>
Function Winadminorim {
<#
    .DESCRIPTION
    Winadminorim contains a collection of funcitions that were written
    to provide functionality not offered conveniently enough, in my opinion based on 
    the difficulties my coworkers experienced, through the Windows OS.
    
    In some cases, these functions replicate functionality provided by built-in
    Windows components.  However, I have tried to streamline and make this 
    functionality more intuitive to administrators and more accessible to 
    inexperienced users who may infrequently need to perform a task requiring
    this functionality.
    
    I may or may not have succeeded in this goal.  If you have any recommendations
    to make, or errors pertaining to functionality, please send an e-mail to me
    at christopher.d.lockard+winadminorim@gmail.com.
        
    !-----------------------  USE AT YOUR OWN RISK ---------------------------!
    
    OK, with that out of the way, here are the functions available in v1.2:
    
    
    .LINK
    http://www.dagorim.com
    
    .SYNOPSIS
    Winadminorim is a collection of administrative functions.  
    
    .INPUTS
    None.
    
    .OUTPUTS
    None.
    
#>
    return $null
}
