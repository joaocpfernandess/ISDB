DROP VIEW IF EXISTS trip_info;


CREATE VIEW trip_info(
    country_iso_origin, country_name_origin,
    country_iso_dest, country_name_dest,
    loc_name_origin,
    loc_name_dest,
    cni_boat,
    country_iso_boat, country_name_boat,
    trip_start_date)
AS
SELECT C2.iso_code as country_iso_origin, loc_info.country_name_origin,C3.iso_code as country_iso_dest,loc_info.country_name_dest,loc_info.loc_name_origin,loc_info.loc_name_dest,
       loc_info.cni as cni_boat, C1.iso_code as country_iso_boat,loc_info.boat_country as country_name_boat, loc_info.takeoff as trip_start_date
FROM
    (SELECT from_info.takeoff,from_info.reservation_start_date,from_info.reservation_end_date,from_info.boat_country,from_info.cni,from_info.loc_name_origin,from_info.country_name_origin,
       L.name as loc_name_dest,L.country_name as country_name_dest
    FROM
        (SELECT T.takeoff,T.reservation_start_date,T.reservation_end_date,T.boat_country,T.cni, L.name as loc_name_origin,L.country_name as country_name_origin,T.to_latitude,T.to_longitude
        FROM trip T LEFT JOIN location L ON T.from_latitude=L.latitude AND T.from_longitude=L.longitude) as from_info
            LEFT JOIN location L ON from_info.to_latitude=L.latitude AND from_info.to_longitude=L.longitude) as loc_info
        LEFT JOIN country C1 ON loc_info.boat_country=C1.name LEFT JOIN country C2 ON loc_info.country_name_origin=C2.name LEFT JOIN country C3 ON loc_info.country_name_dest=C3.name;
