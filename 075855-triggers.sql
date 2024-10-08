-- List all the databases
SHOW DATABASES;
-- switch to the current database
USE 75855_lab2_triggers;
-- list of all tables
SHOW TABLES;

-- STEP 1
SHOW CREATE TABLE employees;
CREATE TABLE `employees` (
  `employeeNumber` int NOT NULL,
  `lastName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `firstName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `extension` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `officeCode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `reportsTo` int DEFAULT NULL,
  `jobTitle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`employeeNumber`),
  KEY `reportsTo` (`reportsTo`),
  KEY `officeCode` (`officeCode`),
  CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`reportsTo`) REFERENCES `employees` (`employeeNumber`),
  CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`officeCode`) REFERENCES `offices` (`officeCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `employees_undo` (
  `date_of_change` timestamp(2) NOT NULL DEFAULT CURRENT_TIMESTAMP(2),
  `employeeNumber` int NOT NULL,
  `lastName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `firstName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `extension` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `officeCode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `reportsTo` int DEFAULT NULL,
  `jobTitle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `change_type` varchar(50) NOT NULL,
  PRIMARY KEY (`date_of_change`),
  UNIQUE KEY `date_of_change_UNIQUE` (`date_of_change`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- STEP 2
CREATE
 
 TRIGGER TRG_BEFORE_UPDATE_ON_employees
 BEFORE UPDATE ON employees FOR EACH ROW
 
 INSERT INTO `employees_undo` SET
 `date_of_change` = CURRENT_TIMESTAMP(2),
 `employeeNumber` = OLD.`employeeNumber` ,
 `lastName` = OLD.`lastName` ,
 `firstName` = OLD.`firstName` ,
 `extension` = OLD.`extension` ,
 `email` = OLD.`email` ,
 `officeCode` = OLD.`officeCode` ,
 `reportsTo` = OLD.`reportsTo` ,
 `jobTitle` = OLD.`jobTitle` ,
 `change_type` = 'An update DML operation was executed';

 -- STEP 3
 SHOW TRIGGERS;
 
 -- STEP 4
 UPDATE `employees`
SET
`lastName` = 'Muiruri'
WHERE
`employeeNumber` = '1056';

UPDATE `employees`
SET
`email` = 'mmuiruri@classicmodelcars.com'
WHERE
`employeeNumber` = '1056';

SELECT * FROM employees_undo;

-- STEP 5
CREATE TABLE `customers_data_reminders` (
 `customerNumber` int NOT NULL COMMENT 'Identifies the customer whose data is partly missing',
 `customers_data_reminders_timestamp` timestamp(2) NOT NULL DEFAULT
CURRENT_TIMESTAMP(2) COMMENT 'Records the time when the missing data was detected',
 `customers_data_reminders_message` varchar(100) NOT NULL COMMENT 'Records a message that helps the customer service personnel to know what data is missing from the customer\'s record',
 `customers_data_reminders_status` tinyint NOT NULL DEFAULT '0' COMMENT
'Used to record the status of a reminder (0 if it has not yet been addressed and 1 if it has been addressed)',
 PRIMARY KEY
(`customerNumber`,`customers_data_reminders_timestamp`,`customers_data_reminders_message`,`customers_data_reminders_status`),
 CONSTRAINT `FK_1_customers_TO_M_customers_data_reminders` FOREIGN KEY
(`customerNumber`) REFERENCES `customers` (`customerNumber`)
 ON DELETE CASCADE
 ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Used to remind the customer service personnel about a client\'s missing data. This enables them to ask the client to
provide the data during the next interaction with the client.';

-- STEP 6
DELIMITER $$
CREATE TRIGGER TRG_AFTER_INSERT_ON_customers
AFTER INSERT ON customers FOR EACH ROW
BEGIN
 IF NEW.postalCode IS NULL THEN
 INSERT INTO `customers_data_reminders`
 (`customerNumber`, `customers_data_reminders_timestamp`,
`customers_data_reminders_message`)
 VALUES (NEW.customerNumber, CURRENT_TIMESTAMP(2), 'Please remember
to record the client\'s postal code');
 END IF;
 IF NEW.salesRepEmployeeNumber IS NULL THEN
 INSERT INTO `customers_data_reminders`
 (`customerNumber`, `customers_data_reminders_timestamp`,
`customers_data_reminders_message`)
 VALUES (NEW.customerNumber, CURRENT_TIMESTAMP(2), 'Please remember
to assign a sales representative to the client');
 END IF;
 IF NEW.creditLimit IS NULL THEN
 INSERT INTO `customers_data_reminders`
 (`customerNumber`, `customers_data_reminders_timestamp`,
`customers_data_reminders_message`)
 VALUES (NEW.customerNumber, CURRENT_TIMESTAMP(2), 'Please remember
to set the client\'s credit limit');
 END IF;
END$$
DELIMITER ;

-- STEP 7
INSERT INTO `customers`
(`customerNumber`, `customerName`, `contactLastName`, `contactFirstName`,
`phone`, `addressLine1`, `city`, `country`)
VALUES
('497', 'House of Leather', 'Wambua', 'Gabriel', '+254 720 123 456', '9
Agha Khan Walk', 'Nairobi', 'Kenya');

DELETE FROM `customers` WHERE `customerNumber` = '497';

select * from customers_data_reminders;

INSERT INTO `customers`
(`customerNumber`, `customerName`, `contactLastName`, `contactFirstName`,
`phone`, `addressLine1`, `city`, `country`, `salesRepEmployeeNumber`)
VALUES
('497', 'House of Leather', 'Wambua', 'Gabriel', '+254 720 123 456', '9
Agha Khan Walk', 'Nairobi', 'Kenya', 1401);

select * from customers_data_reminders;

UPDATE `customers` SET `postalCode` = '00100' WHERE `customerNumber` =
'497';

select * from customers_data_reminders;

-- STEP 8
CREATE TABLE part (
 part_no VARCHAR(18) PRIMARY KEY,
 part_description VARCHAR(255),
 part_supplier_tax_PIN VARCHAR (11) CHECK (part_supplier_tax_PIN REGEXP
'^[A-Z]{1}[0-9]{9}[A-Z]{1}$'),
 part_supplier_email VARCHAR (55),
 part_buyingprice DECIMAL(10,2 ) NOT NULL CHECK (part_buyingprice >= 0),
 part_sellingprice DECIMAL(10,2) NOT NULL,
 CONSTRAINT CHK_part_sellingprice_GT_buyingprice CHECK
(part_sellingprice >= part_buyingprice),
 CONSTRAINT CHK_part_valid_supplier_email CHECK (part_supplier_email
REGEXP '^[a-zA-Z0-9]{3,}@[a-zA-Z0-9]{1,}\\.[a-zA-Z0-9.]{1,}$')
);
 
 -- STEP 9
 DELIMITER //
CREATE TRIGGER TRG_BEFORE_UPDATE_ON_part
BEFORE UPDATE ON part FOR EACH ROW
BEGIN
 DECLARE errorMessage VARCHAR(255);
 DECLARE EXIT HANDLER FOR SQLSTATE '45000'
 BEGIN
 RESIGNAL SET MESSAGE_TEXT = errorMessage;
 END;

 SET errorMessage = CONCAT('The new selling price of ',
NEW.part_sellingprice, ' cannot be 2 times greater than the current selling
price of ', OLD.part_sellingprice);
 IF NEW.part_sellingprice > OLD.part_sellingprice * 2 THEN
 SIGNAL SQLSTATE '45000';
 END IF;
END//
DELIMITER ;

SHOW CREATE TABLE part;
-- STEP 10
INSERT INTO `part` (`part_no`, `part_description`, `part_supplier_tax_PIN`,
`part_supplier_email`, `part_buyingprice`, `part_sellingprice`)
VALUES ('001', 'The tyres of a 1958 Chevy Corvette Limited Edition',
'P051201576U', 'toysRus@gmail.com', '100', '100');

UPDATE `part` SET `part_sellingprice` = '250.00' WHERE (`part_no` = '001');

SHOW TRIGGERS;
 
