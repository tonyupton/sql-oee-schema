CREATE FUNCTION [oee].[fn_FindEquipmentStateByName]
(
	@equipmentId int,
	@stateName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = S.Id
	FROM oee.Equipment
	INNER JOIN oee.StateClasses SC on SC.Id = Equipment.StateClassId
	INNER JOIN oee.States S on SC.Id = S.StateClassId
	WHERE Equipment.Id = @equipmentId
	AND S.Name = @stateName

	RETURN @id
END
go

