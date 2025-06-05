-- A paper --
-- 1
SELECT * FROM SHIP.SH_SHIP
WHERE NET_WEIGHT > 300
ORDER BY NET_WEIGHT;

-- 2
SELECT T_ID, DEPARTURE_TIME, ARRIVAL_TIME FROM SHIP.SH_TRIP
WHERE ARRIVAL_PORT = 'It_Cat'
    AND ARRIVAL_TIME >= TO_DATE('2021-06-16', 'yyyy-mm-dd')
    AND ARRIVAL_TIME < TO_DATE('2021-07-01', 'yyyy-mm-dd')
ORDER BY ARRIVAL_TIME;

-- 3
SELECT TO_CHAR(date_of_order, 'yyyy'), TO_CHAR(date_of_order, 'Month') FROM SHIP.SH_ORDER
GROUP BY TO_CHAR(date_of_order, 'yyyy'), TO_CHAR(date_of_order, 'Month')
HAVING COUNT(*) >= 8
ORDER BY TO_CHAR(date_of_order, 'yyyy'), TO_CHAR(date_of_order, 'Month');

-- 4
SELECT DISTINCT(c_id), first_name, last_name, no_of_containers FROM ship.sh_client c
RIGHT JOIN ship.sh_order o ON o.client_id = C.c_id
WHERE no_of_containers > 20 AND email IS NOT NULL
ORDER BY last_name, first_name;

-- 5
SELECT DEPARTURE_PORT, arrival_port, SUM(NET_WEIGHT) FROM SHIP.sh_ship s
JOIN SHIP.sh_TRIP t ON s.SH_ID = t.SHIP
GROUP BY DEPARTURE_PORT, arrival_port
HAVING SUM(NET_WEIGHT) > 1000
ORDER BY SUM(NET_WEIGHT) DESC;

-- 6
SELECT country, c_name, departure_port FROM SHIP.SH_PORT p
JOIN SHIP.SH_TRIP t ON p.p_id = t.arrival_port
JOIN SHIP.SH_CITY c ON p.city = c.c_id
WHERE P_DESCRIPTION LIKE '%ship service: strong%'
ORDER BY country, c_name, departure_port;

-- 7
SELECT o_id, shipping_fee
FROM SHIP.SH_ORDER
WHERE DATE_OF_ORDER >= TO_DATE('2021-04-01', 'yyyy-mm-dd')
  AND DATE_OF_ORDER < TO_DATE('2021-05-01', 'yyyy-mm-dd')
  AND shipping_fee = (
    SELECT MAX(shipping_fee)
    FROM SHIP.SH_ORDER
    WHERE DATE_OF_ORDER >= TO_DATE('2021-04-01', 'yyyy-mm-dd')
      AND DATE_OF_ORDER < TO_DATE('2021-05-01', 'yyyy-mm-dd')
  );

-- 8
SELECT country, COUNT(o_id) AS total_order FROM SHIP.SH_PORT p
JOIN SHIP.SH_ORDER o ON p.p_id = o.DEPARTURE_PORT
JOIN SHIP.SH_CITY c ON p.city = c.C_ID
GROUP BY country
ORDER BY total_order DESC
FETCH FIRST 3 ROWS ONLY;

-- 9
CREATE TABLE sh_staff (
    id NUMBER(5),
    last_name VARCHAR2(40) NOT NULL,
    first_name VARCHAR2(40) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR2(200),
    ship VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_sh_staff PRIMARY KEY (id),
    CONSTRAINT uq_sh_staff_name_dob UNIQUE (last_name, first_name, date_of_birth),
    CONSTRAINT fk_sh_staff_ship FOREIGN KEY (ship) REFERENCES sh_ship (ship)
);

-- 10
REVOKE SELECT ON sh_staff FROM panovies;

-- 11
CREATE TABLE a_port AS
SELECT * FROM SHIP.SH_PORT
WHERE 1=0;

INSERT INTO a_port
SELECT * FROM ship.sh_port
WHERE P_DESCRIPTION LIKE '%rail connection%';

-- 12
CREATE VIEW order_each_port AS
SELECT country, c_name, COUNT(o_id) AS total_order FROM SHIP.SH_PORT p
LEFT JOIN SHIP.SH_ORDER o ON p.p_id = o.DEPARTURE_PORT
JOIN SHIP.SH_CITY c ON p.city = c.C_ID
GROUP BY country, c_name
ORDER BY total_order DESC;

