

CREATE FUNCTION [OEE].[fn_FindShiftScheduleByName]
(
	@scheduleName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.ShiftSchedules
	WHERE Name = @scheduleName

	RETURN @id
END
go

