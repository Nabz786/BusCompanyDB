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
	stopName VARCHAR(20) PRIMARY KEY,
	stopCapacity INTEGER NOT NULL
);	

CREATE TABLE Route
(
	rNum INTEGER PRIMARY KEY,
	startLoc VARCHAR(20) NOT NULL,
	endLoc VARCHAR(20) NOT NULL,
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
	projRev DECIMAL NOT NULL,
	actRev DECIMAL NOT NULL,
	expenses DECIMAL NOT NULL,
	--
	--pKey1: A financial history can be obtained for the same route on different days
	CONSTRAINT pKey1 PRIMARY KEY (historyDate, routeNum),
	--fKey2: A route must exist to have a financial history
	CONSTRAINT fKey2 FOREIGN KEY (routeNum) REFERENCES Route(rNum),
	--IC_posRev: projectd, actual revenues, and expense must be positive numbers
	CONSTRAINT IC_posRev CHECK(projRev >= 0 AND actRev >= 0 AND expenses >= 0)
);

CREATE TABLE SchedArrivalTime
(
	schedArrivalTime VARCHAR(16),
	stopName VARCHAR(20),
	--
	--pKey2: A stop may have multiple bus arrivals
	CONSTRAINT pKey2 PRIMARY KEY (schedArrivalTime, stopName),
	--fKey3: A stop must be an existing stop to have scheduled busses
	CONSTRAINT fKey3 FOREIGN KEY (stopName) REFERENCES Stop(stopName)
);

CREATE TABLE RodeOn
(
	passengerID INTEGER,
	busVin INTEGER,
	CONSTRAINT pKey3 PRIMARY KEY (passengerID, busVin),
	rideDate DATE NOT NULL,
	onStop VARCHAR(20) NOT NULL,
	offStop VARCHAR(20) NOT NULL,
	--
	--fKey_pExists: a passenger must be someone who has ridden a bus
	CONSTRAINT fKey_pExists FOREIGN KEY (passengerID) REFERENCES Rider(riderId),
	--fKey_bExists: a bus must be an existing bus
	CONSTRAINT fKey_bExists FOREIGN KEY (busVin) REFERENCES Bus(Vin),
	--fKey_stpExists: The stop the passenger boarded the bus must exist
	CONSTRAINT fKey_stpExists FOREIGN KEY (onStop) REFERENCES Stop(stopName),
	--fKey_ostpExists: The stpo where the passenger exited must exist
	CONSTRAINT fKey_oStpExists FOREIGN KEY (offStop) REFERENCES Stop(stopName)
);

CREATE TABLE AssignedTo
(
	vIn Integer,
	rNum Integer,
	dAssigned Date NOT NULL,
	dRemoved DATE,
	--
	--pKey4: To be assigned to a route a bus must exist on an existing route
	CONSTRAINT pKey4 PRIMARY KEY (vIn, rNum),
	--fKey_buExists: To be assigned to a route a bus must be an existing bus
	CONSTRAINT fKey_buExists FOREIGN KEY (vIn) REFERENCES Bus(VIN),
	--fKey9_rExists: A route must exist beforehand in order to be assigned a bus
	CONSTRAINT fKey_rExists FOREIGN KEY (rNum) REFERENCES Route(rNum),
	--IC_aDate: The date a bus is removed from service cannot be before the assigned date
	CONSTRAINT IC_aDate CHECK(NOT(dRemoved < dAssigned))
);

CREATE TABLE StopOnRoute
(
	rNum INTEGER,
	stopName VARCHAR(20),
	stopSequence Integer NOT NULL,
	--
	--pKey5: A stop can be assigned to multiple routes
	CONSTRAINT pKey5 PRIMARY KEY (rNum, stopName),
	--fKey_rtExists: a stop must be assigned to an existing route
	CONSTRAINT fKey_rtExists FOREIGN KEY (rNum) REFERENCES Route(rNum),
	--fKey_stp1Exists: A route can only be assigned existing stops
	CONSTRAINT fKey_stp1Exists FOREIGN KEY (stopName) REFERENCES Stop(stopName),
	--IC_stopSeq: A stop sequence value cannot be negative
	CONSTRAINT IC_stopSeq CHECK(stopSequence > 0)
);	


SET FEEDBACK OFF

