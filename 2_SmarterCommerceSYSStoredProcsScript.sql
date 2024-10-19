USE [SC_SYSDB_NAME] 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelEnvironmentInstance'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelEnvironmentInstance
END 
GO
-- #desc					Delete EnvironmentInstance
-- #bl_class				PremierSySBase.EnvironmentInstance.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @EnvironmentID	Key definition
-- #param @SequenceID		Key definition, Incremental


CREATE PROCEDURE [dbo].SCSYS_DelEnvironmentInstance
    @EnvironmentID	NVARCHAR(40),
	@SequenceID		INT = null
AS 
	
	IF(@SequenceID IS NULL)
		BEGIN
			DELETE
			FROM   [dbo].EnvironmentInstance
			WHERE  [EnvironmentID] = @EnvironmentID
		END
	ELSE
		BEGIN
			DELETE
			FROM   [dbo].EnvironmentInstance
			WHERE  [EnvironmentID] = @EnvironmentID
			AND SequenceID = @SequenceID
		END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelEnvironmentConfig'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelEnvironmentConfig
END 
GO
-- #desc							 Delete EnvironmentConfig
-- #bl_class                         PremierSySBase.EnvironmentConfig.cs
-- #db_dependencies                  N/A
-- #db_references                    N/A

-- #param @EnvironmentID			 Key definition
-- #param @InstanceID				 Key definition
-- #param @ConfKey					 Key definition


CREATE PROCEDURE [dbo].SCSYS_DelEnvironmentConfig
    @EnvironmentID	NVARCHAR(40),
	@InstanceID		INT = null,
	@ConfKey		NVARCHAR(100) = null
AS 
	DELETE
	FROM   [dbo].EnvironmentConfig
	WHERE  [EnvironmentID] = @EnvironmentID
	AND (@ConfKey IS NULL OR ConfKey = @ConfKey)
	AND (@InstanceID IS NULL OR [InstanceID] = @InstanceID)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserEnvironment'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUserEnvironment
END 
GO
-- #desc					Delete User Environment.
-- #bl_class                PremierSySBase.UserEnviroment.cs
-- #db_dependencies         N/A
-- #db_references           N/A

-- #param @EnvironmentID	Key definition
-- #param @UserID			Key definition

CREATE PROCEDURE [dbo].SCSYS_DelUserEnvironment
	@UserID			INT = NULL,
	@EnvironmentID	NVARCHAR(40) = NULL
   
AS  
	DELETE
	FROM   [dbo].UserEnvironment
	WHERE (@EnvironmentID IS NULL OR [EnvironmentID] = @EnvironmentID)
	AND	  (@UserID IS NULL OR [UserID] = @UserID)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserEnvInstallation'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUserEnvInstallation
END 
GO
-- #desc					   Delete User Installation
-- #bl_class                   PremierSySBase.UserStore.cs/UserStores.cs
-- #db_dependencies            N/A
-- #db_references              N/A

-- #param @UserID			   Key definition
-- #param @InstallationID      Key definition

CREATE PROCEDURE [dbo].SCSYS_DelUserEnvInstallation
    @UserID			INT = NULL,
	@EnvironmentID	NVARCHAR(40)= NULL,
    @InstallationID NVARCHAR(3)= NULL

AS 
	
	DELETE
	FROM   [dbo].UserEnvInstallation
	WHERE (@UserID IS NULL OR [UserID] = @UserID)
	AND (@EnvironmentID IS NULL OR [EnvironmentID] = @EnvironmentID)
	AND (@InstallationID IS NULL OR [InstallationID] = @InstallationID)
	
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelMenuSearchIndexLang'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelMenuSearchIndexLang
END 
GO

-- #desc                        Delete a menu search lang.
-- #bl_class                    PremierSySBase.MenuSearchIndexLang.cs
-- #db_dependencies             N/A
-- #db_references               N/A

--#param @ItemUniqueID          UniqueID key required
--#param @LanguageCode 			Language Code required


CREATE PROCEDURE [dbo].SCSYS_DelMenuSearchIndexLang
    @ItemUniqueID	BIGINT,
	@LanguageCode	NVARCHAR(4) = NULL
AS 

	DELETE
	FROM   [dbo].MenuSearchIndexLang
	WHERE  [ItemUniqueID] = @ItemUniqueID 
	AND (@LanguageCode IS NULL OR [LanguageCode] = @LanguageCode)
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelMessageGlossaryLang'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelMessageGlossaryLang
END 
GO

-- #desc                        Delete a message glossary lang.
-- #bl_class					PremierSySBase.SystemMessageLang.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @MessageKey           Message key required
-- #param @LanguageCode 		Language Code required


CREATE PROCEDURE [dbo].SCSYS_DelMessageGlossaryLang
    @MessageKey		NVARCHAR(40),
	@LanguageCode	NVARCHAR(4) = NULL
AS 

	DELETE
	FROM   [dbo].MessageGlossaryLang
	WHERE  [MessageKey] = @MessageKey 
	AND (@LanguageCode IS NULL OR [LanguageCode] = @LanguageCode)
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelRolePermission'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelRolePermission
END 
GO
-- #desc                     Delete RolePermission
-- #bl_class                 PremierSySBase.RolePermission.cs
-- #db_dependencies          N/A
-- #db_references            SCSYS_DelRole

-- #params @RoleID			 Key definition
-- #params @PermissionID	 Key definition (Not Required)


CREATE PROCEDURE [dbo].SCSYS_DelRolePermission
    @RoleID			NVARCHAR(40),
    @PermissionID	NVARCHAR(40) = NULL
AS 
	
	DELETE
	FROM   [dbo].RolePermission
	WHERE  
		[RoleID] = @RoleID
		AND (@PermissionID IS NULL OR [PermissionID] = @PermissionID)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserRole'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUserRole 
END 
GO
-- #desc						Delete User Role
-- #bl_class                    PremierSySBase.UserRole.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @UserID				Key definition
-- #param @RoleID				Key definition


CREATE PROCEDURE [dbo].SCSYS_DelUserRole
    @UserID INT = NULL,
    @RoleID NVARCHAR(40) = NULL
AS 
	
	DELETE
	FROM   [dbo].UserRole
	WHERE (@UserID IS NULL OR [UserID] = @UserID)
	AND (@RoleID IS NULL OR [RoleID] = @RoleID)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserQuickLink'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUserQuickLink
END 
GO
-- #desc							Delete User Quick Link.
-- #bl_class                        Premier.SysBase.UserQuickLink.cs
-- #db_dependencies                 N/A
-- #db_references                   N/A

-- #param @UserID              		User ID key definition required
-- #param @QuickLinkUniqueID  		QuickLinkUniqueID key definition  required


CREATE PROCEDURE [dbo].SCSYS_DelUserQuickLink
	@UserID				INT = NULL,
    @QuickLinkUniqueID	INT = NULL
AS 

	DELETE
	FROM   [dbo].UserQuickLink
	WHERE  
		[UserID] = @UserID
		AND (@QuickLinkUniqueID IS NULL OR [QuickLinkUniqueID] = @QuickLinkUniqueID)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserPasswordHistory'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUserPasswordHistory
END 
GO

-- #desc				Delete User Password History.
-- #bl_class            N/A
-- #db_dependencies     User
-- #db_references		N/A

-- #param @UserID       User ID required


CREATE PROCEDURE [dbo].SCSYS_DelUserPasswordHistory
    @UserID INT
AS 
	SET NOCOUNT ON 

	DELETE
	FROM   [dbo].UserPasswordHistory
	WHERE  [UserID] = @UserID
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserDevicePreference'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUserDevicePreference
END 
GO
-- #desc                        Update User Preferences.
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @OwnerType			User or Device
-- #param @OwnerID				UserID or IP
-- #param @PreferenceKey		AWB OR POS Enum String Value

CREATE PROCEDURE [dbo].[SCSYS_DelUserDevicePreference]
	@OwnerType	NVARCHAR(2),
    @OwnerID	NVARCHAR(30),
    @PreferenceKey	NVARCHAR(30)
AS

	IF (@PreferenceKey <> '*') --delete only the specific preference
	BEGIN
		DELETE FROM [dbo].[UserDevicePreferences]
		WHERE [OwnerType] = @OwnerType AND	[OwnerID] = @OwnerID AND [PreferenceKey] = @PreferenceKey 
	END
	ELSE --delete all the preferences of the user or device
	BEGIN
		DELETE FROM [dbo].[UserDevicePreferences]
		WHERE [OwnerType] = @OwnerType AND	[OwnerID] = @OwnerID
	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserNotification'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUserNotification
END 
GO

-- #desc						Delete User Notification
-- #bl_class                    PremierSySBase.UserNotification.cs
-- #db_dependencies             User
-- #db_references               N/A

-- #param @UserID               User ID 
-- #param @NotificationID 		Notification ID


CREATE PROCEDURE [dbo].SCSYS_DelUserNotification
	@UserID			INT,
	@NotificationID INT
   
AS
	DELETE
	FROM   	[dbo].UserNotification
	WHERE  	[UserID] = @UserID
	AND 	(@NotificationID IS NULL OR [NotificationID] = @NotificationID)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetEnvironmentConfigs'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetEnvironmentConfigs
END 
GO

-- #desc                        Get an Environment Configs.
-- #bl_class					N/A
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @EnvironmentID        Unique Environment required
-- #param @InstanceID           InstanceID required
-- #param @ConfKey              ConfKey required


CREATE PROCEDURE [dbo].SCSYS_GetEnvironmentConfigs
    @EnvironmentID NVARCHAR(40)
AS 	

	SELECT [EnvironmentID]
	,[InstanceID]
	,[ConfKey]
	,[ConfType]
	,[ConfVal]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated]
	 
	FROM   [dbo].EnvironmentConfig 
	WHERE  EnvironmentID = @EnvironmentID
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetEnvironmentInstances'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetEnvironmentInstances
END 
GO

-- #desc                        Get an Environment Instance.
-- #bl_class                    N/A
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @EnvironmentID		Environment ID required
-- #param @SequenceID           Sequence ID required

CREATE PROCEDURE [dbo].SCSYS_GetEnvironmentInstances
    @EnvironmentID NVARCHAR(40)

AS 
	SELECT [EnvironmentID]
	,[SequenceID]
	,[UrlPath]
	,[PhysicalPath]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated]
	 
	FROM   [dbo].EnvironmentInstance 
	WHERE  EnvironmentID = @EnvironmentID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMenuSearchIndexLang'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMenuSearchIndexLang
END 
GO
-- #desc						Get Menu Search Languages.
-- #bl_class					N/A
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @ItemUniqueID			Unique ID required

CREATE PROCEDURE  [dbo].SCSYS_GetMenuSearchIndexLang
    @ItemUniqueID bigINT
AS 
	
	SELECT	
	  ItemUniqueID,
	  LanguageCode, 
	  ItemDesc, 
	  UserUpdate, 
	  WorkstationID, 
	  DateUpdated
	FROM   [dbo].MenuSearchIndexLang 
	WHERE  ItemUniqueID = @ItemUniqueID

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMessageGlossaryLangs'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMessageGlossaryLangs
END 
GO

-- #desc					   Get Message Glossary Languages.
-- #bl_class                   N/A
-- #db_dependencies            N/A
-- #db_references              N/A

-- #param @MessageID		   Message ID required


CREATE PROCEDURE  [dbo].SCSYS_GetMessageGlossaryLangs
    @MessageKey NVARCHAR(40)
AS 
	
	SELECT
	
	  MessageKey,
	  LanguageCode, 
	  MessageDesc, 
	  UserUpdate, 
	  WorkstationID, 
	  DateUpdated

	FROM   [dbo].MessageGlossaryLang 
	WHERE  MessageKey = @MessageKey

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetRolePermissions'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetRolePermissions
END 
GO

-- #desc                        Get an Role Permissions.
-- #bl_class					N/A
-- #db_dependencies             N/A
-- #db_references				N/A

-- #param @RoleID				Role ID required
-- #param @PermissionID         Permission ID required


CREATE PROCEDURE [dbo].SCSYS_GetRolePermissions 
    @RoleID NVARCHAR(40)
AS 
	SELECT RO.[RoleID]
	,RO.[PermissionID]
	,PE.[PermissionDesc]
	,PE.[GroupingCat] AS PermissionGroupCat
	,RO.[UserUpdate]
	,RO.[WorkstationID]
	,RO.[DateUpdated] 
	FROM   [dbo].RolePermission RO
	INNER JOIN [dbo].Permission PE
	ON RO.PermissionID = PE.PermissionID
	WHERE  RO.[RoleID] = @RoleID
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserRoles'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserRoles
END 
GO

-- #desc					Get an User Roles
-- #bl_class                Premier.SysBase.UserRoles.cs
-- #db_dependencies			N/A
-- #db_references			SCSYS_GetUser

-- #param @UserID           User ID required


CREATE PROCEDURE [dbo].SCSYS_GetUserRoles
    @UserID INT
AS 
	
	SELECT URS.[UserID]
	,URS.[RoleID]
	,UR.[RoleDesc]
	,URS.[UserUpdate]
	,URS.[WorkstationID]
	,URS.[DateUpdated]
	FROM   [dbo].UserRole AS URS 
	INNER JOIN [dbo].[Role] AS UR	
	ON URS.RoleID= Ur.RoleID
	WHERE [UserID] = @UserID
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserEnvironments'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserEnvironments 
END 
GO

-- #desc                         Get an User Environments.
-- #bl_class					 Premier.SysBase.UserEnvironment.cs
-- #db_dependencies				 N/A
-- #db_references                N/A

-- #param @UserID                User ID required

CREATE PROCEDURE [dbo].SCSYS_GetUserEnvironments
    @UserID INT
AS 

	SELECT [EnvironmentID]
	,[UserID]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated] 
	
	FROM   [dbo].UserEnvironment 
	WHERE  [UserID] = @UserID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserEnvInstallations'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserEnvInstallations
END 
GO

-- #desc                        Get an User Installations.
-- #bl_class                    Premier.SysBase.UserStores.cs
-- #db_dependencies             User
-- #db_references               N/A

-- #param @UserID               User ID required
-- #param @InstallationID       Installation ID required

CREATE PROCEDURE [dbo].SCSYS_GetUserEnvInstallations
    @UserID			INT,
	@EnvironmentID	NVARCHAR(40) = NULL
AS 
	
	SELECT [UserID]
	,[EnvironmentID]
	,[InstallationID]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated] 

	FROM   [dbo].UserEnvInstallation 
	WHERE  [UserID] = @UserID
	AND (@EnvironmentID IS NULL OR [EnvironmentID] = @EnvironmentID)
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'dbo.SCQRTZ_GetFiredTriggerHistory'))
BEGIN 
    DROP PROCEDURE [dbo].SCQRTZ_GetFiredTriggerHistory
END 
GO

