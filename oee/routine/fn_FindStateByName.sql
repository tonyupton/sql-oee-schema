CREATE FUNCTION [oee].[fn_FindStateByName] 
(
	@equipmentId int,
	@stateName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.States
	WHERE EquipmentId = @equipmentId AND Value = @stateName

	RETURN @id
END
go

