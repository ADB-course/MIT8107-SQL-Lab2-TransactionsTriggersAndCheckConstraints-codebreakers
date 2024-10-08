-- switch to the current database
USE 75855_lab2_triggers;

-- STEP 1: Transaction

-- turn of autocommit option
SET autocommit = OFF;

-- set isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

-- create the new column in orders table to record the orderTotal amount
ALTER TABLE orders
ADD orderTotal decimal(10,2);

-- create the new column in payments table to record the ordorderNumber
ALTER TABLE payments
ADD orderNumber int NOT NULL;
-- Add a check constraint to check the credit limit column in the customers table
ALTER TABLE customers
ADD CONSTRAINT check_credit_limit CHECK (creditLimit >= 0);

-- Create Triggers

-- Trigger 1: check if the customerNumber is valid
DELIMITER //
CREATE TRIGGER order_customer_check
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

-- Trigger 2: Check if a payment is made when an order is inserted
DROP TRIGGER IF EXISTS order_payment_check;

-- Recreate the trigger with new logic
DELIMITER //
CREATE TRIGGER order_payment_check
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE order_amount DECIMAL(10, 2);
    
    -- Get the total amount of the corresponding order
    SELECT orderTotal INTO order_amount
    FROM orders
    WHERE orderNumber = NEW.orderNumber;

    -- Check if the payment amount is less than the order amount
    IF NEW.amount < order_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount is less than the order amount';
    END IF;
END;
//
DELIMITER ;

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
INSERT INTO payments (customerNumber, checkNumber, paymentDate, amount, orderNumber)
VALUES (103, 'CHK123456', DATE(NOW()), 1200, @orderNumber);

-- Commit the transaction
COMMIT;

SET autocommit = ON;


