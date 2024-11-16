-- This function is from https://wiki.postgresql.org/wiki/Pseudo_encrypt
CREATE FUNCTION pseudo_encrypt(value int) returns int AS $$
DECLARE
l1 int;
l2 int;
r1 int;
r2 int;
i int:=0;
BEGIN
l1:= (value >> 16) & 65535;
r1:= value & 65535;
WHILE i < 3 LOOP
    l2 := r1;
    r2 := l1 # ((((1366 * r1 + 150889) % 714025) / 714025.0) * 32767)::int;
    l1 := l2;
    r1 := r2;
    i := i + 1;
END LOOP;
return ((r1 << 16) + l1);
END;
$$ LANGUAGE plpgsql strict immutable;


CREATE FUNCTION to_base36(num int) RETURNS text AS $$
DECLARE
base36_chars text := '0123456789abcdefghijklmnopqrstuvwxyz';
result text := '';
remainder int;
BEGIN
IF num = 0 THEN
    RETURN '0';
END IF;

WHILE num > 0 LOOP
    remainder := num % 36;
    result := substring(base36_chars from remainder + 1 for 1) || result;
    num := num / 36;
END LOOP;

RETURN result;
END;
$$ LANGUAGE plpgsql STRICT IMMUTABLE;


CREATE FUNCTION random_chars(char_count int, salt int default 0) RETURNS text AS $$
DECLARE
base int:= 36;
shift int := base^(char_count-1);
modulus int := base^(char_count) - shift;
rand bigint := random() * 2^48;
BEGIN
RETURN to_base36(((rand + salt) % modulus + shift)::int);
END;
$$ LANGUAGE plpgsql STRICT IMMUTABLE;


CREATE FUNCTION generate_slug(sequence_no int, random_seed int default 0) RETURNS text AS $$
DECLARE
deterministic_part text := to_base36(pseudo_encrypt(sequence_no));
random_part text := random_chars(10 - length(deterministic_part), random_seed);
BEGIN
RETURN deterministic_part || random_part;
END;
$$ LANGUAGE plpgsql STRICT IMMUTABLE;
