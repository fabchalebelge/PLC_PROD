/*
1. Récupérer les x dernières valeurs de mesure dans la table temporaire #Measurements
2. Calculer les moyennes et limites de contrôle pour les valeurs individuelles et les étendues mobiles
3. Identifier les 4 types de test sur les valeurs I et MR
*/

CREATE PROCEDURE [dbo].[USI_sp_GetIMRValues]
	@characteristicId int,
	@numberOfValues int = 30
AS
	DECLARE
		@Ibar decimal(7,4),
		@MRbar decimal(7,4),
		@LCL_I decimal(7,4),
		@UCL_I decimal(7,4),
		@LCL_MR decimal(7,4),
		@UCL_MR decimal(7,4);

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
		@MRbar		= AVG([MR]),
		@LCL_I		= @Ibar - 2.66 * @MRbar,
		@UCL_I		= @Ibar + 2.66 * @MRbar,
		@LCL_MR		= 0,
		@UCL_MR		= @MRbar * 3.268
	FROM
		#Measurements;

	SELECT
		*,
		@Ibar	AS [Ibar],
		@MRbar	AS [MRbar],
		@LCL_I	AS [LCL_I],
		@UCL_I	AS [UCL_I],
		@LCL_MR	AS [LCL_MR],
		@UCL_MR AS [UCL_MR],

		--1 point > 3 standard deviations from center line
		IIF([I] > @UCL_I OR [I] < @LCL_I,
			1,

		--8 points in a row on same side of center line
		IIF(SIGN([I] - @Ibar) = SIGN(LAG([I],1) OVER(ORDER BY [measurementId] ASC) - @Ibar)
			AND SIGN([I] - @Ibar) = SIGN(LAG([I],2) OVER(ORDER BY [measurementId] ASC) - @Ibar)
			AND SIGN([I] - @Ibar) = SIGN(LAG([I],3) OVER(ORDER BY [measurementId] ASC) - @Ibar)
			AND SIGN([I] - @Ibar) = SIGN(LAG([I],4) OVER(ORDER BY [measurementId] ASC) - @Ibar)
			AND SIGN([I] - @Ibar) = SIGN(LAG([I],5) OVER(ORDER BY [measurementId] ASC) - @Ibar)
			AND SIGN([I] - @Ibar) = SIGN(LAG([I],6) OVER(ORDER BY [measurementId] ASC) - @Ibar)
			AND SIGN([I] - @Ibar) = SIGN(LAG([I],7) OVER(ORDER BY [measurementId] ASC) - @Ibar)
			AND SIGN([I] - @Ibar) = SIGN(LAG([I],8) OVER(ORDER BY [measurementId] ASC) - @Ibar),
			2,

		--6 points in a row, all increasing or all decreasing
		IIF(SIGN([I] - LAG([I],1) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([I],1) OVER(ORDER BY [measurementId] ASC) - LAG([I],2) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],1) OVER(ORDER BY [measurementId] ASC) - LAG([I],2) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([I],2) OVER(ORDER BY [measurementId] ASC) - LAG([I],3) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],2) OVER(ORDER BY [measurementId] ASC) - LAG([I],3) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([I],3) OVER(ORDER BY [measurementId] ASC) - LAG([I],4) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],3) OVER(ORDER BY [measurementId] ASC) - LAG([I],4) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([I],4) OVER(ORDER BY [measurementId] ASC) - LAG([I],5) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],4) OVER(ORDER BY [measurementId] ASC) - LAG([I],5) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([I],5) OVER(ORDER BY [measurementId] ASC) - LAG([I],6) OVER(ORDER BY [measurementId] ASC)),
			3,

		--14 points in a row, alternating up and down
		IIF(SIGN([I] - LAG([I],1) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],1) OVER(ORDER BY [measurementId] ASC) - LAG([I],2) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],1) OVER(ORDER BY [measurementId] ASC) - LAG([I],2) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],2) OVER(ORDER BY [measurementId] ASC) - LAG([I],3) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],2) OVER(ORDER BY [measurementId] ASC) - LAG([I],3) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],3) OVER(ORDER BY [measurementId] ASC) - LAG([I],4) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],3) OVER(ORDER BY [measurementId] ASC) - LAG([I],4) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],4) OVER(ORDER BY [measurementId] ASC) - LAG([I],5) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],4) OVER(ORDER BY [measurementId] ASC) - LAG([I],5) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],5) OVER(ORDER BY [measurementId] ASC) - LAG([I],6) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],5) OVER(ORDER BY [measurementId] ASC) - LAG([I],6) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],6) OVER(ORDER BY [measurementId] ASC) - LAG([I],7) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],6) OVER(ORDER BY [measurementId] ASC) - LAG([I],7) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],7) OVER(ORDER BY [measurementId] ASC) - LAG([I],8) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],7) OVER(ORDER BY [measurementId] ASC) - LAG([I],8) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],8) OVER(ORDER BY [measurementId] ASC) - LAG([I],9) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],8) OVER(ORDER BY [measurementId] ASC) - LAG([I],9) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],9) OVER(ORDER BY [measurementId] ASC) - LAG([I],10) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],9) OVER(ORDER BY [measurementId] ASC) - LAG([I],10) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],10) OVER(ORDER BY [measurementId] ASC) - LAG([I],11) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],10) OVER(ORDER BY [measurementId] ASC) - LAG([I],11) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],11) OVER(ORDER BY [measurementId] ASC) - LAG([I],12) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],11) OVER(ORDER BY [measurementId] ASC) - LAG([I],12) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],12) OVER(ORDER BY [measurementId] ASC) - LAG([I],13) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([I],12) OVER(ORDER BY [measurementId] ASC) - LAG([I],13) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([I],13) OVER(ORDER BY [measurementId] ASC) - LAG([I],14) OVER(ORDER BY [measurementId] ASC)),
			4,
			0))))
				AS [errorI],


		--1 point > 3 standard deviations from center line
		IIF([MR] > @UCL_MR OR [MR] < @LCL_MR,
			1,

		--8 points in a row on same side of center line
		IIF(SIGN([MR] - @MRbar) = SIGN(LAG([MR],1) OVER(ORDER BY [measurementId] ASC) - @MRbar)
			AND SIGN([MR] - @MRbar) = SIGN(LAG([MR],2) OVER(ORDER BY [measurementId] ASC) - @MRbar)
			AND SIGN([MR] - @MRbar) = SIGN(LAG([MR],3) OVER(ORDER BY [measurementId] ASC) - @MRbar)
			AND SIGN([MR] - @MRbar) = SIGN(LAG([MR],4) OVER(ORDER BY [measurementId] ASC) - @MRbar)
			AND SIGN([MR] - @MRbar) = SIGN(LAG([MR],5) OVER(ORDER BY [measurementId] ASC) - @MRbar)
			AND SIGN([MR] - @MRbar) = SIGN(LAG([MR],6) OVER(ORDER BY [measurementId] ASC) - @MRbar)
			AND SIGN([MR] - @MRbar) = SIGN(LAG([MR],7) OVER(ORDER BY [measurementId] ASC) - @MRbar)
			AND SIGN([MR] - @MRbar) = SIGN(LAG([MR],8) OVER(ORDER BY [measurementId] ASC) - @MRbar),
			2,

		--6 points in a row, all increasing or all decreasing
		IIF(SIGN([MR] - LAG([MR],1) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([MR],1) OVER(ORDER BY [measurementId] ASC) - LAG([MR],2) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],1) OVER(ORDER BY [measurementId] ASC) - LAG([MR],2) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([MR],2) OVER(ORDER BY [measurementId] ASC) - LAG([MR],3) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],2) OVER(ORDER BY [measurementId] ASC) - LAG([MR],3) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([MR],3) OVER(ORDER BY [measurementId] ASC) - LAG([MR],4) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],3) OVER(ORDER BY [measurementId] ASC) - LAG([MR],4) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([MR],4) OVER(ORDER BY [measurementId] ASC) - LAG([MR],5) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],4) OVER(ORDER BY [measurementId] ASC) - LAG([MR],5) OVER(ORDER BY [measurementId] ASC)) = SIGN(LAG([MR],5) OVER(ORDER BY [measurementId] ASC) - LAG([MR],6) OVER(ORDER BY [measurementId] ASC)),
			3,

		--14 points in a row, alternating up and down
		IIF(SIGN([MR] - LAG([MR],1) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],1) OVER(ORDER BY [measurementId] ASC) - LAG([MR],2) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],1) OVER(ORDER BY [measurementId] ASC) - LAG([MR],2) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],2) OVER(ORDER BY [measurementId] ASC) - LAG([MR],3) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],2) OVER(ORDER BY [measurementId] ASC) - LAG([MR],3) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],3) OVER(ORDER BY [measurementId] ASC) - LAG([MR],4) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],3) OVER(ORDER BY [measurementId] ASC) - LAG([MR],4) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],4) OVER(ORDER BY [measurementId] ASC) - LAG([MR],5) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],4) OVER(ORDER BY [measurementId] ASC) - LAG([MR],5) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],5) OVER(ORDER BY [measurementId] ASC) - LAG([MR],6) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],5) OVER(ORDER BY [measurementId] ASC) - LAG([MR],6) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],6) OVER(ORDER BY [measurementId] ASC) - LAG([MR],7) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],6) OVER(ORDER BY [measurementId] ASC) - LAG([MR],7) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],7) OVER(ORDER BY [measurementId] ASC) - LAG([MR],8) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],7) OVER(ORDER BY [measurementId] ASC) - LAG([MR],8) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],8) OVER(ORDER BY [measurementId] ASC) - LAG([MR],9) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],8) OVER(ORDER BY [measurementId] ASC) - LAG([MR],9) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],9) OVER(ORDER BY [measurementId] ASC) - LAG([MR],10) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],9) OVER(ORDER BY [measurementId] ASC) - LAG([MR],10) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],10) OVER(ORDER BY [measurementId] ASC) - LAG([MR],11) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],10) OVER(ORDER BY [measurementId] ASC) - LAG([MR],11) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],11) OVER(ORDER BY [measurementId] ASC) - LAG([MR],12) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],11) OVER(ORDER BY [measurementId] ASC) - LAG([MR],12) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],12) OVER(ORDER BY [measurementId] ASC) - LAG([MR],13) OVER(ORDER BY [measurementId] ASC))
			AND SIGN(LAG([MR],12) OVER(ORDER BY [measurementId] ASC) - LAG([MR],13) OVER(ORDER BY [measurementId] ASC)) <> SIGN(LAG([MR],13) OVER(ORDER BY [measurementId] ASC) - LAG([MR],14) OVER(ORDER BY [measurementId] ASC)),
			4,
			0))))
				AS [errorMR]
	FROM
		#Measurements
	ORDER BY
		[measurementId] ASC;