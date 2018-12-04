SPOOL project.out
SET ECHO ON

/*
CIS-353 Bus Company Database Team 5
Nabeel Vali, Jongin Seon, Alec Betancourt, Christian Tsoungui Nkoulou
*/

--Delete all tables to prevent duplicate info 
DROP TABLE Rider CASCADE CONSTRAINTS;
DROP TABLE Bus CASCADE CONSTRAINTS;
DROP TABLE Driver CASCADE CONSTRAINTS;
DROP TABLE Route CASCADE CONSTRAINTS;
DROP TABLE Stop CASCADE CONSTRAINTS;
DROP TABLE FinHistory CASCADE CONSTRAINTS;
DROP TABLE SchedArrivalTime CASCADE CONSTRAINTS;
DROP TABLE RodeOn CASCADE CONSTRAINTS;
DROP TABLE StopOnRoute CASCADE CONSTRAINTS;


CREATE TABLE Rider 
(
	riderId INTEGER,
	fName VARCHAR(15) NOT NULL,
	lName VARCHAR(15) NOT NULL,
	--
	--IC_uniqueRdr: Each rider is identified by their rider ID
	CONSTRAINT IC_uniqueRdr PRIMARY KEY (riderId)
);

CREATE TABLE Driver
(
	Ssn INTEGER,
	fName VARCHAR(10) NOT NULL,
	lName VARCHAR(10) NOT NULL,
	salary INTEGER NOT NULL,
	dRank INTEGER NOT NULL,
	--
	--IC_uniqueDr: Each driver is indentified by their Ssn
	CONSTRAINT IC_uniqueDr PRIMARY KEY (Ssn),
	--IC_rank: A drivers rank is only between 1 and 3 inclusive
	CONSTRAINT IC_rank CHECK(NOT(dRank < 1 OR dRank > 3)),
	--IC_ranksal: Drivers >= rank 3 must make at least $45000
	CONSTRAINT IC_rankSal CHECK(NOT(dRank = 3 AND salary < 45000)),
	--IC_rankmin: All drivers make at least $10000
	CONSTRAINT IC_rankMin CHECK(salary >= 10000)
);

CREATE TABLE Stop
(
	stopName VARCHAR(20),
	stopCapacity INTEGER NOT NULL,
	--
	--IC_stName: Each stop has a unique name
	CONSTRAINT IC_stName PRIMARY KEY (stopName),
	--IC_stpCap: A stop must hold at least 10 people
	CONSTRAINT IC_stpCap CHECK(stopCapacity >= 10)
);	

CREATE TABLE Route
(
	rNum INTEGER,
	startLoc VARCHAR(20) NOT NULL,
	endLoc VARCHAR(20) NOT NULL,
	--
	--IC_uniquerNum: Each route has a unique route number
	CONSTRAINT IC_uniquerNum PRIMARY KEY (rNum),
	--IC_startLoc: Every route has a starting location which is the first stop
	CONSTRAINT IC_rstartLoc FOREIGN KEY (startLoc) REFERENCES Stop(stopName) 
		ON DELETE CASCADE,
	--IC_endLoc: Every route has an ending location which is the last stop
	CONSTRAINT IC_rendLoc FOREIGN KEY (endLoc) REFERENCES Stop(stopName) 
		ON DELETE CASCADE,
	--IC_notSame: A route cannot begin and terminate at the same stop
	CONSTRAINT IC_notSame CHECK(startLoc <> endLoc)
);

