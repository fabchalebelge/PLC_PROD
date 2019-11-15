CREATE TABLE [dbo].[USI_ProductionLine]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [productionLine] CHAR(4) NOT NULL
)

GO

CREATE UNIQUE INDEX [IX_ProductionLine_productionLine] ON [dbo].[USI_ProductionLine] ([productionLine])
