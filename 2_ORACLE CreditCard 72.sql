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
	ProductCode		    IN NCHAR,
	UserDefinedCode	    IN NCHAR,
	UserDefinedKey		IN NCHAR,
	LangPref			IN NCHAR
)
RETURN NVARCHAR2 IS
    RETURNS NVARCHAR2(30);
    CodeLength INT :=0;
    UserDefinedKeyTMP NCHAR(10);
    LangPrefTMP NCHAR(2):= LangPref;
BEGIN
	BEGIN
	    SELECT DTCDL INTO CodeLength FROM [SCCTL].F0004 
						WHERE DTSY = ProductCode AND DTRT = UserDefinedCode;
	    EXCEPTION WHEN NO_DATA_FOUND THEN 
	    CodeLength := LENGTH (UserDefinedKey);
	END;

	-- set UserDefinedKey with blank spaces
	UserDefinedKeyTMP := RPAD(' ' , 10 - CodeLength) || TRIM(UserDefinedKey);
	
	IF(TRIM(LangPref) IS NULL) THEN
	    LangPrefTMP := '*';
    END IF;
	
	/* Do not join with Alternate Language Table when LangPref is '*' */
	IF (LangPrefTMP = '*') THEN
		BEGIN
			SELECT A.DRDL01 INTO RETURNS
			FROM	
				[SCCTL].F0005 A
			WHERE
				A.DRSY = ProductCode
				AND A.DRRT = UserDefinedCode
				AND A.DRKY = UserDefinedKeyTmp;-- User Defined Key filter
			EXCEPTION WHEN NO_DATA_FOUND THEN 
			RETURNS := NULL;
		END;
	ELSE
		BEGIN
			SELECT	NVL(B.DRDL01, A.DRDL01) INTO RETURNS
			FROM	
				[SCCTL].F0005 A
			LEFT OUTER JOIN 
				[SCCTL].F0005D B
				ON B.DRSY = ProductCode
				AND B.DRRT = UserDefinedCode
				AND B.DRKY = UserDefinedKeyTmp
				AND B.DRLNGP = LangPrefTMP
			WHERE
				A.DRSY = ProductCode
				AND A.DRRT = UserDefinedCode
				AND A.DRKY = UserDefinedKeyTmp;-- User Defined Key filter
			EXCEPTION WHEN NO_DATA_FOUND THEN 
			RETURNS := NULL;
		END;
	END IF;
    
	RETURN NVL(RETURNS,' ');

END CMM_GetUserDefinedCodeFnc;
  /

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

CREATE OR REPLACE PROCEDURE [SCLIBRARY].PRO_GetCreditCards
(
    AddressNumber   IN NUMBER,
    AddressType     IN NUMBER,
    ContactID       IN NUMBER,
    SequenceNumber  IN NUMBER,
    ConnectionName  IN NCHAR,
    Department      IN NCHAR,
	AlphaName		IN NCHAR,
	MaskedCCNumber  IN NCHAR,
    Status          IN NVARCHAR2,
	SortBy			IN NVARCHAR2,
	SortDir			IN NVARCHAR2,
    PageIndex       IN INT,
    PageSize        IN INT,
    LangPref        IN NCHAR,    
    ResultData1     OUT   GLOBALPKG.refcursor
)
AS
	SQL_DYNAMIC		VARCHAR2(4000);
	WHERE_DYNAMIC	NVARCHAR2(2000) := N' ';
	SORT_CONDITION  NVARCHAR2(50);

	/* Paging */
    RowStart INT := ((PageSize * PageIndex) - PageSize + 1);
    RowEnd INT := (PageIndex * PageSize);
