/* 2 sample Microsoft db describes a fictional store and
   its employees, customers, suppliers, products and orders


Employees table:
It stores information about the people employed at Northwind.
Each employee has:

A unique ID (EmployeeID).
A first and last name (FirstName and LastName).
A professional title (Title) ect.

Customers table:
Each customer has a unique CustomerID, which is a five-letter abbreviation
of the full company name stored in the CompanyName column.
There are also columns related to the contact person (ContactName and
ContactTitle) and some related to the customer's address and fax number.

Products table stores information about products sold at the Northwind store.
Each product has a unique ProductID and a ProductName. Each product is supplied
by a single supplier (SupplierID) and belongs to a single category (CategoryID).
Each product also has a certain UnitPrice. The Discontinued column contains
either a 0 (available in store) or a 1 (discontinued) that reflects the
current availability of that product.

Products are organized into categories. The information about categories is
stored in the Categories table. Each category has a unique ID and a
CategoryName. There is also a short Description.


Orders table contains general information about an order: the OrderID,
CustomerID, and EmployeeID related to that sale. There are also timestamp
columns (OrderDate and ShippedDate) and many columns related to the shipment
process.

The OrderItems table contains information about order items. Each row
represents a single item from an order.

*/

/* For each product, display name (ProductName), the name of the category
it belongs to (CategoryName), quantity per unit (QuantityPerUnit), the unit
price (UnitPrice), and the number of units in stock (UnitsInStock).
Order the results by unit price.
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
Show the information about all the suppliers who provide the store with four or
more different products. Show the SupplierID, CompanyName and the number of
products supplied. */

SELECT
 S.SupplierID,
 S.CompanyName,
 COUNT(*) AS ProductsCount
FROM Products P JOIN Suppliers S
  ON P.SupplierID = S.SupplierID
GROUP BY S.SupplierID, S.CompanyName
HAVING COUNT(*) > 3;

/* Show the list of products purchased in the order with ID 10250.
Show product name, the quantity of the product ordered (Quantity), the unit
price (UnitPrice from OrderItems table), the discount (Discount), and the
OrderDate. Order the items by product name. */

SELECT p.productname,  oi.discount, oi.quantity, oi.unitprice, o.orderdate
FROM products p
INNER JOIN orderitems as oi
  ON p.productid = oi.productid
INNER JOIN orders as o
  ON oi.orderid = o.orderid
WHERE o.orderid = 10250
ORDER BY p.productname;
