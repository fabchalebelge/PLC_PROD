CREATE TABLE [dbo].[USI_Part]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [workOrderId] INT NOT NULL, 
    [timeStamp] DATETIME NULL DEFAULT GetDate(), 
    [valid] BIT NULL, 
    CONSTRAINT [FK_Part_WorkOrder] FOREIGN KEY ([workOrderId]) REFERENCES [USI_WorkOrder]([id])
)

GO

CREATE TRIGGER [dbo].[Trigger_Part]
    ON [dbo].[USI_Part]
    FOR DELETE, INSERT, UPDATE
    AS
    BEGIN
        SET NoCount ON;

		DECLARE
			@workOrderId int,
			@numOfParts smallint,
			@numOfPartsOk smallint,
			@numOfPartsNok smallint,
			@timeStampStop datetime,
			@completed bit;

		SET @workOrderId	= COALESCE((SELECT [workOrderId] FROM [inserted]), (SELECT [workOrderId] FROM [deleted]));

		SET @timeStampStop	= GETDATE();

		SELECT
			@numOfParts		= COUNT([id]),
			@numOfPartsOk	= SUM(CAST([valid] AS tinyint)),
			@numOfPartsNok	= COUNT([valid]) - SUM(CAST([valid] AS tinyint))
		FROM
			[USI_Part]
		WHERE
			[workOrderId] = @workOrderId;

		IF @numOfPartsOk >= (SELECT [size] FROM [USI_WorkOrder] WHERE [id] = @workOrderId)
			SET @completed = 1;
		ELSE
			SET @completed = 0;


		UPDATE
			[USI_WorkOrder]
		SET
			[timeStampStop]	= @timeStampStop,
			[numOfParts]	= @numOfParts,
			[numOfPartsOk]	= @numOfPartsOk,
			[numOfPartsNok]	= @numOfPartsNok,
			[completed]		= @completed
		WHERE
			[id] = @workOrderId;
    END
GO
