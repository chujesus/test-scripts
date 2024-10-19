-- #desc						Get Attribute Groups
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigraAttGroupList
(
	IN PageIndex		INT,
    IN PageSize			INT
)

DYNAMIC RESULT SETS 2
LANGUAGE SQL
SPECIFIC [SCLIBRARY].ECO_GetMigraAttGroupList
NOT DETERMINISTIC
MODIFIES SQL DATA
CALLED ON NULL INPUT
BEGIN
	/*Paging */ 
	DECLARE RowStart INT;
	DECLARE RowEnd INT;
	
	DECLARE GLOBAL TEMPORARY TABLE SESSION.TMP_TABLE
	(
		TemplateId		GRAPHIC(10) CCSID 13488,
		Description		GRAPHIC(30) CCSID 13488,
		TotalRowCount	INT
	)WITH REPLACE ON COMMIT PRESERVE ROWS NOT LOGGED;

	BEGIN
		DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
		SELECT 
			A.TemplateId,
			A.Description,
			A.TotalRowCount
		FROM SESSION.TMP_TABLE A
		FOR FETCH ONLY;
	
		DECLARE TEMP_CURSOR2 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
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
		INNER JOIN SESSION.TMP_TABLE A
			ON A.TemplateId = B.TDTMPI
		INNER JOIN [SCDATA].FQ67420 C
			ON C.AT$9AID = B.TD$9AID
		LEFT OUTER JOIN [SCDATA].FQ67421 D 
			ON D.AV$9AID = B.TD$9AID 
			AND D.AVUKID = B.TDUKID
		FOR FETCH ONLY;
	
		SET RowStart = ((PageSize * PageIndex) - PageSize + 1);
		SET RowEnd = (PageIndex * PageSize);

		INSERT INTO SESSION.TMP_TABLE (TemplateId, Description, TotalRowCount)
		WITH CTE AS (
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
		FROM CTE A
		WHERE (A.RNUM BETWEEN RowStart AND RowEnd);

		OPEN TEMP_CURSOR1;
	
		OPEN TEMP_CURSOR2;
	END;
END;
-- #desc						Read Attribute List
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param PageIndex				Paging - Current page
-- #param PageSize				Paging - Items to be shown

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigraAttributeList
(
	IN PageIndex	INT,
    IN PageSize		INT
)
DYNAMIC RESULT SETS 2
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].ECO_GetMigraAttributeList
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
BEGIN 

	/*Paging */ 
	DECLARE RowStart INT;
	DECLARE RowEnd INT;

	DECLARE GLOBAL TEMPORARY TABLE SESSION.TMP_TABLE
	(
		AttributeId			GRAPHIC(10) CCSID 13488,
		Description			GRAPHIC(30) CCSID 13488,
		AttributeType		NUMERIC(1,0),
		TotalRowCount		INT
		
	)WITH REPLACE ON COMMIT PRESERVE ROWS NOT LOGGED;

	BEGIN
		DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
		SELECT
			A.AttributeId,
			A.Description,
			CASE A.AttributeType WHEN 3 THEN 2 ELSE 1 END AS AttributeType, /* Resolve type Text, Numeric and List with value 1 */
			A.TotalRowCount
		FROM SESSION.TMP_TABLE A
		FOR FETCH ONLY;

	
		DECLARE TEMP_CURSOR2 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
		WITH CTE AS 
		(
			SELECT
				A.IA$9AID	AS AttributeId,
				A.IA$9VAL	AS AttributeValueId,
				ROW_NUMBER() OVER(PARTITION BY A.IA$9AID ORDER BY A.IA$9VAL)		AS SequenceNumber,
				A.IA$9VAL	AS AttributeValue
			FROM 
				[SCDATA].FQ674123 A
				INNER JOIN SESSION.TMP_TABLE T
					ON T.AttributeId = A.IA$9AID
			WHERE T.AttributeType IN (1, 2)
			GROUP BY IA$9AID, IA$9VAL
		)
		SELECT
			A.AV$9AID	AS AttributeId,
			CAST(A.AVUKID AS GRAPHIC(256) CCSID 13488)	AS AttributeValueId,
			A.AVSEQ		AS SequenceNumber,
			A.AV$9VAL	AS AttributeValue
		FROM 
			[SCDATA].FQ67421 A
			INNER JOIN SESSION.TMP_TABLE T
				ON T.AttributeId = A.AV$9AID
		WHERE T.AttributeType = 4	/* Type List */
		UNION
		SELECT
			A.AttributeId,
			A.AttributeValueId,
			A.SequenceNumber,
			A.AttributeValue
		FROM 
			CTE A	/* Type Text and Numeric */
		FOR FETCH ONLY;

		SET RowStart = ((PageSize * PageIndex) - PageSize + 1);
		SET RowEnd = (PageIndex * PageSize);

		/* Insert into temporary table */
		INSERT INTO SESSION.TMP_TABLE(AttributeId, Description, AttributeType, TotalRowCount)
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
		OPEN TEMP_CURSOR1;

		/* Attribute Values */
		OPEN TEMP_CURSOR2;
	END;

