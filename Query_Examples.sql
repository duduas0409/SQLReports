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
			     
			   
/* Create  a report that will show each supplier alongside their number of units in stock and their number of expensive units in stock. 
Show four columns: supplier_id, company_name, all_units (all units in stock supplied by that supplier), and expensive_units (units in stock with 
unit price over 40.0, supplied by that supplier). */
			     
			     
SELECT 
  s.supplier_id,
  s.company_name,
  SUM(units_in_stock) AS all_units,
  SUM(CASE
    WHEN unit_price > 40.0 THEN units_in_stock
    ELSE 0
  END) AS expensive_units
FROM products p
JOIN suppliers s
  ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_id,
  s.company_name;

			     
/*  categorize all orders based on their total price (before any discount). For each order, show the following columns:

order_id
total_price (calculated before discount)
price_group, which should have the following values:
'high' for a total price over $2,000.
'average' for a total price between $600 and $2,000, both inclusive.
'low' for a total price under $600. */
			     
			     
			     
SELECT
  order_id,
  SUM(unit_price * quantity) AS total_price,
  CASE
    WHEN SUM(unit_price * quantity) > 2000 THEN 'high'
    WHEN SUM(unit_price * quantity) > 600 THEN 'average'
    ELSE 'low'
  END AS price_group
FROM order_items
GROUP BY order_id;
			     
			     
/* Group all orders based on the freight column. Show three columns in your report:

low_freight – the number of orders where the freight value is less than 40.0.
avg_freight – the number of orders where the freight value is greater than equal to or 40.0 but less than 80.0.
high_freight – the number of orders where the freight value is greater than equal to or 80.0. */
			     
SELECT
  COUNT(CASE
    WHEN freight >= 80.0 THEN order_id
  END) AS high_freight,
  COUNT(CASE
    WHEN freight < 40.0 THEN order_id
  END) AS low_freight,
  COUNT(CASE
    WHEN freight >= 40.0 AND freight < 80.0 THEN order_id
  END) AS avg_freight
FROM orders;			     
 

/* Show the average total price paid (after discount) per order.	*/		     
			     
WITH order_discounted_prices AS (
  SELECT
    o.order_id, 
    SUM(unit_price * quantity * (1 - discount)) AS total_discounted_price
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  GROUP BY o.order_id
)
SELECT
  ROUND(AVG(total_discounted_price),2) AS avg_total_discounted_price
FROM order_discounted_prices;
	
	
	
/*  find the average order value for each customer from Canada */
	
 WITH order_total_prices AS (
  SELECT
    o.order_id,
    o.customer_id,
    SUM(unit_price * quantity) AS total_price
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  GROUP BY o.order_id, o.customer_id
)

SELECT
  c.customer_id,
  c.company_name,
  AVG(total_price) AS avg_total_price
FROM order_total_prices OTP
JOIN customers c
  ON OTP.customer_id = c.customer_id
WHERE c.country = 'Canada'
GROUP BY c.customer_id, c.company_name;
	
	
/* For each employee from the Washington (WA) region, show the average value for all orders they placed.
 Show the following columns: employee_id, first_name, last_name, and avg_total_price (calculated as the
 average total order price, before discount).  */
	
WITH order_total_prices AS (
  SELECT
    o.order_id,
    o.employee_id,
    SUM(unit_price * quantity) AS total_price
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  GROUP BY o.order_id,
    o.employee_id
)
SELECT
  e.employee_id,
  e.first_name,
  e.last_name,
  AVG(total_price) AS avg_total_price
FROM order_total_prices otp
JOIN employees e
  ON otp.employee_id = e.employee_id
WHERE e.region = 'WA'
GROUP BY e.employee_id,
  e.first_name,
  e.last_name;	
	
                             
                             