Create Procedure [dbo].SCQRTZ_GetFiredTriggerHistory
(
	@SCHED_NAME			NVARCHAR(100),
	@JOB_NAME			NVARCHAR(150),
	@JOB_GROUP			NVARCHAR(150),
	@FirstRow			int,
	@EndRow				int
)
AS 
	IF(@JOB_NAME = '*')
		BEGIN
			SELECT * 
			FROM (
				SELECT ROW_NUMBER() OVER (ORDER BY FIRED_TIME DESC) AS RowNum, *
				FROM SCQRTZ_FIRED_TRIGGERS_HIST T
				WHERE 
					SCHED_NAME = @SCHED_NAME AND
					JOB_GROUP = @JOB_GROUP
				) AS RowConstrainedResult
			WHERE 
				RowNum >= @FirstRow AND 
				RowNum < @EndRow OR 
				@FirstRow =-1
			ORDER BY RowNum
		END
	ELSE
		BEGIN
			SELECT * 
			FROM (
				SELECT ROW_NUMBER() OVER (ORDER BY FIRED_TIME DESC) AS RowNum, *
				FROM SCQRTZ_FIRED_TRIGGERS_HIST T
				WHERE 
					SCHED_NAME = @SCHED_NAME AND
					JOB_GROUP = @JOB_GROUP AND
					JOB_NAME = @JOB_NAME
				) AS RowConstrainedResult
			WHERE 
				RowNum >= @FirstRow AND 
				RowNum < @EndRow OR 
				@FirstRow =-1
			ORDER BY RowNum
		END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'dbo.SCQRTZ_GetJobDetails'))
BEGIN 
    DROP PROCEDURE [dbo].SCQRTZ_GetJobDetails
END 
GO

CREATE Procedure [dbo].SCQRTZ_GetJobDetails
(
	@SCHED_NAME			NVARCHAR(100),
	@StateParam			NVARCHAR(16),
	@StartDateParam		bigint,
	@EndDateParam		bigint,
	@FirstRow			int,
	@EndRow				int,
	@JobGroupParam		NVARCHAR(150)
)
AS
	SELECT *
	FROM ( 
		SELECT ROW_NUMBER() OVER (ORDER BY DT.SCHED_NAME, DT.JOB_GROUP, T.TRIGGER_STATE, T.NEXT_FIRE_TIME, T.START_TIME, FT.STATE, FT.FIRED_TIME) AS RowNum,
				DT.SCHED_NAME, DT.JOB_NAME, DT.JOB_GROUP, DT.DESCRIPTION, DT.JOB_CLASS_NAME, DT.IS_DURABLE, DT.REQUESTS_RECOVERY, DT.JOB_DATA, 
                ISNULL (FT.STATE, ISNULL (T.TRIGGER_STATE, 'COMPLETE')) CURRENT_STATE, T.NEXT_FIRE_TIME, FTH.FIRED_TIME, FTH.LAST_STATUS 
                FROM [dbo].[SCQRTZ_JOB_DETAILS] DT
	                OUTER APPLY (
                        SELECT TOP 1 A.SCHED_NAME, A.JOB_NAME, A.JOB_GROUP, A.TRIGGER_NAME, A.TRIGGER_GROUP, A.TRIGGER_STATE, A.NEXT_FIRE_TIME, A.START_TIME
                        FROM 
							[dbo].[SCQRTZ_TRIGGERS] A
                        WHERE 
							DT.SCHED_NAME = A.SCHED_NAME AND
							DT.JOB_NAME = A.JOB_NAME AND 
							DT.JOB_GROUP =A.JOB_GROUP  
                        ORDER BY 
							A.START_TIME DESC) AS T 
		            OUTER APPLY (
                        SELECT TOP 1  B.FIRED_TIME, B.STATE
                        FROM 
							[dbo].[SCQRTZ_FIRED_TRIGGERS] B
                        WHERE  
							T.SCHED_NAME = B.SCHED_NAME AND 
							T.TRIGGER_NAME = B.TRIGGER_NAME AND 
							T.TRIGGER_GROUP = B.TRIGGER_GROUP AND 
							T.JOB_NAME=B.JOB_NAME AND 
							T.JOB_GROUP=B.JOB_GROUP
						ORDER BY
							B.FIRED_TIME DESC) AS  FT
                    OUTER APPLY(
                        SELECT TOP 1 C.FIRED_TIME, C.STATE LAST_STATUS
                        FROM
							[dbo].[SCQRTZ_FIRED_TRIGGERS_HIST] C
                        WHERE 
							DT.SCHED_NAME = C.SCHED_NAME AND 
							DT.JOB_NAME=C.JOB_NAME AND
							DT.JOB_GROUP=C.JOB_GROUP
                        ORDER BY 
							C.FIRED_TIME DESC) AS  FTH                                
	            WHERE 
					(ISNULL (FT.STATE, ISNULL (T.TRIGGER_STATE,'COMPLETE')) = @StateParam OR @StateParam = '*') AND 
					(T.START_TIME BETWEEN @StartDateParam AND @EndDateParam OR @StartDateParam = -1) AND 
					(DT.SCHED_NAME = @SCHED_NAME) AND 
					(DT.JOB_GROUP = @JobGroupParam OR  @JobGroupParam = '*') 	            
                ) as RowConstrainedResult	
            WHERE 
				RowNum >= @FirstRow AND 
				RowNum < @EndRow OR 
				@FirstRow =-1
            ORDER BY RowNum;
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddDeployPackage'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddDeployPackage
END
GO

-- #desc                            Add Deploy Package description.
-- #bl_class                        PremierSySBase.DeployPackage.cs
-- #db_dependencies					N/A
-- #db_references                   N/A

