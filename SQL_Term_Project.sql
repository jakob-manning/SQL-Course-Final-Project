USE Project
GO

/** B1 **/
SELECT 
	o.orderID, o.Quantity, o.ProductID, p.ReorderLevel, p.SupplierID
FROM 
	dbo.OrderDetails AS o INNER JOIN dbo.Products AS p
	ON o.ProductID = p.ProductID
WHERE o.Quantity >=65 AND o.Quantity <= 70
ORDER BY o.OrderID
GO

/** B2 **/
SELECT
	p.ProductID, p.ProductName, p.EnglishName, p.UnitPrice
FROM
	Products AS p
WHERE
	p.UnitPrice < 8.00
ORDER BY
	p.ProductID

/** B3 **/
SELECT
	c.CustomerID, c.CompanyName, c.Country, c.Phone
FROM
	Customers AS c
WHERE
	c.Country = 'Canada' OR c.Country = 'USA'
ORDER BY
	CustomerID;
GO

/** B4 **/
SELECT
	s.SupplierID, s.Name, p.ProductName, p.ReorderLevel, p.UnitsInStock
FROM
	Products AS p INNER JOIN Suppliers AS s
	ON p.SupplierID = s.SupplierID
	
WHERE
	p.ReorderLevel = p.UnitsInStock
ORDER BY
	s.SupplierID
GO

/** B5 **/
SELECT
	o.OrderID, c.CompanyName, c.ContactName, LEFT(CONVERT(varchar, o.ShippedDate, 100), 11) AS ShippedDate, 2009 - YEAR(o.ShippedDate) AS ElaspedYears
FROM
	Orders as o INNER JOIN Customers AS c
	ON o.CustomerID = c.CustomerID
WHERE 
	o.ShippedDate >= '01-JAN-1994'
ORDER BY 
	o.OrderID, ElaspedYears
GO

/** B6 **/ 
SELECT
	o.OrderID, p.ProductName, c.CompanyName, LEFT(CONVERT(varchar, o.OrderDate,100), 11) AS OrderDate, LEFT(CONVERT(varchar, o.ShippedDate + 10, 100), 11) AS NewShippedDate, p.UnitPrice * od.Quantity AS OrderCost
FROM 
	Orders AS o INNER JOIN OrderDetails AS od
	ON o.OrderID = od.OrderID
	INNER JOIN Products AS p
	ON p.ProductID = od.ProductID
	INNER JOIN Customers AS c
	ON o.CustomerID = c.CustomerID
WHERE 
		o.OrderDate > '01-JAN-1992' 
	AND o.OrderDate < '30-MAR-1992' 
	AND p.UnitPrice * od.Quantity >= 1500
ORDER BY 
	od.OrderID

/** B7 **/
SELECT
	od.OrderID, od.UnitPrice, od.Quantity
FROM
	Orders AS o INNER JOIN OrderDetails AS od
	ON o.OrderID = od.OrderID
WHERE 
	o.ShipCity = 'Vancouver'
ORDER BY
	od.OrderID
GO

/** B8 **/
SELECT
	c.CustomerID, c.CompanyName, c.Fax, o.OrderID, o.OrderDate
FROM
	Orders AS o INNER JOIN Customers AS c
	ON o.CustomerID = c.CustomerID
WHERE
	o.ShippedDate IS null
ORDER BY c.CustomerID, o.OrderDate
GO

/** B9 **/
SELECT
	p.ProductID, p.ProductName, p.QuantityPerUnit, p.UnitPrice
FROM
	Products AS p
WHERE 
		p.ProductName LIKE '%choc%' 
	OR	p.ProductName LIKE '%tofu%'
ORDER BY
	p.ProductID
GO

/** B10 **/
SELECT
	Left(p.ProductName,1) AS ProductName, count(*) AS Total
FROM
	Products AS p
GROUP BY 
	Left(p.ProductName,1)
HAVING
	count(*) >= 3
ORDER BY Left(p.ProductName,1)

USE A01045429_Project
GO


/** C1 - Create View 'vw_supplier_items'  **/

IF OBJECT_ID('dbo.vw_supplier_items') IS NOT NULL DROP VIEW dbo.vw_supplier_items;
GO

CREATE VIEW dbo.vw_supplier_items
AS
SELECT 
	s.SupplierID,
	s.Name,
	p.ProductID,
	p.ProductName
FROM
	Suppliers as s
	INNER JOIN Products as p
	ON s.SupplierID = p.SupplierID
GO

/** C1 - Test View  **/
SELECT
	*
FROM
	vw_supplier_items
ORDER BY
	Name, ProductID
GO

