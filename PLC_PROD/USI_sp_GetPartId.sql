CREATE PROCEDURE [dbo].[USI_sp_GetPartId]
	@workOrderId int
AS
	SET NOCOUNT ON;

	DECLARE
		@returnValue smallint,
		@returnMessage varchar(MAX),
		@partId bigint;

	IF EXISTS(SELECT * FROM [USI_WorkOrder] WHERE [id] = @workOrderId)
		BEGIN
			INSERT INTO [USI_Part]([workOrderId]) VALUES (@workOrderId);
			SET @partId = @@IDENTITY;
			SET @returnValue = 0;
			GOTO OutputRecordSet;
		END
	ELSE
		GOTO ErrorHandler;


	ErrorHandler:
	SET @returnValue = -110;	--workOrderId inexistant
	SET @returnMessage = (SELECT [returnMessage] FROM [USI_ReturnMessage] WHERE [returnValue] = @returnValue);
	GOTO OutputRecordSet;

	
	OutputRecordSet:
	SELECT 
		@returnValue AS [returnValue],
		@returnMessage AS [returnMessage],
		@partId AS [partId];