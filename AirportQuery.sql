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

alter table Planes
add constraint CheckStatus check (Status in ('Na prodaji', 'Aktivan', 'Na popravku', 'Razmontiran'));

alter table Pilots
add constraint CheckPilotAge
check (
    AGE(Birth) between INTERVAL '20 years' and INTERVAL '60 years'
);

alter table ticketsusers
add constraint CheckRatingRange 
check(rating between 1 and 5);

alter table FlightsPilots
add constraint CheckPilotsNumber check(PilotId <= 2);
alter table FlightsStewardesses 
add constraint CheckStewardessesNumber check(StewardessId <= 4);

create function check_flight_capacity()
return trigger as $$
declare
    plane_capacity_economy int;
    plane_capacity_first_class int;
    flight_capacity int;
begin
    select CapacityEconomy, CapacityFirstClass
    into plane_capacity_economy, plane_capacity_first_class
    from Planes
    where PlaneId = new.PlaneId;

    select new.CapacityEconomy + new.CapacityFirstClass
    into flight_capacity;

    if flight_capacity > plane_capacity_economy + plane_capacity_first_class then
        raise exception 'Flight capacity exceeds plane capacity';
    end if;

    return new;
end;
$$ LANGUAGE plpgsql;

create trigger enforce_flight_capacity
before insert or update on Flights
for each row execute function check_flight_capacity();

alter table Seats
add constraint CheckTicketClass Check(Class in ('A','B'))

create function check_seat_number()
returns trigger as $$
declare
    capacity_economy int;
	capacity_first_class int;
    seat_number int;
begin
    select CapacityEconomy
    into capacity_economy
	from Flights
    where FlightId = new.FlightId;
	
	select CapacityFirstClass
	into capacity_first_class
    from Flights
    where FlightId = new.FlightId;

    select Number
    into seat_number
    from Seats
    where SeatId = new.SeatId;

    if seat_number > capacity_economy or seat_number > capacity_first_class then
        raise exception 'Seat number exceeds the flight capacity';
    end if;

    return new;
end;
$$ language plpgsql;

create trigger enforce_seat_number
before insert or update on Tickets
for each row execute function check_seat_number();
