﻿-- =============================================
-- Author: <Minne Charly>
-- Create date: <10/10/2019>
-- Update : <16/12/2019>
-- Description:	< Ce programme permet le pourcentage et le nombre des rebuts Keyence et Kogame par jour. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Rebut_Jour]

AS
	DECLARE 
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + heure fixe
			@First_Id_Piece INT,																	-- Numéro du premier OF après 06:00:00
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10),																		-- Numéro de l'OF
			@Pourcent_Key SMALLINT,																	-- Pourcentage de pièce mauvaise Keyence 
			@Pourcent_Kog SMALLINT,																	-- Pourcentage de pièce mauvaise Kogame
			@Rebut_Tot SMALLINT,																	-- Ex : Nbr de rebut entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Key SMALLINT,																	-- Ex : Nbr de rebut keyence entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Kog SMALLINT																		-- Ex : Nbr de rebut kogame entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			
BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR,-6,GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)					-- Ajout de l'heure 06:00:00 à cette date

	SET @First_Id_Piece = (SELECT TOP(1) idPiece FROM QAGATE_1_MainTable WHERE timeStamp >= @DateTime_H ORDER BY timeStamp ASC)
																									-- Récupération de l'id du premier OF après 06:00:00
	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Numéro d'OF

	IF((SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @First_Id_Piece) != (SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @Last_Id_Piece))
		BEGIN
			SELECT @Rebut_Tot = COUNT(idPiece)														-- Récupération du nombres de rebut depuis date + heure (avec sécurité)  
			FROM QAGATE_1_MainTable
			WHERE ((OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)) AND timeStamp > @DateTime_H AND currentOF = @OF)

			SELECT @Rebut_Key = COUNT(idPiece)														-- Récupération du nombres de rebut keyence depuis date + heure (avec sécurité)  
			FROM QAGATE_1_MainTable 
			WHERE ((OK = 1 AND (keyenceEtat = 1 AND kogameEtat = 0)) AND timeStamp > @DateTime_H AND currentOF = @OF)

			SELECT @Rebut_Kog = COUNT(idPiece)														-- Récupération du nombres de rebut kogame depuis date + heure (avec sécurité)  
			FROM QAGATE_1_MainTable 
			WHERE ((OK = 1 AND (keyenceEtat = 0 AND kogameEtat = 1)) AND timeStamp > @DateTime_H AND currentOF = @OF)
		END
	ELSE
		BEGIN
			SELECT @Rebut_Tot = COUNT(idPiece)														-- Récupération du nombres de rebut depuis date + heure (avec sécurité)  
			FROM QAGATE_1_MainTable
			WHERE ((OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)) AND timeStamp > @DateTime_H)

			SELECT @Rebut_Key = COUNT(idPiece)														-- Récupération du nombres de rebut keyence depuis date + heure (avec sécurité)  
			FROM QAGATE_1_MainTable 
			WHERE ((OK = 1 AND (keyenceEtat = 1 AND kogameEtat = 0)) AND timeStamp > @DateTime_H)

			SELECT @Rebut_Kog = COUNT(idPiece)														-- Récupération du nombres de rebut kogame depuis date + heure (avec sécurité)  
			FROM QAGATE_1_MainTable 
			WHERE ((OK = 1 AND (keyenceEtat = 0 AND kogameEtat = 1)) AND timeStamp > @DateTime_H)
		END

	IF(@Rebut_Key = 0 AND @Rebut_Kog = 0)															-- Condition pour éviter une division par 0
		BEGIN
			SET @Pourcent_Key = 0
			SET @Pourcent_Kog = 0
		END
	ELSE
		BEGIN
			SET @Pourcent_Key = ROUND((CAST(@Rebut_Key AS DECIMAL(5,1))*100)/(CAST(@Rebut_Key AS DECIMAL(5,1))+ CAST(@Rebut_Kog AS DECIMAL(5,1))), 0)						
																									-- Calcul du pourcentage de rebut Keyence
					SET @Pourcent_Kog = 100 - @Pourcent_Key							
																									-- Calcul du pourcentage de rebut Kogame
		END

	SELECT @Rebut_Tot AS 'Total', @Rebut_Key AS 'Keyence', @Pourcent_Key AS 'PKeyence', @Rebut_Kog AS 'Kogame', @Pourcent_Kog AS 'PKogame'								
																									-- Affichage des valeurs de sortie procédure

END