CREATE TABLE Bus
(
	VIN VARCHAR(7),
	numSeats INTEGER NOT NULL,
	driverSsn INTEGER NOT NULL,
	routeNum INTEGER NOT NULL,
	--
	--IC_bVin: Every bus is identified by its VIN #
	CONSTRAINT IC_bVin PRIMARY KEY (VIN),
	--IC_bDriv: A bus is assigned a unique driver
	CONSTRAINT IC_bDriv FOREIGN KEY (driverSsn) REFERENCES Driver(Ssn) 
		ON DELETE CASCADE,
	--IC_oneDriver: An active bus only has one driver 
	CONSTRAINT IC_oneDriver UNIQUE (driverSsn),
	--ic_oneRoute: A bus is assigned to one route only
	CONSTRAINT IC_oneRoute FOREIGN KEY (routeNum) REFERENCES Route(rNum) 
		ON DELETE CASCADE,
	--IC_seatMin All Busses have a minimum of 30 seats
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
	--IC_rHist: A financial history can be obtained for the same route on different days
	CONSTRAINT IC_rHist PRIMARY KEY (historyDate, routeNum),
	--IC_routeEx: A financial history can only be created for an existing route
	CONSTRAINT IC_routeEx FOREIGN KEY (routeNum) REFERENCES Route(rNum) 
		ON DELETE CASCADE,
	--IC_posRev: Numeric values for revenues must be positive
	CONSTRAINT IC_posRev CHECK(projRev >= 0 AND actRev >= 0 AND expenses >= 0)
);

CREATE TABLE SchedArrivalTime
(
	schedArrivalTime VARCHAR(16),
	stopName VARCHAR(20),
	--
	--IC_stopTime: A stop can have bus arrivals at different times
	CONSTRAINT IC_stopTime PRIMARY KEY (schedArrivalTime, stopName),
	--IC_stopExist: A bus can only stop at an existing stop
	CONSTRAINT IC_stopExist FOREIGN KEY (stopName) REFERENCES Stop(stopName) 
		ON DELETE CASCADE
);

CREATE TABLE RodeOn
(
	passengerID INTEGER,
	busVin VARCHAR(7),
	rideDate DATE NOT NULL,
	onStop VARCHAR(20) NOT NULL,
	offStop VARCHAR(20) NOT NULL,
	--
	-- IC_bRide: A passenger can ride multiple busses
	CONSTRAINT IC_bRide PRIMARY KEY (passengerID, busVin),
	--fKey_pExists: a passenger must be someone who has ridden a bus
	CONSTRAINT fKey_pExists FOREIGN KEY (passengerID) REFERENCES Rider(riderId) 
		ON DELETE CASCADE,
	--fKey_bExists: a bus must be an existing bus
	CONSTRAINT fKey_bExists FOREIGN KEY (busVin) REFERENCES Bus(Vin) 
		ON DELETE SET NULL,
	--fKey_stpExists: The stop the passenger boarded the bus must exist
	CONSTRAINT fKey_stpExists FOREIGN KEY (onStop) REFERENCES Stop(stopName) 
		ON DELETE CASCADE,
	--fKey_ostpExists: The stpo where the passenger exited must exist
	CONSTRAINT fKey_oStpExists FOREIGN KEY (offStop) REFERENCES Stop(stopName)
		ON DELETE CASCADE
);

