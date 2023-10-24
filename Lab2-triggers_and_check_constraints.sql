-- switch to the current database
USE 75855_lab2_triggers;
-- list of all tables
SHOW TABLES;

-- STEP 1: Add missing columns

-- create the new column in orders table to record the orderTotal amount
ALTER TABLE orders
ADD orderTotal decimal(10,2);

-- create the new column in payments table to record payment status
ALTER TABLE payments
ADD paymentStatus VARCHAR(50);

-- Trigger 1: check if the customerNumber is valid & if a payment is made before an order is inserted
DELIMITER //
CREATE TRIGGER order_payment_check
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN 
    -- Check if the customerNumber exists in the customers table
    SELECT COUNT(*) INTO @customer_exists
    FROM customers
    WHERE customerNumber = NEW.customerNumber;
    
    IF @customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid customerNumber';
    END IF;  
   
END;
//
DELIMITER ;

-- Trigger 2: Update payment status when an order is inserted
DELIMITER //
CREATE TRIGGER update_payment_status
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE payments
    SET paymentStatus = 'Paid'
    WHERE customerNumber = NEW.customerNumber;
END;
//
DELIMITER ;

-- Trigger 2: Update payment status when an order is inserted
DELIMITER //
CREATE TRIGGER payment_check
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
 DECLARE paid_amount DECIMAL(10, 2);
   -- Check if the payment is sufficient for the order
    SELECT SUM(amount) INTO paid_amount
    FROM payments
    WHERE customerNumber = NEW.customerNumber;
    
    IF paid_amount < NEW.orderTotal THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment insufficient for the order';
    END IF;
END;
//
DELIMITER ;




-- STEP 2: Create a transaction to implement the triggers

-- turn of autocommit option
SET autocommit = OFF;

-- set isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

-- Create a save point before an order is made
SAVEPOINT order_savepoint;

-- Insert a new order
SELECT @orderNumber := MAX(orderNumber)+1 FROM orders;
INSERT INTO orders (orderNumber,orderDate, requiredDate, shippedDate, status, comments, customerNumber, orderTotal)
VALUES (@orderNumber,DATE(NOW()), DATE(DATE_ADD(NOW(), INTERVAL 3 DAY)), NULL, 'Processing', 'New order', 103, 1500);

select * from orders order by orderNumber desc;
select * from payments order by customerNumber asc;

-- Create a save point before a payment is made
SAVEPOINT payment_savepoint;

-- Record a payment for the order
INSERT INTO payments (customerNumber, checkNumber, paymentDate, amount, paymentStatus)
VALUES (103, 'CHK123456', DATE(NOW()), 1200, 'Processing');

-- Commit the transaction
COMMIT;

SET autocommit = ON;


