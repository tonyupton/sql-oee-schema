CREATE TABLE OEE.ShiftSchedules (
	Id int IDENTITY,
	Name varchar(50) NOT NULL,
	CONSTRAINT ShiftSchedules_pk PRIMARY KEY (Id),
	CONSTRAINT ShiftSchedules_pk_2 UNIQUE (Name)
)
go

