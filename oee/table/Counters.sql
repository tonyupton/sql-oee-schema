create table oee.Counters
(
	Id int identity,
	EquipmentId int not null,
	Name int not null,
	Type int not null,
	Mode int not null,
	Value int,
	constraint Counters_pk
		primary key (Id),
	constraint Counters_pk_2
		unique (EquipmentId, Name),
	constraint Counters_Equipment_Id_fk
		foreign key (EquipmentId) references oee.Equipment
)
go

