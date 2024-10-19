IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].COM_ExcUpdAvaTaxOrderNumber'))
	BEGIN
		DROP  Procedure  [DBO].COM_ExcUpdAvaTaxOrderNumber
	END

GO

-- #desc						Execute Update Avatax Order Number
-- #bl_class					Premier.Commerce.AvaTaxIntegration.cs

-- param TransactionsKey		Transactions Key
-- param AddressNumber			Address Number
-- param OrderNumber			Order Number
-- param OrderKey				Order Key

CREATE PROCEDURE [DBO].COM_ExcUpdAvaTaxOrderNumber
(
	@TransactionsKey	NVARCHAR(22),
	@AddressNumber		FLOAT,
	@OrderKey			NVARCHAR(22)
)
AS

	UPDATE [SCDATA].FQ67AT06 
	SET AD$9ATDOCCD = @OrderKey
    WHERE EXISTS(
		SELECT * FROM [SCDATA].FQ67AT05 HEADER
		WHERE AD$9ATDOCCD = AH$9ATDOCCD AND
		ADTDAY = AHTDAY AND
		ADUSER = AHUSER AND
		ADMKEY = AHMKEY AND
		ADUPMJ =  AHUPMJ AND
		ADTDAY = AHTDAY AND
		ADSEQ = AHSEQ AND
		AH$9ATDOCCD = @TransactionsKey AND
		AH$9ATCUSCD = @AddressNumber
	);

	UPDATE [SCDATA].FQ67AT05
	SET 
		AH$9ATDOCCD = @OrderKey	
	WHERE 
		AH$9ATDOCCD = @TransactionsKey AND
		AH$9ATCUSCD = @AddressNumber;

GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].COM_GetAvaTaxECMCompanyCode'))
	BEGIN
		DROP  Procedure [DBO].COM_GetAvaTaxECMCompanyCode
	END
GO

-- #desc					Get AvaTax ECM Company
-- #bl_class				Premier.Commerce.AvaTaxECMIntegration.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @Company	Company

CREATE PROCEDURE [DBO].[COM_GetAvaTaxECMCompanyCode]
(
	@Company		NVARCHAR(10)
)

AS

SELECT	
	AC$9ATCOCD AS AvaTaxCompany
FROM 
	[SCDATA].FQ67AT02
WHERE          
	-- Company filter
    ACCO = @Company

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND id = OBJECT_ID(N'[DBO].COM_GetAvaTaxECMList'))
	BEGIN
		DROP  Procedure [DBO].COM_GetAvaTaxECMList
	END
GO

-- #desc					Get Exemption Certificate List
-- #bl_class				Premier.Commerce.AvaTaxECMCustomerCertList.cs
-- #db_dependencies			N/A
-- #db_references			N/A

-- #param @CustomerNumber	Customer Number
-- #param @AvaTaxCompany	AvaTax Company
-- #param @RegionFilter		Region
-- #param @StatusFilter		Status
-- #param @ReturnRegionList return the region list		
-- #param SortBy			Column to filter by
-- #param SortDir			Direction to filter (A = Ascendant, D = Descendant)
-- #param PageIndex			Page Index 
-- #param PageSize			Page Size

CREATE PROCEDURE [DBO].COM_GetAvaTaxECMList
	 @CustomerNumber	FLOAT,
	 @AvaTaxCompany		NVARCHAR(25),
	 @RegionFilter		NVARCHAR(30),
	 @StatusFilter		NVARCHAR(20),
	 @ReturnRegionList	INT,
	 @SortBy			NVARCHAR(40),
	 @SortDir			NVARCHAR(3),
	 @PageIndex			FLOAT,
	 @PageSize			FLOAT
