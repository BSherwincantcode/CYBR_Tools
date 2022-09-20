USE CyberArk


IF OBJECT_ID(N'tempdb..#InventoryReport') IS NOT NULL
	BEGIN
	DROP TABLE #InventoryReport
	END
GO

IF OBJECT_ID(N'tempdb..#SafeIDs') IS NOT NULL
	BEGIN
	DROP TABLE #SafeIDs
	END
GO

IF OBJECT_ID(N'tempdb..#OwnersIDs') IS NOT NULL
	BEGIN
	DROP TABLE #OwnersIDs
	END
GO

IF OBJECT_ID(N'tempdb..#ChangeFail') IS NOT NULL
BEGIN
DROP TABLE #ChangeFail
END
GO


--Create Temp Tables
CREATE TABLE #InventoryReport(
	SafeID bigint,
	FileID bigint,
	[Safe] nvarchar(28),
	DeviceType nvarchar(128),
	PlatformID nvarchar(128),
	TargetSystemAddress nvarchar(128),
	TargetSystemUsername nvarchar(128),
	GroupName nvarchar(128),
	LastAccessedDate datetime,
	LastAccessedBy nvarchar(128),
	LastModifiedDate datetime,
	LastModifiedBy nvarchar(128),
	ChangeFailure bit,
	VerificationFailure bit,
	FailureReason nvarchar(max)
	)

Create Table #ChangeFail(
	SafeID int,
	FileID int,
	Fail bit,
	LastTask nvarchar(32),
	Error nvarchar(MAX)
	)

CREATE TABLE #SafeIDs(
	SafeIDs int
	)

CREATE TABLE #OwnersIDs(
	OwnerIDs int
	)

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--Define Safe IDs
--Two options - first, section, target specific safes, second is to determine what safes a user owns and target those.
--Option 1: Format: WHERE CASSafeName IN ('safename1','safename2','safename3',etc)
/*
INSERT INTO #SafeIDs
Select CASSafeID from CASafes
WHERE CASSafeName IN ('P_HT_DOM_SPA')
*/
--Option 2: search for specific safe owner by name (as defined within CyberArk)


INSERT INTO #OwnersIDs
SELECT CAUUserID from CAUsers
WHERE CAUUserName = 'Alice'

Insert INTO #OwnersIDs
select CAGMGroupID from CAGroupMembers
LEFT JOIN CAUsers on CAGMUserID = CAUUserID
WHERE CAUUserName = 'Alice'

