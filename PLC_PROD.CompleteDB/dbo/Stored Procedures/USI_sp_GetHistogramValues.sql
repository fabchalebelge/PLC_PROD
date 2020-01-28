/*
1. Récupérer les x dernières valeurs de mesure dans la table temporaire #Measurements
2. Définir les valeurs aberrantes pour les limites de l'histogramme (observations qui se trouvent à au moins 1,5 fois l'étendue interquartile (Q3 - Q1) du bord de la boîte)
3. Créer et remplir une table temporaire pour les valeurs bin et count de l'histogramme
*/

CREATE PROCEDURE [dbo].[USI_sp_GetHistogramValues]
	@characteristicId	int,
	@numberOfValues		int = 30
AS
	DECLARE
		@Ibar		decimal(7,4),
		@STDEV		decimal(7,4),
		@Itild		decimal(7,4),
		@Q1			decimal(7,4),
		@Q3			decimal(7,4),
		@lowerLimit	decimal(7,4),
		@upperLimit decimal(7,4),
		@numOfBin	smallint,
		@bin		decimal(18,15),
		@i			smallint;

	SELECT *
	INTO #Measurements
	FROM
		(
		SELECT TOP (@numberOfValues)
			[M].[id]															AS [measurementId],
			[M].[timeStamp],
			[C].[nominal],
			[C].[nominal] + [C].[upperTolerance]								AS [upperTolerance],
			[C].[nominal] + [C].[lowerTolerance]								AS [lowerTolerance],
			[C].[unit],
			[M].[value]															AS [I],
			ABS([M].[value] - LAG([M].[value]) OVER(ORDER BY [M].[id] ASC))		AS [MR]
		FROM
			[USI_Measurement] AS [M]
		INNER JOIN
			[USI_Characteristic] AS [C] ON [C].[id] = [M].[characteristicId]
		WHERE
			[M].[characteristicId] = @characteristicId
		ORDER BY
			[M].[id] DESC
		) AS TempTable;

	SELECT
		@Ibar		= AVG([I]),
		@STDEV		= STDEV([I]),
		@Itild		= (SELECT TOP(1) PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [I] ASC) OVER () AS med FROM #Measurements),
		@Q1			= (SELECT TOP(1) PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY [I] ASC) OVER () AS med FROM #Measurements),
		@Q3			= (SELECT TOP(1) PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY [I] ASC) OVER () AS med FROM #Measurements),
		@lowerLimit	= @Q1 - 1.5 * (@Q3 - @Q1),
		@upperLimit	= @Q3 + 1.5 * (@Q3 - @Q1),
		@numOfBin	= ROUND(SQRT(COUNT([I])),0),
		@bin		= (@upperLimit - @lowerLimit) / @numOfBin
	FROM
		#Measurements;

	SELECT
		@Ibar		AS [average],
		@STDEV		AS [standardDeviation],
		@Itild		AS [median],
		@lowerLimit	AS [lowerLimit],
		@upperLimit	AS [upperLimit],
		@numOfBin	AS [numOfBin],
		@bin		AS [bin];

	CREATE TABLE #Histogram (
		id			smallint,
		fromValue	decimal(7,4),
		toValue		decimal(7,4),
		frequency	smallint
	);

	INSERT INTO #Histogram(id, toValue, frequency)
	VALUES(1, @lowerLimit, (SELECT COUNT([measurementId]) FROM #Measurements WHERE [I] < @lowerLimit));

	SET @i = 1;
	WHILE @i <= @numOfBin
		BEGIN
			INSERT INTO #Histogram
			VALUES(
				@i + 1,
				@lowerLimit + (@i - 1) * @bin,
				@lowerLimit + @i * @bin,
				(SELECT COUNT([measurementId]) FROM #Measurements WHERE [I] >= @lowerLimit + (@i - 1) * @bin AND [I] < @lowerLimit + @i * @bin)
			);
			SET @i = @i + 1;
		END

	INSERT INTO #Histogram(id, fromValue, frequency)
	VALUES(@i + 1, @upperLimit, (SELECT COUNT([measurementId]) FROM #Measurements WHERE [I] >= @lowerLimit + (@i - 1) * @bin));

	SELECT * FROM #Histogram;