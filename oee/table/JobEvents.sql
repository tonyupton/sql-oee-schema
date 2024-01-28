create table oee.JobEvents
(
	Id int identity,
	EquipmentId int not null,
	JobId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	constraint JobEvents_pk
		primary key (Id),
	constraint JobEvents_pk_2
		unique (EquipmentId, BeginTime),
	constraint JobEvents_Jobs_Id_fk
		foreign key (JobId) references oee.Jobs
)
go

