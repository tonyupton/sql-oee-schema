create table oee.JobEvents
(
	Id int identity,
	EquipmentId int not null,
	JobId int not null,
	BeginTime datetime not null,
	EndTime datetime,
	constraint PK_EquipmentJobEvents
		primary key (Id),
	constraint FK_EquipmentJobEvents_Jobs
		foreign key (JobId) references oee.Jobs
)
go

