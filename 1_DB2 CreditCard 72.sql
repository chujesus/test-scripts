-- #desc						Return the first description
-- #bl_class					N/A
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param ProductCode			Product Code
-- #param UserDefinedCode		User Defined Code 
-- #param UserDefinedKey		User Defined Key
-- #param LangPref				Lang Pref

CREATE OR REPLACE FUNCTION [SCLIBRARY].CMM_GetUserDefinedCodeFnc
(
	ProductCode			VARGRAPHIC(4) CCSID 13488,
	UserDefinedCode		VARGRAPHIC(2) CCSID 13488,
	UserDefinedKey		VARGRAPHIC(40) CCSID 13488,
	LangPref			VARGRAPHIC(2) CCSID 13488
)
RETURNS VARGRAPHIC(30) CCSID 13488
LANGUAGE SQL
SPECIFIC [SCLIBRARY].CMM_GetUserDefinedCodeFnc
DISALLOW PARALLEL
NOT DETERMINISTIC
CALLED ON NULL INPUT
BEGIN
	DECLARE	CodeLength		INTEGER;
	DECLARE UDCDescription	VARGRAPHIC(30) CCSID 13488;

	-- Get Code Length
	SET CodeLength = 0;
	SET CodeLength = (SELECT DTCDL FROM [SCCTL].F0004
						WHERE DTSY = ProductCode AND DTRT = UserDefinedCode);

	-- Set UserDefinedKey with blank spaces
	SET UserDefinedKey = REPEAT(' ' ,10 - CodeLength ) || LTRIM(UserDefinedKey);
	
	IF (LangPref = '*') THEN 
		SELECT	A.DRDL01 
		INTO	UDCDescription	 
		FROM	[SCCTL].F0005 A 
		WHERE 
			A.DRSY = ProductCode 
			AND A.DRRT = UserDefinedCode 
			AND A.DRKY = UserDefinedKey; 
	ELSE 
		SELECT	COALESCE(B.DRDL01,A.DRDL01)
		INTO 	UDCDescription	
		FROM	[SCCTL].F0005 A
		LEFT JOIN [SCCTL].F0005D B
			ON  B.DRSY = ProductCode
			AND B.DRRT = UserDefinedCode
			AND B.DRKY = UserDefinedKey
			AND B.DRLNGP = LangPref
		WHERE
				A.DRSY = ProductCode
			AND A.DRRT = UserDefinedCode
			AND A.DRKY = UserDefinedKey;
	END IF; 
	
	RETURN (COALESCE(UDCDescription,''));
END ;

-- #desc						Fetch Credit Cards for Customer/Consumer 
-- #bl_class	 	 			Premier.Profile.CreditCardList.cs
-- #db_dependencies				N/A
-- #db_references				CST_GetContactChildren, CSM_GetContactChildren 

-- #param AddressNumber			Address Number 
-- #param AddressType			AddressBook Type 
-- #param ContactID				Contact ID Number 
-- #param SequenceNumber		Credit Card Sequence Number (OPTIONAL) 
-- #param ConnectionName		The Parameter is only from Ecommerce (POS and MC send empty) 
-- #param Department			Department code to filter UDC 59/DE 
-- #param AlphaName				Name to filter 
-- #param MaskedCCNumber		Masked Card Number to filter 
-- #param Status				Active = A, Inactive = I, Any = * 
-- #param SortBy				Column to filter by 
-- #param SortDir				Direction to filter (A = Ascendent, D = Descendent) 
-- #param PageIndex				Page Index 
-- #param PageSize				Page Size 
-- #param LangPref				Language Preference 

CREATE OR REPLACE Procedure [SCLIBRARY].PRO_GetCreditCards
(
	IN AddressNumber	NUMERIC(15,0),
	IN AddressType		DECIMAL(10,0),
	IN ContactID		DECIMAL(5,0),
	IN SequenceNumber	NUMERIC(6,2),
	IN ConnectionName   VARGRAPHIC(100) CCSID 13488,
	IN Department       GRAPHIC(40) CCSID 13488,
	IN AlphaName		VARGRAPHIC(40) CCSID 13488,
    IN MaskedCCNumber   VARGRAPHIC(25) CCSID 13488,
    IN Status			VARCHAR(1),
	IN SortBy			VARCHAR(30),
	IN SortDir			VARCHAR(1),
    IN PageIndex        INT,
    IN PageSize         INT,
    IN LangPref         VARCHAR(2)
)
DYNAMIC RESULT SETS 1
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].PRO_GetCreditCards 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 

