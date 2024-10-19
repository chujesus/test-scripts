USE [SCDBNAME] 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_ExcAddMigrationDetail'))
	BEGIN
		DROP  Procedure  [dbo].ECO_ExcAddMigrationDetail
	END

GO

-- #desc						Add Migration Detail
-- #bl_class					Premier.eCommerce.MigrationDetailCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param MigrationId			Migration Id
-- #param StoreId				Store Id	
-- #param EntityType			Entity Type	
-- #param MessageCode			Message Code
-- #param Response				Response	
-- #param DateUpdated			Date Updated

CREATE Procedure [dbo].ECO_ExcAddMigrationDetail
(
	@MigrationId	UNIQUEIDENTIFIER,
	@StoreId		NVARCHAR(3),
	@EntityType		INT,
	@MessageCode	INT,
	@Response		NVARCHAR(MAX),
	@DateUpdated	DATETIME2(7)
)
AS

	INSERT INTO [dbo].SC_MigrationDetail
	(
		MigrationId,
		StoreId,
		EntityType,
		MessageCode,
		Response,
		DateUpdated
	)
	VALUES
	(
		@MigrationId,
		@StoreId,
		@EntityType,
		@MessageCode,
		@Response,
		@DateUpdated
	);
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_ExcAddMigrationSummary'))
	BEGIN
		DROP  Procedure  [dbo].ECO_ExcAddMigrationSummary
	END

GO

-- #desc					Add Migration Summary
-- #bl_class				Premier.eCommerce.MigrationSummaryCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param MigrationId		Migration Id
-- #param MigrationStatus	Migration Status
-- #param MigrationType		Migration Type
-- #param MigrationMode		Migration Mode
-- #param ContentStatus		Content Status
-- #param ReportUrl			Report Url	
-- #param DateUpdated		Date Updated

CREATE Procedure [dbo].ECO_ExcAddMigrationSummary
(
	@MigrationId		UNIQUEIDENTIFIER,
	@MigrationType		INT,
	@MigrationMode		INT,
	@ContentStatus		INT,
	@MigrationStatus	INT,
	@ReportUrl			NVARCHAR(MAX),
	@DateUpdated		DATETIME2(7)
)
AS

	INSERT INTO [dbo].SC_MigrationSummary
	(
		MigrationID,
		MigrationType,
		MigrationMode,
		ContentStatus,
		MigrationStatus,
		ReportUrl,
		ExecutingTrace,
		StartDateTime,
		DateUpdated
	)
	VALUES
	(
		@MigrationID,
		@MigrationType,
		@MigrationMode,
		@ContentStatus,
		@MigrationStatus,
		@ReportUrl,
		N'',
		@DateUpdated,
		@DateUpdated
	);
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_ExcUpdMigraSummaryStatus'))
	BEGIN
		DROP  Procedure  [dbo].ECO_ExcUpdMigraSummaryStatus
	END

GO

-- #desc					Update Migration Summary Status
-- #bl_class				Premier.eCommerce.MigrationSummaryCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param MigrationId		Migration Id
-- #param ContentStatus		Content Status
-- #param DateUpdated		Date Updated

CREATE Procedure [dbo].ECO_ExcUpdMigraSummaryStatus
(
	@MigrationId		UNIQUEIDENTIFIER,
	@MigrationStatus	INT,
	@DateUpdated		DATETIME2(7)
)
AS

	UPDATE [dbo].SC_MigrationSummary 
		SET MigrationStatus = @MigrationStatus, DateUpdated = @DateUpdated 
	WHERE MigrationId = @MigrationId;
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_ExcUpdMigrationTrace'))
	BEGIN
		DROP  Procedure  [dbo].ECO_ExcUpdMigrationTrace
	END

GO

-- #desc					Update Migration Summary Trace
-- #bl_class				Premier.eCommerce.UpdateMigrationExecutingTraceCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param MigrationId		Migration Id
-- #param ExecutingTrace	Executing Trace
-- #param DateUpdated		Date Updated

