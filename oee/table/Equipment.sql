create table [oee].[Equipment]
(
	[Id] int identity,
	[Site] varchar(50) not null,
	[Area] varchar(50) not null,
	[Line] varchar(50) not null,
	[Cell] varchar(50),
	[Description] varchar(255),
	[ShiftScheduleId] int,
	constraint [PK_Equipment]
		primary key ([Id]),
	constraint [UK_Equipment_Path]
		unique ([Site], [Area], [Line], [Cell])
)
go

