create table oee.EquipmentEvents
(
	Id int identity,
	EquipmentId int not null,
	StateEventId int,
	JobEventId int,
	ShiftEventId int,
	PerformanceEventId int,
	BeginTime datetime not null,
	EndTime datetime,
	constraint EquipmentEvents_pk
		primary key (Id),
	constraint EquipmentEvents_uk
		unique (EquipmentId, BeginTime),
	constraint EquipmentEvents_Equipment_Id_fk
		foreign key (EquipmentId) references oee.Equipment,
	constraint EquipmentEvents_JobEvents_Id_fk
		foreign key (JobEventId) references oee.JobEvents,
	constraint EquipmentEvents_PerformanceEvents_Id_fk
		foreign key (PerformanceEventId) references oee.PerformanceEvents,
	constraint EquipmentEvents_ShiftEvents_Id_fk
		foreign key (ShiftEventId) references oee.ShiftEvents,
	constraint EquipmentEvents_StateEvents_Id_fk
		foreign key (StateEventId) references oee.StateEvents
)
go

