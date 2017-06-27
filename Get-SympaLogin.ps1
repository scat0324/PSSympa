function Get-SympaLogin
{

<#
.Synopsis
   This function gets a login cookie to use with the Sympa mailing list server
.DESCRIPTION
   Use this function to login to the Sympa mailling list server before calling other functions in this module (like Get-SympaMailListMembers).

   If using a credentials file (instead of storing them in the script) a sample of how the file should look is included with the module under the filename samplecredsfile.csv.
.EXAMPLE
   To login using the WSDL https://web.maillist.ox.ac.uk/ox/wsdl with the username test-user@ox.ac.uk and password cheesypassword1 use the following.

   $sympa = Get-SympaLogin -Username test-user@ox.ac.uk -Password $("cheesypassword1" | ConvertTo-SecureString -AsPlainText -Force) -WSDL https://web.maillist.ox.ac.uk/ox/wsdl
.EXAMPLE
    To login using a CSV which stores the Username/Password/URI to WSDL use the following.

    $sympa = Get-SympaLogin -CredsPath "C:\Sympa\credsfile.csv"
#>

param(

    #This set of params are used when the details of the Username/Password/WSDL are in the script
    [Parameter(Mandatory=$true,HelpMessage="Enter the username which has administrative permissions to your Sympa instance",ParameterSetName='CredsInScript')]
    [String]$Username,
    [Parameter(Mandatory=$true,HelpMessage="Enter the password of the user previously entered",ParameterSetName='CredsInScript')]
    [System.Security.SecureString]$Password,
    [Parameter(Mandatory=$true,HelpMessage="Enter the URI to the WSDL of the Sympa Server",ParameterSetName='CredsInScript')]
    [String]$WSDL,

    #This set of params are used when the details of the Username/Password/WSDL are stored in a text file
    [Parameter(Mandatory=$true,HelpMessage="Enter the path to the CSV containing credentials and the WSDL to use",ParameterSetName='CredsAtPath')]
    [String]$CredsPath

    )

    #If there is something at $CredsPath then test that the file is really there and if yes then asorb its contents into the script
    if ($CredsPath -ne "")
    {
        #Check that the file is really there, stop the script if it isn't
        try
        {
            $CredsFile = Import-Csv $CredsPath -ErrorAction Stop
        }
        catch
        {
            throw "Credentials file not found"
        }

        #Asorb the contents of the file into the script
        [String]$WSDL = $CredsFile.WSDL
        [String]$Username = $CredsFile.Username
        [System.Security.SecureString]$Password = $($CredsFile.Password | ConvertTo-SecureString -AsPlainText -Force)
    }

    #Download the WDSL
    $Sympa = New-WebServiceProxy -Uri $WSDL

    #Make a cookie container
    $Sympa.CookieContainer = New-Object System.Net.CookieContainer

    #Handle Secure String Password
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)

    #Login and get a session cookie
    $Sympa.login($Username, $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))) | Out-Null
    
    #Output the result
    return $Sympa

}