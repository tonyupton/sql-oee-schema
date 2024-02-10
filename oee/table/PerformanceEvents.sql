create table OEE.PerformanceEvents
(
	Id int identity,
	EquipmentId int not null,
	IdealRate float,
	ScheduleRate float,
	BeginTime datetime not null,
	EndTime datetime,
	constraint PerformanceEvents_pk
		primary key (Id),
	constraint PerformanceEvents_pk_2
		unique (BeginTime, EquipmentId),
	constraint PerformanceEvents_Equipment_Id_fk
		foreign key (EquipmentId) references OEE.Equipment
)
go

