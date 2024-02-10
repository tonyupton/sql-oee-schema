
CREATE FUNCTION [OEE].[fn_FindEquipmentByPath]
(
	@path varchar(255)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.Equipment e
	WHERE e.Path = @path

	RETURN @id
END
go

