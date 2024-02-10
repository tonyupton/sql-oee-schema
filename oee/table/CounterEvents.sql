create table OEE.CounterEvents
(
	Id int identity,
	EquipmentEventId int not null,
	CounterId int not null,
	BeginValue int,
	EndValue int,
	DeltaValue int,
	constraint CounterEvents_pk
		primary key (Id),
	constraint CounterEvents_pk_2
		unique (EquipmentEventId, CounterId),
	constraint CounterEvents_Counters_Id_fk
		foreign key (CounterId) references OEE.Counters,
	constraint CounterEvents_EquipmentEvents_Id_fk
		foreign key (EquipmentEventId) references OEE.EquipmentEvents
)
go