BEGIN
	DECLARE RowStart INT DEFAULT 0;
	DECLARE RowEnd	INT DEFAULT 0;

	/*DYNAMIC SQL QUERY*/
	DECLARE SQL_DYNAMIC VARGRAPHIC(8000) CCSID 13488;
	DECLARE WHERE_CONDITION VARGRAPHIC(4000) CCSID 13488;
	DECLARE SORT_CONDITION VARGRAPHIC(50) CCSID 13488;

	/*CURSOR FOR DYNAMIC SQL*/
	DECLARE TEMP_CURSOR1 CURSOR WITH RETURN TO CLIENT FOR V_DYNAMIC;	
	

	SET RowStart = (PageSize * PageIndex) - PageSize + 1;		
	SET RowEnd = PageIndex * PageSize;


	/*DYNAMIC QUERY CONDITION*/
	SET  WHERE_CONDITION = ''; 

	IF (ContactID IS NOT NULL) THEN
		SET WHERE_CONDITION = N'AND A.CCIDLN = ? ';
	ELSE
		SET WHERE_CONDITION = N' AND (1 = 1 OR ? IS NULL) ';
	END IF;

	IF (SequenceNumber IS NOT NULL) THEN
		SET WHERE_CONDITION = WHERE_CONDITION || N'AND A.CCSEQ = ? ';
	ELSE
		SET WHERE_CONDITION = WHERE_CONDITION || N' AND (1 = 1 OR ? IS NULL) ';
	END IF;

	IF (ConnectionName <> N'*') THEN
		SET WHERE_CONDITION = WHERE_CONDITION || N'AND (UPPER(A.CC$9CNM) = ?
										OR A.CC$9CNM IN (SELECT B.MP$9CNM FROM [SCDATA].FQ67CCI1 B WHERE B.MP$9CCGRPK = (SELECT C.MP$9CCGRPK FROM [SCDATA].FQ67CCI1 C WHERE UPPER(C.MP$9CNM) = ? )))';
	ELSE
		SET WHERE_CONDITION = WHERE_CONDITION || N' AND (1 = 1 OR ?  = ''*'' OR ?  = ''*'') ';
	END IF;

	IF (Department <> N'*') THEN
		SET WHERE_CONDITION = WHERE_CONDITION || N'AND A.CC$9DPT = ? ';
	ELSE
		SET WHERE_CONDITION = WHERE_CONDITION || N' AND (1 = 1 OR ?  = ''*'') ';
	END IF;

	IF (MaskedCCNumber <> '*') THEN
		SET WHERE_CONDITION = WHERE_CONDITION || N'AND UPPER(A.CCCRCI) LIKE ''%'' || ? || ''%'' ';
	ELSE
		SET WHERE_CONDITION = WHERE_CONDITION || N' AND (1 = 1 OR ?  = ''*'') ';
	END IF;

	IF (AlphaName <> '*') THEN
		SET WHERE_CONDITION = WHERE_CONDITION || N'AND UPPER(A.CCALPH) LIKE ''%'' || ? || ''%'' ';
	ELSE
		SET WHERE_CONDITION = WHERE_CONDITION || N' AND (1 = 1 OR ?  = ''*'') ';
	END IF;

	IF (Status = 'A') THEN
		SET WHERE_CONDITION = WHERE_CONDITION || N'AND MONTHS_BETWEEN(TO_DATE(CC$9VSEXDT|| ''01'' , ''YYYYMMDD''), CURRENT DATE )  >= 0 ';
	END IF;

	IF (Status = 'I') THEN
		SET WHERE_CONDITION = WHERE_CONDITION || N'AND MONTHS_BETWEEN(TO_DATE(CC$9VSEXDT|| ''01'' , ''YYYYMMDD''), CURRENT DATE )  < 0 ';
	END IF;

	IF (SortBy = 'AlphaName') THEN
		IF(SortDir = 'A') THEN
			SET SORT_CONDITION = 'UPPER(A.CCALPH) ASC';
		END IF;
		IF(SortDir = 'D') THEN
			SET SORT_CONDITION = 'UPPER(A.CCALPH) DESC';
		END IF;
	END IF;

	IF (SortBy = 'ExpDate') THEN
		IF(SortDir = 'A') THEN
			SET SORT_CONDITION = 'A.CC$9VSEXDT ASC';
		END IF;
		IF(SortDir = 'D') THEN
			SET SORT_CONDITION = 'A.CC$9VSEXDT DESC';
		END IF;
	END IF;

    SET SQL_DYNAMIC = N'                                                           
    WITH CTE1 AS (                 
		SELECT 
			A.CC$9AN8		AS		AddressNumber,
			A.CC$9TYP		AS		AddressType,
			A.CCSEQ			AS		SequenceNumber,
			A.CCCARD		AS      CreditCardType,
			A.CCCRCI		AS      MaskedCCNumber,
			A.CC$9VSEXDT	AS		ExpDate,
			A.CC$9DEF		AS		IsDefault,
			A.CCALPH		AS      AlphaName,
			A.CCADD1		AS      AddressLine1,
			A.CCADD2		AS      AddressLine2,
			A.CCADDS		AS		State,
			A.CCADDZ		AS      ZipCodePostal,
			A.CCCTR			AS      Country,
			A.CCCTY1		AS      City,
			A.CCIDLN		AS      ContactId,
			A.CC$9VSGRP		AS      CCSelectionGroup,
			A.CC$9VSCCN		AS		EncryptedCCNumber,
			A.CCPID			AS      ProgramId,
			A.CCJOBN		AS      WorkStationId,
			A.CCUSER		AS      UserId,
			A.CCUPMJ		AS      DateUpdated,
			A.CCUPMT		AS      TimeLastUpdated,                           
			CC$9CNM			AS      ConnectionName,
			A.CC$9DPT		AS		Department,                      
			A.CC$9commt		AS      Comments,
			ROWNUMBER() OVER (ORDER BY ' || SORT_CONDITION || ') AS RNUM 
		FROM [SCDATA].FQ67CCIF A
		WHERE A.CC$9AN8 = ?
			AND A.CC$9TYP = ? ' || WHERE_CONDITION || '			
	)
	SELECT AddressNumber, AddressType, SequenceNumber, CreditCardType, MaskedCCNumber,
		ExpDate, IsDefault, AlphaName, AddressLine1, AddressLine2,
		State, ZipCodePostal, Country, City, ContactId, CCSelectionGroup, EncryptedCCNumber,
		ProgramId, WorkStationId, UserId, DateUpdated, TimeLastUpdated, 
		[SCLIBRARY].CMM_GetUserDefinedCodeFnc(''00'',''CA'', CreditCardType, '''|| LangPref ||''') AS CreditCardDescription,
		ConnectionName, Department, [SCLIBRARY].CMM_GetUserDefinedCodeFnc(''59'',''DE'', RTRIM(Department), '''|| LangPref ||''')  AS DepartmentDescription,
		Comments, (SELECT COUNT(1) FROM CTE1) AS TotalRowCount
	FROM CTE1
	WHERE (( ? = 0  OR ? = 0) OR ( RNUM BETWEEN ? AND ? )) ';
	
	PREPARE V_DYNAMIC FROM SQL_DYNAMIC;	
    OPEN TEMP_CURSOR1 USING AddressNumber, AddressType, ContactID, SequenceNumber, ConnectionName, ConnectionName, 
							Department, MaskedCCNumber, AlphaName, PageIndex, PageSize, RowStart, RowEnd; 
