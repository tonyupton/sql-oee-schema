create table OEE.EquipmentEvents
(
	Id int identity,
	BeginTime datetime not null,
	EndTime datetime,
	EquipmentId int not null,
	StateEventId int,
	JobEventId int,
	ShiftEventId int,
	PerformanceEventId int,
	constraint EquipmentEvents_pk
		primary key (Id),
	constraint EquipmentEvents_uk
		unique (EquipmentId, BeginTime),
	constraint EquipmentEvents_Equipment_Id_fk
		foreign key (EquipmentId) references OEE.Equipment,
	constraint EquipmentEvents_JobEvents_Id_fk
		foreign key (JobEventId) references OEE.JobEvents,
	constraint EquipmentEvents_PerformanceEvents_Id_fk
		foreign key (PerformanceEventId) references OEE.PerformanceEvents,
	constraint EquipmentEvents_ShiftEvents_Id_fk
		foreign key (ShiftEventId) references OEE.ShiftEvents,
	constraint EquipmentEvents_StateEvents_Id_fk
		foreign key (StateEventId) references OEE.StateEvents
)
go