/* For each shipping country, we want to find the average count of unique products in each order. 
Show the ship_country and avg_distinct_item_count columns. Sort the results by count, in descending order. */
	
	
WITH order_distinct_items AS (
  SELECT
    o.order_id,
    o.ship_country,
    COUNT(distinct product_id) AS distinct_item_count
  FROM orders o
  JOIN order_items oi 
    ON o.order_id = oi.order_id
  GROUP BY o.order_id,
    o.ship_country
)
SELECT
  ship_country,
  AVG(distinct_item_count) AS avg_distinct_item_count 
FROM order_distinct_items
GROUP BY ship_country
ORDER BY avg_distinct_item_count DESC;	
	
	
	
	
/*  For each employee, determine the average number of items they processed per order, for all orders placed in 2016. 
The number of items in an order is defined as the sum of all quantities of all items in that order. 
Show the following columns: first_name, last_name, and avg_item_count. */
	
	
	
WITH order_items_counts AS (
  SELECT
    o.order_id,
    o.employee_id,
    SUM(quantity) AS item_count
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  WHERE o.order_date >= '2016-01-01' AND o.order_date < '2017-01-01'
  GROUP BY o.order_id,
    o.employee_id
)
SELECT
  e.first_name,
  e.last_name,
  AVG(item_count) AS avg_item_count 
FROM order_items_counts oic
JOIN employees e
  ON oic.employee_id = e.employee_id
GROUP BY e.employee_id,
  e.first_name,
  e.last_name;
	
	
/* find the number of customers divided into three groups: those with fewer than 10 orders, those with 10–20 orders, and those with more than 20 orders */
	
	
WITH customer_order_counts AS (
  SELECT
    customer_id, 
    CASE
      WHEN COUNT(o.order_id) > 20
        THEN 'more than 20' 
      WHEN COUNT(o.order_id) <= 20 AND COUNT(o.order_id) >= 10
        THEN 'between 10 and 20'
      ELSE 'less than 10'
    END AS order_count_cat
  FROM orders o
  GROUP BY customer_id
) 

SELECT
  order_count_cat,
  COUNT(customer_id) AS customer_count
FROM customer_order_counts
GROUP BY order_count_cat;
	
	
	
/* Count the number of high value and low value customers. If the total price paid by a given customer for all their
orders is more than $20,000 before discounts, treat the customer as 'high-value'. Otherwise, treat them as 'low-value'.

Create a report with two columns: category (either 'high-value' or 'low-value') and customer_count.	*/
	
	
	
WITH customer_order_values AS (
  SELECT
    customer_id, 
    CASE
      WHEN SUM(quantity * unit_price) > 20000
        THEN 'high-value' 
      ELSE 'low-value'
    END AS category
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  GROUP BY customer_id
) 
SELECT 
  category,
  COUNT(customer_id) AS customer_count
FROM customer_order_values
GROUP BY category;	
	
	
                             
                             
/* What is the average number of products in non-vegetarian (category_id 6 or 8) and vegetarian categories (all other category_id values)? 
Show two columns: product_type (either 'vegetarian' or 'non-vegetarian') and avg_product_count. */
	
	
WITH product_counts AS (
  SELECT 
    category_id,
    CASE
      WHEN category_id IN (6, 8)
        THEN 'non-vegetarian'
      ELSE 'vegetarian'
    END AS product_type, 
    COUNT(*) AS product_count
  FROM products 
  GROUP BY category_id
)
SELECT
  product_type,
  AVG(product_count) AS avg_product_count
FROM product_counts
GROUP BY product_type;
	
	
	
	
/* For each employee, calculate the average order value (after discount) and then
show the minimum average (name the column minimal_average) and the maximum average (name the column maximal_average) values.	*/
	
	
	
WITH order_values AS (
  SELECT
    employee_id,
    SUM(unit_price * quantity * (1 - discount)) AS total_discount_price
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  GROUP BY o.order_id, employee_id
),
customer_averages AS (
  SELECT
    employee_id,
    AVG(total_discount_price) AS avg_discount_total_price
  FROM order_values
  GROUP BY employee_id
)
SELECT
  MIN(avg_discount_total_price) AS minimal_average,
  MAX(avg_discount_total_price) AS maximal_average
