CREATE TABLE [dbo].[USI_Measurement]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [partId] BIGINT NOT NULL, 
    [characteristicId] INT NOT NULL, 
    [timeStamp] DATETIME NULL DEFAULT GetDate(), 
    [value] DECIMAL(7, 4) NOT NULL, 
    [valid] BIT NOT NULL, 
    CONSTRAINT [FK_Measurement_Part] FOREIGN KEY ([partId]) REFERENCES [USI_Part]([id]) ON DELETE CASCADE, 
    CONSTRAINT [FK_Measurement_Characteristic] FOREIGN KEY ([characteristicId]) REFERENCES [USI_Characteristic]([id])
)
