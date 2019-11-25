/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

DECLARE
	@productionLineId int,
	@projectId int,
	@partNameId int,
	@partNumberId int,
	@partNumberProductionLineId int;

/*
======================================================================================
===================================  ReturnMessage  ==================================
======================================================================================
*/

DELETE FROM [USI_ReturnMessage];

INSERT INTO [USI_ReturnMessage] VALUES
	(-100, 'USI_sp_GetWorkOrderId : Ligne de production inexistante'),
	(-101, 'USI_sp_GetWorkOrderId : Part Number inexistant'),
	(-102, 'USI_sp_GetWorkOrderId : Lien inexistant entre le part number et la ligne de production'),
	(-103, 'USI_sp_GetWorkOrderId : OF existant sur une autre ligne de production ou un autre part number'),
	(-110, 'USI_sp_GetPartId : workOrderId inexisatnt'),
	(-120, 'USI_sp_SetMeasurement : partId inexistant'),
	(-121, 'USI_sp_SetMeasurement : caractéristique inexistante'),
	(-130, 'USI_sp_SetPartStatus : partId inexistant');


/*
======================================================================================
=======================================  SG05  =======================================
======================================================================================
*/

IF NOT EXISTS(SELECT * FROM [USI_ProductionLine] WHERE [productionLine] = 'SG05')
	INSERT INTO [USI_ProductionLine] VALUES ('SG05');

