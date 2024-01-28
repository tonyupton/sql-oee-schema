CREATE PROCEDURE [oee].[usp_InsertJobEvent] (
	@equipment_id int,
	@job_ref varchar(50),
	@timestamp datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @timestamp IS NULL SET @timestamp = SYSUTCDATETIME ( )

	DECLARE @now datetime = SYSUTCDATETIME ( )
	DECLARE @x_event_id int
	DECLARE @x_event_begin_time datetime
	DECLARE @x_state_event_id int
	DECLARE @x_job_event_id int
	DECLARE @x_job_ref varchar(50)
	DECLARE @x_shift_event_id int

	SELECT TOP (1)
		@x_event_id = t1.Id,
		@x_event_begin_time = t1.BeginTime,
		@x_state_event_id = t1.StateEventId,
		@x_job_event_id = t2.Id,
		@x_job_ref = t3.Reference,
		@x_shift_event_id = t1.ShiftEventId
	FROM oee.EquipmentEvents t1
	LEFT JOIN oee.JobEvents t2 ON t2.id = t1.JobEventId
	LEFT JOIN oee.Jobs t3 ON t3.id = t2.JobId
	WHERE t1.EquipmentId = @equipment_id AND t1.BeginTime <= @now
	ORDER BY t1.BeginTime DESC

	IF @x_job_ref != @job_ref OR @x_job_ref IS NULL OR @job_ref IS NULL
	BEGIN
		UPDATE oee.JobEvents SET EndTime = @timestamp WHERE id = @x_job_event_id

		DECLARE @job_id int

		SELECT @job_id = id
		FROM oee.Jobs
		WHERE Reference = @job_ref

		IF @job_id IS NULL
		BEGIN
			INSERT INTO oee.Jobs (Reference)
			VALUES (@job_ref)
			SET @job_id = SCOPE_IDENTITY ( )
		END

		INSERT INTO oee.JobEvents(EquipmentId, BeginTime, JobId)
		SELECT @equipment_id, @timestamp, @job_id
		FROM oee.Jobs t1
		WHERE t1.Reference = @job_ref

		DECLARE @job_event_id int = SCOPE_IDENTITY ( )

		UPDATE oee.EquipmentEvents SET EndTime = @timestamp WHERE id = @x_event_id
		
		INSERT INTO oee.EquipmentEvents(EquipmentId, StateEventId, JobEventId, ShiftEventId, BeginTime)
		VALUES (@equipment_id, @x_state_event_id, @job_event_id, @x_shift_event_id, @timestamp)
	
	END
END
go