/** C2 - Create View 'vw_employee_info'  **/
IF OBJECT_ID('vw_employee_info') IS NOT NULL DROP VIEW DBO.vw_employee_info;
GO

CREATE VIEW DBO.vw_employee_info
AS
SELECT 
	e.EmployeeID,
	CONCAT(e.FirstName, ' ', e.LastName) AS Name,
	e.BirthDate
FROM
	Employees as e
GO

/** C2 - Test View  **/
SELECT	*
FROM vw_employee_info
WHERE
	EmployeeID IN (3, 6, 9)

/** C3 - Update fax value  **/
UPDATE Customers
SET    Fax  = 'Unknown'
WHERE  Fax is NULL;
GO

/** C4 **/
DROP VIEW IF EXISTS vw_order_cost
GO

CREATE VIEW vw_order_cost
AS
SELECT
	o.OrderID,
	o.OrderDate,
	p.ProductID,
	c.CompanyName,
	d.Quantity*d.UnitPrice as "order cost"
FROM
	Orders as o
	INNER JOIN OrderDetails as d
	on o.OrderID = d.OrderID
	INNER JOIN Products as p
	on d.ProductID = p.ProductID
	INNER JOIN Customers as c
	on o.CustomerID = c.CustomerID
GO

SELECT  *
FROM vw_order_cost
WHERE OrderID BETWEEN 10100 AND 10200
ORDER BY ProductID
GO

/** C5 **/
IF NOT EXISTS (SELECT * FROM Suppliers WHERE SupplierID = 16)
	BEGIN
		INSERT INTO Suppliers (SupplierID, Name) VALUES (16, 'SUPPLIER P')
	END
GO

/** C6 
In a work setting I would ask my supervisor how they wanted us to handle the rounding for UnitPrice (is it acceptable to have a value on the database that is three decimals long?) **/
UPDATE Products
SET UnitPrice = UnitPrice * 1.15
WHERE UnitPrice < 5
GO

/** C7 
The below query returns more rows than the preview in the quesiton. The question text also lists columns in a different order than the example. Perhaps this explain the discrepancy?
**/
DROP VIEW IF EXISTS vw_orders
GO

CREATE VIEW vw_orders
AS
SELECT
	o.OrderID,
	o.ShippedDate,
	c.CustomerID, 
	c.CompanyName, 
	c.City,
	c.Country
FROM
	Orders AS o
	INNER JOIN Customers AS c
	ON c.CustomerID = c.CustomerID
GO

SELECT *
FROM vw_orders
WHERE ShippedDate BETWEEN '1993-01-01' AND '1993-01-31'
ORDER BY CompanyName, Country
GO

/** D1 **/
IF OBJECT_ID('sp_emp_info') IS NOT NULL DROP PROCEDURE sp_emp_info;
GO

CREATE PROCEDURE sp_emp_info (@employeeID nvarchar(50))
	AS
		SELECT
			e.EmployeeID,
			e.LastName,
			e.FirstName,
			e.Phone
		FROM
			Employees AS e
		WHERE
			EmployeeID = @employeeID
GO

EXEC sp_emp_info 7
GO

/** D2 **/
IF OBJECT_ID('sp_orders_by_dates') IS NOT NULL DROP PROCEDURE sp_orders_by_dates;
GO

CREATE PROCEDURE sp_orders_by_dates (@startDate nvarchar(50), @endDate nvarchar(50))
AS
	SELECT
		o.OrderID,
		c.CustomerID,
		c.CompanyName,
		s.CompanyName,
		o.ShippedDate
	FROM
		Orders AS o
		INNER JOIN Customers AS c
		ON O.CustomerID = C.CustomerID
		INNER JOIN Shippers AS s
		ON o.ShipperID = s.ShipperID
	WHERE o.ShippedDate >= @startDate AND o.ShippedDate <= @endDate
GO

EXEC sp_orders_by_dates '1991-01-01', '1991-12-31'
GO

/** D3 **/
IF OBJECT_ID('sp_products') IS NOT NULL DROP PROCEDURE sp_products;
GO

CREATE PROCEDURE sp_products (@productName nvarchar(50), @month nvarchar(50), @year int)
AS
	SELECT
		p.ProductName,
		p.UnitPrice,
		p.UnitsInStock,
		s.Name
	FROM 
		Products AS p
		INNER JOIN Suppliers AS s
		ON p.SupplierID = s.SupplierID
		INNER JOIN OrderDetails as d
		ON p.ProductID = d.ProductID
		INNER JOIN Orders as o
		ON d.OrderID = o.OrderID

	WHERE
		p.ProductName LIKE @productName AND MONTH(o.OrderDate) = MONTH(@month +' 1 2000') AND YEAR(o.OrderDate) = @year
	GO

