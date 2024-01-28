create table oee.ShiftEvents
(
	Id int identity,
	ShiftScheduleId int not null,
	ShiftId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	constraint ShiftEvents_pk
		primary key (Id),
	constraint ShiftEvents_pk_2
		unique (BeginTime, ShiftScheduleId),
	constraint ShiftEvents_ShiftSchedules_Id_fk
		foreign key (ShiftScheduleId) references oee.ShiftSchedules,
	constraint ShiftEvents_Shifts_Id_fk
		foreign key (ShiftId) references oee.Shifts
)
go

