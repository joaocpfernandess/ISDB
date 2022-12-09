---------Query A----------
SELECT boat_name FROM boat
WHERE (country_registration,cni) IN (SELECT boat_country_reg,cni FROM trip);

--------Query B-----------
SELECT boat_name FROM boat
WHERE (country_registration,cni) NOT IN (SELECT boat_country_reg,cni FROM trip);

---------Query C----------
SELECT boat_name FROM boat
WHERE (country_registration,cni) IN (SELECT boat_country_reg, cni
                                     FROM reservation
                                     WHERE responsible IN
                                           (SELECT sailor_email
                                            FROM sailor
                                            WHERE sailor_surname LIKE '%Santos'));