CREATE Procedure [dbo].ECO_ExcUpdMigrationTrace
(
	@MigrationId		UNIQUEIDENTIFIER,
	@ExecutingTrace		NVARCHAR(MAX),
	@DateUpdated		DATETIME2(7)
)
AS
	UPDATE [dbo].SC_MigrationSummary 
		SET ExecutingTrace = ExecutingTrace + '|@' + @ExecutingTrace, DateUpdated = @DateUpdated 
	WHERE MigrationId = @MigrationId;

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigraCatalogBadgeList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigraCatalogBadgeList
	END

GO

-- #desc						Get Catalog Badge List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id
-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE Procedure [dbo].ECO_GetMigraCatalogBadgeList
(
	@StoreId				NVARCHAR(3),
	@PageIndex				INT,
	@PageSize				INT
)
AS
	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;
	
	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	/* Insert into temporary table Catalog Budges */
	;WITH CTE AS (
		SELECT 
			T.AnnouncementID, 
			T.FlashMessage, 
			T.Description,
			T.BackgroundColor,
			T.FontColor,
			ROW_NUMBER() OVER(ORDER BY T.AnnouncementID) RNUM
		FROM [dbo].SC_TagAnnouncement T
		INNER JOIN [dbo].SC_TagAnnouncementAssignment A
			ON A.AnnouncementId = T.AnnouncementId
		INNER JOIN [dbo].SC_AnnouncementInstallations I
			ON I.AnnouncementId = T.AnnouncementId
			AND I.InstallationID IN (@StoreId, '***')
		WHERE A.AssignmentType = 0 /* By Catalog */
		GROUP BY T.AnnouncementID, T.FlashMessage, T.Description, T.BackgroundColor, T.FontColor
	)
	SELECT 
		T.AnnouncementID, 
		T.FlashMessage, 
		T.Description,
		T.BackgroundColor,
		T.FontColor,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
		INTO #CatalogBadges
	FROM CTE T
	WHERE (T.RNUM BETWEEN @RowStart AND @RowEnd);

	/* Select Announcements */
	SELECT 
		T.AnnouncementID, 
		T.FlashMessage, 
		T.Description,
		T.BackgroundColor,
		T.FontColor,
		T.TotalRowCount
	FROM #CatalogBadges T;

	/* Select announcement Languages */
	SELECT DISTINCT 
		L.AnnouncementID, 
		L.FlashMessage, 
		L.Description,
		LanguageID
	FROM [dbo].SC_TagAnnouncementLangs L
	INNER JOIN #CatalogBadges T
		ON T.AnnouncementId = L.AnnouncementId;

	DROP TABLE #CatalogBadges;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigraCatalogNodeList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigraCatalogNodeList
	END

GO

-- #desc						Get Catalog Category Node List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @StoreId				Store Id
-- #param @RetrieveProducts		Retrieve Products
-- #param @RetrieveBadges		Retrieve Badges
-- #param @PageIndex			Paging - Current page
-- #param @PageSize				Paging - Items to be shown

