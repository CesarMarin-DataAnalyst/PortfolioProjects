--FACT TABLE

SELECT SO.OrderID, SO.CustomerID, SO.SalespersonPersonID, SO.ContactPersonID, SO.OrderDate,
SO.ExpectedDeliveryDate, SO.CustomerPurchaseOrderNumber, SOL.StockItemID, WSI.SupplierID,
SI.DeliveryMethodID, SI.TotalDryItems, SCT.PaymentMethodID, SCT.TransactionDate, 
SCT.AmountExcludingTax, SCT.TaxAmount,SCT.TransactionAmount, SCT.OutstandingBalance, SCT.FinalizationDate
FROM 
Sales.Orders SO
INNER JOIN SALES.Invoices SI
ON 
SO.OrderID = SI.OrderID
INNER JOIN SALES.CustomerTransactions SCT
ON 
SI.InvoiceID = SCT.InvoiceID
INNER JOIN Sales.OrderLines SOL
ON 
SO.OrderID = SOL.OrderID
INNER JOIN Warehouse.StockItems WSI
ON 
SOL.StockItemID = WSI.StockItemID

-- DIM USUARIOS REGISTRADOS

SELECT AP.PersonID, AP.FullName, AP.SearchName, AP.LogonName ,AP.IsPermittedToLogon,
AP.PhoneNumber, AP.FaxNumber, AP.EmailAddress, AP.OtherLanguages, AP.IsEmployee, 
AP.IsSystemUser, AP.IsSalesperson
FROM 
Application.People AP

--DIM PRODUCTOS

SELECT WSI.StockItemID, WSI.StockItemName, WSI.SearchDetails, WSI.MarketingComments,
WSI.UnitPrice, WSI.TaxRate, WSI.RecommendedRetailPrice
FROM
Warehouse.StockItems WSI

--DIM SUPPLIERS

SELECT PS.SupplierID, PS.SupplierName, PSC.SupplierCategoryName AS "Supplier Category", 
AP.FullName AS "Main Contact", ap.EmailAddress, 
PS.SupplierReference, PS.PhoneNumber,PS.FaxNumber, PS.WebsiteURL,
PS.BankAccountName, PS.BankAccountBranch, PS.BankAccountCode,
PS.BankInternationalCode, PS.InternalComments
FROM
Purchasing.Suppliers PS
INNER JOIN Application.People AP
ON 
PS.PrimaryContactPersonID = AP.PersonID
INNER JOIN Purchasing.SupplierCategories PSC
ON PS.SupplierCategoryID = PSC.SupplierCategoryID


--DIM CLIENTES

SELECT SC.CustomerID, SC.CustomerName, sc.PhoneNumber, sc.FaxNumber, sc.WebsiteURL,
sc.DeliveryAddressLine1, sc.DeliveryAddressLine2, sc.DeliveryPostalCode as "Zip Code",
AC.CityName AS "Delivery City", DM.DeliveryMethodName as "Delivery Method", 
AP.FullName AS "Primary Contact", AP.EmailAddress as "Contact Email Address"	
FROM 
SALES.Customers SC
INNER JOIN 
Application.DeliveryMethods DM
ON
SC.DeliveryMethodID = DM.DeliveryMethodID
INNER JOIN Application.People AP
ON SC.PrimaryContactPersonID = AP.PersonID
INNER JOIN Application.Cities AC
ON SC.DeliveryCityID = AC.CityID

-- DIM EMPLOYEES

SELECT AP.PersonID AS "Employee ID", AP.FullName, AP.PreferredName ,AP.PhoneNumber, AP.EmailAddress, 
AP.OtherLanguages, AP.UserPreferences
FROM 
Application.People AP
WHERE AP.IsEmployee = 1