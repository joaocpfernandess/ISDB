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
--Todos os sailors que estão authorized? Ou só os skippers?
---------------------------------------------------------------------
--4.
---------------------------------------------------------------------
SELECT S.firstname, S.surname,S.email
FROM sailor S
WHERE S.email IN (SELECT T.skipper FROM trip T
                                    GROUP BY T.skipper
                                    HAVING COUNT(T.skipper)>=ALL (SELECT count(skipper) FROM trip GROUP BY skipper))
--------------------------------------------------------------------
--5.
--------------------------------------------------------------------