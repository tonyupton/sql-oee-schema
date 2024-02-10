
CREATE FUNCTION [OEE].[fn_FindEquipmentStateByValue]
(
	@equipmentId int,
	@stateValue int
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = S.Id
	FROM OEE.Equipment
	INNER JOIN OEE.StateClasses SC on SC.Id = Equipment.StateClassId
	INNER JOIN OEE.States S on SC.Id = S.StateClassId
	WHERE Equipment.Id = @equipmentId
	AND S.Value = @stateValue

	RETURN @id
END
go

