/****** Table Definition ******/

USE [SC_SYSDB_NAME]
GO
/****** Object:  Table [dbo].[Environment]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Environment](
	[EnvironmentID] [nvarchar](40) NOT NULL,
	[EnvDesc] [nvarchar](256) NOT NULL,
	[Version] [nvarchar](60) NULL,
	[ConfigByInstance] [nvarchar](2) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_Environment_1] PRIMARY KEY CLUSTERED 
(
	[EnvironmentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Environment_1] ON [dbo].[Environment] 
(
	[EnvironmentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeployPackage]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DeployPackage](
	[PackageUniqueID] [uniqueidentifier] NOT NULL,
	[PackageType] [nvarchar](20) NOT NULL,
	[PackageDesc] [nvarchar](1024) NOT NULL,
	[Version] [nvarchar](60) NOT NULL,
	[GenerationDate] [datetime2](7) NOT NULL,
	[MinRequiredVer] [int] NOT NULL,
	[PackageBody] [varbinary](max) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_DeployPackage] PRIMARY KEY CLUSTERED 
(
	[PackageUniqueID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DefaultData]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DefaultData](
	[TargetSystem] [nvarchar](20) NOT NULL,
	[TableName] [nvarchar](128) NOT NULL,
	[TableDesc] [nvarchar](512) NULL,
	[OperationData] [NVARCHAR](max) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_SystemDefaultData] PRIMARY KEY CLUSTERED 
(
	[TargetSystem] ASC,
	[TableName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Role]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[RoleID] [nvarchar](40) NOT NULL,
	[RoleDesc] [nvarchar](512) NOT NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Permission]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permission](
	[PermissionID] [nvarchar](40) NOT NULL,
	[PermissionDesc] [nvarchar](256) NOT NULL,
	[GroupingCat] [nvarchar](40) NULL,
 CONSTRAINT [PK_Permission] PRIMARY KEY CLUSTERED 
(
	[PermissionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MenuSearchIndex]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuSearchIndex](
	[ItemUniqueID] [bigint] NOT NULL,
	[ItemType] [nvarchar](20) NOT NULL,
	[ItemKey] [nvarchar](128) NOT NULL,
	[ItemDesc] [nvarchar](512) NULL,
	[ItemDesc2] [nvarchar](512) NULL,
	[ItemURL] [nvarchar](1024) NULL,
	[ItemArea] [nvarchar](30) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_MenuSearchIndex] PRIMARY KEY CLUSTERED 
(
	[ItemUniqueID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MenuSearchIndex_Key] ON [dbo].[MenuSearchIndex] 
(
	[ItemKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MenuSearchIndex_Type] ON [dbo].[MenuSearchIndex] 
(
	[ItemType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE UNIQUE INDEX MenuSearchIndex_ItemUniqueID ON MenuSearchIndex (ItemUniqueID)
GO

/****** Object:  Table [dbo].[MenuSearchIndexLang]    Script Date: 29/11/2013 02:34:28 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MenuSearchIndexLang](
	[ItemUniqueID] [bigint] NOT NULL,
	[LanguageCode] [nvarchar](4) NOT NULL,
	[ItemDesc] [nvarchar](512) NULL,
	[ItemDesc2] [nvarchar](512) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemUniqueID] ASC,
	[LanguageCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE UNIQUE INDEX MenuSearchIndexLang_ItemUniqueID ON MenuSearchIndexLang (ItemUniqueID)
GO

/****** Object:  Table [dbo].[User]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User](
	[UserID] [int] NOT NULL IDENTITY(1,1),
	[UserName] [nvarchar](128) NOT NULL,
	[UserPassword] [nvarchar](256) NOT NULL,
	[MailingName] [nvarchar](256) NOT NULL,
	[EmailAddress] [nvarchar](256) NOT NULL,
	[AccountDisable] [NCHAR](1) NULL,
	[AccountLocked] [NCHAR](1) NULL,
	[AllowChangePass] [NCHAR](1) NULL,
	[ChangePassNxtLogin] [NCHAR](1) NULL,
	[LastPasswordChanged] [datetime2](7) NULL,
	[LastAccountLocked] [datetime2](7) NULL,
	[UserAvatar] [varbinary](4000) NULL ,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_User_Name] ON [dbo].[User] 
(
	[UserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SecurityAudit]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SecurityAudit](
	[EntryUniqueID] bigint NOT NULL IDENTITY (1, 1),
	[UserID] [int] NULL,
	[UserName] [nvarchar](128) NULL,
	[MachineKey] [nvarchar](128) NOT NULL,
	[AppName] [nvarchar](128) NOT NULL,
	[AppSource] [nvarchar](512) NULL,
	[ActionDesc] [nvarchar](512) NULL,
	[ActionParams] [nvarchar](512) NULL,
	[ActionDateTime] [datetime2](7) NULL,
	[ActionDetail] [NVARCHAR](max) NULL,
 CONSTRAINT [PK_SecurityAudit] PRIMARY KEY CLUSTERED 
(
	[EntryUniqueID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[UserID] [int] NOT NULL,
	[RoleID] [nvarchar](40) NOT NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



/****** Object:  Table [dbo].[UserEnvInstallation]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserEnvInstallation](
	[UserID] [int] NOT NULL,
	[EnvironmentID] [nvarchar](40) NOT NULL,
	[InstallationID] [nvarchar](3) NOT NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_UserEnvInstallation] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[EnvironmentID] ASC,
	[InstallationID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserEnvironment]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserEnvironment](
	[UserID] [int] NOT NULL,
	[EnvironmentID] [nvarchar](40) NOT NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_UserEnvironment] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[EnvironmentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RolePermission]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RolePermission](
	[RoleID] [nvarchar](40) NOT NULL,
	[PermissionID] [nvarchar](40) NOT NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_RolePermission] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC,
	[PermissionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnvironmentPackage]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnvironmentPackage](
	[EnvironmentID] [nvarchar](40) NOT NULL,
	[PackageUniqueID] [uniqueidentifier] NOT NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_EnvironmentPackage] PRIMARY KEY CLUSTERED 
(
	[EnvironmentID] ASC,
	[PackageUniqueID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnvironmentInstance]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnvironmentInstance](
	[EnvironmentID] [nvarchar](40) NOT NULL,
	[SequenceID] [int] NOT NULL,
	[UrlPath] [nvarchar](1024) NULL,
	[PhysicalPath] [nvarchar](1024) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_EnvironmentInstance] PRIMARY KEY CLUSTERED 
(
	[EnvironmentID] ASC,
	[SequenceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnvironmentConfig]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EnvironmentConfig](
	[EnvironmentID] [nvarchar](40) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[ConfKey] [nvarchar](100) NOT NULL,
	[ConfType] [nvarchar](20) NOT NULL,
	[ConfVal] [NVARCHAR](max) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_EnvironmentConfig] PRIMARY KEY CLUSTERED 
(
	[EnvironmentID] ASC,
	[InstanceID] ASC,
	[ConfKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SystemSetting]    Script Date: 06/05/2013 14:20:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SystemSetting](
	[SettingKey] [nvarchar](40) NOT NULL,
	[SettingDesc] [nvarchar](1024) NULL,
	[SettingType] [nvarchar](20) NULL,
	[SettingValue] [NVARCHAR](max) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2] NULL,
PRIMARY KEY CLUSTERED 
(
	[SettingKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



/****** Object:  Table [dbo].[UserQuickLink]    Script Date: 06/05/2013 14:27:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[UserQuickLink](
	[UserID] [int] NOT NULL,
	[QuickLinkUniqueID] [int] NOT NULL,
	[QuickLinkType][nvarchar](20) NULL,
	[Description] [nvarchar](1024) NULL,
	[QuickLinkUrl] [nvarchar](1024) NULL,
	[QuickLinkArea] [NVARCHAR](20) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[QuickLinkUniqueID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[MessageGlossary]    Script Date: 07/11/2013 11:04:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MessageGlossary](
	[MessageKey] [nvarchar](40) NOT NULL,
	[MessageDesc] [nvarchar](512) NULL,
	[MessageType] [nvarchar](20) NULL,
	[MessageLevel] [nvarchar](20) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2] NULL,
PRIMARY KEY CLUSTERED 
(
	[MessageKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[MessageGlossaryLang]    Script Date: 07/11/2013 11:05:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MessageGlossaryLang](
	[MessageKey] [nvarchar](40) NOT NULL,
	[LanguageCode] [nvarchar](4) NOT NULL,
	[MessageDesc] [nvarchar](512) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2] NULL,
PRIMARY KEY CLUSTERED 
(
	[MessageKey] ASC,
	[LanguageCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



/****** Object:  Table [dbo].[UserPasswordHistory]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserPasswordHistory](
	[UserID] [int] NOT NULL,
	[SequenceID] [int] NOT NULL,
	[UserPassword] [nvarchar](256) NULL,
	[DateChanged] [datetime2] NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_UserPasswordHistory] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[SequenceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[UserNotification]    Script Date: 03/01/2013 13:52:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserNotification](
	[UserID] [int] NOT NULL,
	[NotificationID] [int] NOT NULL IDENTITY(1,1),
	[Type] [nvarchar](10) NULL,
	[Description] [nvarchar](1024) NULL,
	[NotificationUrl] [nvarchar](1024) NULL,
	[Status] [nvarchar](2) NULL,
	[Category1] [nvarchar](40) NULL,
	[Category2] [nvarchar](40) NULL,
	[NotificationData] [nvarchar](max) NULL,
	[DateCreated] [datetime2](7) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
 CONSTRAINT [PK_UserNotification] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[NotificationID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[UserDevicePreferences]    Script Date: 30/12/2013 12:21:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[UserDevicePreferences](
	[OwnerType] [NVARCHAR](2) NOT NULL, --can be a user id 'U' or a device id 'D'
	[OwnerID] [NVARCHAR](30) NOT NULL, --can be a user id or a device id
	[PreferenceKey] [NVARCHAR](30) NOT NULL,
	[PreferenceVal] [NVARCHAR](max) NULL,
	[UserUpdate] [nvarchar](128) NULL,
	[WorkstationID] [nvarchar](60) NULL,
	[DateUpdated] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[OwnerType] ASC,
	[OwnerID] ASC,
	[PreferenceKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO

/****** Object:  ForeignKey [FK_UserRole_Role]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([RoleID])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role]
GO
/****** Object:  ForeignKey [FK_UserRole_User]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User]
GO
/****** Object:  ForeignKey [FK_UserEnvInstallation_User]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserEnvInstallation]  WITH CHECK ADD  CONSTRAINT [FK_UserEnvInstallation_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[UserEnvInstallation] CHECK CONSTRAINT [FK_UserEnvInstallation_User]
GO
/****** Object:  ForeignKey [FK_UserEnvInstallation_Environment]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserEnvInstallation]  WITH CHECK ADD  CONSTRAINT [FK_UserEnvInstallation_Environment] FOREIGN KEY([EnvironmentID])
REFERENCES [dbo].[Environment] ([EnvironmentID])
GO
ALTER TABLE [dbo].[UserEnvInstallation] CHECK CONSTRAINT [FK_UserEnvInstallation_Environment]
GO
/****** Object:  ForeignKey [FK_UserEnvironment_Environment]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserEnvironment]  WITH CHECK ADD  CONSTRAINT [FK_UserEnvironment_Environment] FOREIGN KEY([EnvironmentID])
REFERENCES [dbo].[Environment] ([EnvironmentID])
GO
ALTER TABLE [dbo].[UserEnvironment] CHECK CONSTRAINT [FK_UserEnvironment_Environment]
GO
/****** Object:  ForeignKey [FK_UserEnvironment_User]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserEnvironment]  WITH CHECK ADD  CONSTRAINT [FK_UserEnvironment_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[UserEnvironment] CHECK CONSTRAINT [FK_UserEnvironment_User]
GO
/****** Object:  ForeignKey [FK_RolePermission_Permission]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[RolePermission]  WITH CHECK ADD  CONSTRAINT [FK_RolePermission_Permission] FOREIGN KEY([PermissionID])
REFERENCES [dbo].[Permission] ([PermissionID])
GO
ALTER TABLE [dbo].[RolePermission] CHECK CONSTRAINT [FK_RolePermission_Permission]
GO
/****** Object:  ForeignKey [FK_RolePermission_Role]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[RolePermission]  WITH CHECK ADD  CONSTRAINT [FK_RolePermission_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([RoleID])
GO
ALTER TABLE [dbo].[RolePermission] CHECK CONSTRAINT [FK_RolePermission_Role]
GO
/****** Object:  ForeignKey [FK_EnvironmentPackage_DeployPackage]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[EnvironmentPackage]  WITH CHECK ADD  CONSTRAINT [FK_EnvironmentPackage_DeployPackage] FOREIGN KEY([PackageUniqueID])
REFERENCES [dbo].[DeployPackage] ([PackageUniqueID])
GO
ALTER TABLE [dbo].[EnvironmentPackage] CHECK CONSTRAINT [FK_EnvironmentPackage_DeployPackage]
GO
/****** Object:  ForeignKey [FK_EnvironmentPackage_Environment]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[EnvironmentPackage]  WITH CHECK ADD  CONSTRAINT [FK_EnvironmentPackage_Environment] FOREIGN KEY([EnvironmentID])
REFERENCES [dbo].[Environment] ([EnvironmentID])
GO
ALTER TABLE [dbo].[EnvironmentPackage] CHECK CONSTRAINT [FK_EnvironmentPackage_Environment]
GO
/****** Object:  ForeignKey [FK_EnvironmentInstance_Environment]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[EnvironmentInstance]  WITH CHECK ADD  CONSTRAINT [FK_EnvironmentInstance_Environment] FOREIGN KEY([EnvironmentID])
REFERENCES [dbo].[Environment] ([EnvironmentID])
GO
ALTER TABLE [dbo].[EnvironmentInstance] CHECK CONSTRAINT [FK_EnvironmentInstance_Environment]
GO
/****** Object:  ForeignKey [FK_EnvironmentConfig_Environment]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[EnvironmentConfig]  WITH CHECK ADD  CONSTRAINT [FK_EnvironmentConfig_Environment] FOREIGN KEY([EnvironmentID])
REFERENCES [dbo].[Environment] ([EnvironmentID])
GO
ALTER TABLE [dbo].[EnvironmentConfig] CHECK CONSTRAINT [FK_EnvironmentConfig_Environment]
GO
/****** Object:  ForeignKey [FK_UserQuickLink_User]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserQuickLink]  WITH CHECK ADD  CONSTRAINT [FK_UserQuickLink_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO

ALTER TABLE [dbo].[UserQuickLink] CHECK CONSTRAINT [FK_UserQuickLink_User]
GO

/****** Object:  ForeignKey [FK_UserPasswordHistory_User]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserPasswordHistory]  WITH CHECK ADD  CONSTRAINT [FK_UserPasswordHistory_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO

ALTER TABLE [dbo].[UserPasswordHistory] CHECK CONSTRAINT [FK_UserPasswordHistory_User]
GO
/****** Object:  ForeignKey [FK_UserNotification_User]    Script Date: 03/01/2013 13:52:54 ******/
ALTER TABLE [dbo].[UserNotification]  WITH CHECK ADD  CONSTRAINT [FK_UserNotification_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[UserNotification] CHECK CONSTRAINT [FK_UserNotification_User]
GO

/****** Object:  ForeignKey [FK_MenuSearchIndexLang_ItemUniqueID]    Script Date: 29/11/2013 13:52:54 ******/
ALTER TABLE [dbo].[MenuSearchIndexLang]  WITH CHECK ADD  CONSTRAINT [FK_MenuSearchIndexLang_ItemUniqueID] FOREIGN KEY([ItemUniqueID])
REFERENCES [dbo].[MenuSearchIndex] ([ItemUniqueID])
GO

ALTER TABLE [dbo].[MenuSearchIndexLang] CHECK CONSTRAINT [FK_MenuSearchIndexLang_ItemUniqueID]
GO

CREATE TABLE [dbo].UserPasswordResetTokens(
	TokenID NVARCHAR(64) NOT NULL,
	InstallationId NVARCHAR(3) NOT NULL,
	UserID DECIMAL(18, 0) NOT NULL,
	WebAccountID DECIMAL(18, 0) NOT NULL,
	TokenStatus NVARCHAR(2) NULL,
	DateCreated DECIMAL(18, 0) NOT NULL,
	TimeCreated DECIMAL(18, 0) NOT NULL,
	UserUpdate NVARCHAR(30) NULL,
	LastDateUpdated DECIMAL(18, 0) NULL,
	LastTimeUpdated DECIMAL(18, 0) NULL,
 CONSTRAINT PK_UserPasswordResetTokens PRIMARY KEY CLUSTERED (TokenID ASC)
) 
GO

USE [master]
GO

/****** Database Definition ******/

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SC_SYSDB_NAME].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
USE [SC_SYSDB_NAME]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [SC_SYSDB_NAME] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
ALTER DATABASE [SC_SYSDB_NAME]  SET AUTO_SHRINK ON;
GO
ALTER DATABASE [SC_SYSDB_NAME] SET AUTO_CLOSE OFF WITH NO_WAIT
GO
