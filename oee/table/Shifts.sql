create table oee.Shifts
(
	Id int identity,
	Name varchar(50) not null,
	ScheduleId int,
	constraint PK_Shifts
		primary key (Id)
)
go

