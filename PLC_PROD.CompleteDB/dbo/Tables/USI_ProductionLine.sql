CREATE TABLE [dbo].[USI_ProductionLine] (
    [id]             INT      IDENTITY (1, 1) NOT NULL,
    [productionLine] CHAR (4) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductionLine_productionLine]
    ON [dbo].[USI_ProductionLine]([productionLine] ASC);

