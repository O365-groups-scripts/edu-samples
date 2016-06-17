############################################################################################
# Copyright (c) Microsoft Corporation.  All rights reserved. 
# This script first disabled Group creation for all users in Organization. 
# Then it searches for user in organization in a particular domain.
# Then enables the Group creation for only those set of users.
# Exchange Commandlets used are :-
#
# Get-User 					: https://technet.microsoft.com/en-us/library/aa996896(v=exchg.160).aspx
# Set-OwaMailboxPolicy 		: https://technet.microsoft.com/en-us/library/dd297989(v=exchg.160).aspx
# New-OwaMailboxPolicy		: https://technet.microsoft.com/en-us/library/dd351067(v=exchg.160).aspx
# Set-CASMailbox			: https://technet.microsoft.com/en-us/library/bb125264(v=exchg.160).aspx
# New-EmailAddressPolicy	: https://support.office.com/en-us/article/Multi-domain-support-for-Office-365-Groups-7cf5655d-e523-4bc3-a93b-3ccebf44a01a?ui=en-US&rs=en-US&ad=US
#
# Also look here for Tech-net documentation on this - https://support.office.com/en-us/article/Use-PowerShell-to-manage-Office-365-Groups-aeb669aa-1770-4537-9de2-a82ac11b0540
############################################################################################

# Disable group creation for whole tenant
Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -GroupCreationEnabled $false

# Get Set of users, for whome we want to enable groups creation.
$users = Get-User -Filter "WindowsEmailAddress -like '*@faculty.contoso.com*'"

# Create a new mailbox policy
New-OwaMailboxPolicy -Name "GroupsCreationEnabledUsers"

# Set the GroupCreationEnabled value to true for this policy. Going forward 
Set-OwaMailboxPolicy -Identity "GroupsCreationEnabledUsers" -GroupCreationEnabled $true
foreach($user in $users)
{
	echo "Enabling for user " + ($user.WindowsEmailAddress)
	Set-CASMailbox -Identity $user.WindowsEmailAddress -OWAMailboxPolicy "GroupsCreationEnabledUsers"
}

#Adding Exchange EAPs so that for users in faculty domain, Groups gets created with address <Groupalias>@faculty.groups.contoso.com.   Change the values accordingly.
New-EmailAddressPolicy -Name FacultyGroups -IncludeUnifiedGroupRecipients -EnabledEmailAddressTemplates "SMTP:@faculty.groups.contoso.com","smtp:@groups.contoso.com" -ManagedByFilter {EmailAddresses -like '*faculty.contoso.com*'} -Priority 1

#Done.
