IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].ECO_GetMigraAttGroupList'))
	BEGIN
		DROP  Procedure  [DBO].ECO_GetMigraAttGroupList
	END
GO

-- #desc						Get Attribute Groups
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE Procedure [DBO].ECO_GetMigraAttGroupList
(
	@PageIndex				INT,
	@PageSize				INT
)
AS
	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;

	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	;WITH CTE AS (
		SELECT
			A.TMTMPI	AS	TemplateId,
			A.TMDSC1	AS	Description,
			ROW_NUMBER() OVER(ORDER BY TMTMPI) RNUM
		FROM
			[SCDATA].FQ67422A A
	)
	SELECT 
		A.TemplateId,
		A.Description,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
		INTO #AttributeGroups
	FROM CTE A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);

	/* Retrieve Attribute Groups */
	SELECT 
		A.TemplateId,
		A.Description,
		A.TotalRowCount
	FROM #AttributeGroups A;

	SELECT
		B.TDTMPI	AS TemplateId,
		B.TD$9AID	AS AttributeId,
		C.ATDSC1	AS AttributeDescription,
		B.TDSEQ		AS SequenceNumber,
		CASE B.TDUKID 
			WHEN 0 THEN B.TD$9VAL	/* Yes/No or numeric */
			ELSE D.AV$9VAL			/* List */
		END AttributeValue,
		CASE B.TDUKID 
			WHEN 0 THEN B.TD$9VAL	/* Yes/No or numeric */
			ELSE CAST(B.TDUKID AS NVARCHAR(256)) 			/* List */
		END GroupValueId
	FROM
		[SCDATA].FQ67422B B
	INNER JOIN #AttributeGroups A
		ON A.TemplateId = B.TDTMPI
	INNER JOIN [SCDATA].FQ67420 C
		ON C.AT$9AID = B.TD$9AID
	LEFT OUTER JOIN [SCDATA].FQ67421 D 
		ON D.AV$9AID = B.TD$9AID 
		AND D.AVUKID = B.TDUKID;
GO
 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].ECO_GetMigraAttributeList'))
	BEGIN
		DROP  Procedure  [DBO].ECO_GetMigraAttributeList
	END

GO
-- #desc						Read Attribute List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE Procedure [DBO].ECO_GetMigraAttributeList	
(
	@PageIndex				INT,
	@PageSize				INT
)
AS
SET NOCOUNT ON

	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;

	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	;WITH CTE AS 
	(
		SELECT
			AT$9AID		AS AttributeId,
			ATDSC1		AS Description,
			AT$9ADRV	AS AttributeType,
			ROW_NUMBER() OVER(ORDER BY AT$9AID) RNUM
		FROM
			[SCDATA].FQ67420
	)
	SELECT
		A.AttributeId,
		A.Description,
		A.AttributeType,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
		INTO #Attributes
	FROM CTE A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);

	/* Retrieve Attributes */
	SELECT
		A.AttributeId,
		A.Description,
		CASE A.AttributeType WHEN 3 THEN 2 ELSE 1 END AS AttributeType, /* Resolve type Text, Numeric and List with value 1 */
		A.TotalRowCount
	FROM #Attributes A;

	;WITH CTE AS 
	(
		SELECT
			IA$9AID	AS AttributeId,
			IA$9VAL AS AttributeValueId,
			ROW_NUMBER() OVER(PARTITION BY IA$9AID ORDER BY IA$9VAL)		AS SequenceNumber,
			IA$9VAL	AS AttributeValue
		FROM 
			[SCDATA].FQ674123 A
			INNER JOIN #Attributes T
				ON T.AttributeId = A.IA$9AID
		WHERE T.AttributeType IN (1, 2)
		GROUP BY IA$9AID, IA$9VAL
	)
	SELECT
		AV$9AID	AS AttributeId,
		CAST(AVUKID AS NVARCHAR(256))	AS AttributeValueId,
		AVSEQ	AS SequenceNumber,
		AV$9VAL	AS AttributeValue
	FROM 
		[SCDATA].FQ67421 A
	INNER JOIN #Attributes T
			ON T.AttributeId = A.AV$9AID
	WHERE T.AttributeType = 4	/* Type List */
	UNION
	SELECT
		A.AttributeId,
		A.AttributeValueId,
		A.SequenceNumber,
		A.AttributeValue
	FROM 
		CTE A;	/* Type Text and Numeric */

	DROP TABLE #Attributes;
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].ECO_GetMigraCatalogAssignLst'))
	BEGIN
		DROP  Procedure  [DBO].ECO_GetMigraCatalogAssignLst
	END

