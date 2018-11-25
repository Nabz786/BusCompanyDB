SPOOL project.out
SET ECHO ON

/*
CIS-353 Bus Company Database Team 5
*/

DROP TABLE Rider CASCADE CONSTRAINTS;
DROP TABLE Bus CASCADE CONSTRAINTS;
DROP TABLE Driver CASCADE CONSTRAINTS;
DROP TABLE Route CASCADE CONSTRAINTS;
DROP TABLE Stop CASCADE CONSTRAINTS;
DROP TABLE FinHistory CASCADE CONSTRAINTS;
DROP TABLE SchedArrivalTime CASCADE CONSTRAINTS;
DROP TABLE RodeOn CASCADE CONSTRAINTS;
DROP TABLE AssignedTo CASCADE CONSTRAINTS;
DROP TABLE StopOnRoute CASCADE CONSTRAINTS;


CREATE TABLE Rider 
(
	riderId INTEGER PRIMARY KEY,
	fName VARCHAR(15) NOT NULL,
	lName VARCHAR(15) NOT NULL
);

CREATE TABLE Driver
(
	Ssn INTEGER PRIMARY KEY,
	fName VARCHAR(15) NOT NULL,
	lName VARCHAR(15) NOT NULL,
	salary INTEGER NOT NULL,
	dRank INTEGER NOT NULL,
	startDate DATE NOT NULL,
	--
	--IC_ssn: Make sure that an SSN contains only 9 numbers
--	CONSTRAINT DrIC1 CHECK(REGEXP_LIKE(Ssn,'^[[:digit:]]{9}$'))
	--IC_rank: A drivers rank is only between 1 and 5 inclusive
	CONSTRAINT IC_rank CHECK(NOT(dRank < 1 OR dRank > 5)),
	--IC_ranksal: Drivers >= rank 3 must make at least $45000
	CONSTRAINT IC_rankSal CHECK(NOT(dRank > 3 AND salary < 45000)),
	--IC_rankmin: All salaries are at least 10000
	CONSTRAINT IC_rankMin CHECK(salary >= 10000)
);

CREATE TABLE Bus
(
	VIN INTEGER PRIMARY KEY,
	numSeats INTEGER NOT NULL,
	driverSsn INTEGER NOT NULL,
	--
	--fKey1: A bus is assigned a driver from the list of active drivers
	CONSTRAINT fKey1 FOREIGN KEY (driverSsn) REFERENCES Driver(Ssn) ON DELETE CASCADE,
	--IC_oneDriver: An active bus only has one driver 
	CONSTRAINT IC_oneDriver UNIQUE (driverSsn),
	--IC_seatMin All Busses have a minimum of 30 seats
	CONSTRAINT IC_seatMin CHECK(numSeats >= 30)
);

CREATE TABLE Stop
(
	stopName VARCHAR(16) PRIMARY KEY,
	stopCapacity INTEGER NOT NULL
);	

CREATE TABLE Route
(
	rNum INTEGER PRIMARY KEY,
	startLoc VARCHAR(16) NOT NULL,
	endLoc VARCHAR(16) NOT NULL,
	--
	--IC_startLoc: The start location of a route must be an existing stop
	CONSTRAINT IC_startLoc FOREIGN KEY (startLoc) REFERENCES Stop(stopName),
	--IC_endLoc: The end location of a route must be an existing stop
	CONSTRAINT IC_endLoc FOREIGN KEY (endLoc) REFERENCES Stop(stopName),
	--IC_notSame: The start and end location of a route cannot be the same
	CONSTRAINT IC_notSame CHECK(startLoc <> endLoc)
);

CREATE TABLE FinHistory
(
	historyDate DATE,
	routeNum INTEGER,
	CONSTRAINT pKey1 PRIMARY KEY (historyDate, routeNum),
	CONSTRAINT fKey2 FOREIGN KEY (routeNum) REFERENCES Route(rNum)
);

CREATE TABLE SchedArrivalTime
(
	schedArrivalTime VARCHAR(16),
	stopName VARCHAR(16),
	CONSTRAINT pKey2 PRIMARY KEY (schedArrivalTime, stopName),
	CONSTRAINT fKey3 FOREIGN KEY (stopName) REFERENCES Stop(stopName)
);

