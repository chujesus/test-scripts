IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND id = OBJECT_ID(N'[DBO].CMM_GetUserDefinedCodeFnc'))
	BEGIN
		DROP  FUNCTION  [DBO].CMM_GetUserDefinedCodeFnc
	END
GO
 
-- #desc						Return the first description
-- #bl_class					N/A
-- #db_dependencies				N/A
-- #db_references				N/A

-- #param @ProductCode			Product Code
-- #param @UserDefinedCode		User Defined Code 
-- #param @UserDefinedKey		User Defined Key
-- #param @LangPref				Lang Pref

CREATE FUNCTION [DBO].CMM_GetUserDefinedCodeFnc
(
	@ProductCode		NVARCHAR(4),
	@UserDefinedCode	NVARCHAR(2),
	@UserDefinedKey		NVARCHAR(10),
	@LangPref			NVARCHAR(2)
)
RETURNS NVARCHAR(30)
AS
BEGIN
	
	DECLARE	@CodeLength INT
	DECLARE @Description NVARCHAR(30);

	-- Get Code Length
	SET @CodeLength = 0
	SET @CodeLength = (SELECT DTCDL FROM [SCCTL].F0004 
						WHERE DTSY = @ProductCode AND DTRT = @UserDefinedCode)

	-- set UserDefinedKey with blank spaces
	SET @UserDefinedKey = REPLICATE(' ' , 10 - @CodeLength) + @UserDefinedKey
	
	IF (@LangPref = '*')
	BEGIN
		SET @Description = (SELECT A.DRDL01
			FROM [SCCTL].F0005 A
			WHERE A.DRSY = @ProductCode
				AND A.DRRT = @UserDefinedCode
				AND A.DRKY = @UserDefinedKey
		)
	END
	ELSE
	BEGIN
		SET @Description = (SELECT ISNULL(B.DRDL01,A.DRDL01)
			FROM	[SCCTL].F0005 A
			LEFT OUTER JOIN [SCCTL].F0005D B
				ON B.DRSY = @ProductCode
				AND B.DRRT = @UserDefinedCode
				AND B.DRKY = @UserDefinedKey
				AND B.DRLNGP = @LangPref
			WHERE
					A.DRSY = @ProductCode
				AND A.DRRT = @UserDefinedCode
				AND A.DRKY = @UserDefinedKey
		)
	END
	RETURN @Description;
END
GO

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].PRO_GetCreditCards'))
	BEGIN
		DROP  Procedure  [DBO].PRO_GetCreditCards
	END

GO

-- #desc						Return empty
-- #bl_class					Premier.Profile.CreditCardList.cs
-- #db_dependencies				N/A
-- #db_references				N/A	

-- #param @AddressNumber		Address Number
-- #param @AddressType			AddressBook Type
-- #param @ContactID			Contact ID Number
-- #param @SequenceNumber		Credit Card Sequence Number (OPTIONAL)
-- #param @ConnectionName		The Parameter is only from Ecommerce (POS and MC send empty)
-- #param @Department			Department code to filter UDC 59/DE
-- #param @AlphaName			Name to filter
-- #param @MaskedCCNumber		Masked Card Number to filter
-- #param @Status				Active = A, Inactive = I, Any = *
-- #param @SortBy				Column to filter by
-- #param @SortDir				Direction to filter (A = Ascendent, D = Descendent) 
-- #param @PageIndex			Page Index
-- #param @PageSize				Page Size
-- #param @LangPref				Language Preference

CREATE Procedure [DBO].PRO_GetCreditCards
(
	@AddressNumber	FLOAT,
	@AddressType	FLOAT,
	@ContactID		FLOAT = NULL,
	@SequenceNumber FLOAT = NULL,
	@ConnectionName NVARCHAR(100),
	@Department 	NVARCHAR(10),
	@AlphaName		NVARCHAR(40),
	@MaskedCCNumber	NVARCHAR(40),
	@Status			NVARCHAR(1),
	@SortBy			NVARCHAR(30),
	@SortDir		NVARCHAR(1),
	@PageIndex		FLOAT,
    @PageSize		FLOAT,
	@LangPref		NVARCHAR(2)
)
AS

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
		' ' AS Comments,
		' ' AS DepartmentDescription,
		0   AS TotalRowCount
		where 1=0

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].COM_GetInvoicePayConfirmList'))
	BEGIN
		DROP  Procedure  [DBO].COM_GetInvoicePayConfirmList
	END
