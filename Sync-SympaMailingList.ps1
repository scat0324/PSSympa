function Sync-SympaMailingList
{

<#
.Synopsis
   This function adds a member(s) to a Mailing list
.EXAMPLE
   Sync Mailing list(s) against the file at C:\Sympa\synclist.csv

   Sync-SympaMailingList -Sympa $Sympa -Path C:\Sympa\synclist.csv
#>

param(

    [Parameter(Mandatory=$true,HelpMessage="Pass in the result of the 'Get-SympaLogin' function")]
    $Sympa,

    [Parameter(Mandatory=$true,HelpMessage="Enter the path to the reference file for the Mailing lists")]
    [String]$Path
<#
    [Parameter(Mandatory=$false,HelpMessage="Should you notify the user that they are being added to the list, default is no")]
    [ValidateSet("Yes", "No")]
    [String]$Notify = "No"
#>
    )
    
<#
    #Handle the $Notify paramater converting it into the mess that Sympa understands
    switch ($Notify)
    {
        'Yes' {$Alert = "false"}
        'No' {$Alert = "true"}
        Default {$Alert = "true"}
    }
#>

    Process{
        #Import the list
        #Check (and asorb) that the file is really there, stop the script if it isn't
        try
        {
            $Reference = Import-Csv $Path -ErrorAction Stop
        }
        catch
        {
            throw "Reference file not found"
        }

        #Convert the CSV into the same format that the results from Sympa will be coming out in
        #Create empty collection
        $ReferenceArray = New-Object System.Collections.ArrayList

        #Build the data for the collection
        foreach($Row in $Reference){
            #Build an object to store the results in
            $Item = New-Object -TypeName System.Object

            #Add the members to the object
            $Item | Add-Member -MemberType NoteProperty -Name "MailingList" -Value $Row.MailingList
            $Item | Add-Member -MemberType NoteProperty -Name "Member" -Value $Row.Member

            #Add the object to the collection
            $ReferenceArray.Add($Item) | Out-Null
        }

        #Get only the unique Mailing lists
        $UniqueLists = $Reference | Select-Object -Unique -Property MailingList

        #Read the current members of those lists
        $ResultsArray = foreach($UniqueList in $UniqueLists){
            Get-SympaMailingListMember -Sympa $Sympa -MailingList $UniqueList.MailingList
        }

        #Compare against the referance list and build the To Do List
        $ToDoList = Compare-Object -ReferenceObject $ReferenceArray -DifferenceObject $ResultsArray -Property MailingList, Member

        if($ToDoList.Count -eq "0"){
            Write-Verbose "Nothing to do"
        }

        #Perform Add/Remove
        foreach($ToDo in $ToDoList){
            if($ToDo.SideIndicator -eq "=>"){
                Remove-SympaMailingListMember -Sympa $Sympa -MailingList $ToDo.MailingList -Member $ToDo.Member
            }
            elseif($ToDo.SideIndicator -eq "<="){
                Add-SympaMailingListMember -Sympa $Sympa -MailingList $ToDo.MailingList -Member $ToDo.Member
            }
        }
    }
}