SELECT @productionLineId = [id] FROM [USI_ProductionLine] WHERE [productionLine] = 'SG05';

	/*
	***********************************************************************************
	***************************  SUN GEAR DZ01 490020-3600  ***************************
	***********************************************************************************
	*/

	IF NOT EXISTS(SELECT * FROM [USI_Project] WHERE [project] = 'DZ01')
		INSERT INTO [USI_Project] VALUES ('DZ01');

	SELECT @projectId = [id] FROM [USI_Project] WHERE [project] = 'DZ01';

	IF NOT EXISTS(SELECT * FROM [USI_PartName] WHERE [partName] = 'SUN GEAR')
		INSERT INTO [USI_PartName] VALUES ('SUN GEAR');

	SELECT @partNameId = [id] FROM [USI_PartName] WHERE [partName] = 'SUN GEAR';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber] WHERE [partNumber] = '490020-3600')
		INSERT INTO [USI_PartNumber] VALUES (@projectId, @partNameId, '490020-3600');

	SELECT @partNumberId = [id] FROM [USI_PartNumber] WHERE [partNumber] = '490020-3600';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId)
		INSERT INTO [USI_PartNumber_ProductionLine] VALUES (@partNumberId, @productionLineId);

	SELECT @partNumberProductionLineId = [id] FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId;

		/*
		------------------------------------------------------------------------------
		-------------------------  Hauteur 30.200 +/- 0.025  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Hauteur')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Hauteur', 30.200, 0.025, -0.025, 'mm');

		/*
		------------------------------------------------------------------------------
		--------------------------  Parallélisme 0.030 max  --------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Parallélisme')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Parallélisme', 0.000, 0.030, 0.000, 'mm');

		/*
		------------------------------------------------------------------------------
		------------------------  Diamètre 41.193 +/- 0.015  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Diamètre')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Diamètre', 41.193, 0.015, -0.015, 'mm');


	/*
	***********************************************************************************
	**************************  SIDE GEAR UE22 490052-0600  ***************************
	***********************************************************************************
	*/

	IF NOT EXISTS(SELECT * FROM [USI_Project] WHERE [project] = 'UE22')
		INSERT INTO [USI_Project] VALUES ('UE22');

	SELECT @projectId = [id] FROM [USI_Project] WHERE [project] = 'UE22';

	IF NOT EXISTS(SELECT * FROM [USI_PartName] WHERE [partName] = 'SIDE GEAR')
		INSERT INTO [USI_PartName] VALUES ('SIDE GEAR');

	SELECT @partNameId = [id] FROM [USI_PartName] WHERE [partName] = 'SIDE GEAR';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber] WHERE [partNumber] = '490052-0600')
		INSERT INTO [USI_PartNumber] VALUES (@projectId, @partNameId, '490052-0600');

	SELECT @partNumberId = [id] FROM [USI_PartNumber] WHERE [partNumber] = '490052-0600';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId)
		INSERT INTO [USI_PartNumber_ProductionLine] VALUES (@partNumberId, @productionLineId);

	SELECT @partNumberProductionLineId = [id] FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId;

		/*
		------------------------------------------------------------------------------
		-------------------------  Hauteur 33.835 +/- 0.015  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Hauteur')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Hauteur', 33.835, 0.015, -0.015, 'mm');

		/*
		------------------------------------------------------------------------------
		--------------------------  Parallélisme 0.038 max  --------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Parallélisme')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Parallélisme', 0.000, 0.038, 0.000, 'mm');

		/*
		------------------------------------------------------------------------------
		------------------------  Diamètre 31.950 +/- 0.040  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Diamètre')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Diamètre', 31.950, 0.04, -0.04, 'mm');


	/*
	***********************************************************************************
	**************************  SIDE GEAR UE22 490052-0700  ***************************
	***********************************************************************************
	*/

	IF NOT EXISTS(SELECT * FROM [USI_Project] WHERE [project] = 'UE22')
		INSERT INTO [USI_Project] VALUES ('UE22');

	SELECT @projectId = [id] FROM [USI_Project] WHERE [project] = 'UE22';

	IF NOT EXISTS(SELECT * FROM [USI_PartName] WHERE [partName] = 'SIDE GEAR')
		INSERT INTO [USI_PartName] VALUES ('SIDE GEAR');

	SELECT @partNameId = [id] FROM [USI_PartName] WHERE [partName] = 'SIDE GEAR';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber] WHERE [partNumber] = '490052-0700')
		INSERT INTO [USI_PartNumber] VALUES (@projectId, @partNameId, '490052-0700');

	SELECT @partNumberId = [id] FROM [USI_PartNumber] WHERE [partNumber] = '490052-0700';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId)
		INSERT INTO [USI_PartNumber_ProductionLine] VALUES (@partNumberId, @productionLineId);

	SELECT @partNumberProductionLineId = [id] FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId;

		/*
		------------------------------------------------------------------------------
		-------------------------  Hauteur 33.835 +/- 0.015  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Hauteur')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Hauteur', 33.835, 0.015, -0.015, 'mm');

		/*
		------------------------------------------------------------------------------
		--------------------------  Parallélisme 0.038 max  --------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Parallélisme')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Parallélisme', 0.000, 0.038, 0.000, 'mm');

		/*
		------------------------------------------------------------------------------
		------------------------  Diamètre 31.950 +/- 0.040  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Diamètre')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Diamètre', 31.950, 0.04, -0.04, 'mm');


	/*
	***********************************************************************************
	***********************  SPLINE COUPLING UE24 490023-3400  ************************
	***********************************************************************************
	*/

	IF NOT EXISTS(SELECT * FROM [USI_Project] WHERE [project] = 'UE24')
		INSERT INTO [USI_Project] VALUES ('UE24');

	SELECT @projectId = [id] FROM [USI_Project] WHERE [project] = 'UE24';

	IF NOT EXISTS(SELECT * FROM [USI_PartName] WHERE [partName] = 'SPLINE COUPLING')
		INSERT INTO [USI_PartName] VALUES ('SPLINE COUPLING');

	SELECT @partNameId = [id] FROM [USI_PartName] WHERE [partName] = 'SPLINE COUPLING';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber] WHERE [partNumber] = '490023-3400')
		INSERT INTO [USI_PartNumber] VALUES (@projectId, @partNameId, '490023-3400');

	SELECT @partNumberId = [id] FROM [USI_PartNumber] WHERE [partNumber] = '490023-3400';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId)
		INSERT INTO [USI_PartNumber_ProductionLine] VALUES (@partNumberId, @productionLineId);

	SELECT @partNumberProductionLineId = [id] FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId;

		/*
		------------------------------------------------------------------------------
		--------------------------  Hauteur 7.990 +/- 0.025  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Hauteur')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Hauteur', 7.99, 0.025, -0.025, 'mm');

		/*
		------------------------------------------------------------------------------
		--------------------------  Parallélisme 0.025 max  --------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Parallélisme')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Parallélisme', 0.000, 0.025, 0.000, 'mm');


	/*
	***********************************************************************************
	***********************  SPLINE COUPLING UE24 490023-3500  ************************
	***********************************************************************************
	*/

	IF NOT EXISTS(SELECT * FROM [USI_Project] WHERE [project] = 'UE24')
		INSERT INTO [USI_Project] VALUES ('UE24');

	SELECT @projectId = [id] FROM [USI_Project] WHERE [project] = 'UE24';

	IF NOT EXISTS(SELECT * FROM [USI_PartName] WHERE [partName] = 'SPLINE COUPLING')
		INSERT INTO [USI_PartName] VALUES ('SPLINE COUPLING');

	SELECT @partNameId = [id] FROM [USI_PartName] WHERE [partName] = 'SPLINE COUPLING';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber] WHERE [partNumber] = '490023-3500')
		INSERT INTO [USI_PartNumber] VALUES (@projectId, @partNameId, '490023-3500');

	SELECT @partNumberId = [id] FROM [USI_PartNumber] WHERE [partNumber] = '490023-3500';

	IF NOT EXISTS(SELECT * FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId)
		INSERT INTO [USI_PartNumber_ProductionLine] VALUES (@partNumberId, @productionLineId);

	SELECT @partNumberProductionLineId = [id] FROM [USI_PartNumber_ProductionLine] WHERE [partNumberId] = @partNumberId AND [productionLineId] = @productionLineId;

		/*
		------------------------------------------------------------------------------
		--------------------------  Hauteur 7.990 +/- 0.025  -------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Hauteur')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Hauteur', 7.99, 0.025, -0.025, 'mm');

		/*
		------------------------------------------------------------------------------
		--------------------------  Parallélisme 0.025 max  --------------------------
		------------------------------------------------------------------------------
		*/

		IF NOT EXISTS(SELECT * FROM [USI_Characteristic] WHERE [partNumberProductionLineId] = @partNumberProductionLineId AND [characteristic] = 'Parallélisme')
			INSERT INTO [USI_Characteristic] VALUES (@partNumberProductionLineId, 'Parallélisme', 0.000, 0.025, 0.000, 'mm');