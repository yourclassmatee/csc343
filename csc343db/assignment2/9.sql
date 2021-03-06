SET search_path TO uber, public;

insert into client values
(99, 'Mason', 'Daisy', 'daisy@kitchen.com'),
(100, 'Crawley', 'Violet', 'dowager@dower-house.org'),
(88, 'Branson', 'Tom', 'branson@gmail.com');


insert into driver values
(12345, 'Fry', 'Phillip', 'January 1, 1990', 'Planet Earth', 'BGSW 412', false),
(22222, 'Turanga', 'Leela', 'January 1, 1990', 'Planet Earth', 'ABCD 123', false),
(33333, 'Zoidberg', 'John', 'January 1, 1990', 'Decapod 10', 'CDFE 123', true);


insert into available values
(12345, '2016-02-01 10:05', '(1, 2)'),
(22222, '2016-02-01 10:05', '(3, 4)');


-- Locations are specified as longitude and latitude (in that order), in degrees.
insert into place values
('highclere castle', '(1.361, 51.3267)'),
('dower house', '(-0.4632, 51.3552)'),
('eaton centre', '(79.3803,43.654)'),
('cn tower', '(79.3871,43.6426)'),
('north york civic centre', '(79.4146,43.7673)'),
('pearson international airport', '(79.6306,43.6767)'),
('utsc', '(79.1856,43.7836)');


insert into request values
(1, 99, '2013-02-01 08:00', 'eaton centre', 'cn tower'),
(2, 99, '2013-02-02 08:00', 'eaton centre', 'cn tower'),
(3, 99, '2013-02-03 08:00', 'eaton centre', 'cn tower'),
(4, 88, '2013-02-04 08:00', 'eaton centre', 'cn tower'),
(5, 88, '2013-02-05 08:00', 'eaton centre', 'cn tower'),
(6, 100, '2013-02-06 08:00', 'eaton centre', 'cn tower');


insert into dispatch values
-- Zoidberg
(1, 33333, '(1, 4)', '2016-02-01 08:01'),
(2, 33333, '(1, 4)', '2016-02-02 08:01');

insert into pickup values
-- Zoidberg
(1, '2016-02-01 08:03'),
(2, '2016-02-02 08:03');


insert into dropoff values
-- Zoidberg
(1, '2016-02-01 08:05'),
(2, '2016-02-02 08:05');


insert into rates values
(3.2, .55);


insert into billed values
(1, 10),
(2, 10);


insert into driverrating values
(1, 1),
(2, 2);


insert into clientrating values
(1, 1),
(2, 2);


