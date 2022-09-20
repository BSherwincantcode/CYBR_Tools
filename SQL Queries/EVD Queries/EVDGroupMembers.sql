SELECT CAUUserID, CAULDAPFullDN, CAULDAPDirectory, CAGGroupName, CAGLDAPFullDN, CAGLDAPDirectory/*, CAOSafeName*/ FROM CAUsers
--SELECT * FROM CAUsers
--Swap comment on either of the above to see all available columns
INNER JOIN CAGroupMembers
	ON CAGroupMembers.CAGMUserID = CAUsers.CAUUserID
INNER JOIN CAGroups
	ON CAGroupMembers.CAGMGroupID = CAGroups.CAGGroupID
/*INNER JOIN CAOwners
	ON CAGroups.CAGGroupID = CAOOwnerID AND CAOOwnerType = '1'*/
ORDER BY CAGGroupName
--ORDER BY CAOSafeName
/*
This query will show  the usernames, and if applicable, DNs of any users who are 
members of a group inside CyberArk, as well as the group name and group DN

To see the list of safes these groups have access to, uncomment the ", CAOSafeName" in the SELECT
statement and the "INNER JOIN CAOwners...CAOOwnerType = '1'"
*/