CREATE TABLE StopOnRoute
(
	rNum INTEGER,
	stopName VARCHAR(20),
	stopSequence Integer NOT NULL,
	--
	--IC_stpOnR: A stop can be assigned to multiple routes
	CONSTRAINT IC_stpOnR PRIMARY KEY (rNum, stopName),
	--IC_rtExists: a stop must be assigned to an existing route
	CONSTRAINT IC_rtExists FOREIGN KEY (rNum) REFERENCES Route(rNum) 
		ON DELETE CASCADE,
	--IC_stp1Exists: A route can only be assigned existing stops
	CONSTRAINT IC_stp1Exists FOREIGN KEY (stopName) REFERENCES Stop(stopName)
		ON DELETE CASCADE,
	--IC_stopSeq: A stop sequence value must be positive
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
INSERT INTO Rider VALUES (432432, 'Jerome', 'Smith');
--
-- Populate the Driver Table
--
INSERT INTO Driver VALUES (685320372, 'Lillian', 'Bryant', 25000, 1);
INSERT INTO Driver VALUES (157729572, 'Debra', 'Cooper', 49000, 3);
INSERT INTO Driver VALUES (868142440, 'Justin', 'Ward', 55000, 3);
INSERT INTO Driver VALUES (222656890, 'Larry', 'Taylor', 23000, 1);
INSERT INTO Driver VALUES (897461302, 'James', 'Bush', 51000, 3);
INSERT INTO Driver VALUES (120384921, 'David', 'Ross', 44000, 2);
--
-- Populate the Stop Table
--
INSERT INTO Stop VALUES ('Greenview St', 67);
INSERT INTO Stop VALUES ('W Hamilton St', 70);
INSERT INTO Stop VALUES ('Ridgewood Prk', 45);
INSERT INTO Stop VALUES ('Hanover Ave', 42);
INSERT INTO Stop VALUES ('State St', 61);
INSERT INTO Stop VALUES ('Hilldale Rd', 35);
INSERT INTO Stop VALUES ('Bayberry Ln', 82);
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
INSERT INTO Bus VALUES ('WP0AB09', 60, 157729572, 2);
INSERT INTO Bus VALUES ('1GCJC39', 80, 868142440, 3);
INSERT INTO Bus VALUES ('JN8AR05', 70, 222656890, 4);
INSERT INTO Bus VALUES ('2BVBF34', 55, 897461302, 5);
INSERT INTO Bus VALUES ('1X2V067', 40, 120384921, 6);
--
-- Populate Financial Histories for routes
--
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2009', 'MM/DD/YYYY'), 1, 13500.97, 14074.12, 1200.98);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2008', 'MM/DD/YYYY'), 2, 12534.66, 12812.22, 3212.65);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2012', 'MM/DD/YYYY'), 3, 9876.43, 12349.87, 983.12);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2008', 'MM/DD/YYYY'), 4, 10543.43, 11134.87, 1189.12);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2009', 'MM/DD/YYYY'), 5, 11645.23, 12218.92, 3012.14);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2010', 'MM/DD/YYYY'), 6, 13453.43, 12345.87, 1083.32);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2011', 'MM/DD/YYYY'), 1, 18798.40, 13206.22, 1987.76);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2011', 'MM/DD/YYYY'), 2, 19723.33, 15844.39, 4099.30);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2008', 'MM/DD/YYYY'), 3, 14387.86, 13723.22, 3722.34);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2010', 'MM/DD/YYYY'), 4, 12134.12, 14927.41, 2022.45);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2011', 'MM/DD/YYYY'), 5, 11346.23, 12328.67, 3454.14);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2011', 'MM/DD/YYYY'), 6, 10234.43, 10321.82, 1022.75);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2008', 'MM/DD/YYYY'), 1, 13356.23, 16899.87, 2456.55);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2009', 'MM/DD/YYYY'), 2, 15998.71, 13822.25, 4092.32);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2009', 'MM/DD/YYYY'), 3, 10654.12,8906.11, 1231.21);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2011', 'MM/DD/YYYY'), 4, 8934.32, 9908.32, 1119.39);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2010', 'MM/DD/YYYY'), 5, 11747.42, 10901.37, 2909.23);
INSERT INTO FinHistory VALUES(TO_DATE('08/09/2008', 'MM/DD/YYYY'), 6, 7986.87, 9903.38, 999.34);
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
INSERT INTO RodeOn VALUES (120746, '1X2V067', TO_DATE('07/19/2015', 'MM/DD/YYYY'), 'Rose Garden', 'Windfall St');
INSERT INTO RodeOn VALUES (526975, '1X2V067', TO_DATE('10/29/2013', 'MM/DD/YYYY'), 'Windfall St', 'State St');
INSERT INTO RodeOn VALUES (526975, 'WP0AB09', TO_DATE('10/29/2013', 'MM/DD/YYYY'), 'State St', 'W Hamilton St');
INSERT INTO RodeOn VALUES (193044, '1GCJC39', TO_DATE('01/13/2010', 'MM/DD/YYYY'), 'Ridgewood Prk', 'State St');
INSERT INTO RodeOn VALUES (193044, '1X2V067', TO_DATE('01/13/2010', 'MM/DD/YYYY'), 'State St', 'Bayberry Ln');
INSERT INTO RodeOn VALUES (128525, '1X2V067', TO_DATE('09/15/2009', 'MM/DD/YYYY'), 'Rose Garden', 'State St');
INSERT INTO RodeOn VALUES (128525, 'WP0AB09', TO_DATE('09/15/2009', 'MM/DD/YYYY'), 'State St', 'Greenview St');
INSERT INTO RodeOn VALUES (390503, '1GCJC39', TO_DATE('06/06/2016', 'MM/DD/YYYY'), 'Hanover Ave', 'Ridgewood Prk');
INSERT INTO RodeOn VALUES (390503, 'WP0AB09', TO_DATE('06/06/2016', 'MM/DD/YYYY'), 'Ridgewood Prk', 'W Hamilton St');
INSERT INTO RodeOn VALUES (293308, 'JN8AR05', TO_DATE('12/21/2008', 'MM/DD/YYYY'), 'Hilldale Rd', 'Hanover Ave');
INSERT INTO RodeOn VALUES (432432, '2BVBF34', TO_DATE('06/19/2008', 'MM/DD/YYYY'), 'Rose Garden', 'Bayberry Ln');
INSERT INTO RodeOn VALUES (432432, '1X2V067', TO_DATE('06/19/2010', 'MM/DD/YYYY'), 'Bayberry Ln', 'Rose Garden');
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





