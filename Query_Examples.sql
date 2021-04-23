/* 2 sample Microsoft db describes a fictional store and
   its employees, customers, suppliers, products and orders


Employees table:
Stores information about the people employed at Northwind.
Each employee has:

A unique ID (Employee_ID).
A first and last name (First_Name and Last_Name).
A professional title (Title) ect.

Customers table:
Each customer has a unique Customer_ID, which is a five-letter abbreviation of the full company name stored in the Company_Name column.
There are also columns related to the contact person (Contact_Name and Contact_Title) and some related to the customer's address and fax number.

Products table stores information about products sold at the Northwind store.
Each product has a unique Product_ID and a Product_Name. Each product is supplied by a single supplier (Supplier_ID) and belongs to a single category (Category_ID).
Each product also has a certain Unit_Price. The Discontinued column contains either a 0 (available in store) or a 1 (discontinued) that reflects the
current availability of that product.

Products are organized into categories. The information about categories is stored in the Categories table. Each category has a unique ID and a
Category_Name. There is also a short Description.


Orders table contains general information about an order: the Order_ID, Customer_ID, and Employee_ID related to that sale. There are also timestamp
columns (Order_Date and Shipped_Date) and many columns related to the shipment process.

The Order_Items table contains information about order items. Each row represents a single item from an order.
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
  S.Supplier_ID,
  S.Company_Name,
  COUNT(P.Product_ID) as products_supplied_count
FROM Products P
RIGHT JOIN Suppliers S
  ON P.Supplier_ID = S.Supplier_ID
GROUP BY S.Supplier_ID, S.Company_Name;

/* How many distinct products are there in all orders shipped to France? Name the result DistinctProducts.
*/

SELECT
  COUNT(DISTINCT OI.Product_ID) AS Distinct_Products
FROM Orders O
JOIN Order_Items OI
  ON O.Order_ID = OI.Order_ID
WHERE Ship_Country = 'France';

/* Which employees processed the highest -value orders made during June and July 2016?
For each employee, compute the total order value before discount from all orders processed by this employee between 5 July 2016 and 31 July 2016. Show the following columns: FirstName, LastName, and SumOrders. 
Sort the results by SumOrders in descending order.
*/

SELECT
  E.First_Name,
  E.Last_Name, 
  SUM(Unit_Price * Quantity) AS Sum_Orders
FROM Orders O
JOIN Order_Items OI
  ON O.Order_ID = OI.Order_ID
JOIN Employees E
  ON E.Employee_ID = O.Employee_ID
WHERE Order_Date >= '2016-07-05' AND Order_Date < '2016-08-01'
GROUP BY E.Employee_ID,
  E.First_Name,
  E.Last_Name
ORDER BY Sum_Orders DESC;

/* Show the FirstName, LastName, HireDate, and Experience columns for each employee. The Experience column should display the following values:
'junior' for employees hired after January, 1st 2014.
'middle' for employees hired after January, 1st 2013 but before January, 1st 2014.
'senior' for employees hired on or before January, 1st 2013.
*/


SELECT
  First_Name,
  Last_Name,
  Hire_Date,
  CASE
    WHEN Hire_Date > '2014-01-01' THEN 'junior'
    WHEN Hire_Date > '2013-01-01' THEN 'middle'
    ELSE 'senior'
  END AS Experience
FROM Employees;


/* create a report that will divide all products into vegetarian and non-vegetarian categories. For each product, show the following columns:

ProductName
CategoryName
DietType:
N'Non-vegetarian' for products from the categories N'Meat/Poultry' and N'Seafood'.
N'Vegetarian' for any other category. */

SELECT
 product_name,
 category_name,
CASE
  WHEN category_name IN ('Meat/Poultry', 'Seafood') THEN 'Non-vegetarian'
  ELSE 'Vegetarian'
END AS diet_type
FROM products p
JOIN categories c
ON c.category_id = p.category_id


/* Create a report that shows the number of products supplied from a specific continent. Display two columns: SupplierContinent and ProductCount. The SupplierContinent column should have the following values:

N'North America' for products supplied from N'USA' and N'Canada'.
N'Asia' for products from N'Japan' and N'Singapore'.
N'Other' for other countries.
*/

SELECT 
  CASE
    WHEN country IN ('USA', 'Canada') THEN 'North America'
    WHEN country IN ('Japan', 'Singapore') THEN 'Asia'
    ELSE 'Other'
  END AS supplier_continent,
  COUNT(*) AS product_count
FROM products p
JOIN suppliers s
  ON p.supplier_id = s.supplier_id
GROUP BY
  CASE
    WHEN country IN ('USA', 'Canada') THEN 'North America'
    WHEN country IN ('Japan', 'Singapore') THEN 'Asia'
    ELSE 'Other'
  END;


 /* How many customers are represented by owners (ContactTitle = N'Owner'), and how many arent? Show two columns with appropriate values: RepresentedByOwner and NotRepresentedByOwner.
*/

SELECT 
  COUNT(CASE
    WHEN contact_title = 'Owner' THEN customer_id
  END) AS represented_by_owner,
  COUNT(CASE
    WHEN contact_title != 'Owner' THEN customer_id
  END) AS not_represented_by_owner
FROM customers;

/*How many orders have been processed by employees in the WA region, and how many by employees in other regions? Show two columns with their respective counts: OrdersWAEmployees and OrdersNotWAEmployees.
*/

SELECT 
  COUNT(CASE
    WHEN region = 'WA' THEN order_id
  END) AS orders_wa_employees,
  COUNT(CASE
    WHEN region != 'WA' THEN order_id
  END) AS orders_not_wa_employees
FROM employees e
JOIN orders o
  ON e.employee_id = o.employee_id;
                             
                             
/* Create a report that will show the number of products with high and low availability in all product categories. Show three columns:
   category_name, high_availability (count the products with more than 30 units in stock) and low_availability (count the products with 30 or fewer units in stock).
*/
                             
SELECT 
  c.category_name,
  COUNT(CASE
    WHEN units_in_stock > 30 THEN product_id
  END) AS high_availability,
  COUNT(CASE
    WHEN units_in_stock <= 30 THEN product_id
  END) AS low_availability
FROM products p
JOIN categories c
  ON p.category_id = c.category_id
GROUP BY c.category_id,
  c.category_name;
									  
                             
                             
									  

                             
                             
                             
                             
                             















