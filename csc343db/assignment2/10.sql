SET search_path TO uber, public;

insert into client values
(99, 'Mason', 'Daisy', 'daisy@kitchen.com'),
(100, 'Crawley', 'Violet', 'dowager@dower-house.org'),
(88, 'Branson', 'Tom', 'branson@gmail.com');


insert into driver values
(12345, 'Snow', 'Jon', 'January 1, 1990', 'The Wall', 'BGSW 420', false),
(22222, 'Tyrion', 'Lannister', 'January 1, 1990', 'Kings Landing', 'ABCD 123', false);


insert into available values
(12345, '2016-01-08 04:05', '(1, 2)');


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
(1, 100, '2014-02-08 04:10', 'cn tower', 'north york civic centre'),
(2, 100, '2015-02-01 08:00', 'cn tower', 'pearson international airport'),
(3, 100, '2014-03-02 08:00', 'cn tower', 'north york civic centre'),
(4, 100, '2015-03-03 08:00', 'cn tower', 'pearson international airport'),
(5, 100, '2014-04-02 08:00', 'cn tower', 'pearson international airport');


insert into dispatch values
(1, 22222, '(1, 4)', '2014-02-08 04:11'),
(2, 22222, '(5, 5)', '2015-02-01 08:05'),
(3, 22222, '(5, 5)', '2014-03-02 08:05'),
(4, 22222, '(5, 5)', '2015-03-03 08:05'),
(5, 22222, '(5, 5)', '2014-04-02 08:05');


insert into pickup values
(1, '2014-02-08 04:14'),
(2, '2015-02-01 08:06'),
(3, '2014-03-02 08:06'),
(4, '2015-03-03 08:06'),
(5, '2014-04-03 08:06');


insert into dropoff values
(1, '2014-02-08 04:14'),
(2, '2015-02-01 08:16'),
(3, '2014-03-02 08:16'),
(4, '2015-03-03 08:16'),
(5, '2014-04-03 08:16');


insert into rates values
(3.2, .55);


insert into billed values
(1, 10),
(2, 12),
(3, 10),
(4, 12),
(5, 8);


insert into driverrating values
(1, 5);

insert into clientrating values
(1, 4);


