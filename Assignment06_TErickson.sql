--*************************************************************************--
-- Title: Assignment06
-- Author: TErickson
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-08-14,TErickson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TErickson')
	 Begin 
	  Alter Database [Assignment06DB_TErickson] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TErickson;
	 End
	Create Database Assignment06DB_TErickson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TErickson;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Showing my Work:  Use select statement to gather the column names
--Select * From Categories;
--go
USE Assignment06DB_TErickson
GO
CREATE 
VIEW vCategories
WITH SCHEMABINDING 
AS
	SELECT CategoryID
	, CategoryName
	FROM dbo.Categories
GO

--Showing my Work:  Use select statement to gather the column names
--Select * From Products;
--go
USE Assignment06DB_TErickson
GO
CREATE 
VIEW vProducts
WITH SCHEMABINDING 
AS
	SELECT ProductID
	,ProductName
	,CategoryID
	,UnitPrice
	FROM dbo.Products
GO	

--Showing my Work:  Use select statement to gather the column names
--Select * From Employees;
--go
USE Assignment06DB_TErickson
GO
CREATE 
VIEW vEmployees
WITH SCHEMABINDING 
AS
	SELECT EmployeeID
	,EmployeeFirstName
	,EmployeeLastName
	,ManagerID
	FROM dbo.Employees
GO

--Showing my Work:  Use select statement to gather the column names
--Select * From Inventories;
--go
USE Assignment06DB_TErickson
GO
CREATE 
VIEW vInventories
WITH SCHEMABINDING 
AS
	SELECT InventoryID
	,InventoryDate
	,EmployeeID
	,ProductID
	,Count AS InventoryCount
	FROM dbo.Inventories
GO

SELECT * FROM [dbo].[vCategories]
GO
SELECT * FROM [dbo].[vProducts]
GO
SELECT * FROM [dbo].[vEmployees]
GO
SELECT * FROM [dbo].[vInventories]
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Showing my work:  No work to show.  Just using Grant & Deny to set Public Group permissions. Verified by 
--going to Security/Roles/Database Roles/Public, right click 'properties', securables.
USE Assignment06DB_TErickson
GO
DENY SELECT ON dbo.categories TO Public;
GO
DENY SELECT ON dbo.products TO Public;
GO
DENY SELECT ON dbo.employees TO Public;
GO
DENY SELECT ON dbo.inventories TO Public;
GO

USE Assignment06DB_TErickson
GO
GRANT SELECT ON dbo.vCategories TO Public;
GO
GRANT SELECT ON dbo.vProducts TO Public;
GO
GRANT SELECT ON dbo.vEmployees TO Public;
GO
GRANT SELECT ON dbo.vInventories TO Public;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Showing my work: Verified this question is from the same tables as Q1 on Assignment 5, Copied working code,
--adjusted code to pull from the views created in Q1 on Assignment 6. Finally, verified row count of Assignment 6
--Matches row count from Assignment 5(77).

USE Assignment06DB_TErickson
GO
CREATE 
VIEW vProductsByCategories
WITH SCHEMABINDING 
AS
	SELECT TOP 100 dbo.vCategories.CategoryName
	,dbo.vProducts.ProductName
	,dbo.vProducts.UnitPrice
	FROM dbo.vCategories
	JOIN dbo.vProducts ON dbo.vCategories.CategoryID = dbo.vProducts.CategoryID
	ORDER BY CategoryName,ProductName
GO


SELECT * FROM dbo.vProductsByCategories
GO
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Showing my work: Verified this question is from the same tables as Q2 on Assignment 5, Copied working code,
--adjusted code to pull from the views created in Q1 on Assignment 6.Finally, verified row count of Assignment 6
--Matches row count from Assignment 5(231).

USE Assignment06DB_TErickson
GO
CREATE 
VIEW vInventoriesByProductsByDates
WITH SCHEMABINDING 
AS
	SELECT TOP 1000 dbo.vProducts.ProductName
	,dbo.vInventories.InventoryDate
	,dbo.vInventories.InventoryCount
	FROM dbo.vProducts 
	LEFT JOIN dbo.vInventories ON dbo.vProducts.ProductID = dbo.vInventories.ProductID
	ORDER BY ProductName, InventoryDate, InventoryCount
GO

SELECT * FROM dbo.vInventoriesByProductsByDates
GO
-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Showing my work: Verified this question is from the same tables as Q3 on Assignment 5, Copied working code,
--adjusted code to pull from the views created in Q1 on Assignment 6.Finally, verified row count of Assignment 6
--Matches row count and order from Assignment 5(3).

USE Assignment06DB_TErickson
GO
CREATE 
VIEW vInventoriesByEmployeesByDates
WITH SCHEMABINDING 
AS
	SELECT TOP 1000 dbo.vInventories.InventoryDate
,dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName AS EmployeeName
FROM dbo.vInventories
LEFT JOIN dbo.vEmployees ON dbo.vInventories.EmployeeID = dbo.vEmployees.EmployeeID
GROUP BY InventoryDate,EmployeeFirstName,EmployeeLastName
ORDER BY InventoryDate
GO

SELECT * FROM dbo.vInventoriesByEmployeesByDates
GO

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Showing my work: Verified this question is from the same tables as Q4 on Assignment 5, Copied working code,
--adjusted code to pull from the views created in Q1 on Assignment 6.Finally, verified row count of Assignment 6
--Matches row count and order from Assignment 5(231).

