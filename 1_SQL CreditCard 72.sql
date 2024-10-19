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
-- #bl_class					Premier.Profile.CreditCardList
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


CREATE PROCEDURE [DBO].PRO_GetCreditCards
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
SET NOCOUNT ON
	DECLARE @Sort_Condition NVARCHAR(30)
	DECLARE @SQL_DYNAMIC	NVARCHAR(MAX)

	/* Resolve Sort Condition */
	IF (@SortBy = 'AlphaName') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'A.CCALPH ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'A.CCALPH DESC'
	END

	IF (@SortBy = 'ExpDate') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'A.CC$9VSEXDT ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'A.CC$9VSEXDT DESC'
	END

	SET @SQL_DYNAMIC =' 
	;WITH CREDITCARDS  AS 
	(SELECT 
		A.CC$9AN8		AS		AddressNumber,
		A.CC$9TYP		AS		AddressType,
		A.CCSEQ			AS		SequenceNumber,
		A.CCCARD		AS		CreditCardType,
		A.CCCRCI		AS		MaskedCCNumber,
		A.CC$9VSEXDT	AS		ExpDate,
		A.CC$9DEF		AS		IsDefault,
		A.CCALPH		AS		AlphaName,
		A.CCADD1		AS		AddressLine1,
		A.CCADD2		AS		AddressLine2,
		A.CCADDS		AS		State,
		A.CCADDZ		AS		ZipCodePostal,
		A.CCCTR			AS		Country,
		A.CCCTY1		AS		City,
		A.CCIDLN		AS		ContactId,
		A.CC$9VSGRP		AS		CCSelectionGroup,
		A.CC$9VSCCN		AS		EncryptedCCNumber,
		A.CCPID			AS		ProgramId,
		A.CCJOBN		AS		WorkStationId,
		A.CCUSER		AS		UserId,
		A.CCUPMJ		AS		DateUpdated,
		A.CCUPMT		AS		TimeLastUpdated,		
		CC$9CNM			AS		ConnectionName,
		A.CC$9DPT		AS		Department,		
		A.CC$9commt		AS		Comments,
		ROW_NUMBER() OVER (ORDER BY '+ @Sort_Condition +') AS RNUM,  
		COUNT(*) OVER () AS TotalRowCount   
		FROM [SCDATA].FQ67CCIF A
		WHERE A.CC$9AN8 =  @AddressNumber
			AND A.CC$9TYP = @AddressType '


	IF (@ContactID IS NOT NULL)
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND A.CCIDLN = @ContactID '

	IF (@SequenceNumber IS NOT NULL)
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND A.CCSEQ = @SequenceNumber '

	IF (@ConnectionName <> '*')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND (A.CC$9CNM = @ConnectionName OR A.CC$9CNM IN (SELECT B.MP$9CNM FROM [SCDATA].FQ67CCI1 B WHERE B.MP$9CCGRPK = (SELECT C.MP$9CCGRPK FROM [SCDATA].FQ67CCI1 C WHERE C.MP$9CNM = @ConnectionName ))) '		
	
	IF (@Department <> '*')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND A.CC$9DPT = @Department '		
			
	IF (@MaskedCCNumber <> '*')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND A.CCCRCI LIKE ''%'' + @MaskedCCNumber + ''%'' '
			
	IF (@AlphaName <> '*')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND A.CCALPH LIKE ''%'' + @AlphaName + ''%'' '	

	IF (@Status = 'A')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND DATEDIFF(M, GETDATE(),CC$9VSEXDT+''01'') >= 0 '				

	IF (@Status = 'I')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND DATEDIFF(M, GETDATE(),CC$9VSEXDT+''01'') < 0 '
			
			
	SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		) 
		SELECT AddressNumber, AddressType, SequenceNumber, CreditCardType, MaskedCCNumber,
			ExpDate, IsDefault, AlphaName, AddressLine1, AddressLine2  ,
			State, ZipCodePostal, Country, City, ContactId, CCSelectionGroup, EncryptedCCNumber,
			ProgramId, WorkStationId, UserId, DateUpdated, TimeLastUpdated, 
			[DBO].CMM_GetUserDefinedCodeFnc(''00'',''CA'', CreditCardType, ''*'') AS CreditCardDescription,
			ConnectionName, Department, [DBO].CMM_GetUserDefinedCodeFnc(''59'',''DE'', Department, @LangPref)  AS DepartmentDescription,
			Comments, TotalRowCount 
		FROM CREDITCARDS
		WHERE ((@PageIndex = 0 OR @PageSize = 0) OR (RNUM BETWEEN (@PageSize * @PageIndex) - @PageSize + 1 AND @PageIndex * @PageSize))';

	EXECUTE sp_executesql @SQL_DYNAMIC, N'	
	@AddressNumber		FLOAT,
	@AddressType		FLOAT,
	@ContactID			FLOAT,
	@SequenceNumber		FLOAT ,
	@ConnectionName		NVARCHAR(100),
	@Department 		NVARCHAR(10),
	@AlphaName			NVARCHAR(40),
	@MaskedCCNumber		NVARCHAR(40),
	@Status				NVARCHAR(1),
	@SortBy				NVARCHAR(30),
	@SortDir			NVARCHAR(1),
	@PageIndex			FLOAT,
	@PageSize			FLOAT,
	@LangPref			NVARCHAR(2)'	,
	@AddressNumber		=@AddressNumber ,	
	@AddressType		=@AddressType	,
	@ContactID			=@ContactID		,
	@SequenceNumber		=@SequenceNumber,	
	@ConnectionName		=@ConnectionName,	
	@Department 		=@Department 	,
	@AlphaName			=@AlphaName			,
	@MaskedCCNumber		=@MaskedCCNumber	,	
	@Status				=@Status		,
	@SortBy				=@SortBy		,
	@SortDir			=@SortDir		,
	@PageIndex			=@PageIndex		,
	@PageSize			=@PageSize		,
	@LangPref			=@LangPref		

