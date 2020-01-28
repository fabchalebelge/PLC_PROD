CREATE PROCEDURE [dbo].[USI_sp_SetPartStatus]
	@partId bigint,
	@valid bit
AS
	SET NOCOUNT ON;

	DECLARE
		@returnMessage varchar(MAX),
		@returnValue smallint;

	IF EXISTS(SELECT * FROM [USI_Part] WHERE [id] = @partId)
		BEGIN
			UPDATE [USI_Part] SET [valid] = @valid WHERE [id] = @partId;
			SET @returnValue = 0;
			GOTO OutputRecordSet;
		END
	ELSE
		GOTO ErrorHandler;


	ErrorHandler:
		IF NOT EXISTS(SELECT * FROM [USI_Part] WHERE [id] = @partId)	SET @returnValue = -130;	--partId inexistant
		SET @returnMessage = (SELECT [returnMessage] FROM [USI_ReturnMessage] WHERE [returnValue] = @returnValue);
		GOTO OutputRecordSet;


	OutputRecordSet:
		SELECT
			@returnValue AS [returnValue],
			@returnMessage AS [returnMessage];