END;
-- #desc							Read Catalog Assignment List
-- #bl_class						Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param StoreId					Store Id
-- #param CustCatCode				Customer Category Code						
-- #param CustProductCode			Customer Product Code					
-- #param CustUserDefinedCodes		Customer User Defined Codes		
-- #param ConsuCatCode				Consumer Category Code						
-- #param ConsuProductCode			Consumer Product Code					
-- #param ConsuUserDefinedCodes		Consumer User Defined Codes	
-- #param PageIndex					Paging - Current page
-- #param PageSize					Paging - Items to be shown

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigraCatalogAssignLst
(
	IN StoreId					GRAPHIC(3) CCSID 13488,
	IN CustCatCode				GRAPHIC(10) CCSID 13488,
	IN CustProductCode			GRAPHIC(4) CCSID 13488,
	IN CustUserDefinedCodes		GRAPHIC(2) CCSID 13488,
	IN ConsuCatCode				GRAPHIC(10) CCSID 13488,
	IN ConsuProductCode			GRAPHIC(4) CCSID 13488,
	IN ConsuUserDefinedCodes	GRAPHIC(2) CCSID 13488,
	IN PageIndex				INT,
    IN PageSize					INT
)
DYNAMIC RESULT SETS 1 
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].ECO_GetMigraCatalogAssignLst 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
BEGIN
	DECLARE CodeLength  INTEGER;
	
	/*Paging */ 
	DECLARE RowStart INT;
	DECLARE RowEnd INT;

	DECLARE GLOBAL TEMPORARY TABLE SESSION.TMP_TABLE
	(
		CatalogId			GRAPHIC(3) CCSID 13488,
		AssignmentId		DECIMAL(15,0),
		AssignmentType		DECIMAL(31,0),
		CategoryCode		GRAPHIC(10) CCSID 13488,
		AssignmentValue		GRAPHIC(40) CCSID 13488,
		Description			VARGRAPHIC(256) CCSID 13488
		
	)WITH REPLACE ON COMMIT PRESERVE ROWS NOT LOGGED;

	BEGIN
		DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
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
			FROM 
				SESSION.TMP_TABLE A
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
		WHERE (A.RNUM BETWEEN RowStart AND RowEnd)
		FOR FETCH ONLY; 

		/* Customer Category Code */
		SET CodeLength = (SELECT DTCDL FROM [SCCTL].F0004 WHERE DTSY = CustProductCode AND DTRT = CustUserDefinedCodes);
				
		INSERT INTO SESSION.TMP_TABLE(CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
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
			AND UDC.DRRT= CustUserDefinedCodes
		WHERE
			A.CA$9INID = StoreId
			AND CA.CS$9ATYP = 1 
			AND CA.CSDTAI = CustCatCode 
			AND SUBSTRING(UDC.DRKY, 10 - CodeLength + 1, CodeLength) = CA.CSKY;


		/* Consumer Category Code */
		SET CodeLength = (SELECT DTCDL FROM [SCCTL].F0004 WHERE DTSY = ConsuProductCode AND DTRT = ConsuUserDefinedCodes);
					
		INSERT INTO SESSION.TMP_TABLE(CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
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
			ON	UDC.DRSY = ConsuProductCode 
			AND UDC.DRRT= ConsuUserDefinedCodes 
 		WHERE
 			A.CA$9INID = StoreId 
			AND CA.CS$9ATYP = 2 
			AND CA.CSDTAI = ConsuCatCode 
			AND SUBSTRING(UDC.DRKY, 10 - CodeLength + 1, CodeLength) = CA.CSKY;


		/* Customer Number */
		INSERT INTO SESSION.TMP_TABLE(CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
		SELECT 
			CA.CS$9CLGID	AS CatalogId,
			CA.CSUKID		AS AssignmentId,
			CA.CS$9ATYP		AS AssignmentType,
			CA.CSDTAI		AS CategoryCode,
			CAST(CA.CS$9AN8 AS VARGRAPHIC(15) CCSID 13488) AS AssignmentValue,
			CUST.ABALPH		AS Description
		FROM [SCDATA].FQ67414 CA				/* Catalog Assignments */
		INNER JOIN [SCDATA].FQ67412 A
			ON A.CA$9CLGID = CA.CS$9CLGID
		LEFT OUTER JOIN [SCDATA].F0101 CUST	/* Customer Table */
			ON CUST.ABAN8 = CA.CS$9AN8			   		
 		WHERE
 			A.CA$9INID = StoreId
			AND CA.CS$9ATYP = 3;


		/* Consumer Number */
		INSERT INTO SESSION.TMP_TABLE(CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
		SELECT 
			CA.CS$9CLGID	AS CatalogId,
			CA.CSUKID		AS AssignmentId,
			CA.CS$9ATYP		AS AssignmentType,
			CA.CSDTAI		AS CategoryCode,
			CAST(CA.CS$9AN8 AS VARGRAPHIC(15) CCSID 13488) AS AssignmentValue,
			CONS.PRALPH		AS Description
		FROM [SCDATA].FQ67414 CA					/* Catalog Assignments */
		INNER JOIN [SCDATA].FQ67412 A
			ON A.CA$9CLGID = CA.CS$9CLGID
		LEFT OUTER JOIN [SCDATA].FQ670302 CONS	    /* Consumer Table */
			ON CONS.PR$9AN8 = CA.CS$9AN8			   		
 		WHERE
 			A.CA$9INID = StoreId 
			AND CA.CS$9ATYP = 4;


		/* Web Account Id */
		INSERT INTO SESSION.TMP_TABLE(CatalogId, AssignmentId, AssignmentType, CategoryCode, AssignmentValue, Description)
		SELECT 
			CA.CS$9CLGID	AS CatalogId,
			CA.CSUKID		AS AssignmentId,
			CA.CS$9ATYP		AS AssignmentType,
			CA.CSDTAI		AS CategoryCode,
			CAST(WA.WA$9AN8 AS VARGRAPHIC(15) CCSID 13488) || N'-' || CAST(WA.WAIDLN AS VARGRAPHIC(8) CCSID 13488)	AS AssignmentValue,
			WA.WAEMAL		AS Description
		FROM [SCDATA].FQ67414 CA				/* Catalog Assignments */
		INNER JOIN [SCDATA].FQ67412 A
			ON A.CA$9CLGID = CA.CS$9CLGID
		LEFT OUTER JOIN [SCDATA].FQ67101 WA	/* Web Account Table */
			ON WA.WA$9WAN8 = CA.CS$9WAN8			   		
 		WHERE
 			A.CA$9INID = StoreId 
			AND CA.CS$9ATYP = 5;

		
		SET RowStart = ((PageSize * PageIndex) - PageSize + 1);
		SET RowEnd = (PageIndex * PageSize);

		/* Retrieve Catalog assignments by Store Id */
		OPEN TEMP_CURSOR1;
	END;
END;

-- #desc					Get Catalog Category Node List
-- #bl_class				Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param StoreId			Store Id
-- #param CatalogNodesXML	Catalog Nodes XML	<catalogs><catalog><catalogId><![CDATA[ABC]]></catalogId><nodeId><![CDATA[0]]></nodeId></catalog></catalogs>

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigraCatalogNodeList
(
	IN StoreId			GRAPHIC(3) CCSID 13488,
	IN CatalogNodesXML	XML
)
DYNAMIC RESULT SETS 2
LANGUAGE SQL
SPECIFIC [SCLIBRARY].ECO_GetMigraCatalogNodeList
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
BEGIN

	DECLARE GLOBAL TEMPORARY TABLE SESSION.CatalogNodes 
	(
		CatalogId	GRAPHIC(3) CCSID 13488,
		NodeId		DECIMAL(15,0)
	)WITH REPLACE ON COMMIT PRESERVE ROWS NOT LOGGED ;

	BEGIN

		/* Catalog Category Nodes */
		DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
		/* Catalogs */
		SELECT 
			B.CA$9CLGID		AS CatalogId,
			0				AS NodeId,
			0				AS ParentKeyId,
			B.CASEQ			AS SequenceNumber,
			B.CAMCU			AS MCU,
			B.CA$9CCFU		AS MCUBehavior,
			N''				AS AttributeGroup,
			TRIM(D.CFDL01) || ' ' ||
			TRIM(D.CFDL02) || ' ' ||
			TRIM(D.CFDL03) || ' ' ||
			TRIM(D.CFDL04) || ' ' ||
			TRIM(D.CFDL05) || ' ' ||
			TRIM(D.CFDL06) || ' ' ||
			TRIM(D.CFDL07) || ' ' ||
			TRIM(D.CFDL08) || ' ' ||
			TRIM(D.CFDL09) || ' ' ||
			TRIM(D.CFDL10)	AS Keywords,
			D.CFPGTX		AS MetaTitle,
			D.CFCOMMENTS	AS MetaDescription,
			D.CF$9CLFAM		AS FamilyContentId,
			D.CFDSC1		AS ContentTitle,
			D.CF$9HTML		AS HtmlContent
		FROM 
			[SCDATA].FQ67412 B
		INNER JOIN  SESSION.CatalogNodes X
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
			A.CD$9CLGID		AS CatalogId,
			A.CDUKID		AS NodeId,
			A.CD$9PKID		AS ParentKeyId,
			A.CDSEQ			AS SequenceNumber,
			B.CAMCU			AS MCU,
			B.CA$9CCFU		AS MCUBehavior,
			A.CDTMPI		AS AttributeGroup,
			TRIM(D.CFDL01) || ' ' ||
			TRIM(D.CFDL02) || ' ' ||
			TRIM(D.CFDL03) || ' ' ||
			TRIM(D.CFDL04) || ' ' ||
			TRIM(D.CFDL05) || ' ' ||
			TRIM(D.CFDL06) || ' ' ||
			TRIM(D.CFDL07) || ' ' ||
			TRIM(D.CFDL08) || ' ' ||
			TRIM(D.CFDL09) || ' ' ||
			TRIM(D.CFDL10)	AS Keywords,
			D.CFPGTX		AS MetaTitle,
			D.CFCOMMENTS	AS MetaDescription,
			D.CF$9CLFAM		AS FamilyContentId,
			D.CFDSC1		AS ContentTitle,
			D.CF$9HTML		AS HtmlContent
		FROM
			[SCDATA].FQ67413 A
		INNER JOIN [SCDATA].FQ67412 B
			ON B.CA$9CLGID = A.CD$9CLGID
		INNER JOIN SESSION.CatalogNodes X
			ON X.CatalogId = A.CD$9CLGID
			AND X.NodeId = A.CDUKID
		LEFT OUTER JOIN [SCDATA].FQ67418 C
			ON C.FD$9CLGID = A.CD$9CLGID
			AND C.FDUKID = A.CDUKID
		LEFT OUTER JOIN [SCDATA].FQ67419 D
			ON D.CF$9CLFAM = C.FD$9CLFAM
			AND D.CF$9DS = 0
			AND D.CF$9INID = StoreId
		WHERE B.CA$9INID = StoreId
		FOR FETCH ONLY;
	
		/* Content and Nodes Languages */
		DECLARE TEMP_CURSOR2 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
		/* Catalogs */
		SELECT 
			B.CA$9CLGID		AS CatalogId,
			0				AS NodeId,
			D.CFPGTX		AS MetaTitle,
			D.CFCOMMENTS	AS MetaDescription,
			TRIM(D.CFDL01) || ' ' ||
			TRIM(D.CFDL02) || ' ' ||
			TRIM(D.CFDL03) || ' ' ||
			TRIM(D.CFDL04) || ' ' ||
			TRIM(D.CFDL05) || ' ' ||
			TRIM(D.CFDL06) || ' ' ||
			TRIM(D.CFDL07) || ' ' ||
			TRIM(D.CFDL08) || ' ' ||
			TRIM(D.CFDL09) || ' ' ||
			TRIM(D.CFDL10) AS Keywords,
			D.CF$9CLFAM		AS FamilyContentId,
			D.CFDSC1		AS ContentTitle,
			D.CF$9HTML		AS HtmlContent,
			D.CFLNGP		AS LanguageId
		FROM 
			[SCDATA].FQ67412 B
		INNER JOIN SESSION.CatalogNodes X
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
			A.CD$9CLGID		AS CatalogID,
			A.CDUKID		AS NodeId,
			D.CFPGTX		AS MetaTitle,
			D.CFCOMMENTS	AS MetaDescription,
			TRIM(D.CFDL01) || ' ' ||
			TRIM(D.CFDL02) || ' ' ||
			TRIM(D.CFDL03) || ' ' ||
			TRIM(D.CFDL04) || ' ' ||
			TRIM(D.CFDL05) || ' ' ||
			TRIM(D.CFDL06) || ' ' ||
			TRIM(D.CFDL07) || ' ' ||
			TRIM(D.CFDL08) || ' ' ||
			TRIM(D.CFDL09) || ' ' ||
			TRIM(D.CFDL10) AS Keywords,
			D.CF$9CLFAM		AS FamilyContentId,
			D.CFDSC1		AS ContentTitle,
			D.CF$9HTML		AS HtmlContent,
			D.CFLNGP		AS LanguageId
		FROM
			[SCDATA].FQ67413 A
		INNER JOIN [SCDATA].FQ67412 B
			ON B.CA$9CLGID = A.CD$9CLGID
		INNER JOIN SESSION.CatalogNodes X
			ON X.CatalogId = A.CD$9CLGID
			AND X.NodeId = A.CDUKID
		INNER JOIN [SCDATA].FQ67418 C
			ON C.FD$9CLGID = A.CD$9CLGID
			AND C.FDUKID = A.CDUKID
		INNER JOIN [SCDATA].FQ67419L D
			ON D.CF$9CLFAM = FD$9CLFAM
			AND D.CF$9DS = 0
			AND D.CF$9INID = StoreId
		WHERE B.CA$9INID = StoreId
		FOR FETCH ONLY;

		/* Gets Catalog nodes ids and Inserts into SESSION.CatalogNodes  */
		INSERT INTO SESSION.CatalogNodes (CatalogId, NodeId)
		SELECT 
			nodes.catalogId,
			nodes.nodeid
		FROM XMLTABLE ('$d/catalogs/catalog'
			PASSING CatalogNodesXML AS "d"
			COLUMNS CATALOGID GRAPHIC(3) CCSID 13488 PATH 'catalogId',
			NODEID DECIMAL(15,0) PATH 'nodeId') AS nodes;
	

		OPEN TEMP_CURSOR1;/* Gets  Catalogs and Nodes*/
		OPEN TEMP_CURSOR2;/* Gets  Catalogs and Nodes Lang*/

	END;
END;

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
	IN StoreId					GRAPHIC(3) CCSID 13488,
	IN ProductNumbersXML		XML,
	IN RetrieveAttributes		INT,
	IN RetrieveContentSections	INT
)
DYNAMIC RESULT SETS 5 
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].ECO_GetMigrationProductList 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
BEGIN

	DECLARE CurrentJulianDate NUMERIC(6, 0);
	DECLARE DefaultLanguage GRAPHIC(2) CCSID 13488;
	DECLARE DefLangStoreId GRAPHIC(3) CCSID 13488;

	DECLARE GLOBAL TEMPORARY TABLE SESSION.TMP_STOREPRODUCTS
	(
		ShortItemNumber	NUMERIC(8,0), 
		LongItemNumber	GRAPHIC(25) CCSID 13488,
		TBLStoreId		GRAPHIC(3) CCSID 13488,
		Description		GRAPHIC(91) CCSID 13488, 
		HtmlContent		DBCLOB(30000) CCSID 13488,
		ExternalUrl		VARGRAPHIC(256) CCSID 13488,
		Keywords		GRAPHIC(310) CCSID 13488,
		MetaTitle		VARGRAPHIC(255) CCSID 13488,
		MetaDescription	VARGRAPHIC(256) CCSID 13488,
		ScType			GRAPHIC(1) CCSID 13488,
		BranchPlant		DBCLOB(30000) CCSID 13488,
		HasWebContent	INT
	)WITH REPLACE ON COMMIT PRESERVE ROWS NOT LOGGED;
	
	SET CurrentJulianDate = [SCLIBRARY].CMM_GetCurrentJulianDate (CURRENT DATE);
	SET DefLangStoreId = StoreId;

	CALL [SCLIBRARY].CMM_GetConstantValue('DEFLANGPRF', DefLangStoreId, DefaultLanguage);
	

	BEGIN
		/* Products */
		DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
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
		FROM SESSION.TMP_STOREPRODUCTS A
		FOR FETCH ONLY; 
	
		/* Product languages */
		DECLARE TEMP_CURSOR2 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
		SELECT  
			A.CLITM			AS ShortItemNumber,
			B.LongItemNumber,
			A.CLLNGP		AS LanguageId, 
			TRIM(TRIM(A.CLDSC1) || ' ' || TRIM(A.CLDSC2) || ' ' || A.CLDSC3) AS Description,
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
			TRIM(A.CLDL10)	AS Keywords,
			A.CLPGTX		AS MetaTitle,
			A.CLCOMMENTS	AS MetaDescription,
			B.HasWebContent
		FROM 
			[SCDATA].FQ67410L A
		INNER JOIN SESSION.TMP_STOREPRODUCTS B
			ON A.CLITM = B.ShortItemNumber
			AND A.CL$9INID = B.TBLStoreId
		WHERE A.CL$9DS = 0
			AND A.CLLNGP <> DefaultLanguage
		FOR FETCH ONLY;
	
		/* Attributes */
		DECLARE TEMP_CURSOR3 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
		SELECT 			
			A.IAITM		AS ShortItemNumber,
			A.IA$9AID	AS AttributeId,
			(CASE WHEN A.IAUKID = 0 THEN A.IA$9VAL ELSE CAST(A.IAUKID AS VARGRAPHIC(25) CCSID 13488) END) AS AttributeValue,
			COALESCE(D.AVSEQ, 0) AS ValueSequenceNumber,
			C.AT$9ADRV	AS AttributeType
		FROM 
			[SCDATA].FQ674123 A
		INNER JOIN SESSION.TMP_STOREPRODUCTS B
			ON B.ShortItemNumber = A.IAITM
		INNER JOIN [SCDATA].FQ67420 C
			ON C.AT$9AID = A.IA$9AID
		LEFT OUTER JOIN [SCDATA].FQ67421 D
			ON D.AV$9AID = A.IA$9AID
			AND D.AVUKID = IAUKID
		FOR FETCH ONLY;
	
		/* Content Sections */
		DECLARE TEMP_CURSOR4 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
		SELECT 
			A.CDITM		AS ShortItemNumber,
			A.CDUKID	AS UniqueKeyID,
			A.CD$9PTL	AS Title,
			A.CD$9HTML	AS HtmlContent,
			A.CDSEQ		AS SequenceNumber,
			A.CDEFFF	AS EffectiveFromDate,
			A.CDEFFT	AS EffectiveThruDate
		FROM [SCDATA].FQ67411 A
		INNER JOIN SESSION.TMP_STOREPRODUCTS B
			ON B.ShortItemNumber = A.CDITM
			AND B.TBLStoreId = A.CD$9INID
		WHERE A.CD$9DS = 0
			AND (CurrentJulianDate BETWEEN A.CDEFFF AND A.CDEFFT OR CurrentJulianDate < A.CDEFFF)
		FOR FETCH ONLY;
	
		/* Content Sections Languages */
		DECLARE TEMP_CURSOR5 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
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
		INNER JOIN SESSION.TMP_STOREPRODUCTS B
			ON B.ShortItemNumber = A.CLITM
			AND B.TBLStoreId = A.CL$9INID
		WHERE A.CL$9DS = 0
			AND (CurrentJulianDate BETWEEN C.CDEFFF AND C.CDEFFT OR CurrentJulianDate < C.CDEFFF)
			AND A.CLLNGP <> DefaultLanguage
		FOR FETCH ONLY;

		INSERT INTO SESSION.TMP_STOREPRODUCTS
		(
			ShortItemNumber,
			LongItemNumber,
			TBLStoreId,
			Description,
			HtmlContent,
			ExternalUrl,
			Keywords,
			MetaTitle,
			MetaDescription,
			ScType,
			BranchPlant,
			HasWebContent
		)
		WITH CTE AS (
			SELECT
				B.IMITM		AS ShortItemNumber, 
				B.IMLITM	AS LongItemNumber,
				COALESCE(A.CH$9INID, N'***')	AS TBLStoreId,
				TRIM(TRIM(COALESCE(A.CHDSC1, B.IMDSC1)) || ' ' || TRIM(COALESCE(A.CHDSC2, B.IMDSC2)) || ' ' || COALESCE(A.CHDSC3, '')) AS Description,
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
				COALESCE(SCLIBRARY.INV_GetItemBranchPlantStrFnc( StoreId, B.IMITM), N' ')	AS BranchPlant,
				CASE WHEN A.CHITM IS NULL THEN 0 ELSE 1 END HasWebContent,
				ROW_NUMBER()OVER(PARTITION BY B.IMITM ORDER BY A.CH$9INID DESC)	AS Inst
			FROM  
				[SCDATA].F4101 B
			INNER JOIN XMLTABLE('$d/products/product' PASSING ProductNumbersXML AS "d" 
				COLUMNS shortProductNumber NUMERIC(8,0) PATH 'text()') AS X
				ON X.shortProductNumber = B.IMITM
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
		OPEN TEMP_CURSOR1;
	
		/* Product languages */
		OPEN TEMP_CURSOR2;
		
		/* Attributes */
		IF (RetrieveAttributes = 1) THEN
			OPEN TEMP_CURSOR3;
		END IF;
	
		/* Content Sections */
		IF (RetrieveContentSections = 1) THEN
			/* Content Sections */
			OPEN TEMP_CURSOR4;
	
			/* Content Sections Languages */
			OPEN TEMP_CURSOR5;
		END IF;
	END;
END;
-- #desc						Get Settings by Store Id 
-- #bl_class					Premier.eCommerce.MigrationCommand.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id
-- #param SettingsXML			List of settings <settings><setting><settingName><![CDATA[CTLGLISTIN]]></settingName><newSettingName><![CDATA[CATALOG_PROVIDER]]></newSettingName></setting></settings>

CREATE OR REPLACE PROCEDURE [SCLIBRARY].ECO_GetMigrationSettingList
(
	IN StoreId			GRAPHIC(3) CCSID 13488,
	IN SettingsXML		XML
)
DYNAMIC RESULT SETS 1
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].ECO_GetMigrationSettingList 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
BEGIN


	DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
	WITH CTE AS (
		SELECT  
			A.CN$9CNST  Setting,
			A.CN$9VAL	SettingValue,
			S.NewSettingName,
			ROW_NUMBER() OVER(PARTITION BY A.CN$9CNST ORDER BY A.CN$9INID DESC) INST
		FROM  
			[SCDATA].FQ670004 A
		INNER JOIN [SCDATA].FQ670003 B 
			ON A.CN$9CNST = B.CN$9CNST
		INNER JOIN XMLTABLE ('$d/settings/setting'
			PASSING SettingsXML AS "d"
			COLUMNS SettingName GRAPHIC(10) CCSID 13488 PATH 'settingName',
			NewSettingName GRAPHIC(30) CCSID 13488 PATH 'newSettingName') AS S
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
	WHERE INST = 1
	FOR FETCH ONLY;


	/* Get Settings */
	OPEN TEMP_CURSOR1;
END;

-- #desc						Get the row count of Store related tables.
-- #bl_class					Premier.eCommerce.MigrationStatInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param StoreId				Store Id

CREATE OR REPLACE Procedure [SCLIBRARY].ECO_GetMigrationStatInfo
(
	IN StoreId					GRAPHIC(3) CCSID 13488,
	OUT ProductContentSections	INT,
	OUT "Attributes" 			INT,
	OUT CatalogAssignments		INT,			
	OUT CatalogContentSections 	INT,
	OUT BranchPlants 			INT,
	OUT AttributeGroups			INT
)
DYNAMIC RESULT SETS 1 
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].ECO_GetMigrationStatInfo 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
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
	SET "Attributes" = (SELECT COUNT(1) FROM [SCDATA].FQ67420);

	/* Catalog Assignments By Store */
	SET CatalogAssignments = (SELECT COUNT(1) FROM  [SCDATA].FQ67414 A INNER JOIN [SCDATA].FQ67412 B ON B.CA$9CLGID = A.CS$9CLGID WHERE B.CA$9INID = StoreId);
	
	/* Catalog Content Sections By Store */
	SET CatalogContentSections = (SELECT COUNT(1) FROM [SCDATA].FQ67419 WHERE CF$9INID = StoreId);
	
	/* BranchPlants By Store */
	SET BranchPlants = (SELECT COUNT(1) FROM [SCDATA].FQ679910 B WHERE B.BI$9INID = StoreId);
	
	/* AttributeGroups */
	SET AttributeGroups = (SELECT COUNT(1) FROM [SCDATA].FQ67422A);

END;
