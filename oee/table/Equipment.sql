create table OEE.Equipment
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
	Path as concat([Enterprise],'/',[Site],'/',[Area],'/',[Line],case when [Cell] IS NULL then '' else concat('/',[Cell]) end),
	constraint Equipment_pk
		primary key (Id),
	constraint Equipment_pk_2
		unique (Path),
	constraint Equipment_StateClasses_Id_fk
		foreign key (StateClassId) references OEE.StateClasses
)
go