SET NOCOUNT OFF

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
	DECLARE @SurchargeAmount     FLOAT

	SELECT		
		@SurchargeAmount = A.RUAG	
	FROM [SCDATA].F03B13Z1 A		
	LEFT OUTER JOIN [SCDATA].FQ670045 B
		ON  B.SUEDUS = A.RUEDUS
		AND B.SUEDBT = A.RUEDBT
		AND B.SUEDTN = A.RUEDTN
		AND B.SUEDLN = A.RUEDLN	
	WHERE A.RUEDUS = @EdiUserId 
		AND A.RUEDBT = @EdiBatNumber 
		AND A.RUEDTN = @EdiTransactionNumber
		AND B.SUEDBT IS NOT NULL

	IF (@SurchargeAmount = '' OR @SurchargeAmount IS NULL)
	BEGIN
		SET @SurchargeAmount = 0
	END

	SELECT	
		A.RUAN8					AS	AddressNumber,
		D.WWMLNM				AS	MailingName,
		A.RUICU					AS	AccountingBatchNumber,
		A.RUEDBT				AS	EdiBatchNumber,
		A.RUEDTN				AS	TransactionNumber,
		A.RUDMTJ				AS	PaymentDate,
		A.RUCKAM				AS	PaymentAmount, 
		CASE WHEN A.RUCKAM > 0 AND @SurchargeAmount > 0 THEN @SurchargeAmount ELSE 0 END AS SurchargeAmount,
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

	DECLARE @CodeLengthCCType INTEGER;
	DECLARE @CodeLengthDep INTEGER;
	
	/* Get UDC Code Lengths*/
	SET @CodeLengthCCType = 0;
	SET @CodeLengthCCType = (SELECT DTCDL FROM [SCCTL].F0004 WHERE DTSY = '00' AND DTRT = 'CA');	

	SET @CodeLengthDep = 0;
	SET @CodeLengthDep = (SELECT DTCDL FROM [SCCTL].F0004 WHERE DTSY = '59' AND DTRT = 'DE');
		
	
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
		ISNULL(B.DRDL01, A.DRDL01) AS CreditCardDescription,
		ISNULL(D.DRDL01, C.DRDL01) AS DepartmentDescription
	FROM [SCDATA].FQ67CCIF 
	INNER JOIN [SCCTL].F0005 A
		ON A.DRSY = '00' AND A.DRRT = 'CA' 
		AND A.DRKY =  REPLICATE(' ' ,10 - @CodeLengthCCType ) +  LTRIM(CCCARD)        	
	LEFT OUTER JOIN [SCCTL].F0005D B
	    ON B.DRSY = A.DRSY 
	    AND B.DRRT = A.DRRT
	    AND B.DRKY = A.DRKY	
		AND B.DRLNGP = @LangPref	
			       
	LEFT OUTER JOIN [SCCTL].F0005 C
	    ON  C.DRSY = '59' 
		AND C.DRRT = 'DE'
		AND C.DRKY =  REPLICATE(' ' ,10 - @CodeLengthDep ) + LTRIM(CC$9DPT) 
	LEFT OUTER JOIN [SCCTL].F0005D D
	    ON  D.DRSY = C.DRSY 
	    AND D.DRRT = C.DRRT
	    AND D.DRKY = C.DRKY
		AND D.DRLNGP = @LangPref	

	WHERE CC$9AN8 = @AddressNumber 
		AND CC$9TYP = @AddressType 
		AND (@ContactID is null or CCIDLN = @ContactID) 	
		AND CCSEQ = @SequenceNumber;    	
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
	DECLARE @CreditCardsCount INTEGER;
	DECLARE @DefaultCreditCard INTEGER;
	
	SELECT @CreditCardsCount = COUNT(1) FROM [SCDATA].FQ67CCIF A WHERE A.CC$9AN8 = @AddressNumber AND A.CC$9TYP = @AddressType;
	SELECT @DefaultCreditCard = CCSEQ FROM [SCDATA].FQ67CCIF A WHERE A.CC$9AN8 = @AddressNumber AND A.CC$9TYP = @AddressType AND A.CC$9DEF = 1;

	SELECT 
		@CreditCardsCount AS CreditCardsCount,
		@DefaultCreditCard AS DefaultCreditCard

SET NOCOUNT OFF
GO
