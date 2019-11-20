CREATE PROCEDURE [dbo].[USI_sp_SetMeasurement]
	@partId bigint,
	@characteristic varchar(256),
	@value decimal(7, 4),
	@valid bit
AS
	SET NOCOUNT ON;

	DECLARE
		@characteristicId int;

	SET @characteristicId = 
		(
		SELECT [USI_Characteristic].[id]
		FROM [USI_Characteristic]
		INNER JOIN [USI_PartNumber_ProductionLine]	ON [USI_PartNumber_ProductionLine].[id]			= [USI_Characteristic].[partNumberProductionLineId]
		INNER JOIN [USI_WorkOrder]					ON [USI_WorkOrder].[partNumberProductionLineId] = [USI_PartNumber_ProductionLine].[id]
		INNER JOIN [USI_Part]						ON [USI_Part].[workOrderId]						= [USI_WorkOrder].[id]
		WHERE
			[USI_Part].[id] = @partId
			AND [USI_Characteristic].[characteristic] = @characteristic
		)
	
	IF @characteristicId IS NULL
		RETURN -1
	ELSE
		BEGIN
			INSERT INTO [USI_Measurement]	([partId]	,[characteristicId]	,[value]	,[valid])
							VALUES			(@partId	,@characteristicId	,@value		,@valid	)

			RETURN 0;
		END

