

CREATE FUNCTION [OEE].[fn_FindJobByReference]
(
	@reference varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.Jobs
	WHERE Reference = @reference

	RETURN @id
END
go

