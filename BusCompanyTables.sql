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
	--IC_rank: A drivers rank is only between 1 and 3 inclusive
	CONSTRAINT IC_rank CHECK(NOT(dRank < 1 OR dRank > 3)),
	--IC_ranksal: Drivers >= rank 3 must make at least $45000
	CONSTRAINT IC_rankSal CHECK(NOT(dRank = 3 AND salary < 45000)),
	--IC_rankmin: All salaries are at least 10000
	CONSTRAINT IC_rankMin CHECK(salary >= 10000)
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

CREATE TABLE Bus
(
	VIN VARCHAR(7) PRIMARY KEY,
	numSeats INTEGER NOT NULL,
	driverSsn INTEGER NOT NULL,
	routeNum INTEGER NOT NULL,
	--
	--fKey1: A bus is assigned a driver from the list of active drivers
	CONSTRAINT fKey1 FOREIGN KEY (driverSsn) REFERENCES Driver(Ssn) ON DELETE CASCADE,
	--IC_oneDriver: An active bus only has one driver 
	CONSTRAINT IC_oneDriver UNIQUE (driverSsn),
	--ic_oneRoute: A bus is assigned to one route only
	CONSTRAINT IC_oneRoute FOREIGN KEY (routeNum) REFERENCES Route(rNum),
	--IC_seatMin All Busses have a minimum of 30
	CONSTRAINT IC_seatMin CHECK(numSeats >= 30)
);

