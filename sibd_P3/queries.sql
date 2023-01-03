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
--3.a
--Sailors who have skipped everywhere in Portugal
SELECT email, firstname,surname FROM sailor
EXCEPT ALL(
SELECT email, firstname, surname FROM sailor WHERE email IN
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
) as sailors_not_evry))
;

---------------------------------------------------------------------
--3.b
--Sailors who have travelled everywhere in Portugal
SELECT email, firstname,surname FROM sailor
EXCEPT ALL(
SELECT email, firstname, surname FROM sailor WHERE email IN
(SELECT email FROM
(SELECT DISTINCT s.email,l.name
FROM sailor s CROSS JOIN location l
WHERE l.country_name='Portugal'
EXCEPT ALL
    ((SELECT DISTINCT a.sailor,it1.loc_name_origin as loc_name
    FROM (trip t JOIN trip_info i ON t.takeoff=i.trip_start_date AND t.cni=i.cni_boat
                                         AND t.boat_country=i.country_name_boat) as it1
        JOIN authorised a ON it1.reservation_start_date=a.start_date AND it1.cni=a.cni
                                 AND it1.reservation_end_date=a.end_date AND it1.boat_country=a.boat_country
    WHERE country_name_origin='Portugal')
    UNION
    (SELECT DISTINCT a.sailor,it2.loc_name_dest as loc_name
    FROM (trip t JOIN trip_info i ON t.takeoff=i.trip_start_date AND t.cni=i.cni_boat
                                         AND t.boat_country=i.country_name_boat) as it2
        JOIN authorised a ON it2.reservation_start_date=a.start_date AND it2.cni=a.cni
                                 AND it2.reservation_end_date=a.end_date AND it2.boat_country=a.boat_country
    WHERE country_name_dest='Portugal'))
) as sailors_not_evry))
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
--5.a) Listing the sailors with the maximum sum of trip durations grouped by reservation
--------------------------------------------------------------------

SELECT aux.sailor as sailor_email,aux.firstname as sailor_firstname,aux.surname as sailor_surname,aux.duration_in_days
FROM (SELECT a.sailor,SUM(arrival-takeoff) as duration_in_days,s.surname as surname,s.firstname as firstname,R.start_date,R.end_date,R.country,R.cni
        FROM trip T JOIN reservation R ON T.reservation_start_date=R.start_date AND T.reservation_end_date=R.end_date AND T.boat_country=R.country AND T.cni=R.cni
           JOIN authorised a ON t.reservation_start_date=a.start_date AND t.cni=a.cni AND t.reservation_end_date=a.end_date AND t.boat_country=a.boat_country
            JOIN sailor s ON a.sailor=s.email
        GROUP BY R.start_date,R.end_date,R.country,R.country,R.cni,a.sailor,s.firstname,s.surname) AS aux
WHERE aux.duration_in_days>=ALL(SELECT SUM(arrival-takeoff)
        FROM trip T JOIN reservation R ON T.reservation_start_date=R.start_date AND T.reservation_end_date=R.end_date AND T.boat_country=R.country AND T.cni=R.cni
           JOIN authorised a ON t.reservation_start_date=a.start_date AND t.cni=a.cni AND t.reservation_end_date=a.end_date AND t.boat_country=a.boat_country
        GROUP BY R.start_date,R.end_date,R.country,R.country,R.cni,a.sailor);

--5.b) Listing for each reservation, the skipper who skipped for the longest time (i.e. the skipper with the largest sum of trip durations for each reservation)
SELECT aux.skipper as skipper_email,aux.firstname as skipper_firstname,aux.surname as skipper_surname,aux.duration_in_days
FROM (SELECT T.skipper,S.firstname,S.surname,SUM(arrival-takeoff) as duration_in_days,R.start_date,R.end_date,R.country,R.cni
        FROM trip T JOIN reservation R ON T.reservation_start_date=R.start_date AND T.reservation_end_date=R.end_date AND T.boat_country=R.country AND T.cni=R.cni
            JOIN sailor S on T.skipper=S.email
        GROUP BY R.start_date,R.end_date,R.country,R.country,R.cni,T.skipper, S.firstname,S.surname) AS aux
WHERE aux.duration_in_days>=ALL(SELECT SUM(arrival-takeoff)
                                FROM trip T JOIN reservation R ON T.reservation_start_date=R.start_date AND T.reservation_end_date=R.end_date AND T.boat_country=R.country AND T.cni=R.cni
                                GROUP BY R.start_date,R.end_date,R.country,R.country,R.cni,T.skipper
                                HAVING R.start_date=aux.start_date AND R.end_date=aux.end_date AND aux.country=R.country AND aux.cni=R.cni)

