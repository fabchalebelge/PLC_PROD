CREATE PROCEDURE [dbo].[USI_sp_SetPartStatus]
	@partId bigint,
	@valid bit
AS
	SET NOCOUNT ON;

	UPDATE [USI_Part] SET [valid] = @valid WHERE [id] = @partId;

RETURN 0