CREATE TABLE RodeOn
(
	passengerID INTEGER,
	busVin INTEGER,
	CONSTRAINT pKey3 PRIMARY KEY (passengerID, busVin),
	rideDate DATE NOT NULL,
	onStop VARCHAR(16) NOT NULL,
	offStop VARCHAR(16) NOT NULL,
	CONSTRAINT fKey4 FOREIGN KEY (passengerID) REFERENCES Rider(riderId),
	CONSTRAINT fKey5 FOREIGN KEY (busVin) REFERENCES Bus(Vin),
	CONSTRAINT fKey6 FOREIGN KEY (onStop) REFERENCES Stop(stopName),
	CONSTRAINT fKey7 FOREIGN KEY (offStop) REFERENCES Stop(stopName)
	--ride date cannot be a fture date
);

CREATE TABLE AssignedTo
(
	vIn Integer,
	rNum Integer,
	dAssigned Date NOT NULL,
	dRemoved DATE NOT NULL,
	CONSTRAINT pKey4 PRIMARY KEY (vIn, rNum),
	CONSTRAINT fKey8 FOREIGN KEY (vIn) REFERENCES Bus(VIN),
	CONSTRAINT fKey9 FOREIGN KEY (rNum) REFERENCES Route(rNum)
	--date assigned cannot be a future date
);

CREATE TABLE StopOnRoute
(
	rNum INTEGER,
	stopName VARCHAR(16),
	stopSequence Integer NOT NULL,
	CONSTRAINT pKey5 PRIMARY KEY (rNum, stopName),
	CONSTRAINT fKey10 FOREIGN KEY (rNum) REFERENCES Route(rNum),
	CONSTRAINT fKey11 FOREIGN KEY (stopName) REFERENCES Stop(stopName)
	--stop sequence value cannot be negative and must be in sequence with other stops
);	


SET FEEDBACK OFF

--INSERT INTO Rider VALUES (123, 'John', 'Smith');
--Driver IC Tests
--
--Invalid Rank
INSERT INTO Driver VALUES (443243, 'Kevin', 'Jones', 45000, 0, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--Invalid Rank
INSERT INTO Driver VALUES (112324354, 'Kevin', 'Jones', 45000, 6, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--Invalid salary
INSERT INTO Driver VALUES (938493928, 'Kevin', 'Jones', 1000, 2, TO_DATE('08/09/2012', 'DD/MM/YYYY')); 
--Valid
INSERT INTO Driver VALUES (947374938, 'Kevin', 'Jones', 45000, 5, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--Invalid Salary
INSERT INTO Driver VALUES (938493928, 'Kevin', 'Jones', 35000, 4, TO_DATE('08/09/2012', 'DD/MM/YYYY')); 
--
--Bus IC Tests
--
--Valid
INSERT INTO Bus VALUES (1234433, 64, 947374938);
--Invalid: referencing a driver that doesnt exist
INSERT INTO BUS VALUES (243243, 50, 123);
--Invalid: Num of seats is less than min of 30
INSERT INTO BUS VALUES (234, 40, 947374938);
--
--Route IC Tests
--
INSERT INTO Stop VALUES ('123 W 5th St', 25);
INSERT INTO Stop VALUES ('111 Michigan St', 50);
INSERT INTO Stop VALUES ('Monroe Ave', 55);
--Valid
INSERT INTO Route VALUES (5, '123 W 5th St', 'Monroe Ave');
--Invalid: Route numbers cannot be the same
INSERT INTO Route VALUES (5, 'Monroe Ave', '111 Michigan St');
--Invalid: Start and end stops cannot be the same
INSERT INTO Route Values (6, 'Monroe Ave', 'Monroe Ave');

--INSERT INTO finHistory VALUES (TO_DATE('08/09/2014', 'DD/MM/YYYY'), 5);
--INSERT INTO SchedArrivalTime VALUES ('09:30pm', 'Monroe Ave');
--INSERT INTO RodeOn VALUES (123, 1234433, TO_DATE('08/05/2001', 'DD/MM/YYYY'), 'Monroe Ave', '123 W 5th St');
--INSERT INTO AssignedTo VALUES (1234433, 5, TO_DATE('04/04/2001', 'DD/MM/YYYY'), TO_DATE('05/04/2001', 'DD/MM/YYYY'));
--INSERT INTO StopOnRoute VALUES(5, 'Monroe Ave', 1);
--INSERT INTO StopOnRoute Values(4, 'Monroe Ave', 8);

SET FEEDBACK ON
COMMIT;

--SELECT * FROM Rider;
SELECT * FROM Driver;
SELECT * FROM Bus;
SELECT * FROM Route;
SELECT * FROM Stop;
--SELECT * FROM finHistory;
--SELECT * FROM SchedArrivalTime;
--SELECT * FROM RodeOn;
--SELECT * FROM AssignedTo;
--SELECT * FROM StopOnRoute;

COMMIT;

SPOOL OFF
