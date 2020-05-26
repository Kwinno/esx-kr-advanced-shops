CREATE TABLE IF NOT EXISTS `owned_fuel_shops` (
  `identifier` varchar(250) DEFAULT NULL,
  `ShopNumber` int(11) DEFAULT NULL,
  `money` int(11) DEFAULT '0',
  `ShopValue` int(11) DEFAULT NULL,
  `ShopName` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `owned_fuel_shops` (`identifier`, `ShopNumber`, `money`, `ShopValue`, `ShopName`) VALUES
  ('0', 1, 0, 280000, '0'),
  ('0', 2, 0, 220000, '0'),
  ('0', 3, 0, 235000, '0'),
  ('0', 4, 0, 285000, '0'),
  ('0', 5, 0, 135000, '0'),
  ('0', 6, 0, 235000, '0'),
  ('0', 7, 0, 160000, '0'),
  ('0', 8, 0, 275000, '0'),
  ('0', 9, 0, 265000, '0'),
  ('0', 10, 0, 300000, '0'),
  ('0', 11, 0, 225000, '0'),
  ('0', 12, 0, 145000, '0'),
  ('0', 13, 0, 145000, '0'),
  ('0', 14, 0, 280000, '0'),
  ('0', 15, 0, 300000, '0'),
  ('0', 16, 0, 435000, '0'),
  ('0', 17, 0, 150000, '0'),
  ('0', 18, 0, 235000, '0'),
  ('0', 19, 0, 150000, '0'),
  ('0', 20, 0, 165000, '0'),
  ('0', 21, 0, 280000, '0'),
  ('0', 22, 0, 220000, '0'),
  ('0', 23, 0, 235000, '0'),
  ('0', 24, 0, 285000, '0'),
  ('0', 25, 0, 135000, '0'),
  ('0', 26, 0, 235000, '0'),
  ('0', 27, 0, 160000, '0'),
  ('0', 28, 0, 275000, '0');
  
CREATE TABLE IF NOT EXISTS `fuel_shipments` (
  `id` int(11) DEFAULT NULL,
  `identifier` varchar(50) DEFAULT NULL,
  `label` varchar(50) DEFAULT NULL,
  `item` varchar(50) DEFAULT NULL,
  `price` varchar(50) DEFAULT NULL,
  `count` varchar(50) DEFAULT NULL,
  `time` int(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `fuel_shops` (
  `ShopNumber` int(11) NOT NULL DEFAULT '0',
  `src` varchar(50) NOT NULL,
  `count` int(11) NOT NULL,
  `item` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `price` int(11) NOT NULL,
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