USE Assignment06DB_TErickson
GO

GO
CREATE 
VIEW vInventoriesByProductsByCategories
WITH SCHEMABINDING 
AS
	SELECT TOP 1000 dbo.vCategories.CategoryName
	,dbo.vProducts.ProductName
	,dbo.vInventories.InventoryDate
	,dbo.vInventories.InventoryCount
	FROM dbo.vCategories
	JOIN dbo.vProducts ON dbo.vCategories.CategoryID = dbo.vProducts.CategoryID
	JOIN dbo.vInventories ON dbo.vProducts.ProductID = dbo.vInventories.ProductID
	ORDER BY CategoryName,ProductName,InventoryDate,InventoryCount
GO

SELECT * FROM dbo.vInventoriesByProductsByCategories
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Showing my work: Verified this question is from the same tables as Q5 on Assignment 5, Copied working code,
--adjusted code to pull from the views created in Q1 on Assignment 6.Finally, verified row count of Assignment 6
--Matches row count and order from Assignment 5(231).

USE Assignment06DB_TErickson
GO
CREATE 
VIEW vInventoriesByProductsByEmployees
WITH SCHEMABINDING 
AS
	SELECT TOP 1000 dbo.vCategories.CategoryName
	,dbo.vProducts.ProductName
	,dbo.vInventories.InventoryDate
	,dbo.vInventories.InventoryCount
	,dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName AS EmployeeName
	FROM dbo.vCategories
	JOIN dbo.vProducts ON dbo.vCategories.CategoryID = dbo.vProducts.CategoryID
	JOIN dbo.vInventories ON dbo.vProducts.ProductID = dbo.vInventories.ProductID
	JOIN dbo.vEmployees ON dbo.vInventories.EmployeeID = dbo.vEmployees.EmployeeID
	ORDER BY InventoryDate,CategoryName,ProductName,EmployeeName
GO

SELECT * FROM dbo.vInventoriesByProductsByEmployees
GO
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Showing my work: Verified this question is from the same tables as Q6 on Assignment 5, Copied working code,
--adjusted code to pull from the views created in Q1 on Assignment 6.Finally, verified row count of Assignment 6
--Matches row count and order from Assignment 5(6).


USE Assignment06DB_TErickson
GO
CREATE 
VIEW vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING 
AS
	SELECT TOP 1000 dbo.vCategories.CategoryName
	,dbo.vProducts.ProductName
	,dbo.vInventories.InventoryDate
	,dbo.vInventories.InventoryCount
	,dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName AS EmployeeName
	FROM dbo.vCategories
	JOIN dbo.vProducts ON dbo.vCategories.CategoryID = dbo.vProducts.CategoryID
	JOIN dbo.vInventories ON dbo.vProducts.ProductID = dbo.vInventories.ProductID
	JOIN dbo.vEmployees ON dbo.vInventories.EmployeeID = dbo.vEmployees.EmployeeID
	WHERE dbo.vProducts.ProductName IN ('Chai','Chang')
	ORDER BY InventoryDate,CategoryName,ProductName
GO

SELECT * FROM dbo.vInventoriesForChaiAndChangByEmployees
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Showing my work: Verified this question is from the same tables as Q7 on Assignment 5, Copied working code,
--adjusted code to pull from the views created in Q1 on Assignment 6.Finally, verified row count of Assignment 6
--Matches row count and order from Assignment 5(9).

USE Assignment06DB_TErickson
GO
CREATE 
VIEW vEmployeesByManager
WITH SCHEMABINDING 
AS
	SELECT TOP 1000 m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager
	,e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
	FROM dbo.vEmployees e, dbo.vEmployees m
	WHERE  e.ManagerID = m.EmployeeID 
	ORDER BY Manager,EmployeeName
GO

SELECT * FROM dbo.vEmployeesByManager
GO

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?
USE Assignment06DB_TErickson
GO
CREATE 
VIEW vInventoriesByProductsByCategoriesByEmployees
WITH SCHEMABINDING 
AS
	SELECT TOP 1000 dbo.vCategories.CategoryID
	,dbo.vCategories.CategoryName
	,dbo.vProducts.ProductID
	,dbo.vProducts.ProductName
	,dbo.vProducts.UnitPrice
	,dbo.vInventories.InventoryID
	,dbo.vInventories.InventoryDate
	,dbo.vInventories.InventoryCount
	,dbo.vEmployees.EmployeeID
	,dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName AS EmployeeName
	,dbo.vEmployeesByManager.Manager AS ManagerName
	FROM dbo.vCategories
	JOIN dbo.vProducts ON dbo.vCategories.CategoryID = dbo.vProducts.CategoryID
	JOIN dbo.vInventories ON dbo.vProducts.ProductID = dbo.vInventories.ProductID
	JOIN dbo.vEmployees ON dbo.vInventories.EmployeeID = dbo.vEmployees.EmployeeID
	JOIN dbo.vEmployeesByManager ON dbo.vEmployees.EmployeeFirstName + ' ' + dbo.vEmployees.EmployeeLastName 
									= dbo.vEmployeesByManager.EmployeeName
	WHERE dbo.vProducts.ProductName = 'Chai'
GO

SELECT * FROM dbo.vInventoriesByProductsByCategoriesByEmployees
GO 
-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/