CREATE Procedure [dbo].ECO_GetMigraCatalogNodeList 
(
	@StoreId			NVARCHAR(3),
	@RetrieveProducts	INT,
	@RetrieveBadges		INT,
	@PageIndex			INT,
	@PageSize			INT
)
AS
	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;

	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	/* Insert into temp table Catalog Category Nodes */
	;WITH CTE AS (
		SELECT 
			A.CatalogId,
			A.NodeId,
			A.ReferenceId,
			A.Description,
			A.URLPath,
			ROW_NUMBER() OVER(ORDER BY A.CatalogId, A.LeftPosition) RNUM	/* Get Nodes Parents first */
		FROM 
			[dbo].SC_Catalog_NSM A
		WHERE A.InstallationId = @StoreId
	)
	SELECT 
		A.CatalogId,
		A.NodeId,
		A.ReferenceId,
		A.Description,
		A.URLPath,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
		INTO #CatalogNodes
	FROM CTE A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);

	/* Retrieve Catalog Category Nodes */
	SELECT 
		A.CatalogId,
		A.NodeId,
		A.ReferenceId,
		A.Description,
		A.URLPath,
		A.TotalRowCount
	FROM #CatalogNodes A

	/* Retrieve Catalog Category Node Languages */
	SELECT 
		A.CatalogId,
		A.NodeId,
		B.ReferenceId,
		A.LanguageId,
		A.Description
	FROM 
		[dbo].SC_CatalogLangs A
	INNER JOIN #CatalogNodes B
		ON B.CatalogId = A.CatalogId
		AND B.NodeId = A.NodeId
	WHERE A.InstallationID = @StoreId 
		AND A.Description <> N'';

	/* Retrieve Catalog Category Node Products */
	IF (@RetrieveProducts = 1) BEGIN
		SELECT 
			A.CatalogID,
			A.NodeID,
			A.ShortItemNumber,
			A.Priority
		FROM 
			[dbo].SC_CatalogNodeItems A
		INNER JOIN #CatalogNodes B
			ON B.CatalogId = A.CatalogId
			AND B.NodeId = A.NodeId
		WHERE A.InstallationID = @StoreId;
	END
	
	/* Retrieve Badges assignments */
	IF (@RetrieveBadges = 1) BEGIN
		SELECT 
			A.AnnouncementId, 
			A.CatalogId, 
			C.NodeId
		FROM [dbo].SC_TagAnnouncementAssignment A
		INNER JOIN [dbo].SC_AnnouncementInstallations I
			ON I.AnnouncementId = A.AnnouncementId
			AND I.InstallationId IN (@StoreId, N'***')
		INNER JOIN #CatalogNodes C
			ON C.CatalogId = A.CatalogId
			AND C.ReferenceId = A.NodeId
		WHERE A.AssignmentType = 0;/* By Catalog */
	END

	DROP TABLE #CatalogNodes;
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigraCatNodeRestList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigraCatNodeRestList
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc							Get Catalog Matrix Restriction List
-- #bl_class						Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @StoreId					Store Id
-- #param @CatalogNodesXML			Catalog Nodes XML	<catalogs><catalog><catalogId><![CDATA[ABC]]></catalogId><nodeId><![CDATA[0]]></nodeId></catalog></catalogs>

CREATE Procedure [dbo].ECO_GetMigraCatNodeRestList 
(
	@StoreId			NVARCHAR(3),
	@CatalogNodesXML	XML
)
AS
	/* Retrieve Node Matrix children restrictions */
	SELECT
		A.CatalogId,
		A.NodeId AS ReferenceId,
		A.ParentItemNumber AS ParentProductNumber,
		A.ShortItemNumber AS ShortProductNumber
	FROM 
		[dbo].SC_CatalogNodeItemsRestrictions A
	INNER JOIN @CatalogNodesXML.nodes('/catalogs/catalog') AS catalogs(catalog)
		ON catalogs.catalog.value('catalogId[1]','NVARCHAR(3)') = A.CatalogId
		AND catalogs.catalog.value('nodeId[1]','FLOAT') = A.NodeId
	WHERE A.InstallationID = @StoreId
		AND A.PublishStatus = N'P'
	OPTION ( OPTIMIZE FOR ( @CatalogNodesXML = NULL ) );

GO
SET QUOTED_IDENTIFIER OFF 
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigraExtAttributeList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigraExtAttributeList
	END

GO

