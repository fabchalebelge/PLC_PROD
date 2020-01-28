CREATE TABLE [dbo].[USI_PartNumber_ProductionLine] (
    [id]               INT IDENTITY (1, 1) NOT NULL,
    [partNumberId]     INT NOT NULL,
    [productionLineId] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PartNumber_ProductionLine_partNumberId_productionLineId]
    ON [dbo].[USI_PartNumber_ProductionLine]([partNumberId] ASC, [productionLineId] ASC);

