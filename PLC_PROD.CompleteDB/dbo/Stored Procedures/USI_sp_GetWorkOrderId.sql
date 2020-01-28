CREATE PROCEDURE [dbo].[USI_sp_GetWorkOrderId]
	@productionLine char(4),
	@partNumber varchar(50),
	@workOrder char(6)
AS
	SET NOCOUNT ON;

	DECLARE
		@returnValue smallint,
		@returnMessage varchar(MAX),
		@productionLineId int,
		@partNumberId int,
		@partNumberProductionLineId int,
		@workOrderId int,
		@workOrderSize smallint;
		
	SET @productionLineId			= (SELECT [id]	FROM [USI_ProductionLine]				WHERE [productionLine] = @productionLine);
	SET @partNumberId				= (SELECT [id]	FROM [USI_PartNumber]					WHERE [partNumber] = @partNumber);
	SET @partNumberProductionLineId = (SELECT [id]	FROM [USI_PartNumber_ProductionLine]	WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId);
	
	IF @partNumberProductionLineId IS NOT NULL
		BEGIN
			SET @workOrderId = (SELECT [id] FROM [USI_WorkOrder] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [workOrder] = @workOrder);

			IF @workOrderId IS NULL
				BEGIN
					IF EXISTS(SELECT [id] FROM [USI_WorkOrder] WHERE [workOrder] = @workOrder)
						GOTO ErrorHandler;
					ELSE
						BEGIN
							INSERT INTO [USI_WorkOrder]	([partNumberProductionLineId]	,[workOrder]	,[pending]	)
												VALUES	(@partNumberProductionLineId	,@workOrder		,1			);
							SET @workOrderId = @@IDENTITY;
						END
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

			SET @returnValue = 0

			GOTO OutputRecordSet;
		END
	ELSE GOTO ErrorHandler;


	ErrorHandler:	
	IF @productionLineId IS NULL				SET @returnValue = -100;	--Ligne de production inexistante
	ELSE IF @partNumberId IS NULL				SET @returnValue = -101;	--Part number inexistant
	ELSE IF @partNumberProductionLineId IS NULL	SET @returnValue = -102;	--Lien inexistant entre le part number et la ligne de production
	ELSE IF @workOrderId IS NULL				SET @returnValue = -103;	--OF existant sur une autre ligne de production ou un autre part number
	SET @returnMessage = (SELECT [returnMessage] FROM [USI_ReturnMessage] WHERE [returnValue] = @returnValue);
	GOTO OutputRecordSet;


	OutputRecordSet:
	SELECT
		@returnValue AS [returnValue],
		@returnMessage AS [returnMessage],
		@workOrderId AS [workOrderId],
		@workOrderSize AS [workOrderSize];