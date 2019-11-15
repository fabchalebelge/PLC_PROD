CREATE TABLE [dbo].[USI_Characteristic]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [partNumberProductionLineId] INT NOT NULL, 
    [characteristic] VARCHAR(256) NOT NULL, 
    [nominal] DECIMAL(6, 3) NOT NULL, 
    [upperTolerance] DECIMAL(6, 3) NOT NULL, 
    [lowerTolerance] DECIMAL(6, 3) NOT NULL, 
    [unit] VARCHAR(10) NOT NULL, 
    CONSTRAINT [FK_Characteristic_PartNumberProductionLine] FOREIGN KEY ([partNumberProductionLineId]) REFERENCES [USI_PartNumber_ProductionLine]([id])
)

GO

CREATE UNIQUE INDEX [IX_Characteristic_partNumberProductionLineId_characteristic] ON [dbo].[USI_Characteristic] ([partNumberProductionLineId], [characteristic])
