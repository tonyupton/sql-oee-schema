CREATE FUNCTION [oee].[fn_FindEquipmentByPath]
(
	@path varchar(255)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.Equipment e
	WHERE e.Path = @path

	RETURN @id
END
go

