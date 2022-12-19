
--IC: A sailor must exist either in the junior table or the senior table
CREATE OR REPLACE FUNCTION check_mandatory_sailor_senior_or_junior_insert()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.email NOT IN (SELECT email FROM senior) AND NEW.email NOT IN (SELECT email FROM junior) THEN
        RAISE EXCEPTION 'The sailor % % must either be a senior or junior',new.firstname,new.surname;
    ELSEIF NEW.email IN (SELECT email FROM senior) AND NEW.email IN (SELECT email FROM junior) THEN
        RAISE EXCEPTION 'The sailor % % cannot be both a senior and a junior sailor.',new.firstname,new.surname;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_mandatory_sailor_senior_or_junior_insert
AFTER INSERT ON sailor DEFERRABLE
FOR EACH ROW EXECUTE PROCEDURE check_mandatory_sailor_senior_or_junior_insert();


CREATE OR REPLACE FUNCTION check_trip_insert()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NOT EXISTS(SELECT * FROM trip WHERE reservation_start_date=NEW.reservation_start_date
                                       AND  reservation_end_date=NEW.reservation_end_date AND boat_country=NEW.boat_country
                                       AND cni=NEW.cni AND NOT ( NEW.arrival<takeoff OR NEW.takeoff>arrival)) THEN
        RAISE EXCEPTION 'Trips in the same reservation must not overlap';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_trip_insert
AFTER INSERT OR UPDATE ON trip DEFERRABLE
FOR EACH ROW EXECUTE PROCEDURE check_trip_insert();