END;

-- #desc							Invoice Payment Confirmation List
-- #bl_class						Premier.Commerce.InvoicePayConfirmDetailList.cs
-- #db_dependencies					N/A
-- #db_references					N/A	

-- #param EdiUserId					Edi User Id
-- #param EdiBatNumber				Edi Batch Number
-- #param EdiTransactionNumber		Edi Transaction Number
-- #param LangPref					Lang Pref

CREATE OR REPLACE PROCEDURE [SCLIBRARY].COM_GetInvoicePayConfirmList
(
	 IN EdiUserId				VARCHAR(20),
	 IN EdiBatNumber			VARCHAR(30),
	 IN EdiTransactionNumber	VARCHAR(44),
	 IN LangPref				VARCHAR(2)
)
DYNAMIC RESULT SETS 1
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].COM_GetInvoicePayConfirmList 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 
BEGIN 
	DECLARE SURCHARGEAMOUNT FLOAT;

	DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
	SELECT	
		A.RUAN8					AS	AddressNumber,
		D.WWMLNM				AS	MailingName,
		A.RUICU					AS	AccountingBatchNumber,
		A.RUEDBT				AS	EdiBatchNumber,
		A.RUEDTN				AS	TransactionNumber,
		A.RUDMTJ				AS	PaymentDate,
		A.RUCKAM				AS	PaymentAmount,
		CASE WHEN A.RUCKAM > 0 AND SURCHARGEAMOUNT > 0 THEN SURCHARGEAMOUNT ELSE 0 END AS SURCHARGEAMOUNT,
		COALESCE(A.RUCRCD,'USD')	AS	CurrencyCode,
		A.RURMK					AS	Remark,
		A.RUCKNU				AS	PaymentReference,
		A.RUPYIN				AS	PaymentInstrument,
		[SCLIBRARY].CMM_GetUserDefinedCodeFnc('00','PY',A.RUPYIN, LangPref) AS PaymentInstrumentDesc,
		B.RPDCT					As	InvoiceType,
		B.RPDOC					AS	InvoiceNumber,
		B.RPSFX					AS	InvoiceSuffix,
		B.RPSDCT				AS	OrderType,
		B.RPSDOC				AS  OrderNumber,
		A.RUAG					AS	PaymentTotal,
		B.RPDDJ					AS  DueDate
	FROM [SCDATA].F03B13Z1 A
		LEFT OUTER JOIN [SCDATA].F03B11 B
		ON B.RPDOC = A.RUDOC 
		AND B.RPDCT = A.RUDCT 
		AND B.RPKCO = A.RUKCO 
		AND B.RPSFX = A.RUSFX 
		AND B.RPDOC	> 0
	LEFT OUTER JOIN [SCDATA].FQ670045 C
		ON C.SUEDUS = A.RUEDUS
		AND C.SUEDBT = A.RUEDBT
		AND C.SUEDTN = A.RUEDTN
		AND C.SUEDLN = A.RUEDLN
	INNER JOIN  [SCDATA].F0111 D
		ON D.WWAN8 = A.RUAN8 
		AND D.WWIDLN = 0
	WHERE A.RUEDUS = EdiUserId 
		AND A.RUEDBT = EdiBatNumber 
		AND A.RUEDTN = EdiTransactionNumber
		AND C.SUEDBT IS NULL
	ORDER BY InvoiceType, InvoiceNumber, InvoiceSuffix
	FOR FETCH ONLY;

	SELECT A.RUAG INTO SURCHARGEAMOUNT
	FROM [SCDATA].F03B13Z1 A		
	LEFT OUTER JOIN [SCDATA].FQ670045 B
		ON B.SUEDUS = A.RUEDUS
		AND B.SUEDBT = A.RUEDBT
		AND B.SUEDTN = A.RUEDTN
		AND B.SUEDLN = A.RUEDLN	
	WHERE A.RUEDUS = EDIUSERID
		AND A.RUEDBT = EDIBATNUMBER
		AND A.RUEDTN = EDITRANSACTIONNUMBER
		AND B.SUEDBT IS NOT NULL ;