-- #desc						Get Matrix Extended Attribute List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE Procedure [dbo].ECO_GetMigraExtAttributeList 
(
	@PageIndex				INT,
	@PageSize				INT
)
AS
	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;
	
	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	/* Insert block Into temporary table */
	;WITH CTE AS (
		SELECT  
			A.Template,
			A.Style,
			A.SegmentNumber,
			A.DisplayMode,
			A.Size,
			A.MaxWidthSize,
			A.BackgroundImageStyle,
			A.RefreshImage,
			A.DescriptionDisplayMode,
			L.AttributeDescription,
			L.LanguageId,
			ROW_NUMBER() OVER(ORDER BY A.Template, A.Style, A.SegmentNumber) RNUM
		FROM 
			[dbo].SC_MatrixAttributeExtended A
		INNER JOIN [dbo].SC_MatrixAttributeExtendedLang L
			ON L.Template = A.Template
			AND L.Style = A.Style
			AND L.SegmentNumber = A.SegmentNumber
	)
	SELECT  
		A.Template,
		A.Style,
		A.SegmentNumber,
		A.DisplayMode,
		A.Size,
		A.MaxWidthSize,
		A.BackgroundImageStyle,
		A.RefreshImage,
		A.DescriptionDisplayMode,
		A.AttributeDescription,
		A.LanguageId,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
		INTO #MatrixExtAttributes
	FROM 
		CTE A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);

	/* Retrieve extended attributes */
	SELECT  
		A.Template,
		A.Style,
		A.SegmentNumber,
		A.DisplayMode,
		A.Size,
		A.MaxWidthSize,
		A.BackgroundImageStyle,
		A.RefreshImage,
		A.DescriptionDisplayMode,
		A.AttributeDescription,
		A.LanguageId,
		A.TotalRowCount
	FROM #MatrixExtAttributes A;

	/* Matrix Extended Attributes Detail */
	SELECT
		A.Template,
		A.Style,
		A.SegmentNumber,
		A.AttributeValue,
		A.HexaDecimal1,
		A.HexaDecimal2,
		L.LanguageId,
		L.AttributeValueDescription,
		L.OverrideAttributeValue,
		L.Title
	FROM 
		[dbo].SC_MatrixAttributeExtendedDetail A
	INNER JOIN [dbo].SC_MatrixAttributeExtendedDetailLang L
		ON L.Template = A.Template 
		AND L.Style = A.Style 
		AND L.SegmentNumber = A.SegmentNumber
		AND L.AttributeValue = A.AttributeValue
	INNER JOIN #MatrixExtAttributes B
		ON B.Template = A.Template 
		AND B.Style = A.Style 
		AND B.SegmentNumber = A.SegmentNumber;

	DROP TABLE #MatrixExtAttributes;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigraMostViewProducts'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigraMostViewProducts
	END

GO

-- #desc					Reads Most viewed Products by Store
-- #bl_class				Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param StoreId			Store Id
-- #param @LastDailyHits	Last Daily Hits (365 days)
-- #param @PageIndex		Paging - Current page
-- #param @PageSize			Paging - Items to be shown

