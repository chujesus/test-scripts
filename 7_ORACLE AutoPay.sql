
-- #desc							Get Invoice Auto Pay Rule List
-- #bl_class						Premier.Commerce.InvoiceAutoPayRuleList.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param StoreId					Store Id
-- #param CustomerNumber			Customer Number
-- #param RuleName					Rule Name
-- #param RuleId					Rule Id
-- #param CurrencyCode				Currency Code
-- #param StartDateFrom				Start Date From
-- #param StartDateTo				Start Date To
-- #param ExpirationDateFrom		Expiration Date From
-- #param ExpirationDateTo			Expiration Date To
-- #param Status					Status
-- #param SortBy					Sort By Column name
-- #param SortDir					Sort Dir ASC / DESC
-- #param PageIndex					Page Index
-- #param PageSize					Page Size
							  
CREATE OR REPLACE PROCEDURE [SCLIBRARY].COM_GetInvAutoPayRuleList
(
	StoreId				IN NCHAR,
	CustomerNumber		IN NUMBER,
	RuleName		IN NCHAR,
	RuleId				IN NUMBER,
	StartDateFrom	IN NUMBER,
	StartDateTo		IN NUMBER,
	ExpirationDateFrom		IN NUMBER,
	ExpirationDateTo		IN NUMBER,
	CurrencyCode		IN NCHAR,
	Status				IN NUMBER,
	SortBy				IN VARCHAR2,
	SortDir				IN VARCHAR2,
	PageIndex			IN INT,
    PageSize			IN INT,
    ResultData1 OUT GLOBALPKG.refcursor
)
AS
	/* Dynamic */
	SQL_DYNAMIC				VARCHAR2(8000);
	WHERE_DYNAMIC			NVARCHAR2(1000) := ' ';
	SORT_DYNAMIC			NVARCHAR2(60);
	SORTDIR_DYNAMIC			NVARCHAR2(5);
	INNER_DYNAMIC			NVARCHAR2(1000) := ' ';

	/* Document Restrictions for Auto Pay */
	ArRestrict	 NVARCHAR2(1);
	ArINID		 NCHAR(3) := StoreId;
	ArConstant   NCHAR(10):= 'AUTPAY_DOC';
	
	/* Company Restrictions for Auto Pay */	
	CoRestrict	 NVARCHAR2(1);
	CoINID		 NCHAR(3) := StoreId;
	CoConstant   NCHAR(10):= 'INSCOMPANY';

	--/*-----------------------------------------------------------------------------*/
	Today NUMBER(6,0) := [SCLIBRARY].CMM_GetCurrentJulianDate(SYSDATE);

	/* Paging */
    RowStart INT := ((PageSize * PageIndex) - PageSize + 1);
    
    RowEnd INT := (PageIndex * PageSize);
