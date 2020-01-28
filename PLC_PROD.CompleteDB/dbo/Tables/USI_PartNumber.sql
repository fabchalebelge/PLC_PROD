CREATE TABLE [dbo].[USI_PartNumber] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [projectId]  INT          NOT NULL,
    [partNameId] INT          NOT NULL,
    [partNumber] VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_PartNumber_PartName] FOREIGN KEY ([partNameId]) REFERENCES [dbo].[USI_PartName] ([id]),
    CONSTRAINT [FK_PartNumber_Project] FOREIGN KEY ([projectId]) REFERENCES [dbo].[USI_Project] ([id])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PartNumber_partNumber]
    ON [dbo].[USI_PartNumber]([partNumber] ASC);

