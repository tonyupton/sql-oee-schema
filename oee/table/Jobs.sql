create table oee.Jobs
(
	Id int identity,
	Reference varchar(50) not null,
	constraint Jobs_uk
		primary key (Id),
	constraint Jobs_Reference_uk
		unique (Id)
)
go

