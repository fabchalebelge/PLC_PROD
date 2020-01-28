CREATE TABLE [dbo].[USI_WorkOrder] (
    [id]                         INT      IDENTITY (1, 1) NOT NULL,
    [partNumberProductionLineId] INT      NOT NULL,
    [workOrder]                  CHAR (6) NOT NULL,
    [size]                       SMALLINT NULL,
    [timeStampStart]             DATETIME DEFAULT (getdate()) NULL,
    [timeStampStop]              DATETIME DEFAULT (getdate()) NULL,
    [numOfParts]                 SMALLINT NULL,
    [numOfPartsOk]               SMALLINT NULL,
    [numOfPartsNok]              SMALLINT NULL,
    [completed]                  BIT      NULL,
    [pending]                    BIT      DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_WorkOrder_PartNumberProductionLine] FOREIGN KEY ([partNumberProductionLineId]) REFERENCES [dbo].[USI_PartNumber_ProductionLine] ([id])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_WorkOrder_workOrder]
    ON [dbo].[USI_WorkOrder]([workOrder] ASC);

