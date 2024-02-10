

CREATE PROCEDURE [OEE].[usp_FindOrCreateJobByReference] (
	@reference varchar(50),
	@id int OUTPUT
)
AS
BEGIN
	SELECT @id = Id
	FROM OEE.Jobs
	WHERE Reference = @reference

	IF @id IS NULL
	BEGIN
		INSERT INTO OEE.Jobs (Reference)
		VALUES (@reference)
		SET @reference = SCOPE_IDENTITY ( )
	END
END
go

