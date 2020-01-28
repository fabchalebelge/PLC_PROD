CREATE TABLE [dbo].[USI_Part] (
    [id]          BIGINT   IDENTITY (1, 1) NOT NULL,
    [workOrderId] INT      NOT NULL,
    [timeStamp]   DATETIME DEFAULT (getdate()) NULL,
    [valid]       BIT      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_Part_WorkOrder] FOREIGN KEY ([workOrderId]) REFERENCES [dbo].[USI_WorkOrder] ([id]) ON DELETE CASCADE
);


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
		
		IF (SELECT COUNT(*) FROM [inserted]) = 1 OR (SELECT COUNT(*) FROM [deleted]) = 1	--Utile lors de la suppression d'un OF complet (ON DELETE CASCADE)
			BEGIN
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
    END