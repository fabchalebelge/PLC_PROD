CREATE VIEW [dbo].[USI_View_ListOfCharacteristics]
	AS
	
	SELECT
		[productionLine],
		[partName],
		[project],
		[partNumber],
		[characteristic],
		[nominal],
		[upperTolerance],
		[lowerTolerance],
		[unit]

	FROM [USI_ProductionLine]
	INNER JOIN [USI_PartNumber_ProductionLine]	ON [USI_PartNumber_ProductionLine].[productionLineId] = [USI_ProductionLine].[id]
	INNER JOIN [USI_PartNumber]					ON [USI_PartNumber].[id] = [USI_PartNumber_ProductionLine].[partNumberId]
	INNER JOIN [USI_Project]					ON [USI_Project].[id] = [USI_PartNumber].[projectId]
	INNER JOIN [USI_PartName]					ON [USI_PartName].[id] = [USI_PartNumber].[partNameId]
	INNER JOIN [USI_Characteristic]				ON [USI_Characteristic].[partNumberProductionLineId] = [USI_PartNumber_ProductionLine].[id]