BEGIN
	
	IF (ContactID IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND A.CCIDLN = :ContactID ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :ContactID IS NULL) ';
	END IF;

	IF (SequenceNumber IS NOT NULL) THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND A.CCSEQ = :SequenceNumber ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :SequenceNumber IS NULL) ';
	END IF;
  
	IF (ConnectionName <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND (UPPER(A.CC$9CNM) = :ConnectionName OR A.CC$9CNM IN (SELECT B.MP$9CNM FROM [SCDATA].FQ67CCI1 B WHERE B.MP$9CCGRPK = (SELECT C.MP$9CCGRPK FROM [SCDATA].FQ67CCI1 C WHERE UPPER(C.MP$9CNM) = :ConnectionName))) ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :ConnectionName = ''*'' OR :ConnectionName = ''*'') ';
	END IF;

	IF (Department <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND A.CC$9DPT = :Department ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :Department = ''*'') ';
	END IF;

	IF (MaskedCCNumber <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND UPPER(A.CCCRCI) LIKE ''%'' || :MaskedCCNumber || ''%'' ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :MaskedCCNumber = ''*'') ';
	END IF;

	IF (AlphaName <> '*') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND UPPER(A.CCALPH) LIKE ''%'' || :AlphaName || ''%'' ';
	ELSE
		WHERE_DYNAMIC := WHERE_DYNAMIC || N' AND (1 = 1 OR :AlphaName = ''*'') ';
	END IF;

	IF (Status = 'A') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND MONTHS_BETWEEN(TO_DATE(CC$9VSEXDT|| ''01'' , ''YYYYMMDD''), SYSDATE )  >= 0 ';
	END IF;

	IF (Status = 'I') THEN
		WHERE_DYNAMIC := WHERE_DYNAMIC || N'AND MONTHS_BETWEEN(TO_DATE(CC$9VSEXDT|| ''01'' , ''YYYYMMDD''), SYSDATE )  < 0 ';
	END IF;

	IF (SortBy = 'AlphaName') THEN
		IF(SortDir = 'A') THEN
			SORT_CONDITION := 'UPPER(A.CCALPH) ASC';
		END IF;
		IF(SortDir = 'D') THEN
			SORT_CONDITION := 'UPPER(A.CCALPH) DESC';
		END IF;
	END IF;

	IF (SortBy = 'ExpDate') THEN
		IF(SortDir = 'A') THEN
			SORT_CONDITION := 'A.CC$9VSEXDT ASC';
		END IF;
		IF(SortDir = 'D') THEN
			SORT_CONDITION := 'A.CC$9VSEXDT DESC';
		END IF;
	END IF;

	SQL_DYNAMIC := N'
	WITH CREDITCARDS AS
	(	SELECT 
			A.CC$9AN8		AS      AddressNumber,
			A.CC$9TYP		AS      AddressType,
			A.CCSEQ			AS      SequenceNumber,
			A.CCCARD		AS      CreditCardType,
			A.CCCRCI		AS      MaskedCCNumber,
			A.CC$9VSEXDT	AS      ExpDate,
			A.CC$9DEF		AS      IsDefault,
			A.CCALPH		AS      AlphaName,
			A.CCADD1		AS      AddressLine1,
			A.CCADD2		AS      AddressLine2,
			A.CCADDS		AS      State,
			A.CCADDZ		AS      ZipCodePostal,
			A.CCCTR			AS      Country,
			A.CCCTY1		AS      City,
			A.CCIDLN		AS      ContactId,
			A.CC$9VSGRP		AS      CCSelectionGroup,
			A.CC$9VSCCN		AS      EncryptedCCNumber,
			A.CCPID			AS      ProgramId,
			A.CCJOBN		AS      WorkStationId,
			A.CCUSER		AS      UserId,
			A.CCUPMJ		AS      DateUpdated,
			A.CCUPMT		AS      TimeLastUpdated,                           
			CC$9CNM			AS      ConnectionName,
			A.CC$9DPT		AS      Department,                           
			A.CC$9commt		AS      Comments,
			ROW_NUMBER() OVER(ORDER BY '||SORT_CONDITION||N') AS RNUM
		FROM [SCDATA].FQ67CCIF A
		WHERE A.CC$9AN8 = :AddressNumber
			AND A.CC$9TYP = :AddressType 
		' || WHERE_DYNAMIC || N'
	)
	SELECT AddressNumber, AddressType, SequenceNumber, CreditCardType, MaskedCCNumber,
        ExpDate, IsDefault, AlphaName, AddressLine1, AddressLine2,
        State, ZipCodePostal, Country, City, ContactId, CCSelectionGroup, EncryptedCCNumber,
        ProgramId, WorkStationId, UserId, DateUpdated, TimeLastUpdated, 
        [SCLIBRARY].CMM_GetUserDefinedCodeFnc(''00'',''CA'', CreditCardType, ''*'') AS CreditCardDescription,
        ConnectionName, Department, [SCLIBRARY].CMM_GetUserDefinedCodeFnc(''59'',''DE'', RTRIM(Department), :LangPref)  AS DepartmentDescription,
        Comments, (SELECT COUNT(1) FROM CREDITCARDS) AS TotalRowCount 
    FROM CREDITCARDS
	WHERE ((:PageIndex = 0 OR :PageSize = 0) OR (RNUM BETWEEN :RowStart AND :RowEnd)) ';
    
	OPEN ResultData1 FOR SQL_DYNAMIC USING AddressNumber, AddressType, ContactID, SequenceNumber, ConnectionName, ConnectionName, 
									Department, MaskedCCNumber, AlphaName, LangPref, PageIndex, PageSize, RowStart, RowEnd;