GO
-- #desc						Read Catalog Assignment List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id
-- #param CustCatCode			Customer Category Code						
-- #param CustProductCode		Customer Product Code					
-- #param CustUserDefinedCodes	Customer User Defined Codes		
-- #param ConsuCatCode			Consumer Category Code						
-- #param ConsuProductCode		Consumer Product Code					
-- #param ConsuUserDefinedCodes	Consumer User Defined Codes	
-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE Procedure [DBO].ECO_GetMigraCatalogAssignLst
	@StoreId				NCHAR(3),
	@CustCatCode			NVARCHAR(10),
	@CustProductCode		NVARCHAR(4),
	@CustUserDefinedCodes	NVARCHAR(2),
	@ConsuCatCode			NVARCHAR(10),
	@ConsuProductCode		NVARCHAR(4),
	@ConsuUserDefinedCodes	NVARCHAR(2),
	@PageIndex				INT,
	@PageSize				INT
AS
	DECLARE @RowStart INT;
	DECLARE @RowEnd INT;
	DECLARE	@CodeLength INTEGER = 0;

	SET @RowStart = (@PageSize * @PageIndex) - @PageSize + 1;
	SET @RowEnd = @PageIndex * @PageSize;

	CREATE TABLE #CatalogAssignments
	(
		CatalogId			NVARCHAR(3) collate DATABASE_DEFAULT,
		AssignmentId		FLOAT,
		AssignmentType		NUMERIC(18,0),
		CategoryCode		NVARCHAR(10) collate DATABASE_DEFAULT,
		AssignmentValue		NVARCHAR(40) collate DATABASE_DEFAULT,
		Description			NVARCHAR(50) collate DATABASE_DEFAULT
	);

	/* Customer Category Code */
	SET @CodeLength = ( SELECT DTCDL FROM  [SCCTL].F0004 WHERE DTSY = @CustProductCode AND DTRT = @CustUserDefinedCodes);

	INSERT INTO #CatalogAssignments (CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		CA.CSKY			AS AssignmentValue,
        UDC.DRDL01		AS Description
	FROM  [SCDATA].FQ67414 CA			/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	INNER JOIN  [SCCTL].F0005 UDC	/* Control */ 
		ON UDC.DRSY = @CustProductCode AND
		UDC.DRRT= @CustUserDefinedCodes
 	WHERE
 		A.CA$9INID  = @StoreId 
		AND CA.CS$9ATYP = 1
		AND CA.CSDTAI = @CustCatCode 
		AND CA.CSKY = SUBSTRING(UDC.DRKY, 10 - @CodeLength + 1, @CodeLength);

	/* Consumer Category Code */
	SET @CODELENGTH = ( SELECT DTCDL FROM  [SCCTL].F0004 WHERE DTSY = @ConsuProductCode AND DTRT = @ConsuUserDefinedCodes);

	INSERT INTO #CatalogAssignments (CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		CA.CSKY			AS AssignmentValue,
		UDC.DRDL01		AS Description
	FROM  [SCDATA].FQ67414 CA			/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	INNER JOIN [SCCTL].F0005 UDC		/* Control */
		ON UDC.DRSY = @ConsuProductCode AND
		UDC.DRRT = @ConsuUserDefinedCodes 
 	WHERE
 		A.CA$9INID  = @StoreId 
		AND CA.CS$9ATYP = 2
 		AND CA.CSDTAI = @ConsuCatCode
		AND CA.CSKY = SUBSTRING(UDC.DRKY, 10 - @CodeLength + 1, @CodeLength);

	/* Customer Number */
	INSERT INTO #CatalogAssignments (CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		LTRIM(STR(CA.CS$9AN8, 25))		AS AssignmentValue,
		CUST.ABALPH		AS Description
	FROM  [SCDATA].FQ67414 CA					/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	LEFT OUTER JOIN  [SCDATA].F0101 CUST		/* Customer Table */
	ON	CUST.ABAN8 = CA.CS$9AN8			   		
 	WHERE
 		A.CA$9INID  = @StoreId 
		AND CA.CS$9ATYP = 3;

	/* Consumer Number */
	INSERT INTO #CatalogAssignments (CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		LTRIM(STR(CA.CS$9AN8, 25))		AS AssignmentValue,
		CONS.PRALPH		AS Description
	FROM  [SCDATA].FQ67414 CA					/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	LEFT OUTER JOIN  [SCDATA].FQ670302 CONS	/* Consumer Table */
		ON	CONS.PR$9AN8 = CA.CS$9AN8			   		
 	WHERE
 		A.CA$9INID  = @StoreId 
		AND CA.CS$9ATYP = 4;

	/* Web Account Id */
	INSERT INTO #CatalogAssignments (CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		LTRIM(STR(WA.WA$9AN8, 25) + '-' + LTRIM(STR(WA.WAIDLN, 5)))	AS AssignmentValue,
		WA.WAEMAL		AS Description
	FROM  [SCDATA].FQ67414 CA					/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	LEFT OUTER JOIN  [SCDATA].FQ67101 WA		/* Web Account Table */
		ON	WA.WA$9WAN8 = CA.CS$9WAN8			   		
 	WHERE
 		A.CA$9INID  = @StoreId 
		AND CA.CS$9ATYP = 5;

	/* Retrieve Catalog assignments by Store Id */
	;WITH CTE AS (
		SELECT 
			A.CatalogId, 
			A.AssignmentId,
			A.AssignmentType, 
			A.CategoryCode, 
			A.AssignmentValue, 
			A.Description,
			ROW_NUMBER() OVER(ORDER BY A.CatalogId, A.AssignmentId) RNUM
		FROM #CatalogAssignments A
	)
	SELECT 
		A.CatalogId, 
		A.AssignmentId,
		A.AssignmentType, 
		A.CategoryCode, 
		A.AssignmentValue, 
		A.Description,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
	FROM CTE A
	WHERE (A.RNUM BETWEEN @RowStart AND @RowEnd);

	DROP TABLE #CatalogAssignments;
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].ECO_GetMigraCatalogNodeList'))
	BEGIN
		DROP  Procedure  [DBO].ECO_GetMigraCatalogNodeList
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc					Get Catalog Category Node List
-- #bl_class				Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @StoreId			Store Id
-- #param @CatalogNodesXML	Catalog Nodes XML	<catalogs><catalog><catalogId><![CDATA[ABC]]></catalogId><nodeId><![CDATA[0]]></nodeId></catalog></catalogs>