INSERT INTO #SafeIDs
SELECT DISTINCT(CAOSafeID) from CAOwners
LEFT JOIN #OwnersIDs on CAOwners.CAOOwnerID = #OwnersIDs.OwnerIDs


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--Add properties to Inventory Report from FilesList output
INSERT INTO #InventoryReport (SafeID, FileID, [Safe], LastAccessedDate,LastAccessedBy,LastModifiedDate,LastModifiedBy)
Select CAFSafeID, CAFFileID, CAFSafeName, CAFLastUsedDate, CAFLastUsedBy, CAFLastModifiedDate, CAFLastModifiedBy from CAFiles
WHERE CAFSafeID IN (Select * from #SafeIDs) AND CAFType = 2

/*
Select CAOPFileId, CAOPSafeId, CAOPObjectPropertyName, CAOPObjectPropertyValue from CAObjectProperties
WHERE CAOPSafeID = (Select CASSafeID from CASafes WHERE CASSafeName = 'P_HT_DOM_SPA')
	AND (CAOPObjectPropertyId = 2684354561 --Username
	OR CAOPObjectPropertyId = 2684354714 --DeviceType
	OR CAOPObjectPropertyId = 2684354560 --PolicyID, AKA Platform 
	OR CAOPObjectPropertyId = 2684354562 --Address
	OR CAOPObjectPropertyId = 2684354595 --Group Name
	OR CAOPObjectPropertyId = 2684354697 --CPMStatus
	OR CAOPObjectPropertyID = 2684354613 --CPMErrorDetails
	OR CAOPObjectPropertyId = 2684354698 --LastTask (CPM)
	*/

--Device Type
UPDATE #InventoryReport
SET DeviceType = CAOPObjectPropertyValue
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #InventoryReport.FileID = CAObjectProperties.CAOPFileId AND #InventoryReport.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354714

--Platform
UPDATE #InventoryReport
SET PlatformID = CAOPObjectPropertyValue
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #InventoryReport.FileID = CAObjectProperties.CAOPFileId AND #InventoryReport.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354560

--Target System Username
UPDATE #InventoryReport
SET TargetSystemUsername = CAOPObjectPropertyValue
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #InventoryReport.FileID = CAObjectProperties.CAOPFileId AND #InventoryReport.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354561

--Target System Address
UPDATE #InventoryReport
SET TargetSystemAddress = CAOPObjectPropertyValue
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #InventoryReport.FileID = CAObjectProperties.CAOPFileId AND #InventoryReport.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354562

--GroupName
UPDATE #InventoryReport
SET GroupName = CAOPObjectPropertyValue
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #InventoryReport.FileID = CAObjectProperties.CAOPFileId AND #InventoryReport.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354595

--Resolve CPM failure messages, if any
INSERT INTO #ChangeFail(SafeID, FileID)
SELECT #InventoryReport.SafeID, #InventoryReport.FileID from #InventoryReport

--Determine if failure occurred
UPDATE #ChangeFail
SET #ChangeFail.Fail = CASE
	WHEN CAObjectProperties.CAOPObjectPropertyValue = 'failure' AND CAObjectProperties.CAOPObjectPropertyId = 2684354697 THEN 1
	WHEN CAOPObjectPropertyValue = 'success' THEN 0
	ELSE NULL
END
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #ChangeFail.FileID = CAObjectProperties.CAOPFileId AND #ChangeFail.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354697

--Remove rows where no failure occurred
DELETE from #ChangeFail
WHERE #ChangeFail.Fail = 0


--Identify Last Task
UPDATE #ChangeFail
SET #ChangeFail.LastTask = CAObjectProperties.CAOPObjectPropertyValue
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #ChangeFail.FileID = CAObjectProperties.CAOPFileId AND #ChangeFail.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354698

--Get Error
UPDATE #ChangeFail
SET #ChangeFail.Error = CAObjectProperties.CAOPObjectPropertyValue
FROM CAObjectProperties LEFT JOIN #InventoryReport ON CAObjectProperties.CAOPSafeId = #InventoryReport.SafeID
WHERE #ChangeFail.FileID = CAObjectProperties.CAOPFileId AND #ChangeFail.SafeID = CAObjectProperties.CAOPSafeId AND CAOPObjectPropertyId = 2684354613

--Test and apply failure type -- ChangeFailure 
UPDATE #InventoryReport
SET #InventoryReport.ChangeFailure = 1
FROM #ChangeFail JOIN #InventoryReport ON #ChangeFail.SafeID = #InventoryReport.SafeID
WHERE #ChangeFail.FileID = #InventoryReport.FileID AND #ChangeFail.SafeID = #InventoryReport.SafeID AND (#ChangeFail.Error = 'ChangeTask' OR #ChangeFail.Error = 'ReconcileTask')

--Test and apply failure type -- VerifyFailure 
UPDATE #InventoryReport
SET #InventoryReport.VerificationFailure = 1
FROM #ChangeFail JOIN #InventoryReport ON #ChangeFail.SafeID = #InventoryReport.SafeID
WHERE #ChangeFail.FileID = #InventoryReport.FileID AND #ChangeFail.SafeID = #InventoryReport.SafeID AND #ChangeFail.Error = 'VerifyTask'

--Apply error to inventory report
UPDATE #InventoryReport
SET #InventoryReport.FailureReason = #ChangeFail.Error
FROM #ChangeFail JOIN #InventoryReport ON #ChangeFail.SafeID = #InventoryReport.SafeID
WHERE #ChangeFail.FileID = #InventoryReport.FileID AND #ChangeFail.SafeID = #InventoryReport.SafeID AND #ChangeFail.Error IS NOT NULL

SELECT * from #InventoryReport

/*
GO

--Create/Update view
CREATE VIEW InvReport AS
Select #InventoryReport.[Safe], #InventoryReport.DeviceType, #InventoryReport.PlatformID, #InventoryReport.TargetSystemAddress,
	#InventoryReport.TargetSystemUsername, #InventoryReport.GroupName,#InventoryReport.LastAccessedDate, #InventoryReport.LastAccessedBy,
	#InventoryReport.LastModifiedDate, #InventoryReport.LastModifiedBy, #InventoryReport.ChangeFailure,#InventoryReport.VerificationFailure,
	#InventoryReport.FailureReason
	from #InventoryReport
ORDER BY #InventoryReport.SafeID, #InventoryReport.FileID ASC

GO

[Safe] nvarchar(28),
	DeviceType nvarchar(128),
	PlatformID nvarchar(128),
	TargetSystemAddress nvarchar(128),
	TargetSystemUsername nvarchar(128),
	GroupName nvarchar(128),
	LastAccessedDate datetime,
	LastAccessedBy nvarchar(128),
	LastModifiedDate datetime,
	LastModifiedBy nvarchar(128),
	ChangeFailure bit,
	VerificationFailure bit,
	FailureReason nvarchar(max)
--nearly there.  something seems to be wrong with building the owned safes list, but maybe we can resolve that through additional testing.*/