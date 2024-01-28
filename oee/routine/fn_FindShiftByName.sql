CREATE FUNCTION [oee].[fn_FindShiftByName]
(
	@scheduleId int,
	@shiftName varchar(50)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM oee.Shifts
	WHERE ScheduleId = @scheduleId AND Name = @shiftName

	RETURN @id
END
go