CREATE Procedure [dbo].ECO_GetMigraMostViewProducts
(
	@StoreId		NCHAR(3),
	@LastDailyHits	INT,
	@PageIndex		INT,
	@PageSize		INT
)
AS
	/* Get Julian date for the last 365 days */
	DECLARE @LastDailyHitsJulianDate DECIMAL = [dbo].CMM_GetCurrentJulianDate(DATEADD(DAY, - @LastDailyHits, GETDATE()));

	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;
	
	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	/* Insert Into Temporary table */
	;WITH CTE AS (
		SELECT
			MV.ShortItemNumber AS ShortProductNumber,
			MV.InstallationID AS StoreId,
			I.DisplayItemNumber AS DisplayProductNumber,
			ISNULL(HC.WeightRank, 0) AS WeightRank,
			ISNULL(HC.DisplayItem, 1) AS DisplayOnWebsite,
			MAX(MV.VisitDate) AS LastViewedOn,
			COUNT(MV.ShortItemNumber) AS TotalHits,
			ROW_NUMBER() OVER(ORDER BY MV.ShortItemNumber) RNUM
		FROM [dbo].SC_WebSiteItemHits MV
		INNER JOIN [dbo].SC_ItemMaster I
			ON I.InstallationID = MV.InstallationID
			AND I.ShortItemNumber = MV.ShortItemNumber
		LEFT OUTER JOIN [dbo].SC_WebSiteItemHitsConf HC
			ON HC.InstallationID = MV.InstallationID
			AND HC.ShortItemNumber = MV.ShortItemNumber
		WHERE 
			MV.InstallationID = @StoreId
			AND MV.VisitDate >= @LastDailyHitsJulianDate
		GROUP BY MV.ShortItemNumber, MV.InstallationID, I.DisplayItemNumber, HC.WeightRank, HC.DisplayItem
	)
	SELECT 
		A.ShortProductNumber,
		A.StoreId,
		A.DisplayProductNumber,
		A.WeightRank,
		A.DisplayOnWebsite,
		A.LastViewedOn,
		A.TotalHits,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
		INTO #MostViewedProducts
	FROM CTE A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);


	/* Retrieve Most viewed Products by blocks */
	SELECT 
		A.ShortProductNumber,
		A.DisplayProductNumber,
		A.WeightRank,
		A.DisplayOnWebsite,
		A.LastViewedOn,
		A.TotalHits,
		A.TotalRowCount
	FROM #MostViewedProducts A;
	
	/* Select Most Viewed Product Hits */
	SELECT 
		A.ShortItemNumber AS ShortProductNumber,
		A.VisitDate,
		COUNT(1) AS TotalHits
	FROM [dbo].SC_WebSiteItemHits A
	INNER JOIN #MostViewedProducts P
		ON P.StoreId = A.InstallationID
		AND P.ShortProductNumber = A.ShortItemNumber
	WHERE 
		A.InstallationID = @StoreId
		AND A.VisitDate >= @LastDailyHitsJulianDate
	GROUP BY A.ShortItemNumber, A.VisitDate;
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigraProductBadgeList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigraProductBadgeList
	END

GO

-- #desc						Get Product Badge List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @StoreId				Store Id
-- #param @PageIndex			Paging - Current page
-- #param @PageSize				Paging - Items to be shown

CREATE Procedure [dbo].ECO_GetMigraProductBadgeList
(
	@StoreId				NVARCHAR(3),
	@PageIndex				INT,
	@PageSize				INT
)
AS
	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;
	
	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	/* Insert Into temporary table Product Badges */
	;WITH CTE AS (
		SELECT 
			T.AnnouncementId, 
			T.FlashMessage, 
			T.Description,
			T.BackgroundColor,
			T.FontColor,
			ROW_NUMBER() OVER(ORDER BY T.AnnouncementId) RNUM
		FROM [dbo].SC_TagAnnouncement T
		INNER JOIN [dbo].SC_TagAnnouncementAssignment A
			ON A.AnnouncementId = T.AnnouncementId
		INNER JOIN [dbo].SC_AnnouncementInstallations I
			ON I.AnnouncementId = T.AnnouncementId
			AND I.InstallationID IN (@StoreId, N'***')
		WHERE A.AssignmentType = 1	/* By Product */
		GROUP BY T.AnnouncementId, T.FlashMessage, T.Description, T.BackgroundColor, T.FontColor
	)
	SELECT 
		A.AnnouncementId, 
		A.FlashMessage, 
		A.Description,
		A.BackgroundColor,
		A.FontColor,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
		INTO #ProductBadges
	FROM CTE A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);
	
	/* Select Announcements */
	SELECT 
		T.AnnouncementID, 
		T.FlashMessage, 
		T.Description,
		T.BackgroundColor,
		T.FontColor,
		T.TotalRowCount
	FROM #ProductBadges T;

	/* Select announcement Languages */
	SELECT DISTINCT 
		L.AnnouncementId, 
		L.FlashMessage, 
		L.Description,
		LanguageID
	FROM [dbo].SC_TagAnnouncementLangs L
	INNER JOIN #ProductBadges T
		ON T.AnnouncementId = L.AnnouncementId;

	DROP TABLE #ProductBadges;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigrationDetailList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigrationDetailList
	END

