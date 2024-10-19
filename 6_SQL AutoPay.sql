IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].COM_GetInvAutoPayRuleList'))
	BEGIN
		DROP  Procedure  [DBO].COM_GetInvAutoPayRuleList
	END
GO

-- #desc							Get the Invoice Auto Pay Rule List
-- #bl_class						Premier.Commerce.InvoiceAutoPayRuleList.cs
-- #db_dependencies					N/A
-- #db_references					N/A

-- #param @StoreId					Store Id
-- #param @CustomerNumber			Customer Number
-- #param @RuleName					Rule Name
-- #param @RuleId					Rule Id
-- #param @CurrencyCode				Currency Code
-- #param @StartDateFrom			Start Date From
-- #param @StartDateTo				Start Date To
-- #param @ExpirationDateFrom		Expiration Date From
-- #param @ExpirationDateTo			Expiration Date To
-- #param @Status					Status
-- #param @SortBy					Sort By Column name
-- #param @SortDir					Sort Dir ASC / DESC
-- #param @PageIndex				Page Index
-- #param @PageSize					Page Size

CREATE PROCEDURE [DBO].COM_GetInvAutoPayRuleList

	@StoreId		NVARCHAR(3),
	@CustomerNumber FLOAT,
	@RuleName		NVARCHAR(40),
	@RuleId		FLOAT,
	@StartDateFrom	NUMERIC,
	@StartDateTo		NUMERIC,
	@ExpirationDateFrom		NUMERIC,
	@ExpirationDateTo			NUMERIC,
	@CurrencyCode		NVARCHAR(3),
	@Status		FLOAT,
	@SortBy				NVARCHAR(20),
	@SortDir			NVARCHAR(1),
	@PageIndex			FLOAT,
    @PageSize			FLOAT
