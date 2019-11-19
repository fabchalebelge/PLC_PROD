CREATE TABLE [dbo].[USI_Part]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [workOrderId] INT NOT NULL, 
    [timeStamp] DATETIME NULL DEFAULT GetDate(), 
    [valid] BIT NULL, 
    CONSTRAINT [FK_Part_WorkOrder] FOREIGN KEY ([workOrderId]) REFERENCES [USI_WorkOrder]([id]) ON DELETE CASCADE
)
