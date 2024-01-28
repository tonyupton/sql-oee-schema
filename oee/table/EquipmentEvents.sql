create table oee.EquipmentEvents
(
	Id bigint identity,
	EquipmentId int not null,
	StateEventId int,
	JobEventId int,
	ShiftEventId int,
	PerformanceEventId int,
	BeginTime datetime not null,
	EndTime datetime,
	constraint PK_EquipmentEvents
		primary key (Id)
)
go