OPEN TEMP_CURSOR1;

END ;
-- #desc						Fetch Credit Card for Customer/Consumer 
-- #bl_class	 	 			Premier.Profile.CreditCardInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A				

-- #param AddressNumber			Address Number 
-- #param AddressType			AddressBook Type 
-- #param ContactID				Contact ID Number 
-- #param SequenceNumber		Credit Card Sequence Number 
-- #param LangPref				Language Preference 

CREATE OR REPLACE Procedure [SCLIBRARY].PRO_GetCreditCardInfo
(
	IN AddressNumber	NUMERIC(15,0),
	IN AddressType		NUMERIC(15,0),
	IN ContactID		NUMERIC(15,0),
	IN SequenceNumber	NUMERIC(15,0),
    IN LangPref         VARCHAR(2)
)
DYNAMIC RESULT SETS 1
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].PRO_GetCreditCardInfo 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 

BEGIN
	
	DECLARE CodeLengthCCType INTEGER;
	DECLARE CodeLengthDep INTEGER;

	DECLARE TEMP_CURSOR1 CURSOR WITH RETURN TO CLIENT FOR 
	SELECT 
		CC$9AN8		AS		AddressNumber,
		CC$9TYP		AS		AddressType,
		CCSEQ		AS		SequenceNumber,
		CCCARD		AS      CreditCardType,
		CCCRCI		AS      MaskedCCNumber,
		CC$9VSEXDT	AS		ExpDate,
		CC$9DEF		AS		IsDefault,
		CCALPH		AS      AlphaName,
		CCADD1		AS      AddressLine1,
		CCADD2		AS      AddressLine2,
		CCADDS		AS		State,
		CCADDZ		AS      ZipCodePostal,
		CCCTR		AS      Country,
		CCCTY1		AS      City,
		CCIDLN		AS      ContactId,
		CC$9VSGRP	AS      CCSelectionGroup,
		CC$9VSCCN	AS		EncryptedCCNumber,
		CCPID		AS      ProgramId,
		CCJOBN		AS      WorkStationId,
		CCUSER		AS      UserId,
		CCUPMJ		AS      DateUpdated,
		CCUPMT		AS      TimeLastUpdated,                           
		CC$9CNM		AS      ConnectionName,
		CC$9DPT		AS		Department,                      
		CC$9commt	AS      Comments,
		COALESCE(B.DRDL01, A.DRDL01) AS CreditCardDescription,
		COALESCE(D.DRDL01, C.DRDL01) AS DepartmentDescription
	FROM [SCDATA].FQ67CCIF 
	INNER JOIN [SCCTL].F0005 A
		ON A.DRSY = '00' AND A.DRRT = 'CA' 
		AND A.DRKY =  REPEAT(' ' ,10 - CodeLengthCCType ) || LTRIM(CCCARD)        	
	LEFT OUTER JOIN [SCCTL].F0005D B
	    ON B.DRSY = A.DRSY 
	    AND B.DRRT = A.DRRT
	    AND B.DRKY = A.DRKY	
		AND B.DRLNGP = LangPref	
			       
	LEFT OUTER JOIN [SCCTL].F0005 C
	    ON  C.DRSY = '59' 
		AND C.DRRT = 'DE'
		AND C.DRKY =  REPEAT(' ' ,10 - CodeLengthDep ) || LTRIM(CC$9DPT) 
	LEFT OUTER JOIN [SCCTL].F0005D D
	    ON  D.DRSY = C.DRSY 
	    AND D.DRRT = C.DRRT
	    AND D.DRKY = C.DRKY
		AND D.DRLNGP = LangPref	

	WHERE CC$9AN8 =  AddressNumber 
		AND CC$9TYP = AddressType 
		AND (ContactID is null or CCIDLN = ContactID) 	
		AND CCSEQ = SequenceNumber
	FOR FETCH ONLY;
    
	
	/* Get UDC Code Lengths*/
	SET CodeLengthCCType = 0;
	SET CodeLengthCCType = (SELECT DTCDL FROM [SCCTL].F0004 WHERE DTSY = '00' AND DTRT = 'CA');	

	SET CodeLengthDep = 0;
	SET CodeLengthDep = (SELECT DTCDL FROM [SCCTL].F0004 WHERE DTSY = '59' AND DTRT = 'DE');
	
	OPEN TEMP_CURSOR1; 