GO

-- #desc				Reads the Migration detail list  
-- #bl_class			Premier.eCommerce.MigrationDetailList.cs
-- #db_dependencies		N/A
-- #db_references		N/A

-- #param MigrationId	Migration Id
-- #param StoreId		Store Id

CREATE Procedure [dbo].ECO_GetMigrationDetailList
(
	@MigrationId	UNIQUEIDENTIFIER,
	@StoreId		NVARCHAR(3)
)
AS

	SELECT 
		A.MigrationId,
		A.StoreId,
		A.EntityType,
		A.MessageCode,
		A.Response
	FROM 
		[dbo].SC_MigrationDetail A
	WHERE
		A.MigrationId = @MigrationId
		AND A.StoreId = @StoreId
	ORDER BY A.EntityType;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigrationProductList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigrationProductList
	END

GO

-- #desc						Reads Products by Store
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id
-- #param @RetrieveBadges		Retrieve Badges
-- #param @PageIndex			Paging - Current page
-- #param @PageSize				Paging - Items to be shown

CREATE Procedure [dbo].ECO_GetMigrationProductList
(
	@StoreId		NCHAR(3),
	@RetrieveBadges	INT,
	@PageIndex		INT,
	@PageSize		INT
)
AS
	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;
	
	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	/* Insert Into Temporary table */
	;WITH CTE AS (
		SELECT 
			A.ShortItemNumber,
			A.DisplayItemNumber AS DisplayProductNumber,
			/* Validate if the product is related to a Catalog */
			CASE WHEN B.ShortItemNumber IS NULL THEN 0 ELSE 1 END AS RelatedToCatalog
		FROM [dbo].SC_ItemMaster A
		LEFT OUTER JOIN [dbo].SC_CatalogNodeItems B
			ON B.InstallationId = A.InstallationId
			AND B.ShortItemNumber = A.ShortItemNumber
		WHERE A.InstallationId = @StoreId
		UNION ALL
		/* Products with images and have not content */
		SELECT A.ItemNumber AS ShortItemNumber,
			'' AS DisplayProductNumber,
			1 AS RelatedToCatalog
		FROM [dbo].CATALOGITEMMEDIAFILE A
		WHERE A.InstallationID IN (@StoreId, '***')
	),
	CTE1 AS (
		SELECT 
			A.ShortItemNumber,
			MAX(A.DisplayProductNumber) AS DisplayProductNumber, /* Take Item Master Product Number */
			MAX(A.RelatedToCatalog) AS RelatedToCatalog, /* Has image or is related to catalog */
			ROW_NUMBER() OVER(ORDER BY A.ShortItemNumber) RNUM
		FROM CTE A
		GROUP BY A.ShortItemNumber	/* Prevent duplicated */
	) 
	SELECT 
		A.ShortItemNumber,
		A.DisplayProductNumber,
		A.RelatedToCatalog,
		(SELECT COUNT(1) FROM CTE1) TotalRowCount
		INTO #Products
	FROM CTE1 A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);

	/* Retrieve Product Numbers by blocks, get the products that has some relation (Catalogs, Images, Badges) */
	SELECT 
		A.ShortItemNumber,
		A.DisplayProductNumber,
		A.RelatedToCatalog,
		A.TotalRowCount
	FROM #Products A;
	
	/* Select Product Badges */
	IF (@RetrieveBadges = 1) BEGIN
		SELECT 
			A.AnnouncementId, 
			A.ShortItemNumber
		FROM [dbo].SC_TagAnnouncementAssignment A
		INNER JOIN [dbo].SC_AnnouncementInstallations I
			ON I.AnnouncementId = A.AnnouncementId
			AND I.InstallationId IN (@StoreId, N'***')
		INNER JOIN #Products P
			ON P.ShortItemNumber = A.ShortItemNumber
		WHERE A.AssignmentType = 1;/* By Product */
	END

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigrationStatInfo'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigrationStatInfo
	END

