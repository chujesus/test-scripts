-- #desc							Get the Invoice Auto Pay Rule List
-- #bl_class						Premier.Commerce.InvoiceAutoPayRuleList.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param StoreId	Store Id
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
	IN STOREID		VARGRAPHIC(3) CCSID 13488, 
	IN CUSTOMERNUMBER		NUMERIC (8, 0), 
	IN RULENAME			VARGRAPHIC(40) CCSID 13488,  
	IN RULEID		NUMERIC (8, 0), 
	IN STARTDATEFROM		NUMERIC (6, 0), 
	IN STARTDATETO		NUMERIC (6, 0), 
	IN EXPIRATIONDATEFROM			NUMERIC (6, 0), 
	IN EXPIRATIONDATETO			NUMERIC (6, 0), 
	IN CURRENCYCODE			GRAPHIC(3) CCSID 13488, 
	IN STATUS		NUMERIC (8, 0), 
	IN SORTBY				VARGRAPHIC(20) CCSID 13488, 
	IN SORTDIR				VARCHAR(1), 
	IN PAGEINDEX			INT, 
	IN PAGESIZE				INT
)
DYNAMIC RESULT SETS 1
LANGUAGE SQL
SPECIFIC [SCLIBRARY].COM_GetInvAutoPayRuleList
NOT DETERMINISTIC
MODIFIES SQL DATA
CALLED ON NULL INPUT
BEGIN
	/* Define the table to do the filtering and paging */
    DECLARE ROWSTART			INT DEFAULT 0;
    DECLARE ROWEND				INT DEFAULT 0;
    DECLARE SQL_DYNAMIC			VARGRAPHIC(10000) CCSID 13488;
    DECLARE WHERE_DYNAMIC		VARGRAPHIC(10000) CCSID 13488;
    DECLARE SORT_DYNAMIC		VARGRAPHIC(60) CCSID 13488;
    DECLARE SORTDIR_DYNAMIC		VARGRAPHIC(5) CCSID 13488;
    DECLARE INNER_DYNAMIC		VARGRAPHIC(1000) CCSID 13488;
	DECLARE TODAY NUMERIC(6,0) DEFAULT 0;

	/* DYNAMIC SQL Select */
    DECLARE V_DYNAMIC VARGRAPHIC(8000) CCSID 13488;

	/* Document Restrictions for Auto Pay */
    DECLARE ARRESTRIC	GRAPHIC(1) CCSID 13488;
    DECLARE ARINID		GRAPHIC(3) CCSID 13488;
    DECLARE ARCONSTANT	VARGRAPHIC(10) CCSID 13488;
	
	/* Company Restrictions for Auto Pay */	
	DECLARE CORESTRICT	GRAPHIC(1) CCSID 13488;
    DECLARE COINID		GRAPHIC(3) CCSID 13488;
    DECLARE COCONSTANT	VARGRAPHIC(10) CCSID 13488;

	/* Document Restrictions for Auto Pay */
    SET ARCONSTANT = 'AUTPAY_DOC';
    SET ARINID = STOREID;
    CALL [SCLIBRARY].CMM_GETCONSTANTVALUE(ARCONSTANT, ARINID, ARRESTRIC);
	
	/* Company Restrictions for Auto Pay */	
	SET COCONSTANT = 'INSCOMPANY';
    SET COINID = STOREID;
    CALL [SCLIBRARY].CMM_GETCONSTANTVALUE(COCONSTANT, COINID, CORESTRICT);
	
	SET TODAY = [SCLIBRARY].CMM_GetCurrentJulianDate (CURRENT DATE);

	/* Dynamic sort direction statement */ 
	SET SORTDIR_DYNAMIC = CASE SORTDIR WHEN 'A' THEN ' ASC' WHEN 'D' THEN ' DESC' ELSE '' END;
	
	/* Dynamic sort statement */
    SET SORT_DYNAMIC =
        CASE SORTBY
            WHEN 'RuleId' THEN 'RuleId ' || SORTDIR_DYNAMIC || ', StartDate DESC'
            WHEN 'RuleName' THEN 'RuleName ' || SORTDIR_DYNAMIC || ', RuleId DESC'
            WHEN 'Currency' THEN 'Currency ' || SORTDIR_DYNAMIC || ', RuleId DESC'
            WHEN 'PaymentType' THEN 'PaymentType ' || SORTDIR_DYNAMIC || ', RuleId DESC'
            WHEN 'PaymentDate' THEN 'PaymentDate ' || SORTDIR_DYNAMIC || ', RuleId DESC'
			WHEN 'StartDate' THEN 'StartDate ' || SORTDIR_DYNAMIC || ', RuleId DESC'
            WHEN 'Duration' THEN 'Duration ' || SORTDIR_DYNAMIC || ', RuleId DESC'
			ELSE 'StartDate ASC, RuleId DESC'
        END;

	BEGIN
		/* CURSOR FOR DYNAMIC SQL */
		DECLARE TEMP_CURSOR1 CURSOR WITH RETURN FOR V_DYNAMIC;
		
		/* Dynamic query condition */
		SET WHERE_DYNAMIC = '';
		SET INNER_DYNAMIC = '';
 
		SET ROWSTART = ( ( PAGESIZE * PAGEINDEX ) - PAGESIZE + 1 ); 
		SET ROWEND = ( PAGEINDEX * PAGESIZE ); 
    
		IF (CUSTOMERNUMBER IS NOT NULL)
		THEN
			SET WHERE_DYNAMIC = N' A.AR$9AN8 = ? ';
		ELSE    
			SET WHERE_DYNAMIC = N' (1 = 1 OR ? IS NULL) '; 
		END IF;
    
		IF (RULENAME <> '*')
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.ARDSC1 LIKE ''%'' || ? ||''%'' ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? = ''*'') ';
		END IF;

		IF (RULEID IS NOT NULL)
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AR$9UKID =  ? ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? IS NULL) '; 
		END IF;

		IF (STARTDATEFROM IS NOT NULL)
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AREFFF >= ? ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? = 0) ';
		END IF;

		IF (STARTDATETO IS NOT NULL)
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AREFFF <= ? ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? = 0) ';
		END IF;

		IF (EXPIRATIONDATEFROM IS NOT NULL)
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AR$9APAYSD >=  ? ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? = 0) ';
		END IF;

		IF (EXPIRATIONDATETO IS NOT NULL)
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AR$9APAYSD <= ? ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? = 0) ';
		END IF;

		IF (CURRENCYCODE <> '*')
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.ARCRCD = ? ';
		ELSE
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? IS NULL) ';
		END IF;

		/*Add parameter STATUS when it is On Hold or Active*/
		IF(STATUS > 1)
		THEN
			SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND (1 = 1 OR ? IS NULL) ';/*STATUS*/
		END IF;
		
		IF (STATUS <> 4) 
		THEN
			IF (STATUS = 2) /*Expired*/
			THEN
				SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AR$9APAYSD <= ' || TODAY || N' AND A.AR$9APAYEX = 2 ';
			ELSE
				SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND NOT (A.AR$9APAYSD <= ' || TODAY || N' AND A.AR$9APAYEX = 2) ';
				IF (STATUS = 3) /*Future*/
				THEN
					SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AREFFF > ' || TODAY || N' ';
				ELSE
					SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AR$9STS = ? AND A.AREFFF <= ' || TODAY || N' ';/*STATUS*/
					IF (STATUS = 1) /*On Hold*/
					THEN
						SET WHERE_DYNAMIC = WHERE_DYNAMIC || N' AND A.AREFFF < A.ARRDJ ';
					END IF;
				END IF;
			END	IF;
		END IF;

		IF (CORESTRICT = N'L') 
		THEN
			SET INNER_DYNAMIC = N' INNER JOIN (
			SELECT DISTINCT 
					RC.RC$9UKID 
			FROM (
				SELECT  
						C.RC$9AN8,
						C.RC$9UKID,
						C.RCCO
				FROM [SCDATA].FQ670316 C 
				WHERE C.RC$9AN8 = ' || CUSTOMERNUMBER || N') RC 
			INNER JOIN (
				SELECT 
						CR.CI$9INID,
						CR.CICO 
				FROM [SCDATA].FQ679912 CR 
				WHERE CR.CI$9INID = ''' || COINID || N''') REC ON REC.CICO = RC.RCCO) RR
			ON RuleId = RR.RC$9UKID ';
		END IF;

		IF (ARRESTRIC = N'1') 
		THEN
			SET INNER_DYNAMIC = INNER_DYNAMIC || N' INNER JOIN (
			SELECT DISTINCT 
					RT.RI$9UKID 
			FROM (
				SELECT
						T.RI$9AN8, 
						T.RI$9UKID, 
						T.RIDCT
				FROM [SCDATA].FQ670317 T 
				WHERE T.RI$9AN8 = ' || CUSTOMERNUMBER || N') RT 
			INNER JOIN (
				SELECT 
						IT.DR$9INID,
						IT.DR$9CNST,
						IT.DRKY
				FROM [SCDATA].FQ67008 IT 
				WHERE IT.DR$9INID = ''' || ARINID || N''' AND IT.DR$9CNST = ''' || ARCONSTANT || N''') RET 
			ON RET.DRKY = RT.RIDCT) R
			ON RuleId = R.RI$9UKID ';
		END IF;
		
		SET SQL_DYNAMIC = N'
		WITH PAGING AS (
			SELECT AutoPayRules.*, ROW_NUMBER() OVER(ORDER BY ' || SORT_DYNAMIC || ') AS RNUM FROM 
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
				FROM 	[SCDATA].FQ670315 A 
				WHERE ' || WHERE_DYNAMIC || N'
				) AutoPayRules '
				|| INNER_DYNAMIC || N'
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
			(SELECT COUNT(1) FROM PAGING) AS TotalRowCount
		FROM PAGING
		WHERE (( ? = 0  OR ? = 0) OR ( RNUM BETWEEN ? AND ? ))';
		
		PREPARE V_DYNAMIC FROM SQL_DYNAMIC;
		
		OPEN TEMP_CURSOR1 USING  CUSTOMERNUMBER, RULENAME, RULEID, STARTDATEFROM,
							STARTDATETO, EXPIRATIONDATEFROM, EXPIRATIONDATETO, CURRENCYCODE, STATUS,
							PAGEINDEX, PAGESIZE,  ROWSTART, ROWEND;
	END;
END; 
  