END;

-- #desc						Calculate Credit Cards count and default CC  
-- #bl_class	 	 			N/A
-- #db_dependencies				N/A
-- #db_references				ECO_GetAccountSummaryInfo 

-- #param AddressNumber			Address Number 
-- #param AddressType			AddressBook Type 

CREATE OR REPLACE Procedure [SCLIBRARY].PRO_GetCreditCardsSummary
(
	IN AddressNumber	NUMERIC(15,0),
	IN AddressBookType		NUMERIC(15,0)
)
DYNAMIC RESULT SETS 1
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].PRO_GetCreditCardsSummary 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 

BEGIN
	DECLARE CreditCardsCount INTEGER;
	DECLARE DefaultCreditCard INTEGER;

	DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR
	SELECT 
		CreditCardsCount,
		DefaultCreditCard
	FROM SYSIBM.SYSDUMMY1;

	SELECT COUNT(1) INTO CreditCardsCount FROM [SCDATA].FQ67CCIF A WHERE A.CC$9AN8 = AddressNumber AND A.CC$9TYP = AddressBookType;
	SELECT CCSEQ INTO DefaultCreditCard FROM [SCDATA].FQ67CCIF A WHERE A.CC$9AN8 = AddressNumber AND A.CC$9TYP = AddressBookType AND A.CC$9DEF = 1;

	OPEN TEMP_CURSOR1;
END;
