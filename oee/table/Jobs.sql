create table oee.Jobs
(
	Id int identity,
	Reference varchar(50) not null,
	constraint Jobs_pk
		primary key (Id),
	constraint Jobs_pk_2
		unique (Id)
)
go

