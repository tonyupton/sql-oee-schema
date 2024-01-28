CREATE FUNCTION [oee].[fn_FindStateByValue] 
(
	@equipmentId int,
	@stateValue int
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.States
	WHERE EquipmentId = @equipmentId AND Value = @stateValue

	RETURN @id
END
go

