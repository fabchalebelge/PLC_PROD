CREATE TABLE [dbo].[USI_ReturnMessage] (
    [returnValue]   SMALLINT      NOT NULL,
    [returnMessage] VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([returnValue] ASC)
);