CREATE Procedure [DBO].ECO_GetMigraCatalogNodeList 
(
	@StoreId			NVARCHAR(3),
	@CatalogNodesXML	XML
)
AS
	/* Gets Catalog nodes ids and Inserts into #CatalogNodes */
	SELECT 
		catalogs.catalog.value('catalogId[1]','NVARCHAR(3)')	AS CatalogId,
		catalogs.catalog.value('nodeId[1]','FLOAT')				AS NodeId
		INTO #CatalogNodes
	FROM @CatalogNodesXML.nodes('/catalogs/catalog') AS catalogs(catalog)
	OPTION ( OPTIMIZE FOR ( @CatalogNodesXML = NULL ) );


	/* Catalog Category Nodes */
	/* Catalogs */
	SELECT 
		B.CA$9CLGID		AS CatalogId,
		0				AS NodeId,
		0				AS ParentKeyId,
		B.CASEQ			AS SequenceNumber,
		B.CAMCU			AS MCU,
		B.CA$9CCFU		AS MCUBehavior,
		N''				AS AttributeGroup,
		RTRIM(D.CFDL01) +' '+
		RTRIM(D.CFDL02) +' '+
		RTRIM(D.CFDL03) +' '+
		RTRIM(D.CFDL04) +' '+
		RTRIM(D.CFDL05) +' '+
		RTRIM(D.CFDL06) +' '+
		RTRIM(D.CFDL07) +' '+
		RTRIM(D.CFDL08) +' '+
		RTRIM(D.CFDL09) +' '+
		RTRIM(D.CFDL10) AS Keywords,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		D.CF$9CLFAM		AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent
	FROM 
		[SCDATA].FQ67412 B
	INNER JOIN #CatalogNodes X
		ON X.CatalogId = B.CA$9CLGID
		AND X.NodeId = 0
	LEFT OUTER JOIN  [SCDATA].FQ67418 C
		ON C.FD$9CLGID = B.CA$9CLGID
		AND C.FDUKID = 0
	LEFT OUTER JOIN [SCDATA].FQ67419 D
		ON D.CF$9CLFAM = C.FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = @StoreId
	WHERE B.CA$9INID = @StoreId

	UNION ALL
	/* Nodes */
	SELECT
		A.CD$9CLGID		AS CatalogId,
		A.CDUKID		AS NodeId,
		A.CD$9PKID		AS ParentKeyId,
		A.CDSEQ			AS SequenceNumber,
		B.CAMCU			AS MCU,
		B.CA$9CCFU		AS MCUBehavior,
		A.CDTMPI		AS AttributeGroup,
		RTRIM(D.CFDL01) +' '+
		RTRIM(D.CFDL02) +' '+
		RTRIM(D.CFDL03) +' '+
		RTRIM(D.CFDL04) +' '+
		RTRIM(D.CFDL05) +' '+
		RTRIM(D.CFDL06) +' '+
		RTRIM(D.CFDL07) +' '+
		RTRIM(D.CFDL08) +' '+
		RTRIM(D.CFDL09) +' '+
		RTRIM(D.CFDL10) AS Keywords,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		D.CF$9CLFAM		AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent
	FROM
		[SCDATA].FQ67413 A
	INNER JOIN [SCDATA].FQ67412 B
		ON B.CA$9CLGID = A.CD$9CLGID
	INNER JOIN #CatalogNodes X
		ON X.CatalogId = A.CD$9CLGID
		AND X.NodeId = A.CDUKID
	LEFT OUTER JOIN [SCDATA].FQ67418 C
		ON C.FD$9CLGID = A.CD$9CLGID
		AND C.FDUKID = A.CDUKID
	LEFT OUTER JOIN [SCDATA].FQ67419 D
		ON D.CF$9CLFAM = C.FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = @StoreId
	WHERE B.CA$9INID = @StoreId; 


	/* Content and Nodes Languages */
	SELECT 
		B.CA$9CLGID		AS CatalogId,
		0				AS NodeId,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		RTRIM(D.CFDL01) +' '+
		RTRIM(D.CFDL02) +' '+
		RTRIM(D.CFDL03) +' '+
		RTRIM(D.CFDL04) +' '+
		RTRIM(D.CFDL05) +' '+
		RTRIM(D.CFDL06) +' '+
		RTRIM(D.CFDL07) +' '+
		RTRIM(D.CFDL08) +' '+
		RTRIM(D.CFDL09) +' '+
		RTRIM(D.CFDL10) AS Keywords,
		D.CF$9CLFAM		AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent,
		D.CFLNGP		AS LanguageId
	FROM 
		[SCDATA].FQ67412 B
	INNER JOIN #CatalogNodes X
		ON X.CatalogId = B.CA$9CLGID
		AND X.NodeId = 0
	INNER JOIN [SCDATA].FQ67418 C
		ON C.FD$9CLGID = B.CA$9CLGID
		AND C.FDUKID = 0
	INNER JOIN [SCDATA].FQ67419L D
		ON D.CF$9CLFAM = C.FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = @StoreId
	WHERE B.CA$9INID = @StoreId

	UNION ALL
	/* Nodes */
	SELECT
		A.CD$9CLGID		AS	CatalogID,
		A.CDUKID		AS	NodeId,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		RTRIM(D.CFDL01) +' '+
		RTRIM(D.CFDL02) +' '+
		RTRIM(D.CFDL03) +' '+
		RTRIM(D.CFDL04) +' '+
		RTRIM(D.CFDL05) +' '+
		RTRIM(D.CFDL06) +' '+
		RTRIM(D.CFDL07) +' '+
		RTRIM(D.CFDL08) +' '+
		RTRIM(D.CFDL09) +' '+
		RTRIM(D.CFDL10) AS Keywords,
		D.CF$9CLFAM		AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent,
		D.CFLNGP		AS LanguageId
	FROM
		[SCDATA].FQ67413 A
	INNER JOIN [SCDATA].FQ67412 B
		ON B.CA$9CLGID = A.CD$9CLGID
	INNER JOIN #CatalogNodes X
		ON X.CatalogId = A.CD$9CLGID
		AND X.NodeId = A.CDUKID
	INNER JOIN [SCDATA].FQ67418 C
		ON C.FD$9CLGID = A.CD$9CLGID
		AND C.FDUKID = A.CDUKID
	INNER JOIN [SCDATA].FQ67419L D
		ON D.CF$9CLFAM = FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = @StoreId
	WHERE B.CA$9INID = @StoreId;