CREATE TABLE FinHistory
(
	historyDate DATE,
	routeNum INTEGER,
	projRev DECIMAL(7,2) NOT NULL,
	actRev DECIMAL(7,2) NOT NULL,
	expenses DECIMAL(7,2) NOT NULL,
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
INSERT INTO Driver VALUES (685320372, 'Lillian', 'Bryant', 25000, 1, TO_DATE('03/09/2015', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (157729572, 'Debra', 'Cooper', 49000, 3, TO_DATE('05/25/2009', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (868142440, 'Justin', 'Ward', 55000, 3, TO_DATE('09/28/2000', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (222656890, 'Larry', 'Taylor', 23000, 1, TO_DATE('12/09/2012', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (897461302, 'James', 'Bush', 51000, 3, TO_DATE('02/12/2006', 'MM/DD/YYYY'));
INSERT INTO Driver VALUES (120384921, 'David', 'Ross', 44000, 2, TO_DATE('03/28/2004', 'MM/DD/YYYY'));
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
INSERT INTO Route VALUES (2, 'State St', 'Greenview St');
INSERT INTO Route VALUES (3, 'Hanover Ave', 'Hilldale Rd');
INSERT INTO Route VALUES (4, 'Hilldale Rd', 'Hanover Ave');	
INSERT INTO Route VALUES (5, 'Bayberry Ln', 'Rose Garden');
INSERT INTO Route VALUES (6, 'Rose Garden', 'Bayberry Ln');
--
-- Populate the bus table
--
INSERT INTO Bus VALUES ('1FDX4P1', 30, 685320372, 1);
INSERT INTO Bus VALUES ('WP0AB09', 30, 157729572, 2);
INSERT INTO Bus VALUES ('1GCJC39', 30, 868142440, 3);
INSERT INTO Bus VALUES ('JN8AR05', 40, 222656890, 4);
INSERT INTO Bus VALUES ('2BVBF34', 40, 897461302, 5);
INSERT INTO Bus VALUES ('1X2V067', 30, 120384921, 6);
--
-- Populate Financial Histories for routes
--
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2002', 'MM/DD/YYYY'), 1, 13500.97, 14000.12, 1200.98);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 2, 17000.66, 15800.22, 3212.65);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2011', 'MM/DD/YYYY'), 3, 9876.43, 12343.87, 983.12);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2006', 'MM/DD/YYYY'), 4, 10876.43, 11133.87, 1189.12);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2008', 'MM/DD/YYYY'), 5, 11076.23, 12213.92, 3012.14);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2009', 'MM/DD/YYYY'), 6, 10876.43, 92343.87, 1083.32);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2005', 'MM/DD/YYYY'), 1, 18798.40, 18201.22, 1987.76);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2017', 'MM/DD/YYYY'), 2, 19723.33, 19847.39, 4099.30);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 3, 14387.86, 12322.22, 3722.34);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2007', 'MM/DD/YYYY'), 4, 12134.12, 11322.41, 2022.45);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2005', 'MM/DD/YYYY'), 5, 11387.23, 12322.67, 3454.14);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2012', 'MM/DD/YYYY'), 6, 10387.43, 10322.82, 1022.75);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2014', 'MM/DD/YYYY'), 1, 19047.23, 16892.87, 2456.55);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2015', 'MM/DD/YYYY'), 2, 15998.71, 17822.25, 4092.32);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2009', 'MM/DD/YYYY'), 3, 10922.12,8908.11, 1231.21);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2004', 'MM/DD/YYYY'), 4, 8922.32, 9908.32, 1119.39);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2006', 'MM/DD/YYYY'), 5, 11922.42, 10908.37, 2909.23);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2003', 'MM/DD/YYYY'), 6, 7922.87, 9908.38, 999.34);
--
-- Populate SchedArrivalTime Table
--
--R1 
INSERT INTO SchedArrivalTime VALUES ('06:00am', 'Greenview St');
INSERT INTO SchedArrivalTime Values ('06:20am', 'W Hamilton St');
INSERT INTO SchedArrivalTime Values ('06:30am', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime Values ('06:39am', 'State St');
--R2
INSERT INTO SchedArrivalTime Values ('06:50am', 'State St');
INSERT INTO SchedArrivalTime Values ('07:02am', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime Values ('07:13am', 'W Hamilton St');
INSERT INTO SchedArrivalTime Values ('07:25am', 'Greenview St');
--R3
INSERT INTO SchedArrivalTime Values ('06:00am', 'Hanover Ave');
INSERT INTO SchedArrivalTime Values ('06:12am', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime Values ('06:19am', 'State St');
INSERT INTO SchedArrivalTime Values ('06:28am', 'Hilldale Rd');
--R4
INSERT INTO SchedArrivalTime Values ('06:34am', 'Hilldale Rd');
INSERT INTO SchedArrivalTime Values ('06:45am', 'State St');
INSERT INTO SchedArrivalTime Values ('06:53am', 'Ridgewood Prk');
INSERT INTO SchedArrivalTime Values ('07:00am', 'Hanover Ave');
--R5
INSERT INTO SchedArrivalTime Values ('06:00am', 'Bayberry Ln');
INSERT INTO SchedArrivalTime Values ('06:11am', 'State St');
INSERT INTO SchedArrivalTime Values ('06:17am', 'Windfall St');
INSERT INTO SchedArrivalTime Values ('06:25am', 'Rose Garden');
--R6
INSERT INTO SchedArrivalTime Values ('06:30am', 'Rose Garden');
INSERT INTO SchedArrivalTime Values ('06:37am', 'Windfall St');
INSERT INTO SchedArrivalTime Values ('06:46am', 'State St');
INSERT INTO SchedArrivalTime Values ('06:56am', 'Bayberry Ln');
--
--Populate RodeOn Table
--
INSERT INTO RodeOn VALUES (965574, '1FDX4P1', TO_DATE('02/12/2002', 'MM/DD/YYYY'), 'Greenview St', 'Ridgewood Prk');
INSERT INTO RodeOn VALUES (990311, '1GCJC39', TO_DATE('04/25/2007', 'MM/DD/YYYY'), 'Hanover Ave', 'State St');
INSERT INTO RodeOn VALUES (120746, '2BVBF34', TO_DATE('07/19/2015', 'MM/DD/YYYY'), 'Bayberry Ln', 'Rose Garden');
INSERT INTO RodeOn VALUES (526975, '1X2V067', TO_DATE('10/29/2013', 'MM/DD/YYYY'), 'Windfall St', 'State St');
INSERT INTO RodeOn VALUES (526975, 'WP0AB09', TO_DATE('10/29/2013', 'MM/DD/YYYY'), 'State St', 'W Hamilton St');
INSERT INTO RodeOn VALUES (193044, '1GCJC39', TO_DATE('01/13/2010', 'MM/DD/YYYY'), 'Ridgewood Prk', 'State St');
INSERT INTO RodeOn VALUES (193044, '1X2V067', TO_DATE('01/13/2010', 'MM/DD/YYYY'), 'State St', 'Bayberry Ln');
INSERT INTO RodeOn VALUES (128525, '1X2V067', TO_DATE('09/15/2009', 'MM/DD/YYYY'), 'Rose Garden', 'State St');
INSERT INTO RodeOn VALUES (128525, 'WP0AB09', TO_DATE('09/15/2009', 'MM/DD/YYYY'), 'State St', 'Greenview St');
INSERT INTO RodeOn VALUES (390503, '1GCJC39', TO_DATE('06/06/2016', 'MM/DD/YYYY'), 'Hanover Ave', 'Ridgewood Prk');
INSERT INTO RodeOn VALUES (390503, 'WP0AB09', TO_DATE('06/06/2016', 'MM/DD/YYYY'), 'Ridgewood Prk', 'W Hamilton St');
INSERT INTO RodeOn VALUES (293308, 'JN8AR05', TO_DATE('12/21/2008', 'MM/DD/YYYY'), 'Hilldale Rd', 'Hanover Ave');
--
-- Populate Stop on Route Table
--
INSERT INTO StopOnRoute VALUES (1, 'Greenview St', 1);
INSERT INTO StopOnRoute VALUES (1, 'W Hamilton St', 2);
INSERT INTO StopOnRoute VALUES (1, 'Ridgewood Prk', 3);
INSERT INTO StopOnRoute VALUES (1, 'State St', 4);
INSERT INTO StopOnRoute VALUES (2, 'State St', 1);
INSERT INTO StopOnRoute VALUES (2, 'Ridgewood Prk', 2);
INSERT INTO StopOnRoute VALUES (2, 'W Hamilton St', 3);
INSERT INTO StopOnRoute VALUES (2, 'Greenview St', 4);
INSERT INTO StopOnRoute VALUES (3, 'Hanover Ave', 1);
INSERT INTO StopOnRoute VALUES (3, 'Ridgewood Prk', 2);
INSERT INTO StopOnRoute VALUES (3, 'State St', 3);
INSERT INTO StopOnRoute VALUES (3, 'Hilldale Rd', 4);
INSERT INTO StopOnRoute VALUES (4, 'Hilldale Rd', 1);
INSERT INTO StopOnRoute VALUES (4, 'State St', 2);
INSERT INTO StopOnRoute VALUES (4, 'Ridgewood Prk', 3);
INSERT INTO StopOnRoute VALUES (4, 'Hanover Ave', 4);
INSERT INTO StopOnRoute VALUES (5, 'Bayberry Ln', 1);
INSERT INTO StopOnRoute VALUES (5, 'State St', 2);
INSERT INTO StopOnRoute VALUES (5, 'Windfall St', 3);
INSERT INTO StopOnRoute VALUES (5, 'Rose Garden', 4);
INSERT INTO StopOnRoute VALUES (6, 'Rose Garden', 1);
INSERT INTO StopOnRoute VALUES (6, 'Windfall St', 2);
INSERT INTO StopOnRoute VALUES (6, 'State St', 3);
INSERT INTO StopOnRoute VALUES (6, 'Bayberry Ln', 4);


--Query 1: Find the Ssn, First and last name, and the Vin of all drivers who drove busses that stop at Ridgewood Prk
SELECT D.Ssn, D.fName, D.lName, B.VIN
FROM Driver D, Bus B, Route R, Stop S, StopOnRoute St
WHERE D.Ssn = B.driverSsn AND
      B.routeNum = R.rNum AND
      R.rNum = St.rNum AND
      St.stopName = S.stopName AND
      S.stopName = 'Ridgewood Prk'
ORDER BY D.Ssn;

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
SELECT * FROM StopOnRoute;

COMMIT;

SPOOL OFF
