CREATE PROCEDURE [dbo].[USI_sp_GetWorkOrderInfo]
	@productionLine char(4),
	@partNumber varchar(50),
	@workOrder char(6),
	@workOrderId int OUTPUT,
	@workOrderSize smallint OUTPUT
AS
	SET NOCOUNT ON;

	DECLARE
		@productionLineId int,
		@partNumberId int,
		@partNumberProductionLineId int;
		
	SET @productionLineId			= (SELECT [id]	FROM [USI_ProductionLine]				WHERE [productionLine] = @productionLine);
	SET @partNumberId				= (SELECT [id]	FROM [USI_PartNumber]					WHERE [partNumber] = @partNumber);
	SET @partNumberProductionLineId = (SELECT [id]	FROM [USI_PartNumber_ProductionLine]	WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId);
	
	IF @partNumberProductionLineId IS NULL
		RETURN -1
	ELSE
		BEGIN
			SET @workOrderId = (SELECT [id] FROM [USI_WorkOrder] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [workOrder] = @workOrder);

			IF @workOrderId IS NULL
				BEGIN
					INSERT INTO [USI_WorkOrder]	([partNumberProductionLineId]	,[workOrder]	,[pending]	)
										VALUES	(@partNumberProductionLineId	,@workOrder		,1			);
					SET @workOrderId = @@IDENTITY;
				END
			ELSE
				UPDATE [USI_WorkOrder] SET [pending] = 1 WHERE [id] = @workOrderId;

			UPDATE
				[USI_WorkOrder]
			SET
				[pending] = 0
			FROM
				[USI_WorkOrder]
				INNER JOIN [USI_PartNumber_ProductionLine]	ON [USI_PartNumber_ProductionLine].[id] = [USI_WorkOrder].[partNumberProductionLineId]
				INNER JOIN [USI_ProductionLine]				ON [USI_ProductionLine].[id] = [USI_PartNumber_ProductionLine].[productionLineId]
			WHERE
				[USI_WorkOrder].[id] <> @workOrderId AND [USI_ProductionLine].[productionLine] = @productionLine;

			RETURN 0;
		END