--Query 1: Join involving at least 4 relations
--Find the Ssn, First and last name, and the Vin of all drivers who drove busses that stop at Ridgewood Prk
--Order by driver Ssn
SELECT D.Ssn, D.fName, D.lName, B.VIN
FROM Driver D, Bus B, Route R, Stop S, StopOnRoute St
WHERE D.Ssn = B.driverSsn AND
      B.routeNum = R.rNum AND
      R.rNum = St.rNum AND
      St.stopName = S.stopName AND
      S.stopName = 'Ridgewood Prk'
ORDER BY D.Ssn;

--Query 2: Self Join:
--Find the fName, lName, and rank of all pairs of drivers who have the same rank
SELECT D1.fName, D1.lName, D1.dRank, D2.fName, D2.lName, D2.dRank
FROM Driver D1, Driver D2
WHERE D1.dRank = D2.dRank AND
      D1.Ssn < D2.Ssn;

--Query 3: Union, Intersect, Minus
--Find the ssn, rank, and numseats of all drivers who are of rank 2 or greater and drive busses with more than 40 seats
SELECT D.Ssn, D.dRank, B.numSeats
FROM Driver D, Bus B
WHERE D.Ssn = B.driverSsn AND
      D.dRank >= 2
INTERSECT
SELECT D.Ssn, D.dRank, B.numSeats
From Driver D, Bus B
WHERE D.Ssn = B.driverSsn AND
      B.numSeats > 40;

--Query 4: SUM, AVG, MAX, MIN
--Find the route number and sum of every routes actual revenue between 2008 and 2012
SELECT R.rNum, SUM(F.actRev)
FROM Route R, FinHistory F
WHERE R.rNum = F.routeNum AND
      (historyDate > TO_DATE('12/31/2007', 'MM/DD/YYYY') AND
       historyDate < TO_DATE('01/01/2013', 'MM/DD/YYYY'))
GROUP BY R.rNum;

