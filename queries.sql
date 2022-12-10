-- QUERY A ------------------------------------------------------
-- The name of all boats that are used in some trip -------------
-----------------------------------------------------------------

SELECT DISTINCT b.boat_name, b.cni
FROM (SELECT cni, boat_name, country_registration FROM boat) as b
WHERE (b.cni, b.country_registration) IN (SELECT t.cni, t.boat_country_reg FROM trip t);

-- QUERY B ------------------------------------------------------
-- The name of all boats that are not used in any trip ----------
-----------------------------------------------------------------

SELECT DISTINCT b.boat_name, b.cni
FROM (SELECT cni, boat_name, country_registration FROM boat) as b
WHERE (b.cni, b.country_registration) NOT IN (SELECT t.cni, t.boat_country_reg FROM trip t);

-- QUERY C ------------------------------------------------------
-- The name of all boats registered in 'PRT' (ISO code) for -----
-- which at least one responsible for a reservation has a -------
-- surname that ends with 'Santos -------------------------------
-----------------------------------------------------------------

SELECT DISTINCT b.boat_name
FROM (SELECT cni, responsible FROM reservation) AS r
  JOIN (SELECT country_registration, cni, boat_name FROM boat) AS b
  ON r.cni = b.cni
  JOIN (SELECT senior_email, senior_surname FROM senior) AS s
  ON r.responsible = s.senior_email
  JOIN (SELECT country_name, iso_code FROM country) AS c
  ON b.country_registration = c.country_name
WHERE s.senior_surname LIKE '%Santos'
AND c.iso_code = 'PR';


-- QUERY D ------------------------------------------------------
-- The full name of all skippers without any certificate --------
-- corresponding to the class of the trip’s boat ----------------
-----------------------------------------------------------------

SELECT CONCAT(s.sailor_first_name, ' ', s.sailor_surname) AS full_name
FROM (SELECT sailor_email, sailor_first_name, sailor_surname FROM sailor) AS s
  JOIN (SELECT cni, skipper FROM trip) AS t 
  ON s.sailor_email = t.skipper 
  JOIN (SELECT cni, class_name FROM boat) AS b
  ON b.cni = t.cni
WHERE (t.skipper, b.class_name) NOT IN (SELECT sailor_email, for_class_name FROM sailing_certificate);

