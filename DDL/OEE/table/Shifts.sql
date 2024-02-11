CREATE TABLE OEE.Shifts (
	Id int IDENTITY,
	Name varchar(50) NOT NULL,
	ScheduleId int,
	CONSTRAINT Shifts_pk PRIMARY KEY (Id),
	CONSTRAINT Shifts_pk_2 UNIQUE (ScheduleId, Name),
	CONSTRAINT Shifts_ShiftSchedules_Id_fk FOREIGN KEY (ScheduleId) REFERENCES OEE.ShiftSchedules
)
go