GO
SET QUOTED_IDENTIFIER OFF 
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].ECO_GetMigrationProductList'))
	BEGIN
		DROP  Procedure  [DBO].ECO_GetMigrationProductList
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc							Reads Products by Store
-- #bl_class						Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param StoreId					Store Id
-- #param ProductNumbersXML			Product Numbers XML	<products><product><![CDATA[60020]]></product></products>
-- #param RetrieveAttributes		Retrieve Attributes
-- #param RetrieveContentSections	Retrieve Content Sections

CREATE Procedure [DBO].ECO_GetMigrationProductList
(
	@StoreId					NCHAR(3),
	@ProductNumbersXML			XML,
	@RetrieveAttributes			INT,
	@RetrieveContentSections	INT
)
AS
	DECLARE @DefaultLanguage NCHAR(2);
	DECLARE @DefLangStoreId NCHAR(3) = @StoreId;
	DECLARE @CurrentJulianDate NUMERIC
	SET @CurrentJulianDate = [DBO].CMM_GetCurrentJulianDate(GETDATE())
	
	EXEC [DBO].CMM_GetConstantValue  'DEFLANGPRF', @DefLangStoreId, @DefaultLanguage OUT;

	;WITH CTE AS (
		SELECT
			B.IMITM		AS ShortItemNumber, 
			B.IMLITM	AS LongItemNumber,
			ISNULL(A.CH$9INID, N'***')	AS StoreId,
			RTRIM(RTRIM(ISNULL(A.CHDSC1, B.IMDSC1)) + ' ' + RTRIM(ISNULL(A.CHDSC2, B.IMDSC2))  + ' ' + ISNULL(A.CHDSC3, '')) AS Description, 
			A.CH$9HTML	AS HtmlContent,
			A.CHPTURL	AS ExternalUrl,
			RTRIM(A.CHDL01) +' '+
			RTRIM(A.CHDL02) +' '+
			RTRIM(A.CHDL03) +' '+
			RTRIM(A.CHDL04) +' '+
			RTRIM(A.CHDL05) +' '+
			RTRIM(A.CHDL06) +' '+
			RTRIM(A.CHDL07) +' '+
			RTRIM(A.CHDL08) +' '+
			RTRIM(A.CHDL09) +' '+
			A.CHDL10	AS Keywords,
			A.CHPGTX	AS MetaTitle,
			A.CHCOMMENTS	AS MetaDescription,
			CASE 
				WHEN B.IMSTKT IN ('K', 'C') THEN B.IMSTKT
				WHEN B.IMMIC = '1' AND B.IMTMPL <> '' THEN 'M'
				ELSE 'R'
			END			AS ScType,
			ISNULL((SELECT [DBO].INV_GetItemBranchPlantStrFnc( @StoreId, B.IMITM)), ' ')	AS BranchPlant,
			CASE WHEN A.CHITM IS NULL THEN 0 ELSE 1 END HasWebContent,
			ROW_NUMBER()OVER(PARTITION BY B.IMITM ORDER BY A.CH$9INID DESC)	AS Inst
		FROM  
			[SCDATA].F4101 B
		INNER JOIN @ProductNumbersXML.nodes('/products/product') AS items(item)
			ON items.item.value('.','FLOAT') = B.IMITM
		LEFT JOIN [SCDATA].FQ67410 A
			ON A.CHITM = B.IMITM
			AND A.CH$9INID IN (@StoreId, N'***')
			AND A.CH$9DS = 0	/* Published */
	)
	SELECT
		A.ShortItemNumber, 
		A.LongItemNumber,
		A.Description, 
		A.HtmlContent,
		A.ExternalUrl,
		A.Keywords,
		A.MetaTitle,
		A.MetaDescription,
		A.ScType,
		A.BranchPlant,
		A.HasWebContent,
		A.StoreId
		INTO #StoreItems
	FROM 
		CTE A
	WHERE 
		A.Inst = 1;


	/* Products */
	SELECT
		A.ShortItemNumber, 
		A.LongItemNumber,
		A.Description, 
		A.HtmlContent,
		A.ExternalUrl,
		A.Keywords,
		A.MetaTitle,
		A.MetaDescription,
		A.ScType,
		A.BranchPlant,
		A.HasWebContent
	FROM #StoreItems A;
	
	/* Product languages */
	SELECT  
		A.CLITM			AS ShortItemNumber,
		B.LongItemNumber,
		A.CLLNGP		AS LanguageId, 
		RTRIM(RTRIM(A.CLDSC1) + RTRIM(A.CLDSC2) + A.CLDSC3) AS Description,
		A.CL$9HTML		AS HtmlContent,
		RTRIM(A.CLDL01) +' '+ 
		RTRIM(A.CLDL02) +' '+
		RTRIM(A.CLDL03) +' '+
		RTRIM(A.CLDL04) +' '+
		RTRIM(A.CLDL05) +' '+
		RTRIM(A.CLDL06) +' '+
		RTRIM(A.CLDL07) +' '+
		RTRIM(A.CLDL08) +' '+
		RTRIM(A.CLDL08) +' '+
		RTRIM(A.CLDL09) +' ' +
		RTRIM(A.CLDL10) AS Keywords,
		A.CLPGTX		AS MetaTitle,
		A.CLCOMMENTS	AS MetaDescription,
		B.HasWebContent
	FROM 
		[SCDATA].FQ67410L A
	INNER JOIN #StoreItems B
		ON A.CLITM = B.ShortItemNumber
		AND A.CL$9INID = B.StoreId
	WHERE A.CL$9DS = 0
		AND A.CLLNGP <> @DefaultLanguage; /* Prevent duplicated records */

		/* Attributes */
	IF (@RetrieveAttributes = 1) BEGIN
		SELECT 			
			A.IAITM		AS ShortItemNumber,
			A.IA$9AID	AS AttributeId,
			(CASE WHEN A.IAUKID = 0 THEN A.IA$9VAL ELSE CAST(A.IAUKID AS NVARCHAR(25)) END) AS AttributeValue,
			ISNULL(D.AVSEQ, 0) AS ValueSequenceNumber,
			C.AT$9ADRV	AS AttributeType
		FROM 
			[SCDATA].FQ674123 A
		INNER JOIN #StoreItems B
			ON B.ShortItemNumber = A.IAITM
		INNER JOIN [SCDATA].FQ67420 C
			ON C.AT$9AID = A.IA$9AID
		LEFT OUTER JOIN [SCDATA].FQ67421 D
			ON D.AV$9AID = A.IA$9AID
			AND D.AVUKID = IAUKID;
	END

	/* Content Sections */
	IF (@RetrieveContentSections = 1) BEGIN
		/* Content Sections */
		SELECT 
			A.CDITM		AS ShortItemNumber,
			A.CDUKID	AS UniqueKeyID,
			A.CD$9PTL	AS Title,
			A.CD$9HTML	AS HtmlContent,
			A.CDSEQ		AS SequenceNumber,
			A.CDEFFF	AS EffectiveFromDate,
			A.CDEFFT	AS EffectiveThruDate
		FROM [SCDATA].FQ67411 A
		INNER JOIN #StoreItems B
			ON B.ShortItemNumber = A.CDITM
			AND B.StoreId = A.CD$9INID
		WHERE A.CD$9DS = 0
			AND (@CurrentJulianDate BETWEEN A.CDEFFF AND A.CDEFFT OR @CurrentJulianDate < A.CDEFFF); /* Active or future */

		/* Content Sections Languages */
		SELECT 
			A.CLITM		AS ShortItemNumber,
			A.CLUKID	AS UniqueKeyID,
			A.CLLNGP	AS LanguageId,
			A.CL$9PTL	AS Title,
			A.CL$9HTML	AS HtmlContent
		FROM [SCDATA].FQ67411L A
		INNER JOIN [SCDATA].FQ67411 C
			ON C.CDITM = A.CLITM 
			AND C.CDUKID = A.CLUKID
			AND C.CD$9INID = A.CL$9INID 
			AND C.CD$9DS = A.CL$9DS 
		INNER JOIN #StoreItems B
			ON B.ShortItemNumber = A.CLITM
			AND B.StoreId = A.CL$9INID
		WHERE A.CL$9DS = 0
			AND (@CurrentJulianDate BETWEEN C.CDEFFF AND C.CDEFFT OR @CurrentJulianDate < C.CDEFFF) /* Active or future */
			AND A.CLLNGP <> @DefaultLanguage;	/* Prevent duplicated records */
	END


	DROP TABLE #StoreItems;
