CREATE TABLE [dbo].[USI_PartName]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [partName] NVARCHAR(50) NOT NULL
)

GO

CREATE UNIQUE INDEX [IX_USI_PartName_partName] ON [dbo].[USI_PartName] ([partName])
