function Get-SympaMailListMembers
{

<#
.Synopsis
   This function returns the members of a Mailing list(s)
.EXAMPLE
   Get-SympaMailListMembers -Sympa $Sympa -MailList queens-it
.EXAMPLE
   Get-SympaMailListMembers -Sympa $Sympa -MailList @('queens-it','queens-undergrads')
#>

param(

    [Parameter(Mandatory=$true,HelpMessage="Pass in the result of the 'Get-SympaLogin' function")]
    $Sympa,

    [Parameter(Mandatory=$true,HelpMessage="Enter the name of the Mailing list(s) you want to return the members of")]
    [Array]$MailingLists

    )
    
    #Create empty collection
    $Output = New-Object System.Collections.ArrayList

    #Loop over the mail lists provided
    foreach($MailList in $MailLists){
        
        $Results = $Sympa.review("$MailList")

        #Parse the list into objects (Sympa only returns a big long string with line breaks)
        foreach($Result in $Results){

            #Build an object to store the results in
            $item = New-Object -TypeName System.Object

            #Add the members to the object
            $item | Add-Member -MemberType NoteProperty -Name "Mailing list" -Value $MailList
            $item | Add-Member -MemberType NoteProperty -Name "Member" -Value $Result

            #Add the object to the collection
            $Output.Add($item) | Out-Null
        }
    }

    Return $Output
}