GO
-- #desc							Get the row count of Store related tables.
-- #bl_class						Premier.eCommerce.MigrationStatInfo.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @StoreId					Store Id
-- #param @LastDailyHits			Last Daily Hits

CREATE Procedure [dbo].ECO_GetMigrationStatInfo
(
	@StoreId					NVARCHAR(3),
	@LastDailyHits				INT,
	@Products	 				INT OUTPUT,
	@ProductBadges 				INT OUTPUT,
	@Catalogs 					INT OUTPUT,
	@CatalogProducts 			INT OUTPUT,
	@CatalogBadges 				INT OUTPUT,
	@MatrixExtendedAttributes	INT OUTPUT,
	@MostViewedProducts			INT OUTPUT
)
AS
	SET NOCOUNT ON	
	/* Dynamic */
	DECLARE @SQL_DYNAMIC NVARCHAR(MAX);
	
	/* Get Julian date for the last 365 days */
	DECLARE @LastDailyHitsJulianDate DECIMAL = [dbo].CMM_GetCurrentJulianDate(DATEADD(DAY, - @LastDailyHits, GETDATE()));

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_MatrixAttributeExtended')) BeGIN
		/* Matrix Extended Attributes */
		SET @SQL_DYNAMIC = N' SELECT @MatrixExtendedAttributes = COUNT(1) FROM [dbo].SC_MatrixAttributeExtended ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @MatrixExtendedAttributes INT OUTPUT ', @MatrixExtendedAttributes = @MatrixExtendedAttributes OUTPUT;
	END;
	ELSE BEGIN
		SET @MatrixExtendedAttributes = -1;
	END;

	/* Products */
	;WITH CTE AS (
		SELECT ShortItemNumber FROM [dbo].SC_ItemMaster WHERE InstallationID = @StoreId /* Store Products */
		UNION 
		SELECT ItemNumber FROM [dbo].CATALOGITEMMEDIAFILE WHERE InstallationID IN('***', @StoreId) /* Products with images */
	)
	SELECT @Products = COUNT(1) FROM CTE
	
	/* Product Badges */
	;WITH CTE AS ( 
		SELECT DISTINCT A.AnnouncementID FROM SC_TagAnnouncementAssignment A INNER JOIN SC_AnnouncementInstallations I ON I.AnnouncementId = A.AnnouncementId WHERE I.InstallationID IN (@StoreId, '***') AND A.AssignmentType = 1
	)
	SELECT @ProductBadges = COUNT(1) FROM CTE;
	
	/* Catalogs */
	SET @Catalogs = (SELECT COUNT(1) FROM SC_Catalog_NSM WHERE InstallationID = @StoreId AND NodeID = 0);
	
	/* Catalog Products */
	SET @CatalogProducts = (SELECT COUNT(1) FROM [dbo].SC_Catalog_NSM C INNER JOIN [dbo].SC_CatalogNodeItems I ON I.InstallationID = C.InstallationID AND I.CatalogID = C.CatalogID AND I.NodeID = C.NodeID WHERE C.InstallationID = @StoreId);
	
	/* Catalog Badges */
	;WITH CTE AS (
		SELECT DISTINCT A.AnnouncementID FROM SC_TagAnnouncementAssignment A INNER JOIN SC_AnnouncementInstallations I ON I.AnnouncementId = A.AnnouncementId WHERE I.InstallationID IN (@StoreId, '***') AND A.AssignmentType = 0
	)
	SELECT @CatalogBadges = COUNT(1) FROM CTE;
	
	/* Most Viewed Products */
	SELECT @MostViewedProducts = COUNT(DISTINCT MV.ShortItemNumber) FROM [dbo].SC_WebSiteItemHits MV WHERE MV.InstallationID = @StoreId AND MV.VisitDate >= @LastDailyHitsJulianDate;

GO