-- #param @PackageUniqueID          GUID automatically generated
-- #param @PackageType
-- #param @PackageDesc
-- #param @Version
-- #param @GenerationDate
-- #param @MinRequiredVer
-- #param @PackageBody
-- #param @UserUpdate
-- #param @WorkstationID
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddDeployPackage
(
    @PackageUniqueID	UNIQUEIDENTIFIER,
    @PackageType		NVARCHAR(20),
    @PackageDesc		NVARCHAR(1024),
    @Version			NVARCHAR(40),
    @GenerationDate		DATETIME2,
    @MinRequiredVer		INT,
    @PackageBody		VARBINARY(MAX),
    @UserUpdate			NVARCHAR(128),
    @WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
)
AS 
	
	
	INSERT INTO [dbo].DeployPackage ([PackageUniqueID], [PackageType], [PackageDesc], [Version], [GenerationDate], [MinRequiredVer], [PackageBody], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @PackageUniqueID, 
	@PackageType, 
	@PackageDesc, 
	@Version, 
	@GenerationDate, 
	@MinRequiredVer, 
	@PackageBody, @UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddEnvironment'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddEnvironment
END 
GO

-- #desc					Add Enviroment description.
-- #bl_class				PremierSySBase.Environment.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @EnvironmentID	Key definition
-- #param @EnvDesc
-- #param @Version
-- #param @ConfigByInstance
-- #param @UserUpdate
-- #param @WorkstationID
-- #param @DateUpdate


CREATE PROCEDURE [dbo].SCSYS_AddEnvironment
(
    @EnvironmentID		NVARCHAR(40),
    @EnvDesc			NVARCHAR(256),
    @Version			NVARCHAR(60),
	@ConfigByInstance	NVARCHAR(2),
    @UserUpdate			NVARCHAR(128),
    @WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
)
AS 
	INSERT INTO [dbo].Environment ([EnvironmentID], [EnvDesc], [Version], [ConfigByInstance], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @EnvironmentID, 
	@EnvDesc, 
	@Version, 
	@ConfigByInstance,
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddEnvironmentConfig'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddEnvironmentConfig
END 
GO
-- #desc					Add EnviromentConfig description.
-- #bl_class				PremierSySBase.EnvironmentConfig.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @EnvironmentID	Key definition
-- #param @ConfKey			Key definition 
-- #param @InstanceID		Key definition 
-- #param @ConfType
-- #param @ConfVal
-- #param @UserUpdate
-- #param @WorkstationID
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddEnvironmentConfig
(
    @EnvironmentID		NVARCHAR(40),
	@InstanceID			INT,
    @ConfKey			NVARCHAR(100),
    @ConfType			NVARCHAR(20),
    @ConfVal			NVARCHAR(MAX),
    @UserUpdate			NVARCHAR(128),
    @WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
)
AS 
	
	INSERT INTO [dbo].EnvironmentConfig ([EnvironmentID], [InstanceID], [ConfKey], [ConfType], [ConfVal], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @EnvironmentID, 
	@InstanceID,
	@ConfKey, 
	@ConfType, 
	@ConfVal, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddEnvironmentInstance'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddEnvironmentInstance
END 
GO
-- #desc                    Add EnvironmentInstance description.
-- #bl_class                PremierSySBase.EnvironmentInstance.cs
-- #db_dependencies			N/A
-- #db_references           N/A

-- #param @EnvironmentID	Key definition
-- #param @UrlPath
-- #param @PhysicalPath
-- #param @UserUpdate
-- #param @WorkstationID
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddEnvironmentInstance
    @EnvironmentID	NVARCHAR(40),
    @UrlPath		NVARCHAR(1024),
    @PhysicalPath	NVARCHAR(1024),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2 
AS 
	
	DECLARE @sequenceIDMax INT
	--First value is 1
	SET @sequenceIDMax = ISNULL((SELECT max(SequenceID) FROM EnvironmentInstance WHERE EnvironmentID = @EnvironmentID) + 1, 1) 

	INSERT INTO [dbo].EnvironmentInstance ([EnvironmentID], [SequenceID], [UrlPath], [PhysicalPath], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @EnvironmentID,
	@sequenceIDMax, 
	@UrlPath, 
	@PhysicalPath,
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddEnvironmentPackage'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddEnvironmentPackage
END 
GO
-- #desc                    Add EnvironmentPackage description.
-- #bl_class                PremierSySBase.EnvironmentPackage.cs
-- #db_dependencies         N/A
-- #db_references           N/A

-- #param @EnvironmentID	Key definition
-- #param @PackageUniqueID  Key definiion
-- #param @UserApplied 
-- #param @DateApplied


CREATE PROCEDURE [dbo].SCSYS_AddEnvironmentPackage
(
    @EnvironmentID		NVARCHAR(40),
    @PackageUniqueID	UNIQUEIDENTIFIER,
    @UserApplied		INT,
    @DateApplied		DATETIME2
)
AS 
	
	
	INSERT INTO [dbo].EnvironmentPackage ([EnvironmentID], [PackageUniqueID], [UserUpdate], [DateUpdated])
	SELECT @EnvironmentID,
	@PackageUniqueID, 
	@UserApplied, 
	@DateApplied
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddMenuSearchIndex'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddMenuSearchIndex
END 
GO
-- #desc                Add Menu Search Index description.
-- #bl_class            PremierSySBase.MenuSearchIndex.cs
-- #db_dependencies		N/A
-- #db_references		N/A

-- #param @ItemUniqueID Key definition
-- #param @ItemType 
-- #param @ItemKey 
-- #param @ItemDesc 
-- #param @ItemDesc2 
-- #param @ItemURL 
-- #param @UserUpdate 
-- #param @WorkstationID 
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddMenuSearchIndex
( 
    @ItemUniqueID	BIGINT output,
    @ItemType		NVARCHAR(20),
    @ItemKey		NVARCHAR(128),
    @ItemDesc		NVARCHAR(512),
    @ItemDesc2		NVARCHAR(512),
    @ItemURL		NVARCHAR(1024),
	@ItemArea		NVARCHAR(30),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
)
AS 
	-- Return the Max Item Unique ID
	SET @ItemUniqueID = (ISNULL((SELECT MAX ([ItemUniqueID]) FROM [dbo].MenuSearchIndex),0) + 1)
	
	INSERT INTO [dbo].MenuSearchIndex ([ItemUniqueID], [ItemType], [ItemKey], [ItemDesc], [ItemDesc2], [ItemURL], [ItemArea], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT
	@ItemUniqueID,
	@ItemType, 
	@ItemKey, 
	@ItemDesc, 
	@ItemDesc2, 
	@ItemURL,
	@ItemArea, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
	
	
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddMenuSearchIndexLang'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddMenuSearchIndexLang
END 
GO

-- #desc                            Add a menu search index lang.
-- #bl_class                        Premier.Common.MenuSearchLang.cs
-- #db_dependencies                 N/A
-- #db_references                   N/A

--#param @ItemUniqueID       		Unique key required
--#param @LanguageCode				Language Code required
--#param @ItemDesc
--#param @ItemDesc2
--#param @UserUpdate
--#param @Workstation
--#param @DateUpdated

CREATE PROCEDURE [dbo].SCSYS_AddMenuSearchIndexLang
(
	@ItemUniqueID bigINT, 
    @LanguageCode NVARCHAR(4),
    @ItemDesc NVARCHAR(512),
	@ItemDesc2 NVARCHAR(512),
    @UserUpdate NVARCHAR(128),
    @WorkstationID NVARCHAR(60),
    @DateUpdated DATETIME2
)
AS  	
	INSERT INTO [dbo].MenuSearchIndexLang (
	[ItemUniqueID],
	[LanguageCode], 
	[ItemDesc], 
	[ItemDesc2], 
	[UserUpdate], 
	[WorkstationID],
	[DateUpdated])

	SELECT 
	@ItemUniqueID,
	@LanguageCode, 
	@ItemDesc,
	@ItemDesc2,
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddMessageGlossary'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddMessageGlossary
END 
GO

-- #desc                           Add Message Golassary.
-- #bl_class                       Premier.Common.SystemMessage.cs
-- #db_dependencies                N/A
-- #db_references                  N/A

--#param  @MessageKey              Message key required
--#param  @MessageDesc
--#param  @MessageType 
--#param  @MessageLevel
--#param  @UserUpdate
--#param  @WorkstationID
--#param  @DateUpdated

CREATE PROCEDURE [dbo].SCSYS_AddMessageGlossary
    @MessageKey		NVARCHAR(40),
    @MessageDesc	NVARCHAR(512),
    @MessageType	NVARCHAR(20),
    @MessageLevel	NVARCHAR(20),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME
AS 

	INSERT INTO [dbo].MessageGlossary ([MessageKey], [MessageDesc], [MessageType], [MessageLevel], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @MessageKey, @MessageDesc, @MessageType, @MessageLevel, @UserUpdate, @WorkstationID, @DateUpdated
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddMessageGlossaryLang'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddMessageGlossaryLang
END 
GO

-- #desc                           Add a message glossary lang.
-- #bl_class					   Premier.Common.SystemMessageLang.cs
-- #db_dependencies                N/A
-- #db_references                  N/A

--#param @MessageKey         	   Message key required
--#param @LanguageCode			   Language Code required
--#param @MessageLevel			
--#param @LanguageDesc
--#param @UserUpdate
--#param @WorkstationID
--#param @DateUpdated



CREATE PROCEDURE [dbo].SCSYS_AddMessageGlossaryLang
    @MessageKey NVARCHAR(40),
    @LanguageCode NVARCHAR(4),
    @MessageDesc NVARCHAR(512),
    @UserUpdate NVARCHAR(128),
    @WorkstationID NVARCHAR(60),
    @DateUpdated DATETIME2
AS 
 	
	INSERT INTO [dbo].MessageGlossaryLang ([MessageKey],
	[LanguageCode], 
	[MessageDesc], 
	[UserUpdate], 
	[WorkstationID],
	[DateUpdated])	
	SELECT @MessageKey, 
	@LanguageCode, 
	@MessageDesc,
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddRole'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddRole
END 
GO

-- #desc                    Add Role description.
-- #bl_class                PremierSySBase.Permission.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @RoleID			Key definition
-- #param @RoleDesc 
-- #param @UserUpdate 
-- #param @WorkstationID 
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddRole
    @RoleID			NVARCHAR(40),
    @RoleDesc		NVARCHAR(512),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	INSERT INTO [dbo].[Role] ([RoleID], [RoleDesc], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @RoleID, 
	@RoleDesc, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddRolePermission'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddRolePermission
END 
GO
-- #desc                    AddRolePermission description.
-- #bl_class                PremierSySBase.RolePermission.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @RoleID			Key definition
-- #param @PermissionID		Key definition
-- #param @UserUpdate 
-- #param @WorkstationID 
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddRolePermission
    @RoleID			NVARCHAR(40),
    @PermissionID	NVARCHAR(40),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 
	
	
	INSERT INTO [dbo].RolePermission ([RoleID], [PermissionID], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @RoleID, 
	@PermissionID, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddSecurityAudit'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddSecurityAudit
END 
GO
-- #desc                    Add SecurityAudit description.
-- #bl_class                PremierSySBase.RecordSecurityAuditCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @EntryUniqueID	UNIQUEIDENTIFIER, key definition
-- #param @UserID 
-- #param @UserName 
-- #param @MachineKey 
-- #param @AppName 
-- #param @AppSource 
-- #param @ActionDesc 
-- #param @ActionParams 
-- #param @ActionDateTime 
-- #param @ActionDetail


CREATE PROCEDURE [dbo].SCSYS_AddSecurityAudit 
    @UserID			INT,
    @UserName		NVARCHAR(128),
    @MachineKey		NVARCHAR(128),
    @AppName		NVARCHAR(128),
    @AppSource		NVARCHAR(512),
    @ActionDesc		NVARCHAR(512),
    @ActionParams	NVARCHAR(512),
    @ActionDateTime DATETIME2,
    @ActionDetail	NVARCHAR(MAX)
AS 
	
	INSERT INTO [dbo].[SecurityAudit] ([UserID], [UserName], [MachineKey], [AppName], [AppSource], [ActionDesc], [ActionParams], [ActionDateTime], [ActionDetail])
	SELECT  @UserID, @UserName, @MachineKey, @AppName, @AppSource, @ActionDesc, @ActionParams, @ActionDateTime, @ActionDetail
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUser'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUser
END 
GO
-- #desc                        Add User description.
-- #bl_class                    PremierSySBase.User.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @UserID				Key definition
-- #param @UserName 
-- #param @UserPassword 
-- #param @MailingName
-- #param @EmailAddress 
-- #param @AccountDisable
-- #param @AllowChangePass 
-- #param @ChangePassNxtLogin
-- #param @LastPasswordChanged
-- #param @UserAvatar
-- #param @UserUpdate
-- #param @WorkstationID
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddUser 
    @UserID					INT output,
    @UserName				NVARCHAR(128),
    @UserPassword			NVARCHAR(256),
    @MailingName			NVARCHAR(256),
    @EmailAddress			NVARCHAR(256),
    @AccountDisable			NCHAR(1),
	@AccountLocked			NCHAR(1),
    @AllowChangePass		NCHAR(1),
    @ChangePassNxtLogin		NCHAR(1),
    @LastPasswordChanged	DATETIME2,
	@LastAccountLocked		DATETIME2,
    @UserAvatar				VARBINARY(4000) = NULL,
    @UserUpdate				NVARCHAR(128),
    @WorkstationID			NVARCHAR(60),
    @DateUpdated			DATETIME2
AS 
	
	INSERT INTO [dbo].[User] ( [UserName], [UserPassword], [MailingName], [EmailAddress], [AccountDisable], [AccountLocked], [AllowChangePass], [ChangePassNxtLogin], [LastPasswordChanged], [LastAccountLocked], [UserAvatar], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT 	
	@UserName, 
	@UserPassword, 
	@MailingName, 
	@EmailAddress, 
	@AccountDisable,
	@AccountLocked,
	@AllowChangePass, 
	@ChangePassNxtLogin, 
	@LastPasswordChanged,
	@LastAccountLocked, 
	@UserAvatar, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
	
	-- Begin Return SELECT <- do not remove
	SET @UserID=(SELECT [UserID]
	FROM   [dbo].[User]
	WHERE  [UserID] = SCOPE_IDENTITY())	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserDevicePreference'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUserDevicePreference
END 
GO
-- #desc                        Add User Preference.
-- #bl_class                    PremierSySBase.UserDevicePreference.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @OwnerType			User or Device
-- #param @OwnerID				UserID or IP
-- #param @PreferenceKey		AWB OR POS Enum String Value
-- #param @PreferenceVal		Preference value
-- #param @UserUpdate			User that adds the new record
-- #param @WorkstationID		Source computer where the change is applied
-- #param @DateUpdated			Date of change

CREATE PROCEDURE [dbo].[SCSYS_AddUserDevicePreference]
	@OwnerType	NVARCHAR(2),
    @OwnerID	NVARCHAR(30),
    @PreferenceKey	NVARCHAR(30),
    @PreferenceVal	NVARCHAR(MAX),
	@UserUpdate	NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS
	INSERT INTO [dbo].[UserDevicePreferences]
           ([OwnerType],[OwnerID],[PreferenceKey],[PreferenceVal],[UserUpdate],[WorkstationID],[DateUpdated])
     VALUES
           (@OwnerType, @OwnerID, @PreferenceKey, @PreferenceVal, @UserUpdate, @WorkstationID, @DateUpdated)

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserEnvInstallation'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUserEnvInstallation
END 
GO
-- #desc					   Add UserEnvInstallation
-- #bl_class                   PremierSySBase.UserStore.cs
-- #db_dependencies            N/A
-- #db_references              N/A

-- #param @UserID			   Key definition
-- #param @InstallationID	   Key definition
-- #param @UserUpdate 
-- #param @WorkstationID 
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddUserEnvInstallation
    @UserID			INT,
	@EnvironmentID	NVARCHAR(40),
    @InstallationID NVARCHAR(3),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 
	
	
	INSERT INTO [dbo].UserEnvInstallation 
	([UserID], [EnvironmentID], [InstallationID], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @UserID,
	@EnvironmentID, 
	@InstallationID, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserEnvironment'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUserEnvironment 
END 
GO
-- #desc					   Add UserEnvironment description.
-- #bl_class                   PremierSySBase.UserEnviroment.cs
-- #db_dependencies            N/A
-- #db_references              N/A

-- #param @UserID			   Key definition
-- #param @EnvironmentID	   Key definition
-- #param @UserID 
-- #param @UserUpdate 
-- #param @WorkstationID 
-- #param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddUserEnvironment
    @EnvironmentID	NVARCHAR(40),
    @UserID			INT,
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 
	INSERT INTO [dbo].UserEnvironment ([EnvironmentID], [UserID], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @EnvironmentID,
	@UserID, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserNotification'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUserNotification
END 
GO

-- #desc						  Add User Notification
-- #bl_class                      PremierSySBase.UserNotification.cs
-- #db_dependencies               User
-- #db_references                 N/A

-- #param @UserID                 User ID 
-- #param @NotificationID 		  Notification ID
-- #param @Type               	  Type 
-- #param @Description 			  Description
-- #param @NotificationURL        Notification URL 
-- #param @Status 				  Status
-- #param @Category1              Category1 
-- #param @Category2 			  Category2
-- #param @NotificationData       Notification Data
-- #param @DateCreated			  Date Created 
-- #param @UserUpdate 			  User Update
-- #param @WorkstationID          Workstation ID 
-- #param @DateUpdated 			  Date Updated


CREATE PROCEDURE [dbo].SCSYS_AddUserNotification
    @UserID				INT,
	@NotificationID 	INT output,
    @Type				NVARCHAR(10),
    @Description		NVARCHAR(1024),
	@NotificationURL	NVARCHAR(1024),
	@Status				NVARCHAR(2),
	@Category1			NVARCHAR(40),
	@Category2			NVARCHAR(40),
	@NotificationData	NVARCHAR(MAX),
	@DateCreated		DATETIME2,
	@UserUpdate			NVARCHAR(128),
	@WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
AS 	
	INSERT INTO [dbo].UserNotification ([UserID], [Type], [Description], [NotificationURL], [Status], [Category1], [Category2], [NotificationData], [DateCreated], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @UserID, 
	@Type, 
	@Description,
	@NotificationURL,
	@Status,
	@Category1,
	@Category2,
	@NotificationData,
	@DateCreated,
	@UserUpdate,
	@WorkstationID,
	@DateUpdated

	-- Begin Return SELECT <- do not remove
	SET @NotificationID=(SELECT [NotificationID]
	FROM   [dbo].[UserNotification]
	WHERE  [NotificationID] = SCOPE_IDENTITY())	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserPasswordHistory'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUserPasswordHistory
END 
GO


-- #desc					   Add an user password history
-- #bl_class                   Premier.SysBase.UserPasswordHistory.cs
-- #db_dependencies            N/A
-- #db_references              N/A                            

--#param @UserID               Unique User ID required
--#param @SequenceID		   Unique SequenceID required
--#param @UserPassword 			
--#param @DateChanged 
--#param @UserUpdate
--#param @WorkstationID
--#param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddUserPasswordHistory
    @UserID			INT,
    @SequenceID		INT,
    @UserPassword	NVARCHAR(256),
    @DateChanged	DATETIME2,
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	--Resolve max key to use .. First value is 1
	SET  @SequenceID= ISNULL((SELECT MAX(SequenceID) FROM UserPasswordHistory WHERE UserID = @UserID) + 1, 1) 
	
	INSERT INTO [dbo].UserPasswordHistory ([UserID], 
	[SequenceID], 
	[UserPassword], 
	[DateChanged], 
	[UserUpdate], 
	[WorkstationID], 
	[DateUpdated])	
	SELECT @UserID, 
	@SequenceID, 
	@UserPassword, 
	@DateChanged, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserPasswordResetToken'))
	BEGIN
		DROP  Procedure  [dbo].SCSYS_AddUserPasswordResetToken
	END

GO

-- #desc					Add  User Password Reset Token
-- #bl_class				Premier.Security.UserPasswordResetToken.cs

-- #param @TokenID			Token UniqueID
-- #param @InstallationId	InstallationID
-- #param @UserID			SC User Requested the token
-- #param @WebAccountID     Web Account ID related to the user
-- #param @TokenStatus		Token Status
-- #param @DateCreated
-- #param @TimeCreate
-- #param @UserUpdate
-- #param @LastDateUpdated
-- #param @LastTimeUpdated

CREATE Procedure [dbo].SCSYS_AddUserPasswordResetToken
(
	@TokenID    NVARCHAR(64),
	@InstallationId NVARCHAR(3),
	@UserID decimal(18, 0),
	@WebAccountID decimal(18, 0),
	@TokenStatus nvarchar(2),
	@DateCreated decimal(18, 0),
	@TimeCreated decimal(18, 0),
	@UserUpdate NVARCHAR(30),
	@LastDateUpdated decimal(18, 0),
	@LastTimeUpdated decimal(18, 0) 
)
AS
	INSERT INTO UserPasswordResetTokens
	(
		TokenID,
		InstallationId,
		UserID,
		WebAccountID,
		TokenStatus,
		DateCreated,
		TimeCreated,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated
	)
	VALUES
	(
		@TokenID,
		@InstallationId,
		@UserID,
		@WebAccountID,
		@TokenStatus,
		@DateCreated,
		@TimeCreated,
		@UserUpdate,
		@LastDateUpdated,
		@LastTimeUpdated
	)
		
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserQuickLink'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUserQuickLink 
END 
GO
-- #desc                                    Add User Quick Link.
-- #bl_class                                Premier.SysBase.UserQuickLink.cs
-- #db_dependencies                         N/A
-- #db_references                           N/A

--#param @UserID              				User ID key definition required
--#param @QuickLinkUniqueID   				QuickLinkUniqueID key definition  required
--#param @QuickLinkType						Type of Environment  
--#param QuickLinkUrl		   
--#param UserUpdate
--#param WorkstationID
--#param DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddUserQuickLink
	@UserID				INT,
    @QuickLinkUniqueID	INT output,
    @QuickLinkType		NVARCHAR(20),
    @QuickLinkUrl		NVARCHAR(1024),
	@Description		NVARCHAR(1024),
	@QuickLinkArea		NVARCHAR(20),
    @UserUpdate			NVARCHAR(128),
    @WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
AS 

	--Resolve max key to use .. First value is 1
	SET  @QuickLinkUniqueID= ISNULL((SELECT MAX(QuickLinkUniqueID) FROM UserQuickLink WHERE UserID = @UserID) + 1, 1) 
	
	INSERT INTO [dbo].UserQuickLink ([UserID], 
	[QuickLinkUniqueID], 
	[QuickLinkType],
	[QuickLinkUrl], 
	[Description],
	[QuickLinkArea],
	[UserUpdate], 
	[WorkstationID], 
	[DateUpdated])
	SELECT @UserID, @QuickLinkUniqueID,@QuickLinkType, @QuickLinkUrl, @Description, @QuickLinkArea,  @UserUpdate, @WorkstationID, @DateUpdated
GO	


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_AddUserRole'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_AddUserRole 
END 
GO
-- #desc                Add UserRole description.
-- #bl_class            PremierSySBase.UserRole.cs
-- #db_dependencies		N/A
-- #db_references		N/A

--#param @UserID		Key definition
--#param @RoleID		Key definition
--#param @UserUpdate 
--#param @WorkstationID 
--#param @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_AddUserRole
    @UserID			INT,
    @RoleID			NVARCHAR(40),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 
	
	INSERT INTO [dbo].UserRole ([UserID], [RoleID], [UserUpdate], [WorkstationID], [DateUpdated])
	SELECT @UserID, 
	@RoleID, 
	@UserUpdate, 
	@WorkstationID, 
	@DateUpdated
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DatabaseTuning'))
	BEGIN
		DROP  Procedure  [dbo].SCSYS_DatabaseTuning
	END

GO

-- #desc							SQL Server Maintenance Database index and statistics for SmarterCommerceSYSDB
-- #bl_class						N/A
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @pBD						Data Base name
-- #param @IndexesFragmentation		Flag to defrag indexes Y / N
-- #param @UpdateStatistics			Flag to update statistics Y / N

CREATE PROCEDURE [dbo].SCSYS_DatabaseTuning 
(
	@pBD NVARCHAR(50),
	@IndexesFragmentation NVARCHAR(10),
	@UpdateStatistics NVARCHAR(256)
)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @vSQL NVARCHAR(MAX)
	DECLARE @vSchem NVARCHAR(256)
	DECLARE @vTabl NVARCHAR(256)
	DECLARE @vIndx NVARCHAR(256)
	DECLARE @Fragmentation FLOAT
	DECLARE @vPages INT
	DECLARE @Error INT
	DECLARE @COUNTID INT

	SET @Error= 0 

	IF IS_SRVROLEMEMBER('sysadmin') = 0
	BEGIN
		RAISERROR('You need to be a member of the SysAdmin server role to install the solution.',16,1)
		SET @Error = @@ERROR
	END	


	IF @Error = 0 
 
	IF @IndexesFragmentation = 'Y'
	BEGIN
		CREATE TABLE #TDefragIndices
		(
			COUNTID		INT IDENTITY(1,1),
			Schem		NVARCHAR(256),
			Tabl		NVARCHAR(256),
			Indx		NVARCHAR(256),
			Fragmentation	FLOAT,
			Pages		INT
		)

		SET @vSQL =	'INSERT INTO #TDefragIndices --DECLARE CurIndexes CURSOR FAST_FORWARD for
					SELECT 
						ss.name as Tabl,
						so.name ,
						si.name as Indx,
						dt.avg_fragmentation_in_percent ,
						dt.page_count as Pages
					FROM
						(
						SELECT
							object_id,
							index_id,
							avg_fragmentation_in_percent,
							avg_page_space_used_in_percent,
							page_count
						FROM
							sys.dm_db_index_physical_stats (DB_ID(''' + @pBD + '''), NULL, NULL, NULL, NULL)
						WHERE
							index_id <> 0
							AND index_level = 0
							AND page_count > 30
							AND avg_fragmentation_in_percent > 5
						) as dt
					INNER JOIN '
						+ @pBD + '.sys.indexes si ON si.object_id = dt.object_id
						AND si.index_id = dt.index_id
					INNER JOIN '
					+ @pBD + '.sys.objects so ON so.object_id = dt.object_id
					INNER JOIN '
					+ @pBD + '.sys.schemas ss ON ss.schema_id = so.schema_id
					ORDER BY
						Tabl,
						Indx'

		EXECUTE sp_executesql @vSQL

		SELECT @COUNTID = 1

		WHILE @CountID <= (SELECT COUNT(1)  FROM #TDefragIndices)
		BEGIN
		SELECT @Fragmentation = Fragmentation, @vIndx = Indx, @vSchem = Schem, @vTabl = Tabl, @vPages = Pages  FROM #TDefragIndices WHERE COUNTID = @COUNTID
			IF (@vPages < 100000) 
			BEGIN
				IF @Fragmentation < 20
				BEGIN
					SET @vSQL = 'ALTER INDEX "' + @vIndx +  '" ON ' + @pBD + '.' + @vSchem + '."' + @vTabl + '" REORGANIZE'
				END
				ELSE
					SET @vSQL = 'ALTER INDEX "' + @vIndx +  '" ON ' + @pBD + '.' + @vSchem + '."' + @vTabl + '" REBUILD'
			
				EXECUTE sp_executesql @vSQL
				SET @CountID = @CountID+1
			END
		END

		IF (@@ERROR = 0) 
			SELECT 'Indexes have been updated successfully'
		ELSE 
			SELECT 'Indexes update process has failed'	

		DROP TABLE #TDefragIndices
	END
	IF @UpdateStatistics = 'Y'
	BEGIN
		EXEC sp_updatestats;

		SELECT 'Statistics have been updated successfully'
	END

	SET NOCOUNT OFF

END

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelEnvironment'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelEnvironment
END 
GO
-- #desc							  Delete Environment
-- #bl_class                          PremierSySBase.Environment.cs
-- #db_dependencies                   SCSYS_DelEnvironmentInstance, SCSYS_DelEnvironmentConfig,SCSYS_DelUserEnvironment,SCSYS_DelUserEnvInstallation
-- #db_references                     N/A

-- #param @EnvironmentID key definition


CREATE PROCEDURE [dbo].SCSYS_DelEnvironment
    @EnvironmentID NVARCHAR(40)
AS 
	SET XACT_ABORT ON
	
	BEGIN TRAN
	
	--Delete Children
	EXEC [dbo].SCSYS_DelEnvironmentInstance @EnvironmentID
	EXEC [dbo].SCSYS_DelEnvironmentConfig @EnvironmentID
	--Relationships to this environment only
	EXEC [dbo].SCSYS_DelUserEnvironment NULL, @EnvironmentID  
	EXEC [dbo].SCSYS_DelUserEnvInstallation NULL, @EnvironmentID, NULL

	DELETE
	FROM   [dbo].Environment
	WHERE  [EnvironmentID] = @EnvironmentID
	
	COMMIT TRAN
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelEnvironmentInstanceConfigs'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelEnvironmentInstanceConfigs
END 
GO
-- #desc                          Delete EnvironmentConfigs of all Instances
-- #bl_class                      N/A
-- #db_dependencies               N/A
-- #db_references                 N/A

-- #param @EnvironmentID	      Key definition
-- #param @InstanceID			  Key definition
-- #param @ConfKey				  Key definition


CREATE PROCEDURE [dbo].SCSYS_DelEnvironmentInstanceConfigs
    @EnvironmentID	NVARCHAR(40)
AS 
	DELETE
	FROM   [dbo].EnvironmentConfig
	WHERE  [EnvironmentID] = @EnvironmentID
	AND [InstanceID] != 0
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelEnvironmentPackage'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelEnvironmentPackage
END 
GO
-- #desc                        Delete EnvironmentPackage
-- #bl_class                    PremierSySBase.EnvironmentPackage.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @EnvironmentID		Key definition
-- #param @PackageUniqueID		Key definition


CREATE PROCEDURE [dbo].SCSYS_DelEnvironmentPackage
    @EnvironmentID		NVARCHAR(40),
    @PackageUniqueID	UNIQUEIDENTIFIER
AS 
	
	DELETE
	FROM   [dbo].EnvironmentPackage
	WHERE  [EnvironmentID] = @EnvironmentID
	       AND [PackageUniqueID] = @PackageUniqueID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelMenuSearchIndex'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelMenuSearchIndex 
END 
GO

-- #desc                       Delete MenuSearchIndex
-- #bl_class                   PremierSySBase.MenuSearchIndex.cs
-- #db_dependencies            N/A
-- #db_references              SCSYS_DelMenuSearchIndexLang

-- #param @ItemUniqueID		   Key definition


CREATE PROCEDURE [dbo].SCSYS_DelMenuSearchIndex 
    @ItemUniqueID BIGINT
AS 
	SET XACT_ABORT ON
		
	BEGIN TRAN

	EXEC [dbo].SCSYS_DelMenuSearchIndexLang @ItemUniqueID, NULL

	DELETE
	FROM   [dbo].MenuSearchIndex
	WHERE  [ItemUniqueID] = @ItemUniqueID

	COMMIT TRAN
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelMessageGlossary'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelMessageGlossary
END 
GO

-- #desc                         Delete a message glossary
-- #bl_class                     PremierSySBase.SystemMessage.cs
-- #db_dependencies              SCSYS_DelMessageGlossaryLang
-- #db_references                N/A

-- #param @MessageKey            Message key required

CREATE PROCEDURE [dbo].SCSYS_DelMessageGlossary
    @MessageKey NVARCHAR(40)
AS 

	SET XACT_ABORT ON
		
	BEGIN TRAN

	EXEC [dbo].SCSYS_DelMessageGlossaryLang @MessageKey, NULL

	DELETE
	FROM   [dbo].MessageGlossary
	WHERE  [MessageKey] = @MessageKey

	COMMIT TRAN

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelRole'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelRole
END 
GO
-- #desc                      Delete Role
-- #bl_class                  PremierSySBase.Role.cs
-- #db_dependencies           SCSYS_DelRolePermission, SCSYS_DelUserRole
-- #db_references             N/A

-- #param @RoleID			  Key definition


CREATE PROCEDURE [dbo].SCSYS_DelRole
    @RoleID NVARCHAR(40)
AS 
	SET XACT_ABORT ON
		
	BEGIN TRAN
	
	--Delete Children Entities
	EXEC [dbo].SCSYS_DelRolePermission @RoleID, NULL
	EXEC [dbo].SCSYS_DelUserRole NULL, @RoleID

	DELETE
	FROM   [dbo].[Role]
	WHERE  [RoleID] = @RoleID
	
	COMMIT TRAN
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUser'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_DelUser
END 
GO
-- #desc                             Delete User
-- #bl_class                         PremierSySBase.User.cs
-- #db_dependencies                  SCSYS_DelUserRole, SCSYS_DelUserEnvironment, SCSYS_DelUserEnvInstallation, SCSYS_DelUserQuickLink, SCSYS_DelUserPasswordHistory
-- #db_references                    N/A

-- #param @UserID					 Key definition


CREATE PROCEDURE [dbo].SCSYS_DelUser
    @UserID INT
AS 

	SET XACT_ABORT ON
	
	BEGIN TRAN
	
	EXEC [dbo].SCSYS_DelUserRole @UserID, NULL
	EXEC [dbo].SCSYS_DelUserEnvironment @UserID, NULL
	EXEC [dbo].SCSYS_DelUserEnvInstallation @UserID, NULL
	EXEC [dbo].SCSYS_DelUserQuickLink @UserID, NULL
	EXEC [dbo].SCSYS_DelUserPasswordHistory @UserID
	EXEC [dbo].SCSYS_DelUserDevicePreference 'U', @UserID, '*'
	EXEC [dbo].SCSYS_DelUserNotification @UserID, NULL
	
	DELETE
	FROM   [dbo].[User]
	WHERE  [UserID] = @UserID
	
	COMMIT TRAN
	
GO

  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_DelUserPasswordResetToken'))
	BEGIN
		DROP  Procedure  [dbo].SCSYS_DelUserPasswordResetToken
	END

GO

-- #desc						Delete an User Password Reset Token
-- #bl_class					Premier.Security.UserPasswordResetToken.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @TokenID				Token UniqueID


CREATE Procedure [dbo].SCSYS_DelUserPasswordResetToken
(
	@TokenID    NVARCHAR(64)
)
AS
	
	DELETE UserPasswordResetTokens
	WHERE TokenID =	@TokenID
		
GO



IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_ExcChangeUserPassword'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_ExcChangeUserPassword 
END 
GO

-- #desc                                Update User
-- #bl_class                            Premier.SysBase.User.cs
-- #db_dependencies                     N/A
-- #db_references                       N/A

-- #param @UserID					   User ID required
-- #param @UserPassword                User Password 
-- #param @LastPasswordChanged         Last Password Changed


CREATE PROCEDURE [dbo].SCSYS_ExcChangeUserPassword
(
	@UserID					INT,
	@UserPassword			NVARCHAR(256),
	@LastPasswordChanged	DATETIME2
)	
AS

	UPDATE 
		[dbo].[User]
	SET
		[UserPassword] = @UserPassword,
		[LastPasswordChanged] = @LastPasswordChanged,
		[ChangePassNxtLogin] = 'N'
	WHERE 
		[UserID] = @UserID
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_ExcCheckEmailExist'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_ExcCheckEmailExist
END 
GO

-- #desc					   Validate if the email exists
-- #bl_class                   Premier.SysBase.User.cs
-- #db_dependencies            N/A
-- #db_references              N/A

-- #param @EmailAddress        Email Address


CREATE PROCEDURE [dbo].SCSYS_ExcCheckEmailExist
    @EmailAddress NVARCHAR(256)
AS 
	SELECT
	UserID,
	UserName
FROM
	[dbo].[User]
WHERE
	EmailAddress = @EmailAddress
	GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_ExcCheckLastUserAdmin'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_ExcCheckLastUserAdmin 
END 
GO

-- #desc								Check Last User Admin
-- #bl_class							Premier.SysBase.User.cs
-- #db_dependencies						N/A
-- #db_references						N/A

-- #param @UserID						User ID required
-- #param @UserPassword					User Password 
-- #param @LastPasswordChanged			Last Password Changed

CREATE PROCEDURE [dbo].SCSYS_ExcCheckLastUserAdmin
(
	@UserID			DECIMAL,
	@IsLastAdmin	NVARCHAR(1) OUTPUT
)	
AS
	DECLARE @CountUserAdmin INT
	
	BEGIN 

	SET @IsLastAdmin = 'N'
	SELECT @CountUserAdmin = COUNT(*) FROM [dbo].UserRole WHERE [RoleID] in (Select [RoleID] from [dbo].RolePermission where [PermissionId] = 'SYS01')

	IF(@CountUserAdmin = 1)
	BEGIN
		SELECT @CountUserAdmin = COUNT(*) FROM [dbo].UserRole WHERE [RoleID] in (Select [RoleID] from [dbo].RolePermission where [PermissionId] = 'SYS01') AND [UserId] = @UserID
		
		IF(@CountUserAdmin > 0)
		BEGIN 
			SET @IsLastAdmin = 'Y'
		END
	END

	END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_ExcDelSecurityAudit'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_ExcDelSecurityAudit 
END 
GO

-- #desc							Delete Security Audit
-- #bl_class                        Premier.SysBase.SecurityAuditList.cs
-- #db_dependencies                 N/A
-- #db_references                   N/A

-- #param @Days						Days

CREATE PROCEDURE [dbo].SCSYS_ExcDelSecurityAudit
(
	@Days	DECIMAL
)	
AS	
	DELETE 
	FROM [dbo].[SecurityAudit]
	WHERE (@Days = 0 OR ActionDateTime < DATEADD(day, -@Days, GETDATE()))		
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_ExcValidatePasswordHistory'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_ExcValidatePasswordHistory
END 
GO

-- #desc						Get an user password history Count
-- #bl_class					Premier.SysBase.UserPasswordHistory.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @UserID				Unique User ID required
-- #param @SequenceID			Unique SequenceID required

CREATE PROCEDURE [dbo].SCSYS_ExcValidatePasswordHistory
    @UserID INT,
    @PasswordCount INT
AS 

	SELECT  TOP (@PasswordCount) 
		UserID,
		SequenceID,
		UserPassword
	FROM UserPasswordHistory 
	WHERE UserID = @UserID 
	ORDER BY SequenceID DESC
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetDefaultData'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetDefaultData
END 
GO

-- #desc                        Get an Default Data.
-- #bl_class                    Premier.SysBase.SystemDefaultData.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @TargetSystem         Target System required
-- #param @TableName            Table Name required

CREATE PROCEDURE [dbo].SCSYS_GetDefaultData 
    @TargetSystem	NVARCHAR(20),
    @TableName		NVARCHAR(128)
AS 
	SELECT [TargetSystem]
	,[TableName]
	,[TableDesc]
	,[OperationData]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated] 
	
	FROM   [dbo].DefaultData
	WHERE  TargetSystem = @TargetSystem 
	      AND TableName = @TableName
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetDeployPackage'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetDeployPackage 
END 
GO

-- #desc                            Get an Deploy Package.
-- #bl_class                        N/A
-- #db_dependencies                 N/A
-- #db_references                   N/A

-- #param @PackageUniqueID          Unique Package required

CREATE PROCEDURE [dbo].SCSYS_GetDeployPackage
	@PackageUniqueID UNIQUEIDENTIFIER

AS 
	SELECT [PackageUniqueID]
	,[PackageType]
	,[PackageDesc]
	,[Version]
	,[GenerationDate]
	,[MinRequiredVer]
	,[PackageBody]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated]
	
	FROM   [dbo].DeployPackage
	WHERE  PackageUniqueID = @PackageUniqueID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetEnvironment'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetEnvironment
END 
GO

-- #desc                        Get an Environment
-- #bl_class                    Premier.SysBase.DeployPackage.cs
-- #db_dependencies             SCSYS_GetEnvironmentConfigsNone, SCSYS_GetEnvironmentInstances
-- #db_references               N/A 

-- #param @EnvironmentID        Unique Envoironment ID required

CREATE PROCEDURE [dbo].SCSYS_GetEnvironment
    @EnvironmentID NVARCHAR(40)
AS 	

	SELECT [EnvironmentID]
	,[EnvDesc]
	,[Version]
	,[ConfigByInstance]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated] 
	
	FROM   [dbo].Environment 
	WHERE  EnvironmentID = @EnvironmentID

	EXEC [dbo].SCSYS_GetEnvironmentConfigs @EnvironmentID
	EXEC [dbo].SCSYS_GetEnvironmentInstances @EnvironmentID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetEnvironmentConfigList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetEnvironmentConfigList 
END 
GO

-- #desc                        Get an Envoironment Configs.
-- #bl_class                    Premier.SysBase.EnvironmentConfigs.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @EnvironmentID        Unique Environment required
-- #param @InstanceID           InstanceID required
-- #param @ConfKey              ConfKey required


CREATE PROCEDURE [dbo].SCSYS_GetEnvironmentConfigList
    @EnvironmentID		NVARCHAR(40),
	@InstanceID			INT = 0

AS 	
	IF(@InstanceID = -1)
	 SET @InstanceID = (SELECT MAX(InstanceID) from [dbo].EnvironmentConfig WHERE EnvironmentID = @EnvironmentID)

	SELECT [EnvironmentID]
	,[InstanceID]
	,[ConfKey]
	,[ConfType]
	,[ConfVal]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated]
	 
	FROM   [dbo].EnvironmentConfig 
	WHERE  EnvironmentID = @EnvironmentID
	AND InstanceID = @InstanceID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetEnvironmentList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetEnvironmentList
END 
GO

-- #desc                        Get an Environment List.
-- #bl_class                    Premier.SysBase.EnvironmentList.cs
-- #db_dependencies             N/A
-- #db_references				N/A

-- #param @EnvironmentID        Environment ID required
-- #param @EnvDesc              Env Desc required

CREATE PROCEDURE [dbo].SCSYS_GetEnvironmentList

AS 
	SELECT 
		ENV.[EnvironmentID]
		,ENV.[EnvDesc]
		,ENV.[Version]
		,ENV.[ConfigByInstance]
		,(SELECT TOP 1 [UrlPath] FROM [dbo].EnvironmentInstance WHERE [EnvironmentID] = ENV.EnvironmentID ORDER BY SequenceID ASC) AS [UrlPath]
	FROM  [dbo].Environment AS ENV
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetEnvironmentPackages'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetEnvironmentPackages
END 
GO

-- #desc                        Get an Environment Packages.
-- #bl_class                    N/A
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @EnvironmentID        Environment ID System required
-- #param @PackageUniqueID      PackageUnique ID required

CREATE PROCEDURE [dbo].SCSYS_GetEnvironmentPackages
    @EnvironmentID NVARCHAR(40)
AS 

	SELECT [EnvironmentID]
	,[PackageUniqueID]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated]
	
	FROM   [dbo].EnvironmentPackage 
	WHERE  EnvironmentID = @EnvironmentID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetEnvironmentUserList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetEnvironmentUserList
END 
GO

-- #desc                        Get an Environment User List.
-- #bl_class                    Premier.SysBase.EnvironmentUserList.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @EnvironmentID        Environment ID required

CREATE PROCEDURE [dbo].SCSYS_GetEnvironmentUserList
    @EnvironmentID NVARCHAR(40)
AS 
	SELECT USRENV.EnvironmentID
	,ENV.EnvDesc
	,USRENV.UserID
	,USR.UserName 
	,USR.MailingName 
	,USR.EmailAddress 
	,USR.AccountDisable
	
	FROM   [dbo].UserEnvironment USRENV
	INNER JOIN [dbo].Environment ENV
	ON USRENV.EnvironmentID = ENV.EnvironmentID
	INNER JOIN [dbo].[User] USR
	ON USRENV.UserID = USR.UserID
	WHERE  USRENV.EnvironmentID = @EnvironmentID
GO

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetInstallationDelStatInfo'))
	BEGIN
		DROP  Procedure  [dbo].SCSYS_GetInstallationDelStatInfo
	END

GO
-- #desc						Get the row count of installation related tables.
-- #bl_class					Premier.Common.StoreDeleteStatInfo.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @InstallationID		Installation ID.
-- #param @EnvironmentID		Environment ID.

CREATE Procedure [dbo].SCSYS_GetInstallationDelStatInfo
(
	@InstallationID		NVARCHAR(3),	
	@EnvironmentID		NVARCHAR(40) = NULL,
	@UsersByInst		DECIMAL = NULL OUTPUT
)
AS
	SET NOCOUNT ON	
BEGIN
		
	--USERS To Delete
	SET @UsersByInst = (SELECT CAST (COUNT(*)AS NUMERIC(15,0)) FROM [dbo].UserEnvInstallation WHERE [InstallationID] = @InstallationID AND [EnvironmentID] = @EnvironmentID);
	
END;					
		
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMenuSearchIndex'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMenuSearchIndex 
END 
GO

-- #desc                        Get an Menu Search Index.
-- #bl_class                    Premier.SysBase.MenuSearchIndexes.cs
-- #db_dependencies             SCSYS_GetMenuSearchIndexLang
-- #db_references               N/A

-- #param @ItemUniqueID         ItemUnique ID required

CREATE PROCEDURE [dbo].SCSYS_GetMenuSearchIndex
    @ItemUniqueID bigINT
AS 

	SELECT [ItemUniqueID]
	,[ItemType]
	,[ItemKey]
	,[ItemDesc]
	,[ItemURL]
	,[ItemArea]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated] 
	
	FROM   [dbo].MenuSearchIndex 
	WHERE  ItemUniqueID = @ItemUniqueID

	EXEC [dbo].SCSYS_GetMenuSearchIndexLang @ItemUniqueID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMenuSearchIndexes'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMenuSearchIndexes
END 
GO

-- #desc						Get an Menu Search Index.
-- #bl_class                    Premier.SysBase.MenuSearchIndexList.cs
-- #db_dependencies				N/A
-- #db_references               N/A

-- #param @ItemUniqueID         ItemUnique ID required

CREATE PROCEDURE [dbo].SCSYS_GetMenuSearchIndexes

AS 	

	SELECT [ItemUniqueID]
	,[ItemType]
	,[ItemKey]
	,[ItemDesc]
	,[ItemDesc2]
	,[ItemURL]
	,[ItemArea]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated] 
	
	FROM   [dbo].MenuSearchIndex
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMenuSearchIndexList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMenuSearchIndexList
END 
GO

-- #desc						Get MenuSearchIndexList.
-- #bl_class					Premier.SysBase.MenuSearchIndexList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @ItemKey 				Required
-- #param @ItemDesc 
-- #param @ItemURL

CREATE PROCEDURE [dbo].SCSYS_GetMenuSearchIndexList
	@ItemArea		NVARCHAR(30),
	@ItemType		NVARCHAR(20),
	@FilterTerm		NVARCHAR(4000),
	@LangPref		NVARCHAR(4),
	@PageIndex		DECIMAL,
    @PageSize		DECIMAL,
    @TotalRowCount	INT OUTPUT

AS
	-------------------------------------------------------
	-- Define the table to do the filtering and paging
	-------------------------------------------------------
	DECLARE @TBL TABLE
	(
		nID     INT IDENTITY,
		IID		bigINT,
		IType   NVARCHAR(20),
		IKEY	NVARCHAR(128),
		IDESC	NVARCHAR(512),
		IDESC2	NVARCHAR(512),
		IArea	NVARCHAR(30),
		IURL	NVARCHAR(1024)
	)
	DECLARE @LANGPREFTBL TABLE
	(
		ItemUniqueID	bigINT	
	)
	DECLARE @ROWSTART INT
	DECLARE @ROWEND INT
	
	IF @FilterTerm <> '*'
	BEGIN
		
		SET @FilterTerm = REPLACE(@FilterTerm,'.','..');/*Replace special caracters*/
		SET @FilterTerm = LTRIM(RTRIM(REPLACE(@FilterTerm,'-','.-')));/*Replace special caracters*/
		SET @FilterTerm = LTRIM(RTRIM(REPLACE(@FilterTerm,'''','''''')));/*Replace special caracters*/

		--This block is to select the right language table
		IF (@LangPref = 'EN') 
		BEGIN
			INSERT INTO @LANGPREFTBL (ItemUniqueID)
			SELECT ItemUniqueID
			FROM  [dbo].MenuSearchIndex  
			WHERE ItemDesc LIKE '%' + @FilterTerm + '%' OR ItemDesc2 LIKE '%' + @FilterTerm + '%';
		END
		ELSE
		BEGIN
			INSERT INTO @LANGPREFTBL (ItemUniqueID)
			SELECT ItemUniqueID
			FROM [dbo].MenuSearchIndexLang 
			WHERE ItemDesc LIKE '%' + @FilterTerm + '%' OR ItemDesc2 LIKE '%' + @FilterTerm + '%' AND LanguageCode =  @LangPref
		END
		------------

		INSERT INTO @TBL (IID, IType, IKEY, IDESC, IDESC2, IArea, IURL)
		SELECT	
			MS.ItemUniqueID,
			MS.ItemType,
			MS.ItemKey,
			ISNULL(MSLangs.ItemDesc, MS.ItemDesc),
			ISNULL(MSLangs.ItemDesc2, MS.ItemDesc2),
			MS.ItemArea,
			MS.ItemURL
			FROM
			(SELECT DISTINCT ItemUniqueID FROM  @LANGPREFTBL) FinalResult
			INNER JOIN [dbo].MenuSearchIndex AS MS 
					ON FinalResult.ItemUniqueID = MS.ItemUniqueID AND 
						(@ItemType IS NULL OR @ItemType = MS.ItemType) AND
						(@ItemArea IS NULL OR CHARINDEX(@ItemArea, MS.ItemArea) > 0)
			LEFT OUTER JOIN [dbo].MenuSearchIndexLang AS MSLangs
					ON MS.ItemUniqueID = MSLangs.ItemUniqueID
					AND MSLangs.LanguageCode =  @LangPref 
		END
	ELSE
	BEGIN 
		INSERT INTO @TBL (IID, IType, IKEY, IDESC, IDESC2, IArea, IURL)
		SELECT	
			MS.ItemUniqueID,
			MS.ItemType,
			MS.ItemKey,
			ISNULL(MSLangs.ItemDesc, MS.ItemDesc),
			ISNULL(MSLangs.ItemDesc2, MS.ItemDesc2),
			MS.ItemArea,
			MS.ItemURL
   		FROM	
   			[dbo].MenuSearchIndex AS MS  --Menu Search Master
   			LEFT JOIN [dbo].MenuSearchIndexLang MSLangs --Menu Search Language Master
				ON	MSLangs.ItemUniqueID = MS.ItemUniqueID 
				AND	MSLangs.LanguageCode = @LangPref --Languange filter
		WHERE 
			(@ItemType IS NULL OR @ItemType = MS.ItemType) AND 
			(@ItemArea IS NULL OR CHARINDEX(@ItemArea, MS.ItemArea) > 0)
	END
		
	-------------------------------------------------------
	-- Obtain the total count of the result
	-------------------------------------------------------
	SELECT @TotalRowCount = COUNT(*)
	  FROM @TBL

	-------------------------------------------------------
	-- Validate if paging is not required
	-------------------------------------------------------
	IF(@PageIndex = 0 OR @PageSize = 0)
	BEGIN
		-------------------------------------------------------
		-- Set the first row to be selected
		-------------------------------------------------------
		SET @ROWSTART = 1
		-------------------------------------------------------
		-- Set the last row to be selected
		-------------------------------------------------------
		SET @ROWEND = @TotalRowCount
	END
	ELSE
	BEGIN
		-------------------------------------------------------
		-- Set the first row to be selected
		-------------------------------------------------------
		SET @ROWSTART = (@PageSize * @PageIndex) - @PageSize + 1
		-------------------------------------------------------
		-- Set the last row to be selected
		-------------------------------------------------------
		SET @ROWEND = @PageIndex * @PageSize	
	END

	-------------------------------------------------------
	-- SELECT the rows from temporary table betwen the
	-- range of @ROWSTART ans @ROWEND
	-------------------------------------------------------
	SELECT 
		IID AS ItemUniqueID,
		IType AS ItemType,
		IKEY AS ItemKey,
		IDESC AS ItemDesc,
		IDESC2 AS ItemDesc2,
		IArea AS ItemArea,
		IURL AS ItemURL
	FROM @TBL
	WHERE nID BETWEEN  @ROWSTART AND @ROWEND

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMessageGlossary'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMessageGlossary
END 
GO

-- #desc							Get Message Golassary.
-- #bl_class						Premier.Common.SystemMessage.cs
-- #db_dependencies					SCSYS_GetMessageGlossaryLangs
-- #db_references					N/A

-- #param @MessageKey				Message key required

CREATE PROCEDURE [dbo].SCSYS_GetMessageGlossary
    @MessageKey NVARCHAR(40)
AS 
	
	SELECT [MessageKey], [MessageDesc], [MessageType], [MessageLevel], [UserUpdate], [WorkstationID], [DateUpdated] 
	FROM   [dbo].MessageGlossary 
	WHERE  ([MessageKey] = @MessageKey OR @MessageKey IS NULL) 

	EXEC [dbo].SCSYS_GetMessageGlossaryLangs @MessageKey
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMessageGlossaryInfo'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMessageGlossaryInfo
END 
GO

-- #desc							Update Message Glossary.
-- #bl_class						Premier.Common.SystemMessageInfo.cs
-- #db_dependencies					N/A
-- #db_references					N/A

--#param  @MessageKey				Message key required
--#param  @LanguageCode

CREATE Procedure [dbo].SCSYS_GetMessageGlossaryInfo
	@MessageKey		NVARCHAR(40),
	@LanguageCode	NVARCHAR(4)
AS

	SET NOCOUNT ON

    SELECT	
		A.MessageKey,
		A.MessageDesc,	
		A.MessageLevel,
		A.MessageType
   	FROM	
   		MessageGlossary A 
   	LEFT JOIN MessageGlossaryLang B -- Message Language Master
		ON	A.Messagekey = B.MessageKey
		AND B.LanguageCode = @LanguageCode
	WHERE   
		A.MessageKey = @MessageKey
		
GO
	
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetMessageGlossaryList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetMessageGlossaryList 
END 
GO


-- #desc                        Get a message glossary list.
-- #bl_class                    Premier.Common.SystemMessageList.cs
-- #db_dependencies             N/A
-- #db_references               N/A

--#param  @MessageKey           Message key required
--#param @MessageDesc 			Message description required
--#param @MessageLevel			Message level 
--#param @LanguageCode
--#param @PageIndex
--#param @PageSize
--#param @TotalRowCount



CREATE Procedure [dbo].SCSYS_GetMessageGlossaryList
	@MessageKey		NVARCHAR(40),
	@MessageDesc	NVARCHAR(512),
	@MessageLevel	NVARCHAR(20),
	@LanguageCode	NVARCHAR(4),
	@PageIndex		DECIMAL,
    @PageSize		DECIMAL,
    @TotalRowCount	INT OUTPUT
AS
	-------------------------------------------------------
	-- Define the table to do the filtering and paging
	-------------------------------------------------------    
	DECLARE @TBL TABLE
	(
		nID  	INT IDENTITY,
		MKEY	NVARCHAR(40),
		MDESC	NVARCHAR(512), 
		MLEVEL	NVARCHAR(20),
		MTYPE	NVARCHAR(20) 		
	)
	DECLARE @ROWSTART INT
	DECLARE @ROWEND INT

	INSERT INTO @TBL (MKEY,MDESC,MLEVEL,MTYPE)
    SELECT	
		MSHED.MessageKey,
		ISNULL(MSHEDLNG.MessageDesc,MSHED.MessageDesc),
		MSHED.MessageLevel,
		MSHED.MessageType
   	FROM	
   	
   		[dbo].MessageGlossary MSHED /*Message Master*/ 
   		LEFT JOIN [dbo].MessageGlossaryLang MSHEDLNG -- Message Language Master
			ON	MSHEDLNG.MessageKey = MSHED.MessageKey 
			AND	MSHEDLNG.LanguageCode = @LanguageCode --Languange filter        			
    WHERE   
		(@Messagekey = '*' OR MSHED.MessageKey like '%' + @MessageKey + '%') -- Message Id filter		
		AND     
		(@MessageDesc = '*' OR MSHED.MessageDesc like '%' + @MessageDesc + '%')  -- Message Description Filter
		AND     
		(@MessageLevel = '*' OR MSHED.MessageLevel = @MessageLevel)  -- Message Level Filter

-------------------------------------------------------
	-- Obtain the total count of the result
	-------------------------------------------------------
	SELECT @TotalRowCount = COUNT(*)
	  FROM @TBL

	-------------------------------------------------------
	-- Validate if paging is not required
	-------------------------------------------------------
	IF(@PageIndex = 0 OR @PageSize = 0)
	BEGIN
		-------------------------------------------------------
		-- Set the first row to be selected
		-------------------------------------------------------
		SET @ROWSTART = 1
		-------------------------------------------------------
		-- Set the last row to be selected
		-------------------------------------------------------
		SET @ROWEND = @TotalRowCount
	END
	ELSE
	BEGIN
		-------------------------------------------------------
		-- Set the first row to be selected
		-------------------------------------------------------
		SET @ROWSTART = (@PageSize * @PageIndex) - @PageSize + 1
		-------------------------------------------------------
		-- Set the last row to be selected
		-------------------------------------------------------
		SET @ROWEND = @PageIndex * @PageSize	
	END

	-------------------------------------------------------
	-- SELECT the rows from temporary table betwen the
	-- range of @ROWSTART ans @ROWEND
	-------------------------------------------------------
	SELECT 
		MKEY AS MessageKey,
		MDESC AS MessageDesc,
		MLEVEL AS MessageLevel,
		MTYPE AS MessageType
	FROM @TBL
	WHERE nID BETWEEN  @ROWSTART AND @ROWEND
		
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetPermissionList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetPermissionList
END 
GO

-- #desc                        Get an Permission.
-- #bl_class                    Premier.SysBase.PermissionList.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @PermissionID         Permission ID required


CREATE PROCEDURE [dbo].SCSYS_GetPermissionList
    @PermissionID	NVARCHAR(40) = NULL,
	@PermissionDesc NVARCHAR(256) = NULL,
	@GroupingCat	NVARCHAR(40) = NULL
AS 

	SELECT 
	[PermissionID]
	,[PermissionDesc]
	,[GroupingCat] 
	FROM   [dbo].Permission
	WHERE  
		(@PermissionID IS NULL OR [PermissionID] = @PermissionID) 
		AND	(@PermissionDesc IS NULL OR [PermissionDesc] LIKE '%' + @PermissionDesc + '%') 
		AND	(@GroupingCat IS NULL OR [GroupingCat] LIKE '%' + @GroupingCat + '%')
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetRole'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetRole
END 
GO

-- #desc						Get an Role.
-- #bl_class					Premier.SysBase.Role.cs
-- #db_dependencies             SCSYS_GetRolePermissions
-- #db_references				N/A

-- #param @RoleID               Role ID required

CREATE PROCEDURE [dbo].SCSYS_GetRole 
    @RoleID NVARCHAR(40)
AS 

	SELECT [RoleID]
	,[RoleDesc]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated]
	FROM  [dbo].[Role] 
	WHERE [RoleID] = @RoleID

	EXEC [dbo].SCSYS_GetRolePermissions @RoleID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetRoleList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetRoleList
END 
GO

-- #desc                Get an Role List.
-- #bl_class			Premier.SysBase.RoleList.cs
-- #db_dependencies		N/A
-- #db_references       N/A

-- #param N/A

CREATE PROCEDURE [dbo].SCSYS_GetRoleList
   
AS 
	
	SELECT [RoleID]
	,[RoleDesc]
	,[UserUpdate]
	,[WorkstationID]
	,[DateUpdated] 
	FROM   [dbo].[Role]
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetRolePermissionList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetRolePermissionList
END 
GO

-- #desc                        Get Role Permission List.
-- #bl_class					Premier.SysBase.RolePermissionList.cs
-- #db_dependencies				N/A
-- #db_references               N/A

-- #param @RoleID               Role ID required
-- #param @PermissionID         Permission ID optional


CREATE PROCEDURE [dbo].SCSYS_GetRolePermissionList
    @RoleID			NVARCHAR(40),
	@PermissionID	NVARCHAR(40) = NULL
AS 
	SELECT RO.[RoleID]
	,RO.[PermissionID]
	,PE.[PermissionDesc]
	FROM   [dbo].RolePermission RO
	INNER JOIN [dbo].Permission PE
	ON RO.PermissionID = PE.PermissionID
	WHERE  RO.[RoleID] = @RoleID
	AND (@PermissionID IS NULL OR RO.PermissionID = @PermissionID)
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetSecurityAudit'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetSecurityAudit
END 
GO

-- #desc						Get an Security Audit.
-- #bl_class				    N/A
-- #db_dependencies				N/A
-- #db_references               N/A

-- #param @EntryUniqueID        EntryUnique ID required


CREATE PROCEDURE [dbo].SCSYS_GetSecurityAudit
    @EntryUniqueID bigINT
AS 

	SELECT [EntryUniqueID]
	,[UserID]
	,[UserName]
	,[MachineKey]
	,[AppName]
	,[AppSource]
	,[ActionDesc]
	,[ActionParams]
	,[ActionDateTime]
	,[ActionDetail] 
	
	FROM   [dbo].[SecurityAudit]
	WHERE  [EntryUniqueID] = @EntryUniqueID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetSecurityAuditList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetSecurityAuditList
END 
GO

-- #desc                        Get Security Audit List
-- #bl_class                    Premier.SysBase.SecurityAuditList.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @UserName				UserName
-- #param @ActionParams			ActionParams	
-- #param @ActionDesc			ActionDesc
-- #param @AppName  			AppName 
-- #param @ActionDateTimeFrom   Action Date Time From
-- #param @ActionDateTimeTo	    Action Date Time To
-- #param @PageIndex			Paging - Current page
-- #param @PageSize				Paging - Items to be shown
-- #param @TotalRowCount		Paging - Quantity of rows, result of search filter.


CREATE PROCEDURE [dbo].SCSYS_GetSecurityAuditList
    @UserName			NVARCHAR(128),
	@ActionParams       NVARCHAR(512),
	@ActionDesc         NVARCHAR(512),
	@AppName            NVARCHAR(128),
	@ActionDateTimeFrom DATETIME2(7),
	@ActionDateTimeTo	DATETIME2(7),
	@PageIndex			DECIMAL,
	@PageSize			DECIMAL,
	@TotalRowCount		INT OUTPUT

AS 	
	
	DECLARE @TBL TABLE
	(
		nID				INT IDENTITY,
		EntryUniqueID	bigINT,
		UserID			INT,
		UserName		NVARCHAR(128),
		MachineKey		NVARCHAR(128),
		AppName			NVARCHAR(128),
		AppSource		NVARCHAR(512),
		ActionDesc		NVARCHAR(512),
		ActionParams	NVARCHAR(512),
		ActionDateTime	DATETIME2(7),
		ActionDetail	NVARCHAR(max)
	)

	DECLARE @ROWSTART INT
	DECLARE @ROWEND INT

	DECLARE @dateFrom NVARCHAR(8) = NULL
	DECLARE @dateTo NVARCHAR(8) = NULL
	
	IF( @ActionDateTimeFrom IS NULL) 
	BEGIN
		SET @ActionDateTimeFrom = CAST(-53690 as datetime); --MIN DATE AVAILABLE IN SQL (1753-1-1)
	END

	IF( @ActionDateTimeTo IS NULL) 
	BEGIN
		SET @ActionDateTimeTo = GETDATE();
	END
	
	SET @dateFrom = CONVERT(NVARCHAR(8), @ActionDateTimeFrom, 112) -- Format 112 is ISO yyyymmdd
	SET @dateTo = CONVERT(NVARCHAR(8), @ActionDateTimeTo, 112) -- Format 112 is ISO yyyymmdd
	
	INSERT INTO @TBL (EntryUniqueID, UserID, UserName, MachineKey, AppName, 
	AppSource, ActionDesc, ActionParams, ActionDateTime, ActionDetail)	
	SELECT EntryUniqueID
	,UserID
	,UserName
	,MachineKey
	,AppName
	,AppSource
	,ActionDesc
	,ActionParams
	,ActionDateTime
	,ActionDetail	 
	FROM [dbo].[SecurityAudit] 
	WHERE (@UserName = '*' OR UserName like '%' + @UserName + '%')  
	AND (@ActionDesc = '*' OR ActionDesc like '%' + @ActionDesc + '%')
	AND (@ActionParams = '*' OR ActionParams like '%' + @ActionParams + '%')
	AND (@AppName = '*' OR AppName like '%' + @AppName + '%')
	AND (CONVERT(NVARCHAR(8), ActionDateTime, 112) BETWEEN @dateFrom AND @dateTo)
	ORDER BY ActionDateTime DESC
	-------------------------------------------------------
	-- Obtain the total count of the result
	-------------------------------------------------------
	SELECT @TotalRowCount = COUNT(*)
	FROM @TBL

	-------------------------------------------------------
	-- Validate if paging is not required
	-------------------------------------------------------
	IF(@PageIndex = 0 OR @PageSize = 0)
	BEGIN
		-------------------------------------------------------
		-- Set the first row to be selected
		-------------------------------------------------------
		SET @ROWSTART = 1
		-------------------------------------------------------
		-- Set the last row to be selected
		-------------------------------------------------------
		SET @ROWEND = @TotalRowCount
	END
	ELSE
	BEGIN
		-------------------------------------------------------
		-- Set the first row to be selected
		-------------------------------------------------------
		SET @ROWSTART = (@PageSize * @PageIndex) - @PageSize + 1
		-------------------------------------------------------
		-- Set the last row to be selected
		-------------------------------------------------------
		SET @ROWEND = @PageIndex * @PageSize	
	END
	
	-------------------------------------------------------
	-- SELECT the rows from temporary table betwen the
	-- range of @ROWSTART ans @ROWEND
	-------------------------------------------------------
	SELECT 
		EntryUniqueID,
		UserID,
		UserName,
		MachineKey,
		AppName,
		AppSource,
		ActionDesc,
		ActionParams,
		ActionDateTime,
		ActionDetail
	FROM @TBL
	WHERE nID BETWEEN @ROWSTART AND @ROWEND

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetSystemDefaultDataList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetSystemDefaultDataList
END 
GO

-- #desc							Get an Default Data.
-- #bl_class						Premier.SysBase.SystemDefaultData.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @TargetSystem				Target System required
-- #param @TableName				Table Name required

CREATE PROCEDURE [dbo].SCSYS_GetSystemDefaultDataList 

AS 
	SELECT 
	[TargetSystem]
	,[TableName]
	,[TableDesc]
	,[OperationData]
	FROM   [dbo].DefaultData 

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetSystemSetting'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetSystemSetting
END 
GO

-- #desc                       Get system setting.
-- #bl_class				   Premier.SysBase.SystemSetting.cs
-- #db_dependencies            N/A
-- #db_references              N/A

-- #param @SettingKey		   Key definition, required

CREATE PROCEDURE [dbo].SCSYS_GetSystemSetting
    @SettingKey NVARCHAR(40)
AS 


	SELECT [SettingKey], 
	[SettingDesc], 
	[SettingType], 
	[SettingValue], 
	[UserUpdate], 
	[WorkstationID], 
	[DateUpdated] 
	FROM   [dbo].SystemSetting
	
	WHERE  ([SettingKey] = @SettingKey )
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetSystemSettingInfo'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetSystemSettingInfo 
END 
GO

-- #desc					Get system setting info.
-- #bl_class                Premier.SysBase.SystemSettingInfo.cs
-- #db_dependencies			N/A
-- #db_references           N/A

-- #param @SettingKey		Key definition, required

CREATE PROCEDURE [dbo].SCSYS_GetSystemSettingInfo
    @SettingKey NVARCHAR(40)
AS 
	SELECT [SettingKey], 
	[SettingDesc],  
	[SettingValue]
	FROM   [dbo].SystemSetting 
	
	WHERE  ([SettingKey] = @SettingKey )
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUser'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUser
END 
GO

-- #desc                        Get an User.
-- #bl_class                    Premier.SysBase.User.cs
-- #db_dependencies             SCSYS_GetUserRoles, SCSYS_GetUserEnvironments, SCSYS_GetUserEnvInstallations
-- #db_references               N/A

-- #param UserID               User ID required
-- #param UserName             User Name required


CREATE PROCEDURE [dbo].SCSYS_GetUser
    @UserID		INT = NULL,
	@UserName	NVARCHAR(128) = NULL
AS 
	
	IF @UserID IS NULL AND @UserName IS NOT NULL
	BEGIN
		SELECT @UserID = [UserID] FROM [dbo].[User] WHERE [UserName] = @UserName
	END

	IF @UserID IS NOT NULL
	BEGIN

		SELECT [UserID]
		,[UserName]
		,[UserPassword]
		,[MailingName]
		,[EmailAddress]
		,[AccountDisable]
		,[AccountLocked]
		,[AllowChangePass]
		,[ChangePassNxtLogin]
		,[LastPasswordChanged]
		,[LastAccountLocked]
		,[UserAvatar]
		,[UserUpdate]
		,[WorkstationID]
		,[DateUpdated] 

		FROM   [dbo].[User] 
		WHERE  [UserID] = @UserID 

		EXEC [dbo].SCSYS_GetUserRoles @UserID

		EXEC [dbo].SCSYS_GetUserEnvironments @UserID

		EXEC [dbo].SCSYS_GetUserEnvInstallations @UserID, NULL

	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserDevicePreferences'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserDevicePreferences
END 
GO
-- #desc                        Get User Preferences.
-- #bl_class                    Premier.SysBase.UserDevicePreferences.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param @OwnerType			User or Device
-- #param @OwnerID				UserID or IP

CREATE PROCEDURE [dbo].[SCSYS_GetUserDevicePreferences]
	@OwnerType	NVARCHAR(2),
    @OwnerID	NVARCHAR(30)
AS
	SELECT [OwnerType]
      ,[OwnerID]
      ,[PreferenceKey]
      ,[PreferenceVal]
      ,[UserUpdate]
      ,[WorkstationID]
      ,[DateUpdated]
	FROM [dbo].[UserDevicePreferences]
	WHERE [OwnerType] = @OwnerType AND [OwnerID] = @OwnerID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserInfo'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserInfo
END 
GO

-- #desc					   Get an User Info.
-- #bl_class				   Premier.SysBase.UserInfo.cs
-- #db_dependencies            N/A
-- #db_references              N/A

-- #param UserID              User ID required
-- #param UserName            User Name required

CREATE PROCEDURE [dbo].SCSYS_GetUserInfo
    @UserID		INT = NULL,
	@UserName	NVARCHAR(128) = NULL
AS 

	SELECT [UserID]
	,[UserName]
	,[UserPassword]
	,[MailingName]
	,[EmailAddress]
	,[AccountDisable]
	,[AccountLocked]
	,[AllowChangePass]

	FROM   [dbo].[User] 
	WHERE  [UserID] = @UserID
	OR [UserName] = @UserName
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserList'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserList
END 
GO

-- #desc					Get an User List.
-- #bl_class				Premier.SysBase.UserList.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @EnvironmentID	Key definition
-- #param @InstallationID


CREATE PROCEDURE [dbo].SCSYS_GetUserList
    @EnvironmentID	NVARCHAR(40),
	@InstallationID NVARCHAR(3)
AS

	IF(@EnvironmentID IS NULL OR @EnvironmentID = 'SYSTEM')
		BEGIN
			SELECT DISTINCT
				u.UserID,
				u.UserName,
				u.UserPassword,
				u.MailingName,
				u.EmailAddress,
				u.AccountDisable,
				u.AccountLocked,
				u.AllowChangePass
			FROM
				[dbo].[User] AS u
			ORDER BY u.UserName ASC
		END 
	ELSE IF(@InstallationID IS NULL OR @InstallationID = '***')
		BEGIN
			-- BASE Installation
			SELECT DISTINCT
				u.UserID,
				u.UserName,
				u.UserPassword,
				u.MailingName,
				u.EmailAddress,
				u.AccountDisable,
				u.AccountLocked,
				u.AllowChangePass
			FROM 
				[dbo].[User] AS u
			INNER JOIN [dbo].[UserEnvironment] ue
				ON u.UserID = ue.UserID			
				AND ue.EnvironmentID = @EnvironmentID
			ORDER BY u.UserName ASC
		END
	ELSE 
		BEGIN
			-- POS installation
			SELECT DISTINCT
				u.UserID,
				u.UserName,
				u.UserPassword,
				u.MailingName,
				u.EmailAddress,
				u.AccountDisable,
				u.AccountLocked,
				u.AllowChangePass
			FROM 
				[dbo].[User] AS u
			INNER JOIN [dbo].[UserEnvironment] ue
				ON u.UserID = ue.UserID
				AND ue.EnvironmentID = @EnvironmentID
			INNER JOIN [dbo].[UserEnvInstallation] uei
				ON ue.UserID = uei.UserID
				AND uei.EnvironmentID  = ue.EnvironmentID 
				AND uei.InstallationID = @InstallationID		 
			ORDER BY u.UserName ASC	
		END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserNotification'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserNotification
END 
GO

-- #desc						Get User Notification
-- #bl_class					Premier.SysBase.UserNotification.cs
-- #db_dependencies				User
-- #db_references				N/A

-- #param @UserID				User ID 
-- #param @NotificationID 		Notification ID


CREATE PROCEDURE [dbo].SCSYS_GetUserNotification
    @UserID				INT,
	@NotificationID		INT
AS 

	SELECT [UserID]
	,[NotificationID]
	,[Type]
	,[Description]
	,[NotificationURL]
	,[Status]
	,[Category1] 
	,[Category2] 
	,[NotificationData]
	,[DateCreated]
	,[UserUpdate] 
	,[WorkstationID]
	,[DateUpdated] 
	
	FROM   [dbo].UserNotification 
	WHERE  [UserID] = @UserID AND	
		   [NotificationID] = @NotificationID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserNotifications'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserNotifications
END 
GO

-- #desc					Get User Notifications
-- #bl_class				Premier.SysBase.UserNotifications.cs
-- #db_dependencies			User
-- #db_references           N/A

-- #param @UserID			User ID 


CREATE PROCEDURE [dbo].SCSYS_GetUserNotifications
    @UserID INT
AS 

	SELECT [UserID]
	,[NotificationID]
	,[Type]
	,[Description]
	,[NotificationURL]
	,[Status]
	,[Category1] 
	,[Category2] 
	,[NotificationData]
	,[DateCreated]
	,[UserUpdate] 
	,[WorkstationID]
	,[DateUpdated] 
	
	FROM   [dbo].UserNotification 
	WHERE  [UserID] = @UserID
	ORDER BY DateUpdated DESC
GO

  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserPasswordResetToken'))
	BEGIN
		DROP  Procedure  [dbo].SCSYS_GetUserPasswordResetToken
	END

GO

-- #desc				Get  User Password Reset Token
-- #bl_class			Premier.Security.UserPasswordResetToken.cs
-- #db_dependencies		N/A
-- #db_references		N/A

-- #param @TokenID	    Token UniqueID

CREATE Procedure [dbo].SCSYS_GetUserPasswordResetToken
(
	@TokenID    NVARCHAR(64)
)
AS

	SELECT 
	    TokenID,
		InstallationId,
		UserID,
		WebAccountID,
		TokenStatus,
		DateCreated,
		TimeCreated,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated
	FROM 
		UserPasswordResetTokens
	WHERE
		TokenID = @TokenID

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_GetUserQuickLinks'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_GetUserQuickLinks
END 
GO

-- #desc					Get User Quick Link.
-- #bl_class				Premier.SysBase.UserQuickLink.cs
-- #db_dependencies         N/A
-- #db_references           N/A

-- #param @UserID           User ID key definition required


CREATE PROCEDURE [dbo].SCSYS_GetUserQuickLinks
    @UserID INT
AS 
	SELECT
	[UserID], 
	[QuickLinkUniqueID], 
	[QuickLinkType],
	[QuickLinkUrl], 
	[QuickLinkArea],
	[Description],
	[UserUpdate], 
	[WorkstationID], 
	[DateUpdated] 
	FROM   [dbo].UserQuickLink 
	WHERE  ([UserID] = @UserID )
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_PurgeJobs'))
	BEGIN
		DROP PROCEDURE [dbo].SCSYS_PurgeJobs
	END
GO

-- #desc					Purge jobs by old days.
-- #bl_class				Premier.ManagementConsole.SchedulerPurgeCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @OlderThanInDays  Old Days 

CREATE PROCEDURE [dbo].SCSYS_PurgeJobs
(
	@OlderThanInDays INT
)
AS

	IF @OlderThanInDays < 0
		RETURN

	DECLARE @Date DATETIME2 = GETUTCDATE() - @OlderThanInDays
	DECLARE @DateBinary BINARY(9) = CAST(REVERSE(CAST(@Date AS BINARY(9))) AS BINARY(9))
	DECLARE @days BIGINT = CAST(SUBSTRING(@DateBinary, 1, 3) AS BIGINT)
	DECLARE @time BIGINT = CAST(SUBSTRING(@DateBinary, 4, 5) AS BIGINT)

	DECLARE @OlderThanInTicks BIGINT = @days * 864000000000 + @time

	DELETE J FROM [dbo].SCQRTZ_JOB_DETAILS J
	WHERE NOT EXISTS 
	(
		SELECT 1 FROM [dbo].SCQRTZ_TRIGGERS T
		WHERE T.SCHED_NAME = J.SCHED_NAME
		AND T.JOB_NAME = J.JOB_NAME
		AND T.JOB_GROUP = J.JOB_GROUP
	)
	AND EXISTS
	(
		SELECT 1 FROM [dbo].SCQRTZ_FIRED_TRIGGERS_HIST H
		WHERE H.SCHED_NAME = J.SCHED_NAME
		AND H.JOB_NAME = J.JOB_NAME
		AND H.JOB_GROUP = J.JOB_GROUP
		AND H.FIRED_TIME < @OlderThanInTicks
	)

	DELETE FROM SCQRTZ_FIRED_TRIGGERS_HIST WHERE FIRED_TIME < @OlderThanInTicks

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdDefaultData'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdDefaultData
END 
GO

-- #desc							Update an Default Data.
-- #bl_class						Premier.SysBase.SystemDefaultData.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param TargetSystem             Target System required
-- #param TableName                Table Name required
-- #param TableDesc                Table Desc 
-- #param OperationData            Operation 
-- #param UserUpdate               User Update 
-- #param WorkstationID            Workstation 
-- #param DateUpdated              Date Updated


CREATE PROCEDURE [dbo].SCSYS_UpdDefaultData 
    
	@TargetSystem	NVARCHAR(20),
    @TableName		NVARCHAR(128),
    @TableDesc		NVARCHAR(512),
    @OperationData	NVARCHAR(MAX),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].DefaultData
	SET    [TargetSystem] = @TargetSystem
	     ,    [TableName] = @TableName
	     ,    [TableDesc] = @TableDesc
	     ,[OperationData] = @OperationData
	     ,   [UserUpdate] = @UserUpdate
	     ,[WorkstationID] = @WorkstationID
	     ,  [DateUpdated] = @DateUpdated
	
	WHERE  [TargetSystem] = @TargetSystem
          AND [TableName] = @TableName
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdDeployPackage'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdDeployPackage
END 
GO

-- #desc							Update Deploy Package.
-- #bl_class						N/A
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param PackageUniqueID          Package Unique ID required
-- #param PackageType              Package Type 
-- #param PackageDesc				Package Desc 
-- #param Version                  Version 
-- #param GenerationDate           Generation Date 
-- #param MinRequiredVer           Min Required Ver 
-- #param PackageBody              Package Body 
-- #param UserUpdate               User Update 
-- #param WorkstationID            Work station ID 
-- #param DateUpdated              Date Updated 


CREATE PROCEDURE [dbo].SCSYS_UpdDeployPackage
    @PackageUniqueID	UNIQUEIDENTIFIER,
    @PackageType		NVARCHAR(20),
    @PackageDesc		NVARCHAR(1024),
    @Version			NVARCHAR(40),
    @GenerationDate		DATETIME2,
    @MinRequiredVer		INT,
    @PackageBody		VARBINARY(MAX),
    @UserUpdate			NVARCHAR(128),
    @WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
AS 
	
	UPDATE [dbo].DeployPackage
	SET   [PackageUniqueID] = @PackageUniqueID
	,         [PackageType] = @PackageType
	,         [PackageDesc] = @PackageDesc
	,             [Version] = @Version
	,      [GenerationDate] = @GenerationDate
	,      [MinRequiredVer] = @MinRequiredVer
	,         [PackageBody] = @PackageBody
	,          [UserUpdate] = @UserUpdate
	,       [WorkstationID] = @WorkstationID
	,         [DateUpdated] = @DateUpdated

	WHERE [PackageUniqueID] = @PackageUniqueID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdEnvironment'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdEnvironment 
END 
GO

-- #desc                                Update Environmente.
-- #bl_class                            Premier.SysBase.Environment.cs
-- #db_dependencies                     N/A
-- #db_references						N/A

-- #param EnvironmentID				Environment ID required
-- #param EnvDesc						Env Desc 
-- #param Version						Version 
-- #param ConfigByInstance				ConfigByInstance 
-- #param UserUpdate					User Update 
-- #param WorkstationID				Work station ID 
-- #param DateUpdated					Date Updated 


CREATE PROCEDURE [dbo].SCSYS_UpdEnvironment 
    @EnvironmentID	NVARCHAR(40),
    @EnvDesc		NVARCHAR(256),
    @Version		NVARCHAR(40),
	@ConfigByInstance NVARCHAR(2),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].Environment
	SET   [EnvironmentID] = @EnvironmentID
	,           [EnvDesc] = @EnvDesc
	,           [Version] = @Version
	,	[ConfigByInstance] = @ConfigByInstance
	,        [UserUpdate] = @UserUpdate
	,     [WorkstationID] = @WorkstationID
	,       [DateUpdated] = @DateUpdated

	WHERE [EnvironmentID] = @EnvironmentID
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdEnvironmentConfig'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdEnvironmentConfig
END 
GO

-- #desc                            Update Environment Config.
-- #bl_class						Premier.SysBase.EnvironmentConfig.cs
-- #db_dependencies                 N/A
-- #db_references                   N/A

-- #param EnvironmentID            Environment ID required
-- #param InstanceID				Instance ID
-- #param ConfKey                  Conf Key
-- #param ConfType                 Conf Type 
-- #param ConfVal                  Conf Val  
-- #param UserUpdate               User Update 
-- #param WorkstationID            Work station ID 
-- #param DateUpdated              Date Updated 


CREATE PROCEDURE [dbo].SCSYS_UpdEnvironmentConfig 
    @EnvironmentID	NVARCHAR(40),
	@InstanceID		INT,
    @ConfKey		NVARCHAR(100),
    @ConfType		NVARCHAR(20),
    @ConfVal		NVARCHAR(MAX),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].EnvironmentConfig
	SET    [EnvironmentID] = @EnvironmentID
	,		  [InstanceID] = @InstanceID
	,			 [ConfKey] = @ConfKey
	,			[ConfType] = @ConfType
	,			 [ConfVal] = @ConfVal
	,		  [UserUpdate] = @UserUpdate
	,	   [WorkstationID] = @WorkstationID
	,		 [DateUpdated] = @DateUpdated

	WHERE  [EnvironmentID] = @EnvironmentID
	         AND [ConfKey] = @ConfKey
			 AND [InstanceID] = @InstanceID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdEnvironmentInstance'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdEnvironmentInstance
END
GO

-- #desc                            Update Environment Instance.
-- #bl_class                        Premier.SysBase.EnvironmentInstance.cs
-- #db_dependencies                 N/A
-- #db_references					N/A

-- #param EnvironmentID            Environment ID required
-- #param SequenceID				Sequence ID 
-- #param UrlPath                  Url Path 
-- #param PhysicalPath				Physical Path 
-- #param UserUpdate               User Update 
-- #param WorkstationID            Work station ID 
-- #param DateUpdated				Date Updated 


CREATE PROCEDURE [dbo].SCSYS_UpdEnvironmentInstance
    @EnvironmentID	NVARCHAR(40),
    @SequenceID		INT,
    @UrlPath		NVARCHAR(1024),
    @PhysicalPath	NVARCHAR(1024),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 
	

	UPDATE [dbo].EnvironmentInstance
	SET    [EnvironmentID] = @EnvironmentID
	,         [SequenceID] = @SequenceID
	,            [UrlPath] = @UrlPath
	,       [PhysicalPath] = @PhysicalPath
	,         [UserUpdate] = @UserUpdate
	,      [WorkstationID] = @WorkstationID
	,        [DateUpdated] = @DateUpdated
	
	WHERE  [EnvironmentID] = @EnvironmentID
	      AND [SequenceID] = @SequenceID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdEnvironmentPackage'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdEnvironmentPackage
END
GO

-- #desc								Update Environment Package.
-- #bl_class                            N/A
-- #db_dependencies                     N/A
-- #db_references                       N/A

-- #param EnvironmentID                Environment ID required
-- #param PackageUniqueID              Package Unique ID required
-- #param UserApplied                  User Applied 
-- #param DateApplied					Date Applied 


CREATE PROCEDURE [dbo].SCSYS_UpdEnvironmentPackage 
    @EnvironmentID		NVARCHAR(40),
    @PackageUniqueID	UNIQUEIDENTIFIER,
    @UserUpdate			NVARCHAR(128),
    @DateUpdated		DATETIME2,
	@WorkstationID		NVARCHAR(60)
AS 
	
	UPDATE [dbo].EnvironmentPackage
	SET    [EnvironmentID] = @EnvironmentID
	,	 [PackageUniqueID] = @PackageUniqueID
	,		 [UserUpdate] = @UserUpdate
	,		 [DateUpdated] = @DateUpdated
	,		 [WorkstationID] = @WorkstationID
	
	WHERE  [EnvironmentID] = @EnvironmentID
	 AND [PackageUniqueID] = @PackageUniqueID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdMenuSearchIndex'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdMenuSearchIndex
END
GO

-- #desc                            Update Menu Search Index.
-- #bl_class                        Premier.SysBase.MenuSearchIndex.cs
-- #db_dependencies					N/A
-- #db_references                   N/A

-- #param ItemUniqueID             Item Unique ID required
-- #param ItemType					Item Type 
-- #param ItemKey                  Item Key 
-- #param ItemDesc                 Item Desc 
-- #param ItemDesc2                Item Desc 2
-- #param ItemURL                  Item URL 
-- #param UserUpdate               User Update 
-- #param WorkstationID            Work station ID 
-- #param DateUpdated              Date Updated 


CREATE PROCEDURE [dbo].SCSYS_UpdMenuSearchIndex
    @ItemUniqueID	bigINT,
    @ItemType		NVARCHAR(20),
    @ItemKey		NVARCHAR(128),
    @ItemDesc		NVARCHAR(512),
    @ItemDesc2		NVARCHAR(512),
    @ItemURL		NVARCHAR(1024),
	@ItemArea		NVARCHAR(20),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].MenuSearchIndex
	SET		   [ItemType] = @ItemType
	,			[ItemKey] = @ItemKey
	,		   [ItemDesc] = @ItemDesc
	,		  [ItemDesc2] = @ItemDesc2
	,			[ItemURL] = @ItemURL
	,		   [ItemArea] = @ItemArea
	,		 [UserUpdate] = @UserUpdate
	,	  [WorkstationID] = @WorkstationID
	,	    [DateUpdated] = @DateUpdated
	
	WHERE  [ItemUniqueID] = @ItemUniqueID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdMenuSearchIndexLang'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdMenuSearchIndexLang
END
GO

-- #desc						Update Menu Search lang.
-- #bl_class					Premier.SysBase.MenuSearchIndexLang.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param 
--#param ItemUniqueID			UniqueID key required
--#param ItemDesc 				Item description required
--#param ItemDesc2 			Item description 2
--#param LanguageCode			Language Code 
--#param UserUpdate			Audit Information
--#param WorkstationID	  		Audit information
--#param@DateUpdated 			Audit information
	

CREATE PROCEDURE [dbo].SCSYS_UpdMenuSearchIndexLang
    @ItemUniqueID	bigINT,
    @LanguageCode	NVARCHAR(4),
	@ItemDesc		NVARCHAR(512),
	@ItemDesc2		NVARCHAR(512),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].MenuSearchIndexLang
	SET [LanguageCode] = @LanguageCode,
	[ItemDesc] = @ItemDesc, 
	[ItemDesc2] = @ItemDesc2, 
	[UserUpdate] = @UserUpdate, 
	[WorkstationID] = @WorkstationID,
	[DateUpdated] = @DateUpdated
	
	WHERE  [ItemUniqueID] = @ItemUniqueID
	AND [LanguageCode] = @LanguageCode
	

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdMessageGlossary'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdMessageGlossary
END
GO

-- #desc                        Update Message Glossary.
-- #bl_class                    Premier.SysBase.SystemMessage.cs
-- #db_dependencies             N/A
-- #db_references               N/A

--#param  @MessageKey           Message key required
--#param  @MessageDesc
--#param  @MessageType 
--#param  @MessageLevel
--#param  @UserUpdate
--#param  @WorkstationID
--#param  @DateUpdated


CREATE PROCEDURE [dbo].SCSYS_UpdMessageGlossary 
    @MessageKey		NVARCHAR(40),
    @MessageDesc	NVARCHAR(512),
    @MessageType	NVARCHAR(20),
    @MessageLevel	NVARCHAR(20),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].MessageGlossary
	SET    [MessageKey] = @MessageKey,
	[MessageDesc] = @MessageDesc, 
	[MessageType] = @MessageType, 
	[MessageLevel] = @MessageLevel, 
	[UserUpdate] = @UserUpdate, 
	[WorkstationID] = @WorkstationID,
	[DateUpdated] = @DateUpdated
	WHERE  [MessageKey] = @MessageKey
	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdMessageGlossaryLang'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdMessageGlossaryLang
END
GO

-- #desc						Update message glossary lang.
-- #bl_class					Premier.SysBase.SystemMessageLang.cs
-- #db_dependencies				N/A
-- #db_references				N/A


--#param MessageKey			Message key required
--#param MessageDesc 			Message description required
--#param LanguageCode			Language Code 
--#param UserUpdate			Audit Information
--#param WorkstationID	  		Audit information
--#param DateUpdated 			Audit information
	

CREATE PROCEDURE [dbo].SCSYS_UpdMessageGlossaryLang
    @MessageKey		NVARCHAR(40),
    @LanguageCode	NVARCHAR(4),
    @MessageDesc	NVARCHAR(512),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].MessageGlossaryLang
	SET    [MessageKey] = @MessageKey,
	[LanguageCode] = @LanguageCode, 
	[MessageDesc] = @MessageDesc, 
	[UserUpdate] = @UserUpdate, 
	[WorkstationID] = @WorkstationID,
	[DateUpdated] = @DateUpdated
	
	WHERE  [MessageKey] = @MessageKey
	AND [LanguageCode] = @LanguageCode
	

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdRole'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdRole
END 
GO

-- #desc                            Update Role.
-- #bl_class                        Premier.SysBase.Role.cs
-- #db_dependencies                 N/A
-- #db_references					N/A

-- #param RoleID                   Role ID required
-- #param RoleDesc					Role Desc 
-- #param UserUpdate               User Update 
-- #param WorkstationID            Work station ID 
-- #param DateUpdated              Date Updated 


CREATE PROCEDURE [dbo].SCSYS_UpdRole
    @RoleID			NVARCHAR(40),
    @RoleDesc		NVARCHAR(512),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 
	
	UPDATE [dbo].[Role]
	SET   
		[RoleDesc] = @RoleDesc
		,[UserUpdate] = @UserUpdate
		,[WorkstationID] = @WorkstationID
		,[DateUpdated] = @DateUpdated
	WHERE    
		[RoleID] = @RoleID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdSystemSetting'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdSystemSetting
END
GO

-- #desc								Update an System Setting.
-- #bl_class                            Premier.SysBase.SystemSetting.cs
-- #db_dependencies                     N/A
-- #db_references                       N/A

-- #param SettingKey              		Key definition, required
-- #param SettingDesc 
-- #param SettingType 
-- #param SettingValue 
-- #param UserUpdate 
-- #param WorkstationID 
-- #param DateUpdated


CREATE PROCEDURE [dbo].SCSYS_UpdSystemSetting
    @SettingKey		NVARCHAR(40),
    @SettingDesc	NVARCHAR(1024),
    @SettingType	NVARCHAR(20),
    @SettingValue	NVARCHAR(MAX),
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 

	UPDATE [dbo].SystemSetting
	SET    [SettingKey] = @SettingKey, 
	[SettingDesc] = @SettingDesc, 
	[SettingType] = @SettingType, 
	[SettingValue] = @SettingValue, 
	[UserUpdate] = @UserUpdate, 
	[WorkstationID] = @WorkstationID, 
	[DateUpdated] = @DateUpdated
	WHERE  [SettingKey] = @SettingKey
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdUser'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdUser 
END
GO

-- #desc                            Update User.
-- #bl_class						Premier.SysBase.User.cs
-- #db_dependencies                 N/A
-- #db_references                   N/A

-- #param UserID					User ID required
-- #param UserName                 User Name 
-- #param MailingName              Mailing Name 
-- #param EmailAddress             Email Address 
-- #param AccountDisable           Account Disable 
-- #param AllowChangePass          Allow Change Pass
-- #param ChangePassNxtLogin       Change Pass Nxt Login
-- #param UserAvatar               User Avatar
-- #param UserUpdate               User Update 
-- #param WorkstationID            Work station ID 
-- #param DateUpdated              Date Updated 


CREATE PROCEDURE [dbo].SCSYS_UpdUser
    @UserID				INT,
    @UserName			NVARCHAR(128),
    @MailingName		NVARCHAR(256),
    @EmailAddress		NVARCHAR(256),
    @AccountDisable		NCHAR(1),
	@AccountLocked		NCHAR(1),
    @AllowChangePass	NCHAR(1),
    @ChangePassNxtLogin NCHAR(1),
	@LastAccountLocked	DATETIME2,
    @UserAvatar			VARBINARY(4000),
    @UserUpdate			NVARCHAR(128),
    @WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
AS 
	

	UPDATE [dbo].[User]
	SET          
	            [UserName] = @UserName
	,         [MailingName] = @MailingName
	,        [EmailAddress] = @EmailAddress
	,      [AccountDisable] = @AccountDisable
	,       [AccountLocked] = @AccountLocked
	,     [AllowChangePass] = @AllowChangePass
	,  [ChangePassNxtLogin] = @ChangePassNxtLogin
	,   [LastAccountLocked] = @LastAccountLocked
	,          [UserAvatar] = @UserAvatar
	,          [UserUpdate] = @UserUpdate
	,       [WorkstationID] = @WorkstationID
	,         [DateUpdated] = @DateUpdated
	
	WHERE          [UserID] = @UserID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdUserDevicePreference'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdUserDevicePreference
END 
GO
-- #desc                        Update User Preferences.
-- #bl_class					Premier.SysBase.UserDevicePreference.cs
-- #db_dependencies             N/A
-- #db_references               N/A

-- #param OwnerType			User or Device
-- #param OwnerID				UserID or IP
-- #param PreferenceKey		AWB OR POS Enum String Value
-- #param PreferenceVal		Preference value
-- #param UserUpdate			User that adds the new record
-- #param WorkstationID		Source computer where the change is applied
-- #param DateUpdated			Date of change	


CREATE PROCEDURE [dbo].[SCSYS_UpdUserDevicePreference]
	@OwnerType	NVARCHAR(2),
    @OwnerID	NVARCHAR(30),
    @PreferenceKey	NVARCHAR(30),
    @PreferenceVal	NVARCHAR(MAX),
	@UserUpdate	NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS
	UPDATE [dbo].[UserDevicePreferences]
	   SET [PreferenceVal] = @PreferenceVal 
		  ,[UserUpdate] = @UserUpdate
		  ,[WorkstationID] = @WorkstationID
		  ,[DateUpdated] = @DateUpdated
	 WHERE [OwnerType] = @OwnerType AND	[OwnerID] = @OwnerID AND [PreferenceKey] = @PreferenceKey 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdUserNotification'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdUserNotification
END
GO

-- #desc                        Update User Notification
-- #bl_class                    PremierSySBase.UserNotification.cs
-- #db_dependencies				User
-- #db_references				N/A

-- #param UserID               User ID 
-- #param NotificationID 		Notification ID
-- #param Type               	Type 
-- #param Description 			Description
-- #param NotificationURL      Notification URL 
-- #param Status 				Status
-- #param Category1            Category1 
-- #param Category2 			Category2
-- #param NotificationData     Notification Data 
-- #param UserUpdate 			User Update
-- #param WorkstationID        Workstation ID 
-- #param DateUpdated 			Date Updated


CREATE PROCEDURE [dbo].SCSYS_UpdUserNotification
    @UserID				INT,
    @NotificationID		INT,
    @Type				NVARCHAR(10),
    @Description		NVARCHAR(1024),
	@NotificationURL	NVARCHAR(1024),
	@Status				NVARCHAR(2),
	@Category1			NVARCHAR(40),
	@Category2			NVARCHAR(40),
	@NotificationData	NVARCHAR(max),
	@UserUpdate			NVARCHAR(128),
	@WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
AS 

	UPDATE [dbo].UserNotification
	SET    [Type] = @Type, 
	[Description] = @Description, 
	[NotificationURL] = @NotificationURL,
	[Status] = @Status,
	[Category1] = @Category1, 
	[Category2] = @Category2, 
	[NotificationData] = @NotificationData, 
	[UserUpdate] = @UserUpdate, 
	[WorkstationID] = @WorkstationID, 
	[DateUpdated] = @DateUpdated	
	WHERE  [UserID] = @UserID
	AND [NotificationID] = @NotificationID
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdUserPasswordHistory'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdUserPasswordHistory
END 
GO

-- #desc                    Update an user password history
-- #bl_class				N/A
-- #db_dependencies         N/A
-- #db_references           N/A 

--#param UserID            Unique User ID required
--#param SequenceID		Unique SequenceID required
--#param UserPassword 			
--#param DateChanged 
--#param UserUpdate
--#param WorkstationID
--#param DateUpdated


CREATE PROCEDURE [dbo].SCSYS_UpdUserPasswordHistory
    @UserID			INT,
    @SequenceID		INT,
    @UserPassword	NVARCHAR(256),
    @DateChanged	DATETIME2,
    @UserUpdate		NVARCHAR(128),
    @WorkstationID	NVARCHAR(60),
    @DateUpdated	DATETIME2
AS 


	UPDATE [dbo].UserPasswordHistory
	SET    [UserID] = @UserID,
	[SequenceID] = @SequenceID, 
	[UserPassword] = @UserPassword, 
	[DateChanged] = @DateChanged, 
	[UserUpdate] = @UserUpdate, 
	[WorkstationID] = @WorkstationID, 
	[DateUpdated] = @DateUpdated
	
	WHERE  [UserID] = @UserID
	AND [SequenceID] = @SequenceID
GO
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdUserPasswordResetToken'))
	BEGIN
		DROP  Procedure  [dbo].SCSYS_UpdUserPasswordResetToken
	END

GO

-- #desc					Update User Password Reset Token
-- #bl_class				Premier.Security.UserPasswordResetToken.cs
-- #db_dependencies         N/A
-- #db_references           N/A 

-- #param TokenID			Token UniqueID
-- #param InstallationId	InstallationID
-- #param TokenStatus		Token Status
-- #param UserUpdate
-- #param LastDateUpdated
-- #param LastTimeUpdated

CREATE Procedure [dbo].SCSYS_UpdUserPasswordResetToken
(
	@TokenID   nvarchar(64),
	@InstallationId NVARCHAR(3),
	@TokenStatus nvarchar(2),
	@UserUpdate NVARCHAR(30),
	@LastDateUpdated decimal(18, 0),
	@LastTimeUpdated decimal(18, 0) 
)
AS

	UPDATE UserPasswordResetTokens
	SET
		InstallationId = @InstallationId,
		TokenStatus = @TokenStatus,
		UserUpdate = @UserUpdate,
		LastDateUpdated = @LastDateUpdated,
		LastTimeUpdated = @LastTimeUpdated
	WHERE 
		TokenID = @TokenID
		
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SCSYS_UpdUserQuickLink'))
BEGIN 
    DROP PROCEDURE [dbo].SCSYS_UpdUserQuickLink
END
GO

-- #desc                            Update User Quick Link.
-- #bl_class                        Premier.SysBase.UserQuickLink.cs
-- #db_dependencies                 N/A
-- #db_references                   N/A

--#param UserID              		User ID key definition required
--#param QuickLinkUniqueID  		QuickLinkUniqueID key definition  required
--#param QuickLinkType				
--#param quickLinkUrl
--#param UserUpdate
--#param WorkstationID
--#param DateUpdated


CREATE PROCEDURE [dbo].SCSYS_UpdUserQuickLink
(
    @UserID				INT,
    @QuickLinkUniqueID	INT,
	@QuickLinkType		NVARCHAR(20),
    @QuickLinkUrl		NVARCHAR(1024),
	@Description		NVARCHAR(1024),
	@QuickLinkArea		NVARCHAR(20),
    @UserUpdate			NVARCHAR(128),
    @WorkstationID		NVARCHAR(60),
    @DateUpdated		DATETIME2
)
AS 

	UPDATE [dbo].UserQuickLink
	SET    
	[UserID] = @UserID, 
	[QuickLinkUniqueID] = @QuickLinkUniqueID, 
	[QuickLinkType]= @QuickLinkType,
	[QuickLinkUrl] = @QuickLinkUrl, 
	[Description] = @Description,
	[QuickLinkArea] = @QuickLinkArea,
	[UserUpdate] = @UserUpdate, 
	[WorkstationID] = @WorkstationID, 
	[DateUpdated] = @DateUpdated
	
	WHERE  [UserID] = @UserID
	AND [QuickLinkUniqueID] = @QuickLinkUniqueID
GO