END;
  /

-- #desc							Invoice Payment Confirmation List
-- #bl_class						Premier.Commerce.InvoicePayConfirmDetailList.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param EdiUserId					Edi User Id
-- #param EdiBatNumber				Edi Batch Number
-- #param EdiTransactionNumber		Edi Transaction Number
 --#param LangPref					Lang Pref

CREATE OR REPLACE PROCEDURE [SCLIBRARY].COM_GetInvoicePayConfirmList
(
	 EdiUserId					IN NCHAR,
	 EdiBatNumber				IN NCHAR,
	 EdiTransactionNumber		IN NCHAR,
	 LangPref					IN NCHAR,
	 ResultData1				OUT GLOBALPKG.refcursor
)
AS
SurchargeAmount NUMBER;
BEGIN
	SELECT 
		A.RUAG INTO SurchargeAmount
	FROM [SCDATA].F03B13Z1 A
	LEFT OUTER JOIN [SCDATA].FQ670045 B
		ON  B.SUEDUS = A.RUEDUS
		AND B.SUEDBT = A.RUEDBT
		AND B.SUEDTN = A.RUEDTN
		AND B.SUEDLN = A.RUEDLN	
	WHERE A.RUEDUS = EdiUserId 
		AND A.RUEDBT = EdiBatNumber 
		AND A.RUEDTN = EdiTransactionNumber
		AND B.SUEDBT IS NOT NULL;
		
	IF (SurchargeAmount = '' OR SurchargeAmount IS NULL) THEN
		SurchargeAmount := 0;
	END IF;

	OPEN ResultData1 FOR
	SELECT	
		A.RUAN8					AS	AddressNumber,
		D.WWMLNM				AS	MailingName,
		A.RUICU					AS	AccountingBatchNumber,
		A.RUEDBT				AS	EdiBatchNumber,
		A.RUEDTN				AS	TransactionNumber,
		A.RUDMTJ				AS	PaymentDate,
		A.RUCKAM				AS	PaymentAmount,
		CASE WHEN A.RUCKAM > 0 AND SurchargeAmount > 0 THEN SurchargeAmount ELSE 0 END AS SurchargeAmount,
		NVL(A.RUCRCD,'USD')		AS	CurrencyCode,
		A.RURMK					AS	Remark,
		A.RUCKNU				AS	PaymentReference,
		A.RUPYIN				AS	PaymentInstrument,
		[SCLIBRARY].CMM_GetUserDefinedCodeFnc('00','PY', A.RUPYIN, LangPref) AS PaymentInstrumentDesc,
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
	LEFT OUTER JOIN [SCDATA].FQ670045 C
		ON  C.SUEDUS = A.RUEDUS
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
	ORDER BY InvoiceType, InvoiceNumber, InvoiceSuffix;
END;
  /
-- #desc						Fetch Credit Card for Customer/Consumer 
-- #bl_class	 	 			Premier.Profile.CreditCardInfo.cs 
-- #db_dependencies				N/A
-- #db_references				N/A		