GO
SET QUOTED_IDENTIFIER OFF 
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].ECO_GetMigrationSettingList'))
	BEGIN
		DROP  Procedure  [DBO].ECO_GetMigrationSettingList
	END

GO

SET QUOTED_IDENTIFIER ON
GO

-- #desc						Get Settings by Store Id 
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id
-- #param SettingsXML			List of settings <settings><setting><settingName><![CDATA[CTLGLISTIN]]></settingName><newSettingName><![CDATA[CATALOG_PROVIDER]]></newSettingName></setting></settings>

CREATE Procedure [DBO].ECO_GetMigrationSettingList
(
	@StoreId		NVARCHAR(3),
	@SettingsXML	XML
)
AS
	SET NOCOUNT ON
	
	;WITH CTE AS (
		SELECT  
			A.CN$9CNST  Setting,
			A.CN$9VAL	SettingValue,
			settings.setting.value('newSettingName[1]','NVARCHAR(30)')	AS NewSettingName,
			ROW_NUMBER() OVER(PARTITION BY A.CN$9CNST ORDER BY A.CN$9INID DESC) INST
		FROM  
			[SCDATA].FQ670004 A
		INNER JOIN [SCDATA].FQ670003 B 
			ON A.CN$9CNST = B.CN$9CNST
		INNER JOIN @SettingsXML.nodes('/settings/setting') AS settings(setting)
			ON settings.setting.value('settingName[1]','NVARCHAR(10)') = A.CN$9CNST
		WHERE 
			A.CN$9INID IN (@StoreId, N'***')
	)
	SELECT
		A.Setting,
		A.SettingValue,
		A.NewSettingName
	FROM 
		CTE A
	WHERE INST = 1;
