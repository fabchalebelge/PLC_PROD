CREATE TABLE [dbo].[USI_PartNumber]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [projectId] INT NOT NULL, 
    [partNameId] INT NOT NULL, 
    [partNumber] NVARCHAR(50) NOT NULL, 
    CONSTRAINT [FK_PartNumber_Project] FOREIGN KEY ([projectId]) REFERENCES [USI_Project]([id]), 
    CONSTRAINT [FK_PartNumber_PartName] FOREIGN KEY ([partNameId]) REFERENCES [USI_PartName]([id])
)

GO

CREATE UNIQUE INDEX [IX_USI_PartNumber_partNumber] ON [dbo].[USI_PartNumber] ([partNumber])