-- #param AddressNumber			Address Number 
-- #param AddressType			AddressBook Type 
-- #param ContactID				Contact ID Number 
-- #param SequenceNumber		Credit Card Sequence Number 
-- #param LangPref				Language Preference 

CREATE OR REPLACE PROCEDURE [SCLIBRARY].PRO_GetCreditCardInfo
(
	AddressNumber	IN DECIMAL,
	AddressType		IN DECIMAL,
	ContactID		IN DECIMAL,
	SequenceNumber	IN DECIMAL,
    LangPref        IN NVARCHAR2,    
    ResultData1     OUT  GLOBALPKG.refcursor
)
AS
	CodeLengthCCType DECIMAL;
	CodeLengthDep DECIMAL;
BEGIN
	/* Get UDC Code Lengths*/
	CodeLengthCCType := 0;
	SELECT DTCDL INTO CodeLengthCCType FROM [SCCTL].F0004 WHERE DTSY = '00' AND DTRT = 'CA';	

	CodeLengthDep := 0;
	SELECT DTCDL INTO CodeLengthDep FROM [SCCTL].F0004 WHERE DTSY = '59' AND DTRT = 'DE';

	OPEN ResultData1 FOR
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
		NVL(B.DRDL01, A.DRDL01) AS CreditCardDescription,
		NVL(D.DRDL01, C.DRDL01) AS DepartmentDescription
	FROM [SCDATA].FQ67CCIF 
	INNER JOIN [SCCTL].F0005 A
		ON A.DRSY = '00' AND A.DRRT = 'CA' 
		AND A.DRKY =  RPAD(' ' , 10 - CodeLengthCCType ) || TRIM(CCCARD)        	
	LEFT OUTER JOIN [SCCTL].F0005D B
	    ON B.DRSY = A.DRSY 
	    AND B.DRRT = A.DRRT
	    AND B.DRKY = A.DRKY	
		AND B.DRLNGP = LangPref	
			       
	LEFT OUTER JOIN [SCCTL].F0005 C
	    ON  C.DRSY = '59' 
		AND C.DRRT = 'DE'
		AND C.DRKY =  RPAD(' ' , 10 - CodeLengthDep ) || SUBSTR(LTRIM( CC$9DPT), 1, CodeLengthDep) 
	LEFT OUTER JOIN [SCCTL].F0005D D
	    ON  D.DRSY = C.DRSY 
	    AND D.DRRT = C.DRRT
	    AND D.DRKY = C.DRKY
		AND D.DRLNGP = LangPref	

	WHERE CC$9AN8 =  AddressNumber 
		AND CC$9TYP = AddressType 
		AND (ContactID is null or CCIDLN = ContactID) 	
		AND CCSEQ = SequenceNumber;
END;

  /

-- #desc						Calculate Credit Cards count and default CC  
-- #bl_class	 	 			N/A 
-- #db_dependencies				N/A
-- #db_references				ECO_GetAccountSummaryInfo 

-- #param AddressNumber			Address Number 
-- #param AddressType			AddressBook Type 

CREATE OR REPLACE PROCEDURE [SCLIBRARY].PRO_GetCreditCardsSummary
(
	AddressNumber		IN DECIMAL,
	AddressType		IN DECIMAL,
	ResultData1 OUT GLOBALPKG.refcursor
)
AS
	CreditCardsCount INT;
	DefaultCreditCard INT;

	BEGIN
		SELECT COUNT(1) INTO CreditCardsCount FROM [SCDATA].FQ67CCIF A WHERE A.CC$9AN8 = AddressNumber AND A.CC$9TYP = AddressType;
		BEGIN
			SELECT CCSEQ INTO DefaultCreditCard FROM [SCDATA].FQ67CCIF A WHERE A.CC$9AN8 = AddressNumber AND A.CC$9TYP = AddressType AND A.CC$9DEF = 1;
			EXCEPTION WHEN NO_DATA_FOUND THEN 
			DefaultCreditCard := 0; 
		END;

		OPEN ResultData1 FOR
		SELECT 
			CreditCardsCount AS CreditCardsCount,
			DefaultCreditCard AS DefaultCreditCard
		FROM SYS.DUAL;
	END;
  /
