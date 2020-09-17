CREATE TABLE [dbo].[USI_Project] (
    [id]      INT      IDENTITY (1, 1) NOT NULL,
    [project] CHAR (4) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Project_project]
    ON [dbo].[USI_Project]([project] ASC);

