CREATE TABLE [dbo].[USI_PartName]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [partName] VARCHAR(50) NOT NULL
)

GO

CREATE UNIQUE INDEX [IX_PartName_partName] ON [dbo].[USI_PartName] ([partName])