FROM customer_averages;
	
	
	
/* Among orders shipped to Italy, show all orders that had an above-average total value (before discount).
Show the order_id, order_value, and avg_order_value column. The avg_order_value column should show the same average order value for all rows.	*/
	
	
WITH order_values AS (
  SELECT
    o.order_id,
    SUM(quantity * unit_price) AS order_value
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  WHERE ship_country = 'Italy'
  GROUP BY o.order_id
),
avg_order_value AS (
  SELECT
    AVG(order_value) AS avg_order_value
  FROM order_values
)
SELECT
  order_id,
  order_value,
  avg_order_value
FROM order_values, avg_order_value
WHERE order_value > avg_order_value;
	
	
	
/* Find the average order value (after discount) for each customer. 
	Show the customer_id and avg_discounted_price columns.	*/
	
	
WITH order_values AS (
  SELECT
    customer_id,
    oi.order_id,
    SUM(unit_price * quantity * (1 - discount)) AS total_discounted_price
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  GROUP BY customer_id, oi.order_id
)
SELECT
  customer_id,
  AVG(total_discounted_price) AS avg_discounted_price
FROM order_values
GROUP BY customer_id;	
	
	
	
/* Create a report with two columns: price_category (which will contain either 'cheap' for 
products with a maximum unit_price of 20.0 or 'expensive' otherwise) and avg_products_on_order 
(the average number of units on order for a given price category).	 */
	
	
	
WITH product_info AS (
  SELECT
    product_id,
    CASE
      WHEN unit_price <= 20.0 THEN 'cheap'
      ELSE 'expensive'
    END AS price_category,
      units_on_order
  FROM products
)
SELECT
  price_category,
  AVG(units_on_order) AS avg_products_on_order
FROM product_info
GROUP By price_category;	


/* For each employee, determine their performance for 2016: Compute the total number and the total revenue for orders processed 
by each employee. Show the employee's first name (first_name), last name (last_name), and the two metrics in columns named order_count 
(total number of orders processed by the employee) and order_revenue (total revenue for orders processed by the employee). */
	
SELECT
  first_name,
  last_name,
  COUNT(DISTINCT o.order_id) AS order_count,
  SUM(unit_price * quantity * (1 - discount)) AS order_revenue
FROM employees e
LEFT JOIN orders o
  ON e.employee_id = o.employee_id
LEFT JOIN order_items oi
  ON o.order_id = oi.order_id
WHERE order_date BETWEEN '2016-01-01' AND '2016-12-31'
GROUP BY e.employee_id,
  first_name,
  last_name;
			       
			       
			       


/* For each category, show the number of products in stock (i.e., products where units_in_stock > 0) and the number of products not in stock. 
The report should contain three columns:

category_name, products_in_stock, products_not_in_stock  */

SELECT 
  category_name, 
  SUM(CASE
    WHEN units_in_stock > 0 THEN 1
    ELSE 0
  END) AS products_in_stock,
  SUM(CASE
    WHEN units_in_stock = 0 THEN 1
    ELSE 0
  END) AS products_not_in_stock
FROM products p
JOIN categories c
  ON p.category_id = c.category_id
GROUP BY c.category_id, 
  category_name;
			       
			       
			       

/* find the ratio of the revenue from all discounted items to the total revenue from all items.

discounted_revenue – the revenue (after discount) from all discounted line items in all orders.
total_revenue – the total revenue (after discount) from line items in all orders. 
discounted_ratio. It should contain the ratio of discounted line items (from column 1) to all line items (from column 2).  */
			       
