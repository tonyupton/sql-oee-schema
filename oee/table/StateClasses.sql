create table oee.StateClasses
(
	Id int identity,
	Name varchar(50) not null,
	constraint StateClasses_pk
		primary key (Id),
	constraint StateClasses_pk_2
		unique (Name)
)
go

