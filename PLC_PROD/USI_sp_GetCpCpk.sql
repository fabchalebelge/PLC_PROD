CREATE PROCEDURE [dbo].[USI_sp_GetCpCpk]
	@characteristicId int,
	@numberOfValues int = 30
AS
	DECLARE
		@Ibar decimal(7,4),
		@STDEV decimal(7,4),
		@IT decimal(7,4),
		@IT1 decimal(7,4),
		@IT2 decimal(7,4),
		@Cp decimal(6,3),
		@CpK decimal(6,3);

	SELECT *
	INTO #Measurements
	FROM
		(
		SELECT TOP (@numberOfValues)
			[M].[id] AS [measurementId],
			[M].[timeStamp],
			[C].[nominal],
			[C].[nominal] + [C].[upperTolerance] AS [upperTolerance],
			[C].[nominal] + [C].[lowerTolerance] AS [lowerTolerance],
			[C].[unit],
			[M].[value] AS [I],
			ABS([M].[value] - LAG([M].[value]) OVER(ORDER BY [M].[id] ASC)) AS [MR]
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
		@IT			= (SELECT TOP(1) [upperTolerance] - [lowerTolerance] FROM #Measurements ORDER BY [measurementId] DESC),
		@Cp			= @IT / (6 * @STDEV),
		@IT1		= (SELECT TOP(1) [upperTolerance] FROM #Measurements ORDER BY [measurementId] DESC) - @Ibar,
		@IT2		= @Ibar - (SELECT TOP(1) [lowerTolerance] FROM #Measurements ORDER BY [measurementId] DESC),
		@CpK		= IIF(@IT1 < @IT2,
							@IT1 / (3 * @STDEV),
							@IT2 / (3 * @STDEV))
	FROM
		#Measurements;

	SELECT
		@Cp		AS [Cp],
		@CpK	AS [CpK];