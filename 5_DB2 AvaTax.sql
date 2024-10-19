--DROP SPECIFIC PROCEDURE [SCLIBRARY].COM_ExcUpdAvaTaxOrderNumber;

-- #desc						Execute Update Avatax Order Number
-- #bl_class					Premier.Commerce.AvaTaxIntegration.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- param TransactionsKey		Transactions Key
-- param AddressNumber			Address Number
-- param OrderNumber			Order Number
-- param OrderKey				Order Key

CREATE OR REPLACE PROCEDURE [SCLIBRARY].COM_ExcUpdAvaTaxOrderNumber
(
	TransactionsKey		VARCHAR(22),
	AddressNumber		NUMERIC(15,0),
	OrderKey			VARCHAR(22)
)
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].COM_ExcUpdAvaTaxOrderNumber
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT
BEGIN 

	UPDATE [SCDATA].FQ67AT06 DETAIL 
	SET DETAIL.AD$9ATDOCCD = OrderKey
    WHERE EXISTS(
		SELECT * FROM [SCDATA].FQ67AT05 HEADER
		WHERE AD$9ATDOCCD = AH$9ATDOCCD AND
		ADTDAY = AHTDAY AND
		ADUSER = AHUSER AND
		ADMKEY = AHMKEY AND
		ADUPMJ =  AHUPMJ AND
		ADTDAY = AHTDAY AND
		ADSEQ = AHSEQ AND
		AH$9ATDOCCD = TransactionsKey AND
		AH$9ATCUSCD = AddressNumber
	);

	UPDATE [SCDATA].FQ67AT05
	SET 
		AH$9ATDOCCD = OrderKey	
	WHERE 
		AH$9ATDOCCD = TransactionsKey AND
		AH$9ATCUSCD = AddressNumber;

END ;
-- #desc						Get AvaTax ECM Company
-- #bl_class					Premier.Commerce.AvaTaxECMIntegration.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @Company		        Company

CREATE OR REPLACE Procedure [SCLIBRARY].COM_GetAvaTaxECMCompanyCode
(
	Company varchar(10)
)

DYNAMIC RESULT SETS 1 
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].COM_GetAvaTaxECMCompanyCode 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
BEGIN 

DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
SELECT	
	AC$9ATCOCD AS AvaTaxCompany
FROM 
	[SCDATA].FQ67AT02
WHERE          
	-- Company filter
    UPPER(RTRIM(ACCO)) = UPPER(RTRIM(Company))
FOR FETCH ONLY;

OPEN TEMP_CURSOR1;

END


 ;
-- #desc					Get Exemption Certificate List
-- #bl_class				Premier.Commerce.AvaTaxECMCustomerCertList.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param CustomerNumber	Customer Number
-- #param AvaTaxCompany	    AvaTax Company
-- #param RegionFilter		Region
-- #param StatusFilter		Status
-- #param ReturnRegionList return the region list
-- #param SortBy			Column to filter by
-- #param SortDir			Direction to filter (A = Ascendant, D = Descendant)
-- #param PageIndex			Page Index 
-- #param PageSize			Page Size


CREATE OR REPLACE Procedure [SCLIBRARY].COM_GetAvaTaxECMList
(
	IN CustomerNumber	NUMERIC(8,0),
	IN AvaTaxCompany	VARGRAPHIC(25) CCSID 13488,
	IN RegionFilter     VARGRAPHIC(30) CCSID 13488,
	IN StatusFilter     VARGRAPHIC(20) CCSID 13488,
	IN ReturnRegionList	INT,
	IN SortBy           VARGRAPHIC(40) CCSID 13488,
	IN SortDir          GRAPHIC(1) CCSID 13488,
	IN PageIndex		INT,
	IN PageSize         INT
)
DYNAMIC RESULT SETS 1 
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].COM_GetAvaTaxECMList
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT

BEGIN

	DECLARE SQL_DYNAMIC		VARGRAPHIC(10000) CCSID 13488;
	DECLARE WHERE_DYNAMIC	VARGRAPHIC(10000) CCSID 13488;
	DECLARE RowStart		INT;
	DECLARE RowEnd			INT;
	DECLARE SORT_DYNAMIC	VARGRAPHIC(60) CCSID 13488;
	DECLARE SORTDIR_DYNAMIC	VARGRAPHIC(20) CCSID 13488;

	SET WHERE_DYNAMIC = N' ';

	/* Paging */ 
	SET RowStart = ((PageSize * PageIndex) - PageSize + 1);
	SET RowEnd = (PageIndex * PageSize);

	BEGIN
		/* CURSOR FOR DYNAMIC SQL */
		DECLARE TEMP_CURSOR1 CURSOR WITH RETURN TO CLIENT FOR V_DYNAMIC;

		DECLARE TEMP_CURSOR2 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
		SELECT DISTINCT
			EC$9ECMRGN	AS Region			
		FROM [SCDATA].FQ67AT17 
		WHERE EC$9ATCUSCD = CustomerNumber
			AND EC$9ATCOCD = AvaTaxCompany;

		/* Dynamic sort direction statement */ 
		SET SORTDIR_DYNAMIC = CASE SortDir WHEN 'A' THEN ' ASC' WHEN 'D' THEN ' DESC' ELSE '' END ; 
  
		/* Dynamic sort statement */ 
		SET SORT_DYNAMIC = CASE SortBy 
								WHEN 'CertificateId' THEN 'EC$9CRID' || SORTDIR_DYNAMIC || ', EC$9ECMRGN ASC'
								WHEN 'Region' THEN 'EC$9ECMRGN' || SORTDIR_DYNAMIC
								WHEN 'EffectiveDate' THEN 'EC$9ECMCRD' || SORTDIR_DYNAMIC || ', EC$9ECMRGN ASC'
								WHEN 'ExpirationDate' THEN 'EC$9ECMEXD' || SORTDIR_DYNAMIC || ', EC$9ECMRGN ASC'
								WHEN 'ExemptionReason' THEN 'EC$9EXRES' || SORTDIR_DYNAMIC || ', EC$9ECMRGN ASC'
								WHEN 'Status' THEN 'EC$9ECMSTS' || SORTDIR_DYNAMIC || ', EC$9ECMRGN ASC'
								ELSE 'EC$9CRID ASC, EC$9ECMRGN ASC'
							END ; 

		IF (RegionFilter <> '*') THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND EC$9ECMRGN LIKE N''%'' || ? || ''%'' ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? = ''*'') ';
		END IF;

		IF (StatusFilter <> '*') THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND EC$9ECMSTS = ? ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? = ''*'') ';
		END IF;

		SET SQL_DYNAMIC = N' WITH ECM AS  (
			SELECT  
				EC$9CRID	AS CertificateId, 
				EC$9ATCUSCD	AS CustomerNumber,
				EC$9ECMRGN	AS Region,
				EC$9ECMCRD	AS EffectiveDate, 
				EC$9ECMEXD	AS ExpirationDate,
				EC$9EXRES	AS ExemptionReason,
				EC$9ECMSTS	AS Status,
				ROW_NUMBER() OVER (ORDER BY '|| SORT_DYNAMIC ||N') AS RNUM
			FROM [SCDATA].FQ67AT17	
			WHERE EC$9ATCUSCD = ?
				AND EC$9ATCOCD = ? 
				'|| WHERE_DYNAMIC ||N'
		)
		SELECT CertificateId, CustomerNumber, Region, EffectiveDate, ExpirationDate, ExemptionReason, Status,
			(SELECT COUNT(1) FROM ECM) AS TotalRowCount 
		FROM ECM 
		WHERE (( ? = 0 OR ? = 0) OR (RNUM BETWEEN ? AND ? )) ';

		PREPARE V_DYNAMIC FROM SQL_DYNAMIC;
		OPEN TEMP_CURSOR1 USING CustomerNumber, AvaTaxCompany, RegionFilter, StatusFilter, 
			PageIndex, PageSize, RowStart, RowEnd;

		IF(ReturnRegionList = 1) THEN
			OPEN TEMP_CURSOR2;	
		END IF;
	END;
END;