GO
SET QUOTED_IDENTIFIER OFF 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].ECO_GetMigrationStatInfo'))
	BEGIN
		DROP  Procedure  [DBO].ECO_GetMigrationStatInfo
	END

GO

-- #desc						Get the row count of Store related tables.
-- #bl_class					Premier.eCommerce.MigrationStatInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @StoreId				Store Id


CREATE Procedure [DBO].ECO_GetMigrationStatInfo
(
	@StoreId					NVARCHAR(3),
	@ProductContentSections		INT OUTPUT,
	@Attributes 				INT OUTPUT,
	@CatalogAssignments			INT OUTPUT,
	@CatalogContentSections 	INT OUTPUT,
	@BranchPlants 				INT OUTPUT,
	@AttributeGroups			INT OUTPUT
)
AS
	SET NOCOUNT ON			

	/* Product Content Sections By Store */
	;WITH CTE AS (
		SELECT 
			B.CHITM,
			B.CH$9INID,
			RANK() OVER(PARTITION BY B.CHITM ORDER BY B.CH$9INID DESC) RNK
		FROM 
			[SCDATA].FQ67410 B
		INNER JOIN [SCDATA].FQ67411 A
			ON A.CDITM = B.CHITM
			AND A.CD$9INID = B.CH$9INID
			AND A.CD$9DS = B.CH$9DS
		WHERE B.CH$9INID IN (@StoreId, N'***') 
			AND B.CH$9DS = 0
	)
	SELECT 
		@ProductContentSections = COUNT(1)
	FROM 
		CTE A
	WHERE A.RNK = 1;

	/* Attributes */
	SET @Attributes = (SELECT COUNT(1) FROM [SCDATA].FQ67420);

	/* Catalog Assignments By Store */
	SET @CatalogAssignments = (SELECT COUNT(1) FROM  [SCDATA].FQ67414 A INNER JOIN [SCDATA].FQ67412 B ON B.CA$9CLGID = A.CS$9CLGID WHERE B.CA$9INID = @StoreId);
	
	/* Catalog Content Sections By Store */
	SET @CatalogContentSections = (SELECT COUNT(1) FROM [SCDATA].FQ67419 WHERE CF$9INID = @StoreId);
	
	/* BranchPlants By Store */
	SET @BranchPlants = (SELECT COUNT(1) FROM [SCDATA].FQ679910 B WHERE B.BI$9INID = @StoreId);
	
	/* AttributeGroups */
	SET @AttributeGroups = (SELECT COUNT(1) FROM [SCDATA].FQ67422A);
	
GO

