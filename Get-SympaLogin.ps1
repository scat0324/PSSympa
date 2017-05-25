function Get-SympaLogin
{

<#
.Synopsis
   This function gets a login cookie to use with the Sympa mail list server
.DESCRIPTION
   Use this function to login to the Sympa mail list server before calling other functions in this module (like Get-SympaMailListMembers).
.EXAMPLE
   $sympa = Get-SympaLogin -Username test-user@ox.ac.uk -Password cheesypassword1 -WSDL https://web.maillist.ox.ac.uk/ox/wsdl
#>

param(

    [Parameter(Mandatory=$true,HelpMessage="Enter the username which has administrative permissions to your Sympa instance")]
    [String]$Username,
    [Parameter(Mandatory=$true,HelpMessage="Enter the password of the user previously entered")]
    [String]$Password,
    [Parameter(Mandatory=$true,HelpMessage="Enter the URI to the WSDL of the Sympa Server")]
    [String]$WSDL

    )

    #Download the WDSL
    $Sympa = New-WebServiceProxy -Uri $WSDL

    #Make a cookie container
    $Sympa.CookieContainer = New-Object System.Net.CookieContainer

    #Login and get a session cookie
    $Sympa.login($Username, $Password) | Out-Null
    
    #Output the result
    return $Sympa

}