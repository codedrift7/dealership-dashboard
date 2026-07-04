-- ==========================================
-- AUTHENTICATION & USER MANAGEMENT QUERIES
-- ==========================================

-- 1. Register a new Customer Account
INSERT INTO UserAccount (
    Account_ID, Username, Email, PasswordHash, Role, Customer_ID
) VALUES (
    'AUTH_101', 'johndoe', 'johndoe@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', 'C001'
);

-- 2. Register a new Employee Account
INSERT INTO UserAccount (
    Account_ID, Username, Email, PasswordHash, Role, Employee_ID
) VALUES (
    'AUTH_102', 'ashley_sales', 'ashley@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Sales', 'E003'
);

-- 3. Login: Retrieve user by Username to verify password in backend
SELECT 
    Account_ID, 
    PasswordHash, 
    Role, 
    Employee_ID, 
    Customer_ID 
FROM UserAccount 
WHERE Username = 'ashley_sales' AND IsActive = TRUE;

-- 4. Update Last Login Time (Run this after a successful password match)
UPDATE UserAccount 
SET LastLogin = CURRENT_TIMESTAMP 
WHERE Account_ID = 'AUTH_102';

-- 5. Create a Session (If using session-based auth instead of stateless JWTs)
INSERT INTO UserSession (
    Session_ID, Account_ID, IPAddress, UserAgent, ExpiresAt
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000', 
    'AUTH_102', 
    '192.168.1.50', 
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64)...', 
    DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 7 DAY) 
);


/* =========================================================
   KPI 1. TOTAL CUSTOMERS
   ========================================================= */

SELECT
    COUNT(*) AS TotalCustomers
FROM Buyer;


/* =========================================================
   KPI 2. TOTAL EMPLOYEES
   ========================================================= */

SELECT
    COUNT(*) AS TotalEmployees
FROM Employee;


/* =========================================================
   KPI 3. TOTAL CARS SOLD
   ========================================================= */

SELECT
    COUNT(*) AS CarsSold
FROM CarOrder
WHERE OrderStatus = 'Delivered';


/* =========================================================
   KPI 4. TOTAL REVENUE
   ========================================================= */

SELECT
    COALESCE(SUM(c.SalePrice), 0) AS TotalRevenue
FROM CarOrder co
JOIN Car c
    ON co.SerialNumber = c.SerialNumber
WHERE co.OrderStatus = 'Delivered';


/* =========================================================
   1. CUSTOMER PURCHASE REPORT
   Shows customers and vehicles purchased
   ========================================================= */

SELECT
    b.Customer_ID,
    CONCAT(b.FirstName,' ',COALESCE(b.LastName,'')) AS CustomerName,
    c.Brand,
    c.CarName,
    c.Model,
    co.OrderDate,
    co.OrderStatus,
    co.DownPayment
FROM CarOrder co
JOIN Buyer b
    ON co.Customer_ID = b.Customer_ID
JOIN Car c
    ON co.SerialNumber = c.SerialNumber
ORDER BY co.OrderDate;


/* =========================================================
   2. REVENUE BY BRAND
   Highest revenue generating brands
   ========================================================= */

SELECT
    c.Brand,
    COUNT(*) AS CarsSold,
    SUM(c.SalePrice) AS Revenue
FROM CarOrder co
JOIN Car c
    ON co.SerialNumber = c.SerialNumber
WHERE co.OrderStatus = 'Delivered'
GROUP BY c.Brand
ORDER BY Revenue DESC;


/* =========================================================
   3. EMPLOYEE SALES PERFORMANCE
   Sales activity by employee
   ========================================================= */

SELECT
    e.Employee_ID,
    CONCAT(e.FirstName,' ',COALESCE(e.LastName,'')) AS EmployeeName,
    COUNT(co.Order_ID) AS CarsSold,
    COALESCE(SUM(co.DownPayment),0) AS TotalDownPayment
FROM Employee e
LEFT JOIN CarOrder co
    ON e.Employee_ID = co.Employee_ID
    AND co.OrderStatus = 'Delivered'
GROUP BY e.Employee_ID
ORDER BY CarsSold DESC;


/* =========================================================
   4. TOP 5 SALES LEADERBOARD
   Unlike #3 (which lists every employee, including those with
   zero sales, for a full performance review), this is a genuine
   "top N" leaderboard: only employees with at least one delivered
   sale, capped to the top 5.
   ========================================================= */

SELECT
    CONCAT(e.FirstName,' ',COALESCE(e.LastName,'')) AS EmployeeName,
    COUNT(*) AS CarsSold
FROM CarOrder co
JOIN Employee e
    ON co.Employee_ID = e.Employee_ID
WHERE co.OrderStatus = 'Delivered'
GROUP BY e.Employee_ID
ORDER BY CarsSold DESC, EmployeeName ASC   -- tie-breaker: without this, ties at the 5th spot return arbitrarily
LIMIT 5;


/* =========================================================
   5. UNSOLD VEHICLE INVENTORY
   Vehicles never sold
   ========================================================= */

SELECT
    c.SerialNumber,
    c.Brand,
    c.CarName,
    c.Model,
    c.ManufacturingYear,
    c.StockQuantity
FROM Car c
LEFT JOIN CarOrder co
    ON c.SerialNumber = co.SerialNumber
WHERE co.SerialNumber IS NULL;


/* =========================================================
   6. CURRENT VEHICLE INVENTORY
   Current stock levels
   ========================================================= */

SELECT
    Brand,
    CarName,
    Model,
    ManufacturingYear,
    SalePrice,
    StockQuantity
FROM Car
ORDER BY StockQuantity DESC, SalePrice DESC;


/* =========================================================
   7. VEHICLE MODIFICATION ANALYSIS
   Customization cost by vehicle
   ========================================================= */

SELECT
    c.SerialNumber,
    c.Brand,
    c.CarName,
    COUNT(m.ModificationDesc) AS TotalModifications,
    SUM(m.ModificationPrice) AS TotalModificationCost
FROM Car c
JOIN Modification m
    ON c.SerialNumber = m.SerialNumber
GROUP BY c.SerialNumber
ORDER BY TotalModificationCost DESC;


/* =========================================================
   8. WORKSHOP SPARE PART INVENTORY
   Spare part stock by workshop
   ========================================================= */

SELECT
    w.Service,
    sp.BrandSP,
    sp.DescSP,
    sp.StockQuantity,
    sp.Price
FROM Sparepart sp
JOIN Workshop w
    ON sp.Workshop_ID = w.Workshop_ID
ORDER BY sp.StockQuantity DESC;


/* =========================================================
   9. LOW STOCK ALERT (vehicles)
   Relies on Car.StockQuantity actually being decremented on delivery
   (see the triggers added at the bottom of database.sql). Threshold of
   1 is an example cutoff; adjust per business rule.
   ========================================================= */

SELECT
    SerialNumber,
    Brand,
    CarName,
    Model,
    StockQuantity
FROM Car
WHERE StockQuantity <= 1
ORDER BY StockQuantity ASC;