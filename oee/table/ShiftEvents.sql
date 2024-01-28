create table [oee].[ShiftEvents]
(
	[Id] int identity,
	[ShiftScheduleId] int not null,
	[ShiftId] int not null,
	[BeginTime] datetime not null,
	[EndTime] datetime,
	constraint [PK_ShiftEvents]
		primary key ([Id])
)
go