SELECT
  SUM(CASE
    WHEN discount > 0
      THEN unit_price * quantity * (1 - discount)
  END) AS discounted_revenue,
  SUM(unit_price * quantity * (1 - discount)) AS total_revenue,
  ROUND(SUM(CASE
    WHEN discount > 0
      THEN unit_price * quantity * (1 - discount)
  END) / SUM(unit_price * quantity * (1 - discount)), 3) AS discounted_ratio
FROM order_items;
	     
	     
			
		  
/* What is the percentage of discontinued items at Northwind?
Show three columns: count_discontinued, count_all, and percentage_discontinued. Round the last column to two decimal places.	*/
	     
	     
	     
SELECT
  COUNT(CASE
    WHEN discontinued IS TRUE
      THEN product_id
  END) AS count_discontinued,
  COUNT(product_id) AS count_all,
  ROUND(COUNT(CASE
    WHEN discontinued IS TRUE
      THEN product_id
  END) / CAST(COUNT(product_id) AS decimal) * 100, 2) AS percentage_discontinued
FROM products;
	     
	     
	     
/* For each employee, find the percentage of all orders they processed that were placed by customers in France. 
Show five columns: first_name, last_name, count_france, count_all, and percentage_france (rounded to one decimal point). */
	     
	     
	     
SELECT
  first_name,
  last_name,
  COUNT(CASE
    WHEN c.country = 'France'
      THEN order_id
  END) AS count_france,
  COUNT(order_id) AS count_all,
  ROUND(COUNT(CASE
    WHEN c.country = 'France'
      THEN order_id
  END) / CAST(COUNT(order_id) AS decimal) * 100, 1) AS percentage_france
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
JOIN employees e
  ON e.employee_id = o.employee_id
GROUP BY e.employee_id,
  first_name,
  last_name;
	     
	     
/* Show each employee alongside the number of orders they processed in 2017 and the percentage of all orders from 2017 that they generated. 
Show the following columns: employee_id. first_name. last_name.
order_count – the number of orders processed by that employee in 2017.
order_count_percentage – the percentage of orders from 2017 processed by that employee.
Round the value of the last column to two decimal places. */
	     
	     
WITH total_count AS(
  SELECT 
    COUNT(order_id) AS all_orders 
  FROM orders
  WHERE order_date >= '2017-01-01' AND order_date < '2018-01-01'
)
SELECT 
  e.employee_id,
  e.first_name,
  e.last_name,
  COUNT(order_id) AS order_count, 
  ROUND(COUNT(order_id) / CAST(total_count.all_orders AS decimal) * 100, 2) AS order_count_percentage
FROM total_count, 
  employees e
JOIN orders o
  ON e.employee_id = o.employee_id 
WHERE order_date >= '2017-01-01' AND order_date < '2018-01-01'
GROUP BY e.employee_id,
  e.first_name,
  e.last_name,
  total_count.all_orders;	
	     
	     
	     
/* For each country, find the percentage of revenue generated by orders shipped to it in 2018. Show three columns:
ship_country, revenue – the total revenue generated by all orders shipped to that country in 2018,
revenue_percentage – the percentage of that year's revenue generated by orders shipped to that country in 2018.	  */
	     
	     
	     
WITH total_sales AS (
  SELECT 
    SUM(quantity * unit_price) AS sales_2018 
  FROM order_items oi
  JOIN orders o
    ON o.order_id = oi.order_id
  WHERE shipped_date >= '2018-01-01' AND shipped_date < '2019-01-01'
)
SELECT 
  o.ship_country, 
  SUM(quantity * unit_price) AS revenue, 
  ROUND(SUM(quantity * unit_price) / total_sales.sales_2018 * 100, 2) AS revenue_percentage
FROM total_sales, 
  orders o
JOIN order_items oi
  ON oi.order_id = o.order_id
WHERE shipped_date >= '2018-01-01' AND shipped_date < '2019-01-01'
GROUP BY o.ship_country,
  total_sales.sales_2018
ORDER BY 2 DESC;
	     
	     
	     
	     
	     
	     