AS
BEGIN	

	/* Dynamic */
	DECLARE @SQL_DYNAMIC 				NVARCHAR(MAX)
	DECLARE @WHERE_DYNAMIC 				NVARCHAR(MAX) = ''
	DECLARE @SORT_DYNAMIC				NVARCHAR(60)
	DECLARE @SORTDIR_DYNAMIC			NVARCHAR(5)
	DECLARE @INNER_DYNAMIC	 			NVARCHAR(MAX) = ''

	/* Document Restrictions for Auto Pay */
	DECLARE	@ArRestric	 NVARCHAR(256)
	DECLARE @ArINID		 NVARCHAR(3)
	DECLARE @ArConstant    NVARCHAR(10)

	SET @ArConstant = 'AUTPAY_DOC';
	SET @ArINID = @StoreId;
	EXEC [DBO].CMM_GetConstantValue @ArConstant, @ArINID out, @ArRestric out

	/* Company Restrictions for Auto Pay */	
	DECLARE	@CoRestric	 NVARCHAR(256)
	DECLARE @CoINID		 NVARCHAR(3)
	DECLARE @CoConstant		NVARCHAR(256)

	SET @CoConstant = 'INSCOMPANY';
	SET @CoINID = @StoreId;
	EXEC [DBO].CMM_GetConstantValue @CoConstant, @CoINID out, @CoRestric out

	/*-----------------------------------------------------------------------------*/
	DECLARE @TODAY NUMERIC;
	SET @Today = [DBO].CMM_GetCurrentJulianDate (GETDATE());

	/* Dynamic sort direction statement */
    SET @SORTDIR_DYNAMIC = CASE @SortDir WHEN 'A' THEN ' ASC' WHEN 'D' THEN ' DESC' ELSE '' END

    /* Dynamic sort statement */
    SET @SORT_DYNAMIC = CASE @SortBy 
        WHEN 'RuleId' THEN 'RuleId ' + @SORTDIR_DYNAMIC + ', StartDate DESC'
        WHEN 'RuleName' THEN 'RuleName ' + @SORTDIR_DYNAMIC + ', RuleId DESC'
        WHEN 'Currency' THEN 'Currency ' + @SORTDIR_DYNAMIC + ', RuleId DESC'
        WHEN 'PaymentType' THEN 'PaymentType ' + @SORTDIR_DYNAMIC + ', RuleId DESC'
        WHEN 'PaymentDate' THEN 'PaymentDate ' + @SORTDIR_DYNAMIC + ', RuleId DESC'
        WHEN 'StartDate' THEN 'StartDate ' + @SORTDIR_DYNAMIC + ', RuleId DESC'
        WHEN 'Duration' THEN 'Duration ' + @SORTDIR_DYNAMIC + ', RuleId DESC' 
        ELSE 'StartDate ASC, RuleId DESC'
    END
	
	/* Dynamic query conditions */
	IF (@CustomerNumber IS NOT NULL) BEGIN
		SET @WHERE_DYNAMIC = N'A.AR$9AN8 = @CustomerNumber'
	END 
	
	IF (@RuleName <> '*') BEGIN
		IF (@WHERE_DYNAMIC <> N'') BEGIN
			SET @WHERE_DYNAMIC += N' AND '
		END
		SET @WHERE_DYNAMIC += N'A.ARDSC1 LIKE ''%'' + @RuleName + ''%'''
	END
	
	IF (@RuleId IS NOT NULL) BEGIN
		IF (@WHERE_DYNAMIC <> N'') BEGIN
			SET @WHERE_DYNAMIC += N' AND '
		END
		SET @WHERE_DYNAMIC += N'A.AR$9UKID = @RuleId'
	END

	IF (@StartDateFrom IS NOT NULL) BEGIN
		IF (@WHERE_DYNAMIC <> N'') BEGIN
			SET @WHERE_DYNAMIC += N' AND '
		END
		SET @WHERE_DYNAMIC += N'A.AREFFF >= @StartDateFrom'
	END
	
	IF (@StartDateTo IS NOT NULL) BEGIN
		IF (@WHERE_DYNAMIC <> N'') BEGIN
			SET @WHERE_DYNAMIC += N' AND '
		END
		SET @WHERE_DYNAMIC += N'A.AREFFF <= @StartDateTo'
	END
	
	IF (@ExpirationDateFrom IS NOT NULL) BEGIN
		IF (@WHERE_DYNAMIC <> N'') BEGIN
			SET @WHERE_DYNAMIC += N' AND '
		END
		SET @WHERE_DYNAMIC += N'A.AR$9APAYSD >= @ExpirationDateFrom'
	END
	
	IF (@ExpirationDateTo IS NOT NULL) BEGIN
		IF (@WHERE_DYNAMIC <> N'') BEGIN
			SET @WHERE_DYNAMIC += N' AND '
		END
		SET @WHERE_DYNAMIC += N'A.AR$9APAYSD <= @ExpirationDateTo'
	END
	
	IF (@CurrencyCode <> '*') BEGIN
		IF (@WHERE_DYNAMIC <> N'') BEGIN
			SET @WHERE_DYNAMIC += N' AND '
		END
		SET @WHERE_DYNAMIC += N'A.ARCRCD = @CurrencyCode'
	END
	
	IF (@Status <> 4) BEGIN
		IF (@Status = 2) BEGIN /*Expired*/
			IF (@WHERE_DYNAMIC <> N'') BEGIN
				SET @WHERE_DYNAMIC += N' AND '
			END
			SET @WHERE_DYNAMIC += N'A.AR$9APAYSD <= @Today AND A.AR$9APAYEX = 2'
		END
		ELSE BEGIN
			IF (@WHERE_DYNAMIC <> N'') BEGIN
				SET @WHERE_DYNAMIC += N' AND '
			END
			SET @WHERE_DYNAMIC += N'NOT (A.AR$9APAYSD <= @Today AND A.AR$9APAYEX = 2)'
			IF (@Status = 3) BEGIN /*Future*/
				SET @WHERE_DYNAMIC += N' AND A.AREFFF > @Today'
			END
			ELSE BEGIN
				SET @WHERE_DYNAMIC += N' AND A.AR$9STS = @Status AND A.AREFFF <= @Today'
				IF (@Status = 1) BEGIN /*On Hold*/
					SET @WHERE_DYNAMIC += N' AND A.AREFFF < A.ARRDJ'
				END
			END
		END	
	END

	IF (@CoRestric = 'L') BEGIN
		SET @INNER_DYNAMIC = N' INNER JOIN (
		SELECT DISTINCT 
				RC.RC$9UKID 
		FROM (
			SELECT  
					C.RC$9AN8,
					C.RC$9UKID,
					C.RCCO
			FROM [SCDATA].FQ670316 C 
			WHERE C.RC$9AN8 = @CustomerNumber) RC 
		INNER JOIN (
			SELECT 
					CR.CI$9INID,
					CR.CICO 
			FROM [SCDATA].FQ679912 CR 
			WHERE CR.CI$9INID = @CoINID) REC ON REC.CICO = RC.RCCO) RR
		ON RuleId = RR.RC$9UKID '
	END

	IF (@ArRestric = N'1' ) BEGIN
		SET @INNER_DYNAMIC += N' INNER JOIN (
		SELECT DISTINCT 
				RT.RI$9UKID 
		FROM (
			SELECT
					T.RI$9AN8, 
					T.RI$9UKID, 
					T.RIDCT
			FROM [SCDATA].FQ670317 T 
			WHERE T.RI$9AN8 = @CustomerNumber) RT 
		INNER JOIN (
			SELECT 
					IT.DR$9INID,
					IT.DR$9CNST,
					IT.DRKY
			FROM [SCDATA].FQ67008 IT 
			WHERE IT.DR$9INID = @ArINID AND IT.DR$9CNST = @ArConstant) RET 
		ON RET.DRKY = RT.RIDCT) R
		ON RuleId = R.RI$9UKID '
	END

	BEGIN
	SET @SQL_DYNAMIC = N'
		SELECT	
				A.AR$9AN8	AS		CustomerNumber,
				A.AR$9TYP	AS		Type,
				A.AR$9UKID	AS		RuleId,
				A.ARDSC1	AS		RuleName,
				A.AR$9STS		AS		Status,
				A.ARRDJ	AS		ReleaseDate,
				A.ARRYIN	AS		PaymentType,
				A.AR$9APIBO		AS		PaymentDate,
				A.AR$9APIBOV	AS		PaymentDateValue,
				A.ARMCU	AS		BranchPlant,
				A.ARCRCD	AS		Currency,   
				A.ARSEQ	AS		CCSequence,
				A.ARIDLN	AS		CCLineId,   
				A.ARUKID	AS		BankAccountUniqueId,
				A.AR$9APAYA		AS		PaymentAmount,
				A.AR$9APAYAV	AS		PaymentAmountValue,
				A.AREFFF	AS		StartDate,
				A.AR$9APAYEX	AS		Duration,
				A.AR$9APAYSD	AS		ExpirationDate, 
				A.AR$9APAYNP	AS		NumberOfPayments
		INTO #TMP_TABLE
		FROM 	[SCDATA].FQ670315	A	 		  
		WHERE ' + @WHERE_DYNAMIC;
	END
	/* Dynamic query */

	SET @SQL_DYNAMIC += N'
	
	;WITH PAGING AS
	(
	SELECT 
		CustomerNumber,
		Type,
		RuleId,
		RuleName,
		Status,
		ReleaseDate,
		PaymentType,
		PaymentDate,
		PaymentDateValue,
		BranchPlant,
		Currency,
		CCSequence,
		CCLineId,
		BankAccountUniqueId,
		PaymentAmount,
		PaymentAmountValue,
		StartDate,
		Duration,
		ExpirationDate,
		NumberOfPayments,
		ROW_NUMBER() OVER (ORDER BY ' + @SORT_DYNAMIC + ') AS RNUM
	FROM #TMP_TABLE '
	+ @INNER_DYNAMIC + '
	)
	SELECT
		CustomerNumber,
		Type,
		RuleId,
		RuleName,
		Status,
		ReleaseDate,
		PaymentType,
		PaymentDate,
		PaymentDateValue,
		BranchPlant,
		Currency,
		CCSequence,
		CCLineId,
		BankAccountUniqueId,
		PaymentAmount,
		PaymentAmountValue,
		StartDate,
		Duration,
		ExpirationDate,
		NumberOfPayments,
		TotalRowCount = (SELECT COUNT(1) FROM PAGING)
	FROM PAGING

	WHERE ((@PageIndex = 0 OR @PageSize = 0) OR ( RNUM BETWEEN (@PageSize * @PageIndex) - @PageSize + 1 AND @PageIndex * @PageSize)) ';

	EXECUTE sp_executesql @SQL_DYNAMIC, N'
	@StoreId		NVARCHAR(3),
	@CustomerNumber FLOAT,
	@RuleName		NVARCHAR(40),
	@RuleId		FLOAT,
	@StartDateFrom	NUMERIC,
	@StartDateTo		NUMERIC,
	@ExpirationDateFrom		NUMERIC,
	@ExpirationDateTo			NUMERIC,
	@CurrencyCode		NVARCHAR(3),
	@Status		FLOAT,
	@ArINID				NVARCHAR(3),
	@ArConstant			NVARCHAR(10),
	@ArRestric			NVARCHAR(256),
	@CoINID				NVARCHAR(3),
	@CoConstant			NVARCHAR(256),
	@CoRestric		NVARCHAR(256),
	@PageIndex			FLOAT,
    @PageSize			FLOAT,
	@Today				NUMERIC',
	@StoreId = @StoreId,
	@CustomerNumber = @CustomerNumber,
	@RuleName = @RuleName, 
	@RuleId = @RuleId,	
	@StartDateFrom = @StartDateFrom, 
	@StartDateTo = @StartDateTo,
	@ExpirationDateFrom = @ExpirationDateFrom,
	@ExpirationDateTo = @ExpirationDateTo,
	@CurrencyCode = @CurrencyCode,
	@Status = @Status,	
	@ArINID = @ArINID,
	@ArConstant = @ArConstant,
	@ArRestric = @ArRestric,
	@CoRestric = @CoRestric,
	@CoINID = @CoINID,
	@CoConstant = @CoConstant,
	@PageIndex = @PageIndex, 
	@PageSize = @PageSize,
	@Today = @Today

END

GO
