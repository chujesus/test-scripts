USE [SCDBNAME] 
GO

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_DelEmailTemplateLang'))
	BEGIN
		DROP  Procedure  [dbo].EML_DelEmailTemplateLang
	END

GO


-- #desc						Delete email template record
-- #bl_class					Premier.SCMail.EmailTemplateLang.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type
-- #param @LanguagePref			Languages Preference

CREATE Procedure [dbo].EML_DelEmailTemplateLang
(
	@InstallationId NVARCHAR(3),
	@TemplateType	NVARCHAR(10),
	@LanguagePref	NVARCHAR(2)
)
AS

	DELETE 
	FROM EMAILTEMPLATELANGS
	WHERE InstallationId = @InstallationId 
		and  (@TemplateType = '*' OR TemplateType = @TemplateType)
		and	(@LanguagePref='*' OR LanguagePref = @LanguagePref)
GO 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_DelEmailTemplate'))
	BEGIN
		DROP  Procedure  [dbo].EML_DelEmailTemplate
	END

GO

-- #desc						Delete email template record
-- #bl_class					Premier.SCMail.EmailTemplate.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type

CREATE Procedure [dbo].EML_DelEmailTemplate
(
	@InstallationId NVARCHAR(3),
	@TemplateType	NVARCHAR(10)	
)
AS
	SET XACT_ABORT ON
		
	BEGIN TRAN

		EXEC [dbo].EML_DelEmailTemplateLang @InstallationId, @TemplateType, '*'

		DELETE 
		FROM EMAILTEMPLATE
		WHERE InstallationId = @InstallationId
				AND (@TemplateType = '*' OR TemplateType = @TemplateType)

	COMMIT TRAN
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetMatrixSegmentExtendedPropertyLangs'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetMatrixSegmentExtendedPropertyLangs
	END

GO
-- #desc				
-- #dll					
-- #class				
-- #method				
-- #Dependencies
-- #References

CREATE Procedure [dbo].INV_GetMatrixSegmentExtendedPropertyLangs
(
	@Template				NVARCHAR(20),
	@Style					NVARCHAR(10),
	@SegmentNumber			DECIMAL(18, 0),
	@AttributeValue			NVARCHAR(256),
	@DefaultLanguage		VARCHAR(2)
)
AS
BEGIN 
	SELECT
		Template		AS Template, 
		Segment1		AS Segment1,
		Segment			AS Segment,
		AttributeCode	AS AttributeCode,
		OverrideAttributeCode  AS OverrideAttributeCode,
		Description		AS Description,
		Title			As Title,
		Language		AS Language
	FROM
		[dbo].SC_AttributesExtended A--Get the description for Default language
	WHERE A.Template = @Template AND A.Style = @Style AND A.SegmentNumber = @SegmentNumber AND A.AttributeValue = @AttributeValue AND A.Language != @DefaultLanguage
END
GO
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcUpdItemServerFileStatus'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcUpdItemServerFileStatus
	END

GO

-- #desc					Update image status By ItemNumber
-- #bl_class				Premier.Inventory.CatalogItemMediaFiles.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @InstallationID   Installation ID /*The parameter is required. Images from this installation and also from BASE will be updated*/
-- #param @ItemNumber       Item Number /*Zero to update the MediaFileStatus to ALL item images for the @InstallationID*/
-- #param @MediaFileStatus	Media File Status

CREATE Procedure [dbo].INV_ExcUpdItemServerFileStatus
(
	@InstallationID			NVARCHAR(3),
	@ItemNumber			    DECIMAL,
	@MediaFileStatus	    NVARCHAR(3)
)
AS

	IF(@ItemNumber > 0) BEGIN  
		WITH item AS
		(
			SELECT 
				MediaFileUniqueID 
			FROM [dbo].CATALOGITEMMEDIAFILE A
			WHERE 
				A.ItemNumber = @ItemNumber
				AND (A.InstallationID = @InstallationID OR A.InstallationID = '***')
		)
		UPDATE 
			serverT
		SET
			MediaFileStatus = @MediaFileStatus
		FROM [dbo].CATALOGSERVERMEDIAFILE serverT
		INNER JOIN item
			ON item.MediaFileUniqueID = serverT.MediaFileUniqueID
	END
	ELSE BEGIN
		UPDATE 
			[dbo].CATALOGSERVERMEDIAFILE
		SET
			MediaFileStatus = @MediaFileStatus
		WHERE
			InstallationID = @InstallationID OR InstallationID = '***'
	END
GO

   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcUpdServerMediaFileStatus'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcUpdServerMediaFileStatus
	END

GO

-- #desc						Update Status Catalog Server Media File
-- #bl_class					Premier.Inventory.CatalogServerMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID
-- #param @MediaFileUniqueID	Media File UniqueID
-- #param @ServerName		    Server Name
-- #param @MediaFileStatus		Media File Status

CREATE Procedure [dbo].INV_ExcUpdServerMediaFileStatus
(
	@InstallationID			NVARCHAR(3),
    @MediaFileUniqueID      DECIMAL,
    @ServerName             NVARCHAR(128),
    @MediaFileStatus        NVARCHAR(3)
)
AS
	
	UPDATE	CATALOGSERVERMEDIAFILE
	SET
        MediaFileStatus     = @MediaFileStatus
	WHERE 
	    (@InstallationID = '*' OR InstallationID = @InstallationID)
	    AND (@ServerName = '*' OR ServerName = @ServerName)
		AND MediaFileUniqueID   = @MediaFileUniqueID
GO 
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_DelCatalogItemMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_DelCatalogItemMediaFile
	END

GO

-- #desc						Del Catalog Media File
-- #bl_class					Premier.Inventory.CatalogItemMediaFile.cs/CatalogItemMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Product Number
-- #param @MediaFileUniqueID	Media File UniqueID If 0 then mark as 'DEL' all records with the @InstallationID and @ItemNumber ELSE Mark as 'DEL' the image for all machines.
-- #param @ExistProductContent	Exist Product Content Indicates if  exist product content extended information for the desired product number, 0 if not exists, 1 if exist.

CREATE Procedure [dbo].INV_DelCatalogItemMediaFile
(
	@InstallationID         NVARCHAR(3),
	@ItemNumber             DECIMAL,
	@MediaFileUniqueID      DECIMAL,
	@ExistProductContent    NVARCHAR(1)
)
AS

	DECLARE @ITEMSONSOMECAT TABLE(
		ShortProductNumber DECIMAL UNIQUE
    )    

    --Products referenced by other catalogs  with same store
    INSERT INTO @ITEMSONSOMECAT(ShortProductNumber)
        SELECT DISTINCT A.ShortItemNumber 
        FROM SC_CatalogNodeItems A
        WHERE A.InstallationID = @InstallationID  and A.ShortItemNumber = @ItemNumber 

	/* 			 
	* Do not delete if product has extended information		 
	* Do not delete if product is referenced by other catalog			 
	*/
    DELETE [dbo].SC_ItemMaster 
    FROM [dbo].SC_ItemMaster A
    WHERE A.InstallationID = @InstallationID and
    A.ShortItemNumber = @ItemNumber and
    A.ShortItemNumber NOT IN (SELECT DISTINCT ShortProductNumber FROM @ITEMSONSOMECAT) 
	and @ExistProductContent = 'N';

	IF (@MediaFileUniqueID = 0) 
		BEGIN 
			EXEC [dbo].INV_ExcUpdItemServerFileStatus @InstallationID, @ItemNumber, 'DEL'
		END 
	ELSE   
		BEGIN
			EXEC [dbo].INV_ExcUpdServerMediaFileStatus @InstallationID, @MediaFileUniqueID, '*', 'DEL';
		END

	DELETE 
	FROM CATALOGITEMMEDIAFILE
	WHERE
	        InstallationID      = @InstallationID	--Required
		AND (ItemNumber          = @ItemNumber OR @ItemNumber = 0) --Zero for ALL
		AND (MediaFileUniqueID   = @MediaFileUniqueID OR @MediaFileUniqueID = 0) --Zero for ALL

GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_UpdCatalogMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_UpdCatalogMediaFile
	END

GO

-- #desc						Update Catalog Media File
-- #bl_class					Premier.Inventory.CatalogMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation id
-- #param @MediaFileUniqueID	Media File UniqueID
-- #param @MediaFileName		Media File Name installation id
-- #param @MediaFileType		Media File Type installation id
-- #param @MediaFileComments	Media File Comments  
-- #param @UserUpdate		    User Update
-- #param @LastDateUpdated		Last Date Updated
-- #param @LastTimeUpdated		Last Time Updated

CREATE Procedure [dbo].INV_UpdCatalogMediaFile
(
    @MediaFileUniqueID      DECIMAL,
    @MediaFileName          NVARCHAR(128),
    @MediaFileType          NVARCHAR(2),
    @MediaFileComments      NVARCHAR(512),
    @UserUpdate             NVARCHAR(30),
    @LastDateUpdated        DECIMAL,
    @LastTimeUpdated        DECIMAL
)
AS
	
	UPDATE [dbo].CATALOGMEDIAFILE
	SET
	    MediaFileName = @MediaFileName,
	    MediaFileType = @MediaFileType,
	    MediaFileComments = @MediaFileComments,
	    UserUpdate = @UserUpdate,
	    LastDateUpdated = @LastDateUpdated,
	    LastTimeUpdated = @LastTimeUpdated	    
	WHERE
		MediaFileUniqueID = @MediaFileUniqueID 

GO 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_AddCatalogMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_AddCatalogMediaFile
	END

GO

-- #desc						Add Catalog Media File
-- #bl_class					Premier.Inventory.CatalogMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation id
-- #param @MediaFileUniqueID	Media File UniqueID
-- #param @MediaFileName		Media File Name
-- #param @MediaFileType		Media File Type
-- #param @InstallationOwner	Installation Owner
-- #param @MediaFileComments	Media File Comments  
-- #param @MediaFileBody		Media File Body 
-- #param @MediaFileThumbnail   Media File Thumbnail
-- #param @DateInsert		    Date Insert
-- #param @TimeInsert		    Time Insert
-- #param @UserInsert		    User Insert
-- #param @LastDateUpdated		Last Date Updated
-- #param @LastTimeUpdated		Last Time Updated
-- #param @AddImageMode			Add Image Mode /* 0 Overwrite, 1 Keep both, 2 Skip */
-- #param @OriginalFileName		Original File Name

CREATE Procedure [dbo].INV_AddCatalogMediaFile
(
	@MediaFileUniqueID      DECIMAL OUTPUT,
    @MediaFileName          NVARCHAR(128),
    @MediaFileType          NVARCHAR(2),
    @ReSizeConstantPolicy   NVARCHAR(30),
    @InstallationOwner		NVARCHAR(3),
    @MediaFileComments      NVARCHAR(512),
    @MediaFileBody          varbinary(MAX),
	@MediaFileThumbnail		VARBINARY(MAX),
    @DateInsert             DECIMAL,
    @TimeInsert             DECIMAL,
    @UserInsert             NVARCHAR(30),
    @LastDateUpdated        DECIMAL,
    @LastTimeUpdated        DECIMAL,
	@AddImageMode			INT,	/* 0 Overwrite, 1 Keep both, 2 Skip */
	@OriginalFileName		NVARCHAR(128)
)
AS
	/* Generate CheckSum to compare images with different MediaFileName and MediaFileUniqueID
	 * Generates an INT 
	 */
	DECLARE @MediaFileCheckSum INT = BINARY_CHECKSUM(@MediaFileBody);
	/* Upload images process */
	DECLARE @InsertImage INT = 1;	/* Flag to determine if insert new image */
	DECLARE @OldMediaFileUniqueID DECIMAL = NULL;	/* Media File Unique ID to be deleted if the mode is Overwrite */
	DECLARE @ItemNumber DECIMAL = NULL;		/* Item Number Media File */
	DECLARE @InstallationID NVARCHAR(3) = NULL;
	
	/* Calculate MediaFileUniqueID before Overwrite images to avoid duplicated keys in ItemMediaFile table */
	IF(@MediaFileUniqueID = 0 OR @MediaFileUniqueID IS NULL)
	BEGIN
		SET @MediaFileUniqueID = (SELECT MAX (MediaFileUniqueID)+1 FROM [dbo].CATALOGMEDIAFILE );
		--SET 1 IF THE MAX IS NULL
		IF(@MediaFileUniqueID IS NULL)
		BEGIN
			SET @MediaFileUniqueID = 1
		END
	END

	IF (@AddImageMode <> 1) /* 0 Overwrite, 2 Skip */
	BEGIN
		/* Get Media File Unique ID and Short Item Number based on OriginalFileName */
		SELECT @OldMediaFileUniqueID = A.MediaFileUniqueID, @ItemNumber = B.ItemNumber, @InstallationID = B.InstallationID 
		FROM [dbo].CATALOGMEDIAFILE A 
			INNER JOIN [dbo].CATALOGITEMMEDIAFILE B 
			ON B.MediaFileUniqueID = A.MediaFileUniqueID
		WHERE A.OriginalFileName = @OriginalFileName;

		/* Validate if exists image */
		IF (@OldMediaFileUniqueID IS NOT NULL) 
		BEGIN
			IF (@AddImageMode = 0)	/* 0 Overwrite, Delete images with the same OriginalFileName and add new */
			BEGIN
				/* Delete Item Media File relation */
				EXEC [dbo].INV_DelCatalogItemMediaFile @InstallationID, @ItemNumber, @OldMediaFileUniqueID;
			END;
			ELSE
			BEGIN	/* 2 Skip new image if exists one with the same OriginalFileName */
				SET @InsertImage = 0;
			END;
		END;
	END;
	
	IF(@InsertImage = 1)
	BEGIN

		INSERT INTO [dbo].CATALOGMEDIAFILE
		(
			MediaFileUniqueID,
			MediaFileName,
			MediaFileType,
			ReSizeConstantPolicy,
			InstallationOwner,
			MediaFileComments,
			MediaFileBody,
			MediaFileThumbnail,
			MediaFileCheckSum,
			DateInsert,
			TimeInsert,
			UserInsert,
			LastDateUpdated,
			LastTimeUpdated,
			OriginalFileName
		)
		VALUES
		(
			@MediaFileUniqueID,
			@MediaFileName,
			@MediaFileType,
			@ReSizeConstantPolicy,
			@InstallationOwner,
			@MediaFileComments,
			@MediaFileBody,
			@MediaFileThumbnail,
			@MediaFileCheckSum,
			@DateInsert,
			@TimeInsert,
			@UserInsert,
			@LastDateUpdated,
			@LastTimeUpdated,
			@OriginalFileName
		);
	END
	ELSE 
	BEGIN
		SET @MediaFileUniqueID = 0;
	END;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigrationExeTrace'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigrationExeTrace
	END

GO

-- #desc					Get Migration Trace
-- #bl_class				Premier.eCommerce.GetMigrationExecutingTraceCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param MigrationId		Migration Id

CREATE Procedure [dbo].ECO_GetMigrationExeTrace
(
	@MigrationId		UNIQUEIDENTIFIER
)
AS

	SELECT 
		A.ExecutingTrace
	FROM 
		[dbo].SC_MigrationSummary A
	WHERE
		A.MigrationId = @MigrationId;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].ECO_GetMigrationSummaryList'))
	BEGIN
		DROP  Procedure  [dbo].ECO_GetMigrationSummaryList
	END

GO

-- #desc					Reads the list of Migrations 
-- #bl_class				Premier.eCommerce.MigrationSummaryList.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param MigrationType		Migration Type
-- #param MigrationStatus	Migration Status
-- #param DateTimeFrom		Date Time From
-- #param DateTimeTo		Date Time To

CREATE Procedure [dbo].ECO_GetMigrationSummaryList
(
	@MigrationType		INT,
	@MigrationStatus	INT,
	@DateTimeFrom		DATETIME2(7),
	@DateTimeTo			DATETIME2(7)
)
AS

	SELECT 
		A.MigrationId,
		A.MigrationType,
		A.MigrationMode,
		A.ContentStatus,
		A.MigrationStatus,
		A.ReportUrl,
		A.StartDateTime,
		A.DateUpdated
	FROM 
		[dbo].SC_MigrationSummary A
	WHERE
		(@MigrationType IS NULL OR A.MigrationType = @MigrationType) 
		AND (@MigrationStatus IS NULL OR A.MigrationStatus = @MigrationStatus)
		AND (@DateTimeFrom IS NULL OR A.DateUpdated BETWEEN @DateTimeFrom AND @DateTimeTo)
	ORDER BY A.DateUpdated DESC;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].CMM_DelInstallation'))
	BEGIN
		DROP  Procedure  [dbo].CMM_DelInstallation
	END

GO

-- #desc					Deletes an Installation description.
-- #bl_class				Premier.Common.Store.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @InstallationID	Installation ID.

CREATE Procedure [dbo].CMM_DelInstallation
	@InstallationID NVARCHAR(3)

AS
SET NOCOUNT ON
BEGIN
	/* Dynamic */
	DECLARE @SQL_DYNAMIC NVARCHAR(MAX);
	
	--Declare items where not are in others installations
	CREATE TABLE #FILTERTABLEITEMSNOTHERSINST
	(
			ShortItemNumber DECIMAL UNIQUE
	)		
	
	--Items where not are in others installations
	INSERT INTO #FILTERTABLEITEMSNOTHERSINST(ShortItemNumber)
	  SELECT DISTINCT ShortItemNumber 
		FROM SC_ItemMaster
		WHERE InstallationID = @InstallationID AND 
			  ShortItemNumber NOT IN (SELECT ShortItemNumber FROM SC_ItemMaster WHERE InstallationID <> @InstallationID) ;
	
	/* Obsolete functionality */
	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_ItemMasterRelated')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE
								FROM [dbo].SC_ItemMasterRelated
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_ItemAttributesLang')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE A
								FROM [dbo].SC_ItemAttributesLang A
								WHERE EXISTS (SELECT 1 FROM #FILTERTABLEITEMSNOTHERSINST B WHERE B.ShortItemNumber = A.ShortItemNumber); ';
		EXECUTE sp_executesql @SQL_DYNAMIC;
	END;
	/* Obsolete functionality */

	--DELETE SC_ItemMasterLangs
	DELETE 
	FROM SC_ItemMasterLangs
	WHERE InstallationID = @InstallationID;
	
	--Delete Catalog Langs
	DELETE
	FROM SC_CatalogLangs
	WHERE InstallationID =@InstallationID;
	
	/* Obsolete functionality */
	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_CatalogNodeAttributesPriority')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_CatalogNodeAttributesPriority
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_ItemAttributes')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE A
								FROM [dbo].SC_ItemAttributes A
								WHERE EXISTS (SELECT 1 FROM #FILTERTABLEITEMSNOTHERSINST B WHERE B.ShortItemNumber = A.ShortItemNumber); ';
		EXECUTE sp_executesql @SQL_DYNAMIC;
	END;
	/* Obsolete functionality */


	--Delete  Catalog Node Items
	DELETE 
	FROM SC_CatalogNodeItems
	WHERE InstallationID = @InstallationID;
		
	--Delete  Catalog Node Items
	DELETE 
	FROM SC_ItemMaster
	WHERE InstallationID = @InstallationID;
	
	/* Obsolete functionality */
	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_TagAnnouncementAssignment')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_TagAnnouncementAssignment 
								WHERE CatalogID IN (SELECT CatalogID FROM [dbo].SC_Catalog_NSM WHERE INSTALLATIONID = @InstallationID) AND AssignmentType = 0; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;
	/* Obsolete functionality */

	--Delete  Catalog Node Items
	DELETE 
	FROM SC_Catalog_NSM
	WHERE InstallationID = @InstallationID;

	/* Obsolete functionality */
	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_CatalogNodeItemsRestrictions')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_CatalogNodeItemsRestrictions
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_MatrixChildrenMaster')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_MatrixChildrenMaster
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_MatrixTemplateMaster')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_MatrixTemplateMaster
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_CustomerItemCrossReference')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE A
								FROM [dbo].SC_CustomerItemCrossReference A
								WHERE EXISTS (SELECT 1 FROM #FILTERTABLEITEMSNOTHERSINST B WHERE B.ShortItemNumber = A.ShortItemNumber); ';
		EXECUTE sp_executesql @SQL_DYNAMIC;
	END;

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_CustomerItemRestrictions')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE A
								FROM [dbo].SC_CustomerItemRestrictions A
								WHERE EXISTS (SELECT 1 FROM #FILTERTABLEITEMSNOTHERSINST B WHERE B.ShortItemNumber = A.ShortItemNumber); ';
		EXECUTE sp_executesql @SQL_DYNAMIC;
	END;
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_WebSiteItemHits')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_WebSiteItemHits
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_WebSiteItemHitsConf')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_WebSiteItemHitsConf
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	/* Obsolete functionality */

	--Delete Announcements Relation
	IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'U' AND id = OBJECT_ID(N'[dbo].SC_AnnouncementInstallations')) BEGIN
		SET @SQL_DYNAMIC = N' DELETE 
								FROM [dbo].SC_AnnouncementInstallations
								WHERE InstallationID = @InstallationID; ';
		EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3) ', @InstallationID = @InstallationID;
	END;

	--Delete EmailTemplate Langs
	exec [dbo].EML_DelEmailTemplateLang @InstallationID,'*', '*';

	--Delete EmailTemplate
	exec [dbo].EML_DelEmailTemplate @InstallationID, '*';

	--Delete Print Documents
	DELETE
	FROM SC_PrintDocuments
	WHERE InstallationID = @InstallationID;

	--Delete P4210 Versions
	DELETE 
	FROM [dbo].SC_P4210Versions
	WHERE InstallationID = @InstallationID;

	DROP TABLE #FILTERTABLEITEMSNOTHERSINST;
END;	


GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND id = OBJECT_ID(N'[dbo].CMM_GetCurrentJulianDate'))
	BEGIN
		DROP  FUNCTION  [dbo].CMM_GetCurrentJulianDate
	END
GO

CREATE FUNCTION [dbo].CMM_GetCurrentJulianDate
(@currentDate DATETIME )
RETURNS INTEGER
AS
BEGIN

RETURN CONVERT( INTEGER , CONVERT(NVARCHAR, DATEPART(yy, @currentDate)-1900) + RIGHT('000' + CONVERT(NVARCHAR,DATEPART(dy, @currentDate)),3))

END

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND id = OBJECT_ID(N'[dbo].CMM_GetFullTextQueryTerms'))
	BEGIN
		DROP FUNCTION  [dbo].CMM_GetFullTextQueryTerms
	END
GO

-- #desc					Create search text condition to be use in Full-Text Search queries. 
--							Using "Prefix Term" and "Weighted Term" Forms
-- #bl_class				N/A
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @FilterTerm		Search Criteria
-- #param @AnyWord			Filter with "OR" or Filter with "AND". 0 = OR 1 = AND

