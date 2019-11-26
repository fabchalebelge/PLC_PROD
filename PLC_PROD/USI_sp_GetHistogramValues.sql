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
		@Ibar		float,
		@STDEV		float,
		@nominal	decimal(7,4),
		@lowerTol	decimal(7,4),
		@upperTol	decimal(7,4),
		@Itild		decimal(7,4),
		@Q1			decimal(7,4),
		@Q3			decimal(7,4),
		@lowerLimit	decimal(7,4),
		@upperLimit decimal(7,4),
		@numOfBin	smallint,
		@bin		float,
		@i			smallint,
		@norm		float;

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
		@nominal	= (SELECT TOP(1) [nominal] FROM #Measurements ORDER BY [measurementId] DESC),
		@lowerTol	= (SELECT TOP(1) [lowerTolerance] FROM #Measurements ORDER BY [measurementId] DESC),
		@upperTol	= (SELECT TOP(1) [upperTolerance] FROM #Measurements ORDER BY [measurementId] DESC),
		@Itild		= (SELECT TOP(1) PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [I] ASC) OVER () AS med FROM #Measurements),
		@Q1			= (SELECT TOP(1) PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY [I] ASC) OVER () AS med FROM #Measurements),
		@Q3			= (SELECT TOP(1) PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY [I] ASC) OVER () AS med FROM #Measurements),
		@lowerLimit	= @Q1 - 1.5 * (@Q3 - @Q1),
		@upperLimit	= @Q3 + 1.5 * (@Q3 - @Q1),
		@numOfBin	= ROUND(SQRT(COUNT([I])),0),
		@bin		= (@upperLimit - @lowerLimit) / @numOfBin
	FROM
		#Measurements;

	--SELECT
	--	@Ibar		AS [average],
	--	@STDEV		AS [standardDeviation],
	--	@Itild		AS [median],
	--	@lowerLimit	AS [lowerLimit],
	--	@upperLimit	AS [upperLimit],
	--	@numOfBin	AS [numOfBin],
	--	@bin		AS [bin];

	WHILE (@lowerLimit > @lowerTol)
		BEGIN
			SET @lowerLimit = @lowerLimit - @bin;
			SET @numOfBin = @numOfBin + 1;
		END

	WHILE (@upperLimit < @upperTol)
		BEGIN
			SET @upperLimit = @upperLimit + @bin;
			SET @numOfBin = @numOfBin + 1;
		END

	CREATE TABLE #Histogram (
		id			smallint,
		fromValue	decimal(7,4),
		toValue		decimal(7,4),
		bin			nvarchar(50),
		frequency	smallint,
		gauss		float,
		gauss_norm	real,
		limits		smallint
	);

	INSERT INTO #Histogram(id, toValue, bin, frequency, gauss)
	VALUES(1, @lowerLimit, CONCAT(N']-∞, ', CONVERT(varchar,CONVERT(decimal(6,3), @lowerLimit)), '['), (SELECT COUNT([measurementId]) FROM #Measurements WHERE [I] < @lowerLimit), NULL);

	SET @i = 1;
	WHILE @i <= @numOfBin
		BEGIN
			INSERT INTO #Histogram(id, fromValue, toValue, bin, frequency, gauss)
			VALUES(
				@i + 1,
				@lowerLimit + (@i - 1) * @bin,
				@lowerLimit + @i * @bin,
				CONCAT(N'[', CONVERT(varchar,CONVERT(decimal(6,3), @lowerLimit + (@i - 1) * @bin)), ', ', CONVERT(varchar,CONVERT(decimal(6,3), @lowerLimit + @i * @bin)), '['),
				(SELECT COUNT([measurementId]) FROM #Measurements WHERE [I] >= @lowerLimit + (@i - 1) * @bin AND [I] < @lowerLimit + @i * @bin),
				1 / (@STDEV * SQRT(2 * PI())) * EXP(-0.5 * POWER(((@lowerLimit + (@i - 0.5) * @bin) - @Ibar) / @STDEV, 2))
			);
			SET @i = @i + 1;
		END

	INSERT INTO #Histogram(id, fromValue, bin, frequency, gauss)
	VALUES(@i + 1, @lowerLimit + (@i - 1) * @bin, CONCAT('[', CONVERT(varchar,CONVERT(decimal(6,3), @lowerLimit + (@i - 1) * @bin)), N', +∞['), (SELECT COUNT([measurementId]) FROM #Measurements WHERE [I] >= @lowerLimit + (@i - 1) * @bin), NULL);

	SELECT @norm = SUM(frequency) / SUM(gauss) FROM #Histogram;

	UPDATE #Histogram SET gauss_norm = gauss * @norm;

	UPDATE
		#Histogram
	SET
		limits = (SELECT MAX(frequency) FROM #Histogram) * 1.1
	WHERE
		/*(@nominal >= fromValue AND @nominal < toValue)
		OR*/ (@lowerTol >= fromValue AND @lowerTol < toValue)
		OR (@upperTol >= fromValue AND @upperTol < toValue);



	SELECT * FROM #Histogram;