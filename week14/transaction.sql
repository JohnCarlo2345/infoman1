-- =========================================
-- WEEK 14 F2 — TRANSACTIONS.SQL
-- Inventory & Sales System
-- PREREQUISITE: Week 13 schema.sql + seed.sql
-- =========================================
USE inventory_sales_db;

-- ==================================================
-- SCENARIO 1: SUCCESSFUL TRANSACTION
-- Order created + stock deducted — both commit
-- ==================================================
-- BEFORE: Notebook (product_id=1) stock = 100
SELECT 'BEFORE — Successful Transaction' AS state;
SELECT product_id, product_name, stock_quantity
FROM products WHERE product_id = 1;

START TRANSACTION;
    -- Lock and check
    SELECT product_id, stock_quantity
    FROM products
    WHERE product_id = 1
    FOR UPDATE;

    -- Deduct stock only if available
    UPDATE products
    SET stock_quantity = stock_quantity - 1
    WHERE product_id = 1 AND stock_quantity >= 1;
    SELECT ROW_COUNT() AS rows_updated;

    -- Create order
    INSERT INTO orders (customer_id, total_amount) VALUES (1, 45.00);
    SET @order_id = LAST_INSERT_ID();

    -- Create order item
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (@order_id, 1, 1, 45.00);
COMMIT;

-- AFTER: Notebook stock = 99, new order exists
SELECT 'AFTER — Successful Transaction' AS state;
SELECT product_id, stock_quantity
FROM products WHERE product_id = 1;
SELECT order_id, customer_id, total_amount
FROM orders WHERE order_id = @order_id;

-- ==================================================
-- SCENARIO 2: FAILURE + FULL ROLLBACK
-- Error after first write → stock change undone
-- ==================================================
-- BEFORE: Ballpen (product_id=2) stock = 500
SELECT 'BEFORE — Failure + Rollback' AS state;
SELECT product_id, product_name, stock_quantity
FROM products WHERE product_id = 2;

START TRANSACTION;
    -- Deduct stock
    UPDATE products
    SET stock_quantity = stock_quantity - 2
    WHERE product_id = 2 AND stock_quantity >= 2;
    SELECT ROW_COUNT() AS rows_updated;

    -- Intentional ERROR: invalid customer_id triggers FK violation
    INSERT INTO orders (customer_id, total_amount) VALUES (99999, 25.00);
    -- SEE ERROR MESSAGE HERE, THEN RUN:
    ROLLBACK;

-- AFTER: Stock still = 500 — NO partial change
SELECT 'AFTER — Failure + Full Rollback' AS state;
SELECT product_id, stock_quantity
FROM products WHERE product_id = 2;

-- ==================================================
-- SCENARIO 3: SAVEPOINT DEMONSTRATION
-- Partial rollback vs full rollback
-- ==================================================
-- BEFORE: Bond Paper (product_id=3) stock = 50
SELECT 'BEFORE — Savepoint Test' AS state;
SELECT product_id, product_name, stock_quantity
FROM products WHERE product_id = 3;

START TRANSACTION;
    -- Change A
    UPDATE products SET stock_quantity = stock_quantity - 5 WHERE product_id = 3;
    SELECT 'After Change A — stock should be 45' AS step, stock_quantity
    FROM products WHERE product_id = 3;

    SAVEPOINT after_change_a;

    -- Change B
    UPDATE products SET stock_quantity = stock_quantity - 10 WHERE product_id = 3;
    SELECT 'After Change B — stock should be 35' AS step, stock_quantity
    FROM products WHERE product_id = 3;

    -- Undo ONLY Change B
    ROLLBACK TO SAVEPOINT after_change_a;
    SELECT 'After ROLLBACK TO SAVEPOINT — stock back to 45' AS step, stock_quantity
    FROM products WHERE product_id = 3;

    -- Undo EVERYTHING
    ROLLBACK;
    SELECT 'After FULL ROLLBACK — stock back to 50' AS step, stock_quantity
    FROM products WHERE product_id = 3;