AS
	DECLARE @Sort_Condition NVARCHAR(30)
	DECLARE @SQL_DYNAMIC	NVARCHAR(MAX)

	/* Resolve Sort Condition */

	IF (@SortBy = 'CertificateId') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'EC$9CRID ASC, EC$9ECMRGN ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'EC$9CRID DESC, EC$9ECMRGN ASC'
	END	
	ELSE IF (@SortBy = 'Region') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'EC$9ECMRGN ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'EC$9ECMRGN DESC'
	END
	ELSE IF (@SortBy = 'EffectiveDate') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'EC$9ECMCRD ASC, EC$9ECMRGN ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'EC$9ECMCRD DESC, EC$9ECMRGN ASC'
	END
	ELSE IF (@SortBy = 'ExpirationDate') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'EC$9ECMEXD ASC, EC$9ECMRGN ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'EC$9ECMEXD DESC, EC$9ECMRGN ASC'
	END
	ELSE IF (@SortBy = 'ExemptionReason') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'EC$9EXRES ASC, EC$9ECMRGN ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'EC$9EXRES DESC, EC$9ECMRGN ASC'
	END
	ELSE IF (@SortBy = 'Status') BEGIN
		IF(@SortDir = 'A')
			SET @Sort_Condition = 'EC$9ECMSTS ASC, EC$9ECMRGN ASC'
		IF(@SortDir = 'D')
			SET @Sort_Condition = 'EC$9ECMSTS DESC, EC$9ECMRGN ASC'
	END
	ELSE 
		SET @Sort_Condition = 'EC$9CRID ASC, EC$9ECMRGN ASC'

	SET @SQL_DYNAMIC =' 
	;WITH ECM AS 
	(SELECT  
			EC$9CRID	AS CertificateId, 
			EC$9ATCUSCD	AS CustomerNumber,
			EC$9ECMRGN	AS Region,
			EC$9ECMCRD	AS EffectiveDate, 
			EC$9ECMEXD	AS ExpirationDate,
			EC$9EXRES	AS ExemptionReason,
			EC$9ECMSTS	AS Status,
			ROW_NUMBER() OVER (ORDER BY '+ @Sort_Condition +') AS RNUM,  
			COUNT(*) OVER () AS TotalRowCount 
		FROM  
			[SCDATA].FQ67AT17	
		WHERE EC$9ATCUSCD = @CustomerNumber
			AND EC$9ATCOCD = @AvaTaxCompany '
	
	IF (@RegionFilter <> '*')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND EC$9ECMRGN LIKE ''%'' + @RegionFilter + ''%'' '

	IF (@StatusFilter <> '*')
		SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		AND EC$9ECMSTS = @StatusFilter '
	
	SET @SQL_DYNAMIC = @SQL_DYNAMIC + N'
		) 
		SELECT CertificateId, CustomerNumber, Region, EffectiveDate, ExpirationDate,
			ExemptionReason, Status, TotalRowCount
		FROM ECM
		WHERE ((@PageIndex = 0 OR @PageSize = 0) OR (RNUM BETWEEN (@PageSize * @PageIndex) - @PageSize + 1 AND @PageIndex * @PageSize))';
	
	EXECUTE sp_executesql @SQL_DYNAMIC, N'	
		@CustomerNumber		FLOAT,
		@AvaTaxCompany		NVARCHAR(25),
		@RegionFilter		NVARCHAR(30),
		@StatusFilter		NVARCHAR(20),
		@SortBy				NVARCHAR(30),
		@SortDir			NVARCHAR(1),
		@PageIndex			INT,
		@PageSize			INT',
		@CustomerNumber		=@CustomerNumber,
		@AvaTaxCompany		=@AvaTaxCompany,	
		@RegionFilter		=@RegionFilter,
		@StatusFilter		=@StatusFilter,
		@SortBy				=@SortBy,
		@SortDir			=@SortDir,
		@PageIndex			=@PageIndex,
		@PageSize			=@PageSize

	IF(@ReturnRegionList = 1)	
	BEGIN
		SELECT DISTINCT
			EC$9ECMRGN	AS Region			
		FROM [SCDATA].FQ67AT17 
		WHERE EC$9ATCUSCD = @CustomerNumber
			AND EC$9ATCOCD = @AvaTaxCompany;
	END

SET NOCOUNT OFF
GO