EXEC sp_products '%tofu%', 'December', 1992
GO

/** D4 **/
/** In a workplace setting, I would ask my team how we should handle inequality (greater than vs. greater than or equals) **/
IF OBJECT_ID('sp_unit_prices') IS NOT NULL DROP PROCEDURE sp_unit_prices;
GO

CREATE PROCEDURE sp_unit_prices (@minPrice MONEY, @maxPrice MONEY)
AS
	SELECT
		p.ProductID, p.ProductName, p.EnglishName, p.UnitPrice
	FROM
		Products as p
	WHERE
		p.UnitPrice >= @minPrice AND p.UnitPrice <= @maxPrice
GO

EXEC sp_unit_prices 5.50, 8.00
GO

/** D5 **/
IF OBJECT_ID('sp_customer_city') IS NOT NULL DROP PROCEDURE sp_customer_city;
GO

CREATE PROCEDURE sp_customer_city (@cityName nvarchar(50))
AS
	SELECT
		c.CustomerID,
		c.CompanyName,
		c.Address,
		c.City,
		c.Phone
	FROM
		Customers as c
	WHERE c.City = @cityName
GO

EXEC sp_customer_city 'Paris'
GO

/** D6 **/
IF OBJECT_ID('sp_reorder_qty') IS NOT NULL DROP PROCEDURE sp_reorder_qty;
GO

CREATE PROCEDURE sp_reorder_qty (@recorderMargin INT)
AS
	SELECT
		p.ProductID, p.ProductName, p.UnitsInStock, p.ReorderLevel,
		s.Name
	FROM
		Products as p
		INNER JOIN Suppliers as s
		ON p.SupplierID = s.SupplierID
	WHERE
		p.UnitsInStock - p.ReorderLevel < @recorderMargin
	ORDER BY
		p.ProductID
GO

EXEC sp_reorder_qty 9
GO

/** D7 **/
IF OBJECT_ID('sp_shipping_date') IS NOT NULL DROP PROCEDURE sp_shipping_date;
GO

CREATE PROCEDURE sp_shipping_date (@shippingDate DATE)
AS
	SELECT
		o.OrderID, c.CompanyName as CustomerName,
		s.CompanyName as ShipperName,
		o.OrderDate, o.ShippedDate
	FROM
		Orders as o
		INNER JOIN Customers as c
		ON o.CustomerID = c.CustomerID
		INNER JOIN Shippers as s
		ON o.ShipperID = s.ShipperID
	WHERE
		o.ShippedDate = @shippingDate AND o.OrderDate = DATEADD(d, -10, @shippingDate)
GO

EXEC sp_shipping_date '1993-11-29'
GO

/** D8 **/
IF OBJECT_ID('sp_del_inactive_cust') IS NOT NULL DROP PROCEDURE sp_del_inactive_cust;
GO

CREATE PROCEDURE sp_del_inactive_cust
AS
	DELETE c
	FROM
		Customers as c
		LEFT JOIN Orders as o
		ON  c.CustomerID = o.CustomerID
	WHERE
		o.OrderID is null
GO

EXEC sp_del_inactive_cust


/** D9 **/
DROP TRIGGER IF EXISTS tr_check_qty
GO

CREATE TRIGGER tr_check_qty
ON OrderDetails
FOR UPDATE
AS
DECLARE @orderQuantity INT
DECLARE @productID INT
DECLARE @orderID INT
BEGIN
	SELECT 
		@orderQuantity = Quantity,
		@productID = ProductID,
		@orderID = OrderID
	FROM
		inserted
	IF @orderQuantity > (
		SELECT 	P.UnitsInStock
		FROM
			OrderDetails as d
			INNER JOIN Products as p
			ON d.ProductID = p.ProductID
		WHERE p.ProductID = @productID AND d.OrderID = @orderID
	) ROLLBACK TRANSACTION
END
GO

/**
UPDATE OrderDetails
SET Quantity = 40
WHERE OrderID = 10044 AND ProductID = 77
GO
**/

/** D10 **/
DROP TRIGGER IF EXISTS tr_insert_shippers
GO

CREATE TRIGGER tr_insert_shippers
ON Shippers
INSTEAD OF INSERT
AS
DECLARE @newName NVARCHAR
BEGIN
	INSERT INTO Shippers (ShipperID, CompanyName)
	SELECT
		i.ShipperID,
		i.CompanyName
	FROM
		inserted i
	WHERE
		i.CompanyName NOT IN (
			SELECT CompanyName
			FROM Shippers
		)
END
GO

INSERT Shippers
Values (4, 'Federal Shipping')
GO