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

-- #desc						Return empty
-- #bl_class					Premier.Profile.CreditCardList.cs
-- #db_dependencies				N/A
-- #db_references				N/A

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
    AddressNumber   IN DECIMAL,
    AddressType     IN DECIMAL,
    ContactID       IN DECIMAL,
    SequenceNumber  IN DECIMAL,
    ConnectionName  IN NVARCHAR2,
    Department      IN NVARCHAR2,
	AlphaName		IN NVARCHAR2,
	MaskedCCNumber  IN NVARCHAR2,
    Status          IN NVARCHAR2,
	SortBy			IN NVARCHAR2,
	SortDir			IN NVARCHAR2,
    PageIndex       IN DECIMAL,
    PageSize        IN DECIMAL,
    LangPref        IN NVARCHAR2,    
    ResultData1     OUT   GLOBALPKG.refcursor
)
AS
BEGIN
    OPEN ResultData1 FOR
        SELECT 
		        0 AS AddressNumber,
		0 AS AddressType,
		0 AS SequenceNumber,
		0 AS CreditCardType,
		' ' AS MaskedCCNumber ,
		0 AS ExpDate,
		0 AS IsDefault,
		' ' AS AlphaName,
		' ' AS AddressLine1,
		' ' AS AddressLine2,
		' ' AS State,
		' ' AS ZipCodePostal,
		' ' AS Country,
		' ' AS City,
		0 AS ContactId,
		' ' AS CCSelectionGroup,
		' ' AS EncryptedCCNumber,
		' ' AS ConnectionName,
		' ' AS ProgramId  ,
		' ' AS WorkStationId  ,
		' ' AS UserId  ,
		0 AS DateUpdated  ,
		0 AS TimeLastUpdated  ,
		' ' AS CreditCardDescription,
		' ' AS Department,
		' ' AS DepartmentDescription,
		' ' AS Comments,
		0 AS TotalRowCount
		FROM SYS.DUAL
		WHERE 1=0;

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
BEGIN
	OPEN ResultData1 FOR
	SELECT	
		A.RUAN8					AS	AddressNumber,
		D.WWMLNM				AS	MailingName,
		A.RUICU					AS	AccountingBatchNumber,
		A.RUEDBT				AS	EdiBatchNumber,
		A.RUEDTN				AS	TransactionNumber,
		A.RUDMTJ				AS	PaymentDate,
		A.RUCKAM				AS	PaymentAmount,
		0                       AS  SurchargeAmount,
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
BEGIN
	OPEN ResultData1 FOR
	SELECT 
		0		AS		AddressNumber,
		0		AS		AddressType,
		0		AS		SequenceNumber,
		''		AS      CreditCardType,
		''		AS      MaskedCCNumber,
		0		AS		ExpDate,
		0		AS		IsDefault,
		''		AS      AlphaName,
		''		AS      AddressLine1,
		''		AS      AddressLine2,
		''		AS		State,
		''		AS      ZipCodePostal,
		''		AS      Country,
		''		AS      City,
		0		AS      ContactId,
		''		AS      CCSelectionGroup,
		''		AS		EncryptedCCNumber,
		''		AS      ProgramId,
		''		AS      WorkStationId,
		''		AS      UserId,
		0		AS      DateUpdated,
		0		AS      TimeLastUpdated,                           
		''		AS      ConnectionName,
		''		AS		Department,                      
		''		AS      Comments,
		''	    AS		CreditCardDescription,
		''		AS		DepartmentDescription
	FROM SYS.DUAL
	WHERE 1=0;

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
	BEGIN
		OPEN ResultData1 FOR
		SELECT 
			0 AS CreditCardsCount,
			0 AS DefaultCreditCard
		FROM SYS.DUAL;
	END;
  /
