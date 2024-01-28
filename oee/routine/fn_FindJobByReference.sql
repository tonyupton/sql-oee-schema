CREATE FUNCTION [oee].[fn_FindJobByReference] 
(
	@reference varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.Jobs
	WHERE Reference = @reference

	RETURN @id
END
go

