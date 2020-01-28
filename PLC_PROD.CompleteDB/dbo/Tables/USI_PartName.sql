CREATE TABLE [dbo].[USI_PartName] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [partName] VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PartName_partName]
    ON [dbo].[USI_PartName]([partName] ASC);

