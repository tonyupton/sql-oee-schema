CREATE TABLE OEE.ShiftEvents (
	Id int IDENTITY,
	BeginTime datetime  NOT NULL,
	EndTime datetime,
	ShiftScheduleId int NOT NULL,
	ShiftId int         NOT NULL,
	CONSTRAINT ShiftEvents_pk PRIMARY KEY (Id),
	CONSTRAINT ShiftEvents_pk_2 UNIQUE (BeginTime, ShiftScheduleId),
	CONSTRAINT ShiftEvents_ShiftSchedules_Id_fk FOREIGN KEY (ShiftScheduleId) REFERENCES OEE.ShiftSchedules,
	CONSTRAINT ShiftEvents_Shifts_Id_fk FOREIGN KEY (ShiftId) REFERENCES OEE.Shifts
)
go

