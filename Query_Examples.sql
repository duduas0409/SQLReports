/* 2 sample Microsoft db describes a fictional store and
   its employees, customers, suppliers, products and orders


Employees table:
It stores information about the people employed at Northwind.
Each employee has:

A unique ID (EmployeeID).
A first and last name (FirstName and LastName).
A professional title (Title) ect.

Customers table:
Each customer has a unique CustomerID, which is a five-letter abbreviation of the full company name stored in the CompanyName column.
There are also columns related to the contact person (ContactName and ContactTitle) and some related to the customer's address and fax number.

Products table stores information about products sold at the Northwind store.
Each product has a unique ProductID and a ProductName. Each product is supplied by a single supplier (SupplierID) and belongs to a single category (CategoryID).
Each product also has a certain UnitPrice. The Discontinued column contains either a 0 (available in store) or a 1 (discontinued) that reflects the
current availability of that product.

Products are organized into categories. The information about categories is stored in the Categories table. Each category has a unique ID and a
CategoryName. There is also a short Description.


Orders table contains general information about an order: the OrderID, CustomerID, and EmployeeID related to that sale. There are also timestamp
columns (OrderDate and ShippedDate) and many columns related to the shipment process.

The OrderItems table contains information about order items. Each row represents a single item from an order.
*/


/*  QUERYES 

For each product, display name (ProductName), the name of the category it belongs to (CategoryName), quantity per unit (QuantityPerUnit), the unit
price (UnitPrice), and the number of units in stock (UnitsInStock). Order the results by unit price.
*/

SELECT p.productname,
  c.categoryname,
  p.quantityperunit,
  p.unitprice,
  p.unitsinstock
FROM products as p
INNER JOIN categories as c
  ON p.categoryid = c.categoryid
ORDER BY unitprice;


/*
Show the information about all the suppliers who provide the store with four or more different products. Show the SupplierID, CompanyName and the number of
products supplied. */

SELECT
 S.SupplierID,
 S.CompanyName,
 COUNT(*) AS ProductsCount
FROM Products P JOIN Suppliers S
  ON P.SupplierID = S.SupplierID
GROUP BY S.SupplierID, S.CompanyName
HAVING COUNT(*) > 3;

/* 
Show the list of products purchased in the order with ID 10250. Show product name, the quantity of the product ordered (Quantity), the unit
price (UnitPrice from OrderItems table), the discount (Discount), and the OrderDate. Order the items by product name. */


SELECT p.productname,  oi.discount, oi.quantity, oi.unitprice, o.orderdate
FROM products p
INNER JOIN orderitems as oi
  ON p.productid = oi.productid
INNER JOIN orders as o
  ON oi.orderid = o.orderid
WHERE o.orderid = 10250
ORDER BY p.productname;


/* Show the following information related to all items with OrderID = 10248:  Product name, the unit price, the quantity, and the name of the supplier's 
company (as SupplierName).
*/

SELECT
  ProductName,
  OI.UnitPrice,
  OI.Quantity,
  CompanyName AS SupplierName
FROM OrderItems OI
JOIN Products P 
  ON OI.ProductID = P.ProductID
JOIN Suppliers S
  ON S.SupplierID = P.SupplierID
WHERE OI.OrderID = 10248;

/* Count the number of employees hired in 2013.  Name the result NumberOfEmployees.
*/


SELECT COUNT(EmployeeID) as NumberOfEmployees
FROM Employees
WHERE HireDate Between '2013-01-01' AND '2013-12-31';

/* Show each SupplierID alongside the CompanyName and the number of products they supply (alias ProductsCount column). 
*/

SELECT S.SupplierID,
  S.CompanyName,
  Count(P.ProductID) as ProductsCount
 From Products P
 INNER JOIN Suppliers S
 ON P.SupplierID = S.SupplierID
 GROUP BY S.SupplierID, S.CompanyName;

 /* The Northwind store offers its customers discounts for some products. Find the Total price and price after discount for the order with ID 10250.
 */

 SELECT 
  SUM(UnitPrice * Quantity) AS TotalPrice, 
  SUM(UnitPrice * Quantity * (1 - Discount)) AS TotalPriceAfterDiscount
FROM Orders O
JOIN OrderItems OI
  ON O.OrderID = OI.OrderID
WHERE O.OrderID = 10250;


/* Show the number of orders processed by each employee. Show the following columns: EmployeeID, FirstName, LastName, and the number of orders processed as OrdersCount.
 */

SELECT
  E.EmployeeID,
  E.FirstName,
  E.LastName,
  COUNT(*) AS OrdersCount
FROM Orders O
JOIN Employees E
  ON E.EmployeeID = O.EmployeeID
GROUP BY E.EmployeeID,
  E.FirstName,
  E.LastName;

/* How much are the products in stock in each category worth? Show three columns: CategoryID, CategoryName, and CategoryTotalValue.
*/

SELECT
  C.CategoryID,
  C.CategoryName,
  SUM(UnitPrice * UnitsInStock) AS CategoryTotalValue
FROM Products P
JOIN Categories C
  ON P.CategoryID = C.CategoryID
GROUP BY C.CategoryID, C.CategoryName;

/* Count the number of orders placed by each customer. Show the CustomerID, CompanyName, and OrdersCount columns.
*/

SELECT
  C.CustomerID,
  C.CompanyName,
  COUNT(*) AS OrdersCount
FROM Orders O
JOIN Customers C
  ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID,
  C.CompanyName;

/* Which customers paid the most for orders made in June 2016 or July 2016? Show two columns:
CompanyName, TotalPaid  calculated as the total price (after discount) paid for all orders made by a given customer in June 2016 or July 2016.
Sort the results by TotalPaid in descending order. 
*/

SELECT 
 C.CompanyName,
 SUM(UnitPrice * Quantity * (1 - Discount)) as TotalPaid
FROM OrderItems
INNER JOIN Orders
 ON OrderItems.OrderID = Orders.OrderID
INNER JOIN Customers c
ON Orders.CustomerID = C.CustomerID
WHERE OrderDate BETWEEN '2016-06-01' AND '2016-07-31'
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalPaid DESC

/* Find the number of orders to be shipped to each country and the number of orders already shipped.
*/

SELECT
  ShipCountry,
  COUNT(*) AS AllOrders,
  COUNT(ShippedDate) AS ShippedOrders
FROM Orders
GROUP BY ShipCountry;

/* Find the total number of products provided by each supplier. Show the CompanyName and ProductsCount (the number of products supplied) 
 columns. Include suppliers that haven't provided any products.
 */

 SELECT 
  S.CompanyName,
  COUNT(P.ProductID) AS ProductsCount
FROM Suppliers S
LEFT JOIN Products P
  ON P.SupplierID = S.SupplierID
GROUP BY S.SupplierID, S.CompanyName;


/* Show the number of unique companies (as NumberOfCompanies)that had orders shipped to Spain.
*/

SELECT
  COUNT(DISTINCT C.CustomerID) AS NumberOfCompanies
FROM Orders O
JOIN Customers C
  ON O.CustomerID = C.CustomerID
WHERE ShipCountry = N'Spain';

/* Find the total number of products supplied by each supplier. Show the following columns: SupplierID, CompanyName, and 
ProductsSuppliedCount (the number of products supplied by that company).
*/

SELECT 
  S.SupplierID,
  S.CompanyName,
  COUNT(P.ProductID) as ProductsSuppliedCount
FROM Products P
INNER JOIN Suppliers S
  ON P.SupplierID = S.SupplierID
GROUP BY S.SupplierID, S.CompanyName;







