CREATE TABLE [dbo].[USI_PartNumber_ProductionLine]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [partNumberId] INT NOT NULL, 
    [productionLineId] INT NOT NULL
)

GO

CREATE UNIQUE INDEX [IX_USI_PartNumber_ProductionLine_partNumberId_productionLineId] ON [dbo].[USI_PartNumber_ProductionLine] ([partNumberId], [productionLineId])