--------------------------------------------------------------------------------------

-- B Paper --
-- 1
SELECT DISTINCT country FROM SHIP.SH_CITY
ORDER BY country;

-- 2
SELECT 
    TO_CHAR(date_of_order, 'yyyy-mm-dd') AS o_date,
    TO_CHAR(date_of_order, 'hh24:mi:ss') AS order_time,
    shipping_fee 
FROM SHIP.SH_ORDER
WHERE shipping_fee >= 10000000
   OR TO_CHAR(date_of_order, 'hh24:mi:ss') BETWEEN '12:00:00' AND '23:59:59'
ORDER BY o_date;

-- 3
SELECT order_id, SUM(cargo_weight) FROM SHIP.SH_ASSIGN
GROUP BY order_id
HAVING SUM(cargo_weight) > 1000
ORDER BY SUM(cargo_weight);

-- 4
SELECT DISTINCT c_id, last_name, first_name FROM SHIP.SH_CLIENT
WHERE c_id NOT IN (SELECT client_id FROM SHIP.SH_ORDER);

-- 5
SELECT COUNT(t_id) num_departure, departure_port FROM SHIP.SH_TRIP
WHERE ship IN (
    SELECT sh_id FROM SHIP.SH_SHIP
    WHERE sh_name = 'Goliat')
GROUP BY departure_port
ORDER BY num_departure DESC;

-- 6
SELECT t_id, t_name AS type_name, sh_id, sh_name AS ship_name FROM SHIP.SH_SHIP_TYPE st
LEFT JOIN SHIP.SH_SHIP s ON st.t_id = s.sh_type
ORDER BY type_name, ship_name;

-- 7
SELECT DISTINCT p_id, country, c_name FROM SHIP.SH_PORT p
JOIN SHIP.SH_CITY c ON p.city = c.c_id
WHERE p_id IN (SELECT departure_port FROM SHIP.SH_TRIP
                WHERE ship = (SELECT sh_id FROM SHIP.SH_SHIP
                                WHERE sh_name = 'SC Bella'));

-- 8
SELECT sh_name AS ship_name, MAX_CARRYING_CAPACITY, t_name AS type_name
FROM SHIP.SH_SHIP s
LEFT JOIN SHIP.SH_SHIP_TYPE st ON s.sh_type = st.t_id
WHERE sh_id NOT IN (SELECT ship FROM SHIP.SH_TRIP);

-- 9
CREATE TABLE my_staff (
    id NUMBER(5),
    last_name VARCHAR2(40) NOT NULL,
    first_name VARCHAR2(40) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR2(200),
    ship_id VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_sh_staff PRIMARY KEY (id),
    CONSTRAINT uq_my_staff_name_dob UNIQUE (last_name, first_name, date_of_birth),
    CONSTRAINT fk_my_staff_ship FOREIGN KEY (ship_id) REFERENCES MY_SHIP (SH_ID)
);

-- 10
CREATE TABLE my_ship AS
SELECT * FROM SHIP.SH_SHIP
WHERE 1=0;

GRANT INSERT ON my_ship TO PUBLIC;

-- 11
CREATE TABLE my_trip AS
SELECT * FROM SHIP.SH_TRIP;

UPDATE MY_TRIP
SET ship = '*' || ship || '*'
WHERE ship IN (
    SELECT ship 
    FROM (
        SELECT ship, COUNT(*) AS trip_count 
        FROM SHIP.SH_TRIP 
        GROUP BY ship
    )
    WHERE trip_count = (
        SELECT MAX(trip_count)
        FROM (
            SELECT MAX(COUNT(*))
            FROM SHIP.SH_TRIP
            GROUP BY ship)));

-- 12
CREATE VIEW customer AS
SELECT last_name, first_name, c_name, country, COUNT(o_id) AS total_order
FROM SHIP.SH_CLIENT cl
LEFT JOIN SHIP.SH_CITY ci ON cl.city = ci.c_id
LEFT JOIN SHIP.SH_ORDER o ON cl.c_id = o.client_id
GROUP BY last_name, first_name, c_name, country;

--------------------------------------------------------------------------------------

