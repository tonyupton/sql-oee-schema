create table oee.States
(
	Id int identity,
	EquipmentId int not null,
	Name varchar(50) not null,
	Value int not null,
	Running bit not null,
	AtSpeed bit not null,
	GoodQuality bit not null,
	Recordable bit not null,
	constraint PK_EquipmentStates
		primary key (Id),
	constraint UK_EquipmentState_EquipmentId_Name
		unique (EquipmentId, Name),
	constraint FK_EquipmentStates_Equipment
		foreign key (EquipmentId) references oee.Equipment
)
go

