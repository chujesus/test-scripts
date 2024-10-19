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

  
-- #desc				        Return empty
-- #bl_class	 	 	        Premier.Profile.CreditCardList.cs 
-- #db_dependencies		        N/A
-- #db_references			    CST_GetContactChildren, CSM_GetContactChildren

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
  
CREATE OR REPLACE PROCEDURE [SCLIBRARY].PRO_GETCREDITCARDS
( 
	IN AddressNumber	NUMERIC(15,0),
	IN AddressType		NUMERIC(15,0),
	IN ContactID		NUMERIC(15,0),
	IN SequenceNumber	NUMERIC(15,0),
	IN ConnectionName   VARGRAPHIC(100) CCSID 13488,
	IN Department       VARCHAR(10),
	IN AlphaName		VARGRAPHIC(40) CCSID 13488,
    IN MaskedCCNumber   VARGRAPHIC(40) CCSID 13488,
    IN Status			VARCHAR(1),
	IN SortBy			VARCHAR(30),
	IN SortDir			VARCHAR(1),
    IN PageIndex        NUMERIC(15,0),
    IN PageSize         NUMERIC(15,0),
    IN LangPref         VARCHAR(2)
) 
      DYNAMIC RESULT SETS 1
        LANGUAGE SQL 
SPECIFIC [SCLIBRARY].PRO_GETCREDITCARDS 
        NOT DETERMINISTIC 
        MODIFIES SQL DATA 
        CALLED ON NULL INPUT 
        BEGIN 
       
  
      DECLARE TEMP_CURSOR2 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
      SELECT 0 AS ADDRESSNUMBER, 
      0 AS ADDRESSTYPE, 
      0 AS SEQUENCENUMBER, 
      0 AS CREDITCARDTYPE, 
      '' AS MASKEDCCNUMBER, 
      0 AS EXPDATE, 
      0 AS ISDEFAULT, 
      '' AS ALPHANAME, 
      '' AS ADDRESSLINE1, 
      '' AS ADDRESSLINE2, 
      '' AS STATE, 
      '' AS ZIPCODEPOSTAL, 
      '' AS COUNTRY,
      '' AS CITY,
      0 AS CONTACTID, 
      '' AS CCSELECTIONGROUP, 
      '' AS ENCRYPTEDCCNUMBER,
	  '' AS CONNECTIONNAME,
      '' AS "PROGRAMID",
      '' AS WORKSTATIONID, 
      '' AS "USERID", 
      0 AS DATEUPDATED, 
      0 AS TIMELASTUPDATED, 
      '' AS CREDITCARDDESCRIPTION,
	  '' AS DEPARTMENT,
	  '' AS DEPARTMENTDESCRIPTION,
	  '' AS COMMENTS,
	  0 AS TOTALROWCOUNT
      FROM SYSIBM . SYSDUMMY1 WHERE 1 = 0 FOR FETCH ONLY; 
  
      OPEN TEMP_CURSOR2 ;     
END

 ;
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

	DECLARE TEMP_CURSOR1 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
	SELECT	
		A.RUAN8					AS	AddressNumber,
		D.WWMLNM				AS	MailingName,
		A.RUICU					AS	AccountingBatchNumber,
		A.RUEDBT				AS	EdiBatchNumber,
		A.RUEDTN				AS	TransactionNumber,
		A.RUDMTJ				AS	PaymentDate,
		A.RUCKAM				AS	PaymentAmount,
		0						AS  SURCHARGEAMOUNT,
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
	DECLARE TEMP_CURSOR1 CURSOR WITH RETURN TO CLIENT FOR 
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
		''	    AS CreditCardDescription,
		''		AS DepartmentDescription
	FROM SYSIBM.SYSDUMMY1 WHERE 1 = 0 FOR FETCH ONLY;

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
	IN AddressType		NUMERIC(15,0)
)
DYNAMIC RESULT SETS 1
LANGUAGE SQL 
SPECIFIC [SCLIBRARY].PRO_GetCreditCardsSummary 
NOT DETERMINISTIC 
MODIFIES SQL DATA 
CALLED ON NULL INPUT 

BEGIN
	DECLARE TEMP_CURSOR2 CURSOR WITH HOLD WITH RETURN TO CLIENT FOR 
    SELECT 
		0 AS CreditCardsCount,
		0 AS DefaultCreditCard
    FROM SYSIBM.SYSDUMMY1 WHERE 1 = 0 FOR FETCH ONLY; 
  
    OPEN TEMP_CURSOR2;
END ;