-- C Paper --
-- 1
SELECT last_name, first_name FROM SHIP.SH_CLIENT
WHERE last_name LIKE 'b%' OR last_name LIKE 'B%'
ORDER BY last_name, first_name;

-- 2
SELECT 
    TO_CHAR(t.departure_time, 'HH24:MI:SS') AS departure_time,
    TO_CHAR(t.arrival_time, 'yyyy-mm-dd hh24:mi:ss') AS arrival_datetime,
    t.departure_port,
    t.arrival_port
FROM SHIP.SH_TRIP t
WHERE TRUNC(t.departure_time) = TO_DATE('2021-06-06', 'YYYY-MM-DD')
ORDER BY TO_CHAR(t.departure_time, 'HH24:MI:SS');

-- 3
SELECT TO_CHAR(date_of_order, 'yyyy month') AS o_date, COUNT(o_id) FROM SHIP.SH_ORDER
GROUP BY TO_CHAR(date_of_order, 'yyyy month')
HAVING COUNT(o_id) >= 8
ORDER BY o_date;

-- 4
SELECT t_name, t_description FROM SHIP.SH_SHIP_TYPE
WHERE T_ID IN (
    SELECT sh_type FROM SHIP.SH_SHIP
    WHERE sh_name = 'SC Rosy'
);

-- 5
SELECT c_name, country FROM SHIP.SH_CLIENT cl
JOIN SHIP.SH_CITY ci ON cl.city = ci.c_id
GROUP BY c_name, country
HAVING COUNT(cl.c_id) > 1
ORDER BY c_name;

-- 6
SELECT t_id, t_name AS type_name, sh_id, sh_name AS ship_name FROM SHIP.SH_SHIP s
RIGHT JOIN SHIP.SH_SHIP_TYPE st ON s.sh_type = st.t_id
ORDER BY type_name, ship_name;

-- 7
SELECT o_id, arrival_port, no_of_containers, first_name || ' ' || last_name AS full_name 
FROM SHIP.SH_ORDER o
JOIN SHIP.SH_CLIENT cl ON o.client_id = cl.c_id
WHERE departure_port = 'It_Cat'
AND shipping_fee = (
    SELECT MAX(shipping_fee) FROM SHIP.SH_ORDER
    WHERE departure_port = 'It_Cat'
);

-- 8
SELECT first_name, last_name, COUNT(o_id) FROM SHIP.SH_ORDER o
JOIN SHIP.SH_CLIENT cl ON o.client_id = cl.c_id
GROUP BY first_name, last_name
ORDER BY count(o_id) DESC
FETCH FIRST 4 ROWS ONLY;


-- 9
CREATE TABLE my_staff (
    id NUMBER(5),
    last_name VARCHAR2(40) NOT NULL,
    first_name VARCHAR2(40) NOT NULL,
    date_of_birth DATE,
    email VARCHAR2(200),
    ship_id VARCHAR2(10),
    CONSTRAINT pk_my_staff PRIMARY KEY (id),
    CONSTRAINT uq_my_staff_name_dob UNIQUE (last_name, first_name, date_of_birth),
    CONSTRAINT fk_my_staff_ship FOREIGN KEY (ship_id) REFERENCES my_ship(sh_id)
);

CREATE TABLE my_ship (
    sh_id VARCHAR2(10) PRIMARY KEY
);

DROP TABLE my_ship;

-- 10
ALTER TABLE my_trip DROP CONSTRAINT sh_tr_uq;

SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'MY_TRIP';

-- 11
DELETE FROM SHIP.SH_TRIP
WHERE departure_time >= TO_DATE('2021-06-01', 'yyyy-mm-dd')
AND departure_time < TO_DATE('2021-07-01', 'yyyy-mm-dd')
AND EXISTS (
    SELECT 1 FROM (
        SELECT trip_id FROM SHIP.SH_CARRY
        GROUP BY trip_id
        HAVING COUNT(CONTAINER_ID) < 20) sub
    WHERE sub.trip_id = t.t_id
);

-- 12
CREATE VIEW countries AS
SELECT co.country, COUNT(p.p_id) AS port_count
FROM SHIP.SH_CITY ci
LEFT JOIN SHIP.SH_PORT p ON ci.c_id = p.city
RIGHT JOIN SHIP.SH_COUNTRY co ON co.country = ci.country
GROUP BY co.country;

--------------------------------------------------------------------------------------
