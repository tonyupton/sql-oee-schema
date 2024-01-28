CREATE FUNCTION [oee].[fn_FindShiftScheduleByName]
(
	@scheduleName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.ShiftSchedules
	WHERE Name = @scheduleName

	RETURN @id
END
go

