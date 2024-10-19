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
	TransactionsKey	IN  NCHAR,
	AddressNumber	IN	NUMBER,
	OrderKey		IN	NCHAR
)
AS
BEGIN
	UPDATE [SCDATA].FQ67AT06 
	SET AD$9ATDOCCD = OrderKey
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

END;
  /

-- #desc						Get AvaTax ECM Company
-- #bl_class					Premier.Commerce.AvaTaxECMIntegration.cs
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @Company		        Company

CREATE OR REPLACE PROCEDURE [SCLIBRARY].COM_GetAvaTaxECMCompanyCode
(
	Company IN NVARCHAR2,
	ResultData1 OUT GLOBALPKG.refcursor
)

AS

BEGIN
OPEN ResultData1 FOR
	SELECT	
		AC$9ATCOCD AS AvaTaxCompany
	FROM 
		[SCDATA].FQ67AT02
	WHERE          
		-- Company filter
		TRIM(ACCO) = TRIM(Company);

END;



  /
-- #desc					Get Exemption Certificate List
-- #bl_class				Premier.Commerce.AvaTaxECMCustomerCertList.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param CustomerNumber	Customer Number
-- #param AvaTaxCompany	AvaTax Company
-- #param RegionFilter		Region
-- #param StatusFilter		Status
-- #param ReturnRegionList return the region list
-- #param SortBy			Column to filter by
-- #param SortDir			Direction to filter (A = Ascendant, D = Descendant)
-- #param PageIndex			Page Index 
-- #param PageSize			Page Size

CREATE OR REPLACE PROCEDURE [SCLIBRARY].COM_GetAvaTaxECMList
(
	CustomerNumber		IN NUMBER,
	AvaTaxCompany		IN NCHAR,
	RegionFilter		IN NCHAR,
	StatusFilter		IN NCHAR,
	ReturnRegionList	IN INT,
	SortBy				IN NCHAR,
	SortDir				IN NCHAR,
	PageIndex			IN INT,
    PageSize			IN INT,
	ResultData1 OUT GLOBALPKG.refcursor,
	ResultData2 OUT GLOBALPKG.refcursor
)
AS
	/* Dynamic */
	SQL_DYNAMIC			VARCHAR2(4000);
	WHERE_DYNAMIC		NVARCHAR2(1000) := N' ';
	SORT_DYNAMIC		NVARCHAR2(60);
	SORTDIR_DYNAMIC		NVARCHAR2(5);

	/* Paging */
    RowStart INT := ((PageSize * PageIndex) - PageSize + 1);
    RowEnd INT := (PageIndex * PageSize);

BEGIN

	/* Dynamic sort direction statement */
    SORTDIR_DYNAMIC := CASE SortDir WHEN 'A' THEN ' ASC' WHEN 'D' THEN ' DESC' ELSE '' END;

	/* Dynamic sort statement */
    SORT_DYNAMIC := CASE SortBy
						WHEN 'CertificateId' THEN 'EC$9CRID' || SORTDIR_DYNAMIC || ', UPPER(EC$9ECMRGN) ASC'
						WHEN 'Region' THEN 'UPPER(EC$9ECMRGN)' || SORTDIR_DYNAMIC
						WHEN 'EffectiveDate' THEN 'EC$9ECMCRD' || SORTDIR_DYNAMIC || ', UPPER(EC$9ECMRGN) ASC'
						WHEN 'ExpirationDate' THEN 'EC$9ECMEXD' || SORTDIR_DYNAMIC || ', UPPER(EC$9ECMRGN) ASC'
						WHEN 'ExemptionReason' THEN 'EC$9EXRES' || SORTDIR_DYNAMIC || ', UPPER(EC$9ECMRGN) ASC'
						WHEN 'Status' THEN 'UPPER(EC$9ECMSTS)' || SORTDIR_DYNAMIC || ', UPPER(EC$9ECMRGN) ASC'
						ELSE 'EC$9CRID ASC, UPPER(EC$9ECMRGN) ASC' 
					END;

	IF (RegionFilter <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND EC$9ECMRGN LIKE N''%'' || :RegionFilter || ''%'' ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :RegionFilter = N''*'') ';
	END IF;

	IF (StatusFilter <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND EC$9ECMSTS = :StatusFilter ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :StatusFilter = N''*'') ';
	END IF;

	SQL_DYNAMIC := N' 
		WITH ECM AS (
		SELECT			
			EC$9CRID	AS CertificateId, 
			EC$9ATCUSCD	AS CustomerNumber,
			EC$9ECMRGN	AS Region,
			EC$9ECMCRD	AS EffectiveDate, 
			EC$9ECMEXD	AS ExpirationDate,
			EC$9EXRES	AS ExemptionReason,
			EC$9ECMSTS	AS Status,
			ROW_NUMBER() OVER (ORDER BY '|| SORT_DYNAMIC ||') AS RNUM 
		FROM  
			[SCDATA].FQ67AT17	
		WHERE EC$9ATCUSCD = :CustomerNumber
			AND EC$9ATCOCD = :AvaTaxCompany
		'|| WHERE_DYNAMIC ||'
		) 
		SELECT CertificateId, CustomerNumber, Region, EffectiveDate, ExpirationDate,
			ExemptionReason, Status, (SELECT COUNT(1) FROM ECM) AS TotalRowCount
		FROM ECM
		WHERE ((:PageIndex = 0 OR :PageSize = 0) OR (RNUM BETWEEN :RowStart AND :RowEnd)) ';

    OPEN ResultData1 FOR SQL_DYNAMIC USING CustomerNumber, AvaTaxCompany, RegionFilter, StatusFilter, 
		PageIndex, PageSize, RowStart, RowEnd;

	IF(ReturnRegionList = 1) THEN  
		OPEN ResultData2 FOR
		SELECT DISTINCT
			EC$9ECMRGN	AS Region			
		FROM [SCDATA].FQ67AT17 
		WHERE EC$9ATCUSCD = CustomerNumber
			AND EC$9ATCOCD = AvaTaxCompany;
	END IF;
END;
  /