CREATE FUNCTION [dbo].CMM_GetFullTextQueryTerms
(
	@FilterTerm	NVARCHAR(4000),
	@AnyWord    DECIMAL
)
RETURNS NVARCHAR(4000)
AS
BEGIN

	DECLARE @SearchText NVARCHAR(4000) = ''
	DECLARE @Word NVARCHAR(4000) = ''
	DECLARE @Weight FLOAT = 1
	DECLARE @length INT
		
	SET @FilterTerm = LTRIM(RTRIM(REPLACE(@FilterTerm,'''','''''')));/*Replace special caracters*/
		
	WHILE (LEN(@FilterTerm) > 0)/*Parse input string to use the ISABOUT function and assign weight to the words*/
	BEGIN
		IF(SUBSTRING(@FilterTerm, 1, 1) = '"' AND CHARINDEX('"', @FilterTerm, 2) > 0)/*words between quotes(")*/
		BEGIN
			SET @length = CHARINDEX('"', @FilterTerm, 2)/*Get closing quote(")*/
			SET @Word = LTRIM(RTRIM(SUBSTRING(@FilterTerm, 2, @length - 2)))
		END
		ELSE
		BEGIN
			SET @length = CHARINDEX(' ', @FilterTerm) - 1/*There are multiple words*/
			IF(@length <= 0)
				SET @length = LEN(@FilterTerm)
			SET @Word = REPLACE(SUBSTRING(@FilterTerm, 1, @length),'"','')/*Remove single quotes*/
		END
			
		IF (LEN(@Word) > 0)
		BEGIN
			IF(@AnyWord = 0)
				BEGIN
					IF(LEN(@SearchText) > 0)
						SET @SearchText = @SearchText + ', '
					SET @SearchText = @SearchText + '"' + @Word + '*" WEIGHT(' + CAST(@Weight AS NVARCHAR(MAX)) + ')'
					SET @Weight = (@Weight * 0.8)
				END
			ELSE 
			BEGIN
				IF(LEN(@SearchText) > 0)
					SET @SearchText = @SearchText + ' AND '
				SET @SearchText = @SearchText + '"' + @Word + '*"'					
			END
		END
			
		SET @FilterTerm = LTRIM(SUBSTRING(@FilterTerm, (@length + 1), (LEN(@FilterTerm) - @length)))	

	END
	-- End While
		
	-- Parsed string
	IF(@SearchText <> '' AND @AnyWord = 0)
		SET @SearchText = 'ISABOUT('+ @SearchText + ')'
	
	RETURN @SearchText

END

GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].CMM_GetInstallationDelStatInfo'))
	BEGIN
		DROP  Procedure  [dbo].CMM_GetInstallationDelStatInfo
	END

GO
-- #desc						Get the row count of installation related tables.
-- #bl_class					Premier.Common.StoreDeleteStatInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID.
-- #param IsECOMInstallation	IsECOMInstallation

CREATE Procedure [dbo].CMM_GetInstallationDelStatInfo
(
	@InstallationID			NVARCHAR(3),	
	@IsECOMInstallation     INT,
	@TotalCatalogsCount		DECIMAL = NULL OUTPUT,	
	@MostViewedItems		DECIMAL = NULL OUTPUT,
	@EmailTemplates			DECIMAL = NULL OUTPUT,
	@PrintDocuments			DECIMAL = NULL OUTPUT,
	@P4210Versions			DECIMAL = NULL OUTPUT
)
AS
	SET NOCOUNT ON	
BEGIN
		
	IF (@IsECOMInstallation = 0) BEGIN
		--Catalogs To Delete
		SET @TotalCatalogsCount = (SELECT COUNT(*) FROM SC_Catalog_NSM WHERE InstallationID = @InstallationID AND NodeID=0);
	END;

	--Email Templates 
	SET @EmailTemplates = (SELECT COUNT(*) FROM EMAILTEMPLATE WHERE InstallationID = @InstallationID);

	--Printed Documents
	SET @PrintDocuments = (SELECT COUNT(*) FROM SC_PrintDocuments WHERE InstallationID = @InstallationID);

	--P4210 Versions
	SET @P4210Versions = (SELECT COUNT(1) FROM [dbo].SC_P4210Versions WHERE InstallationID = @InstallationID);

END;					
		
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_AddP4210Version'))
	BEGIN
		DROP  Procedure  [dbo].COM_AddP4210Version
	END

GO

-- #desc						Add P4210 Version
-- #bl_class					Premier.Commerce.P4210Version.cs		
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence OUT,
-- #param @InstallationId		Current installation id
-- #param @Description			Description.
-- #param @Sequence				Sequence.
-- #param @VersionType			Version Type.
-- #param @SVersion				SVersion type.
-- #param @CCVersion			CCVersion.

CREATE Procedure [dbo].COM_AddP4210Version
(
	@RecordUniqueID		DECIMAL OUT,
	@InstallationID		NVARCHAR(3),
	@Description		NVARCHAR(60),
	@Sequence			DECIMAL,
	@VersionType		NVARCHAR(1),
	@SVersion			NVARCHAR(10),
	@CCVersion			NVARCHAR(10)
)
AS
	
	INSERT INTO [dbo].SC_P4210Versions
	(
		InstallationID,	
		Description,
		Sequence,
		VersionType,
		SVersion,
		CCVersion
	)
	VALUES
	(
		@InstallationID,	
		@Description,
		@Sequence,
		@VersionType,
		@SVersion,
		@CCVersion
	)
	SET @RecordUniqueID = (ISNULL((SELECT MAX (RecordUniqueID) FROM [dbo].SC_P4210Versions),0) )

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_AddSalesOrderFile'))
	BEGIN
		DROP  Procedure  [dbo].COM_AddSalesOrderFile
	END

GO

-- #desc						Create temporal order record
-- #bl_class					Premier.Commerce.SalesOrderFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence OUT,
-- #param @InstallationId		Current installation id
-- #param @RegisterId			Current register id POS only
-- #param @DocumentType			Document type , T=Temporal, F=Fail
-- #param @DocumentID			Customer Mailing Name for Temporal, OrderType + OrderNumber for FailOrders
-- #param @DocumentBody			Document Body
-- #param @Status				Status A=Active,I=Inactive
-- #param @UserInsert			SC User ID,
-- #param @DateInsert			Date record created
-- #param @TimeInsert			Time record created
-- #param @UserUpdate			Audit JDE User
-- #param @LastDateUpdated		Audit Last Date Updated
-- #param @LastTimeUpdated		Audit Last Time Updated

CREATE Procedure [dbo].COM_AddSalesOrderFile
(
	@RecordUniqueID		DECIMAL OUT,
	@InstallationId		NVARCHAR(3),
	@RegisterId			NVARCHAR(30),
	@DocumentType		NVARCHAR(2),
	@DocumentID			NVARCHAR(128),
	@DocumentBody		VARBINARY(MAX),
	@Status				NVARCHAR(2),	
	@UserInsert			NVARCHAR(30),
	@DateInsert			DECIMAL,
	@TimeInsert			DECIMAL,
	@UserUpdate			NVARCHAR(30),
	@LastDateUpdated	DECIMAL,
	@LastTimeUpdated	DECIMAL
)
AS

	--Get max sequence number
	SET @RecordUniqueID = (ISNULL((SELECT MAX (RecordUniqueID) FROM SALESORDERFILE),0) + 1)
	
	INSERT INTO 
		SALESORDERFILE
	(
		RecordUniqueID,	
		InstallationId,	
		RegisterId,		
		DocumentType,	
		DocumentID,		
		DocumentBody,	
		Status,			
		UserInsert,		
		DateInsert,		
		TimeInsert,		
		UserUpdate,		
		LastDateUpdated,
		LastTimeUpdated
	
	)
	VALUES
	(
		@RecordUniqueID,	
		@InstallationId,	
		@RegisterId,		
		@DocumentType,	
		@DocumentID,		
		@DocumentBody,	
		@Status,			
		@UserInsert,		
		@DateInsert,		
		@TimeInsert,		
		@UserUpdate,		
		@LastDateUpdated,
		@LastTimeUpdated	
	)

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_DelP4210Version'))
	BEGIN
		DROP  Procedure  [dbo].COM_DelP4210Version
	END

GO

-- #desc						Delete a record from P4210 Version table
-- #bl_class					Premier.Commerce.P4210Version.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence

CREATE Procedure [dbo].COM_DelP4210Version
(
	@RecordUniqueID DECIMAL
)
AS

	DELETE 
	FROM [dbo].SC_P4210Versions
	WHERE RecordUniqueID = @RecordUniqueID

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_DelSalesOrderFile'))
	BEGIN
		DROP  Procedure  [dbo].COM_DelSalesOrderFile
	END

GO

-- #desc						Delete temporal order record
-- #bl_class	 	 			Premier.Commerce.P4210Version.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence

CREATE Procedure [dbo].COM_DelSalesOrderFile
(
	@RecordUniqueID DECIMAL
)
AS

	DELETE 
	FROM SALESORDERFILE
	WHERE RecordUniqueID = @RecordUniqueID

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_ExcPurgeSalesOrderFiles'))
	BEGIN
		DROP  Procedure  [dbo].COM_ExcPurgeSalesOrderFiles
	END

GO

-- #desc						Delete temporal OLD order record
-- #bl_class	 	 			Premier.Commerce.SalesOrderFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Current installation id
-- #param @DocumentType			Document type , T=Temporal, F=Fail
-- #param @DateInsert			Date record created

CREATE Procedure [dbo].COM_ExcPurgeSalesOrderFiles
(
	@InstallationID		NVARCHAR(3),
	@DocumentType		NVARCHAR(2),
	@DateTicket			DECIMAL
)
AS

	DELETE	FROM 
		SALESORDERFILE
	WHERE
		(@InstallationID = '*' OR InstallationId  = @InstallationID) AND
		DocumentType = @DocumentType AND
		(DateInsert < @DateTicket)

GO 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_GetP4210Version'))
	BEGIN
		DROP  Procedure  [dbo].COM_GetP4210Version
	END

GO

-- #desc						Reads P4210 Version record
-- #bl_class	 	 			Premier.Commerce.P4210Version.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence

CREATE Procedure [dbo].COM_GetP4210Version
(
	@RecordUniqueID DECIMAL
)
AS

	SELECT 
		RecordUniqueID,
		InstallationID,	
		Description,
		Sequence,
		VersionType,
		SVersion,
		CCVersion
	FROM 
		[dbo].SC_P4210Versions
	WHERE
		RecordUniqueID = @RecordUniqueID

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_GetP4210VersionList'))
	BEGIN
		DROP  Procedure  [dbo].COM_GetP4210VersionList
	END

GO

-- #desc						Reads the list of P4210 Version records for and specific intallation and Version type
-- #bl_class					Premier.Commerce.P4210VersionList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Current installation id
-- #param @VersionType			Version Type

CREATE Procedure [dbo].COM_GetP4210VersionList
(
	@InstallationID		NVARCHAR(3),
	@VersionType		NVARCHAR(3)
)
AS

	SELECT 
		RecordUniqueID,
		InstallationID,	
		Description,
		Sequence,
		VersionType,
		SVersion,
		CCVersion
	FROM 
		[dbo].SC_P4210Versions
	WHERE
		InstallationID = @InstallationID AND
		(@VersionType = '*' OR VersionType = @VersionType)
		ORDER BY Sequence DESC, Description
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_GetP4210Versions'))
	BEGIN
		DROP  Procedure  [dbo].COM_GetP4210Versions
	END

GO

-- #desc						Reads P4210 Version record
-- #bl_class	 	 			Premier.Commerce.P4210Versions.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence

CREATE Procedure [dbo].COM_GetP4210Versions
(
	@InstallationID		NVARCHAR(3),
	@FilterTerm			NVARCHAR(60),
	@VersionType		NVARCHAR(3)
)
AS

	SELECT 
		RecordUniqueID,
		InstallationID,	
		Description,
		Sequence,
		VersionType,
		SVersion,
		CCVersion
	FROM 
		[dbo].SC_P4210Versions
	WHERE
		InstallationID = @InstallationID AND
		(@VersionType = '*' OR VersionType = @VersionType) AND 
		(@FilterTerm = '*' OR Description LIKE '%'+ @FilterTerm +'%' OR SVersion LIKE '%'+ @FilterTerm +'%' OR CCVersion LIKE '%'+ @FilterTerm +'%' )
		ORDER BY VersionType, Sequence DESC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_GetSalesOrderFile'))
	BEGIN
		DROP  Procedure  [dbo].COM_GetSalesOrderFile
	END

GO

-- #desc						Reads temporal order record
-- #bl_class	 	 			Premier.Commerce.SalesOrderFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence

CREATE Procedure [dbo].COM_GetSalesOrderFile
	(
		@RecordUniqueID DECIMAL
	)
AS

	SELECT 
		RecordUniqueID,
		InstallationId,
		RegisterId,
		DocumentType,
		DocumentID,
		DocumentBody,
		DATALENGTH(DocumentBody) AS DocFileLength,
		Status,
		UserInsert,
		DateInsert,
		TimeInsert,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated
	FROM 
		SALESORDERFILE
	WHERE
		RecordUniqueID = @RecordUniqueID

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_GetSalesOrderFileList'))
	BEGIN
		DROP  Procedure  [dbo].COM_GetSalesOrderFileList
	END

GO

-- #desc						Load Temporal Order list
-- #bl_class					Premier.Commerce.SalesOrderFiles.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Current installation id
-- #param @DocumentType			Document type , T=Temporal, F=Fail
-- #param @DocumentID			Customer Mailing Name for Temporal, OrderType+OrderNumber for FailOrders
-- #param @Status				Status A=Active,I=Inactive



CREATE Procedure [dbo].COM_GetSalesOrderFileList
	(
		@InstallationId		NVARCHAR(3),
		@DocumentType		NVARCHAR(2),
		@Status				NVARCHAR(2),
		@DocumentID			NVARCHAR(128),
		@PageIndex			DECIMAL,
		@PageSize			DECIMAL,
		@TotalRowCount		int OUTPUT
	)
AS
	BEGIN
	DECLARE @TMP_TABLE TABLE
	(
		nID int identity,
		RecordUniqueID		decimal,
		InstallationId		NVARCHAR(3),
		RegisterId			NVARCHAR(30),
		DocumentType		NVARCHAR(2),
		DocumentID			NVARCHAR(128),
		Status				NVARCHAR(2),	
		UserInsert			NVARCHAR(30),
		DateInsert			decimal,
		TimeInsert			decimal,
		UserUpdate			NVARCHAR(30),
		LastDateUpdated		decimal,
		LastTimeUpdated		decimal
		)SET NOCOUNT ON;
		
	DECLARE @ROWSTART int
	DECLARE @ROWEND int
		
	INSERT INTO @TMP_TABLE
	(
		RecordUniqueID,	
		InstallationId,	
		RegisterId,		
		DocumentType,	
		DocumentID,		
		Status,			
		UserInsert,		
		DateInsert,		
		TimeInsert,		
		UserUpdate,		
		LastDateUpdated,
		LastTimeUpdated
	)
		(SELECT 
			RecordUniqueID,	
			InstallationId,	
			RegisterId,		
			DocumentType,	
			DocumentID,		
			Status,			
			UserInsert,		
			DateInsert,		
			TimeInsert,		
			UserUpdate,		
			LastDateUpdated,
			LastTimeUpdated
		FROM 
			SALESORDERFILE
		WHERE
			(@InstallationId = '*' OR InstallationId = @InstallationId) AND
			(@DocumentType = '*' OR  DocumentType = @DocumentType) AND
			(@Status = '*' OR Status = @Status) AND
			(@DocumentID = '*' OR DocumentID LIKE '%' + @DocumentID + '%'))
			
		SELECT @TotalRowCount = COUNT(*)
		  FROM @TMP_TABLE

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
END

SELECT * FROM @TMP_TABLE
WHERE nID BETWEEN  @ROWSTART AND @ROWEND
		
		
GO
		
		


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_UpdP4210Version'))
	BEGIN
		DROP  Procedure  [dbo].COM_UpdP4210Version
	END

GO

CREATE Procedure [dbo].COM_UpdP4210Version
(
	@RecordUniqueID		DECIMAL,
	@InstallationID		NVARCHAR(3),
	@Description		NVARCHAR(60),
	@Sequence			DECIMAL,
	@VersionType		NVARCHAR(1),
	@SVersion			NVARCHAR(10),
	@CCVersion			NVARCHAR(10)
)
AS
	
	UPDATE [dbo].SC_P4210Versions
	SET
		InstallationID = @InstallationID,
		Description = @Description,
		Sequence = @Sequence,
		VersionType = @VersionType,
		SVersion = @SVersion,
		CCVersion = @CCVersion
	WHERE RecordUniqueID = @RecordUniqueID

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].COM_UpdSalesOrderFile'))
	BEGIN
		DROP  Procedure  [dbo].COM_UpdSalesOrderFile
	END

GO

-- #desc						Create temporal order record
-- #bl_class					Premier.Commerce.SalesOrderFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence OUT,
-- #param @InstallationId		current installation id
-- #param @RegisterId			current register id POS only
-- #param @DocumentType			Document type , T=Temporal, F=Fail
-- #param @DocumentID			Customer Mailing Name for Temporal, OrderType + OrderNumber for FailOrders
-- #param @Status				Status A=Active,I=Inactive
-- #param @UserInsert			SC User ID,
-- #param @DateInsert			Date record created
-- #param @TimeInsert			Time record created
-- #param @UserUpdate			Audit JDE User
-- #param @LastDateUpdated		Audit Last Date Updated
-- #param @LastTimeUpdated		Audit Last Time Updated

CREATE Procedure [dbo].COM_UpdSalesOrderFile
(
	@RecordUniqueID		DECIMAL OUT,
	@InstallationId		NVARCHAR(3),
	@RegisterId			NVARCHAR(30),
	@DocumentType		NVARCHAR(2),
	@DocumentID			NVARCHAR(128),
	@DocumentBody		VARBINARY(MAX),
	@Status				NVARCHAR(2),	
	@UserInsert			NVARCHAR(30),
	@DateInsert			DECIMAL,
	@TimeInsert			DECIMAL,
	@UserUpdate			NVARCHAR(30),
	@LastDateUpdated	DECIMAL,
	@LastTimeUpdated	DECIMAL
)
AS
	
	UPDATE	SALESORDERFILE
	SET
		InstallationId	= @InstallationId,	
		RegisterId		= @RegisterId,		
		DocumentType	= @DocumentType,	
		DocumentID		= @DocumentID,
		DocumentBody	= @DocumentBody,
		Status			= @Status,
		UserInsert		= @UserInsert,
		DateInsert		= @DateInsert,
		TimeInsert		= @TimeInsert,
		UserUpdate		= @UserUpdate,
		LastDateUpdated = @LastDateUpdated,
		LastTimeUpdated = @LastTimeUpdated
	WHERE 
		RecordUniqueID = @RecordUniqueID
	

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_AddEmailHistory'))
	BEGIN
		DROP  PROCEDURE  [dbo].EML_AddEmailHistory
	END

GO

-- #desc						Create Email History record
-- #bl_class					Premier.SCMail.EmailHistory.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param EmailType				Email Type			
-- #param InstallationID		Installation ID	
-- #param DocumentID			Document ID		
-- #param EmailTo				Email To			
-- #param CarbonCopy			Carbon Copy (CC)
-- #param BlindCarbonCopy		Blind Carbon Copy (BCC)
-- #param EmailSubject			Email Subject		
-- #param EmailPriority			Email Priority		
-- #param EmailBody				Email Body			
-- #param UserID				User ID			
-- #param WorkStationID			Work Station ID		
-- #param DateUpdated			Date Updated		
-- #param TimeUpdated			Time Updated		

CREATE PROCEDURE [dbo].EML_AddEmailHistory
(
	@EmailType			INT,
	@InstallationID		NVARCHAR(3),
	@DocumentID			NVARCHAR(60),
	@EmailTo			NVARCHAR(MAX),
	@CarbonCopy			NVARCHAR(MAX),
	@BlindCarbonCopy	NVARCHAR(MAX),
	@EmailSubject		NVARCHAR(60),
	@EmailPriority		INT,
	@LangPref			NVARCHAR(2),
	@EmailBody			VARBINARY(MAX),
	@UserID				NVARCHAR(10),
	@WorkStationID		NVARCHAR(128),
	@DateUpdated		DECIMAL(6,0),
	@TimeUpdated		DECIMAL(6,0)
)
AS
	DECLARE @UniqueID INT;

	BEGIN TRAN
		/* Insert Email History Header */
		INSERT INTO [dbo].SC_EmailHistoryHeader
		(
			EmailType,
			InstallationID,
			DocumentID,
			EmailTo,
			CarbonCopy,
			BlindCarbonCopy,
			EmailSubject,
			EmailPriority,
			ResendDate,
			ResendTime,
			ResendTo,
			LangPref,
			UserID,
			WorkStationID,
			DateUpdated,
			TimeUpdated
		)
		VALUES
		(
			@EmailType,
			@InstallationID,
			@DocumentID,
			@EmailTo,
			@CarbonCopy,
			@BlindCarbonCopy,
			@EmailSubject,
			@EmailPriority,
			@DateUpdated,
			@TimeUpdated,
			'',
			@LangPref,
			@UserID,
			@WorkStationID,
			@DateUpdated,
			@TimeUpdated
		)

		/* Get UniqueID */
		SELECT  @UniqueID = SCOPE_IDENTITY();

		/* Insert Email History Detail*/
		INSERT INTO [dbo].SC_EmailHistoryDetail
		(
			UniqueID,
			EmailBody,
			UserID,
			WorkstationID,
			DateUpdated,
			TimeUpdated
		)
		VALUES
		(
			@UniqueID,
			@EmailBody,
			@UserID,
			@WorkstationID,
			@DateUpdated,
			@TimeUpdated
		);
	COMMIT TRAN;
GO 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_AddEmailTemplate'))
	BEGIN
		DROP  Procedure  [dbo].EML_AddEmailTemplate
	END

GO

-- #desc						Create email template record
-- #bl_class					Premier.SCMail.EmailTemplate.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type,
-- #param @TemplateName			Template Name,
-- #param @ConfigBody			Config Body,
-- #param @HTMLBody				HTML Body,
-- #param @DateInsert			Date Insert,
-- #param @TimeInsert			Time Insert,
-- #param @UserInsert			User Insert,
-- #param @UserUpdate			User Update,
-- #param @LastDateUpdated		Last Date Updated,
-- #param @LastTimeUpdated		Last Time Updated,

CREATE Procedure [dbo].EML_AddEmailTemplate
(
	@InstallationId		NVARCHAR(3),
	@Templatetype		NVARCHAR(10),
	@TemplateName		NVARCHAR(100),
	@ConfigBody			NVARCHAR(MAX),
	@HTMLBody			NVARCHAR(MAX),
	@DateInsert			DECIMAL,
	@TimeInsert			DECIMAL,
	@UserInsert			NVARCHAR(30),
	@UserUpdate			NVARCHAR(30),
	@LastDateUpdated	DECIMAL,
	@LastTimeUpdated	DECIMAL
)
AS

	INSERT INTO 
		EMAILTEMPLATE
	(
		InstallationId,
		TemplateType,
		TemplateName,
		ConfigBody,
		HTMLBody,
		DateInsert,
		TimeInsert,
		UserInsert,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated
	
	)
	VALUES
	(
		@InstallationId,
		@TemplateType,
		@TemplateName,
		@ConfigBody,
		@HTMLBody,
		@DateInsert,
		@TimeInsert,
		@UserInsert,
		@UserUpdate,
		@LastDateUpdated,
		@LastTimeUpdated
	)

GO 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_AddEmailTemplateLang'))
	BEGIN
		DROP  Procedure  [dbo].EML_AddEmailTemplateLang
	END

GO


-- #desc						Create email template record
-- #bl_class					Premier.SCMail.EmailTemplateLangList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type
-- #param @LanguagePref			Language Preference,
-- #param @ConfigBody			Config Body,
-- #param @HTMLBody				HTML Body,
-- #param @DateInsert			Date Insert,
-- #param @TimeInsert			Time Insert,
-- #param @UserInsert			User Insert,
-- #param @UserUpdate			User Update,
-- #param @LastDateUpdated		Last Date Updated,
-- #param @LastTimeUpdated		Last Time Updated,

CREATE Procedure [dbo].EML_AddEmailTemplateLang
(
	@InstallationID 	NVARCHAR(3),
	@TemplateType		NVARCHAR(10),
	@LanguagePref		NVARCHAR(2),
	@ConfigBody			NVARCHAR(MAX),
	@HTMLBody			NVARCHAR(MAX),
	@DateInsert			DECIMAL,
	@TimeInsert			DECIMAL,
	@UserInsert			NVARCHAR(30),
	@UserUpdate			NVARCHAR(30),
	@LastDateUpdated	DECIMAL,
	@LastTimeUpdated	DECIMAL
)
AS

	INSERT INTO EMAILTEMPLATELANGS	
	(
		InstallationID,
		TemplateType,
		LanguagePref,
		ConfigBody,
		HTMLBody,
		DateInsert,
		TimeInsert,
		UserInsert,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated	
	)
	VALUES
	(
		@InstallationID,
		@TemplateType,
		@LanguagePref,
		@ConfigBody,
		@HTMLBody,
		@DateInsert,
		@TimeInsert,
		@UserInsert,
		@UserUpdate,
		@LastDateUpdated,
		@LastTimeUpdated
	)


GO 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_DelEmailHistory'))
	BEGIN
		DROP  Procedure  [dbo].EML_DelEmailHistory
	END

GO

-- #desc				Delete Email History record
-- #bl_class			Premier.SCMail.EmailHistory.cs
-- #db_dependencies		N/A
-- #db_references		N/A

-- #param @UniqueID		Unique ID

CREATE Procedure [dbo].EML_DelEmailHistory
(
	@UniqueID	BIGINT
)
AS
	BEGIN TRAN
		/* Delete detail */
		DELETE FROM [dbo].SC_EmailHistoryDetail WHERE UniqueID = @UniqueID;

		/* Delete header */
		DELETE FROM [dbo].SC_EmailHistoryHeader WHERE UniqueID = @UniqueID;
	COMMIT TRAN
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_DelEmailHistoryDetail'))
	BEGIN
		DROP  Procedure  [dbo].EML_DelEmailHistoryDetail
	END

GO

-- #desc				Delete Email History Detail record
-- #bl_class			Premier.SCMail.EmailHistory.cs
-- #db_dependencies		N/A
-- #db_references		N/A

-- #param @UniqueID		Unique ID

CREATE Procedure [dbo].EML_DelEmailHistoryDetail
(
	@UniqueID	BIGINT
)
AS
	BEGIN TRAN
		/* Delete detail */
		DELETE FROM [dbo].SC_EmailHistoryDetail WHERE UniqueID = @UniqueID;

	COMMIT TRAN
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_ExcUpdEmailHistoryResend'))
	BEGIN
		DROP  Procedure  [dbo].EML_ExcUpdEmailHistoryResend
	END

GO

-- #desc					Update Email History re send date
-- #bl_class				Premier.SCMail.EmailHistoryUpdateCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @UniqueID			Unique ID
-- #param @ResendDate		Resend Date

CREATE PROCEDURE [dbo].EML_ExcUpdEmailHistoryResend
(
	@UniqueID	BIGINT,
	@ResendTo	NVARCHAR(MAX),
	@ResendDate DECIMAL(6,0),
	@ResendTime DECIMAL(6,0)
)
AS
BEGIN
	UPDATE [dbo].SC_EmailHistoryHeader 
		SET ResendDate = @ResendDate, ResendTime = @ResendTime, ResendTo = @ResendTo 
	WHERE UniqueID = @UniqueID
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_GetEmailHistoryInfo'))
	BEGIN
		DROP  Procedure  [dbo].EML_GetEmailHistoryInfo
	END

GO

-- #desc				Reads Email History record
-- #bl_class			Premier.SCMail.EmailHistoryInfo.cs
-- #db_dependencies		N/A
-- #db_references		N/A

-- #param @UniqueID		Email Unique ID

CREATE Procedure [dbo].EML_GetEmailHistoryInfo
(
	@UniqueID	BIGINT
)
AS

	SELECT 
		A.UniqueID,
		A.EmailType,
		A.DocumentID,
		A.EmailTo,
		A.CarbonCopy,
		A.BlindCarbonCopy,
		A.EmailSubject,
		A.EmailPriority,
		A.ResendDate,
		A.ResendTime,
		A.LangPref,
		A.DateUpdated,
		A.TimeUpdated,
		B.EmailBody,
		DATALENGTH(B.EmailBody) AS EmailXmlLength
	FROM 
		[dbo].SC_EmailHistoryHeader A
	INNER JOIN [dbo].SC_EmailHistoryDetail B /* Filter only records with Email Detail */
		ON B.UniqueID = A.UniqueID
	WHERE
		A.UniqueID = @UniqueID;
GO


 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_GetEmailHistoryList'))
	BEGIN
		DROP  PROCEDURE  [dbo].EML_GetEmailHistoryList
	END

GO

-- #desc						Reads email history List
-- #bl_class					Premier.SCMail.EmailHistoryInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID
-- #param @EmailType			Email Type
-- #param @DocumentID			Document ID
-- #param @SendDateFrom			Send Date From
-- #param @SendDateTo			Send Date To
-- #param @EmailTo				Email To
-- #param @DisplayAllDetails	Display All Details 
-- #param @PageIndex			Page Index
-- #param @PageSize				Page Size

CREATE PROCEDURE [dbo].EML_GetEmailHistoryList
(
	@InstallationID		NVARCHAR(3),
	@EmailType			INT,
	@DocumentID			NVARCHAR(60),
	@SendDateFrom		DECIMAL(6,0),
	@SendDateTo			DECIMAL(6,0),
	@EmailTo			NVARCHAR(MAX),
	@DisplayAllDetails  INT,
	@PageIndex			INT,
	@PageSize			INT
)
AS
	/* Dynamic */
	DECLARE @SQL_DYNAMIC NVARCHAR(MAX);
	DECLARE @WHERE_DYNAMIC NVARCHAR(MAX) = '';		/* Filter Conditions */


	/* Paging */
    DECLARE @RowStart INT = ((@PageSize * @PageIndex) - @PageSize + 1);
    DECLARE @RowEnd INT = (@PageIndex * @PageSize);

	IF (@EmailType IS NOT NULL) BEGIN
		SET @WHERE_DYNAMIC += N' AND A.EmailType = @EmailType ';
	END
	
	IF (@DocumentID <> N'*') BEGIN
		SET @WHERE_DYNAMIC += N' AND A.DocumentID LIKE ''%'' + @DocumentID + ''%'' ';
	END

	IF (@SendDateFrom > 0 and @SendDateTo > 0) BEGIN
		SET @WHERE_DYNAMIC += N' AND A.DateUpdated BETWEEN @SendDateFrom AND @SendDateTo ';
	END
	
	IF (@EmailTo <> N'*') BEGIN
		SET @WHERE_DYNAMIC += N' AND A.EmailTo LIKE ''%'' + @EmailTo + ''%'' ';
	END
	ELSE IF(@DisplayAllDetails = 0)BEGIN
		SET @WHERE_DYNAMIC += N' AND A.EmailTo <> ''''';
		SET @WHERE_DYNAMIC += N' AND B.UniqueID IS NOT NULL';
	END

	SET @SQL_DYNAMIC = N'
	;WITH CTE AS (
		SELECT 
			A.UniqueID,
			A.EmailType,
			A.DocumentID,
			A.EmailTo,
			A.CarbonCopy,
			A.BlindCarbonCopy,
			A.EmailSubject,
			A.EmailPriority,
			A.ResendDate,
			A.ResendTime,
			A.DateUpdated,
			A.TimeUpdated,
			CASE 
				WHEN B.UniqueID IS NULL THEN 0 ELSE 1 END As HasDetail,
			ROW_NUMBER() OVER(ORDER BY A.ResendDate DESC, A.ResendTime DESC) RNUM,
			COUNT(1) OVER() TotalRowCount
		FROM 
			[dbo].SC_EmailHistoryHeader A
		LEFT JOIN [dbo].SC_EmailHistoryDetail B
			ON B.UniqueID = A.UniqueID
		WHERE
			A.InstallationID = @InstallationID
			'+ @WHERE_DYNAMIC +'
	)
	SELECT 
		A.UniqueID,
		A.EmailType,
		A.DocumentID,
		A.EmailTo,
		A.CarbonCopy,
		A.BlindCarbonCopy,
		A.EmailSubject,
		A.EmailPriority,
		A.ResendDate,
		A.ResendTime,
		A.DateUpdated,
		A.HasDetail,
		A.TimeUpdated,
		A.TotalRowCount
	FROM
		CTE A
	WHERE ((@PageIndex = 0 OR @PageSize = 0) OR (RNUM BETWEEN @RowStart AND @RowEnd)) ';

	EXECUTE sp_executesql @SQL_DYNAMIC, N' @InstallationID NVARCHAR(3), @EmailType INT, @DocumentID NVARCHAR(60), @SendDateFrom DECIMAL(6,0),
										@SendDateTo DECIMAL(6,0), @EmailTo NVARCHAR(MAX), @RowStart INT, @RowEnd INT, @PageIndex INT, @PageSize INT ',
										@InstallationID = @InstallationID, @EmailType = @EmailType, @DocumentID = @DocumentID,
										@SendDateFrom = @SendDateFrom, @SendDateTo = @SendDateTo, @EmailTo = @EmailTo,
										@RowStart = @RowStart, @RowEnd = @RowEnd, @PageIndex = @PageIndex, @PageSize = @PageSize
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_GetEmailTemplate'))
	BEGIN
		DROP  Procedure  [dbo].EML_GetEmailTemplate
	END
GO

-- #desc						Reads email template record
-- #bl_class					Premier.SCMail.EmailTemplate.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type

CREATE Procedure [dbo].EML_GetEmailTemplate
(
	@InstallationId NVARCHAR(3),
	@TemplateType	NVARCHAR(10)
)
AS
	Declare @InstallationTemp NVARCHAR(3)
	SET @InstallationTemp = @InstallationId;

	IF NOT EXISTS(SELECT TemplateType FROM EMAILTEMPLATE WHERE InstallationId = @InstallationId AND TemplateType = @TemplateType)
	BEGIN
		SET @InstallationTemp = '***';
	END

	SELECT 
		A.InstallationId,
		A.TemplateType,
		A.TemplateName,
		A.ConfigBody,
		A.HTMLBody,		
		A.DateInsert,
		A.TimeInsert,
		A.UserInsert,
		A.UserUpdate,
		A.LastDateUpdated,
		A.LastTimeUpdated
	FROM 
		EMAILTEMPLATE A		
	WHERE
		A.InstallationId =@InstallationTemp
		AND	A.TemplateType= @TemplateType
	
	--Email Templates Langs
	SELECT 
		InstallationId,		
		TemplateType,
		LanguagePref,
		ConfigBody,		
		HTMLBody,
		DateInsert,
		TimeInsert,
		UserInsert,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated
	FROM 
		EMAILTEMPLATELANGS
	WHERE
		InstallationId = @InstallationTemp
		AND TemplateType = @TemplateType
GO


 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_GetEmailTemplateInfo'))
	BEGIN
		DROP  Procedure  [dbo].EML_GetEmailTemplateInfo
	END

GO

-- #desc						Reads email template record
-- #bl_class					Premier.SCMail.EmailTemplateInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id
-- #param @TemplateType			Template Type
-- #param @LangPref				Language Preference

CREATE Procedure [dbo].EML_GetEmailTemplateInfo
(
	@InstallationId NVARCHAR(3),
	@TemplateType	NVARCHAR(10),
	@LangPref		NVARCHAR(2)
)
AS

	DECLARE @RECORDFOUND INT
	
	SELECT @RECORDFOUND = COUNT(*)
	FROM EMAILTEMPLATE A
	WHERE
		A.InstallationId = @InstallationId
		AND	A.TemplateType = @TemplateType
	   
	IF (@RECORDFOUND = 0)
	BEGIN
		SET @InstallationID = '***'; /*Branch plant override can only be set up in BASE installation*/
	END

	SELECT 
		A.InstallationId,
		A.TemplateType,
		A.TemplateName,
		A.ConfigBody,
		ISNULL(B.HTMLBody, A.HTMLBody) AS HTMLBody,
		ISNULL(B.ConfigBody, '') AS ConfigLang
	FROM EMAILTEMPLATE A
	LEFT OUTER JOIN EMAILTEMPLATELANGS B
	ON A.InstallationId = B.InstallationId
		AND A.TemplateType = B.TemplateType
		AND B.LanguagePref = @LangPref		
	WHERE
		A.InstallationId = @InstallationId
		AND	A.TemplateType = @TemplateType
GO


 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_GetEmailTemplateLangs'))
	BEGIN
		DROP  Procedure  [dbo].EML_GetEmailTemplateLangs
	END

GO

-- #desc						Reads email template record
-- #bl_class					Premier.SCMail.EmailTemplateLangs.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type

Create Procedure [dbo].EML_GetEmailTemplateLangs
	@InstallationId NVARCHAR(3),
	@TemplateType	NVARCHAR(10)
AS

	SELECT 
		InstallationId,		
		TemplateType,
		LanguagePref,
		ConfigBody,
		HTMLBody,
		DateInsert,
		TimeInsert,
		UserInsert,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated
	FROM 
		EMAILTEMPLATELANGS
	WHERE
		InstallationId = @InstallationId
		AND TemplateType = @TemplateType
GO 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_GetEmailTemplateList'))
	BEGIN
		DROP  Procedure  [dbo].EML_GetEmailTemplateList
	END

GO

-- #desc						Reads email template record
-- #bl_class					Premier.SCMail.EmailTemplateList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,

CREATE Procedure [dbo].EML_GetEmailTemplateList(
	@InstallationId NVARCHAR(3)
)
AS
	SELECT 
		InstallationId,
		TemplateType,
		TemplateName,
		ConfigBody,
		HTMLBody,	
		'' AS ConfigLang,			
		DateInsert,
		TimeInsert,
		UserInsert,
		UserUpdate,
		LastDateUpdated,
		LastTimeUpdated
	FROM 
		EMAILTEMPLATE	
	WHERE
		InstallationId = @InstallationId
	ORDER BY
		TemplateType;
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_GetEmailTemplateOverrideInst'))
	BEGIN
		DROP  Procedure  [dbo].EML_GetEmailTemplateOverrideInst
	END

GO

-- #desc						Reads installations that share the content
-- #bl_class					Premier.SCMail.EmailTemplate.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @TemplateType			Template Type

CREATE Procedure [dbo].EML_GetEmailTemplateOverrideInst(
	@Templatetype	NVARCHAR(10)
)
AS
	SELECT 
		InstallationId
	FROM 
		EMAILTEMPLATE	
	WHERE
		Templatetype = @Templatetype
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_PurgeEmailHistory'))
	BEGIN
		DROP PROCEDURE [dbo].EML_PurgeEmailHistory
	END
GO

-- #desc							Purge Email History jobs by old days.
-- #bl_class						Premier.ManagementConsole..cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @InstallationID			Installation ID
-- #param @HeaderOlderThanInDays	Header Older Than In Days
-- #param @DetailOlderThanInDays	Detail Older Than In Days


CREATE PROCEDURE [dbo].EML_PurgeEmailHistory
(
	@InstallationID		NVARCHAR(3),
	@HeaderOlderThanInDays	INT, /* Header Days */
	@DetailOlderThanInDays	INT /* Detail Days */
)
AS

	IF (@HeaderOlderThanInDays < 0 OR @DetailOlderThanInDays < 0)
		RETURN;

	DECLARE @HeaderOlderJulianDate DECIMAL(6,0);
	DECLARE @DetailOlderJulianDate DECIMAL(6,0);
	SET @HeaderOlderJulianDate = [dbo].CMM_GetCurrentJulianDate (GETDATE() - @HeaderOlderThanInDays);
	SET @DetailOlderJulianDate = [dbo].CMM_GetCurrentJulianDate (GETDATE() - @DetailOlderThanInDays);

	BEGIN TRAN
		/* Delete detail */
		DELETE D 
		FROM [dbo].SC_EmailHistoryDetail D
		INNER JOIN [dbo].SC_EmailHistoryHeader H
			ON H.UniqueID = D.UniqueID
		WHERE H.InstallationID = @InstallationID 
			AND D.DateUpdated < @DetailOlderJulianDate;

		/* Delete header */
		DELETE FROM [dbo].SC_EmailHistoryHeader 
		WHERE InstallationID = @InstallationID 
			AND DateUpdated < @HeaderOlderJulianDate;
	COMMIT TRAN
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_UpdEmailTemplate'))
	BEGIN
		DROP  Procedure  [dbo].EML_UpdEmailTemplate
	END

GO

-- #desc						Update email template record
-- #bl_class					Premier.SCMail.EmailTemplate.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type,
-- #param @TemplateName			Template Name,
-- #param @ConfigBody			Config Body,
-- #param @HTMLBody				HTML Body,
-- #param @UserUpdate			User Update,
-- #param @LastDateUpdated		Last Date Updated,
-- #param @LastTimeUpdated		Last Time Updated,

CREATE Procedure [dbo].EML_UpdEmailTemplate
(
	@InstallationId 	NVARCHAR(3),
	@TemplateType		NVARCHAR(10),
	@TemplateName		NVARCHAR(100),
	@ConfigBody			NVARCHAR(MAX),
	@HTMLBody			NVARCHAR(MAX),
	@UserUpdate			NVARCHAR(30),
	@LastDateUpdated	DECIMAL,
	@LastTimeUpdated	DECIMAL
)
AS
	
	UPDATE	EMAILTEMPLATE
	SET
		TemplateName    =   @TemplateName,
		ConfigBody		=	@ConfigBody,
		HTMLBody		=	@HTMLBody,
		UserUpdate		=	@UserUpdate,
		LastDateUpdated	=	@LastDateUpdated,
		LastTimeUpdated	=	@LastTimeUpdated
	WHERE 
		InstallationId = @InstallationId 
		AND TemplateType = @Templatetype

GO 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].EML_UpdEmailTemplateLang'))
	BEGIN
		DROP  Procedure  [dbo].EML_UpdEmailTemplateLang
	END

GO


-- #desc						Update email template record
-- #bl_class					Premier.SCMail.EmailTemplateLang.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id,
-- #param @TemplateType			Template Type,
-- #param @LanguagePref			Language Preference
-- #param @ConfigBody			Config Body,
-- #param @HTMLBody				HTML Body,
-- #param @UserUpdate			User Update,
-- #param @LastDateUpdated		Last Date Updated,
-- #param @LastTimeUpdated		Last Time Updated,

CREATE Procedure [dbo].EML_UpdEmailTemplateLang
(
	@InstallationId 	NVARCHAR(3),
	@TemplateType		NVARCHAR(10),
	@LanguagePref		NVARCHAR(2),
	@ConfigBody			NVARCHAR(MAX),
	@HTMLBody			NVARCHAR(MAX),
	@UserUpdate			NVARCHAR(30),
	@LastDateUpdated	DECIMAL,
	@LastTimeUpdated	DECIMAL
)
AS
	
	UPDATE	EMAILTEMPLATELANGS
	SET
		ConfigBody		=   @ConfigBody,
		HTMLBody		=	@HTMLBody,
		UserUpdate		=	@UserUpdate,
		LastDateUpdated	=	@LastDateUpdated,
		LastTimeUpdated	=	@LastTimeUpdated
	WHERE 
	InstallationId = @InstallationId
	and	TemplateType = @TemplateType
	and	LanguagePref = @LanguagePref

GO 
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_AddCatalogItemMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_AddCatalogItemMediaFile
	END

GO

-- #desc						Add Catalog Media File
-- #bl_class					Premier.Inventory.CatalogMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Item Number
-- #param @MediaFileUniqueID	Media File UniqueID
-- #param @PriorityIndex	    Priority Index
-- #param @DefaultImage			Determine if is the Default Image 
-- #param @MediaFileName		Media File Name
-- #param @MediaFileType		Media File Type
-- #param @ReSizeConstantPolicy Resize Constant Policy
-- #param @MediaFileComments	Media File Comments  
-- #param @MediaFileBody		Media File Body
-- #param @MediaFileThumbnail   Media File Thumbnail
-- #param @AddImageMode			Add Image Mode /* 0 Overwrite, 1 Keep both, 2 Skip */
-- #param @OriginalFileName		Original File Name
-- #param @UserInsert		    User Insert
-- #param @LastDateUpdated		Last Date Updated
-- #param @LastTimeUpdated		Last Time Updated

CREATE Procedure [dbo].INV_AddCatalogItemMediaFile
(
	@InstallationId		    NVARCHAR(3),
	@ItemNumber             DECIMAL,
	@MediaFileUniqueID      DECIMAL OUTPUT,
    @PriorityIndex          DECIMAL,
	@DefaultImage			INT,
	@MediaFileName          NVARCHAR(128),
    @MediaFileType          NVARCHAR(2),
    @ReSizeConstantPolicy   NVARCHAR(30),
    @MediaFileComments      NVARCHAR(512),
    @MediaFileBody          VARBINARY(MAX),
	@MediaFileThumbnail		VARBINARY(MAX),
	@AddImageMode			INT,		/* 0 Overwrite, 1 Keep both, 2 Skip */
	@OriginalFileName		NVARCHAR(128),
    @UserInsert             NVARCHAR(30),
    @LastDateUpdated        DECIMAL,
    @LastTimeUpdated        DECIMAL
)
AS
	EXECUTE [dbo].INV_AddCatalogMediaFile  @MediaFileUniqueID OUT, @MediaFileName, @MediaFileType, @ReSizeConstantPolicy, @InstallationId,  @MediaFileComments, @MediaFileBody, @MediaFileThumbnail, @LastDateUpdated, @LastTimeUpdated, @UserInsert, @LastDateUpdated, @LastTimeUpdated, @AddImageMode, @OriginalFileName

	if(@PriorityIndex = 0)
	BEGIN
		SET @PriorityIndex = (SELECT MAX (PriorityIndex)+1 FROM CATALOGITEMMEDIAFILE WHERE InstallationID = @InstallationId AND ItemNumber = @ItemNumber);
			--SET 1 IF THE MAX IS NULL
			IF(@PriorityIndex IS NULL)
			BEGIN
				SET @PriorityIndex = 1
			END     
	END

	IF(@MediaFileUniqueID <> 0)BEGIN /* Do not insert when skip image */
	    --Remove existing Default image
		IF(@DefaultImage = 1)
		BEGIN    
			UPDATE CATALOGITEMMEDIAFILE
			SET DefaultImage = 0
			WHERE InstallationId = @InstallationId AND ItemNumber = @ItemNumber 
		END

		INSERT INTO CATALOGITEMMEDIAFILE
		(
			InstallationID,
			ItemNumber,
			MediaFileUniqueID,
			PriorityIndex,
			LastDateUpdated,
			LastTimeUpdated,
			DefaultImage
		)
		VALUES
		(  
			@InstallationID,
			@ItemNumber,
			@MediaFileUniqueID,
			@PriorityIndex,
			@LastDateUpdated,
			@LastTimeUpdated,
			@DefaultImage
		)  
	END
GO 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_AddCatalogNSMItems'))
	BEGIN
		DROP  Procedure  [dbo].INV_AddCatalogNSMItems
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc						Move temporal Catalog Data to SC_Catalog_NSM
-- #bl_class					Premier.Inventory.CatalogNSMGenerateCommand.cs/GetCatalogNodeXMLItemsCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A			

-- #param @JobGenerationKey	    Unique Identifier of the Job trigger
-- #param @InstallationID		Installation ID	
-- #param @CatalogID			Catalog ID	
-- #param @CompressedXML        Compressed Data of Items , XML Template : <itemsData><header installationId='' catalogId='' dateUpdated ='' workstationId=''/><items><item shortNum='1' dispNum='1' DefUnitMsr='1' scType='M' template='SHIRT'><content></content><description1></description1><description2></description2><description3></description3><brachPlant></brachPlant></item></items><itemsLangs><lang itemNumber='' langId=''><description1></description1><description2></description2><description3></description3></lang></itemsLangs><itemNodes><nodeItem item="" node="" sequence=""/></itemNodes> <itemRelated><relatedItem itemNum="1" parentNum="1" scType="R" /></itemRelated> </itemsData>
-- #param @UserID				User ID
-- #param @WorkStation			Work Station ID
-- #param @DateUpdated			Date Updated
-- #param @TimeUpdated			Time Updated

CREATE PROCEDURE [dbo].INV_AddCatalogNSMItems(
		@JobGenerationKey DECIMAL,
		@InstallationID NVARCHAR(3),
		@CatalogID NVARCHAR(3),
		@CompressedXML VARBINARY(MAX),
		@UserID NVARCHAR(10),
		@WorkStation NVARCHAR(128),
		@DateUpdated DECIMAL,
		@TimeUpdated DECIMAL
	)
	AS
	BEGIN	
		BEGIN TRANSACTION
		BEGIN TRY
			
			DECLARE @ItemsDataXML XML
			--Decompress XML Data
			SELECT @ItemsDataXML = [dbo].SC_DecompressXML(@CompressedXML,2);
			
			--ItemMaster Insert
			INSERT 
			INTO SC_ItemMaster_Temp(
					JobGenerationKey,
					InstallationID,
					ShortItemNumber,
					DisplayItemNumber,
					DefaultUnitOfMeasure,
					PrimaryUnitOfMeasure,
					PricingUnitOfMeasure,
					ShippingUnitOfMeasure,
					Description1,
					Description2,
					Description3,
					Content,
					BranchPlant,
					StockingType,
					InventoryFlag,
					ScType,
					Template,
					UserID,
					WorkStationID,
					DateUpdated,
					TimeUpdated					
				)	
			SELECT	
				@JobGenerationKey,
				@InstallationID,
				ItemsData.item.value('@shortNum','DECIMAL') as ShortItem,
				ItemsData.item.value('@dispNum','NVARCHAR(25)') as DislayItemNumber,
				ItemsData.item.value('@defUnitMsr','NVARCHAR(3)') as DefaultUnitOfMeasure,
				ItemsData.item.value('@primaryUnitOfMeasure','NVARCHAR(3)') as PrimaryUnitOfMeasure,
				ItemsData.item.value('@pricingUnitOfMeasure','NVARCHAR(3)') as PricingUnitOfMeasure,
				ItemsData.item.value('@shippingUnitOfMeasure','NVARCHAR(3)') as ShippingUnitOfMeasure,
				ItemsData.item.value('description1[1]','NVARCHAR(MAX)')as Description1,
				ItemsData.item.value('description2[1]','NVARCHAR(MAX)') as Description2,
				ItemsData.item.value('description3[1]','NVARCHAR(MAX)') as Description3,
				ItemsData.item.value('description1[1]','NVARCHAR(MAX)')+ ' ' + 
				ItemsData.item.value('description2[1]','NVARCHAR(MAX)')+ ' ' + 
				ItemsData.item.value('description3[1]','NVARCHAR(MAX)')+ ' ' + 
				ItemsData.item.value('content[1]','NVARCHAR(MAX)') as Content,
				ItemsData.item.value('brachPlant[1]','NVARCHAR(MAX)') as BranchPlant,
				ItemsData.item.value('StockingType[1]','NVARCHAR(MAX)') as StockingType,
				ItemsData.item.value('InventoryFlag[1]','NVARCHAR(MAX)') as InventoryFlag,
				ItemsData.item.value('@scType','NVARCHAR(1)') as ScType,
				ItemsData.item.value('@template','NVARCHAR(20)') as Template,
				@UserID,
				@WorkStation,
				@DateUpdated,
				@TimeUpdated
			FROM @ItemsDataXML.nodes('/itemsData/items/item') as ItemsData(item)
			OPTION ( OPTIMIZE FOR ( @ItemsDataXML = NULL ) )							
			
			---Node Items Relation insert
			INSERT
			INTO SC_CatalogNodeItems_Temp (JobGenerationKey,InstallationID,CatalogID,NodeID,ShortItemNumber,Priority)
			SELECT
					@JobGenerationKey,
					@InstallationID,
					@CatalogID,
					C.NodeID,
					ItemsData.nodeItem.value('@item','DECIMAL') as ShortItem,
					ItemsData.nodeItem.value('@priority','INT') as Priority
			FROM @ItemsDataXML.nodes('/itemsData/itemNodes/nodeItem') as ItemsData(nodeItem)
			INNER JOIN  SC_Catalog_NSM_TEMP C
				ON C.JobGenerationKey = @JobGenerationKey 
				AND C.InstallationID = @InstallationID
				AND	C.CatalogID = @CatalogID
			WHERE C.ReferenceID = ItemsData.nodeItem.value('@node','NVARCHAR(20)')
			OPTION ( OPTIMIZE FOR ( @ItemsDataXML = NULL ) )

			--Items Master Langs Insert		
			INSERT INTO SC_ItemMasterLangs_TEMP(JobGenerationKey,InstallationID,ShortItemNumber,LanguageID,Description1,Description2,Description3,Content)
			SELECT	
					@JobGenerationKey,
					@InstallationID,
					ItemsLangs.lang.value('@itemNumber','DECIMAL'),
					ItemsLangs.lang.value('@langId','NVARCHAR(2)'),
					ItemsLangs.lang.value('description1[1]','NVARCHAR(MAX)'),
					ItemsLangs.lang.value('description2[1]','NVARCHAR(MAX)'),
					ItemsLangs.lang.value('description3[1]','NVARCHAR(MAX)'),
					ItemsLangs.lang.value('description1[1]','NVARCHAR(MAX)')+ ' ' + 
					ItemsLangs.lang.value('description2[1]','NVARCHAR(MAX)')+ ' ' + 
					ItemsLangs.lang.value('description3[1]','NVARCHAR(MAX)')+ ' ' + 
					ItemsLangs.lang.value('content[1]','NVARCHAR(MAX)')
			FROM @ItemsDataXML.nodes('/itemsData/itemsLangs/lang') as ItemsLangs(lang)
			OPTION ( OPTIMIZE FOR ( @ItemsDataXML = NULL ) )	
												
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

			-- Use RAISERROR inside the CATCH block to return error
			-- information about the original error that caused
			-- execution to jump to the CATCH block.
			RAISERROR (@ErrorMessage, -- Message text.
					   @ErrorSeverity, -- Severity.
					   @ErrorState -- State.
					   );
		END CATCH
	END
GO
SET QUOTED_IDENTIFIER OFF 
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_AddCatalogNSMNodeBase'))
BEGIN
	DROP  Procedure  [dbo].INV_AddCatalogNSMNodeBase
END
GO
-- #desc						Insert Node of Catalog to Nested Model Temporary Data Table when the node parent has children
-- #bl_class					N/A
-- #db_dependencies				N/A
-- #db_references				[dbo].INV_AddNodeSCCatalogNSMTEMP

-- #param @JobGenerationKey	    Unique Identifier of the Job trigger
-- #param @RightPositionParent	Parent right Position
-- #param @InstallationID		Installation ID	
-- #param @CatalogID			Catalog ID	
-- #param @Description			Description
-- #param @MediaFileUniqueID	Media Family ID
-- #param @ParentID				Parent Indentifier
-- #param @ApplyEffectiveDates  Apply efective dates
-- #param @EffectiveFrom		Effective from
-- #param @EffectiveThru		Effective Thru
-- #param @UserID				User ID
-- #param @WorkStation			Work Station ID
-- #param @DateUpdated			Date Updated
-- #param @TimeUpdated			Time Updated
-- #param @ReferenceID			Id of node in old model table, If the reference ID is missing is because the object is new and not have reference in another table

	CREATE PROCEDURE [dbo].INV_AddCatalogNSMNodeBase
		@JobGenerationKey DECIMAL,
		@RightPositionParent INT,
		@InstallationID NVARCHAR(3),
		@CatalogID NVARCHAR(3),
		@Description NVARCHAR(30),
		@MediaFileUniqueID BIGINT,
		@ApplyEffectiveDates NUMERIC(18, 0),
		@EffectiveFrom DECIMAL, 
		@EffectiveThru DECIMAL,
		@UserID				NVARCHAR(10),
		@WorkStationID		NVARCHAR(128), 
		@DateUpdated			DECIMAL,
		@TimeUpdated			DECIMAL,
		@ReferenceID  NCHAR(10) = NULL 
		
	AS
	BEGIN
		----Update the Tree position with position pluss 2
			UPDATE SC_Catalog_NSM_TEMP 
			SET RightPosition = RightPosition + 2 
			WHERE RightPosition > @RightPositionParent
				  AND JobGenerationKey=@JobGenerationKey;
			UPDATE SC_Catalog_NSM_TEMP 
			SET LeftPosition = LeftPosition + 2 
			WHERE LeftPosition > @RightPositionParent
				  AND JobGenerationKey=@JobGenerationKey;
				  
		----Insert the new node
			DECLARE @myLeft INT;
			DECLARE @myRight INT;
			SET @myLeft   = @RightPositionParent+1;
			SET @myRight =  @RightPositionParent + 2;			
			
			---Retrieve the las ID inserted
			DECLARE @nodeId DECIMAL;			
			SELECT @nodeId=MAX(NodeID) 
			FROM SC_Catalog_NSM_TEMP 
			WHERE JobGenerationKey=@JobGenerationKey;
			
			INSERT 
			INTO SC_Catalog_NSM_TEMP (JobGenerationKey,NodeId,InstallationID ,CatalogID, Description , LeftPosition,RightPosition, ReferenceID,MediaFileUniqueID,ApplyEffectiveDates,EffectiveFrom,EffectiveThru,UserID,WorkStationID,DateUpdated,TimeUpdated)
			VALUES (@JobGenerationKey, @nodeId,@InstallationID , @CatalogID, @Description, @myleft, @myRight,@ReferenceID,@MediaFileUniqueID,@ApplyEffectiveDates,@EffectiveFrom,@EffectiveThru,@UserID,@WorkStationID,@DateUpdated,@TimeUpdated);	
	END;
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_AddCatalogNSMNodeLeaf'))
BEGIN
	DROP  Procedure  [dbo].INV_AddCatalogNSMNodeLeaf
END
GO
-- #desc						Insert Node of Catalog to Nested Model Temporary Data Table when the node parent doesn't have children nodes
-- #bl_class					N/A
-- #db_dependencies				N/A
-- #db_references				[dbo].INV_AddNodeSCCatalogNSMTEMP

-- #param @JobGenerationKey	    Unique Identifier of the Job trigger
-- #param @LeftPositionParent	Left position of the parent node
-- #param @InstallationID		Installation ID	
-- #param @CatalogID			Catalog ID	
-- #param @Description			Description
-- #param @MediaFileUniqueID	Media Family ID
-- #param @ParentID				Parent Indentifier
-- #param @ApplyEffectiveDates  Apply efective dates
-- #param @EffectiveFrom		Effective from
-- #param @EffectiveThru		Effective Thru
-- #param @ReferenceID			Id of node in old model table, If the reference ID is missing is because the object is new and not have reference in another table
-- #param @RelatedItemsMethod	CC - CategoryCode | SI- Specific Items | NI- Not Include
-- #param @UserID				User ID
-- #param @WorkStation			Work Station ID
-- #param @DateUpdated			Date Updated
-- #param @TimeUpdated			Time Updated

	CREATE PROCEDURE [dbo].INV_AddCatalogNSMNodeLeaf
		@JobGenerationKey DECIMAL,
		@LeftPositionParent INT,
		@InstallationID NVARCHAR(3),
		@CatalogID NVARCHAR(3),
		@Description NVARCHAR(30),
		@MediaFileUniqueID BIGINT,
		@ApplyEffectiveDates NUMERIC(18, 0),  
		@EffectiveFrom DECIMAL, 
		@EffectiveThru DECIMAL, 
		@ReferenceID  NCHAR(10) = NULL,
		@RelatedItemsMethod NVARCHAR(2),
		@UserID				NVARCHAR(10),
		@WorkStationID		NVARCHAR(128), 
		@DateUpdated			DECIMAL,
		@TimeUpdated			DECIMAL				
	AS
	BEGIN
			
		----Update the Tree position with position plus 2
		UPDATE SC_Catalog_NSM_TEMP 
		SET RightPosition = RightPosition + 2 
		WHERE RightPosition > @LeftPositionParent
				AND JobGenerationKey=@JobGenerationKey;
		UPDATE SC_Catalog_NSM_TEMP 
		SET LeftPosition = LeftPosition + 2 
		WHERE LeftPosition > @LeftPositionParent
				AND JobGenerationKey=@JobGenerationKey;
				  
		----Insert the new node
		DECLARE @myLeft INT;
		DECLARE @myRight INT;
		SET @myLeft   = @LeftPositionParent+1;
		SET @myRight =  @LeftPositionParent + 2;
			
		---Retrieve the las ID inserted
		DECLARE @nodeId DECIMAL;
		SELECT @nodeId=MAX(NodeID) 
		FROM SC_Catalog_NSM_TEMP 
		WHERE JobGenerationKey = @JobGenerationKey;
			
		IF(@nodeId IS NULL)
		BEGIN
			SET @nodeId = 0;
		END
		ELSE
			SET @nodeId += 1;
				
		INSERT 
		INTO SC_Catalog_NSM_TEMP (JobGenerationKey, NodeId, InstallationID, CatalogID, Description, LeftPosition, RightPosition, ReferenceID, 
			MediaFileUniqueID, ApplyEffectiveDates, EffectiveFrom, EffectiveThru, RelatedItemsMethod, UserID, WorkStationID, DateUpdated, TimeUpdated)
		VALUES (@JobGenerationKey, @nodeId, @InstallationID, @CatalogID, @Description, @myleft, @myRight,
			@ReferenceID, @MediaFileUniqueID, @ApplyEffectiveDates, @EffectiveFrom, @EffectiveThru, 
			@RelatedItemsMethod, @UserID, @WorkStationID, @DateUpdated, @TimeUpdated);	
	END;
	
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_AddCatalogNSMNodes'))
	BEGIN
		DROP  Procedure  [dbo].INV_AddCatalogNSMNodes
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc						Insert Node of Catalog to Nested Model Temp Table
-- #bl_class					Premier.Inventory.CatalogNSMGenerateCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @JobGenerationKey	    Unique Identifier of the Job trigger
-- #param @InstallationID		Installation ID	
-- #param @CatalogID			Catalog ID	
-- #param @CompressedXML		Compressed XML data of Nodes 
--							    Template of XML <catalogData><nodes><node id='' parentId='' effectiveModeFlag='' effectiveFromDate='' effectiveThruDate='' sequenceNumner='' imageId=''><description></description></node></nodes><langs>	<lang nodeId='' id=''><description></description></lang></langs></catalogData>*/
-- #param @UserID				User ID
-- #param @WorkStation			Work Station ID
-- #param @DateUpdated			Date Updated
-- #param @TimeUpdated			Time Updated		
		
																																																  
CREATE PROCEDURE [dbo].INV_AddCatalogNSMNodes 
	(
		@JobGenerationKey DECIMAL,
		@InstallationID NVARCHAR(3),--Installation Identifier SC_Catalog_NSM_TEMP
		@CatalogID NVARCHAR(3),--Catalog ID	
		@CompressedXML VARBINARY(MAX),
		@UserID NVARCHAR(10),		
		@WorkStation NVARCHAR(128),	
		@DateUpdated DECIMAL,
		@TimeUpdated DECIMAL
	)
	AS
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY			
			DELETE
			FROM SC_ItemMasterLangs_TEMP
				WHERE JobGenerationKey = @JobGenerationKey
			
			DELETE  
			FROM SC_CatalogLangs_TEMP
			WHERE JobGenerationKey = @JobGenerationKey
											
			DELETE  
			FROM SC_CatalogNodeItems_TEMP
				WHERE JobGenerationKey = @JobGenerationKey
		
			DELETE  
			FROM SC_ItemMaster_TEMP
			WHERE JobGenerationKey = @JobGenerationKey
			
			DELETE  
			FROM SC_Catalog_NSM_TEMP
			WHERE JobGenerationKey = @JobGenerationKey

		
		
			DECLARE @XmlNodes XML;
			DECLARE @xmlOflangs XMl;
			--Vars to storage the Nodes data
			DECLARE @Description NVARCHAR(MAX);--Description 
			DECLARE	@ParentID NVARCHAR(10);--Node of the parent
			DECLARE	@MediaFileUniqueID DECIMAL; --Image ID		
			DECLARE	@ApplyEffectiveDates DECIMAL;  --If apply in effective date
			DECLARE	@EffectiveFrom DECIMAL; --Effective from Date
			DECLARE	@EffectiveThru DECIMAL; --Effective  to Date
			DECLARE	@ReferenceID  NVARCHAR(10);
			DECLARE @RelatedItemsMethod NVARCHAR(2);
			DECLARE @isFirtsRun BIT;--Indicates that is the first run
			DECLARE @currentNodeXML NVARCHAR(MAX)='';
			DECLARE @OrphansNodes NVARCHAR(MAX)='';
			DECLARE @existTemporalOrphans BIT;
			DECLARE @runInsertionOfNodes BIT;
			
			SET @existTemporalOrphans = 0;
			SET @runInsertionOfNodes =1;
								   
			--Decompress XML Data
			SELECT @XmlNodes= [dbo].SC_DecompressXML(@CompressedXML,2);
			
			SELECT @xmlOflangs=@XmlNodes.query('/catalogData//langs');
			
			WHILE (@runInsertionOfNodes=1)
			BEGIN  --While Orphans Comprobation
				SET @runInsertionOfNodes = 0; 
								
				DECLARE @CountOfNodes INT		
				
				SELECT @CountOfNodes = COUNT(Nodes.node.value('@id','NVARCHAR(10)'))
				FROM @XmlNodes.nodes('/catalogData/nodes/node') as Nodes(node)	
				OPTION ( OPTIMIZE FOR ( @XmlNodes = NULL ) )
				
				DECLARE @Count INT
				SET @Count =0;
				DECLARE  @insertedNodes TABLE
				(
					 nodeId NVARCHAR(10) UNIQUE
				)
				WHILE @Count < @CountOfNodes
				BEGIN--Main While						
						--SET THE VARS DATA FOR THE CURRENT ROW		
						SELECT Top 1	
							@currentNodeXML = CONVERT(NVARCHAR(4000),NodesData.node.query('.')),	
							@ReferenceID = NodesData.node.value('@id','NVARCHAR(10)'),
							@ParentID = NodesData.node.value('@parentId','NVARCHAR(10)'),
							@EffectiveFrom = NodesData.node.value('@effectiveFromDate','DECIMAL'),	
							@EffectiveThru = NodesData.node.value('@effectiveThruDate','DECIMAL'),
							@ApplyEffectiveDates = NodesData.node.value('@effectiveModeFlag','DECIMAL'),
							@MediaFileUniqueID = NodesData.node.value('@imageId','DECIMAL'),
							@RelatedItemsMethod = NodesData.node.value('@relatedItemsMethod','NVARCHAR(2)'),
							@Description = NodesData.node.value('description[1]','NVARCHAR(MAX)')
						FROM @XmlNodes.nodes('/catalogData/nodes/node') as NodesData(node)	
						WHERE  NodesData.node.value('@id','NVARCHAR(10)') NOT IN (SELECT  nodeId FROM @insertedNodes) 	
						OPTION ( OPTIMIZE FOR ( @XmlNodes = NULL ) )
															
						INSERT INTO @insertedNodes (nodeId) VALUES(@ReferenceID);
						
						DECLARE	@nodeId_Conv DECIMAL; 
						
						SET @Count = @Count +1;		
							
					BEGIN --Insert nodes		
							--GET the RightPositin of the Parent Node
							DECLARE @rightPositionParent INT = NULL;
							DECLARE @leftpositionParent INT= NULL;
							Declare @numericParentId INT ;
							If(ISNUMERIC(@ParentID)=0)
							BEGIN			
								SET @numericParentId =0;
							END
							ELSE
							BEGIN
								SET @numericParentId = CONVERT(INT,@ParentID);
							END	
							--IF IT'S INSERTING WITH REFERENCE CODE IS BECAUSE IT IS INSERTION FROM CONVERSION
							IF(@ReferenceID='')
							BEGIN
								
								SELECT @rightPositionParent =ct.RightPosition, @leftpositionParent = ct.LeftPosition
								FROM SC_Catalog_NSM_TEMP AS ct
								WHERE  ct.JobGenerationKey = @JobGenerationKey
									AND ct.InstallationID = @InstallationID
									AND	ct.CatalogID = @CatalogID
									AND ct.NodeId = @numericParentId;
							END			
							ELSE		   
							BEGIN				
								SELECT @rightPositionParent =ct.RightPosition, @leftpositionParent = ct.LeftPosition
								FROM SC_Catalog_NSM_TEMP AS ct
								WHERE  ct.JobGenerationKey =@JobGenerationKey
										AND ct.InstallationID = @InstallationID
										AND	ct.CatalogID = @CatalogID
										AND ct.ReferenceID =@ParentID;	
							END		
							--If the node parent does'nt exist and does not have reference and parent ID would be inserted as root
							IF (@rightPositionParent is null or  @leftpositionParent is null ) and  (ISNUMERIC(@ReferenceID)=1 AND @ReferenceID='0')
							BEGIN					
								SET @rightPositionParent =0;
								SET @leftpositionParent =0;
								EXEC [dbo].INV_AddCatalogNSMNodeLeaf @JobGenerationKey, @leftpositionParent, @InstallationID, @CatalogID, @Description, 
									 @MediaFileUniqueID, @ApplyEffectiveDates, @EffectiveFrom, @EffectiveThru, @ReferenceID, @RelatedItemsMethod, @UserID, @WorkStation, @DateUpdated, @TimeUpdated;
							END
							ELSE
							BEGIN--Else  1		
								--If the parent exist else disregard the node
								IF(@rightPositionParent is not null or  @leftpositionParent is not null ) 
								BEGIN					
									DECLARE @subs INT;
									SET @subs =@leftpositionParent -@rightPositionParent;
									IF @subs >1
									BEGIN		
										EXEC [dbo].INV_AddCatalogNSMNodeBase @JobGenerationKey, @rightPositionParent, @InstallationID, @CatalogID,@Description,@MediaFileUniqueID,@ApplyEffectiveDates,@EffectiveFrom,@EffectiveThru,@UserID,@WorkStation,@DateUpdated,@TimeUpdated,@ReferenceID;
									END
									ELSE 
									BEGIN			
										EXEC [dbo].INV_AddCatalogNSMNodeLeaf @JobGenerationKey, @leftpositionParent, @InstallationID, @CatalogID, @Description,
											@MediaFileUniqueID, @ApplyEffectiveDates, @EffectiveFrom, @EffectiveThru, @ReferenceID, @RelatedItemsMethod, @UserID, @WorkStation, @DateUpdated, @TimeUpdated;
									END;
								END;
								ELSE
								BEGIN --If the parent of the node does not exist, is because isn't inserted yet so it have to be marked as orphan								   
								   SET @existTemporalOrphans = 1; 				
								   select @OrphansNodes = @OrphansNodes+@currentNodeXML;	   										
								END;
							END--End Else 1																											
					END--End insert nodes				
				END--End Main While
				IF(@existTemporalOrphans =1)--if there is orphan  nodes, try to insert again
				BEGIN
					SET @Count = 0;
					SET @existTemporalOrphans=0;
					SET @runInsertionOfNodes =1;--mark the insertion flag available again
				    select @XmlNodes= '<catalogData><nodes>'+@OrphansNodes+'</nodes></catalogData>';
					SET @OrphansNodes='';
				    DELETE FROM @insertedNodes;
				END;
				
			END--End While Orphans comprobation
			
			--Insert Catalog Nodes Languages
			INSERT
			INTO SC_CatalogLangs_Temp (JobGenerationKey,InstallationID,CatalogID,NodeID,LanguageID,Description)		
			SELECT	
					@JobGenerationKey,
					@InstallationID,
					@CatalogID,
					C.NodeID,
					DetailLangs.lang.value('@id','NVARCHAR(20)'),
					DetailLangs.lang.value('description[1]','NVARCHAR(30)')
			FROM @xmlOflangs.nodes('langs/lang') AS DetailLangs(lang)			
			 INNER JOIN  SC_Catalog_NSM_Temp C
			 ON C.JobGenerationKey = @JobGenerationKey 
				AND C.InstallationID = @InstallationID
				AND	C.CatalogID = @CatalogID
			WHERE C.ReferenceID = DetailLangs.lang.value('@nodeId','NVARCHAR(20)')
			OPTION ( OPTIMIZE FOR ( @xmlOflangs = NULL ) )
			
			--Update effective date range
			DECLARE CatalogNSM_Cursor CURSOR FOR				
			SELECT NodeID, EffectiveFrom, EffectiveThru, LeftPosition, RightPosition  
			FROM SC_Catalog_NSM_TEMP 
			WHERE JobGenerationKey = @JobGenerationKey
				AND InstallationID = @InstallationID
				AND CatalogID = @CatalogID
				AND ApplyEffectiveDates = 1

			DECLARE @NodeID DECIMAL;
			DECLARE	@EffectiveFromNode DECIMAL; 
			DECLARE	@EffectiveThruNode DECIMAL; 
			DECLARE	@LeftPosition DECIMAL;
			DECLARE	@RightPosition DECIMAL;
			
			OPEN CatalogNSM_Cursor 
			FETCH NEXT FROM CatalogNSM_Cursor INTO @NodeID, @EffectiveFromNode, @EffectiveThruNode, @LeftPosition, @RightPosition
			WHILE @@fetch_status = 0
			BEGIN
				UPDATE SC_Catalog_NSM_TEMP 
				SET ApplyEffectiveDates = 1, 
					EffectiveFrom = (CASE WHEN @EffectiveFromNode > EffectiveFrom
									 THEN @EffectiveFromNode ELSE EffectiveFrom END),
					EffectiveThru = (CASE WHEN (@EffectiveThruNode < EffectiveThru OR EffectiveThru = 0)
									 THEN @EffectiveThruNode ELSE EffectiveThru END)
				WHERE LeftPosition BETWEEN @LeftPosition AND @RightPosition 
					AND JobGenerationKey = @JobGenerationKey
					AND InstallationID = @InstallationID
					AND CatalogID = @CatalogID
					AND NodeID <> @NodeID
				
				FETCH NEXT FROM CatalogNSM_Cursor INTO @NodeID, @EffectiveFromNode, @EffectiveThruNode, @LeftPosition, @RightPosition
			END
	
			CLOSE CatalogNSM_Cursor
			DEALLOCATE CatalogNSM_Cursor
			
			COMMIT TRANSACTION
			END TRY			
		BEGIN CATCH
			ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

			-- Use RAISERROR inside the CATCH block to return error
			-- information about the original error that caused
			-- execution to jump to the CATCH block.
			RAISERROR (@ErrorMessage, -- Message text.
					   @ErrorSeverity, -- Severity.
					   @ErrorState -- State.
					   );
		END CATCH		
	END;
GO
SET QUOTED_IDENTIFIER OFF 
GO

  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_AddCatalogServerMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_AddCatalogServerMediaFile
	END

GO

-- #desc						Add Catalog Server Media File
-- #bl_class					Premier.Inventory.CatalogServerMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation ID
-- #param @MediaFileUniqueID	Media File UniqueID
-- #param @ServerName		    Server Name
-- #param @MediaFileStatus		Media File Status
-- #param @LastDateUpdated		Last Date Updated
-- #param @LastTimeUpdated		Last Time Updated

CREATE Procedure [dbo].INV_AddCatalogServerMediaFile
(
	@InstallationId		    NVARCHAR(3),
	@ServerName             NVARCHAR(128),
    @MediaFileUniqueID      DECIMAL,
    @MediaFileStatus        NVARCHAR(3),
    @LastDateUpdated        DECIMAL,
    @LastTimeUpdated        DECIMAL
)
AS
	
	INSERT INTO CATALOGSERVERMEDIAFILE
	(
		InstallationId,
	    ServerName,
        MediaFileUniqueID,
        MediaFileStatus,
        LastDateUpdated,
        LastTimeUpdated 
	)
	VALUES
	(
		@InstallationId,
	    @ServerName,
        @MediaFileUniqueID,
        @MediaFileStatus,
        @LastDateUpdated,
        @LastTimeUpdated 
	)

GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_CatalogItemMasterMediaList'))
	BEGIN
		DROP  Procedure  [dbo].INV_CatalogItemMasterMediaList
	END

GO

-- #desc								Get Catalog Item Master Media List
-- #bl_class							Premier.Inventory.CatalogItemMasterMediaList.cs
-- #db_dependencies						N/A
-- #db_references						N/A

-- #param @InstallationID				InstallationID 
-- #param @ItemNumber					Search by Item Number
-- #param @FilterTerm					Filter Term
--#param @Status						Status	0 - SpecificInstallation | 1 - Shared | 2 - Any
-- #param @PageIndex					Paging - Current page
-- #param @PageSize						Paging - Items to be shown

CREATE Procedure [dbo].INV_CatalogItemMasterMediaList
(
	@InstallationID 			NVARCHAR(3),
	@ItemNumber 				DECIMAL,
	@FilterTerm					NVARCHAR(MAX),
	@Status						DECIMAL,
	@PageIndex					DECIMAL,
	@PageSize					DECIMAL
)
AS
	DECLARE @BaseInstallation		NVARCHAR(3) = '***'
	DECLARE @SearchText				NVARCHAR(4000) = ' '
	/* Dynamic */
	DECLARE @SQL_DYNAMIC			NVARCHAR(MAX)
	DECLARE @WHERE_DYNAMIC			NVARCHAR(MAX) = ' '
	DECLARE @STATUS_FILTER			NVARCHAR(100) = ' '
	DECLARE @CONTENT_FILTER			NVARCHAR(1000) = ' '

	
	
	IF(@Status = 0)BEGIN
		SET @STATUS_FILTER = N' WHERE COUNTS.InstallationImages > 0 '
	END
	ELSE IF(@Status = 1)BEGIN
		SET @STATUS_FILTER = N' WHERE COUNTS.SharedImages > 0 '
	END

	IF(@ItemNumber IS NOT NULL)BEGIN
		SET @WHERE_DYNAMIC = N' AND C.itemnumber = @ItemNumber '
	END

	IF(@FilterTerm <> '*')BEGIN
		SET @SearchText = [dbo].CMM_GetFullTextQueryTerms(@FilterTerm, 0)
		SET @CONTENT_FILTER = N'
		INNER JOIN CONTAINSTABLE(SC_ItemMaster, (Content), @SearchText) AS Cont
					ON Cont.[key] = A.UniqueID AND A.InstallationID IN  (@InstallationID, @BASEINSTALLATION)
		'
	END

	SET @SQL_DYNAMIC = N'
	SELECT 
		PAGING.InstallationImages, 
		PAGING.SharedImages, 
		PAGING.ShortItemNumber, 
		PAGING.DisplayItemNumber, 
		PAGING.Description1, 
		PAGING.Description2, 
		PAGING.TotalRowCount
	FROM (
		SELECT /* Calculate status and total row count */
			COUNTS.InstallationImages, 
			COUNTS.SharedImages, 
			COUNTS.ShortItemNumber, 
			COUNTS.DisplayItemNumber, 
			COUNTS.Description1, 
			COUNTS.Description2,
			ROW_NUMBER() OVER (ORDER BY Description1) AS RNUM,
			COUNT(*) OVER () AS TotalRowCount 
		FROM (
			SELECT /* Count images related and shared */
				COUNT(CASE WHEN A.installationid = @InstallationID THEN 1 ELSE NULL END) AS InstallationImages,
				COUNT(CASE WHEN A.installationid = @BASEINSTALLATION THEN 1 ELSE NULL END) AS SharedImages,
				A.ShortItemNumber,
				A.DisplayItemNumber,
				A.Description1,
				A.Description2
			FROM (
				SELECT /* Gets records shared or associated to the specific installation */ 
					itemnumber AS ShortItemNumber, 
					ISNULL(ContentSpecific.displayitemNumber, ContentShared.displayitemNumber) AS DisplayItemNumber, 
					ISNULL (ContentSpecific.description1, ContentShared.description1) AS Description1,
					ISNULL(ContentSpecific.description2, ContentShared.DESCRIPTION2) Description2,
					C.InstallationID,
					ISNULL(ContentSpecific.UniqueID, ContentShared.UniqueID) as UniqueID
				FROM CATALOGITEMMEDIAFILE c

				LEFT OUTER JOIN SC_ItemMaster ContentSpecific 
					ON c.itemnumber = ContentSpecific.Shortitemnumber  
					AND @InstallationID = ContentSpecific.InstallationID 
				LEFT OUTER JOIN SC_ItemMaster ContentShared 
					ON c.itemnumber = ContentShared.Shortitemnumber  
					AND @BASEINSTALLATION = ContentShared.installationid 
				WHERE C.installationid IN (@InstallationID, @BASEINSTALLATION) ' + @WHERE_DYNAMIC + '
			) as A

			' + @CONTENT_FILTER + '

			GROUP BY A.ShortItemNumber, A.DisplayitemNumber, A.Description1, A.Description2
			) COUNTS
		' + @STATUS_FILTER + '
	) PAGING
	WHERE ((@PageIndex = 0 OR @PageSize = 0) OR (PAGING.RNUM BETWEEN (@PageSize * @PageIndex) - @PageSize + 1 AND @PageIndex * @PageSize))'

	EXECUTE sp_executesql @SQL_DYNAMIC, N'@InstallationID NVARCHAR(3), @PageIndex FLOAT, @PageSize FLOAT, @ItemNumber FLOAT, @SearchText NVARCHAR(4000), @BaseInstallation	NVARCHAR(3) ', 
										@InstallationId = @InstallationId, @PageIndex = @PageIndex, @PageSize = @PageSize, @ItemNumber = @ItemNumber, @SearchText = @SearchText,
										@BaseInstallation = @BaseInstallation 



GO




IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_CopyCatalogImages'))
	BEGIN
		DROP  Procedure  [dbo].INV_CopyCatalogImages
	END

GO

-- #desc						Copy the images of a catalog.
-- #bl_class					Premier.Inventory.CopyCatalogCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @NewInstallationID	The id of the new installation
-- #param @NewCatalogID			The id of the new catalog
-- #param @NodeImagePairs	    String of pairs with node id and the related old image id

-- #return string with trio NodeID|OldImageID|NewImageID

CREATE PROCEDURE [dbo].[INV_CopyCatalogImages]
	@NewInstallationID NVARCHAR(3),
	@NewCatalogID NVARCHAR(3),
	@NodeImagePairs NVARCHAR(MAX)
AS
BEGIN
	DECLARE @MediaFileUniqueID DECIMAL
	DECLARE @Pos INT
	DECLARE @NextString NVARCHAR(20)

	DECLARE @InnerPos INT
	DECLARE @NodeID NVARCHAR(3)
	DECLARE @ImageID NVARCHAR(10)

	DECLARE @NewMediaFileName NVARCHAR(128)
	DECLARE @PosInMediaFileName INT

	DECLARE @TrioResult NVARCHAR(MAX) = ''


    IF (@NodeImagePairs <> '')
	BEGIN
		SET @Pos = CHARINDEX('|@', @NodeImagePairs)		
		WHILE (@Pos <> 0)
			BEGIN
				SET @NextString = SUBSTRING(@NodeImagePairs, 1, @Pos - 1)
				SET @NodeImagePairs = SUBSTRING(@NodeImagePairs,@Pos + 2,LEN(@NodeImagePairs))
				SET @Pos = CHARINDEX('|@', @NodeImagePairs)

				SET @InnerPos = CHARINDEX('~', @NextString)
				SET @NodeID = SUBSTRING(@NextString, 1, @InnerPos - 1)
				SET @ImageID = SUBSTRING(@NextString, @InnerPos + 1, LEN(@NextString))

				--GET THE NEXT IMAGE ID
				SET @MediaFileUniqueID = (SELECT MAX (MediaFileUniqueID)+1 FROM CATALOGMEDIAFILE);
				--SET 1 IF THE MAX IS NULL
				IF(@MediaFileUniqueID IS NULL)
				BEGIN
					SET @MediaFileUniqueID = 1
				END
				
				--FORM THE NEW NODE~OLDIMAGE~NEWIMAGE TRIO
				SET @TrioResult = @TrioResult + @NextString + '~' + CONVERT(NVARCHAR, @MediaFileUniqueID) + '|@'

				--PRINT CONVERT(bigint, @ImageID)

				IF (@ImageID IS NOT NULL)
				BEGIN
					SET @NewMediaFileName = (SELECT MediaFileName FROM [dbo].CATALOGMEDIAFILE
											WHERE MediaFileUniqueID = CONVERT(bigint, @ImageID))
					SET @PosInMediaFileName = CHARINDEX('-', @NewMediaFileName);
					SET @NewMediaFileName = SUBSTRING(@NewMediaFileName,@PosInMediaFileName,LEN(@NewMediaFileName))
					SET @NewMediaFileName = @NewCatalogID + @NewMediaFileName

					INSERT INTO [dbo].CATALOGMEDIAFILE(MediaFileUniqueID, MediaFileName, OriginalFileName, MediaFileType, ReSizeConstantPolicy, InstallationOwner, MediaFileComments, MediaFileBody, MediaFileThumbnail, MediaFileCheckSum, DateInsert, TimeInsert, UserInsert, UserUpdate, LastDateUpdated, LastTimeUpdated)
					SELECT
					@MediaFileUniqueID,
					@NewMediaFileName,
					OriginalFileName,
					MediaFileType,
					ReSizeConstantPolicy,
					@NewInstallationID,
					MediaFileComments,
					MediaFileBody,
					MediaFileThumbnail,
					MediaFileCheckSum,
					DateInsert,
					TimeInsert,
					UserInsert,
					UserUpdate,
					LastDateUpdated,
					LastTimeUpdated
					FROM [dbo].CATALOGMEDIAFILE
					WHERE MediaFileUniqueID = CONVERT(bigint, @ImageID)
				END --IF
			END --WHILE

			SELECT @TrioResult as RESULT

	END --IF 
END

GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_DelCatalogMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_DelCatalogMediaFile
	END

GO

-- #desc							Del Catalog Media File
-- #bl_class						Premier.Inventory.CatalogMediaFile.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @InstallationID			InstallationID
-- #param @MediaFileUniqueID	    Media File UniqueID

CREATE Procedure [dbo].INV_DelCatalogMediaFile
(
	@MediaFileUniqueID      DECIMAL
)
AS

	DELETE 
	FROM CATALOGMEDIAFILE
	WHERE
		MediaFileUniqueID = @MediaFileUniqueID

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_DelCatalogNSM'))
	BEGIN
		DROP  Procedure  [dbo].INV_DelCatalogNSM
	END

GO 
-- #desc						Deletes the Catalog in format NSM 
-- #bl_class					Premier.Inventory.CatalogNSMNodes.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation Identifier
-- #param @CatalogID			Catalog Identifier		
	
CREATE PROCEDURE [dbo].INV_DelCatalogNSM
	@InstallationID NVARCHAR(3),
	@CatalogID NVARCHAR(3)	
AS
BEGIN
	--Declare table of Items by Installation
	CREATE TABLE #FILTERTABLEITEMS
	(
			ShortItemNumber DECIMAL PRIMARY KEY
	)

	--Declare items where not are in others installations
	CREATE TABLE #FILTERTABLEITEMSNOTFOUNDINOTHERSCAT
	(
			ShortItemNumber DECIMAL PRIMARY KEY
	)
	
	/*Declare matrix related items that are not referenced in other catalog*/
	CREATE TABLE #FILTERTABLEITEMSRELATEDTODELETE
	(
			ShortItemNumber DECIMAL UNIQUE
	)		
	
	--Items of the same installation thats are not referenced in others catalogs
	INSERT INTO #FILTERTABLEITEMS(ShortItemNumber)
	  SELECT DISTINCT ShortItemNumber 
		FROM SC_CatalogNodeItems
		WHERE InstallationID = @InstallationID
			  And CatalogID = @CatalogID;
			
	--Items were not are in others catalogs with same installation
	INSERT INTO #FILTERTABLEITEMSNOTFOUNDINOTHERSCAT(ShortItemNumber)
	  SELECT DISTINCT ShortItemNumber 
		FROM SC_ItemMaster A
		WHERE EXISTS (SELECT 1 FROM #FILTERTABLEITEMS WHERE ShortItemNumber = A.ShortItemNumber) 
			  AND  ShortItemNumber NOT IN (SELECT ShortItemNumber FROM SC_CatalogNodeItems WHERE  (InstallationID= @InstallationID and CatalogID<>@CatalogID)or(InstallationID<>@InstallationID and CatalogID=@CatalogID));

	--DELETE SC_ItemMasterLangs
	DELETE 
	FROM SC_ItemMasterLangs
	WHERE  ShortItemNumber IN ( SELECT ShortItemNumber FROM #FILTERTABLEITEMSNOTFOUNDINOTHERSCAT  )
			AND InstallationID = @InstallationID;
	
	--Delete Catalog Langs
	DELETE
	FROM SC_CatalogLangs
	WHERE InstallationID =@InstallationID 
		AND CatalogID = @CatalogID

	--Delete  Catalog Node Items
	DELETE 
	FROM SC_CatalogNodeItems
	WHERE InstallationID = @InstallationID AND CatalogID = @CatalogID;	
	
	/*Delete Items that are not associated to other catalogs */
	/*Do not delete matrix child items that still exist in SC_ItemMasterRelated. Those are items which parent is associated to another catalog.*/
	DELETE A
		FROM SC_ItemMaster A
		INNER JOIN #FILTERTABLEITEMSNOTFOUNDINOTHERSCAT B
			ON A.ShortItemNumber = B.ShortItemNumber
		WHERE
		 A.InstallationID = @InstallationID;

	DELETE A
		FROM SC_ItemMaster A
	  INNER JOIN #FILTERTABLEITEMSRELATEDTODELETE B
			ON A.ShortItemNumber = B.ShortItemNumber
		WHERE
		 A.InstallationID = @InstallationID;

	--Delete  Catalog Nodes
	DELETE 
	FROM SC_Catalog_NSM
	WHERE InstallationID = @InstallationID
		  AND CatalogID = @CatalogID;
		 				  
END; 

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_DelCatalogNSMTempData'))
	BEGIN
		DROP  Procedure  [dbo].INV_DelCatalogNSMTempData
	END

GO

-- #desc						Deletes all Catalog NSM temporal data
-- #bl_class					Premier.Inventory.CatalogNSMGenerateCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @JobGenerationKey	    Unique Identifier of the Job trigger

CREATE  PROCEDURE [dbo].INV_DelCatalogNSMTempData
@JobGenerationKey DECIMAL
AS
SET NOCOUNT ON
BEGIN	
	delete  from SC_ItemMasterLangs_TEMP WHERE JobGenerationKey = @JobGenerationKey;
	delete  from SC_CatalogLangs_TEMP WHERE JobGenerationKey = @JobGenerationKey;
	delete  from SC_CatalogNodeItems_TEMP WHERE JobGenerationKey = @JobGenerationKey;
	delete  from SC_ItemMaster_TEMP WHERE JobGenerationKey = @JobGenerationKey;
	delete  from SC_Catalog_NSM_TEMP WHERE JobGenerationKey = @JobGenerationKey;
END;
GO
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_DelCatalogServerMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_DelCatalogServerMediaFile
	END

GO

-- #desc							Del Catalog Media File
-- #bl_class						Premier.Inventory.CatalogServerMediaFile.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @InstallationID			InstallationID
-- #param @ServerName				Server Name
-- #param @MediaFileUniqueID	    Media File UniqueID

CREATE Procedure [dbo].INV_DelCatalogServerMediaFile
(
	@InstallationId		    NVARCHAR(3),
	@ServerName             NVARCHAR(128),
    @MediaFileUniqueID      DECIMAL
)
AS

	DELETE 
	FROM CATALOGSERVERMEDIAFILE
	WHERE
	        InstallationID      = @InstallationID
		AND ServerName          = @ServerName
		AND MediaFileUniqueID   = @MediaFileUniqueID
		
		
--Delete image when there's no nobody related to the image		
IF((SELECT COUNT(*) FROM catalogitemmediafile   WHERE MEDIAFILEUNIQUEID = @MediaFileUniqueID)=0 AND
	(SELECT COUNT(*) FROM CATALOGSERVERMEDIAFILE WHERE MediaFileUniqueID = @MediaFileUniqueID)=0)
		BEGIN
			DELETE FROM CATALOGMEDIAFILE
			WHERE MediaFileUniqueID  = @MediaFileUniqueID
		END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_DelProductsWithoutContent'))
	BEGIN
		DROP  Procedure  [dbo].INV_DelProductsWithoutContent
	END
GO

-- #desc					Indicates if the Product Content is referred in catalogMedia or catalog nodes. And delete the SC_ItemMaster in some cases
-- #bl_class				Premier.Inventory.ItemWebContentHeader.cs/UpdateProductContentInfoCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @ProductNumber	Product Number.
-- #param @StoreId			Store ID.

CREATE PROCEDURE [dbo].INV_DelProductsWithoutContent
(
	@StoreId NVARCHAR(3),
	@ProductNumber FLOAT
)
AS
	DECLARE @PRODUCTSONSOMECAT TABLE(
            ShortProductNumber DECIMAL UNIQUE
        )    

    --Products referenced by other catalogs  with same store
    INSERT INTO @PRODUCTSONSOMECAT(ShortProductNumber)
        SELECT DISTINCT A.ShortItemNumber 
        FROM SC_CatalogNodeItems A
        WHERE A.InstallationID = @StoreId  and A.ShortItemNumber = @ProductNumber 

    --Delete the SC_ItemMaster record only if that record is not referred by another catalog
	DELETE [dbo].SC_ItemMaster 
    WHERE InstallationID = @StoreId
    AND ShortItemNumber = @ProductNumber 
	AND ShortItemNumber NOT IN (SELECT DISTINCT ShortProductNumber FROM @PRODUCTSONSOMECAT);

	--Get the number of images and the catalog nodes that use the product in the specific store
	SELECT COUNT(*) as ProductsCount
	FROM (
		SELECT ItemNumber FROM CATALOGITEMMEDIAFILE WHERE InstallationID = @StoreId and ItemNumber = @ProductNumber
		UNION all
		SELECT ShortProductNumber FROM @PRODUCTSONSOMECAT WHERE ShortProductNumber = @ProductNumber
	) A
GO



  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcAddCatalogNSMItemMaster'))
BEGIN
	DROP  Procedure  [dbo].INV_ExcAddCatalogNSMItemMaster
END
GO
-- #desc						Add basic item information
-- #bl_class					Premier.Inventory.CatalogNSMItemMasterInsertCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID
-- #param @ShortItemNumber		Short Item Number	
-- #param @DisplayItemNumber	Display Item Number
-- #param @Description1			Description 1		
-- #param @Description2			Description 2		
-- #param @Content				Content			
-- #param @UserID				User ID			
-- #param @WorkStationID		WorkStation ID	
-- #param @DateUpdated			Date Updated		
-- #param @TimeUpdated			Time Updated

/* This stored procedure will be called only to insert basic item information that needs to be available in the MC Item Images List. */

CREATE PROCEDURE [dbo].INV_ExcAddCatalogNSMItemMaster
	@InstallationID				NVARCHAR(3),
	@ShortItemNumber			DECIMAL,
	@DisplayItemNumber			NVARCHAR(25),
	@Description1				NVARCHAR(30),
	@Description2				NVARCHAR(30),
	@Content					NVARCHAR(MAX),
	@UserID						NVARCHAR(10),
	@WorkStationID				NVARCHAR(128),
	@DateUpdated				DECIMAL,
	@TimeUpdated				DECIMAL
AS
BEGIN
	DECLARE @ExistItem DECIMAL = 0;
	DECLARE @InserItem DECIMAL = 0;

	/* When is not BASE installation */
	IF (@InstallationID <> '***') BEGIN
		/* Verify if exist the record */
		SELECT @ExistItem = COUNT(*) FROM SC_ItemMaster IM WHERE IM.ShortItemNumber = @ShortItemNumber AND IM.InstallationID = @InstallationID
		IF(@ExistItem = 0)BEGIN
			/* Turn on the flag to insert item information */
			SET @InserItem = 1; 
		END;
	END
	ELSE IF(@InstallationID = '***') BEGIN
		/* Delete record associated to BASE installation */
		DELETE FROM SC_ItemMaster WHERE ShortItemNumber = @ShortItemNumber AND InstallationID = @InstallationID
		/* Turn on the flag to insert item information */
		SET @InserItem = 1;		
	END

	/* Validate if flag to insert item is on */
	IF(@InserItem = 1) BEGIN 
		INSERT INTO SC_ItemMaster
			(
				InstallationID,
				ShortItemNumber,
				DisplayItemNumber,
				Description1,
				Description2,
				Description3,
				Content,
				BranchPlant,
				StockingType,
				InventoryFlag,
				ListPrice,
				ForeignListPrice,
				CurrencyMode,
				CurrencyCode,
				ForeignCurrencyCode,
				DefaultUnitOfMeasure,
				PrimaryUnitOfMeasure,
				PricingUnitOfMeasure,
				ShippingUnitOfMeasure,
				SCType,
				Template,
				ContentStatus,
				UserID,
				WorkStationID,
				DateUpdated,
				TimeUpdated
			)
			VALUES(
				@InstallationID,
				@ShortItemNumber,
				@DisplayItemNumber,
				@Description1,
				@Description2,
				' ',
				@Description1 + ' '  + @Description2 + ' '  + @Content,
				' ',
				' ',
				' ',
				0,
				0,
				' ',
				' ',
				' ',
				' ',
				' ',
				' ',
				' ',
				' ',
				' ',
				' ',
				@UserID,
				@WorkStationID,
				@DateUpdated,
				@TimeUpdated
			)
	END
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcCatalogNSMExistItem'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcCatalogNSMExistItem
	END

GO

-- #desc						Verify that item belongs at least one published catalog
-- #bl_class					Premier.Inventory.CatalogNSMExistItemCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Item Number

CREATE Procedure [dbo].INV_ExcCatalogNSMExistItem
(
	@InstallationID         NVARCHAR(3),
	@ItemNumber             DECIMAL
)
AS

	SELECT COUNT(*)
	FROM SC_CatalogNodeItems
	WHERE
	    InstallationID = @InstallationID AND
		ShortItemNumber = @ItemNumber

GO 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcCopyInstallationMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcCopyInstallationMediaFile
	END

GO

-- #desc						Copy an Installation of the Media Files.
-- #bl_class					Premier.Inventory.CopyStoreMediaFilesCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID	    Installation ID.
-- #param @InstallationIDFrom	Copy Installation ID.
-- #param @SelectionKeys        Selection Keys.
-- #param @UserID				User ID.

CREATE Procedure [dbo].[INV_ExcCopyInstallationMediaFile]
(
	@InstallationID		NVARCHAR(3),
	@InstallationIDFrom NVARCHAR(3),
	@UserID				decimal
)
AS

BEGIN

	DECLARE @MediaFileUniqueIDToCopy DECIMAL
	DECLARE @NewMediaFileUniqueID DECIMAL
	DECLARE @CursorImagesToCopy CURSOR

	--get the mediafileuniqueid of the images of the items by origin installation
	SET @CursorImagesToCopy = CURSOR FAST_FORWARD --this cursor works with less overhead
	FOR
		SELECT
			MediaFileUniqueID
		FROM CATALOGITEMMEDIAFILE CIF
		WHERE CIF.InstallationID = @InstallationIDFrom


	OPEN @CursorImagesToCopy
	FETCH NEXT FROM @CursorImagesToCopy
	INTO @MediaFileUniqueIDToCopy --the first record of the cursor

	WHILE @@FETCH_STATUS = 0 --while to make the insert into the CATALOGMEDIAFILE
	BEGIN

		--get the new UniqueID for the current image to copy
		SET @NewMediaFileUniqueID = (SELECT MAX (MediaFileUniqueID)+1 FROM CATALOGMEDIAFILE)

		--copy into the IMAGES MASTER TABLE
		INSERT INTO CATALOGMEDIAFILE (MediaFileUniqueID, MediaFileName, OriginalFileName, MediaFileType, ReSizeConstantPolicy, InstallationOwner, MediaFileComments, MediaFileBody, MediaFileThumbnail, MediaFileCheckSum, DateInsert, TimeInsert, UserInsert, UserUpdate, LastDateUpdated, LastTimeUpdated)
			SELECT 
				@NewMediaFileUniqueID,
				CMF.MediaFileName,
				CMF.OriginalFileName,
				CMF.MediaFileType,
				CMF.ReSizeConstantPolicy,
				@InstallationID, --installationOwner
				CMF.MediaFileComments,
				CMF.MediaFileBody,
				CMF.MediaFileThumbnail,
				CMF.MediaFileCheckSum,
				CMF.DateInsert,
				CMF.TimeInsert,
				CMF.UserInsert,
				CMF.UserUpdate,
				CMF.LastDateUpdated,
				CMF.LastTimeUpdated
			FROM CATALOGMEDIAFILE CMF
			WHERE
				CMF.MEDIAFILEUNIQUEID = @MediaFileUniqueIDToCopy AND
				CMF.INSTALLATIONOWNER = @InstallationIDFrom
		
		INSERT INTO CATALOGITEMMEDIAFILE (InstallationID, ItemNumber, MediaFileUniqueID, PriorityIndex, LastDateUpdated, LastTimeUpdated, DefaultImage)
		SELECT
			@InstallationID,
			ItemNumber,
			@NewMediaFileUniqueID, --with the last inserted id in the CatalogMediaFile table
			PriorityIndex,
			LastDateUpdated,
			LastTimeUpdated,
			DefaultImage
		FROM CATALOGITEMMEDIAFILE
		WHERE
			MediaFileUniqueID = @MediaFileUniqueIDToCopy AND
			InstallationID = @InstallationIDFrom
		
		FETCH NEXT FROM @CursorImagesToCopy 
		INTO @MediaFileUniqueIDToCopy --get the next row
	END

	CLOSE @CursorImagesToCopy
	DEALLOCATE @CursorImagesToCopy

	--Copy item content info from original installation to the copy. This is done because item images descriptions may be empty when item content is for a specific installation
	INSERT INTO [dbo].SC_ItemMaster (InstallationID,ShortItemNumber,DisplayItemNumber,Description1,Description2,Description3,Content,BranchPlant,StockingType,
							   InventoryFlag,ListPrice,ForeignListPrice,CurrencyMode,CurrencyCode,ForeignCurrencyCode,DefaultUnitOfMeasure,PrimaryUnitOfMeasure,PricingUnitOfMeasure,
							   ShippingUnitOfMeasure,SCType,Template,ContentStatus,UserID,WorkStationID,DateUpdated,TimeUpdated)
	SELECT
		@InstallationID,
		ShortItemNumber,
		DisplayItemNumber,
		Description1,
		Description2,
		Description3,
		Content,
		BranchPlant,
		StockingType,
		InventoryFlag,
		ListPrice,
		ForeignListPrice,
		CurrencyMode,
		CurrencyCode,
		ForeignCurrencyCode,
		DefaultUnitOfMeasure,
		PrimaryUnitOfMeasure,
		PricingUnitOfMeasure,
		ShippingUnitOfMeasure,
		SCType,
		Template,
		ContentStatus,
		UserID,
		WorkStationID,
		DateUpdated, 
		TimeUpdated  
	FROM [dbo].SC_ItemMaster
	WHERE InstallationID = @InstallationIDFrom
	
END 
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcCopyItemMediaFileToInst'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcCopyItemMediaFileToInst
	END

GO

-- #desc								Copy Item Media File to Specific Installation
-- #bl_class							Premier.Inventory.CatalogItemMediaFile.cs
-- #db_dependencies						N/A
-- #db_references						N/A

-- #param @SourceInstallation			Source Installation ID
-- #param @TargetInstallation			Target Installation ID  
-- #param @ItemNumber					Item Number.
-- #param @DuplicateMediaFileContent	1 Mark as deleted current images in DB then delete the images and insert the same images but with @TargetInstallation / 1 Duplicate images to new installation without delete them, just generate a new Id

CREATE Procedure [dbo].INV_ExcCopyItemMediaFileToInst
(
	@SourceInstallation NVARCHAR(3),
	@TargetInstallation NVARCHAR(3),
	@ItemNumber			DECIMAL,
	@DuplicateMediaFileContent INT
)
AS
BEGIN
	DECLARE @MediaFileUniqueIDToCopy DECIMAL
	DECLARE @NewMediaFileUniqueID DECIMAL
	DECLARE @CursorImagesToCopy CURSOR

	IF (@DuplicateMediaFileContent = 1) 
		BEGIN
		--Get the MediafileUniqueId of items images of origin installation
		SET @CursorImagesToCopy = CURSOR FAST_FORWARD --this cursor works with less overhead
		FOR
			SELECT
				MediaFileUniqueID
			FROM CATALOGITEMMEDIAFILE CIF
			WHERE 
				CIF.InstallationID = @SourceInstallation AND
				ItemNumber = @ItemNumber

		OPEN @CursorImagesToCopy
		FETCH NEXT FROM @CursorImagesToCopy
		INTO @MediaFileUniqueIDToCopy --the first record of the cursor

		WHILE @@FETCH_STATUS = 0 --while to make the insert into the CATALOGMEDIAFILE
		BEGIN

			--get the new UniqueID for the current image to copy
			SET @NewMediaFileUniqueID = (SELECT MAX (MediaFileUniqueID)+1 FROM CATALOGMEDIAFILE)

			--copy into the IMAGES MASTER TABLE
			INSERT INTO CATALOGMEDIAFILE (MediaFileUniqueID, MediaFileName, OriginalFileName, MediaFileType, ReSizeConstantPolicy, InstallationOwner, MediaFileComments, MediaFileBody, MediaFileThumbnail, MediaFileCheckSum, DateInsert,TimeInsert,UserInsert,UserUpdate,LastDateUpdated,LastTimeUpdated)
				SELECT 
					@NewMediaFileUniqueID,
					CMF.MediaFileName,
					CMF.OriginalFileName,
					CMF.MediaFileType,
					CMF.ReSizeConstantPolicy,
					@TargetInstallation, --installationOwner
					CMF.MediaFileComments,
					CMF.MediaFileBody,
					CMF.MediaFileThumbnail,
					CMF.MediaFileCheckSum,
					CMF.DateInsert,
					CMF.TimeInsert,
					CMF.UserInsert,
					CMF.UserUpdate,
					CMF.LastDateUpdated,
					CMF.LastTimeUpdated
				FROM CATALOGMEDIAFILE CMF
				WHERE
					CMF.MEDIAFILEUNIQUEID = @MediaFileUniqueIDToCopy
		
			INSERT INTO CATALOGITEMMEDIAFILE (InstallationID,ItemNumber,MediaFileUniqueID,PriorityIndex,LastDateUpdated,LastTimeUpdated, DefaultImage)
			SELECT
				@TargetInstallation,
				ItemNumber,
				@NewMediaFileUniqueID, --with the last inserted id in the CatalogMediaFile table
				PriorityIndex,
				LastDateUpdated,
				LastTimeUpdated,
				DefaultImage			 
			FROM CATALOGITEMMEDIAFILE
			WHERE
				InstallationID = @SourceInstallation AND
				ItemNumber = @ItemNumber AND
				MediaFileUniqueID = @MediaFileUniqueIDToCopy
		
			FETCH NEXT FROM @CursorImagesToCopy 
			INTO @MediaFileUniqueIDToCopy --get the next row
		END

		CLOSE @CursorImagesToCopy
		DEALLOCATE @CursorImagesToCopy
	END	
	ELSE
		--Replace Images      
		BEGIN 
		--Mark as Delete Previous Target Content
				;WITH CTE AS (
					SELECT MF.MediaFileUniqueID 
					FROM [dbo].CATALOGMEDIAFILE MF
					WHERE EXISTS (SELECT 1 FROM [dbo].CATALOGITEMMEDIAFILE IMF
							WHERE IMF.InstallationID = @TargetInstallation AND
								IMF.ItemNumber = @ItemNumber AND
								IMF.MediaFileUniqueID = MF.MediaFileUniqueID)
				)
				UPDATE SMF SET MediaFileStatus = 'DEL'
				FROM [dbo].CATALOGSERVERMEDIAFILE SMF
					INNER JOIN CTE A
					ON A.MediaFileUniqueID = SMF.MediaFileUniqueID
				WHERE SMF.InstallationID = @TargetInstallation    
		
		--Delete Previous Target Content
		DELETE FROM CATALOGITEMMEDIAFILE
		WHERE  
			InstallationID = @TargetInstallation AND
			ItemNumber = @ItemNumber
		
		--Copy catalog item media file table     
		INSERT INTO CATALOGITEMMEDIAFILE (InstallationID,ItemNumber,MediaFileUniqueID,PriorityIndex,LastDateUpdated,LastTimeUpdated, DefaultImage)
		SELECT
			@TargetInstallation,
			ItemNumber,
			MediaFileUniqueID,
			PriorityIndex,
			LastDateUpdated,
			LastTimeUpdated,
			DefaultImage
		FROM CATALOGITEMMEDIAFILE
		WHERE  
			InstallationID = @SourceInstallation AND
			ItemNumber = @ItemNumber 

			/* Update Catalog Media File Installation Owner Column */
		UPDATE CM SET CM.InstallationOwner = @TargetInstallation 
		FROM [dbo].CATALOGMEDIAFILE CM 
			INNER JOIN [dbo].CATALOGITEMMEDIAFILE CI
			ON CI.MediaFileUniqueID = CM.MediaFileUniqueID
		WHERE CI.InstallationID = @SourceInstallation 
			AND CI.ItemNumber = @ItemNumber;

		END
END	
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcDelInstallationMediaFile'))
BEGIN
	DROP  Procedure  [dbo].INV_ExcDelInstallationMediaFile
END

GO

-- #desc						Delete all the images of a specific installation
-- #bl_class					Premier.Inventory.DelStoreMediaFileCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID

CREATE Procedure [dbo].[INV_ExcDelInstallationMediaFile]
(
	@InstallationId NVARCHAR(3)
)
AS
	DELETE CIMF FROM CATALOGITEMMEDIAFILE CIMF
	WHERE CIMF.MediaFileUniqueID IN (SELECT CMF.MediaFileUniqueID FROM CATALOGMEDIAFILE CMF
								WHERE CMF.InstallationOwner = @InstallationId)

	DELETE CSMF FROM CATALOGSERVERMEDIAFILE CSMF
	WHERE CSMF.MediaFileUniqueID IN (SELECT CMF.MediaFileUniqueID FROM CATALOGMEDIAFILE CMF
								WHERE CMF.InstallationOwner = @InstallationId)

	DELETE CMF FROM CATALOGMEDIAFILE CMF WHERE CMF.InstallationOwner = @InstallationId
	
GO 
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcExistItemMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcExistItemMediaFile
	END

GO

-- #desc						Exist Item Media File
-- #bl_class					Premier.Inventory.CatalogItemMediaFiles.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Item Number
-- #param @MediaFileUniqueID	Media File UniqueID

CREATE Procedure [dbo].INV_ExcExistItemMediaFile
(
	@InstallationID         NVARCHAR(3),
	@ItemNumber             DECIMAL
)
AS

	SELECT COUNT(*)
	FROM CATALOGITEMMEDIAFILE
	WHERE
	    InstallationID = @InstallationID AND
		ItemNumber = @ItemNumber

GO 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcGetInstallationDelMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcGetInstallationDelMediaFile
	END

GO

-- #desc					Get the row count of installation related tables.
-- #bl_class				Premier.Inventory.GetStoreDelMediaFileInfoCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @InstallationID	Installation ID.

CREATE Procedure [dbo].INV_ExcGetInstallationDelMediaFile
(
	@InstallationID			NVARCHAR(3),		
	@TotalCount				DECIMAL = NULL OUTPUT
)
AS
	DECLARE @ItemMediaFile		DECIMAL
	SET NOCOUNT ON				
	
	--Catalog Item Media File
	SET @ItemMediaFile = (SELECT COUNT(*) FROM CATALOGITEMMEDIAFILE WHERE InstallationID = @InstallationID)
	 
	SET @TotalCount =	@ItemMediaFile
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcGetItemDefaultMediaFile'))
BEGIN
	DROP  Procedure  [dbo].INV_ExcGetItemDefaultMediaFile
END

GO

-- #desc						Get Item Default Media File
-- #bl_class					Premier.Inventory.GetItemDefaultMediaFileCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Item Number
-- #param @RetrieveImageBody	Retrieve Image Body

CREATE Procedure [dbo].INV_ExcGetItemDefaultMediaFile
(
	@InstallationID		    NVARCHAR(3),
	@ItemNumber             DECIMAL,
    @RetrieveImageBody      DECIMAL
)
AS
	IF(@RetrieveImageBody = 1) BEGIN
		SELECT TOP 1 
			Item.MediaFileUniqueID,
			MediaFile.MediaFileBody
		FROM CATALOGITEMMEDIAFILE AS Item
		INNER JOIN CATALOGMEDIAFILE AS MediaFile
			ON Item.MediaFileUniqueID = MediaFile.MediaFileUniqueID
		WHERE
			Item.InstallationID	= @InstallationID
			AND (@ItemNumber IS NULL OR Item.ItemNumber	= @ItemNumber)
		ORDER BY Item.PriorityIndex ASC
	END
	ELSE BEGIN
		SELECT TOP 1 
			MediaFileUniqueID,
			0 AS MediaFileBody
		FROM CATALOGITEMMEDIAFILE
		WHERE
			InstallationID = @InstallationID
			AND (@ItemNumber IS NULL OR ItemNumber = @ItemNumber)
		ORDER BY PriorityIndex ASC
	END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcGetItemMediaFilePriority'))
BEGIN
	DROP  Procedure  [dbo].INV_ExcGetItemMediaFilePriority
END

GO

-- #desc							Get Item Media File Priority
-- #bl_class						N/A
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @InstallationID			InstallationID
-- #param @ItemNumber				Item Number
-- #param @PriorityIndex			Priority Index

CREATE Procedure [dbo].INV_ExcGetItemMediaFilePriority
(
	@InstallationID		NVARCHAR(3),
	@ItemNumber			DECIMAL,
	@PriorityIndex		DECIMAL OUTPUT
)
AS
	
		SET @PriorityIndex = (SELECT MAX (PriorityIndex)+1 FROM CATALOGITEMMEDIAFILE WHERE InstallationID = @InstallationID AND ItemNumber = @ItemNumber);
		--SET 1 IF THE MAX IS NULL
		IF(@PriorityIndex IS NULL)
		BEGIN
			SET @PriorityIndex = 1
		END
GO


 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcPublishCatalogNSM'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcPublishCatalogNSM
	END

GO
-- #desc						Publish Temporary Catalog Nested Data 
-- #bl_class					Premier.Inventory.Premier.Inventory.CatalogNSMGenerateCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @JobGenerationKey	    Unique Identifier of the Job trigger
-- #param @InstallationID		Installation ID	
-- #param @CatalogID			Catalog ID


CREATE PROCEDURE [dbo].INV_ExcPublishCatalogNSM
(
		@JobGenerationKey DECIMAL,
		@InstallationID NVARCHAR(3),/*Installation Identifier SC_Catalog_NSM_TEMP*/
		@CatalogID NVARCHAR(3),/*Catalog ID*/
		@UserID NVARCHAR(10),
		@WorkStation NVARCHAR(128),
		@DateUpdated DECIMAL,
		@TimeUpdated DECIMAL
	)
	AS
	BEGIN
		--TRANSACTION BEGINS
		BEGIN TRANSACTION
		BEGIN TRY
			DECLARE @FILTERTABLE TABLE(
					ShortItemNumber DECIMAL UNIQUE
				)	
			DECLARE @ITEMSNOTSAMECAT TABLE(
					ShortItemNumber DECIMAL UNIQUE
				)	
			DECLARE @ItemsToBeUpdated TABLE(
					ShortItemNumber DECIMAL UNIQUE
				)
		    
		    --Items referenced by other catalogs  with same installation
			INSERT INTO @ITEMSNOTSAMECAT(ShortItemNumber)
				SELECT DISTINCT A.ShortItemNumber 
				FROM SC_CatalogNodeItems A
				INNER JOIN SC_CatalogNodeItems_Temp TMP
				ON A.InstallationID = TMP.InstallationID
				AND A.ShortItemNumber = TMP.ShortItemNumber
				WHERE A.InstallationID = @InstallationID 
				AND A.CatalogID <> @CatalogID 
				AND TMP.JobGenerationKey = @JobGenerationKey;

			/*Items of the same installation that are not referenced in others catalogs*/
			INSERT INTO @FILTERTABLE(ShortItemNumber)
			  SELECT DISTINCT ShortItemNumber 
				FROM SC_CatalogNodeItems 
				WHERE InstallationID = @InstallationID AND  CatalogID = @CatalogID 	
					  AND   
						ShortItemNumber NOT IN (SELECT DISTINCT ShortItemNumber FROM SC_CatalogNodeItems WHERE CatalogID <> @CatalogID and InstallationID = @InstallationID )	
					  AND 
						ShortItemNumber NOT IN (SELECT DISTINCT ShortItemNumber FROM @ITEMSNOTSAMECAT )
			
			BEGIN --ITEMS DELETION						
				
				DELETE [dbo].SC_ItemMasterLangs 
				FROM [dbo].SC_ItemMasterLangs A 
				INNER JOIN SC_ItemMasterLangs_Temp B
				ON A.InstallationID = B.InstallationID
				AND A.ShortItemNumber = B.ShortItemNumber
				WHERE B.JobGenerationKey = @JobGenerationKey;
				
				-- Delete items not longer referenced by this catalog and can be deleted in this installation
				DELETE [dbo].SC_ItemMasterLangs
				FROM [dbo].SC_ItemMasterLangs LN
				JOIN @FILTERTABLE B 
				ON LN.ShortItemNumber = B.ShortItemNumber
				WHERE LN.InstallationID = @InstallationID;				

				/* Items in other catalog referenced by other catalogs 
				 * @ITEMSNOTSAMECAT 
				 */
				INSERT INTO @ItemsToBeUpdated(ShortItemNumber)
				SELECT ShortItemNumber FROM @ITEMSNOTSAMECAT
			
			END --ITEMS TABLES RELATED			
			BEGIN --NODES TABLES RELATED DELETION
			
				DELETE FROM SC_CatalogLangs WHERE InstallationID = @InstallationID and CatalogId = @CatalogID ;
				DELETE FROM SC_CatalogNodeItems WHERE InstallationID = @InstallationID AND  CatalogID = @CatalogID;
				
			END --END 		
			
			DELETE FROM [dbo].SC_Catalog_NSM WHERE InstallationID = @InstallationID AND  CatalogID = @CatalogID;
			
			/* Delete items not longer referenced by this catalog and can be deleted in this installation 
			 * Do not delete if item has related images
			 * Do not delete if item is a matrix child and is referenced by other catalog
			 */
			DELETE [dbo].SC_ItemMaster 
			FROM [dbo].SC_ItemMaster A 
			INNER JOIN @FILTERTABLE B 
			ON A.ShortItemNumber = B.ShortItemNumber
			WHERE A.InstallationID = @InstallationID
			AND A.ShortItemNumber NOT IN (SELECT DISTINCT ItemNumber FROM CATALOGITEMMEDIAFILE);

			BEGIN --BEGIN MOVE TEMPORARY DATA
				
				/* To do update table */

				UPDATE Node 
				SET  Node.URLPath = [dbo].INV_GetCatalogNSMBreadCrumbFnc(@JobGenerationKey, @InstallationID, @CatalogID, Node.NodeID), 
				Node.PathCode = [dbo].CMM_GetASCIIValueSumFnc(dbo.INV_GetCatalogNSMBreadCrumbFnc(@JobGenerationKey, @InstallationID, @CatalogID, Node.NodeID))
				FROM SC_Catalog_NSM_Temp  Node
				WHERE 
					Node.JobGenerationKey = @JobGenerationKey
					AND Node.InstallationID = @InstallationID
					AND Node.CatalogID = @CatalogID;

			    --Catalog Nodes				
				INSERT  
				INTO SC_Catalog_NSM( InstallationID, CatalogID,NodeID,ReferenceID, Description, LeftPosition, RightPosition, MediaFileUniqueID,ApplyEffectiveDates,EffectiveFrom,EffectiveThru,UserID,WorkStationID, DateUpdated,TimeUpdated, URLPath, PathCode)
				SELECT InstallationID, CatalogID,NodeID,ReferenceID, Description, LeftPosition, RightPosition, MediaFileUniqueID, ApplyEffectiveDates, EffectiveFrom, EffectiveThru, UserID, WorkStationID, DateUpdated, TimeUpdated, URLPath, PathCode
					FROM SC_Catalog_NSM_Temp
					WHERE  JobGenerationKey =@JobGenerationKey							
				
				--Catalog Langs				
				INSERT
				INTO SC_CatalogLangs(InstallationID ,CatalogID ,NodeID, LanguageID, Description)
				SELECT InstallationID ,CatalogID ,NodeID, LanguageID, Description 
					FROM SC_CatalogLangs_Temp
					WHERE JobGenerationKey =@JobGenerationKey ;
					
				--Catalog Items
				INSERT 
				INTO SC_ItemMaster(InstallationID,ShortItemNumber,DisplayItemNumber, Description1, Description2, Description3, Content,BranchPlant, StockingType, InventoryFlag, ListPrice, ForeignListPrice, CurrencyMode, CurrencyCode, ForeignCurrencyCode,DefaultUnitOfMeasure,PrimaryUnitOfMeasure,PricingUnitOfMeasure, ShippingUnitOfMeasure, ScType, Template, UserID, WorkStationID,DateUpdated,TimeUpdated)
				SELECT TMP.InstallationID,TMP.ShortItemNumber,TMP.DisplayItemNumber, TMP.Description1, TMP.Description2, TMP.Description3, TMP.Content, TMP.BranchPlant,TMP.StockingType, TMP.InventoryFlag, TMP.ListPrice, TMP.ForeignListPrice, TMP.CurrencyMode, TMP.CurrencyCode, TMP.ForeignCurrencyCode, TMP.DefaultUnitOfMeasure, TMP.PrimaryUnitOfMeasure, TMP.PricingUnitOfMeasure, TMP.ShippingUnitOfMeasure, TMP.ScType, TMP.Template, TMP.UserID, TMP.WorkStationID, TMP.DateUpdated, TMP.TimeUpdated
				FROM  SC_ItemMaster_TEMP TMP
				WHERE TMP.JobGenerationKey = @JobGenerationKey
				AND TMP.InstallationID = @InstallationID
				AND NOT EXISTS (SELECT TOP 1 * FROM SC_ItemMaster ITM WHERE ITM.InstallationID = @InstallationID AND ITM.ShortItemNumber = TMP.ShortItemNumber)
						
				---Catalog Relation between Node and Items
				INSERT 
				INTO SC_CatalogNodeItems(InstallationID ,CatalogID ,NodeID ,ShortItemNumber,Priority )
				SELECT InstallationID ,CatalogID ,NodeID ,ShortItemNumber,Priority  
					FROM SC_CatalogNodeItems_TEMP 
					WHERE JobGenerationKey = @JobGenerationKey;
				
				--Item Master Langs
				INSERT 
				INTO SC_ItemMasterLangs(InstallationID,ShortItemNumber,LanguageID,Description1,Description2,Description3,Content)
				SELECT InstallationID,ShortItemNumber,LanguageID,Description1,Description2,Description3,Content
				FROM SC_ItemMasterLangs_TEMP TMP
				WHERE TMP.JobGenerationKey = @JobGenerationKey
				AND	NOT EXISTS ( SELECT TOP 1 * FROM SC_ItemMasterLangs IL WHERE IL.InstallationID = TMP.InstallationID AND IL.ShortItemNumber = TMP.ShortItemNumber AND IL.LanguageID = TMP.LanguageID)
					
			    /* Update the items that exist referenced by other catalog 
				 * Update items that is a matrix child and is referenced by other catalog
				*/
						
				UPDATE itm 
					SET  itm.DisplayItemNumber = itmTemp.DisplayItemNumber, itm.Description1 = itmTemp.Description1, itm.Description2 = itmTemp.Description2, 
						itm.Description3 = itmTemp.Description3, itm.Content = itmTemp.Content, itm.BranchPlant = itmTemp.BranchPlant, itm.StockingType = itmTemp.StockingType, 
						itm.InventoryFlag = itmTemp.InventoryFlag, itm.ListPrice = itmTemp.ListPrice, itm.ForeignListPrice = itmTemp.ForeignListPrice,
						itm.CurrencyMode = itmTemp.CurrencyMode, itm.CurrencyCode = itmTemp.CurrencyCode, itm.ForeignCurrencyCode = itmTemp.ForeignCurrencyCode,
						itm.DefaultUnitOfMeasure = itmTemp.DefaultUnitOfMeasure, itm.PrimaryUnitOfMeasure = itmTemp.PrimaryUnitOfMeasure,
						itm.PricingUnitOfMeasure = itmTemp.PricingUnitOfMeasure, itm.ShippingUnitOfMeasure = itmTemp.ShippingUnitOfMeasure, itm.ScType = itmTemp.ScType, 
						itm.Template = itmTemp.Template, itm.UserID = itmTemp.UserID, itm.WorkStationID = itmTemp.WorkStationID, itm.DateUpdated = itmTemp.DateUpdated, 
						itm.TimeUpdated = itmTemp.TimeUpdated
					FROM SC_ItemMaster  itm
					INNER JOIN SC_ItemMaster_Temp itmTemp 
					ON itm.InstallationID = itmTemp.InstallationID 
					AND itm.ShortItemNumber = itmTemp.ShortItemNumber
					INNER JOIN @ItemsToBeUpdated NS /* Items in other catalogs */
					ON itm.ShortItemNumber = NS.ShortItemNumber
					WHERE itmTemp.JobGenerationKey = @JobGenerationKey;	
				
				UPDATE itmLang	
					SET itmLang.Description1=langTemp.Description1, itmLang.Description2=langTemp.Description2,itmLang.Description3=langTemp.Description3, itmLang.Content=langTemp.Content
					FROM SC_ItemMasterLangs itmLang
					INNER JOIN SC_ItemMasterLangs_TEMP langTemp
					ON itmLang.InstallationID=langTemp.InstallationID 
					AND itmLang.ShortItemNumber=langTemp.ShortItemNumber 
					AND  itmLang.LanguageID=langTemp.LanguageID
					AND langTemp.JobGenerationKey =@JobGenerationKey;

			END

			BEGIN /*CLEAN TEMPORARY DATA*/				
				DELETE 
				FROM SC_CatalogLangs_Temp 
				WHERE JobGenerationKey =@JobGenerationKey
					AND CatalogId = @CatalogID 
									
				DELETE 
				FROM [dbo].SC_ItemMasterLangs_Temp 
				WHERE JobGenerationKey =@JobGenerationKey					
				
				DELETE 
				FROM SC_CatalogNodeItems_Temp 
				WHERE JobGenerationKey =@JobGenerationKey		
						
				DELETE FROM SC_ItemMaster_Temp	
				WHERE JobGenerationKey =@JobGenerationKey
					  
				DELETE FROM [dbo].SC_Catalog_NSM_Temp 
				WHERE JobGenerationKey =@JobGenerationKey
			
			END /*CLEAN TEMPORARY DATA*/

			/*COMMIT THE TRANSACTION*/
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

			-- Use RAISERROR inside the CATCH block to return error
			-- information about the original error that caused
			-- execution to jump to the CATCH block.
			RAISERROR (@ErrorMessage, -- Message text.
					   @ErrorSeverity, -- Severity.
					   @ErrorState -- State.
					   );
		END CATCH		
	END;
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcUpdCatalogNSMItem'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcUpdCatalogNSMItem
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc						Publish Item Content Information: Main info, languages.
-- #bl_class					Premier.Inventory.CatalogNSMItemUpdateCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID	
-- #param @ItemID				Item Number
-- #param @CompressedXML        Compressed Data of Items , XML Template : <itemsData><header installationId='' catalogId='' dateUpdated ='' workstationId=''/><items><item shortNum='1' dispNum='1' DefUnitMsr='1'><content></content><description1></description1><description2></description2><description3></description3><brachPlant></brachPlant></item></items><itemsLangs><lang itemNumber='' langId=''><description1></description1><description2></description2><description3></description3></lang></itemsLangs></itemsData>
-- #param @UserID				User ID
-- #param @WorkStation			Work Station ID
-- #param @DateUpdated			Date Updated
-- #param @TimeUpdated			Time Updated


CREATE PROCEDURE [dbo].INV_ExcUpdCatalogNSMItem(
		@InstallationID NVARCHAR(3),	
		@ItemID DECIMAL,
		@CompressedXML VARBINARY(MAX),
		@UserID NVARCHAR(10),
		@WorkStation NVARCHAR(128),
		@DateUpdated DECIMAL,
		@TimeUpdated DECIMAL
	)
	AS
	BEGIN				
		BEGIN TRANSACTION
		BEGIN TRY
			DECLARE @ItemsDataXML XML
			DECLARE @RECORDFOUND INT;
		
			/*CHECK IF ITEM EXISTS*/
			SELECT @RECORDFOUND = COUNT(*) 
			FROM SC_ItemMaster
			WHERE InstallationID = @InstallationID 
			AND ShortItemNumber = @ItemID
		
						
			/*Decompress XML Data*/
			SELECT @ItemsDataXML=dbo.SC_DeCompressXML(@CompressedXML,2);				
			
			
			/*Insert or Update Item Content */
			IF (@RECORDFOUND > 0) BEGIN
				UPDATE it
				SET								
						it.DisplayItemNumber=ItemsData.item.value('@dispNum','NVARCHAR(25)'),
						it.DefaultUnitOfMeasure= ItemsData.item.value('@defUnitMsr','NVARCHAR(MAX)') ,
						it.PrimaryUnitOfMeasure=ItemsData.item.value('@primaryUnitOfMeasure','NVARCHAR(MAX)'),
						it.PricingUnitOfMeasure=ItemsData.item.value('@pricingUnitOfMeasure','NVARCHAR(MAX)'),
						it.ShippingUnitOfMeasure=ItemsData.item.value('@shippingUnitOfMeasure','NVARCHAR(MAX)'),
						it.Description1= ItemsData.item.value('description1[1]','NVARCHAR(MAX)'),
						it.Description2 = ItemsData.item.value('description2[1]','NVARCHAR(MAX)'),
						it.Description3= ItemsData.item.value('description3[1]','NVARCHAR(MAX)'),
						it.Content= ItemsData.item.value('description1[1]','NVARCHAR(MAX)')+ ' ' + 
						ItemsData.item.value('description2[1]','NVARCHAR(MAX)')+ ' ' + 
						ItemsData.item.value('description3[1]','NVARCHAR(MAX)')+ ' ' +
						ItemsData.item.value('content[1]','NVARCHAR(MAX)') ,						
						it.BranchPlant = ItemsData.item.value('branchPlant[1]','NVARCHAR(MAX)'),
						it.UserID= @UserID,
						it.WorkStationID = @WorkStation,
						it.DateUpdated= @DateUpdated,
						it.TimeUpdated = @TimeUpdated,
						it.StockingType = ItemsData.item.value('@stockingType','NVARCHAR(MAX)'),
						it.InventoryFlag = ItemsData.item.value('@inventoryFlag','NVARCHAR(MAX)'),
						it.ScType = ItemsData.item.value('@scType','NVARCHAR(1)'),
						it.Template = ItemsData.item.value('@template','NVARCHAR(20)')
				FROM 
					SC_ItemMaster it
				INNER JOIN
					@ItemsDataXML.nodes('/itemsData/items/item') as ItemsData(item)		
					ON it.InstallationID= @InstallationID 
					AND it.ShortItemNumber = ItemsData.item.value('@shortNum','DECIMAL')
			END
			ELSE BEGIN 
				INSERT INTO SC_ItemMaster
				(InstallationID, 
				ShortItemNumber, 
				DisplayItemNumber,
				Description1, 
				Description2, 
				Description3, 
				Content, 
				BranchPlant, 
				StockingType,
				InventoryFlag,
				ScType,
				Template, 
				DefaultUnitOfMeasure, 
				PrimaryUnitOfMeasure,
				PricingUnitOfMeasure, 
				ShippingUnitOfMeasure, 
				UserID, 
				WorkStationID, 
				DateUpdated, 
				TimeUpdated)
				SELECT 	@InstallationID, @ItemID, ItemsData.item.value('@dispNum','NVARCHAR(25)'),
				ItemsData.item.value('description1[1]','NVARCHAR(MAX)'),
				ItemsData.item.value('description2[1]','NVARCHAR(MAX)'),
				ItemsData.item.value('description3[1]','NVARCHAR(MAX)'),
				ItemsData.item.value('description1[1]','NVARCHAR(MAX)')+ ' ' + 
				ItemsData.item.value('description2[1]','NVARCHAR(MAX)')+ ' ' + 
				ItemsData.item.value('description3[1]','NVARCHAR(MAX)')+ ' ' +
				ItemsData.item.value('content[1]','NVARCHAR(MAX)') ,		
				ItemsData.item.value('branchPlant[1]','NVARCHAR(MAX)'),
				ItemsData.item.value('@stockingType','NVARCHAR(MAX)'),
				ItemsData.item.value('@inventoryFlag','NVARCHAR(MAX)'),
				ItemsData.item.value('@scType','NVARCHAR(1)'),
				ItemsData.item.value('@template','NVARCHAR(20)'),
				ItemsData.item.value('@defUnitMsr','NVARCHAR(MAX)') ,
				ItemsData.item.value('@primaryUnitOfMeasure','NVARCHAR(MAX)'),					
				ItemsData.item.value('@pricingUnitOfMeasure','NVARCHAR(MAX)'),
				ItemsData.item.value('@shippingUnitOfMeasure','NVARCHAR(MAX)'),
				@UserID, @WorkStation, @DateUpdated, @TimeUpdated
				FROM  @ItemsDataXML.nodes('/itemsData/items/item') as ItemsData(item)		
			END;

			DELETE 
			FROM SC_ItemMasterLangs 
			WHERE InstallationID= @InstallationID AND ShortItemNumber = @ItemID
			--Items Langs Insert		
			INSERT INTO SC_ItemMasterLangs(InstallationID,ShortItemNumber,LanguageID,Description1,Description2,Description3,Content)
			SELECT	
					@InstallationID,
					@ItemID,
					ItemsLangs.lang.value('@langId','NVARCHAR(MAX)'),
					ItemsLangs.lang.value('description1[1]','NVARCHAR(MAX)'),
					ItemsLangs.lang.value('description2[1]','NVARCHAR(MAX)'),
					ItemsLangs.lang.value('description3[1]','NVARCHAR(MAX)'),
					ItemsLangs.lang.value('description1[1]','NVARCHAR(MAX)')+ ' ' + 
					ItemsLangs.lang.value('description2[1]','NVARCHAR(MAX)')+ ' ' + 
					ItemsLangs.lang.value('description3[1]','NVARCHAR(MAX)')+ ' ' + 		
					ItemsLangs.lang.value('content[1]','NVARCHAR(MAX)')										
			FROM @ItemsDataXML.nodes('/itemsData/itemsLangs/lang') as ItemsLangs(lang)	
				 
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

			-- Use RAISERROR inside the CATCH block to return error
			-- information about the original error that caused
			-- execution to jump to the CATCH block.
			RAISERROR (@ErrorMessage, -- Message text.
						@ErrorSeverity, -- Severity.
						@ErrorState -- State.
						);
		END CATCH				
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcUpdCatalogNSMItems'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcUpdCatalogNSMItems
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc						Publish Item Content Information: Main info, languages.
-- #bl_class					Premier.Inventory.CatalogNSMItemsUpdateCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID
-- #param @CompressedXML        Compressed Data of Items , XML Template : 
								/*<itemsData>
								<items><item defUnitMsr="" primaryUnitOfMeasure="" pricingUnitOfMeasure="" shippingUnitOfMeasure="" shortNum="" dispNum="" stockingType="" inventoryFlag="" scType="" template=""><description1></description1><description2></description2><description3 /><branchPlant></branchPlant><content></content></item></items>
								<itemsLangs><lang itemNumber="" langId=""><description1></description1><description2></description2><description3 /><content></content></lang></itemsLangs>
								</itemsData>*/
-- #param @ItemsInstallations	XML with Items and Installations, XML Template : 
								/*
								*/
-- #param @UserID				User ID
-- #param @WorkStation			Work Station ID
-- #param @DateUpdated			Date Updated
-- #param @TimeUpdated			Time Updated


CREATE PROCEDURE [dbo].INV_ExcUpdCatalogNSMItems
(
	@CompressedXML 	VARBINARY(MAX),
	@CompressedItemsInstallations	VARBINARY(MAX),
	@UserID 		NVARCHAR(10),
	@WorkStation 	NVARCHAR(128),
	@DateUpdated 	DECIMAL,
	@TimeUpdated 	DECIMAL
)
AS
BEGIN				
	BEGIN TRANSACTION
	
	BEGIN TRY
		DECLARE @ItemsDataXML XML;
		DECLARE @ItemsInstallatiosDataXML XML;
		
		/*Decompress XML Data*/
		SELECT @ItemsDataXML = [dbo].SC_DeCompressXML(@CompressedXML,2);	
		SELECT @ItemsInstallatiosDataXML = [dbo].SC_DeCompressXML(@CompressedItemsInstallations, 2);	
		
		SELECT 	
			ItemsData.item.value('@shortNum','DECIMAL') AS ShortNum, 
			ItemsInstallationsData.itemInst.value('@installationID','NVARCHAR(3)') AS InstallationID,
			ItemsData.item.value('@dispNum','NVARCHAR(25)') AS DispNum,
			ItemsData.item.value('description1[1]','NVARCHAR(30)') AS Description1,
			ItemsData.item.value('description2[1]','NVARCHAR(30)') AS Description2,
			ItemsData.item.value('description3[1]','NVARCHAR(30)') AS Description3,
			ItemsData.item.value('description1[1]','NVARCHAR(30)')+ ' ' + 
			ItemsData.item.value('description2[1]','NVARCHAR(30)')+ ' ' + 
			ItemsData.item.value('description3[1]','NVARCHAR(30)')+ ' ' +
			ItemsData.item.value('content[1]','NVARCHAR(MAX)') AS Content,		
			ItemsData.item.value('branchPlant[1]','NVARCHAR(MAX)') AS BranchPlant,
			ItemsData.item.value('@stockingType','NVARCHAR(2)') AS StockingType,
			ItemsData.item.value('@inventoryFlag','NVARCHAR(1)') AS InventoryFlag,
			ItemsData.item.value('@scType','NVARCHAR(2)') AS ScType,
			ItemsData.item.value('@template','NVARCHAR(20)') AS Template,
			ItemsData.item.value('@defUnitMsr','NVARCHAR(3)') AS DefUnitMsr,
			ItemsData.item.value('@primaryUnitOfMeasure','NVARCHAR(3)') AS PrimaryUnitOfMeasure,					
			ItemsData.item.value('@pricingUnitOfMeasure','NVARCHAR(3)') AS PricingUnitOfMeasure,
			ItemsData.item.value('@shippingUnitOfMeasure','NVARCHAR(3)') AS ShippingUnitOfMeasure
		INTO #Items
		FROM  
			@ItemsDataXML.nodes('/itemsData/items/item') as ItemsData(item)
		INNER JOIN @ItemsInstallatiosDataXML.nodes('/items/item') as ItemsInstallationsData(itemInst)
			ON ItemsInstallationsData.itemInst.value('.','DECIMAL') = ItemsData.item.value('@shortNum','DECIMAL')
		OPTION ( OPTIMIZE FOR ( @ItemsDataXML = NULL ) )


		/*CHECK IF ITEM EXISTS*/
		SELECT 
			I.ShortNum AS ShortItemNumber,
			I.InstallationID,
			CASE WHEN A.ShortItemNumber IS NULL THEN 0 ELSE 1 END AS RecordExists
			INTO #TempItems
		FROM #Items I
			LEFT OUTER JOIN [dbo].SC_ItemMaster A
			ON A.InstallationID = I.InstallationID 
			AND A.ShortItemNumber = I.ShortNum
		
		/*Insert or Update Item Content */
		/* Update items */
		UPDATE it
		SET								
			it.DisplayItemNumber = I.DispNum,
			it.DefaultUnitOfMeasure = I.DefUnitMsr,
			it.PrimaryUnitOfMeasure = I.PrimaryUnitOfMeasure,
			it.PricingUnitOfMeasure = I.PricingUnitOfMeasure,
			it.ShippingUnitOfMeasure = I.ShippingUnitOfMeasure,
			it.Description1 = I.Description1,
			it.Description2 = I.Description2,
			it.Description3 = I.Description3,
			it.Content = I.Description1 + ' ' + I.Description2 + ' ' + I.Description3 + ' ' + I.Content,						
			it.BranchPlant = I.BranchPlant,
			it.UserID = @UserID,
			it.WorkStationID = @WorkStation,
			it.DateUpdated = @DateUpdated,
			it.TimeUpdated = @TimeUpdated,
			it.StockingType = I.StockingType,
			it.InventoryFlag = I.InventoryFlag,
			it.ScType = I.ScType,
			it.Template = I.Template
		FROM 
			[dbo].SC_ItemMaster it
		INNER JOIN #Items I
			ON it.InstallationID = I.InstallationID 
			AND it.ShortItemNumber = I.ShortNum
		INNER JOIN #TempItems B
			ON B.ShortItemNumber = I.ShortNum
			AND B.RecordExists = 1;
				
		/* Insert New Items */
		INSERT INTO [dbo].SC_ItemMaster
		(
			InstallationID, 
			ShortItemNumber, 
			DisplayItemNumber,
			Description1, 
			Description2, 
			Description3, 
			Content, 
			BranchPlant, 
			StockingType,
			InventoryFlag,
			ScType,
			Template, 
			DefaultUnitOfMeasure, 
			PrimaryUnitOfMeasure,
			PricingUnitOfMeasure, 
			ShippingUnitOfMeasure, 
			UserID, 
			WorkStationID, 
			DateUpdated, 
			TimeUpdated
		)
		SELECT 	
			B.InstallationID, 
			I.ShortNum, 
			I.DispNum,
			I.Description1,
			I.Description2,
			I.Description3,
			I.Description1+ ' ' + 
			I.Description2 + ' ' + 
			I.Description3 + ' ' +
			I.Content ,		
			I.BranchPlant,
			I.StockingType,
			I.InventoryFlag,
			I.ScType,
			I.Template,
			I.DefUnitMsr,
			I.PrimaryUnitOfMeasure,					
			I.PricingUnitOfMeasure,
			I.ShippingUnitOfMeasure,
			@UserID, 
			@WorkStation, 
			@DateUpdated, 
			@TimeUpdated
		FROM  #Items I
			INNER JOIN #TempItems B
			ON B.ShortItemNumber = I.ShortNum
			AND B.InstallationID = I.InstallationID
		WHERE B.RecordExists = 0;

		DELETE IL
		FROM [dbo].SC_ItemMasterLangs IL
		INNER JOIN #TempItems B
			ON B.ShortItemNumber = IL.ShortItemNumber
		WHERE IL.InstallationID = B.InstallationID;
		
		--Items Langs Insert		
		INSERT INTO [dbo].SC_ItemMasterLangs(InstallationID,ShortItemNumber,LanguageID,Description1,Description2,Description3,Content)
		SELECT	
				ItemsInstallationsData.itemInst.value('@installationID','NVARCHAR(3)'),
				ItemsLangs.lang.value('@itemNumber','DECIMAL'),
				ItemsLangs.lang.value('@langId','NVARCHAR(2)'),
				ItemsLangs.lang.value('description1[1]','NVARCHAR(30)'),
				ItemsLangs.lang.value('description2[1]','NVARCHAR(30)'),
				ItemsLangs.lang.value('description3[1]','NVARCHAR(30)'),
				ItemsLangs.lang.value('description1[1]','NVARCHAR(30)')+ ' ' + 
				ItemsLangs.lang.value('description2[1]','NVARCHAR(30)')+ ' ' + 
				ItemsLangs.lang.value('description3[1]','NVARCHAR(30)')+ ' ' + 		
				ItemsLangs.lang.value('content[1]','NVARCHAR(MAX)')										
		FROM @ItemsDataXML.nodes('/itemsData/itemsLangs/lang') as ItemsLangs(lang)
		INNER JOIN @ItemsInstallatiosDataXML.nodes('/items/item') as ItemsInstallationsData(itemInst)
			ON ItemsInstallationsData.itemInst.value('.','DECIMAL') = ItemsLangs.lang.value('@itemNumber','DECIMAL')
				
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (@ErrorMessage, -- Message text.
					@ErrorSeverity, -- Severity.
					@ErrorState -- State.
					);
	END CATCH				
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_ExcUpdCatalogServerFileStatus'))
	BEGIN
		DROP  Procedure  [dbo].INV_ExcUpdCatalogServerFileStatus
	END

GO

-- #desc					Update By CatalogId
-- #bl_class				Premier.Inventory.CatalogMediaFile.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @InstallationID   Installation ID
-- #param @CatalogId		Catalog Id
-- #param @MediaFileStatus	Media File Status


CREATE Procedure [dbo].INV_ExcUpdCatalogServerFileStatus
(
	@InstallationID			NVARCHAR(3),
	@CatalogId				NVARCHAR(3),
	@MediaFileStatus	    NVARCHAR(3)
)
AS
	UPDATE 
	    CATALOGSERVERMEDIAFILE
	SET
	    MediaFileStatus = @MediaFileStatus
	FROM
	    CATALOGSERVERMEDIAFILE serverT
		INNER JOIN CATALOGMEDIAFILE master
			ON master.MediaFileUniqueID = serverT.MediaFileUniqueID
			AND ReSizeConstantPolicy = 'IMGNODESIZ'
	WHERE
	    (serverT.InstallationID      = @InstallationID) --Required
	    AND (@CatalogId IS NULL OR master.MediaFileName LIKE RTRIM(LTRIM(@CatalogId))+ '-' + '%') -- (catalogId + '-') to identify the images catalog
GO
   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogItemMediaFileInfo'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetCatalogItemMediaFileInfo
	END

GO

-- #desc						Get Catalog Media File - Used to get an item principal image
-- #bl_class					Premier.Inventory.CatalogItemMediaFileInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Item Number
-- #param @ServerName	        Server Name

/* Note: This stored procedure performance has already been reviewed. 
   It is less expensive for the database to execute the two selects (IF and Select), 
   than having a single select using an order by installationID. */

CREATE Procedure [dbo].INV_GetCatalogItemMediaFileInfo
(
	@InstallationId		    NVARCHAR(3),
	@ItemNumber             DECIMAL,
	@ServerName				NVARCHAR(128)
)
AS
		
IF((SELECT COUNT(*) FROM 
		CATALOGITEMMEDIAFILE AS Item
		INNER JOIN CATALOGMEDIAFILE AS MediaFile
			ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
		INNER JOIN CATALOGSERVERMEDIAFILE ServerT
			ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
			AND ServerT.InstallationID =  Item.InstallationID
			AND ServerT.ServerName = @ServerName
			AND ServerT.MediaFileStatus <> 'DEL'
	WHERE Item.InstallationID = @InstallationID
	AND  Item.ItemNumber = @ItemNumber) > 0)
	BEGIN
		SELECT TOP 1
			Item.InstallationID AS InstallationId,
			Item.ItemNumber,
			Item.MediaFileUniqueID,
			Item.PriorityIndex,
			MediaFile.MediaFileName,
			MediaFile.MediaFileComments,
			MediaFile.MediaFileType
		FROM 
			CATALOGITEMMEDIAFILE AS Item
			INNER JOIN CATALOGMEDIAFILE AS MediaFile
				ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
			INNER JOIN CATALOGSERVERMEDIAFILE ServerT
				ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
				AND ServerT.InstallationID =  Item.InstallationID
				AND ServerT.ServerName = @ServerName
				AND ServerT.MediaFileStatus <> 'DEL'
		WHERE Item.InstallationID = @InstallationID
		AND Item.ItemNumber = @ItemNumber
		ORDER BY Item.PriorityIndex ASC
	END
ELSE
	BEGIN
		SELECT TOP 1
			Item.InstallationID AS InstallationId,
			Item.ItemNumber,
			Item.MediaFileUniqueID,
			Item.PriorityIndex,
			MediaFile.MediaFileName,
			MediaFile.MediaFileComments,
			MediaFile.MediaFileType
		FROM 
			CATALOGITEMMEDIAFILE AS Item
			INNER JOIN CATALOGMEDIAFILE AS MediaFile
				ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
			INNER JOIN CATALOGSERVERMEDIAFILE ServerT
				ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
				AND ServerT.InstallationID = Item.InstallationID
				AND ServerT.ServerName = @ServerName
				AND ServerT.MediaFileStatus <> 'DEL'
		WHERE Item.InstallationID = '***'
		AND Item.ItemNumber = @ItemNumber
		ORDER BY Item.PriorityIndex ASC
	END		
GO


   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogItemMediaFileList'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetCatalogItemMediaFileList
	END

GO

-- #desc						Get Catalog Media File List - Used to load item gallery
-- #bl_class					Premier.Inventory.CatalogItemMediaFileList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Item Number
-- #param @ServerName	        Server Name

CREATE Procedure [dbo].INV_GetCatalogItemMediaFileList
(
	@InstallationId		    NVARCHAR(3),
	@ItemNumber             DECIMAL,
	@ServerName				NVARCHAR(128)
)
AS

IF (SELECT COUNT(*) FROM 
		CATALOGITEMMEDIAFILE AS Item
		INNER JOIN CATALOGMEDIAFILE AS MediaFile
			ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
		INNER JOIN CATALOGSERVERMEDIAFILE ServerT
			ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
			AND ServerT.InstallationID =  Item.InstallationID
			AND ServerT.ServerName = @ServerName
			AND ServerT.MediaFileStatus <> 'DEL'
	WHERE Item.InstallationID = @InstallationID
	AND Item.ItemNumber = @ItemNumber) > 0
	BEGIN
		SELECT 
			Item.InstallationID AS InstallationId,
			Item.ItemNumber,
			Item.MediaFileUniqueID,
			Item.PriorityIndex,
			MediaFile.MediaFileName,
			MediaFile.MediaFileComments,
			MediaFile.MediaFileType
		FROM 
			CATALOGITEMMEDIAFILE AS Item
			INNER JOIN CATALOGMEDIAFILE AS MediaFile
				ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
			INNER JOIN CATALOGSERVERMEDIAFILE ServerT
				ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
				AND ServerT.InstallationID =  Item.InstallationID
				AND ServerT.ServerName = @ServerName
				AND ServerT.MediaFileStatus <>'DEL'
		WHERE Item.InstallationID = @InstallationID
		AND Item.ItemNumber = @ItemNumber
		ORDER BY Item.PriorityIndex
	END
ELSE
	BEGIN
		SELECT 
			Item.InstallationID AS InstallationId,
			Item.ItemNumber,
			Item.MediaFileUniqueID,
			Item.PriorityIndex,
			MediaFile.MediaFileName,
			MediaFile.MediaFileComments,
			MediaFile.MediaFileType
		FROM 
			CATALOGITEMMEDIAFILE AS Item
			INNER JOIN CATALOGMEDIAFILE AS MediaFile
				ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
			INNER JOIN CATALOGSERVERMEDIAFILE ServerT
				ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
				AND ServerT.InstallationID = Item.InstallationID
				AND ServerT.ServerName = @ServerName
				AND ServerT.MediaFileStatus <> 'DEL'
		WHERE Item.InstallationID = '***'
		AND Item.ItemNumber = @ItemNumber
		ORDER BY Item.PriorityIndex
	END
	
		
	


GO
   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogItemMediaFiles'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetCatalogItemMediaFiles
	END

GO

-- #desc								Get Catalog Media File
-- #bl_class							Premier.Inventory.CatalogItemMediaFiles.cs
-- #db_dependencies						N/A
-- #db_references						N/A

-- #param @InstallationID				InstallationID
-- #param @ItemNumber					Item Number
-- #param @MediaFileUniqueID			Media File UniqueID
-- #param @RetrieveThumbnailContent		Return Thumbnail Content when is available.

CREATE Procedure [dbo].INV_GetCatalogItemMediaFiles
(
	@InstallationID		    NVARCHAR(3),
	@ItemNumber             DECIMAL,
    @MediaFileUniqueID      DECIMAL,
	@RetrieveThumbnailContent  INT
)
AS
	SELECT DISTINCT
	    Item.InstallationID,
	    Item.ItemNumber,
	    Item.MediaFileUniqueID,  
	    Item.PriorityIndex,
		Item.DefaultImage,
	    MediaFile.MediaFileName,
	    MediaFile.MediaFileComments,
	    MediaFile.MediaFileType,
	    CASE @RetrieveThumbnailContent 
			WHEN 1 THEN ISNULL(MediaFile.MediaFileThumbnail, MediaFile.MediaFileBody)
			ELSE MediaFile.MediaFileBody END AS MediaFileBody,
	    MediaFile.UserInsert, 
	    MediaFile.UserUpdate
	FROM 
		CATALOGITEMMEDIAFILE AS Item
		INNER JOIN CATALOGMEDIAFILE AS MediaFile
		ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
	WHERE
		    (Item.InstallationID      = @InstallationID)
		AND (@ItemNumber IS NULL OR Item.ItemNumber          = @ItemNumber)
		AND (@MediaFileUniqueID IS NULL OR Item.MediaFileUniqueID   = @MediaFileUniqueID)    
	ORDER BY Item.InstallationID, Item.PriorityIndex ASC
GO
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetCatalogMediaFile
	END

GO

-- #desc							Get Catalog Media File
-- #bl_class						Premier.Inventory.CatalogMediaFile.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @InstallationID			InstallationID
-- #param @MediaFileUniqueID	    Media File UniqueID

CREATE Procedure [dbo].INV_GetCatalogMediaFile
(
	@MediaFileUniqueID      DECIMAL
)
AS

	SELECT 
	    MediaFileUniqueID,
	    MediaFileName,
	    MediaFileType,
	    MediaFileComments,
	    MediaFileBody,
	    ReSizeConstantPolicy,
	    DateInsert,
	    TimeInsert,
	    UserInsert,
	    UserUpdate
	FROM 
		CATALOGMEDIAFILE
	WHERE
		MediaFileUniqueID = @MediaFileUniqueID

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMBreadCrumbFnc'))
BEGIN
	DROP FUNCTION [dbo].INV_GetCatalogNSMBreadCrumbFnc
END

GO

-- #desc						Get specific Node Description path
-- #bl_class					N/A
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @JobGenerationKey		Job Generation Key
-- #param @InstallationID		Installation ID
-- #param @CatalogID			Catalog Id
-- #param @NodeID				Node Id


CREATE FUNCTION [dbo].INV_GetCatalogNSMBreadCrumbFnc
(
	@JobGenerationKey	DECIMAL,
	@InstallationID		VARCHAR(3),
	@CatalogID		    VARCHAR(3),
	@NodeID				DECIMAL
)
RETURNS VARCHAR(512)
AS
BEGIN

	DECLARE @Url VARCHAR(512)
	DECLARE @UrlAux VARCHAR(512)
	SET @Url  = ''

	SELECT @Url += RTRIM(Parent.Description) + '@@@'
	FROM SC_Catalog_NSM_Temp AS Node
	INNER JOIN SC_Catalog_NSM_Temp AS Parent
		ON Node.JobGenerationKey = Parent.JobGenerationKey
		AND Node.InstallationID = Parent.InstallationID 
		AND Node.CatalogID = Parent.CatalogId
	WHERE 
		Node.JobGenerationKey = @JobGenerationKey	
		AND Node.InstallationID = @InstallationID 
		AND Node.CatalogID = @CatalogID 
		AND Node.NodeID = @NodeID
		AND (Node.LeftPosition BETWEEN Parent.LeftPosition AND Parent.RightPosition)
	ORDER BY Parent.LeftPosition;

	SET @UrlAux = [dbo].CMM_RemoveSpecialCharsFnc(@Url, '-'); 

	SET @UrlAux = REPLACE(@UrlAux,'@@@', '/');
	
	--Remove ending concatenation char '/'
	IF(LEN(@UrlAux) > 1)
		SET @UrlAux =  LEFT(@UrlAux, LEN(@UrlAux)-1);
		
	RETURN @UrlAux;

END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMBreadCrumbList'))
BEGIN
	DROP PROCEDURE [dbo].INV_GetCatalogNSMBreadCrumbList
END

GO

-- #desc						Get specific Node Bread Crumb
-- #bl_class					Premier.Inventory.CatalogNSMBreadCrumbList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @StoreId				Store Id
-- #param @URLPath				URL Path
-- #param @CatalogID			Catalog Id
-- #param @NodeID				Node Id
-- #param @ReferenceID			Support to get by old CatalogDetailID number,
-- #param @AllowedCatalogs		Allowed Catalog List
-- #param @LangPref				Language Preference

CREATE Procedure [dbo].INV_GetCatalogNSMBreadCrumbList
(
	@StoreId		NVARCHAR(3),
	@URLPath			NVARCHAR(512),
	@CatalogID		    NVARCHAR(3),
	@NodeID				DECIMAL,
	@ReferenceID		NVARCHAR(10),
	@LangPref			NVARCHAR(2)
)
AS
BEGIN
	/* Dynamic */
	DECLARE @SQL_CATALOG_DYNAMIC NVARCHAR(MAX);
	DECLARE @WHERE_DYNAMIC NVARCHAR(MAX) = N'';

	DECLARE @ASCIIValue DECIMAL
	SET @ASCIIValue = 0
	/* Validate if catalog is active */
	DECLARE @CurrentJulianDate DECIMAL;
	SET @CurrentJulianDate = [dbo].CMM_GetCurrentJulianDate (GETDATE());

	IF (@ReferenceID <> '*') BEGIN
		SELECT TOP 1 @NodeID = NodeID FROM SC_Catalog_NSM AS C WHERE CatalogID = @CatalogID AND ReferenceID = @ReferenceID AND InstallationID = @StoreId
	END
	ELSE IF(@URLPath <> '*') BEGIN
		SET @ASCIIValue = [dbo].CMM_GetASCIIValueSumFnc(@URLPath);

		SET @SQL_CATALOG_DYNAMIC = N'
		SELECT TOP 1
			@CatalogID = CatalogID,
			@NodeID = NodeID
		FROM [dbo].SC_Catalog_NSM A
		WHERE
			'+ @WHERE_DYNAMIC +N'
				InstallationID = @StoreId
			AND ( (@ASCIIValue > 0 AND PathCode = @ASCIIValue AND URLPath = @URLPath 
					AND (A.ApplyEffectiveDates = 0 OR (@CurrentJulianDate BETWEEN A.EffectiveFrom AND A.EffectiveThru)))
				OR  ( @ASCIIValue = 0 AND CatalogID = @CatalogID
					AND @NodeID IS NOT NULL AND NodeID = @NodeID ) )';

		EXECUTE sp_executesql @SQL_CATALOG_DYNAMIC,	N'@CatalogID NVARCHAR(3) OUTPUT, @NodeID DECIMAL OUTPUT, @StoreId NVARCHAR(3), 
													@ASCIIValue DECIMAL, @URLPath NVARCHAR(512), @CurrentJulianDate DECIMAL ',
													@CatalogID = @CatalogID OUT, @NodeID = @NodeID OUT, @StoreId = @StoreId, 
													@ASCIIValue = @ASCIIValue, @URLPath = @URLPath, @CurrentJulianDate = @CurrentJulianDate;
	END	

	IF(@LangPref = '')
	BEGIN
		SELECT 
			Parent.NodeID	AS NodeID,
			Parent.Description	AS Description,
			Parent.URLPath
		FROM SC_Catalog_NSM AS Node
		INNER JOIN SC_Catalog_NSM AS Parent
			ON Node.InstallationID = Parent.InstallationID 
			AND Node.CatalogID = Parent.CatalogId
		WHERE 
			Node.InstallationID = @StoreId 
			AND Node.CatalogID = @CatalogID
			AND (@NodeID IS NOT NULL AND Node.NodeID = @NodeID) 
			AND (Node.LeftPosition BETWEEN Parent.LeftPosition AND Parent.RightPosition)
		ORDER BY Parent.LeftPosition
	END
	ELSE
	BEGIN
		SELECT
			Parent.NodeID	AS NodeID,
			ISNULL(Lang.Description, Parent.Description)	AS Description,
			Parent.URLPath
		FROM SC_Catalog_NSM AS Node
		INNER JOIN SC_Catalog_NSM AS Parent
			ON Node.InstallationID = Parent.InstallationID 
			AND Node.CatalogID = Parent.CatalogId
		LEFT OUTER JOIN SC_CatalogLangs as Lang
			ON Parent.InstallationID = Lang.InstallationID
			AND Parent.CatalogID = Lang.CatalogID
			AND Parent.NodeID = Lang.NodeID
			AND Lang.LanguageID = @LangPref
		WHERE
			Node.InstallationID = @StoreId
			AND Node.CatalogID = @CatalogID
			AND (@NodeID IS NOT NULL AND Node.NodeID = @NodeID)
			AND (Node.LeftPosition BETWEEN Parent.LeftPosition AND Parent.RightPosition)
		ORDER BY Parent.LeftPosition
	END
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMItemLocation'))
BEGIN
	DROP  Procedure  [dbo].INV_GetCatalogNSMItemLocation
END

GO 

-- #desc						Gets nodes from item
-- #bl_class					Premier.Inventory.ItemCatalogLocationList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @ItemNumber			ItemNumber

CREATE Procedure [dbo].INV_GetCatalogNSMItemLocation
(
	@ItemNumber		DECIMAL
)	
AS
	DECLARE @SQL_DYNAMIC NVARCHAR(MAX);

	SET @SQL_DYNAMIC = N'
	SELECT 
		A.InstallationID	AS InstallationID, 
		A.CatalogID			AS CatalogID, 
		A.NodeID			AS NodeID,
		B.ReferenceID		AS ReferenceID
	FROM SC_CatalogNodeItems A
	INNER JOIN SC_Catalog_NSM B
		ON B.InstallationID = A.InstallationID
		AND B.CatalogID = A.CatalogID
		AND B.NodeID = A.NodeID
	WHERE A.ShortItemNumber = @ItemNumber
	ORDER BY A.InstallationID';

	EXECUTE sp_executesql @SQL_DYNAMIC,	N'@ItemNumber DECIMAL', @ItemNumber = @ItemNumber
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMItemSearchList'))
BEGIN
	DROP PROCEDURE [dbo].INV_GetCatalogNSMItemSearchList
END
GO

-- #desc						Search into Catalog NSM data. 
--								1. This Store Procedure looks for @SearchCriteria into SC_ItemMaster and SC_ItemMasterLangs
--								using the FullText Index
--								2. Then if @BranchPlant is provided, an inner join is applied against a new search over
--								SC_ItemMaster table but using BranchPlant FullText Index column to ensure customer branchplant restrictions.
--								3. If @CatalogRestriction and @NodeID(optional) are provided, performs an inner join against SC_CatalogNodeItems table
--								to ensure catalog restrinctions and optionally filter search result under specific node.
--								4. Apply paging to returns records to display
--								5. If @LangPref is provided, performs an join against SC_ItemMasterLangs table
--								to try to display item descriptions from user language preference.
-- #bl_class					Premier.Inventory.CatalogNSMItemSearchList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @StoreId		Installation ID
-- #param @URLPath				URL Path
-- #param @SearchCriteria		Search Criteria
-- #param @BranchPlant			Customer branch plant
-- #param @CatalogRestriction	Comma-separated CatalogId string
--								If user is searching by category (specific catalog or node) then @CatalogRestriction will be only one catalog 
--								and not the customer catalog restriction list 	
-- #param @AnyWord				Filter with "OR" or Filter with "AND". 0 = OR 1 = AND

-- #param @LangPref				Display Language Preference
-- #param @PageIndex			Initial page to display records
-- #param @PageSize				Quantity of records to display
-- #param @TotalRowCount		Total query result record count


CREATE PROCEDURE [dbo].INV_GetCatalogNSMItemSearchList
(
	@StoreId				NVARCHAR(3),
	@URLPath				NVARCHAR(512),
	@SearchCriteria			NVARCHAR(4000),
	@BranchPlant			NVARCHAR(25),
	@CatalogRestriction		NVARCHAR(4000),
	@NodeID					DECIMAL,
	@AnyWord                DECIMAL,
	@ServerName				NVARCHAR(128),
	@LangPref				NVARCHAR(2),
	@PageIndex				DECIMAL,
    @PageSize				DECIMAL,
    @TotalRowCount			INT OUTPUT
)
AS
		SET NOCOUNT ON
		
		/* Paging */
		DECLARE @ROWSTART INT
		DECLARE @ROWEND INT
	
		DECLARE @SQL NVARCHAR(MAX)
		DECLARE @SearchSQL NVARCHAR(MAX)
		DECLARE @SubSQL NVARCHAR(MAX)
		
		DECLARE	@LeftPosition DECIMAL
		DECLARE	@RightPosition DECIMAL
		
		DECLARE @CurrentJulianDate INT
		SET @CurrentJulianDate = [dbo].CMM_GetCurrentJulianDate(GETDATE())
		
		DECLARE @SearchText NVARCHAR(4000)
		SET @SearchText = [dbo].CMM_GetFullTextQueryTerms(@SearchCriteria, @AnyWord)
		
		
		DECLARE @ASCIIValue DECIMAL
		SET @ASCIIValue = 0

		/* Define the table to do the filtering and paging */
		CREATE TABLE #ItemsTBL
		(
			ShortItemNumber			DECIMAL,
			DisplayItemNumber		NVARCHAR(25),
			StockingType			NVARCHAR(2),
			Description1			NVARCHAR(30),
			Description2			NVARCHAR(30),
			Description3			NVARCHAR(30),
			MediaFileUniqueID		INT,
			MediaFileName			NVARCHAR(128),
			InstallationID			NVARCHAR(3),
			DefaultUnitOfMeasure	NVARCHAR(3),				
			[rank]					DECIMAL,
			ItemType				NVARCHAR(2),
			TemplateID				NVARCHAR(20)
		)

		IF (@URLPath <> '*') BEGIN
			SET @ASCIIValue = [dbo].CMM_GetASCIIValueSumFnc(@URLPath);
			SELECT TOP 1
				@CatalogRestriction = '''' + CatalogID +'''',
				@NodeID = NodeID
			FROM [dbo].SC_Catalog_NSM A
			WHERE
				InstallationID = @StoreId
				AND (@ASCIIValue > 0 AND PathCode = @ASCIIValue AND URLPath = @URLPath 
					AND (A.ApplyEffectiveDates = 0 OR (@CurrentJulianDate BETWEEN A.EffectiveFrom AND A.EffectiveThru)))
		END

		IF(@SearchText <> '')
			SET @SearchText = '''' + @SearchText + '''' /* Single quote concatenation for dynamic sql */
		ELSE
		BEGIN
			SET @TotalRowCount = 0
			return
		END
		
		SET  @SQL = 
		'INSERT INTO #ItemsTBL (ShortItemNumber, DisplayItemNumber, StockingType, Description1, Description2, Description3, MediaFileUniqueID, MediaFileName, InstallationID, DefaultUnitOfMeasure, [rank], ItemType, TemplateID)
		SELECT
			IM.ShortItemNumber		AS ShortItemNumber,
			IM.DisplayItemNumber	AS DisplayItemNumber,
			IM.StockingType			AS StockingType,'
		/*6. Get item information for specific language*/
		IF @LangPref <> ''
		BEGIN
			SET  @SQL = @SQL +
			' ISNULL(IMLangs.Description1, IM.Description1)	AS Description1,
			ISNULL(IMLangs.Description2, IM.Description2)	AS Description2,
			ISNULL(IMLangs.Description3, IM.Description3)	AS Description3,'
		END
		ELSE/*Get Item information*/
		BEGIN
			SET  @SQL = @SQL +
			' IM.Description1			AS Description1,
			IM.Description2			AS Description2,
			IM.Description3			AS Description3,'
		END
		
		/*Get item image*/
		IF @ServerName <> ''
		BEGIN
			SET  @SQL = @SQL +
			' ISNULL(ItemSpecificINID.MediaFileUniqueID, ItemBaseINID.MediaFileUniqueID) AS MediaFileUniqueID,
			ISNULL(ItemSpecificINID.MediaFileName, ItemBaseINID.MediaFileName) AS MediaFileName,
			ISNULL(ItemSpecificINID.InstallationID, ItemBaseINID.InstallationID) AS InstallationID,'
		END
		ELSE 
		BEGIN
			SET  @SQL += ' 0 AS MediaFileUniqueID,
			'''' AS MediaFileName,
			'''' AS InstallationID,'
		END
		
		SET  @SQL = @SQL +
			' IM.DefaultUnitOfMeasure AS DefaultUnitOfMeasure,
			FinalResult.[rank]		AS [rank],
			IM.SCType				AS ItemType,
			IM.Template				AS TemplateID
		FROM
		('
			/*FullText index search and branchplant validation*/
			SET @SearchSQL = 
			' SELECT
				ShortItemNumber,
				MAX([rank]) [rank]
			FROM
			('				
				IF @BranchPlant <> '*'
				BEGIN
					/*FullText index search into SC_ItemMaster*/
				    /*FullText index search into SC_ItemMaster(BranchPlant) to validate customer restriction (In stock)*/
					SET @SearchSQL = @SearchSQL + 
					'SELECT
						A.ShortItemNumber,
						B.[rank]
						FROM SC_ItemMaster A
						INNER JOIN CONTAINSTABLE(SC_ItemMaster, (Content),  @SearchText) AS B
							ON B.[key] = A.UniqueID
						INNER JOIN CONTAINSTABLE(SC_ItemMaster, (BranchPlant),  @BranchPlant ) AS BranchSearch
							ON BranchSearch.[key] = A.UniqueID
						WHERE							
							A.InstallationID =  @StoreId 
							AND	A.StockingType <> ''N''
							AND A.InventoryFlag IN (''Y'',''D'') 						
						UNION '
				END

				/*FullText index search into SC_ItemMaster*/
				SET @SearchSQL = @SearchSQL + '					
						SELECT
						A.ShortItemNumber,
						B.[rank]
						FROM SC_ItemMaster A
						INNER JOIN CONTAINSTABLE(SC_ItemMaster, (Content),  @SearchText ) AS B
							ON B.[key] = A.UniqueID
						WHERE A.InstallationID =  @StoreId'

				IF @BranchPlant <> '*'
				BEGIN
					/* FullText index search into SC_ItemMaster(BranchPlant) to validate customer restriction (NON stock)*/		
					SET @SearchSQL = @SearchSQL + ' AND (A.StockingType = ''N'' OR A.InventoryFlag NOT IN  (''Y'',''D''))'
				END
								
				IF @BranchPlant <> '*'
				BEGIN
					/* FullText index search into SC_ItemMasterLangs*/
					/* FullText index search into SC_ItemMaster(BranchPlant) to validate customer restriction (in stock)*/	
					SET @SearchSQL = @SearchSQL + 
					' UNION
					SELECT
						D.ShortItemNumber,
						C.[rank]
					FROM CONTAINSTABLE(SC_ItemMasterLangs, *,  @SearchText) AS C
					INNER JOIN SC_ItemMasterLangs D
						ON C.[key] = D.UniqueID
						AND D.InstallationID =  @StoreId
					INNER JOIN SC_ItemMaster E
						ON D.ShortItemNumber = E.ShortItemNumber
						AND D.InstallationID =  E.InstallationID
						AND	E.StockingType <> ''N''
						AND E.InventoryFlag IN (''Y'',''D'')
					INNER JOIN CONTAINSTABLE(SC_ItemMaster, (BranchPlant),  @BranchPlant) AS BranchSearch
						ON BranchSearch.[key] = E.UniqueID
						AND E.InstallationID =  @StoreId'				
				END

				/* FullText index search into SC_ItemMasterLangs*/
				SET @SearchSQL = @SearchSQL + 
				' UNION
				SELECT
					D.ShortItemNumber,
					C.[rank]
				FROM CONTAINSTABLE(SC_ItemMasterLangs, *,  @SearchText) AS C
				INNER JOIN SC_ItemMasterLangs D
					ON C.[key] = D.UniqueID
					AND D.InstallationID =  @StoreId
				INNER JOIN SC_ItemMaster E
					ON D.ShortItemNumber = E.ShortItemNumber
					AND D.InstallationID =  E.InstallationID'
				
				IF @BranchPlant <> '*'
				BEGIN
					/* FullText index search into SC_ItemMaster(BranchPlant) to validate customer restriction (NON stock)*/	
					SET @SearchSQL = @SearchSQL + '	AND (E.StockingType = ''N'' OR E.InventoryFlag NOT IN (''Y'',''D''))'
				END

				
				SET @SearchSQL = @SearchSQL + 
			') F
			GROUP BY ShortItemNumber'
			
			/*Items filter*/	
			SET @SearchSQL = 
				'SELECT DISTINCT
					CTResult.ShortItemNumber,
					[rank]
				FROM
				(' + @SearchSQL + ' ) CTResult 
				INNER JOIN SC_CatalogNodeItems AS CNI 
					ON CNI.InstallationID = @StoreId 					
					AND CTResult.ShortItemNumber = CNI.ShortItemNumber'			
			
			/*4. Catalog Assigment Restrictions: to filter by customer catalog restrictions or search items in an specific catalog/node*/
			IF @CatalogRestriction <> '*'
			BEGIN
				SET @SearchSQL = @SearchSQL +
				' AND CNI.CatalogID IN (' + @CatalogRestriction + ')'
			END	
			
			/*Effective date filter*/	
			SET @SearchSQL = @SearchSQL +
			' INNER JOIN SC_Catalog_NSM AS CAT
				  ON CNI.CatalogID = CAT.CatalogID
			      AND CNI.InstallationID = CAT.InstallationID
			      AND CNI.NodeID = CAT.NodeID
			      AND (CAT.ApplyEffectiveDates = 0 OR (' + CAST(@CurrentJulianDate AS NVARCHAR(18)) + ' BETWEEN CAT.EffectiveFrom AND CAT.EffectiveThru))'
			
			/*4. Specific node search filter: filter for the specific node and all its children*/
			IF @NodeID IS NOT NULL
			BEGIN
				SET @CatalogRestriction = REPLACE(@CatalogRestriction,'''','')
												
				SELECT 
					@LeftPosition = LeftPosition,
					@RightPosition = RightPosition
				FROM SC_Catalog_NSM
				WHERE InstallationID = @StoreId 
					AND CatalogID = @CatalogRestriction  
					AND NodeID = @NodeID 
			 	
			 	IF CAST(@LeftPosition AS NVARCHAR(18)) <> '' AND CAST(@RightPosition AS NVARCHAR(18)) <> ''
			 	BEGIN			 	
			 		SET @SearchSQL = @SearchSQL +  
					' AND CAT.LeftPosition BETWEEN ' + CAST(@LeftPosition AS NVARCHAR(18)) + ' AND ' + CAST(@RightPosition AS NVARCHAR(18)) + ' 
					AND (CAT.RightPosition - CAT.LeftPosition) = 1'
				END
			END
			
			/*Count Total Rows before paging*/
			SET @SubSQL = 'SELECT @count = COUNT(*) FROM  (' + @SearchSQL + ' ) A'
			EXEC sp_executesql @SubSQL , N'@StoreId NVARCHAR(3), @BranchPlant NVARCHAR(25), @SearchText NVARCHAR(4000), @count int output',
			@StoreId = @StoreId, @BranchPlant = @BranchPlant, @SearchText = @SearchText, @count = @TotalRowCount OUTPUT
				
			/*5. Paging*/
			IF @PageIndex > 0 AND @PageSize > 0
			BEGIN
				/* Set the first row to be selected */
				SET @ROWSTART = (@PageSize * @PageIndex) - @PageSize + 1
				/* Set the last row to be selected */
				SET @ROWEND = @PageIndex * @PageSize
				
				SET  @SearchSQL = 
				' SELECT
					 * 
				FROM
				(
					SELECT 
						ROW_NUMBER() OVER (ORDER BY [rank] DESC) AS RowNumber,        
						*       
					FROM 
					(' + @SearchSQL + ' ) RNumber
				)PagingResult
				WHERE RowNumber BETWEEN ' + CAST(@ROWSTART AS NVARCHAR(18)) + ' AND ' + CAST(@ROWEND AS NVARCHAR(18))
			END
		
		/*Get Item information*/		
		SET @SQL = @SQL + @SearchSQL +
		' ) FinalResult
		INNER JOIN SC_ItemMaster AS IM 
			ON FinalResult.ShortItemNumber = IM.ShortItemNumber
			AND IM.InstallationID = @StoreId ';
		
		/*6. Get item information for specific language*/
		IF @LangPref <> ''
		BEGIN
			SET  @SQL = @SQL +
			' LEFT OUTER JOIN SC_ItemMasterLangs AS IMLangs
			ON IM.ShortItemNumber = IMLangs.ShortItemNumber
			AND IM.InstallationID = IMLangs.InstallationID
			AND IMLangs.LanguageID = @LangPref ';
		
		END
		
		/*Get item image*/
		IF @ServerName <> ''
		BEGIN
			SET  @SQL = @SQL +
			' OUTER APPLY
				( SELECT TOP 1
						Item.MediaFileUniqueID,
						Item.InstallationID,
						MediaFile.MediaFileName 			
					FROM CATALOGITEMMEDIAFILE AS Item
					INNER JOIN CATALOGMEDIAFILE AS MediaFile
						ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
					INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
						ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
						AND ServerT.InstallationID =  Item.InstallationID
						AND ServerT.ServerName =  @ServerName 
						AND ServerT.MediaFileStatus <> ''DEL''
					WHERE Item.InstallationID =  @StoreId  
						AND Item.ItemNumber = IM.ShortItemNumber
					ORDER BY Item.PriorityIndex ASC
				) AS ItemSpecificINID				
			OUTER APPLY
				( SELECT TOP 1
						Item.MediaFileUniqueID,
						Item.InstallationID,
						MediaFile.MediaFileName 			
					FROM CATALOGITEMMEDIAFILE AS Item
					INNER JOIN CATALOGMEDIAFILE AS MediaFile
						ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
					INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
						ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
						AND ServerT.InstallationID =  Item.InstallationID
						AND ServerT.ServerName =  @ServerName 
						AND ServerT.MediaFileStatus <> ''DEL''
					WHERE Item.InstallationID = ''***''
						AND Item.ItemNumber = IM.ShortItemNumber
					ORDER BY Item.PriorityIndex ASC
				) AS ItemBaseINID'
		END
		
		/*5. No Paging*/
		IF @PageIndex <= 0 OR @PageSize <= 0
		BEGIN
			SET  @SQL = @SQL +
			' ORDER BY FinalResult.[rank] DESC'
		END
	
		EXECUTE sp_executesql @SQL, N'@StoreId NVARCHAR(3), @BranchPlant NVARCHAR(25), @SearchText NVARCHAR(4000), @ServerName NVARCHAR(128), @LangPref NVARCHAR(2)',
		@StoreId = @StoreId, @BranchPlant = @BranchPlant, @SearchText = @SearchText, @ServerName = @ServerName, @LangPref = @LangPref;


		SELECT ShortItemNumber, DisplayItemNumber, StockingType, Description1, Description2, Description3, 
				MediaFileUniqueID, MediaFileName, InstallationID, DefaultUnitOfMeasure, [rank], ItemType, TemplateID, '' as RefProductNumber
		FROM #ItemsTBL

		DROP TABLE #ItemsTBL
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMList'))
BEGIN
	DROP  Procedure  [dbo].INV_GetCatalogNSMList
END

GO 

-- #desc							Gets Catalog List
-- #bl_class						Premier.Inventory.GetGeneratedCatalogsCommand.cs
-- #db_dependencies					N/A
-- #db_references					N/A
-- #param @InstallationId			InstallationId

CREATE Procedure [dbo].INV_GetCatalogNSMList
(
	@InstallationId				NVARCHAR(3)
)	
AS
	
	SELECT DISTINCT CatalogID
	FROM SC_Catalog_NSM
	WHERE InstallationID = @InstallationId 
	
	
	
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMNodeInfo'))
BEGIN
	DROP PROCEDURE [dbo].INV_GetCatalogNSMNodeInfo
END

GO

-- #desc						Get the Node Information.
-- #dll							Premier.Inventory.dll
-- #class						CatalogNSMNodeInfo.cs
-- #method						DataPortal_Fetch
-- #References					NA

-- #param @InstallationID		Installation ID
-- #param @URLPath				URL Path
-- #param @CatalogID			Catalog Id
-- #param @NodeID				Node Id
-- #param @ReferenceID			Support to get by old CatalogDetailID number,
-- #param @AllowedCatalogs		Allowed Catalog List
-- #param @RetrieveNestedItems	Retrieve Nested Nodes Items
-- #param @LangPref				Language Preference

CREATE Procedure [dbo].INV_GetCatalogNSMNodeInfo
(
	@InstallationID			NVARCHAR(3),
	@URLPath				NVARCHAR(512),
	@CatalogID				NVARCHAR(3),
	@NodeID					DECIMAL,
	@ReferenceID			NVARCHAR(10),
	@AllowedCatalogs		NVARCHAR(MAX),
	@RetrieveNestedItems	DECIMAL,
	@LangPref				NVARCHAR(2)
)
AS
BEGIN	
	DECLARE @SQL_DYNAMIC NVARCHAR(MAX);
	DECLARE @SQL_CATALOG_DYNAMIC NVARCHAR(MAX);
	DECLARE @WHERE_DYNAMIC NVARCHAR(MAX) = N'';
	DECLARE @ASCIIValue DECIMAL
	SET @ASCIIValue = 0
	/* Validate if catalog is active */
	DECLARE @CurrentJulianDate DECIMAL;
	SET @CurrentJulianDate = [dbo].CMM_GetCurrentJulianDate (GETDATE());

	IF (@ReferenceID <> '*') BEGIN
		SELECT TOP 1 
			@NodeID = NodeID 
		FROM SC_Catalog_NSM AS C WHERE ReferenceID = @ReferenceID AND InstallationID = @InstallationID AND CatalogID = @CatalogID
	END
	ELSE IF(@URLPath <> '*') BEGIN
		SET @ASCIIValue = [dbo].CMM_GetASCIIValueSumFnc(@URLPath);

		IF(@AllowedCatalogs <> '*') BEGIN
			SET @WHERE_DYNAMIC = N'A.CatalogID IN ('+ @AllowedCatalogs +') AND';
		END;

		SET @SQL_CATALOG_DYNAMIC = N'
		SELECT TOP 1
			@CatalogID = CatalogID,
			@NodeID = NodeID
		FROM [dbo].SC_Catalog_NSM A
		WHERE
			'+ @WHERE_DYNAMIC +N'
				InstallationID = @InstallationID
			AND ( (@ASCIIValue > 0 AND PathCode = @ASCIIValue AND URLPath = @URLPath 
					AND (A.ApplyEffectiveDates = 0 OR (@CurrentJulianDate BETWEEN A.EffectiveFrom AND A.EffectiveThru)))
				OR  ( @ASCIIValue = 0 AND CatalogID = @CatalogID
					AND @NodeID IS NOT NULL AND NodeID = @NodeID ) )';

		EXECUTE sp_executesql @SQL_CATALOG_DYNAMIC,	N'@CatalogID NVARCHAR(3) OUTPUT, @NodeID DECIMAL OUTPUT, @InstallationID NVARCHAR(3), 
													@ASCIIValue DECIMAL, @URLPath NVARCHAR(512), @CurrentJulianDate DECIMAL ',
													@CatalogID = @CatalogID OUT, @NodeID = @NodeID OUT, @InstallationID = @InstallationID, 
													@ASCIIValue = @ASCIIValue, @URLPath = @URLPath, @CurrentJulianDate = @CurrentJulianDate;

	END

	SET @SQL_DYNAMIC = N'
		SELECT
			Node.InstallationID,
			Node.CatalogID,
			(SELECT TOP 1 NodeID 
				 FROM SC_Catalog_NSM Parent
				 WHERE 
					Parent.InstallationID =  @InstallationID
					AND Parent.CatalogID = @CatalogID
					AND Parent.LeftPosition < Node.LeftPosition AND Parent.RightPosition > Node.RightPosition
				 ORDER BY Parent.RightPosition - Node.RightPosition 
			) AS ParentNodeID,
			Node.NodeID,
			Node.Description,
			CASE (Node.RightPosition - Node.LeftPosition)
				WHEN 1 THEN ''Y''
				ELSE ''N'' 
			END AS IsLeafNode,
			Node.MediaFileUniqueID,
			Node.ReferenceID,
			CASE
				WHEN (@RetrieveNestedItems = 1 OR (Node.RightPosition - Node.LeftPosition) = 1 ) AND (SELECT COUNT(*)
				 FROM SC_ItemAttributes A
				 INNER JOIN SC_CatalogNodeItems B
					ON B.InstallationID = Node.InstallationID
					AND B.CatalogID = Node.CatalogID
					AND (
					     ((Node.RightPosition - Node.LeftPosition) = 1  AND B.NodeID = Node.NodeID)
						 OR
						 B.NodeID IN (SELECT Nested.NodeID FROM SC_Catalog_NSM Nested 
									 WHERE Nested.InstallationID = @InstallationID AND Nested.CatalogID = @CatalogID 
									 AND Nested.LeftPosition > Node.LeftPosition AND Nested.RightPosition <  Node.RightPosition)
						)
					AND A.ShortItemNumber = B.ShortItemNumber
				 WHERE 
					A.Usage IN (''C'',''SC'')		
				) > 0 
				THEN ''Y''
				ELSE ''N'' 
			END AS HasComparableItems,
			Node.URLPath,
			MediaFile.MediaFileName,     
			MediaFile.MediaFileComments
		FROM SC_Catalog_NSM Node
		LEFT OUTER JOIN CATALOGMEDIAFILE AS MediaFile
				ON MediaFile.MediaFileUniqueID = Node.MediaFileUniqueID
		WHERE
			Node.InstallationID = @InstallationID
			AND Node.CatalogID = @CatalogID
			AND (@NodeID IS NOT NULL AND Node.NodeID = @NodeID) ';

	IF(@LangPref <> '')
	BEGIN
		SET @SQL_DYNAMIC = N'
		SELECT
			A.InstallationID,
			A.CatalogID,
			ParentNodeID,
			A.NodeID,
			ISNULL(B.Description, A.Description) AS Description,
			IsLeafNode,
			MediaFileUniqueID,
			ReferenceID,
			HasComparableItems,
			URLPath,
			MediaFileName,   
			MediaFileComments
		FROM
		('
			+ @SQL_DYNAMIC +
		N') A
		LEFT OUTER JOIN SC_CatalogLangs B
			ON A.InstallationID = B.InstallationID
			AND A.CatalogID = B.CatalogID
			AND A.NodeID = B.NodeID
			AND B.LanguageID = @LangPref ';
	END

	/* Execute SQL dynamic, insert into #NodeItemsTBL */
	EXECUTE sp_executesql @SQL_DYNAMIC,	N'@InstallationID NVARCHAR(3), @CatalogID NVARCHAR(3), @NodeID DECIMAL, @LangPref NVARCHAR(2) , @RetrieveNestedItems DECIMAL',
						@InstallationID = @InstallationID,@CatalogID = @CatalogID, @NodeID = @NodeID, @LangPref = @LangPref, @RetrieveNestedItems = @RetrieveNestedItems;

END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMNodeItemList'))
BEGIN
	DROP PROCEDURE [dbo].INV_GetCatalogNSMNodeItemList
END
GO

-- #desc						Get Items for an specific Catalog Node. 
--								1. Get Item Number by specific Node using @NodeID. Sort by Item Priority.
--								3. Then if @BranchPlant is provided, an inner join is applied against a new search over
--								SC_ItemMaster table but using BranchPlant FullText Index column to ensure customer branchplant restrictions.
--								4. Sort items by Description1 (No language provided), DisplayItemNumber.
--								5. If @LangPref is provided, performs an join against SC_ItemMasterLangs table
--								to try to display item descriptions from user language preference. 
--								Sort by Description1
--								Get Item Cross Reference Description for Customer
--								Apply paging to returns records to display
-- #bl_class					Premier.Inventory.CatalogNSMItemSearchList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID
-- #param @CatalogID			Catalog Id
-- #param @NodeID				Node Id
-- #param @BranchPlant			Customer branch plant
-- #param @SortBy				0 = Priority | 1 = Description1 | 2 = DisplayItemNumber
-- #param @LangPref				Display Language Preference
-- #param @RetrieveNestedItems	Retrieve Nested Nodes Items
-- #param @PageIndex			Initial page to display records
-- #param @PageSize				Quantity of records to display
-- #param @TotalRowCount		Total query result record count

CREATE PROCEDURE [dbo].INV_GetCatalogNSMNodeItemList
(
	@InstallationID			NVARCHAR(3),
	@CatalogID				NVARCHAR(3),
	@NodeID					DECIMAL,	
	@BranchPlant			NVARCHAR(25),
	@SortBy					DECIMAL,
	@LangPref				NVARCHAR(2),
	@ServerName				NVARCHAR(128),
	@RetrieveNestedItems	DECIMAL,
	@PageIndex				DECIMAL,
    @PageSize				DECIMAL,
    @TotalRowCount			INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @left INT = 0
	DECLARE @right INT = 0
	DECLARE @IsLeafNode VARCHAR(1) /* 1=Y otherwise=N */
	
	CREATE TABLE #NodeItemsTBL
	(
		ShortItemNumber DECIMAL,
		SortByPriority DECIMAL
	)

	/* Define the table to fill information with specific language - LangPref != '' */
	CREATE TABLE #ItemsDetailTBL
	(
		nID  					INT IDENTITY,
		ShortItemNumber			DECIMAL,
		DisplayItemNumber		NVARCHAR(25),
		Description1			NVARCHAR(30),
		Description2			NVARCHAR(30),
		Description3			NVARCHAR(30),
		DefaultUnitOfMeasure	NVARCHAR(3),
		StockingType			NVARCHAR(2),
		RefProductNumber		NVARCHAR(25),
		MediaFileUniqueID		DECIMAL,
		MediaFileName           NVARCHAR(128),
		InstallationID			NVARCHAR(3),
		ItemType				NVARCHAR(2),
		TemplateID				NVARCHAR(20)
	)

	/* Define the table to do the filtering and paging */
	DECLARE @ItemsTBL TABLE
	(
		nID  					INT IDENTITY,
		ShortItemNumber			DECIMAL,
		DisplayItemNumber		NVARCHAR(25),
		Description1			NVARCHAR(30),
		Description2			NVARCHAR(30),
		Description3			NVARCHAR(30),
		DefaultUnitOfMeasure	NVARCHAR(3),
		StockingType			NVARCHAR(2),
		InventoryFlag			NVARCHAR(1),
		ItemType				NVARCHAR(2),
		TemplateID				NVARCHAR(20),
		SortByPriority			DECIMAL
	)
	
	/* Paging */
	DECLARE @ROWSTART INT
	DECLARE @ROWEND INT
	
	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @Pos INT
	DECLARE @NextString NVARCHAR(MAX)	
	DECLARE @CurrentJulianDate INT
	DECLARE @SQL_DYNAMIC NVARCHAR(MAX);	
	DECLARE @FROM_DYNAMIC NVARCHAR(30);
	DECLARE @nodeIds NVARCHAR(MAX);

	SET @FROM_DYNAMIC = ' SC_CatalogNodeItems AS CNI ';
	
	IF (@RetrieveNestedItems = 1) BEGIN
		SELECT TOP 1
			@left = LeftPosition,
			@right = RightPosition,
			@IsLeafNode = CASE (RightPosition - LeftPosition) WHEN 1 THEN 'Y' ELSE 'N' END
		FROM SC_Catalog_NSM
		WHERE
			InstallationID = @InstallationID AND 
			CatalogID = @CatalogID AND 
			NodeID = @NodeID 		
	END

	IF (@RetrieveNestedItems = 1 AND @IsLeafNode = 'N') BEGIN		
		SET @nodeIds = N''
		SELECT @nodeIds = @nodeIds + convert (NVARCHAR(12), NodeID )  + ',' FROM SC_Catalog_NSM 
							WHERE InstallationID = @InstallationID AND 
							CatalogID = @CatalogID AND 
							LeftPosition > @left  AND RightPosition < @right AND (RightPosition - LeftPosition = 1)
		SET @nodeIds = substring(@nodeIds,1,len(@nodeIds)-1)

		SET @SQL_DYNAMIC = N'
		INSERT INTO #NodeItemsTBL (ShortItemNumber, SortByPriority)
		SELECT DISTINCT ITEMS.ShortItemNumber, MAX(Priority) Priority FROM 
			(SELECT DISTINCT  CNI.ShortItemNumber ShortItemNumber, Priority 
			FROM ' + @FROM_DYNAMIC 
			+ N' WHERE CNI.InstallationID = @InstallationID
				AND CNI.CatalogID = @CatalogID
				AND CNI.NodeID IN ( '+ @nodeIds + N' )) AS ITEMS GROUP BY ITEMS.ShortItemNumber'					
	END
	ELSE BEGIN
		SET @SQL_DYNAMIC = N'
		INSERT INTO #NodeItemsTBL (ShortItemNumber, SortByPriority)
		SELECT DISTINCT ITEMS.ShortItemNumber, MAX(Priority) Priority FROM 
		(SELECT CNI.ShortItemNumber ShortItemNumber, Priority FROM ' + @FROM_DYNAMIC 
		+ N' WHERE 
			CNI.InstallationID = @InstallationID
			AND CNI.CatalogID = @CatalogID
			AND CNI.NodeID = @NodeID) AS ITEMS GROUP BY ITEMS.ShortItemNumber'		
	END

	/* Execute SQL dynamic, insert into #NodeItemsTBL */
	EXECUTE sp_executesql @SQL_DYNAMIC,	N'@InstallationID NVARCHAR(3), @CatalogID NVARCHAR(3), @NodeID DECIMAL, @SortBy DECIMAL,
										@IsLeafNode VARCHAR(1), @right INT, @left INT',
						@InstallationID = @InstallationID,@CatalogID = @CatalogID, @NodeID = @NodeID, @SortBy = @SortBy, @IsLeafNode = @IsLeafNode,
						@right = @right, @left = @left

			
	IF @BranchPlant <> '*' BEGIN/*3. FullText index search into SC_ItemMaster(BranchPlant) to validate customer restriction*/
		/*4. Sorting by Priority, Description1 or DisplayItemNumber*/
			INSERT INTO @ItemsTBL (ShortItemNumber, DisplayItemNumber, Description1, Description2, Description3, DefaultUnitOfMeasure, StockingType, InventoryFlag, ItemType, TemplateID, SortByPriority)
			SELECT * FROM (SELECT
				IM.ShortItemNumber,
				IM.DisplayItemNumber DisplayItemNumber,
				IM.Description1 Description1,
				IM.Description2,
				IM.Description3,
				IM.DefaultUnitOfMeasure,
				IM.StockingType,
				IM.InventoryFlag,
				IM.SCType,
				IM.Template,
				NI.SortByPriority
			FROM #NodeItemsTBL NI
			INNER JOIN SC_ItemMaster IM
				ON NI.ShortItemNumber = IM.ShortItemNumber
				AND IM.InstallationID = @InstallationID
			INNER JOIN CONTAINSTABLE(SC_ItemMaster, (BranchPlant), @BranchPlant) AS BranchSearch
				ON BranchSearch.[key] = IM.UniqueID
			WHERE (IM.StockingType <> 'N' 
			AND (IM.InventoryFlag ='Y' OR IM.InventoryFlag= 'D'))
			UNION
			SELECT
				IM.ShortItemNumber,
				IM.DisplayItemNumber DisplayItemNumber,
				IM.Description1 Description1,
				IM.Description2,
				IM.Description3,
				IM.DefaultUnitOfMeasure,
				IM.StockingType,
				IM.InventoryFlag,
				IM.SCType,
				IM.Template,
				NI.SortByPriority
			FROM #NodeItemsTBL NI
			INNER JOIN SC_ItemMaster IM
				ON NI.ShortItemNumber = IM.ShortItemNumber
				AND IM.InstallationID = @InstallationID
			WHERE (IM.StockingType = 'N' 
			OR (IM.InventoryFlag <>'Y' AND IM.InventoryFlag <> 'D'))) AS ITEMS
			ORDER BY
				CASE WHEN @SortBy = 0 AND SortByPriority = 0 THEN 1 END,
				CASE WHEN @SortBy = 0 THEN SortByPriority END ASC,
				CASE WHEN @SortBy = 1 AND @LangPref = '' THEN Description1 END,
				CASE WHEN @SortBy = 2 THEN DisplayItemNumber END
	
	END
	ELSE BEGIN
		/*4. Sorting by  Priority, Description1 or DisplayItemNumber*/
			INSERT INTO @ItemsTBL (ShortItemNumber, DisplayItemNumber, Description1, Description2, Description3, DefaultUnitOfMeasure, StockingType, InventoryFlag, ItemType, TemplateID)
			SELECT
				IM.ShortItemNumber,
				IM.DisplayItemNumber,
				IM.Description1,
				IM.Description2,
				IM.Description3,
				IM.DefaultUnitOfMeasure,
				IM.StockingType,
				IM.InventoryFlag,
				IM.SCType,
				IM.Template
			FROM #NodeItemsTBL NI
			INNER JOIN SC_ItemMaster IM
				ON NI.ShortItemNumber = IM.ShortItemNumber
				AND IM.InstallationID = @InstallationID
			ORDER BY
				CASE WHEN @SortBy = 0 AND SortByPriority = 0 THEN 1 END,
				CASE WHEN @SortBy = 0 THEN SortByPriority END ASC,
				CASE WHEN @SortBy = 1 AND @LangPref = '' THEN IM.Description1 END,
				CASE WHEN @SortBy = 2 THEN IM.DisplayItemNumber END
	END
	
	/* Obtain the total count of the result */
	SELECT @TotalRowCount = COUNT(*)
	  FROM @ItemsTBL
	  	
	IF(@PageIndex = 0 OR @PageSize = 0)
	BEGIN
		SET @ROWSTART = 1		
		SET @ROWEND = @TotalRowCount
	END
	ELSE BEGIN		
		SET @ROWSTART = (@PageSize * @PageIndex) - @PageSize + 1		
		SET @ROWEND = @PageIndex * @PageSize	
	END

	/* Select the rows from temporary table betwen the range of @ROWSTART and @ROWEND */
	SET @CurrentJulianDate = [dbo].CMM_GetCurrentJulianDate (GETDATE())
	
	IF @LangPref = ''  BEGIN/*5. Paging*/
		SELECT 
				ShortItemNumber,
				DisplayItemNumber,
				Description1,
				Description2,
				Description3,
				DefaultUnitOfMeasure,
				IM.StockingType,
				'' AS RefProductNumber,
				ISNULL(ItemSpecificINID.MediaFileUniqueID, ItemBaseINID.MediaFileUniqueID) AS MediaFileUniqueID,
				ISNULL(ItemSpecificINID.MediaFileName, ItemBaseINID.MediaFileName) AS MediaFileName,
				ISNULL(ItemSpecificINID.InstallationID, ItemBaseINID.InstallationID) AS InstallationID,
				ItemType,
				TemplateID
			FROM @ItemsTBL IM
			OUTER APPLY
				( SELECT TOP 1
						Item.MediaFileUniqueID,
						Item.InstallationID,
						MediaFile.MediaFileName 			
					FROM CATALOGITEMMEDIAFILE AS Item
					INNER JOIN CATALOGMEDIAFILE AS MediaFile
						ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
					INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
						ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
						AND ServerT.InstallationID =  Item.InstallationID
						AND ServerT.ServerName = @ServerName
						AND ServerT.MediaFileStatus <> 'DEL'
					WHERE Item.InstallationID = @InstallationID 
						AND Item.ItemNumber = IM.ShortItemNumber
					ORDER BY Item.PriorityIndex ASC
				) AS ItemSpecificINID				
			OUTER APPLY
				( SELECT TOP 1
						Item.MediaFileUniqueID,
						Item.InstallationID,
						MediaFile.MediaFileName 			
					FROM CATALOGITEMMEDIAFILE AS Item
					INNER JOIN CATALOGMEDIAFILE AS MediaFile
						ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
					INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
						ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
						AND ServerT.InstallationID =  Item.InstallationID
						AND ServerT.ServerName = @ServerName
						AND ServerT.MediaFileStatus <> 'DEL'
					WHERE Item.InstallationID = '***'
						AND Item.ItemNumber = IM.ShortItemNumber
					ORDER BY Item.PriorityIndex ASC
				) AS ItemBaseINID
			WHERE nID >=  @ROWSTART AND nID <= @ROWEND
	END
	ELSE BEGIN /*5. Get item information for specific language*/
		IF(@SortBy = 1)  BEGIN/*5. Paging*/
			INSERT INTO #ItemsDetailTBL (ShortItemNumber, DisplayItemNumber, Description1, Description2, Description3, DefaultUnitOfMeasure, StockingType, RefProductNumber, MediaFileUniqueID, MediaFileName, InstallationID, ItemType, TemplateID)
				SELECT 
					ShortItemNumber,
					DisplayItemNumber,
					Description1,
					Description2,
					Description3,
					DefaultUnitOfMeasure,
					StockingType,
					'' AS RefProductNumber,
					ISNULL(ItemSpecificINID.MediaFileUniqueID, ItemBaseINID.MediaFileUniqueID) AS MediaFileUniqueID,
					ISNULL(ItemSpecificINID.MediaFileName, ItemBaseINID.MediaFileName) AS MediaFileName,
					ISNULL(ItemSpecificINID.InstallationID, ItemBaseINID.InstallationID) AS InstallationID,
					ItemType,
					TemplateID
				FROM 
				(
					SELECT
						IM.ShortItemNumber,
						DisplayItemNumber,
						ISNULL(IMLangs.Description1, IM.Description1) Description1,
						ISNULL(IMLangs.Description2, IM.Description2) Description2,
						ISNULL(IMLangs.Description3, IM.Description3) Description3,
						DefaultUnitOfMeasure,
						IM.StockingType,
						ItemType,
						TemplateID,
						ROW_NUMBER() OVER (ORDER BY ISNULL(IMLangs.Description1, IM.Description1)) AS RowNumber
					FROM @ItemsTBL IM
					LEFT OUTER JOIN SC_ItemMasterLangs AS IMLangs
						ON IM.ShortItemNumber = IMLangs.ShortItemNumber
						AND IMLangs.InstallationID = @InstallationID
						AND IMLangs.LanguageID = @LangPref
				) Final
				OUTER APPLY
					( SELECT TOP 1
							Item.MediaFileUniqueID,
							Item.InstallationID,
							MediaFile.MediaFileName 			
						FROM CATALOGITEMMEDIAFILE AS Item
						INNER JOIN CATALOGMEDIAFILE AS MediaFile
							ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
						INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
							ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
							AND ServerT.InstallationID =  Item.InstallationID
							AND ServerT.ServerName = @ServerName
							AND ServerT.MediaFileStatus <> 'DEL'
						WHERE Item.InstallationID = @InstallationID 
							AND Item.ItemNumber = Final.ShortItemNumber
						ORDER BY Item.PriorityIndex ASC
					) AS ItemSpecificINID				
				OUTER APPLY
					( SELECT TOP 1
							Item.MediaFileUniqueID,
							Item.InstallationID,
							MediaFile.MediaFileName 			
						FROM CATALOGITEMMEDIAFILE AS Item
						INNER JOIN CATALOGMEDIAFILE AS MediaFile
							ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
						INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
							ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
							AND ServerT.InstallationID =  Item.InstallationID
							AND ServerT.ServerName = @ServerName
							AND ServerT.MediaFileStatus <> 'DEL'
						WHERE Item.InstallationID = '***'
							AND Item.ItemNumber = Final.ShortItemNumber
						ORDER BY Item.PriorityIndex ASC
					) AS ItemBaseINID
				WHERE RowNumber >=  @ROWSTART AND RowNumber <= @ROWEND
			SELECT * FROM #ItemsDetailTBL
		END
		ELSE BEGIN/*5. Paging*/
			SELECT 
					IM.ShortItemNumber,
					DisplayItemNumber,
					ISNULL(IMLangs.Description1, IM.Description1) Description1,
					ISNULL(IMLangs.Description2, IM.Description2) Description2,
					ISNULL(IMLangs.Description3, IM.Description3) Description3,
					DefaultUnitOfMeasure,
					IM.StockingType,
					'' AS RefProductNumber,
					ISNULL(ItemSpecificINID.MediaFileUniqueID, ItemBaseINID.MediaFileUniqueID) AS MediaFileUniqueID,
					ISNULL(ItemSpecificINID.MediaFileName, ItemBaseINID.MediaFileName) AS MediaFileName,
					ISNULL(ItemSpecificINID.InstallationID, ItemBaseINID.InstallationID) AS InstallationID,
					ItemType,
					TemplateID
				FROM @ItemsTBL IM
				LEFT OUTER JOIN SC_ItemMasterLangs AS IMLangs
					ON IM.ShortItemNumber = IMLangs.ShortItemNumber
					AND IMLangs.InstallationID = @InstallationID
					AND IMLangs.LanguageID = @LangPref
				OUTER APPLY
					( SELECT TOP 1
							Item.MediaFileUniqueID,
							Item.InstallationID,
							MediaFile.MediaFileName 			
						FROM CATALOGITEMMEDIAFILE AS Item
						INNER JOIN CATALOGMEDIAFILE AS MediaFile
							ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
						INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
							ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
							AND ServerT.InstallationID =  Item.InstallationID
							AND ServerT.ServerName = @ServerName
							AND ServerT.MediaFileStatus <> 'DEL'
						WHERE Item.InstallationID = @InstallationID 
							AND Item.ItemNumber = IM.ShortItemNumber
						ORDER BY Item.PriorityIndex ASC
					) AS ItemSpecificINID				
				OUTER APPLY
					( SELECT TOP 1
							Item.MediaFileUniqueID,
							Item.InstallationID,
							MediaFile.MediaFileName 			
						FROM CATALOGITEMMEDIAFILE AS Item
						INNER JOIN CATALOGMEDIAFILE AS MediaFile
							ON MediaFile.MediaFileUniqueID = Item.MediaFileUniqueID
						INNER JOIN CATALOGSERVERMEDIAFILE AS ServerT
							ON ServerT.MediaFileUniqueID = MediaFile.MediaFileUniqueID
							AND ServerT.InstallationID =  Item.InstallationID
							AND ServerT.ServerName = @ServerName
							AND ServerT.MediaFileStatus <> 'DEL'
						WHERE Item.InstallationID = '***'
							AND Item.ItemNumber = IM.ShortItemNumber
						ORDER BY Item.PriorityIndex ASC
					) AS ItemBaseINID
				WHERE nID >=  @ROWSTART AND nID <= @ROWEND
		END
	END
	DROP TABLE #NodeItemsTBL
	DROP TABLE #ItemsDetailTBL
END	
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogNSMNodeList'))
BEGIN
	DROP PROCEDURE [dbo].INV_GetCatalogNSMNodeList
END

GO

-- #desc						Get the @NodeID information in the first result set.
--								Get the children node list of @NodeID or @ReferenceID in the second result set.
--								Get as many @NodeID or @ReferenceID children subleves as @NestedLevel indicates.
-- #bl_class					Premier.Inventory.CatalogNSMNodeList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @StoreId				Store Id
-- #param @URLPath				URL Path
-- #param @CatalogID			Catalog Id
-- #param @NodeID				Node Id
-- #param @ReferenceID			Support to get by old CatalogDetailID number,
-- #param @NestedLevel			Subleves to be retrieved. 0 = All sublevels,
-- #param @LangPref				Language Preference

CREATE Procedure [dbo].INV_GetCatalogNSMNodeList
(
	@StoreId		NVARCHAR(3),
	@URLPath			NVARCHAR(512),
	@CatalogID		    NVARCHAR(3),
	@NodeID				DECIMAL,
	@ReferenceID		NVARCHAR(10),
	@NestedLevel		DECIMAL,
	@LangPref			NVARCHAR(2)
)
AS
BEGIN	
	DECLARE @left INT
	DECLARE @right INT
	DECLARE @MainNodeID DECIMAL
	DECLARE @Description NVARCHAR(30)
	DECLARE @IsLeafNode NVARCHAR(1) /* 1=Y otherwise=N */
	DECLARE @ASCIIValue DECIMAL
	DECLARE @SQL_CATALOG_DYNAMIC NVARCHAR(MAX);
	DECLARE @WHERE_DYNAMIC NVARCHAR(MAX) = N'';
		
	/* Define the table to gets announcements */
	DECLARE @NodesTBL TABLE
	(
		ParentNodeID		DECIMAL,
		NodeID				DECIMAL,
		Description			NVARCHAR(30),
		IsLeafNode			NVARCHAR(1),
		MediaFileUniqueID	INT,
		ReferenceID			NVARCHAR(10),
		URLPath				VARCHAR(MAX),
		MediaFileName		NVARCHAR(256),
		MediaFileComments	NVARCHAR(512),
		NodePosition		INT
	)

	DECLARE @CurrentJulianDate INT
	SET @CurrentJulianDate = [dbo].CMM_GetCurrentJulianDate (GETDATE())
	SET @ASCIIValue = 0

	IF (@ReferenceID <> '*') BEGIN
		SELECT TOP 1 
			@NodeID = NodeID 
		FROM SC_Catalog_NSM AS C WHERE ReferenceID = @ReferenceID AND InstallationID = @StoreId AND CatalogID = @CatalogID
	END
	ELSE IF (@URLPath <> '*') BEGIN
		SET @ASCIIValue = [dbo].CMM_GetASCIIValueSumFnc(@URLPath);
		
		SET @SQL_CATALOG_DYNAMIC = N'
		SELECT TOP 1
			@CatalogID = CatalogID,
			@NodeID = NodeID
		FROM [dbo].SC_Catalog_NSM A
		WHERE
			'+ @WHERE_DYNAMIC +N'
				InstallationID = @StoreId
			AND ( (@ASCIIValue > 0 AND PathCode = @ASCIIValue AND URLPath = @URLPath 
					AND (A.ApplyEffectiveDates = 0 OR (@CurrentJulianDate BETWEEN A.EffectiveFrom AND A.EffectiveThru)))
				OR  ( @ASCIIValue = 0 AND CatalogID = @CatalogID
					AND @NodeID IS NOT NULL AND NodeID = @NodeID ) )';

		EXECUTE sp_executesql @SQL_CATALOG_DYNAMIC,	N'@CatalogID NVARCHAR(3) OUTPUT, @NodeID DECIMAL OUTPUT, @StoreId NVARCHAR(3), 
													@ASCIIValue DECIMAL, @URLPath NVARCHAR(512), @CurrentJulianDate DECIMAL ',
													@CatalogID = @CatalogID OUT, @NodeID = @NodeID OUT, @StoreId = @StoreId, 
													@ASCIIValue = @ASCIIValue, @URLPath = @URLPath, @CurrentJulianDate = @CurrentJulianDate;
	END

	
	SELECT TOP 1
		@left = LeftPosition,
		@right = RightPosition,
		@MainNodeID = NodeID,
		@Description = Description,
		@IsLeafNode = CASE (RightPosition - LeftPosition)
							WHEN 1 THEN 'Y'
							ELSE 'N' END,
		@CatalogID = CatalogID,
		@NodeID = NodeID, 
		@URLPath = URLPath
	FROM SC_Catalog_NSM
	WHERE
		InstallationID = @StoreId
		AND CatalogID = @CatalogID
		AND (@NodeID IS NOT NULL AND NodeID = @NodeID)
	
	IF(@LangPref = '') BEGIN
		SELECT
			@CatalogID		AS CatalogID,
			@MainNodeID		AS NodeID,
			@Description	AS Description,
			@IsLeafNode		AS IsLeafNode,
			@URLPath		AS URLPath
			
		IF(@IsLeafNode = 'N')	BEGIN
			INSERT INTO @NodesTBL (ParentNodeID, NodeID, Description, IsLeafNode, MediaFileUniqueID, ReferenceID, URLPath, MediaFileName, MediaFileComments, NodePosition)
			SELECT
				(SELECT TOP 1 NodeID 
				 FROM SC_Catalog_NSM
				 WHERE 
					InstallationID =  @StoreId
					AND CatalogID = @CatalogID
					AND LeftPosition < Node.LeftPosition AND RightPosition > Node.RightPosition
				 ORDER BY RightPosition - Node.RightPosition 
				) AS ParentNodeID,
				Node.NodeID,
				Node.Description,
				CASE (Node.RightPosition - Node.LeftPosition)
					WHEN 1 THEN 'Y'
					ELSE 'N' 
				END AS IsLeafNode,
				Node.MediaFileUniqueID,
				Node.ReferenceID,
				Node.URLPath,
				MediaFile.MediaFileName,
        MediaFile.MediaFileComments,
				Node.LeftPosition
			FROM SC_Catalog_NSM AS Node
			INNER JOIN SC_Catalog_NSM AS Parent
				ON Node.InstallationID = Parent.InstallationID
				AND Node.CatalogID = Parent.CatalogID
				AND	(Node.ApplyEffectiveDates = 0 OR (@CurrentJulianDate >= Node.EffectiveFrom AND @CurrentJulianDate <= Node.EffectiveThru))
			LEFT OUTER JOIN CATALOGMEDIAFILE AS MediaFile
				ON MediaFile.MediaFileUniqueID = Node.MediaFileUniqueID
			WHERE 
				Node.InstallationID = @StoreId
				AND Node.CatalogID = @CatalogID
				AND Parent.LeftPosition > @left AND Parent.RightPosition < @right
				AND Node.LeftPosition BETWEEN Parent.LeftPosition AND Parent.RightPosition
			GROUP BY Node.NodeID, Node.Description,Node.LeftPosition, Node.RightPosition, Node.MediaFileUniqueID, Node.ReferenceID, Node.URLPath, MediaFile.MediaFileName, MediaFile.MediaFileComments
			HAVING @NestedLevel <= 0 OR (COUNT(Parent.NodeID) - 1) < @NestedLevel
		END /* @IsLeafNode */
	END
	ELSE BEGIN
		SET @Description = ISNULL((SELECT TOP 1 Description 
							FROM SC_CatalogLangs
							WHERE
								InstallationID = @StoreId
								AND CatalogID = @CatalogID
								AND NodeID = @MainNodeID
								AND LanguageID = @LangPref), @Description)
		SELECT
			@CatalogID	AS CatalogID, 
			@MainNodeID		AS NodeID,
			@Description	AS Description,
			@IsLeafNode		AS IsLeafNode,
			@URLPath		AS URLPath
		
		IF(@IsLeafNode = 'N')	BEGIN
			INSERT INTO @NodesTBL (ParentNodeID, NodeID, Description, IsLeafNode, MediaFileUniqueID, ReferenceID, URLPath, MediaFileName, MediaFileComments, NodePosition)
			SELECT
				Cat.ParentNodeID,
				Cat.NodeID,
				ISNULL(Langs.Description, Cat.Description) AS Description,
				Cat.IsLeafNode,
				Cat.MediaFileUniqueID,
				Cat.ReferenceID,
				Cat.URLPath,
				Cat.MediaFileName,
        Cat.MediaFileComments,
				Cat.LeftPosition
			FROM
			(
				SELECT
					(SELECT TOP 1 NodeID 
					 FROM SC_Catalog_NSM
					 WHERE 
						InstallationID =  @StoreId
						AND CatalogID = @CatalogID
						AND LeftPosition < Node.LeftPosition AND RightPosition > Node.RightPosition
					 ORDER BY RightPosition - Node.RightPosition 
					) AS ParentNodeID,
					Node.NodeID,
					Node.Description,
					CASE (Node.RightPosition - Node.LeftPosition)
						WHEN 1 THEN 'Y'
						ELSE 'N' 
					END AS IsLeafNode,
					Node.MediaFileUniqueID,
					Node.ReferenceID,
					Node.InstallationID,
					Node.CatalogID,
					Node.LeftPosition,
					Node.URLPath,
					MediaFile.MediaFileName,
          MediaFile.MediaFileComments
				FROM SC_Catalog_NSM AS Node
				INNER JOIN SC_Catalog_NSM AS Parent
					ON Node.InstallationID = Parent.InstallationID
					AND Node.CatalogID = Parent.CatalogID
					AND	(Node.ApplyEffectiveDates = 0 OR (@CurrentJulianDate >= Node.EffectiveFrom AND @CurrentJulianDate <= Node.EffectiveThru))
				LEFT OUTER JOIN CATALOGMEDIAFILE AS MediaFile
					ON MediaFile.MediaFileUniqueID = Node.MediaFileUniqueID
				WHERE 
					Node.InstallationID = @StoreId
					AND Node.CatalogID = @CatalogID
					AND Parent.LeftPosition > @left AND Parent.RightPosition < @right
					AND Node.LeftPosition BETWEEN Parent.LeftPosition AND Parent.RightPosition
				GROUP BY Node.NodeID, Node.Description, Node.LeftPosition, Node.RightPosition, Node.MediaFileUniqueID, Node.ReferenceID, Node.InstallationID, Node.CatalogID, Node.URLPath, MediaFile.MediaFileName, MediaFile.MediaFileComments
				HAVING @NestedLevel <= 0 OR (COUNT(Parent.NodeID) - 1) < @NestedLevel
			) Cat
			LEFT OUTER JOIN SC_CatalogLangs Langs
				ON Cat.InstallationID = Langs.InstallationID
				AND Cat.CatalogID = Langs.CatalogID
				AND Cat.NodeID = Langs.NodeID
				AND Langs.LanguageID = @LangPref
		END /* @IsLeafNode */
	END

	IF(@IsLeafNode = 'N')	BEGIN
		SELECT 
			@StoreId	AS InstallationID,
			@CatalogID AS CatalogID,
			ParentNodeID,
			NodeID,
			Description,
			IsLeafNode,
			MediaFileUniqueID,
			ReferenceID,
			URLPath,
			MediaFileName,
      MediaFileComments
		FROM @NodesTBL
		ORDER BY ParentNodeID, NodePosition DESC

	END
END
GO
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetCatalogServerMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetCatalogServerMediaFile
	END

GO

-- #desc						Get Catalog Server Media File
-- #bl_class					Premier.Inventory.CatalogServerMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation id
-- #param @ServerName		    Server Name
-- #param @MediaFileUniqueID	Media File UniqueID


CREATE Procedure [dbo].INV_GetCatalogServerMediaFile
(
	@InstallationID		    NVARCHAR(3),
	@ServerName             NVARCHAR(128),
    @MediaFileUniqueID      DECIMAL
)
AS
	
	SELECT 
	    InstallationID,
	    ServerName,
	    MediaFileUniqueID,
	    MediaFileStatus 
	FROM 
		CATALOGSERVERMEDIAFILE
	WHERE
		    InstallationID = @InstallationID
		AND ServerName = @ServerName
		AND MediaFileUniqueID = @MediaFileUniqueID

GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetItemMediaFileOverrideInst'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetItemMediaFileOverrideInst
	END

GO

-- #desc						Reads installations that share the content
-- #bl_class					Premier.Inventory.CatalogItemMediaFiles.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @ItemNumber			Item Number

CREATE Procedure [dbo].INV_GetItemMediaFileOverrideInst(
	@ItemNumber		DECIMAL
)
AS
	SELECT DISTINCT
		InstallationId
	FROM 
		CATALOGITEMMEDIAFILE	
	WHERE
		ItemNumber = @ItemNumber
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetItemPublishedSrchList'))
BEGIN
	DROP PROCEDURE [dbo].INV_GetItemPublishedSrchList
END
GO

-- #desc						
-- #bl_class					Premier.Inventory.ItemPublishedList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		Installation ID
-- #param @FilterTerm		    Filter Search
-- #param @CatalogID			Catalog ID
-- #param @PageIndex			Initial page to display recors
-- #param @PageSize				Quantity of records to display
-- #param @TotalRowCount		Total query result record count


CREATE PROCEDURE [dbo].INV_GetItemPublishedSrchList
(
	@InstallationID			NVARCHAR(3),
	@FilterTerm				NVARCHAR(4000),
	@CatalogID				NVARCHAR(3),
	@PageIndex				DECIMAL,
    @PageSize				DECIMAL,
    @TotalRowCount			INT OUTPUT
)
AS
		IF(@FilterTerm <> '*')
		BEGIN
			SET NOCOUNT ON

			DECLARE @TBL TABLE
			(
				nID					INT IDENTITY,
				ShortItemNumber		DECIMAL,				
				[rank]				DECIMAL
			)

			DECLARE @TBLPagging TABLE
			(
				nID					INT IDENTITY,
				rownumber			Decimal,
				ShortItemNumber		DECIMAL,				
				[rank]				DECIMAL
			)

			DECLARE @ROWSTART INT
			DECLARE @ROWEND INT
	
			DECLARE @SearchText NVARCHAR(4000)
			SET @SearchText = [dbo].CMM_GetFullTextQueryTerms(@FilterTerm, 0)
		
			IF(@SearchText = '')
			BEGIN
				SET @TotalRowCount = 0
				return
			END
		
			INSERT INTO @TBL (ShortItemNumber, [rank])
				SELECT DISTINCT
					CTResult.ShortItemNumber,					
					[rank]
				FROM
					(SELECT
						ShortItemNumber,						
						MAX([rank]) [rank]
					FROM
					(			
						SELECT
							B.ShortItemNumber,
							A.[rank]
						FROM CONTAINSTABLE(SC_ItemMaster, (Content), @SearchText) AS A
						INNER JOIN SC_ItemMaster B
							ON A.[key] = B.UniqueID
							AND B.InstallationID = @InstallationID
						UNION
						SELECT
							D.ShortItemNumber,
							C.[rank]
						FROM CONTAINSTABLE(SC_ItemMasterLangs, *, @SearchText) AS C
						INNER JOIN SC_ItemMasterLangs D
							ON C.[key] = D.UniqueID
							AND D.InstallationID = @InstallationID
					) F
					GROUP BY ShortItemNumber ) CTResult 
					INNER JOIN SC_CatalogNodeItems AS CNI 
						ON CNI.InstallationID = @InstallationID
						AND (@CatalogID = '*' OR  CNI.CatalogID = @CatalogID)
						AND CTResult.ShortItemNumber = CNI.ShortItemNumber
						
			/*Count Total Rows before paging*/
			SELECT @TotalRowCount = COUNT(*) FROM @TBL
				
			/*5. Paging*/
			IF @PageIndex > 0 AND @PageSize > 0
			BEGIN
				-------------------------------------------------------
				-- Set the first row to be selected
				-------------------------------------------------------
				SET @ROWSTART = (@PageSize * @PageIndex) - @PageSize + 1
				-------------------------------------------------------
				-- Set the last row to be selected
				-------------------------------------------------------
				SET @ROWEND = @PageIndex * @PageSize
				INSERT INTO @TBLPagging (rownumber, ShortItemNumber, [rank])
					SELECT * FROM
					(
						SELECT ROW_NUMBER() OVER (ORDER BY [rank] DESC) AS RowNumber, ShortItemNumber, [rank]      
						FROM @TBL RNumber
					)PagingResult
					WHERE RowNumber BETWEEN CAST(@ROWSTART AS NVARCHAR(18)) AND CAST(@ROWEND AS NVARCHAR(18))				
			
				SELECT
					IM.ShortItemNumber		AS ItemNumber,
					IM.DisplayItemNumber	AS DisplayItemNumber,
					IM.Description1			AS ItemDescription1,
					IM.Description2			AS ItemDescription2,
					IM.Description3			AS ItemDescription3,
					IM.DefaultUnitOfMeasure AS DefaultUOM,
					FinalResult.[rank]
				FROM
				(
					SELECT * FROM @TBLPagging
				) FinalResult
				INNER JOIN SC_ItemMaster AS IM 
					ON FinalResult.ShortItemNumber = IM.ShortItemNumber
					AND IM.InstallationID = @InstallationID						
			END
			ELSE
			BEGIN
				SELECT
					IM.ShortItemNumber		AS ItemNumber,
					IM.DisplayItemNumber	AS DisplayItemNumber,
					IM.Description1			AS ItemDescription1,
					IM.Description2			AS ItemDescription2,
					IM.Description3			AS ItemDescription3,
					IM.DefaultUnitOfMeasure AS DefaultUOM,
					FinalResult.[rank]
				FROM
				(
					SELECT * FROM @TBL
				) FinalResult
				INNER JOIN SC_ItemMaster AS IM 
					ON FinalResult.ShortItemNumber = IM.ShortItemNumber
					AND IM.InstallationID = @InstallationID
				 ORDER BY FinalResult.[rank] DESC
			END		
		END		
		
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetMatrixSegmentExtendedProperty'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetMatrixSegmentExtendedProperty
	END

GO

-- #desc				
-- #dll					
-- #class				
-- #method				
-- #Dependencies
-- #References

CREATE Procedure [dbo].INV_GetMatrixSegmentExtendedProperty
(
	@Template				NVARCHAR(20),
	@Style					NVARCHAR(10),
	@SegmentNumber			DECIMAL(18, 0),
	@AttributeValue			NVARCHAR(256),
	@DefaultLanguage		VARCHAR(2)
)
AS
BEGIN 
	SELECT
		A.Template		AS Template, 
		A.Style			AS Style,
		A.SegmentNumber	AS SegmentNumber,
		A.AttributeID	AS AttributeID,
		A.AttributeValue	AS AttributeValue,
		B.OverrideAttributeValue	AS OverrideAttributeValue,
		B.Description 			AS Description,
		A.DescriptionDisplayMode	AS DescriptionDisplayMode,
		B.Title			AS Title,
		A.Hexadecimal1	AS Hexadecimal1,
		A.Hexadecimal2	AS Hexadecimal1,
		A.ImageURL		AS ImageUrl,
		A.Size			AS Size,
		A.MaxWidthSize	AS MaxWidthSize,
		A.BackgroundImageStyle	AS BackgroundImageStyle,
		A.RefreshImage	AS RefreshImage,
		A.DisplayMode		AS DisplayMode,
		@DefaultLanguage
	FROM
		[dbo].SC_AttributesExtended A
		INNER JOIN [dbo].SC_AttributesExtendedLang B--Get the description for Default language
		ON A.Template = B.Template AND A.Style = B.Style AND A.SegmentNumber = B.SegmentNumber AND A.AttributeValue = B.AttributeValue AND B.Language = @DefaultLanguage
	WHERE A.Template = @Template AND A.Style = @Style AND A.SegmentNumber = @SegmentNumber AND A.AttributeValue = @AttributeValue;
		
	EXECUTE [dbo].INV_GetMatrixSegmentExtendedPropertyLangs @Template, @Style, @SegmentNumber, @AttributeValue, @DefaultLanguage;

END
GO
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetMatrixSegmentExtendedPropertyLang'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetMatrixSegmentExtendedPropertyLang
	END

GO

-- #desc				
-- #dll					
-- #class				
-- #method				
-- #Dependencies
-- #References

CREATE Procedure [dbo].INV_GetMatrixSegmentExtendedPropertyLang
(
	@Template				NVARCHAR(20),
	@Style					NVARCHAR(10),
	@SegmentNumber			DECIMAL(18, 0),
	@AttributeValue			NVARCHAR(256),
	@Language				VARCHAR(2)
)
AS
BEGIN 
	SELECT
		MATMPL					AS Template, 
		Style					AS Style, 
		SegmentNumber			AS SegmentNumber,
		AttributeValue			AS AttributeValue,
		OverrideAttributeValue  AS OverrideAttributeValue,
		Description				AS Description, 
		Title					As Title,
		Language				AS Language
	FROM
		[dbo].SC_AttributesExtendedLang A--Get the description for Default language
	WHERE A.Template = @Template AND A.Style = @Style AND A.SegmentNumber = @SegmentNumber AND A.AttributeValue = @AttributeValue AND A.Language = @Language
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetMediaThumbnailPendingList'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetMediaThumbnailPendingList 
	END
GO

-- #desc						Read Pending thumbnail images
-- #bl_class					Premier.Inventory.GenerateCatMediaThumbnailCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

CREATE Procedure [dbo].INV_GetMediaThumbnailPendingList
AS
SELECT TOP 10 
	MediaFileUniqueID,
	MediaFileBody
FROM
	CATALOGMEDIAFILE
WHERE 
	MediaFileThumbnail IS NULL
	AND MediaFileBody IS NOT NULL

GO
   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_GetServMediaFileList'))
	BEGIN
		DROP  Procedure  [dbo].INV_GetServMediaFileList
	END
GO

-- #desc								Get Catalog Server Media File List
-- #bl_class							Premier.Inventory.CatalogServerMediaFileList
-- #db_dependencies						N/A
-- #db_references						N/A
-- #param @InstallationID				InstallationID
-- #param @ServerName					Server Name
-- #param @ImageStatus					Image Status

CREATE Procedure [dbo].INV_GetServMediaFileList
(
	@InstallationID				NVARCHAR(3),
	@ServerName					NVARCHAR(128),
	@ImageStatus				NVARCHAR(3)
)
AS	
	IF(@ImageStatus = 'OLD') BEGIN
		/*Get Old and new images*/	    
	        /*1. Old images*/
	        SELECT 
                C.InstallationID		AS InstallationID, 
                @ServerName				AS ServerName,
                C.MediaFileUniqueID		AS MediaFileUniqueID,
                C.MediaFileStatus		AS ImageStatus,
                ''						AS  MediaFileName,
                ''						AS  MediaFileType
                FROM CATALOGSERVERMEDIAFILE AS C
				INNER JOIN CATALOGMEDIAFILE AS B
					ON B.MediaFileUniqueID = C.MediaFileUniqueID													
                WHERE C.SERVERNAME = @ServerName					
				AND   C.MEDIAFILESTATUS = @ImageStatus 
			UNION ALL
			/*New images: needs to get new images for the current installation that do not exist in the server.
			  But also missing images from base installation. It is important to notice that those images could 
			  be already loaded for the current installation, and we don't want to have duplicated files on the server
			  
			2. Images missing for the current installation*/	 
			SELECT  InstallationID	AS InstallationID, 
                @ServerName			AS ServerName,
                MediaFileUniqueID AS MediaFileUniqueID,
                'NEW'  AS ImageStatus,
                ''     AS  MediaFileName,
                ''     AS  MediaFileType
			FROM (
					SELECT A.MediaFileUniqueID, B.InstallationID
					FROM CATALOGMEDIAFILE AS A
					INNER JOIN CatalogItemMediaFile AS B
						ON  B.InstallationID = @InstallationID
						AND B.MediaFileUniqueID = A.MediaFileUniqueID
				) AS IMAGES
				WHERE NOT EXISTS (SELECT  MediaFileUniqueID  
												FROM CATALOGSERVERMEDIAFILE B
												WHERE B.INSTALLATIONID =@InstallationID
												AND B.SERVERNAME=@ServerName
												AND B.MediaFileUniqueID = IMAGES.MediaFileUniqueID)			  
			UNION ALL
			/*
			3. Images missing for base installation*/	        
			SELECT	InstallationID	AS InstallationID, 
				@ServerName			AS ServerName,
                MediaFileUniqueID AS MediaFileUniqueID,
                'NEW'  AS ImageStatus,
                ''     AS  MediaFileName,
                ''     AS  MediaFileType
			FROM (
					SELECT A.MediaFileUniqueID, B.InstallationID
					 FROM CATALOGMEDIAFILE AS A
					 INNER JOIN CatalogItemMediaFile AS B
					 ON  B.MediaFileUniqueID = A.MediaFileUniqueID
					 AND  InstallationID= '***' 
				 ) AS IMAGES
			WHERE NOT EXISTS (SELECT MediaFileUniqueID  
											FROM CATALOGSERVERMEDIAFILE A
											WHERE A.INSTALLATIONID IN (@InstallationID,'***') 
											AND A.SERVERNAME=@ServerName
											AND A.MediaFileUniqueID = IMAGES.MediaFileUniqueID)				
			/*
			4.Missing Images not related to Items or Families*/
			UNION ALL
			SELECT	@InstallationID		AS InstallationID, 
					@ServerName			AS ServerName,
					A.MediaFileUniqueID AS MediaFileUniqueID,
					'NEW'				AS ImageStatus,
					''					AS MediaFileName,
					''					AS MediaFileType
			FROM CATALOGMEDIAFILE AS A		
			WHERE  InstallationOwner = @InstallationID
			AND NOT EXISTS (SELECT  MediaFileUniqueID FROM CatalogItemMediaFile I WHERE I.MediaFileUniqueID = A.MediaFileUniqueID)
			AND NOT EXISTS (SELECT  MediaFileUniqueID  
											FROM CATALOGSERVERMEDIAFILE B
											WHERE B.INSTALLATIONID = @InstallationID
											AND B.SERVERNAME= @ServerName
											AND B.MediaFileUniqueID = A.MediaFileUniqueID)	

			/*
			6. Delete images that exists on both installations. (The image was first related to base installation and the to the specific installation) */			
			UPDATE CATALOGSERVERMEDIAFILE  SET MediaFileStatus = 'DEL'
			WHERE SERVERNAME = @ServerName
			AND installationid ='***'
			AND mediafileuniqueid IN
			(SELECT mediafileuniqueid  FROM CATALOGSERVERMEDIAFILE WHERE SERVERNAME = @ServerName
			AND installationid = @InstallationID)

	END
    ELSE
    IF(@ImageStatus = 'DEL') BEGIN
        /*Images are not deleted from CATALOGMEDIAFILE until the last server deletes the record from CATALOGSERVERMEDIAFILE*/
		SELECT 
            A.InstallationID	AS InstallationID,
            @ServerName			AS ServerName, 
            B.MediaFileUniqueID	AS  MediaFileUniqueID,
            A.MediaFileStatus	AS ImageStatus,
            B.MediaFileName		AS  MediaFileName,
            B.MediaFileType		AS  MediaFileType
        FROM CATALOGSERVERMEDIAFILE AS A
        INNER JOIN CATALOGMEDIAFILE AS B
            ON A.MediaFileUniqueID = B.MediaFileUniqueID
        WHERE 
        A.InstallationID IN (@InstallationID,'***')
        AND A.MediaFileStatus = 'DEL'
        AND A.ServerName = @ServerName
	END
    
GO


  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_UpdCatalogItemMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_UpdCatalogItemMediaFile
	END

GO

-- #desc						Update Catalog Media File
-- #bl_class					Premier.Inventory.CatalogItemMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationID		InstallationID
-- #param @ItemNumber	        Item Number
-- #param @MediaFileUniqueID	Media File UniqueID
-- #param @PriorityIndex	    Priority Index
-- #param @DefaultImage			Default Image( YES = 1, NO = 0) 
-- #param @MediaFileName		Media File Name installation id
-- #param @MediaFileType		Media File Type installation id
-- #param @MediaFileComments	Media File Comments
-- #param @UserUpdate		    User Update
-- #param @LastDateUpdated		Last Date Updated 
-- #param @LastTimeUpdated		Last Time Updated

CREATE Procedure [dbo].INV_UpdCatalogItemMediaFile
( 
	@InstallationId		    NVARCHAR(3),
	@ItemNumber             DECIMAL,
    @MediaFileUniqueID      DECIMAL,
    @PriorityIndex          DECIMAL,
	@DefaultImage			INT,
	@MediaFileName          NVARCHAR(128),
    @MediaFileType          NVARCHAR(2),
    @MediaFileComments      NVARCHAR(512),
    @UserUpdate             NVARCHAR(30),
    @LastDateUpdated        DECIMAL,
    @LastTimeUpdated        DECIMAL
)
AS
	EXECUTE [dbo].INV_UpdCatalogMediaFile @MediaFileUniqueID, @MediaFileName, @MediaFileType, @MediaFileComments, @UserUpdate, @LastDateUpdated, @LastTimeUpdated
	
	UPDATE	CATALOGITEMMEDIAFILE
	SET
	    PriorityIndex   = @PriorityIndex,
	    LastDateUpdated = @LastDateUpdated,
	    LastTimeUpdated = @LastTimeUpdated,
		DefaultImage	= @DefaultImage
	WHERE 
	        InstallationID      = @InstallationID
		AND ItemNumber          = @ItemNumber
		AND MediaFileUniqueID   = @MediaFileUniqueID
GO 
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_UpdCatalogServerMediaFile'))
	BEGIN
		DROP  Procedure  [dbo].INV_UpdCatalogServerMediaFile
	END

GO

-- #desc						Update Catalog Server Media File
-- #bl_class					Premier.Inventory.CatalogServerMediaFile.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Installation Id
-- #param @ServerName		    Server Name
-- #param @MediaFileUniqueID	Media File UniqueID
-- #param @LastDateUpdated		Last Date Updated
-- #param @LastTimeUpdated		Last Time Updated

CREATE Procedure [dbo].INV_UpdCatalogServerMediaFile
(
	@InstallationId		    NVARCHAR(3),
	@ServerName             NVARCHAR(128),
    @MediaFileUniqueID      DECIMAL,
    @MediaFileStatus        NVARCHAR(3),
    @LastDateUpdated        DECIMAL,
    @LastTimeUpdated        DECIMAL
)
AS
	
	UPDATE	CATALOGSERVERMEDIAFILE
	SET
        MediaFileStatus     = @MediaFileStatus,
        LastDateUpdated     = @LastDateUpdated,
        LastTimeUpdated     = @LastTimeUpdated  
	WHERE 
	        InstallationID      = @InstallationID
	    AND ServerName          = @ServerName
		AND MediaFileUniqueID   = @MediaFileUniqueID
GO 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].INV_UpdMediaFileThumbnail'))
	BEGIN
		DROP  Procedure  [dbo].INV_UpdMediaFileThumbnail
	END
GO

-- #desc							Update Pending thumbnail images
-- #bl_class						Premier.Inventory.GenerateCatMediaThumbnailCommand.cs
-- #db_dependencies					N/A
-- #db_references					N/A
-- #param @MediaFileUniqueID		Media File Unique ID
-- #param @MediaFileThumbnail		Media File Preview Body

CREATE Procedure [dbo].INV_UpdMediaFileThumbnail
(
	@MediaFileUniqueID			BIGINT,
    @MediaFileThumbnail       VARBINARY(max)
)
AS

	UPDATE [dbo].CATALOGMEDIAFILE
	SET
		MediaFileThumbnail = @MediaFileThumbnail
	WHERE MediaFileUniqueID = @MediaFileUniqueID
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].POS_AddPrintDocument'))
	BEGIN
		DROP  Procedure  [dbo].POS_AddPrintDocument
	END

GO

-- #desc						Create document record to reprint
-- #bl_class					Premier.POS.PrintDocument 
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence OUT,
-- #param @InstallationId		Current installation id
-- #param @RegisterId			Current register id POS only
-- #param @PrintDocumentType	Document type , ReportTemplates Enum
-- #param @DocumentID			OrderType + OrderNumber 
-- #param @DocumentBody			Document Body
-- #param @UserID				User ID
-- #param @WorkStationID		WorkStation ID
-- #param @DateUpdated			Date Updated
-- #param @TimeUpdated			Time Updated

CREATE Procedure [dbo].POS_AddPrintDocument
(
	@RecordUniqueID		DECIMAL OUT,
	@InstallationID		NVARCHAR(3),
	@RegisterID			NVARCHAR(30),
	@PrintDocumentType	NVARCHAR(20),
	@DocumentID			NVARCHAR(256),
	@DocumentBody		NVARCHAR(MAX),
	@UserID				DECIMAL,
	@WorkStationID		NVARCHAR(128),
	@DateUpdated		DECIMAL,
	@TimeUpdated		DECIMAL
)
AS

	--Get max sequence number
	SET @RecordUniqueID = (ISNULL((SELECT MAX (RecordUniqueID) FROM SC_PrintDocuments),0) + 1)

	INSERT INTO 
		SC_PrintDocuments
	(
		RecordUniqueID,
		InstallationId,
		RegisterId,
		PrintDocumentType,
		DocumentID,
		DocumentBody,
		UserID,
		WorkStationID,
		DateUpdated,
		TimeUpdated
	)
	VALUES
	(
		@RecordUniqueID,		
		@InstallationID,	
		@RegisterID,	
		@PrintDocumentType,	
		@DocumentID,
		@DocumentBody,		
		@UserID,			
		@WorkStationID,		
		@DateUpdated,		
		@TimeUpdated		
	)

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].POS_ExcDeletePrintDocument'))
	BEGIN
		DROP  Procedure  [dbo].POS_ExcDeletePrintDocument
	END

GO

-- #desc						Clear print document list
-- #bl_class					Premier.POS.PrintDocument 
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Current installation id
-- #param @PersistHours			Setting: Number of hours to persist printed receipts files

CREATE PROCEDURE [dbo].POS_ExcDeletePrintDocument
(
	@InstallationID		NVARCHAR(3),
	@PersistHours		DECIMAL
)
AS

	DECLARE @CurrentDate datetime
	DECLARE @JulianDate VARCHAR(6) = [dbo].CMM_GetCurrentJulianDate(GETDATE());
	DECLARE @JulianTime DECIMAL = REPLACE(CONVERT (VARCHAR(8),GETDATE(), 108),':','');

	/* Current Date in DateTime format */
	SET @CurrentDate = (SELECT	DATEADD(YEAR, 100 * CONVERT(INT, LEFT(@JulianDate,1)) + 10 * CONVERT(INT, SUBSTRING(@JulianDate, 2, 1)) + CONVERT(INT, SUBSTRING(@JulianDate, 3, 1)), 
		DATEADD(DAY, CONVERT(INT, SUBSTRING(@JulianDate, 4, 3)) - 1, DATEADD(HOUR, cast((@JulianTime / 10000) as int) % 100, 
		DATEADD(MINUTE, cast((@JulianTime / 100) as int) % 100, DATEADD(SECOND, @JulianTime % 100, 0))))));
	

	DELETE 
	FROM SC_PrintDocuments
	WHERE
		InstallationID = @InstallationID AND 
		/* Substract Date when document was saved Current Date, and return the hours of difference, then compare with setting */
		DATEDIFF(HOUR, DATEADD(YEAR, 100 * CONVERT(INT, LEFT(CAST(DateUpdated AS VARCHAR),1)) + 10 * CONVERT(INT, SUBSTRING(CAST(DateUpdated AS VARCHAR), 2, 1)) + CONVERT(INT, SUBSTRING(CAST(DateUpdated AS VARCHAR), 3, 1)), 
										DATEADD(DAY, CONVERT(INT, SUBSTRING(CAST(DateUpdated AS VARCHAR), 4, 3)) - 1, /* Adds days*/
										DATEADD(HOUR, CAST((TimeUpdated / 10000) AS INT) % 100, /* Adds hours */
										DATEADD(MINUTE, CAST((TimeUpdated / 100) AS INT) % 100, DATEADD(SECOND, TimeUpdated % 100, 0)) /* Adds minutes */ 
		))), @CurrentDate) > @PersistHours

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].POS_GetPrintDocument'))
	BEGIN
		DROP  Procedure  [dbo].POS_GetPrintDocument
	END

GO

-- #desc						Reads print document record
-- #bl_class					Premier.POS.PrintDocument 
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @RecordUniqueID		Unique ID Sequence 


CREATE Procedure [dbo].POS_GetPrintDocument
(
	@RecordUniqueID		DECIMAL
)
AS
	SELECT
		DocumentBody,
		PrintDocumentType
	FROM 
		SC_PrintDocuments
	WHERE
		RecordUniqueID = @RecordUniqueID;
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].POS_GetPrintDocumentList'))
	BEGIN
		DROP  Procedure  [dbo].POS_GetPrintDocumentList
	END

GO

-- #desc						Reads print document list
-- #bl_class					Premier.POS.PrintDocumentList
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @InstallationId		Current installation id
-- #param @RegisterId			Current register id POS only
-- #param @UserID				User ID
-- #param @PersistHours			Setting: Number of hours to persist printed receipts files 

CREATE PROCEDURE [dbo].POS_GetPrintDocumentList
(
	@InstallationID		NVARCHAR(3),
	@RegisterID			NVARCHAR(30),
	@UserID				DECIMAL,
	@PersistHours		DECIMAL,
	@DocumentID			NVARCHAR(256) = '*',
	@PrintDocumentType	NVARCHAR(20) = '*'
)
AS
	
	DECLARE @CurrentDate datetime
	DECLARE @JulianDate VARCHAR(6) = [dbo].CMM_GetCurrentJulianDate(GETDATE());
	DECLARE @JulianTime DECIMAL = REPLACE(CONVERT (VARCHAR(8),GETDATE(), 108),':','');

	/* Current Date in DateTime format */
	SET @CurrentDate = (SELECT	DATEADD(YEAR, 100 * CONVERT(INT, LEFT(@JulianDate,1)) + 10 * CONVERT(INT, SUBSTRING(@JulianDate, 2, 1)) + CONVERT(INT, SUBSTRING(@JulianDate, 3, 1)), 
		DATEADD(DAY, CONVERT(INT, SUBSTRING(@JulianDate, 4, 3)) - 1, DATEADD(HOUR, cast((@JulianTime / 10000) as int) % 100, 
		DATEADD(MINUTE, cast((@JulianTime / 100) as int) % 100, DATEADD(SECOND, @JulianTime % 100, 0))))));

	SELECT
		RecordUniqueID,
		InstallationID,
		RegisterID,
		PrintDocumentType,
		DocumentID,
		UserID,
		WorkStationID,
		DateUpdated,
		TimeUpdated
	FROM
		SC_PrintDocuments
	WHERE
		(@InstallationID = '*' OR InstallationId = @InstallationID) AND
		(@RegisterID = '*' OR RegisterId = @RegisterID) AND
		(@UserID IS NULL OR UserID = @UserID) AND
		/* Substract Current Date and Date when document was saved and return the hours of difference, compare with setting */
		DATEDIFF(HOUR, DATEADD(YEAR, 100 * CONVERT(INT, LEFT(CAST(DateUpdated AS VARCHAR),1)) + 10 * CONVERT(INT, SUBSTRING(CAST(DateUpdated AS VARCHAR), 2, 1)) + CONVERT(INT, SUBSTRING(CAST(DateUpdated AS VARCHAR), 3, 1)), 
										DATEADD(DAY, CONVERT(INT, SUBSTRING(CAST(DateUpdated AS VARCHAR), 4, 3)) - 1, /* Adds days*/
										DATEADD(HOUR, CAST((TimeUpdated / 10000) AS INT) % 100, /* Adds hours */
										DATEADD(MINUTE, CAST((TimeUpdated / 100) AS INT) % 100, DATEADD(SECOND, TimeUpdated % 100, 0)) /* Adds minutes */ 
		))), @CurrentDate) <= @PersistHours AND
		(@DocumentID = '*' OR DocumentID = @DocumentID) AND
		(@PrintDocumentType = '*' OR PrintDocumentType = @PrintDocumentType)
	ORDER BY DateUpdated DESC, TimeUpdated DESC


GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'dbo.SCDB_DatabaseTuning'))
	BEGIN
		DROP  Procedure  [dbo].SCDB_DatabaseTuning
	END

GO

-- #desc							SQL Server Maintenance Database index and statistics for _SmartCommerceDB
-- #bl_class						N/A
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @pBD						Data Base name
-- #param @IndexesFragmentation		Flag to defrag indexes 
-- #param @UpdateStatistics			Flag to update statistics

CREATE PROCEDURE [dbo].SCDB_DatabaseTuning 
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
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SEC_AddAPIAuthorization'))
BEGIN
	DROP  Procedure  [dbo].SEC_AddAPIAuthorization
END

GO

-- #desc						Creates API Authorization record
-- #bl_class					Premier.Security.APIAuthorization.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param TokenID				API Authorization Token identifier.
-- #param Policy				API Authorization Policies.
-- #param Status				API Authorization Status (Active/Inactive).
-- #param DateCreated			Token generation date.
-- #param LastDateUsed			If Token is used generate a date.
-- #param UserID				Audit information: UserID
-- #param WorkStationID		Audit information: WorkStationID
-- #param DateUpdated			Audit information: DateUpdated
-- #param TimeUpdated			Audit information: TimeUpdated

CREATE Procedure [dbo].SEC_AddAPIAuthorization
(
	@TokenID			INT OUTPUT,
	@Policy				NVARCHAR(1024),
	@Status				NCHAR(2),
	@DateCreated		DECIMAL,
	@LastDateUsed       DATETIME2,
	@UserID				NVARCHAR(10),
	@WorkStationID		NVARCHAR(128), 
	@DateUpdated		DECIMAL,
	@TimeUpdated		DECIMAL
)
AS
INSERT INTO [dbo].[SC_APIAuthorizations]
	(
		[Policy],
		[Status],
		[DateCreated],
		[LastDateUsed],
		[UserID],
		[WorkStationID],
		[DateUpdated],
		[TimeUpdated]
	)
	SELECT
		@Policy,
		@Status,
		@DateCreated,
		@LastDateUsed,
		@UserID,
		@WorkStationId,
		@DateUpdated,
		@TimeUpdated

	SET @TokenID = IDENT_CURRENT ('SC_APIAuthorizations')

GO
		
	


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SEC_DelAPIAuthorization'))
BEGIN
	DROP  Procedure  [dbo].SEC_DelAPIAuthorization
END

GO

-- #desc						Deletes API Authorization record.
-- #bl_class					Premier.Security.APIAuthorization.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param TokenID				API Authorization Token identifier.

CREATE PROCEDURE [dbo].[SEC_DelAPIAuthorization]
	@TokenID			INT
AS 
	DELETE
	FROM [dbo].[SC_APIAuthorizations]
	WHERE [TokenID] = @TokenID
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SEC_ExeCheckAPIAuthorization'))
BEGIN
	DROP  Procedure  [dbo].SEC_ExeCheckAPIAuthorization
END

GO

-- #desc						Checks for API Authorization record existance, Status and Policies.
-- #bl_class					Premier.Security.APIAuthorization.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param APIAccessToken		API Authorization Token.
-- #param Role					API Authorization Policy Role.

CREATE Procedure [dbo].SEC_ExeCheckAPIAuthorization
(
	@APIAccessToken		NVARCHAR(512),
	@Role				NVARCHAR(20)
)
AS
	SELECT COUNT(*)
	FROM [dbo].[SC_APIAuthorizations]
	WHERE ([APIAccessToken] = @APIAccessToken) AND ([Status] = 'A') AND ([Policy] LIKE '%' + @Role + '%');
GO
		
	


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SEC_GetAPIAuthorization'))
BEGIN
	DROP  Procedure  [dbo].SEC_GetAPIAuthorization
END

GO

-- #desc					Gets API Authorization record.
-- #bl_class				Premier.Security.APIAuthorizationList.cs
-- #db_dependencies			N/A
-- #db_references			N/A

CREATE Procedure [dbo].SEC_GetAPIAuthorization
(
	@TokenID			INT
)
AS
	SELECT 
		TokenID,
		APIAccessToken,
		Policy,
		Status,
		LastDateUsed
	FROM [dbo].[SC_APIAuthorizations]
	WHERE ([TokenID] = @TokenID) 
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SEC_GetAPIAuthorizationList'))
BEGIN
	DROP  Procedure  [dbo].SEC_GetAPIAuthorizationList
END

GO

-- #desc						Gets API Authorization List
-- #bl_class					Premier.Security.APIAuthorizationList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

CREATE Procedure [dbo].SEC_GetAPIAuthorizationList
(
	@Status		NCHAR(2)
)
AS
	SELECT 
		TokenID,
		APIAccessToken,
		Status,
		Policy,
		DateCreated,
	    LastDateUsed
	FROM [dbo].[SC_APIAuthorizations]
	WHERE @Status IS NULL OR [Status] = @Status
	ORDER BY DateCreated DESC
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[dbo].SEC_UpdAPIAuthorization'))
BEGIN
	DROP  Procedure  [dbo].SEC_UpdAPIAuthorization
END

GO

-- #desc						Updates API Authorization record
-- #bl_class					Premier.Security.APIAuthorization.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param TokenID				API Authorization Token identifier.
-- #param APIAccessToken		API Authorization Token.
-- #param Policy				API Authorization Policies.
-- #param Status				API Authorization Status (Active/Inactive).
-- #param UserID				Audit information: UserID
-- #param WorkStationID		    Audit information: WorkStationID
-- #param DateUpdated			Audit information: DateUpdated
-- #param LastDateUsed			If Token is used generate a date.
-- #param TimeUpdated			Audit information: TimeUpdated

CREATE Procedure [dbo].SEC_UpdAPIAuthorization
(
	@TokenID			INT,
	@APIAccessToken		NVARCHAR(512),
	@Status				NCHAR(2),
	@UserID				NVARCHAR(10),
	@WorkStationID		NVARCHAR(128), 
	@DateUpdated		DECIMAL,
	@LastDateUsed       DATETIME2,
	@TimeUpdated		DECIMAL
)
AS
	UPDATE [dbo].[SC_APIAuthorizations]
	SET
		[APIAccessToken] = @APIAccessToken,
		[Status] = @Status,
		[UserID] = @UserID,
		[WorkStationID] = @WorkStationID,
		[DateUpdated] = @DateUpdated,
		[LastDateUsed] = @LastDateUsed,
		[TimeUpdated] = @TimeUpdated
	WHERE [TokenID] = @TokenID
GO
		
	


