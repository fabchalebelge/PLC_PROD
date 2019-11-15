CREATE TABLE [dbo].[USI_Project]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [project] NCHAR(4) NOT NULL
)

GO

CREATE UNIQUE INDEX [IX_USI_Project_project] ON [dbo].[USI_Project] ([project])
