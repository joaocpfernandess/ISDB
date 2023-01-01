--------------------------------------------------------------------------------
---------------------------3.Queries--------------------------------------------
--------------------------------------------------------------------------------
--1.
-------------------------------------------------------------------
SELECT C.name as Country_name
FROM country C inner join boat B on C.name=B.country
GROUP BY C.name
HAVING COUNT(C.name)>=ALL (SELECT COUNT(c.name) FROM country c inner join boat b on c.name=b.country GROUP BY c.name);
--------------------------------------------------------------------
--2.
--------------------------------------------------------------------
SELECT S.firstname,S.surname,S.email
FROM sailor S INNER JOIN sailing_certificate SC on S.email=SC.sailor
GROUP BY S.email
HAVING COUNT(S.email)>=2;
---------------------------------------------------------------------
--3.
--Sailors who have skipped everywhere in Portugal
SELECT email FROM sailor
EXCEPT ALL
--sailors and portuguese locations where they've never been
(SELECT email FROM
(SELECT DISTINCT s.email,l.name
FROM sailor s CROSS JOIN location l
WHERE l.country_name='Portugal'
EXCEPT ALL
    --sailors who have been to some location in portugal (sailor,location)
    ((SELECT DISTINCT t.skipper,i.loc_name_origin as loc_name
    FROM trip t JOIN trip_info i ON t.takeoff=i.trip_start_date AND t.cni=i.cni_boat AND t.boat_country=i.country_name_boat
    WHERE country_name_origin='Portugal') --skippers who have travelled from a portuguese location
    UNION
    (SELECT DISTINCT t.skipper,i.loc_name_dest as loc_name
    FROM trip t JOIN trip_info i ON t.takeoff=i.trip_start_date AND t.cni=i.cni_boat AND t.boat_country=i.country_name_boat
    WHERE country_name_dest='Portugal')) --skippers who have travelled to a portuguese location
) as sailors_not_evry)
;
---------------------------------------------------------------------
--4.
---------------------------------------------------------------------
SELECT S.firstname, S.surname,S.email
FROM sailor S
WHERE S.email IN (SELECT T.skipper FROM trip T
                                    GROUP BY T.skipper
                                    HAVING COUNT(T.skipper)>=ALL (SELECT count(skipper) FROM trip GROUP BY skipper));
--------------------------------------------------------------------
--5.
--------------------------------------------------------------------

SELECT aux.skipper,aux.duration_in_days
FROM (SELECT T.skipper,SUM(arrival-takeoff) as duration_in_days,R.start_date,R.end_date,R.country,R.cni
        FROM trip T JOIN reservation R ON T.reservation_start_date=R.start_date AND T.reservation_end_date=R.end_date AND T.boat_country=R.country AND T.cni=R.cni
        GROUP BY R.start_date,R.end_date,R.country,R.country,R.cni,T.skipper) AS aux
WHERE aux.duration_in_days>=ALL(SELECT SUM(arrival-takeoff)
                                FROM trip T JOIN reservation R ON T.reservation_start_date=R.start_date AND T.reservation_end_date=R.end_date AND T.boat_country=R.country AND T.cni=R.cni
                                GROUP BY R.start_date,R.end_date,R.country,R.country,R.cni,T.skipper
                                HAVING R.start_date=aux.start_date AND R.end_date=aux.end_date AND aux.country=R.country AND aux.cni=R.cni)