--Query 5: Group order by and having in one query:
--Find the name and number of routes served of all stops that serve more than 3 routes
--Order by the number of stops
SELECT S.stopName, COUNT(S.stopName)
FROM StopOnRoute St, Stop S
WHERE S.stopName = St.stopName
GROUP BY S.stopName
HAVING COUNT(S.stopName) > 3
ORDER BY COUNT(S.stopName);

--Query 6: Correlated Subquery:
--find the stop name, capacity and route number of stops that have the highest capacity along each route
--Order by the route number
SELECT S.stopName, S.stopCapacity, R.rNum
FROM Stop S, Route R
WHERE S.stopCapacity = (
	SELECT MAX(S2.stopCapacity)
	FROM STOP S2, StopOnRoute St
	WHERE St.rNum = R.rNum AND
              S2.stopname = St.stopName)
ORDER BY R.rNum;

--Query 7: Non-Correlated Subquery: 
--Find the ID and last name of every rider who hasn't boarded a bus at a stop on route 2. 
--Order by the Rider's Id
SELECT P.riderId, P.lName
FROM  Rider P
WHERE P.riderId NOT IN
       (SELECT DISTINCT O.passengerID
        FROM RodeOn O, StopOnRoute St
	WHERE St.rNum = 2 AND
	     (O.onStop = St.stopName))
ORDER BY P.riderId;

--Query 8: Division Query: Find the riderID, first and last name of all the riders who rode on all busses that stop at rose garden
SELECT R.riderId, R.fName, R.lName
FROM Rider R
WHERE NOT EXISTS ((SELECT B.VIN 
		   FROM Bus B, StopOnRoute St
		   WHERE B.routeNum = St.rNum AND
			 St.stopName = 'Rose Garden')
		   MINUS
		   (SELECT B.VIN
	            FROM Bus B, StopOnRoute St, RodeOn P
		    WHERE P.passengerId = R.riderId AND
		          P.busVin = B.VIN AND
			  B.routeNum = St.rNum AND
			  St.stopName = 'Rose Garden'));

--Query 9: Outer Join Query: Find the first name and last name of all the drivers and the VIN of the busses they drive
--Order by the Driver's Ssn
SELECT D.fName, D.lName, B.VIN
FROM Driver D LEFT OUTER JOIN Bus B ON B.driverSsn = D.Ssn
ORDER BY D.Ssn;
			     
--Query 10: RANK Query: Find the rank of a stop with capacity 54 among all the other stops
SELECT RANK (54) WITHIN GROUP
       (ORDER BY stopCapacity) "Rank of Stop with Capacity 54"
FROM Stop;
			     
--Query 11: TOP-N Query: Find the ssn, last name, and salary of the 3 highest paid drivers
SELECT Ssn, lName, salary
FROM (SELECT * FROM Driver ORDER BY salary DESC)
WHERE ROWNUM < 4;





--
--IC Tests
--


--
--Constraint 1 Tests: IC_uniqueRnum, No duplicate route numbers
--



INSERT INTO Route VALUES (4, 'Rose Garden', 'State St');
INSERT INTO Route VALUES (1, 'State St', 'Ridgewood Prk');



--
--Constraint 2 Tests: IC_bDriv, A driver does not exist
--



INSERT INTO BUS VALUES ('243243', 50, 938473618, 6);
INSERT INTO BUS VALUES ('1ER93IF', 65, 453627483, 5);



--
--Constraint 3 Test: IC_rank, A drivers rank can only be between 1 and 3 inclusive
--



INSERT INTO Driver VALUES (948374636, 'Kevin', 'Jones', 45000, 6);
INSERT INTO Driver VALUES (373649382, 'Adam', 'Smith', 45000, 0);



--
--Constraint 4 Test: IC_rankSal, A driver of rank = 3, must have a salary >= $45000
--



INSERT INTO Driver VALUES (938493928, 'Kevin', 'Jones', 35000, 3); 
INSERT INTO Driver VALUES (293742343, 'Michelle', 'Brown', 12000, 3); 


COMMIT;

SPOOL OFF