GO

-- #desc							Invoice Payment Confirmation List
-- #bl_class						Premier.Commerce.InvoicePayConfirmDetailList.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @EdiUserId				Edi User Id
-- #param @EdiBatNumber				Edi Batch Number
-- #param @EdiTransactionNumber		Edi Transaction Number
 --#param @LangPref					Lang Pref

CREATE Procedure [DBO].COM_GetInvoicePayConfirmList
(
	 @EdiUserId					NVARCHAR(20),
	 @EdiBatNumber				NVARCHAR(30),
	 @EdiTransactionNumber		NVARCHAR(44),
	 @LangPref					NVARCHAR(2)
)
AS
	SELECT	
		A.RUAN8					AS	AddressNumber,
		D.WWMLNM				AS	MailingName,
		A.RUICU					AS	AccountingBatchNumber,
		A.RUEDBT				AS	EdiBatchNumber,
		A.RUEDTN				AS	TransactionNumber,
		A.RUDMTJ				AS	PaymentDate,
		A.RUCKAM				AS	PaymentAmount,
		0                       AS  SurchargeAmount,
		ISNULL(A.RUCRCD,'USD')	AS	CurrencyCode,
		A.RURMK					AS	Remark,
		A.RUCKNU				AS	PaymentReference,
		A.RUPYIN				AS	PaymentInstrument,
		[DBO].CMM_GetUserDefinedCodeFnc('00','PY',A.RUPYIN,@LangPref) AS PaymentInstrumentDesc,
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
		ON  C.SUEDUS = A.RUEDUS
		AND C.SUEDBT = A.RUEDBT
		AND C.SUEDTN = A.RUEDTN
		AND C.SUEDLN = A.RUEDLN
	INNER JOIN  [SCDATA].F0111 D
		ON D.WWAN8 = A.RUAN8 
		AND D.WWIDLN = 0
	WHERE A.RUEDUS = @EdiUserId 
		AND A.RUEDBT = @EdiBatNumber 
		AND A.RUEDTN = @EdiTransactionNumber 
		AND C.SUEDBT IS NULL  
	ORDER BY InvoiceType, InvoiceNumber, InvoiceSuffix
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].PRO_GetCreditCardInfo'))
	BEGIN
		DROP  Procedure  [DBO].PRO_GetCreditCardInfo
	END

GO		

-- #desc						Fetch Credit Card for Customer/Consumer 
-- #bl_class	 	 			Premier.Profile.CreditCardInfo.cs
-- #db_dependencies				N/A
-- #db_references				N/A		

-- #param @AddressNumber		Address Number 
-- #param @AddressType			AddressBook Type 
-- #param @ContactID			Contact ID Number 
-- #param @SequenceNumber		Credit Card Sequence Number 
-- #param @LangPref				Language Preference 

CREATE Procedure [DBO].PRO_GetCreditCardInfo
(
	@AddressNumber	FLOAT,
	@AddressType	FLOAT,
	@ContactID		FLOAT,
	@SequenceNumber	FLOAT,
    @LangPref       NVARCHAR(2)
)
AS	
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
	 WHERE 1 = 0 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].PRO_GetCreditCardsSummary'))
	BEGIN
		DROP PROCEDURE [DBO].PRO_GetCreditCardsSummary
	END
GO
	
-- #desc						Calculate Credit Cards count and default CC 
-- #bl_class	 	 			N/A 
-- #db_dependencies				N/A
-- #db_references				ECO_GetAccountSummaryInfo 

-- #param AddressNumber			Address Number 
-- #param AddressType			AddressBook Type

CREATE PROCEDURE [DBO].PRO_GetCreditCardsSummary
(
	@AddressNumber	FLOAT,
	@AddressType	FLOAT
)
AS
SET NOCOUNT ON
	SELECT 
		0 AS CreditCardsCount,
		0 AS DefaultCreditCard
	WHERE 1 = 0;
SET NOCOUNT OFF
GO
