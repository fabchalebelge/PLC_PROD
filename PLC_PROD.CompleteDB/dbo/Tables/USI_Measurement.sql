CREATE TABLE [dbo].[USI_Measurement] (
    [id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [partId]           BIGINT         NOT NULL,
    [characteristicId] INT            NOT NULL,
    [timeStamp]        DATETIME       DEFAULT (getdate()) NULL,
    [value]            DECIMAL (7, 4) NOT NULL,
    [valid]            BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_Measurement_Characteristic] FOREIGN KEY ([characteristicId]) REFERENCES [dbo].[USI_Characteristic] ([id]),
    CONSTRAINT [FK_Measurement_Part] FOREIGN KEY ([partId]) REFERENCES [dbo].[USI_Part] ([id]) ON DELETE CASCADE
);

