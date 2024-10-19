
-- #desc						Get Attribute Groups
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE OR REPLACE  PROCEDURE [SCLIBRARY].ECO_GetMigraAttGroupList
(
	PageIndex		IN INT,
	PageSize		IN INT,
	ResultData1 OUT GLOBALPKG.refcursor,
	ResultData2 OUT GLOBALPKG.refcursor
)
AS
	RowStart	INT;
	RowEnd		INT;
BEGIN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE [SCLIBRARY].ECO_GETMIGRAATTGROUPLIST_A';

	/*Paging */ 
    RowStart := ((PageSize * PageIndex ) - PageSize + 1);
    RowEnd := (PageIndex * PageSize ); 

	INSERT INTO [SCLIBRARY].ECO_GETMIGRAATTGROUPLIST_A
	WITH CTE AS 
	(
		SELECT
			A.TMTMPI	AS	TemplateId,
			A.TMDSC1	AS	Description,
			ROW_NUMBER() OVER(ORDER BY A.TMTMPI) RNUM
		FROM
			[SCDATA].FQ67422A A
	)
	SELECT 
		A.TemplateId,
		A.Description,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
	FROM CTE A
	WHERE (A.RNUM BETWEEN RowStart AND RowEnd);


    OPEN ResultData1 FOR
	SELECT 
		A.TemplateId,
		A.Description,
		A.TotalRowCount
	FROM [SCLIBRARY].ECO_GETMIGRAATTGROUPLIST_A A;

	OPEN ResultData2 FOR
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
			ELSE TO_NCHAR(B.TDUKID) 			/* List */
		END GroupValueId
	FROM
		[SCDATA].FQ67422B B
	INNER JOIN [SCLIBRARY].ECO_GETMIGRAATTGROUPLIST_A A
		ON A.TemplateId = B.TDTMPI
	INNER JOIN [SCDATA].FQ67420 C
		ON C.AT$9AID = B.TD$9AID
	LEFT OUTER JOIN [SCDATA].FQ67421 D 
		ON D.AV$9AID = B.TD$9AID 
		AND D.AVUKID = B.TDUKID;

END;
  /

-- #desc						Read Attribute List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigraAttributeList
(
	PageIndex				IN INT,
	PageSize				IN INT,
	ResultData1 OUT GLOBALPKG.refcursor,
	ResultData2 OUT GLOBALPKG.refcursor
)
AS
	RowStart	INT;
	RowEnd		INT;
BEGIN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE [SCLIBRARY].ECO_GETMIGRAATTRIBUTELIST_A';

	/*Paging */ 
    RowStart := ((PageSize * PageIndex ) - PageSize + 1);
    RowEnd := (PageIndex * PageSize ); 

	INSERT INTO [SCLIBRARY].ECO_GETMIGRAATTRIBUTELIST_A
	WITH CTE AS 
	(
		SELECT
			A.AT$9AID	AS AttributeId,
			A.ATDSC1	AS Description,
			A.AT$9ADRV	AS AttributeType,
			ROW_NUMBER() OVER(ORDER BY A.AT$9AID) RNUM
		FROM
			[SCDATA].FQ67420 A
	)
	SELECT
		A.AttributeId,
		A.Description,
		A.AttributeType,
		(SELECT COUNT(1) FROM CTE) TotalRowCount
	FROM CTE A
	WHERE (A.RNUM BETWEEN RowStart AND RowEnd);


	/* Attributes */
    OPEN ResultData1 FOR
	SELECT
		A.AttributeId,
		A.Description,
		CASE A.AttributeType WHEN 3 THEN 2 ELSE 1 END AS AttributeType, /* Resolve type Text, Numeric and List with value 1 */
		A.TotalRowCount
	FROM [SCLIBRARY].ECO_GETMIGRAATTRIBUTELIST_A A;

	/* Attribute values */
    OPEN ResultData2 FOR
	WITH CTE AS 
	(
		SELECT
			A.IA$9AID	AS AttributeId,
			A.IA$9VAL	AS AttributeValueId,
			ROW_NUMBER() OVER(PARTITION BY A.IA$9AID ORDER BY A.IA$9VAL)		AS SequenceNumber,
			A.IA$9VAL	AS AttributeValue
		FROM 
			[SCDATA].FQ674123 A
		INNER JOIN [SCLIBRARY].ECO_GETMIGRAATTRIBUTELIST_A T
			ON T.AttributeId = A.IA$9AID
		WHERE T.AttributeType IN (1, 2)
		GROUP BY A.IA$9AID, A.IA$9VAL
	)
	SELECT
		A.AV$9AID	AS AttributeId,
		TO_NCHAR(A.AVUKID)	AS AttributeValueId,
		A.AVSEQ		AS SequenceNumber,
		A.AV$9VAL	AS AttributeValue
	FROM 
		[SCDATA].FQ67421 A
	INNER JOIN [SCLIBRARY].ECO_GETMIGRAATTRIBUTELIST_A T
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

