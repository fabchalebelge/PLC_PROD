CREATE TABLE [dbo].[USI_WorkOrder]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [partNumberProductionLineId] INT NOT NULL, 
    [workOrder] CHAR(6) NOT NULL, 
    [size] SMALLINT NULL, 
    [timeStampStart] DATETIME NULL DEFAULT GetDate(), 
    [timeStampStop] DATETIME NULL DEFAULT GetDate(), 
    [numOfParts] SMALLINT NULL, 
    [numOfPartsOk] SMALLINT NULL, 
    [numOfPartsNok] SMALLINT NULL, 
    [completed] BIT NULL, 
    [pending] BIT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_WorkOrder_PartNumberProductionLine] FOREIGN KEY ([partNumberProductionLineId]) REFERENCES [USI_PartNumber_ProductionLine]([id])
)

GO

CREATE UNIQUE INDEX [IX_WorkOrder_workOrder] ON [dbo].[USI_WorkOrder] ([workOrder])