INSERT INTO Rider VALUES (123, 'John', 'Smith');
INSERT INTO Rider VALUES (222, 'Steve', 'Jones');
INSERT INTO Rider VALUES (444, 'John', 'Smith');
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
--Valid
INSERT INTO Driver VALUES (243243, 'Kevin', 'Jones', 45000, 4, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--
--Bus IC Tests
--
--Valid
INSERT INTO Bus VALUES (1234433, 64, 947374938);
--Valid
INSERT INTO BUS VALUES (32232, 50, 243243);
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
--Valid
INSERT INTO Route VALUES (7, '123 W 5th St', '111 Michigan St');
--Invalid: Route numbers cannot be the same
INSERT INTO Route VALUES (5, 'Monroe Ave', '111 Michigan St');
--Invalid: Start and end stops cannot be the same
INSERT INTO Route Values (6, 'Monroe Ave', 'Monroe Ave');
--
--FinHistory IC Tests
--
--Valid
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, 1000, 800, 12);
--Invalid: Two fin histories for a route on same day
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, 1000, 800, 12);
--Invalid: Negative values 
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, -1000, 800, -12);
--Invalid Negative Values
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, 1000, -800, 12);
--Invalid: Non-existant route
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 999, 1000, 800, 12);
--
--SchedArrivalTime IC Tests
--
--Valid
INSERT INTO SchedArrivalTime VALUES ('09:30pm', 'Monroe Ave');
--Valid
INSERT INTO SchedArrivalTime VALUES ('04:30pm', '111 Michigan St');
--Invalid: No duplicate times for a stop
INSERT INTO SchedArrivalTime VALUES ('04:30pm', '111 Michigan St');
--Invalid: A stop must exist to have a scheduled bus stop time
INSERT INTO SchedArrivalTime VALUES ('04:35pm', '123 Allendale Ave');
--
--RodeOn IC Tests
--
--Valid
INSERT INTO RodeOn VALUES (123, 1234433, TO_DATE('12/12/2015', 'MM/DD/YYYY'), '123 W 5th St', 'Monroe Ave');
--Valid
INSERT INTO RodeOn VALUES (222, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '111 Michigan St');
--Invalid: Non-Existant rider
INSERT INTO RodeOn VALUES (999, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '111 Michigan St');
--Invalid Non-Existant bus
INSERT INTO RodeOn VALUES (222, 8373723, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '111 Michigan St');
--Invalid: Non-Exsitant on stop
INSERT INTO RodeOn VALUES (123, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), '123 Ave', '111 Michigan St');
--Invalid: Non-Existant off stop
INSERT INTO RodeOn VALUES (444, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '555 Michigan St');
--
--AssignedTo IC Tests
--
--Valid 
INSERT INTO AssignedTo VALUES (32232, 5, TO_DATE('06/12/2012', 'MM/DD/YYYY'), TO_DATE('07/12/2012', 'MM/DD/YYYY'));
--Valid
INSERT INTO AssignedTo VALUES (32232, 7, TO_DATE('07/12/2012', 'MM/DD/YYYY'), TO_DATE('08/12/2012', 'MM/DD/YYYY'));
--Invalid: Bus Doesnt exist
INSERT INTO AssignedTo VALUES (32, 7, TO_DATE('07/12/2012', 'MM/DD/YYYY'), TO_DATE('08/12/2012', 'MM/DD/YYYY'));
--Invalid: Route does not exist
INSERT INTO AssignedTo VALUES (1234433, 90, TO_DATE('07/12/2012', 'MM/DD/YYYY'), TO_DATE('08/12/2012', 'MM/DD/YYYY'));
--Invalid: Removed date before assigned date
INSERT INTO AssignedTo VALUES (32232, 7, TO_DATE('04/12/2012', 'MM/DD/YYYY'), TO_DATE('03/12/2012', 'MM/DD/YYYY'));
--
--StopOnRoute IC Tests
--
--Valid
INSERT INTO StopOnRoute VALUES (5, 'Monroe Ave', 1);
--Valid
INSERT INTO StopOnRoute VALUES (7, '111 Michigan St', 10);
--Invalid: Non-Existant route
INSERT INTO StopOnRoute VALUES (20, '111 Michigan St', 20);
--Invalid: Non-Existant Stop
INSERT INTO StopOnRoute VALUES (5, '12312 Test St', 2);
--Invalid: Negative stop sequence value
INSERT INTO StopOnRoute VALUES (5, '111 Michigan St', -2);

SET FEEDBACK ON
COMMIT;

SELECT * FROM Rider;
SELECT * FROM Driver;
SELECT * FROM Bus;
SELECT * FROM Route;
SELECT * FROM Stop;
SELECT * FROM finHistory;
SELECT * FROM SchedArrivalTime;
SELECT * FROM RodeOn;
SELECT * FROM AssignedTo;
SELECT * FROM StopOnRoute;

COMMIT;

SPOOL OFF