END;

  /

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

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigraCatalogAssignLst
(
	StoreId					IN NCHAR,
	CustCatCode				IN NCHAR,
	CustProductCode			IN NCHAR,
	CustUserDefinedCodes	IN NCHAR,
	ConsuCatCode			IN NCHAR,
	ConsuProductCode		IN NCHAR,
	ConsuUserDefinedCodes	IN NCHAR,
	PageIndex				IN INT,
	PageSize				IN INT,
	ResultData1 OUT GLOBALPKG.refcursor
)
AS
    CodeLength  INT := 0;
	
	RowStart	INT;
	RowEnd		INT;
BEGIN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE [SCLIBRARY].ECO_GETMIGRACATALOGASSIGNLST_A';

	/*Paging */ 
    RowStart := ((PageSize * PageIndex ) - PageSize + 1);
    RowEnd := (PageIndex * PageSize ); 

	/* Customer Category Code */
	BEGIN
		SELECT DTCDL INTO CodeLength FROM [SCCTL].F0004 WHERE DTSY = CustProductCode AND DTRT = CustUserDefinedCodes;
	EXCEPTION WHEN NO_DATA_FOUND THEN 
	CodeLength := 0;
	END;

	INSERT INTO [SCLIBRARY].ECO_GETMIGRACATALOGASSIGNLST_A
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		CA.CSKY			AS AssignmentValue,
		UDC.DRDL01		AS Description
	FROM [SCDATA].FQ67414 CA			/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	INNER JOIN [SCCTL].F0005 UDC		/* Control */
		ON UDC.DRSY = CustProductCode 
		AND UDC.DRRT = CustUserDefinedCodes 
 	WHERE
 		A.CA$9INID = StoreId
		AND CA.CS$9ATYP = 1
		AND CA.CSDTAI = CustCatCode
		AND SUBSTR(UDC.DRKY, 10 - CodeLength + 1, CodeLength) = SUBSTR(CA.CSKY, 0, CodeLength);

	/* Consumer Category Code */
	BEGIN
		SELECT DTCDL INTO CodeLength FROM [SCCTL].F0004 WHERE DTSY = ConsuProductCode AND DTRT = ConsuUserDefinedCodes;
	EXCEPTION WHEN NO_DATA_FOUND THEN 
	CodeLength := 0;
	END;

	INSERT INTO [SCLIBRARY].ECO_GETMIGRACATALOGASSIGNLST_A
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		CA.CSKY			AS AssignmentValue,
		UDC.DRDL01		AS Description
	FROM [SCDATA].FQ67414 CA			/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	INNER JOIN [SCCTL].F0005 UDC		/* Control */
		ON UDC.DRSY = ConsuProductCode 
		AND UDC.DRRT = ConsuUserDefinedCodes 	   			
 	WHERE 					
 		A.CA$9INID = StoreId
		AND CA.CS$9ATYP = 2
		AND CA.CSDTAI = ConsuCatCode
		AND SUBSTR(UDC.DRKY, 10 - CodeLength + 1, CodeLength) = SUBSTR(CA.CSKY, 0, CodeLength);	

	/* Customer Number */
	INSERT INTO [SCLIBRARY].ECO_GETMIGRACATALOGASSIGNLST_A
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		TO_NCHAR(CA.CS$9AN8) AS AssignmentValue,
		CUST.ABALPH		AS Description
	FROM [SCDATA].FQ67414 CA			/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	LEFT OUTER JOIN [SCDATA].F0101 CUST	/* Customer Table */
		ON CUST.ABAN8 = CA.CS$9AN8			   		
 	WHERE
 		A.CA$9INID = StoreId 
		AND CA.CS$9ATYP = 3;

	/* Consumer Number */
	INSERT INTO [SCLIBRARY].ECO_GETMIGRACATALOGASSIGNLST_A
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		TO_NCHAR(CA.CS$9AN8) AS AssignmentValue,
		CONS.PRALPH		AS Description
	FROM [SCDATA].FQ67414 CA					/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	LEFT OUTER JOIN [SCDATA].FQ670302 CONS	/* Consumer Table */
		ON CONS.PR$9AN8 = CA.CS$9AN8			   		
 	WHERE
 		A.CA$9INID = StoreId 
		AND CA.CS$9ATYP = 4;

	/* Web Account Id */
	INSERT INTO [SCLIBRARY].ECO_GETMIGRACATALOGASSIGNLST_A
	SELECT 
		CA.CS$9CLGID	AS CatalogId,
		CA.CSUKID		AS AssignmentId,
		CA.CS$9ATYP		AS AssignmentType,
		CA.CSDTAI		AS CategoryCode,
		TO_NCHAR(WA.WA$9AN8) || N'-' || TO_NCHAR(WA.WAIDLN)	AS AssignmentValue,
		WA.WAEMAL		AS Description
	FROM [SCDATA].FQ67414 CA				/* Catalog Assignments */
	INNER JOIN [SCDATA].FQ67412 A
		ON A.CA$9CLGID = CA.CS$9CLGID
	LEFT OUTER JOIN [SCDATA].FQ67101 WA	/* Web Account Table */
		ON WA.WA$9WAN8 = CA.CS$9WAN8			   		
 	WHERE
 		A.CA$9INID = StoreId
		AND CA.CS$9ATYP = 5;

	/* Retrieve Catalog assignments by Store Id */
	OPEN ResultData1 FOR
	WITH CTE AS 
	(
		SELECT 
			A.CatalogId, 
			A.AssignmentId,
			A.AssignmentType, 
			A.CategoryCode, 
			A.AssignmentValue, 
			A.Description,
			ROW_NUMBER() OVER(ORDER BY A.CatalogId, A.AssignmentId) RNUM
		FROM [SCLIBRARY].ECO_GETMIGRACATALOGASSIGNLST_A A
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
	WHERE (A.RNUM BETWEEN RowStart AND RowEnd);

END;
  /

-- #desc					Get Catalog Category Node List
-- #bl_class				Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param StoreId			Store Id
-- #param CatalogNodesXML	Catalog Nodes XML	<catalogs><catalog><catalogId><![CDATA[ABC]]></catalogId><nodeId><![CDATA[0]]></nodeId></catalog></catalogs>

CREATE OR REPLACE  PROCEDURE   [SCLIBRARY].ECO_GetMigraCatalogNodeList
(
  StoreId			IN NCHAR,
  CatalogNodesXML	IN XMLType,
  ResultData1 OUT  GLOBALPKG.refcursor,
  ResultData2 OUT  GLOBALPKG.refcursor
)

AS
	
BEGIN 	

	EXECUTE IMMEDIATE 'TRUNCATE TABLE [SCLIBRARY].ECO_GETMIGRACATALOGNODELIST_A';

	/* Gets Catalog nodes ids and Inserts into ECO_GETMIGRACATALOGNODELIST_A */
	INSERT INTO [SCLIBRARY].ECO_GETMIGRACATALOGNODELIST_A (catalogId, nodeId)
	SELECT 
		catalogs.catalogId,
		catalogs.nodeId
	FROM XMLTABLE ('/catalogs/catalog'
					PASSING CatalogNodesXML
					COLUMNS CATALOGID NCHAR(3) PATH 'catalogId',
					NODEID NUMBER PATH 'nodeId') catalogs	;
	
	/* Catalog Category Nodes */	
	OPEN ResultData1 FOR
	/* Catalogs */
	SELECT 
		B.CA$9CLGID		AS CatalogId,
		0				AS NodeId,
		0				AS ParentKeyId,
		B.CASEQ			AS SequenceNumber,
		B.CAMCU			AS MCU,
		B.CA$9CCFU		AS MCUBehavior,
		N' '			AS AttributeGroup,
		TRIM(D.CFDL01) || N' ' ||
		TRIM(D.CFDL02) || N' ' ||
		TRIM(D.CFDL03) || N' ' ||
		TRIM(D.CFDL04) || N' ' ||
		TRIM(D.CFDL05) || N' ' ||
		TRIM(D.CFDL06) || N' ' ||
		TRIM(D.CFDL07) || N' ' ||
		TRIM(D.CFDL08) || N' ' ||
		TRIM(D.CFDL09) || N' ' ||
		TRIM(D.CFDL10) AS Keywords,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		D.CF$9CLFAM		AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent
	FROM 
		[SCDATA].FQ67412 B
	INNER JOIN [SCLIBRARY].ECO_GETMIGRACATALOGNODELIST_A X
		ON X.CatalogId = B.CA$9CLGID
		AND X.NodeId = 0
	LEFT OUTER JOIN  [SCDATA].FQ67418 C
		ON C.FD$9CLGID = B.CA$9CLGID
		AND C.FDUKID = 0
	LEFT OUTER JOIN [SCDATA].FQ67419 D
		ON D.CF$9CLFAM = C.FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = StoreId
	WHERE B.CA$9INID = StoreId

	UNION ALL
	/* Nodes */
	SELECT
		A.CD$9CLGID	AS CatalogId,
		A.CDUKID		AS NodeId,
		A.CD$9PKID		AS ParentKeyId,
		A.CDSEQ		AS SequenceNumber,
		B.CAMCU		AS MCU,
		B.CA$9CCFU  AS MCUBehavior,
		A.CDTMPI	AS AttributeGroup,
		TRIM(D.CFDL01) || N' ' ||
		TRIM(D.CFDL02) || N' ' ||
		TRIM(D.CFDL03) || N' ' ||
		TRIM(D.CFDL04) || N' ' ||
		TRIM(D.CFDL05) || N' ' ||
		TRIM(D.CFDL06) || N' ' ||
		TRIM(D.CFDL07) || N' ' ||
		TRIM(D.CFDL08) || N' ' ||
		TRIM(D.CFDL09) || N' ' ||
		TRIM(D.CFDL10) AS Keywords,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		D.CF$9CLFAM	AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent
	FROM
		[SCDATA].FQ67413 A
	INNER JOIN [SCDATA].FQ67412 B
		ON B.CA$9CLGID = A.CD$9CLGID
	INNER JOIN [SCLIBRARY].ECO_GETMIGRACATALOGNODELIST_A X
		ON X.CatalogId = A.CD$9CLGID
		AND X.NodeId = A.CDUKID
	LEFT OUTER JOIN [SCDATA].FQ67418 C
		ON C.FD$9CLGID = A.CD$9CLGID
		AND C.FDUKID = A.CDUKID
	LEFT OUTER JOIN [SCDATA].FQ67419 D
		ON D.CF$9CLFAM = C.FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = StoreId
	WHERE B.CA$9INID = StoreId;

	/* Content and Nodes Languages */
	OPEN ResultData2 FOR
	/* Catalogs */
	SELECT 
		B.CA$9CLGID	AS CatalogId,
		0		AS NodeId,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		TRIM(D.CFDL01) || N' ' ||
		TRIM(D.CFDL02) || N' ' ||
		TRIM(D.CFDL03) || N' ' ||
		TRIM(D.CFDL04) || N' ' ||
		TRIM(D.CFDL05) || N' ' ||
		TRIM(D.CFDL06) || N' ' ||
		TRIM(D.CFDL07) || N' ' ||
		TRIM(D.CFDL08) || N' ' ||
		TRIM(D.CFDL09) || N' ' ||
		TRIM(D.CFDL10) AS Keywords,
		D.CF$9CLFAM	AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent,
		D.CFLNGP		AS LanguageId
	FROM 
		[SCDATA].FQ67412 B
	INNER JOIN [SCLIBRARY].ECO_GETMIGRACATALOGNODELIST_A X
		ON X.CatalogId = B.CA$9CLGID
		AND X.NodeId = 0
	INNER JOIN [SCDATA].FQ67418 C
		ON C.FD$9CLGID = B.CA$9CLGID
		AND C.FDUKID = 0
	INNER JOIN [SCDATA].FQ67419L D
		ON D.CF$9CLFAM = C.FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = StoreId
	WHERE B.CA$9INID = StoreId

	UNION ALL
	/* Nodes */
	SELECT
		A.CD$9CLGID	AS CatalogID,
		A.CDUKID		AS NodeId,
		D.CFPGTX		AS MetaTitle,
		D.CFCOMMENTS	AS MetaDescription,
		TRIM(D.CFDL01) || N' ' ||
		TRIM(D.CFDL02) || N' ' ||
		TRIM(D.CFDL03) || N' ' ||
		TRIM(D.CFDL04) || N' ' ||
		TRIM(D.CFDL05) || N' ' ||
		TRIM(D.CFDL06) || N' ' ||
		TRIM(D.CFDL07) || N' ' ||
		TRIM(D.CFDL08) || N' ' ||
		TRIM(D.CFDL09) || N' ' ||
		TRIM(D.CFDL10) AS Keywords,
		D.CF$9CLFAM	AS FamilyContentId,
		D.CFDSC1		AS ContentTitle,
		D.CF$9HTML		AS HtmlContent,
		D.CFLNGP		AS LanguageId
	FROM
		[SCDATA].FQ67413 A
	INNER JOIN [SCDATA].FQ67412 B
		ON B.CA$9CLGID = A.CD$9CLGID
	INNER JOIN [SCLIBRARY].ECO_GETMIGRACATALOGNODELIST_A X
		ON X.CatalogId = A.CD$9CLGID
		AND X.NodeId = A.CDUKID
	INNER JOIN [SCDATA].FQ67418 C
		ON C.FD$9CLGID = A.CD$9CLGID
		AND C.FDUKID = A.CDUKID
	INNER JOIN [SCDATA].FQ67419L D
		ON D.CF$9CLFAM = FD$9CLFAM
		AND D.CF$9DS = 0
		AND D.CF$9INID = StoreId
	WHERE B.CA$9INID = StoreId;

END; 
  /

-- #desc							Reads Products by Store
-- #bl_class						Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param StoreId					Store Id
-- #param ProductNumbersXML			Product Numbers XML	<products><product><![CDATA[60020]]></product></products>
-- #param RetrieveAttributes		Retrieve Attributes
-- #param RetrieveContentSections	Retrieve Content Sections

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigrationProductList
(
	StoreId					IN NCHAR,
	ProductNumbersXML		IN XMLType,
	RetrieveAttributes		IN INT,
	RetrieveContentSections	IN INT,
	ResultData1 OUT GLOBALPKG.refcursor,
	ResultData2 OUT GLOBALPKG.refcursor,
	ResultData3 OUT GLOBALPKG.refcursor,
	ResultData4 OUT GLOBALPKG.refcursor,
	ResultData5 OUT GLOBALPKG.refcursor
)
AS
	DefLangStoreId NCHAR(3) := StoreId;
	DefaultLanguage NCHAR(2);
	SQL_DYNAMIC_ATTRIBUTES		VARCHAR2(4000);
	SQL_DYNAMIC_CONTSECTIONS	VARCHAR2(4000);
	SQL_DYNAMIC_CONTSECLANGS	VARCHAR2(4000);
	CurrentJulianDate 	NUMBER(6,0) := [SCLIBRARY].CMM_GetCurrentJulianDate (SYSDATE);
BEGIN
	[SCLIBRARY].CMM_GetConstantValue('DEFLANGPRF', DefLangStoreId, DefaultLanguage);

    EXECUTE IMMEDIATE 'TRUNCATE TABLE [SCLIBRARY].ECO_GETMIGRATIONPRODUCTLIST_A';

	/* Insert products into temporary table */
	INSERT INTO [SCLIBRARY].ECO_GETMIGRATIONPRODUCTLIST_A 
	WITH CTE AS (
		SELECT
			B.IMITM		AS ShortItemNumber, 
			B.IMLITM	AS LongItemNumber,
			NVL(A.CH$9INID, N'***')	AS TBLStoreId,
			TRIM(TRIM(NVL(A.CHDSC1, B.IMDSC1)) || ' ' || TRIM(NVL(A.CHDSC2, B.IMDSC2)) || ' ' || NVL(A.CHDSC3, '')) AS Description, 
			A.CH$9HTML	AS HtmlContent,
			A.CHPTURL	AS ExternalUrl,
			TRIM(A.CHDL01) ||' '||
			TRIM(A.CHDL02) ||' '||
			TRIM(A.CHDL03) ||' '||
			TRIM(A.CHDL04) ||' '||
			TRIM(A.CHDL05) ||' '||
			TRIM(A.CHDL06) ||' '||
			TRIM(A.CHDL07) ||' '||
			TRIM(A.CHDL08) ||' '||
			TRIM(A.CHDL09) ||' '||
			A.CHDL10	AS Keywords,
			A.CHPGTX	AS MetaTitle,
			A.CHCOMMENTS	AS MetaDescription,
			CASE 
				WHEN B.IMSTKT IN (N'K', N'C') THEN B.IMSTKT
				WHEN B.IMMIC = N'1' AND B.IMTMPL <> N' ' THEN N'M'
				ELSE N'R'
			END			AS ScType,
			NVL(SCLIBRARY.INV_GetItemBranchPlantStrFnc( StoreId, B.IMITM), N' ')	AS BranchPlant,
			CASE WHEN A.CHITM IS NULL THEN 0 ELSE 1 END HasWebContent,
			ROW_NUMBER()OVER(PARTITION BY B.IMITM ORDER BY A.CH$9INID DESC)	AS Inst
		FROM 
			[SCDATA].F4101 B  
		INNER JOIN XMLTABLE ('/products/product' 
				PASSING ProductNumbersXML
				COLUMNS ShortProductNumber NUMBER PATH 'text()') X
			ON X.ShortProductNumber = B.IMITM
		LEFT JOIN [SCDATA].FQ67410 A
			ON A.CHITM = B.IMITM
			AND A.CH$9INID IN (StoreId, N'***')
			AND A.CH$9DS = 0	/* Published */
	)
	SELECT
		A.ShortItemNumber, 
		A.LongItemNumber,
		A.TBLStoreId,
		A.Description, 
		A.HtmlContent,
		A.ExternalUrl,
		A.Keywords,
		A.MetaTitle,
		A.MetaDescription,
		A.ScType,
		A.BranchPlant,
		A.HasWebContent
	FROM 
		CTE A
	WHERE 
		A.Inst = 1;


	/* Products */
	OPEN ResultData1 FOR
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
	FROM [SCLIBRARY].ECO_GETMIGRATIONPRODUCTLIST_A A;

	/* Product languages */
	OPEN ResultData2 FOR
	SELECT  
		A.CLITM			AS ShortItemNumber,
		B.LongItemNumber,
		A.CLLNGP		AS LanguageId, 
		TRIM(TRIM(A.CLDSC1) || TRIM(A.CLDSC2) || A.CLDSC3) AS Description,
		A.CL$9HTML		AS HtmlContent,
		TRIM(A.CLDL01) ||' '|| 
		TRIM(A.CLDL02) ||' '||
		TRIM(A.CLDL03) ||' '||
		TRIM(A.CLDL04) ||' '||
		TRIM(A.CLDL05) ||' '||
		TRIM(A.CLDL06) ||' '||
		TRIM(A.CLDL07) ||' '||
		TRIM(A.CLDL08) ||' '||
		TRIM(A.CLDL08) ||' '||
		TRIM(A.CLDL09) ||' '||
		TRIM(A.CLDL10) AS Keywords,
		A.CLPGTX		AS MetaTitle,
		A.CLCOMMENTS	AS MetaDescription,
		B.HasWebContent
	FROM 
		[SCDATA].FQ67410L A
	INNER JOIN [SCLIBRARY].ECO_GETMIGRATIONPRODUCTLIST_A B
		ON A.CLITM = B.ShortItemNumber
		AND A.CL$9INID = B.TBLStoreId
	WHERE A.CL$9DS = 0
		AND A.CLLNGP <> DefaultLanguage; /* Prevent duplicated records */

	/* Attributes */
	SQL_DYNAMIC_ATTRIBUTES := N'
		SELECT 			
				A.IAITM		AS ShortItemNumber,
				A.IA$9AID	AS AttributeId,
				(CASE WHEN A.IAUKID = 0 THEN A.IA$9VAL ELSE TO_NCHAR(A.IAUKID) END) AS AttributeValue,
				NVL(D.AVSEQ, 0) AS ValueSequenceNumber,
				C.AT$9ADRV	AS AttributeType
			FROM 
				[SCDATA].FQ674123 A
			INNER JOIN [SCLIBRARY].ECO_GETMIGRATIONPRODUCTLIST_A B
				ON B.ShortItemNumber = A.IAITM
			INNER JOIN [SCDATA].FQ67420 C
				ON C.AT$9AID = A.IA$9AID
			LEFT OUTER JOIN [SCDATA].FQ67421 D
				ON D.AV$9AID = A.IA$9AID
				AND D.AVUKID = IAUKID ';

	
	/* Content Sections */
	SQL_DYNAMIC_CONTSECTIONS := N'
		SELECT 
			A.CDITM		AS ShortItemNumber,
			A.CDUKID	AS UniqueKeyID,
			A.CD$9PTL	AS Title,
			A.CD$9HTML	AS HtmlContent,
			A.CDSEQ		AS SequenceNumber,
			A.CDEFFF	AS EffectiveFromDate,
			A.CDEFFT	AS EffectiveThruDate
		FROM [SCDATA].FQ67411 A
		INNER JOIN [SCLIBRARY].ECO_GETMIGRATIONPRODUCTLIST_A B
			ON B.ShortItemNumber = A.CDITM
			AND B.TBLStoreId = A.CD$9INID
		WHERE A.CD$9DS = 0
			AND (:CurrentJulianDate BETWEEN A.CDEFFF AND A.CDEFFT OR :CurrentJulianDate < A.CDEFFF) ';

	/* Content Sections Languages */
	SQL_DYNAMIC_CONTSECLANGS := N'
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
		INNER JOIN [SCLIBRARY].ECO_GETMIGRATIONPRODUCTLIST_A B
			ON B.ShortItemNumber = A.CLITM
			AND B.TBLStoreId = A.CL$9INID
		WHERE A.CL$9DS = 0
			AND (:CurrentJulianDate BETWEEN C.CDEFFF AND C.CDEFFT OR :CurrentJulianDate < C.CDEFFF)
			AND A.CLLNGP <> :DefaultLanguage ';

	IF (RetrieveAttributes = 1 AND RetrieveContentSections = 1) THEN
		/* Attributes */
		OPEN ResultData3 FOR SQL_DYNAMIC_ATTRIBUTES;

		/* Content Sections */
		OPEN ResultData4 FOR SQL_DYNAMIC_CONTSECTIONS USING CurrentJulianDate, CurrentJulianDate;

		/* Content Sections Languages */
		OPEN ResultData5 FOR SQL_DYNAMIC_CONTSECLANGS USING CurrentJulianDate, CurrentJulianDate, DefaultLanguage;

	ELSIF(RetrieveAttributes = 1) THEN
		/* Attributes */
		OPEN ResultData3 FOR SQL_DYNAMIC_ATTRIBUTES;

	ELSIF(RetrieveContentSections = 1) THEN
		/* Content Sections */
		OPEN ResultData3 FOR SQL_DYNAMIC_CONTSECTIONS USING CurrentJulianDate, CurrentJulianDate;

		/* Content Sections Languages */
		OPEN ResultData4 FOR SQL_DYNAMIC_CONTSECLANGS USING CurrentJulianDate, CurrentJulianDate, DefaultLanguage;
	END IF;

END;
  /

-- #desc						Get Settings by Store Id 
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id
-- #param SettingsXML			List of settings <settings><setting><settingName><![CDATA[CTLGLISTIN]]></settingName><newSettingName><![CDATA[CATALOG_PROVIDER]]></newSettingName></setting></settings>

CREATE OR REPLACE  PROCEDURE   [SCLIBRARY].ECO_GetMigrationSettingList
(
  StoreId		IN NCHAR,
  SettingsXML	IN XMLType,
  ResultData1 OUT  GLOBALPKG.refcursor
)

AS
	
BEGIN 	
	
	OPEN ResultData1 FOR
	WITH CTE AS (
		SELECT  
			A.CN$9CNST  Setting,
			A.CN$9VAL	SettingValue,
			S.NewSettingName,
			ROW_NUMBER() OVER(PARTITION BY A.CN$9CNST ORDER BY A.CN$9INID DESC) INST
		FROM  
			[SCDATA].FQ670004 A
		INNER JOIN [SCDATA].FQ670003 B 
			ON B.CN$9CNST = A.CN$9CNST
		INNER JOIN XMLTABLE ('/settings/setting'
				PASSING SettingsXML
				COLUMNS SettingName NCHAR(10) PATH 'settingName',
				NewSettingName NCHAR(30) PATH 'newSettingName') S
			ON S.SettingName = A.CN$9CNST
		WHERE 
			A.CN$9INID IN (StoreId, N'***')
	)
	SELECT
		A.Setting,
		A.SettingValue,
		A.NewSettingName
	FROM 
		CTE A
	WHERE INST = 1;

END; 
  /
-- #desc						Get the row count of Store related tables.
-- #bl_class					Premier.eCommerce.MigrationStatInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigrationStatInfo
(
	StoreId					IN NCHAR,
	ProductContentSections	OUT INT,
	Attributes 				OUT INT,
	CatalogAssignments		OUT INT,
	CatalogContentSections 	OUT INT,
	BranchPlants			OUT INT,
	AttributeGroups			OUT INT
)
AS
BEGIN			
	
	/* Product Content Sections By Store */
	WITH CTE AS (
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
		WHERE B.CH$9INID IN (StoreId, N'***') 
			AND B.CH$9DS = 0
	)
	SELECT 
		COUNT(1) INTO ProductContentSections
	FROM 
		CTE A
	WHERE A.RNK = 1;

	/* Attributes */
	SELECT COUNT(1) INTO Attributes FROM [SCDATA].FQ67420;

	/* Catalog Assignments By Store */
	SELECT COUNT(1) INTO CatalogAssignments FROM  [SCDATA].FQ67414 A INNER JOIN [SCDATA].FQ67412 B ON B.CA$9CLGID = A.CS$9CLGID WHERE B.CA$9INID = StoreId;
	
	/* Catalog Content Sections By Store */
	SELECT COUNT(1) INTO CatalogContentSections FROM [SCDATA].FQ67419 WHERE CF$9INID = StoreId;
	
	/* BranchPlants By Store */
	SELECT COUNT(1) INTO BranchPlants FROM [SCDATA].FQ679910 B WHERE B.BI$9INID = StoreId;
	
	/* AttributeGroups */
	SELECT COUNT(1) INTO AttributeGroups FROM [SCDATA].FQ67422A;
END;				
		
  /
