create table oee.Equipment
(
	Id int identity,
	Enterprise varchar(50) not null,
	Site varchar(50) not null,
	Area varchar(50) not null,
	Line varchar(50) not null,
	Cell varchar(50),
	Description varchar(255),
	ShiftScheduleId int,
	StateClassId int,
	constraint Equipment_pk
		primary key (Id),
	constraint Equipment_pk_2
		unique (Enterprise, Site, Area, Line, Cell),
	constraint Equipment_StateClasses_Id_fk
		foreign key (StateClassId) references oee.StateClasses
)
go

