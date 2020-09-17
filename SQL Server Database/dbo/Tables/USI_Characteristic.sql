CREATE TABLE [dbo].[USI_Characteristic] (
    [id]                         INT            IDENTITY (1, 1) NOT NULL,
    [partNumberProductionLineId] INT            NOT NULL,
    [characteristic]             VARCHAR (256)  NOT NULL,
    [nominal]                    DECIMAL (6, 3) NOT NULL,
    [upperTolerance]             DECIMAL (6, 3) NOT NULL,
    [lowerTolerance]             DECIMAL (6, 3) NOT NULL,
    [unit]                       VARCHAR (10)   NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_Characteristic_PartNumberProductionLine] FOREIGN KEY ([partNumberProductionLineId]) REFERENCES [dbo].[USI_PartNumber_ProductionLine] ([id])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Characteristic_partNumberProductionLineId_characteristic]
    ON [dbo].[USI_Characteristic]([partNumberProductionLineId] ASC, [characteristic] ASC);

