create table OEE.JobEvents
(
	Id int identity,
	BeginTime datetime not null,
	EndTime datetime,
	EquipmentId int not null,
	JobId int not null,
	constraint JobEvents_pk
		primary key (Id),
	constraint JobEvents_pk_2
		unique (EquipmentId, BeginTime),
	constraint JobEvents_Jobs_Id_fk
		foreign key (JobId) references OEE.Jobs
)
go

