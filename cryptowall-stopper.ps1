param (

    [string]$User,
    [string]$SourceFile,
    [string]$FileScreenPath,
    [string]$Server,
    [string]$ViolatedFileGroup

)

$share = "SMBShareName"

# get the active SMB sessions for reporting
$smbSessions = Get-SmbSession -ClientUserName $User

# immediately block the user with a DENY entry to SMB share
Block-SmbShareAccess -AccountName $User -Name $share -force

# destroy user's open SMB sessions
Close-SmbSession -ClientUserName $User -Force

# list the smb sessions that the script found earlier
foreach ($smb in $smbSessions) {

    "$($smb.ClientComputerName) - $($smb.ClientUserName) - $($smb.SessionId)" | out-file $pwd\smb-sessions

}

$smtpFrom = "server@corp.com"
$smtpTo = "bar@corp.com"
$smtpServer = "foomailer.corp.com"
$smtpPriority = "High"

# send notification to recipients about the event
Send-MailMessage -From $smtpFrom -SmtpServer $smtpServer -Priority $smtpPriority -Subject "Cryptowall Infected User Alert - $user - $FileScreenPath on $Server" -to $smtpTo -Body "****** THIS IS AN AUTOMATED MESSAGE, DO NOT REPLY ******`n`nA Cryptowall or Cryptolocker virus derivative has been detected on $Server. This virus was actively encrypting $FileScreenPath and was detected by rule $ViolatedFileGroup.`n`n$User has been denied access to $FileScreenPath over SMB. NTFS permissions for this user have not been modified, but network access has been denied. Additionally, all open SMB sessions using $User's credentials have been terminated.  The active sessions for this user were:`n`nClient Computer - User - SMB Session ID`n$(get-content $pwd\smb-sessions)`n`nAfter $User's computer has been secured, please remove the Deny ACL from the share for $FileScreenPath."

rm $pwd\smb-sessions
