CREATE TABLE [dbo].[USI_Project]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [project] CHAR(4) NOT NULL
)

GO

CREATE UNIQUE INDEX [IX_Project_project] ON [dbo].[USI_Project] ([project])
