
CREATE TABLE `f_cannabis` (
  `plantid` int NOT NULL UNIQUE,   
  `position` longtext DEFAULT NULL, 
  `stage` int(11) DEFAULT 0,
  `time` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