BEGIN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE [SCLIBRARY].COM_GETINVAUTOPAYRULELIST_A';	
	EXECUTE IMMEDIATE 'TRUNCATE TABLE [SCLIBRARY].COM_GETINVAUTOPAYRULELIST_B';	

	[SCLIBRARY].CMM_GetConstantValue(ArConstant, ArINID, ArRestrict);
	[SCLIBRARY].CMM_GetConstantValue(CoConstant, CoINID, CoRestrict);

	/* Dynamic sort direction statement */
    SORTDIR_DYNAMIC := CASE SortDir WHEN 'A' THEN ' ASC' WHEN 'D' THEN ' DESC' ELSE '' END;

	/* Dynamic sort statement */
    SORT_DYNAMIC := CASE SortBy
		WHEN 'RuleId' THEN 'RuleId ' || SORTDIR_DYNAMIC || ', StartDate DESC'
		WHEN 'RuleName' THEN 'RuleName ' || SORTDIR_DYNAMIC || ', RuleId DESC'
		WHEN 'Currency' THEN 'Currency ' || SORTDIR_DYNAMIC || ', RuleId DESC'
		WHEN 'PaymentType' THEN 'PaymentType ' || SORTDIR_DYNAMIC || ', RuleId DESC'
		WHEN 'PaymentDate' THEN 'PaymentDate ' || SORTDIR_DYNAMIC || ', RuleId DESC'
		WHEN 'StartDate' THEN 'StartDate ' || SORTDIR_DYNAMIC || ', RuleId DESC'
		WHEN 'Duration' THEN 'Duration ' || SORTDIR_DYNAMIC || ', RuleId DESC'
		ELSE 'StartDate ASC, RuleId DESC'
	END;

	/* Dynamic query conditions */ 
	IF (CustomerNumber IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'A.AR$9AN8 = :CustomerNumber ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'(1 = 1 OR :CustomerNumber IS NULL) ';
	END IF;

	IF (RuleName <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.ARDSC1 LIKE ''%'' || :RuleName || ''%''';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :RuleName = ''*'') ';
	END IF;

	IF (RuleId IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AR$9UKID = :RuleId ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :RuleId IS NULL) ';
	END IF;

	IF (StartDateFrom IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AREFFF >= :StartDateFrom ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :StartDateFrom IS NULL) ';
	END IF;

	IF (StartDateTo IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AREFFF <= :StartDateTo ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :StartDateTo IS NULL) ';
	END IF;

	IF (ExpirationDateFrom IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AR$9APAYSD >= :ExpirationDateFrom ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'  AND (1 = 1 OR :ExpirationDateFrom IS NULL) ';
	END IF;

	IF (ExpirationDateTo IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AR$9APAYSD <= :ExpirationDateTo ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'  AND (1 = 1 OR :ExpirationDateTo IS NULL) ';
	END IF;

	IF (CurrencyCode <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.ARCRCD = :CurrencyCode ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :CurrencyCode = ''*'') ';
	END IF;

	/*Add parameter STATUS when it is On Hold or Active*/
	IF(Status > 1)
	THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :Status IS NULL) ';/*STATUS*/
	END IF;
		
	IF (Status <> 4) 
	THEN
		IF (Status = 2) /*Expired*/
		THEN
			WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AR$9APAYSD <= ' || Today || N' AND A.AR$9APAYEX = 2 ';
		ELSE
			WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND NOT (A.AR$9APAYSD <= ' || Today || N' AND A.AR$9APAYEX = 2) ';
			IF (Status = 3) /*Future*/
			THEN
				WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AREFFF > ' || Today || N' ';
			ELSE
				WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AR$9STS = :Status AND A.AREFFF <= ' || Today || N' ';/*STATUS*/
				IF (Status = 1) /*On Hold*/
				THEN
					WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND A.AREFFF < A.ARRDJ ';
				END IF;
			END IF;
		END	IF;
	END IF;

	
	/* Valid RuleId by Company Restrictions */
	INSERT INTO [SCLIBRARY].COM_GETINVAUTOPAYRULELIST_A
	SELECT DISTINCT 
		RC.RC$9UKID AS RULEID
	FROM (
		SELECT  
			C.RC$9AN8,
			C.RC$9UKID,
			C.RCCO
		FROM [SCDATA].FQ670316 C 
		WHERE C.RC$9AN8 = CustomerNumber) RC 
	INNER JOIN (
		SELECT 
			CR.CI$9INID,
			CR.CICO 
		FROM [SCDATA].FQ679912 CR 
		WHERE CR.CI$9INID = CoINID) REC 
	ON REC.CICO = RC.RCCO;

	/* Valid RuleId by Document Restrictions */
	INSERT INTO [SCLIBRARY].COM_GETINVAUTOPAYRULELIST_B
	SELECT DISTINCT
		RT.RI$9UKID AS RULEID
	FROM (
		SELECT
			T.RI$9AN8, 
			T.RI$9UKID, 
			T.RIDCT
		FROM [SCDATA].FQ670317 T 
		WHERE T.RI$9AN8 = CustomerNumber) RT 
	INNER JOIN (
		SELECT
			IT.DR$9INID,
			IT.DR$9CNST,
			IT.DRKY
		FROM [SCDATA].FQ67008 IT 
		WHERE IT.DR$9INID = ArINID AND IT.DR$9CNST = ArConstant) RET 
	ON RET.DRKY = RT.RIDCT;

	IF (CoRestrict = N'L') 
	THEN
		INNER_DYNAMIC := ' INNER JOIN [SCLIBRARY].COM_GETINVAUTOPAYRULELIST_A R ON PAGING.RuleId = R.RULEID ';
	END IF;

	IF (ArRestrict = N'1')
	THEN
		INNER_DYNAMIC := INNER_DYNAMIC || ' INNER JOIN [SCLIBRARY].COM_GETINVAUTOPAYRULELIST_B RR ON PAGING.RuleId = RR.RULEID ';
	END IF;

	/* Dynamic query */
	SQL_DYNAMIC := 
	N'WITH PAGING AS 
	(
		SELECT AutoPayRules.*, ROW_NUMBER() OVER (ORDER BY ' || SORT_DYNAMIC || ') AS RNUM, COUNT(1) OVER () AS TotalRowCount FROM 
		(
			SELECT	

			A.AR$9AN8		AS		CustomerNumber,
			A.AR$9TYP		AS		Type,
			A.AR$9UKID		AS		RuleId,
			A.ARDSC1		AS		RuleName,
			A.AR$9STS		AS		Status,
			A.ARRDJ			AS		ReleaseDate,
			A.ARRYIN		AS		PaymentType,
			A.AR$9APIBO		AS		PaymentDate,
			A.AR$9APIBOV	AS		PaymentDateValue,
			A.ARMCU			AS		BranchPlant,
			A.ARCRCD		AS		Currency,   
			A.ARSEQ			AS		CCSequence,
			A.ARIDLN		AS		CCLineId,   
			A.ARUKID		AS		BankAccountUniqueId,
			A.AR$9APAYA		AS		PaymentAmount,
			A.AR$9APAYAV	AS		PaymentAmountValue,
			A.AREFFF		AS		StartDate,
			A.AR$9APAYEX	AS		Duration,
			A.AR$9APAYSD	AS		ExpirationDate, 
			A.AR$9APAYNP	AS		NumberOfPayments	 
			FROM 	[SCDATA].FQ670315 A				/*AUTO PAY RULES*/
			WHERE ' || WHERE_DYNAMIC || N'
		) AutoPayRules 
	)
	SELECT 
		PAGING.CustomerNumber, 
		PAGING.Type, 
		PAGING.RuleId, 
		PAGING.RuleName, 
		PAGING.Status, 
		PAGING.ReleaseDate, 
		PAGING.PaymentType, 
		PAGING.PaymentDate, 
		PAGING.PaymentDateValue, 
		PAGING.BranchPlant, 
		PAGING.Currency, 
		PAGING.CCSequence, 
		PAGING.CCLineId, 
		PAGING.BankAccountUniqueId, 
		PAGING.PaymentAmount, 
		PAGING.PaymentAmountValue, 
		PAGING.StartDate, 
		PAGING.Duration, 
		PAGING.ExpirationDate, 
		PAGING.NumberOfPayments, 
		PAGING.TotalRowCount
    FROM PAGING
	' || INNER_DYNAMIC || N'
	WHERE 
		((:PageIndex = 0 OR :PageSize = 0) OR (RNUM BETWEEN :RowStart AND :RowEnd)) ';
	
	OPEN ResultData1 FOR SQL_DYNAMIC USING CustomerNumber, RuleName, RuleId, StartDateFrom,
											StartDateTo, ExpirationDateFrom, ExpirationDateTo, CurrencyCode, Status,
											PageIndex, PageSize, RowStart, RowEnd;
	
END;

  /
