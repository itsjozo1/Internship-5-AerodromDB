create table Cities( 
	CityId serial primary key, 
	Name varchar(30) not null 
); 

create table Airports( 
	AirportId serial primary key, 
	Name varchar(50) not null, Geolocation point, 
	CityId int references Cities(CityId) 
); 

create table Companies ( 
	CompanyId serial primary key, 
	Name varchar(30) not null 
); 
	
create table Planes( 
	PlaneId serial primary key, 
	Name varchar(20) not null, 
	CapacityEconomy int not null, 
	Status varchar(50) not null,
	CapacityFirstClass int not null, Status varchar(10), 
	CompanyId int references Companies(CompanyId),
	LocationStatus varchar(50) not null
); 
create table Seats( 
	SeatId serial primary key, 
	Class varchar(10) not null, 
	PlaneId int references Planes(PlaneId),
	Number int 
); 
	
create table Users( 
	UserId serial primary key, 
	Name varchar(30) not null, 
	Surname varchar(30) not null, 
	LoyalityCardStatus int not null 
); 

create table Pilots( 
	PilotId serial primary key, 
	Name varchar(30) not null, 
	Surname varchar(30) not null, 
	Birth timestamp,
	Pay int not null
); 

create table Stewardesses( 
	StewardessId serial primary key, 
	Name varchar(30) not null, 
	Surname varchar(30) not null, 
	Birth timestamp,
	Pay int not null
); 

create table Flights( 
	FlightId serial primary key, 
	PlaneId int references Planes(PlaneId), 
	StartAirportId int references Airports(AirportId), 
	EndAirportId int references Airports(AirportId), 
	StartDate date not null, 
	EndDate date not null, 
	CapacityEconomy int not null,
	CapacityFirstClass int not null
);

create table Tickets( 
	TicketId serial primary key, 
	Name varchar(30) not null, 
	Surname varchar(30) not null, 
	SeatId int references Seats(SeatId), 
	UserId int references Users(UserId), 
	Price int not null 
);

create table FlightsTickets( 
	TicketId int references Tickets(TicketId), 
	FlightId int references Flights(FlightId) 
); 

create table FlightsPilots( 
	FlightId int references Flights(FlightId), 
	PilotId int references Pilots(PilotId)
); 
create table FlightsStewardesses( 
	FlightId int references Flights(FlightId), 
	StewardessId int references Stewardesses(StewardessId) 
); 

create table TicketsUsers( 
	TicketUsersId serial primary key,
	TicketId int references Tickets(TicketId), 
	UsersId int references Users(UserId), 
	Rating int not null 
); 
create table Comments( 
	CommentId serial primary key, 
	UserId int references Users(UserId), 
	FlightId int references Flights(FlightId), 
	Comment varchar(100) 
);

ALTER TABLE Planes
ADD CONSTRAINT CheckStatus CHECK (Status IN ('Na prodaji', 'Aktivan', 'Na popravku', 'Razmontiran'));

ALTER TABLE Pilots
ADD CONSTRAINT CheckPilotAge
CHECK (
    AGE(Birth) BETWEEN INTERVAL '20 years' AND INTERVAL '60 years'
);

alter table ticketsusers
add constraint CheckRatingRange 
check(rating between 1 and 5);

alter table FlightsPilots
add constraint CheckPilotsNumber check(PilotId <= 2);
alter table FlightsStewardesses 
add constraint CheckStewardessesNumber check(StewardessId <= 4);

