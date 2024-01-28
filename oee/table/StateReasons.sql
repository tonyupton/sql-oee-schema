create table oee.StateReasons
(
	Id int identity,
	StateId int not null,
	Name varchar(50) not null,
	Category varchar(50),
	Scheduled bit default 0 not null,
	constraint StateReasons_pk
		primary key (Id),
	constraint StateReasons_pk_2
		unique (StateId, Category, Name),
	constraint StateReasons_States_Id_fk
		foreign key (StateId) references oee.States,
)
go

