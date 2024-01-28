create table oee.ShiftSchedules
(
	Id int identity,
	Name varchar(50) not null,
	constraint ShiftSchedules_pk
		primary key (Id),
	constraint ShiftSchedules_pk_2
		unique (Name)
)
go

