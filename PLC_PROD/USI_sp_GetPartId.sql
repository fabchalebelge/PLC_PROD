CREATE PROCEDURE [dbo].[USI_sp_GetPartId]
	@workOrderId int,
	@partId bigint OUTPUT
AS
	SET NOCOUNT ON;

	INSERT INTO [USI_Part]([workOrderId]) VALUES (@workOrderId);

	SET @partId = @@IDENTITY;
RETURN 0
