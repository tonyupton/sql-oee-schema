create table oee.States
(
	Id int identity,
	StateClassId int not null,
	Name varchar(50) not null,
	Value int not null,
	Running bit,
	Slow bit not null,
	Waste bit not null,
	Recordable bit not null,
	constraint States_pk
		primary key (Id),
	constraint States_pk_2
		unique (StateClassId, Name),
	constraint States_pk_3
		unique (StateClassId, Value),
	constraint States_StateClasses_Id_fk
		foreign key (StateClassId) references oee.StateClasses
)
go

