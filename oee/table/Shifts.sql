create table oee.Shifts
(
	Id int identity,
	Name varchar(50) not null,
	ScheduleId int,
	constraint Shifts_pk
		primary key (Id),
	constraint Shifts_pk_2
		unique (ScheduleId, Name),
	constraint Shifts_ShiftSchedules_Id_fk
		foreign key (ScheduleId) references oee.ShiftSchedules
)
go

