

CREATE FUNCTION [OEE].[fn_FindShiftByName]
(
	@scheduleId int,
	@shiftName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM OEE.Shifts
	WHERE ScheduleId = @scheduleId AND Name = @shiftName

	RETURN @id
END
go

