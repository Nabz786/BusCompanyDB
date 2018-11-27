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
	VIN VARCHAR(7) PRIMARY KEY,
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
	stopCapacity INTEGER NOT NULL,
	--
	--IC_stpCap: A stop must hold at least 10 people
	--
	CONSTRAINT IC_stpCap CHECK(stopCapacity >= 10)
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
	busVin VARCHAR(7),
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
	vIn VARCHAR(7),
	rNum INTEGER,
	dAssigned DATE NOT NULL,
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

--
-- Populate the Riders Table
--
INSERT INTO Rider VALUES (965574, 'Judith', 'Edwards');
INSERT INTO Rider VALUES (990311, 'Alan', 'Brown');
INSERT INTO Rider VALUES (120746, 'Jesse', 'Simmons');
INSERT INTO Rider VALUES (526975, 'Ronald', 'Hall');
INSERT INTO Rider VALUES (193044, 'Angela', 'Peterson');
INSERT INTO Rider VALUES (128525, 'Phillip', 'Jones');
INSERT INTO Rider VALUES (390503, 'Jack', 'Thompson');
INSERT INTO Rider VALUES (293308, 'Sharon', 'Garcia');
--
-- Populate the Driver Table
--
INSERT INTO Driver VALUES (685320372, 'Lillian', 'Bryant', 25000, 1, TO_DATE('08/09/2015', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (157729572, 'Debra', 'Cooper', 49000, 3, TO_DATE('08/09/2009', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (868142440, 'Justin', 'Ward', 55000, 5, TO_DATE('08/09/2000', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (222656890, 'Larry', 'Taylor', 35000, 2, TO_DATE('08/09/2012', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (897461302, 'James', 'Bush', 51000, 4, TO_DATE('08/09/2006', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (509990039, 'Delia', 'Jones', 42000, 3, TO_DATE('08/09/2008', 'MM/DD/YYYY'));
--
-- Populate the Bus Table
--
INSERT INTO Bus VALUES ('1FDX4P1', 64, 685320372);
INSERT INTO Bus VALUES ('WP0AB09', 64, 157729572);
INSERT INTO Bus VALUES ('1GCJC39', 64, 868142440);
INSERT INTO Bus VALUES ('JN8AR05', 64, 222656890);
INSERT INTO Bus VALUES ('2BVBF34', 64, 897461302);
INSERT INTO Bus VALUES ('1X2V067', 64, 509990039);
--
-- Populate the Stop Table
--
INSERT INTO Stop VALUES ('Greenview St', 17);
INSERT INTO Stop VALUES ('W Hamilton St', 12);
INSERT INTO Stop VALUES ('Ridgewood Prk', 45);
INSERT INTO Stop VALUES ('Hanover Ave', 42);
INSERT INTO Stop VALUES ('State St', 75);
INSERT INTO Stop VALUES ('Hilldale Rd', 35);
INSERT INTO Stop VALUES ('Bayberry Ln', 27);
INSERT INTO Stop VALUES ('Windfall St', 35);
INSERT INTO Stop VALUES ('Rose Garden', 60);
--
-- Populate the Route Table
--
INSERT INTO Route VALUES (1, 'Greenview St', 'State St');
INSERT INTO Route VALUES (2, 'Hanover Ave', 'Hilldale Rd');
INSERT INTO Route VALUES (3, 'Bayberry Ln', 'Rose Garden');
--
-- Populate Financial Histories for routes
--
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2002', 'MM/DD/YYYY'), 1, 11500.97, 13000.12, 1200.98);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 2, 17000.66, 15800.22, 3212.65);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2009', 'MM/DD/YYYY'), 3, 9876.43, 12343,87, 983.12);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2005', 'MM/DD/YYYY'), 1, 8798.40, 9201.22, 2987.76);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2017', 'MM/DD/YYYY'), 2, 18723.33, 20847.39, 4099.30);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2010', 'MM/DD/YYYY'), 3, 14387.86, 16322.81, 3722.34);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2010', 'MM/DD/YYYY'), 1, 10247.36, 11892.22, 2456.55);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2010', 'MM/DD/YYYY'), 2, 14998.76, 17822.25, 3892.32);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2010', 'MM/DD/YYYY'), 3, 7922.43, 9908.32, 1309.33);
--
-- Populate SchedArrivalTime Table
--
INSERT INTO SchedArrivalTime VALUES ('06:10am', 'Greenview St');
INSERT INTO SchedArrivalTime VALUES ('09:08pm', 'Greenview St');
INSERT INTO SchedArrivalTime VALUES ('06:20am', 'W Hamilton St');
INSERT INTO SchedArrivalTime VALUES ('09:18pm', 'W Hamilton St');
INSERT INTO SchedArrivalTime VALUES ('06:30am', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime VALUES ('09:25pm', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime VALUES ('06:39am', 'State St');
INSERT INTO SchedArrivalTime VALUES ('09:34pm', 'State St');
INSERT INTO SchedArrivalTime VALUES ('06:00am', 'Hanover Ave');
INSERT INTO SchedArrivalTime VALUES ('09:00pm', 'Hanover Ave');
INSERT INTO SchedArrivalTime VALUES ('06:12am', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime VALUES ('09:10am', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime VALUES ('06:19am', 'State St');
INSERT INTO SchedArrivalTime VALUES ('09:14pm', 'State St');
INSERT INTO SchedArrivalTime VALUES ('06:29am', 'Hilldale Rd');
INSERT INTO SchedArrivalTime VALUES ('09:24pm', 'Hilldale Rd');
INSERT INTO SchedArrivalTime VALUES ('06:20am', 'Bayberry Ln');
INSERT INTO SchedArrivalTime VALUES ('09:15pm', 'Bayberry Ln');
INSERT INTO SchedArrivalTime VALUES ('06:27am', 'State St');
INSERT INTO SchedArrivalTime VALUES ('09:20pm', 'State St');
INSERT INTO SchedArrivalTime VALUES ('06:38am', 'Windfall St');
INSERT INTO SchedArrivalTime VALUES ('09:24pm', 'Windfall St');
INSERT INTO SchedArrivalTime VALUES ('06:43am', 'Rose Garden');
INSERT INTO SchedArrivalTime VALUES ('09:29pm', 'Rose Garden');
--
--Populate RodeOn Table
--
INSERT INTO RodeOn VALUES (965574, '1FDX4P1', TO_DATE('02/12/2002', 'MM/DD/YYYY'), 'Greenview St', 'Ridgewood Prk');
INSERT INTO RodeOn VALUES (990311, '1GCJC39', TO_DATE('04/25/2007', 'MM/DD/YYYY'), 'Hanover Ave', 'State St');
INSERT INTO RodeOn VALUES (120746, '2BVBF34', TO_DATE('07/19/2015', 'MM/DD/YYYY'), 'Bayberry Ln', 'Rose Garden');
INSERT INTO RodeOn VALUES (526975, '1X2V067', TO_DATE('10/29/2013', 'MM/DD/YYYY'), 'Windfall St', 'State St');
INSERT INTO RodeOn VALUES (526975, 'WPOAB09', TO_DATE('10/29/2013', 'MM/DD/YYYY'), 'State St', 'W Hamilton St');
INSERT INTO RodeOn VALUES (193044, 'JN8AR05', TO_DATE('01/13/2010', 'MM/DD/YYYY'), 'Ridgewood Prk', 'State St');
INSERT INTO RodeOn VALUES (193044, '2BVBF34', TO_DATE('01/13/2010', 'MM/DD/YYYY'), 'State St', 'Bayberry Ln');
INSERT INTO RodeOn VALUES (128525, '1X2V067', TO_DATE('09/15/2009', 'MM/DD/YYYY'), 'Rose Garden', 'State St');
INSERT INTO RodeOn VALUES (128525, '1FDX4P1', TO_DATE('09/15/2009', 'MM/DD/YYYY'), 'State St', 'Greenview St');
INSERT INTO RodeOn VALUES (390503, '1GCJC39', TO_DATE('06/06/2016', 'MM/DD/YYYY'), 'Hanover Ave', 'Ridgewood Prk');
INSERT INTO RodeOn VALUES (390503, 'WPOAB09', TO_DATE('06/06/2016', 'MM/DD/YYYY'), 'Ridgewood Prk', 'W Hamilton St');
INSERT INTO RodeOn VALUES (293308, '2BVBF34', TO_DATE('12/21/2008', 'MM/DD/YYYY'), 'State St', 'Bayberry Ln');
--
-- Populate Assigned To Table
--
INSERT INTO AssignedTo VALUES ('1FDX4P1', 1, TO_DATE('01/01/2001', 'MM/DD/YYYY'), TO_DATE('06/01/2016', 'MM/DD/YYYY'));
INSERT INTO AssignedTo VALUES ('1FDX4P1', 5, TO_DATE('06/12/2012', 'MM/DD/YYYY'), TO_DATE('07/12/2012', 'MM/DD/YYYY'));
INSERT INTO AssignedTo VALUES (32232, 5, TO_DATE('06/12/2012', 'MM/DD/YYYY'), TO_DATE('07/12/2012', 'MM/DD/YYYY'));
INSERT INTO AssignedTo VALUES (32232, 5, TO_DATE('06/12/2012', 'MM/DD/YYYY'), TO_DATE('07/12/2012', 'MM/DD/YYYY'));
INSERT INTO AssignedTo VALUES (32232, 5, TO_DATE('06/12/2012', 'MM/DD/YYYY'), TO_DATE('07/12/2012', 'MM/DD/YYYY'));


--Driver IC Tests
--
--Invalid Rank
--INSERT INTO Driver VALUES (443243, 'Kevin', 'Jones', 45000, 0, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--Invalid Rank
--INSERT INTO Driver VALUES (112324354, 'Kevin', 'Jones', 45000, 6, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--Invalid salary
--INSERT INTO Driver VALUES (938493928, 'Kevin', 'Jones', 1000, 2, TO_DATE('08/09/2012', 'DD/MM/YYYY')); 
--Valid
--INSERT INTO Driver VALUES (947374938, 'Kevin', 'Jones', 45000, 5, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--Invalid Salary
--INSERT INTO Driver VALUES (938493928, 'Kevin', 'Jones', 35000, 4, TO_DATE('08/09/2012', 'DD/MM/YYYY')); 
--Valid
--INSERT INTO Driver VALUES (243243, 'Kevin', 'Jones', 45000, 4, TO_DATE('08/09/2012', 'DD/MM/YYYY'));
--
--Bus IC Tests
--
--Valid
--INSERT INTO Bus VALUES (1234433, 64, 947374938);
--Valid
--INSERT INTO BUS VALUES (32232, 50, 243243);
--Invalid: referencing a driver that doesnt exist
--INSERT INTO BUS VALUES (243243, 50, 123);
--Invalid: Num of seats is less than min of 30
--INSERT INTO BUS VALUES (234, 40, 947374938);
--
--Route IC Tests
--
--INSERT INTO Stop VALUES ('123 W 5th St', 25);
--INSERT INTO Stop VALUES ('111 Michigan St', 50);
--INSERT INTO Stop VALUES ('Monroe Ave', 55);
--Valid
--INSERT INTO Route VALUES (5, '123 W 5th St', 'Monroe Ave');
--Valid
--INSERT INTO Route VALUES (7, '123 W 5th St', '111 Michigan St');
--Invalid: Route numbers cannot be the same
--INSERT INTO Route VALUES (5, 'Monroe Ave', '111 Michigan St');
--Invalid: Start and end stops cannot be the same
--INSERT INTO Route Values (6, 'Monroe Ave', 'Monroe Ave');
--
--FinHistory IC Tests
--
--Valid
--INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, 1000, 800, 12);
--Invalid: Two fin histories for a route on same day
--INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, 1000, 800, 12);
--Invalid: Negative values 
--INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, -1000, 800, -12);
--Invalid Negative Values
--INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 5, 1000, -800, 12);
--Invalid: Non-existant route
--INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 999, 1000, 800, 12);
--
--SchedArrivalTime IC Tests
--
--Valid
--INSERT INTO SchedArrivalTime VALUES ('09:30pm', 'Monroe Ave');
--Valid
--INSERT INTO SchedArrivalTime VALUES ('04:30pm', '111 Michigan St');
--Invalid: No duplicate times for a stop
--INSERT INTO SchedArrivalTime VALUES ('04:30pm', '111 Michigan St');
--Invalid: A stop must exist to have a scheduled bus stop time
--INSERT INTO SchedArrivalTime VALUES ('04:35pm', '123 Allendale Ave');
--
--RodeOn IC Tests
--
--Valid
--INSERT INTO RodeOn VALUES (123, 1234433, TO_DATE('12/12/2015', 'MM/DD/YYYY'), '123 W 5th St', 'Monroe Ave');
--Valid
--INSERT INTO RodeOn VALUES (222, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '111 Michigan St');
--Invalid: Non-Existant rider
--INSERT INTO RodeOn VALUES (999, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '111 Michigan St');
--Invalid Non-Existant bus
--INSERT INTO RodeOn VALUES (222, 8373723, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '111 Michigan St');
--Invalid: Non-Exsitant on stop
--INSERT INTO RodeOn VALUES (123, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), '123 Ave', '111 Michigan St');
--Invalid: Non-Existant off stop
--INSERT INTO RodeOn VALUES (444, 32232, TO_DATE('06/12/2015', 'MM/DD/YYYY'), 'Monroe Ave', '555 Michigan St');
--
--AssignedTo IC Tests
--
--Valid 
--INSERT INTO AssignedTo VALUES (32232, 5, TO_DATE('06/12/2012', 'MM/DD/YYYY'), TO_DATE('07/12/2012', 'MM/DD/YYYY'));
--Valid
--INSERT INTO AssignedTo VALUES (32232, 7, TO_DATE('07/12/2012', 'MM/DD/YYYY'), TO_DATE('08/12/2012', 'MM/DD/YYYY'));
--Invalid: Bus Doesnt exist
--INSERT INTO AssignedTo VALUES (32, 7, TO_DATE('07/12/2012', 'MM/DD/YYYY'), TO_DATE('08/12/2012', 'MM/DD/YYYY'));
--Invalid: Route does not exist
--INSERT INTO AssignedTo VALUES (1234433, 90, TO_DATE('07/12/2012', 'MM/DD/YYYY'), TO_DATE('08/12/2012', 'MM/DD/YYYY'));
--Invalid: Removed date before assigned date
--INSERT INTO AssignedTo VALUES (32232, 7, TO_DATE('04/12/2012', 'MM/DD/YYYY'), TO_DATE('03/12/2012', 'MM/DD/YYYY'));
--
--StopOnRoute IC Tests
--
--Valid
--INSERT INTO StopOnRoute VALUES (5, 'Monroe Ave', 1);
--Valid
--INSERT INTO StopOnRoute VALUES (7, '111 Michigan St', 10);
--Invalid: Non-Existant route
--INSERT INTO StopOnRoute VALUES (20, '111 Michigan St', 20);
--Invalid: Non-Existant Stop
--INSERT INTO StopOnRoute VALUES (5, '12312 Test St', 2);
--Invalid: Negative stop sequence value
--INSERT INTO StopOnRoute VALUES (5, '111 Michigan St', -2);

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
