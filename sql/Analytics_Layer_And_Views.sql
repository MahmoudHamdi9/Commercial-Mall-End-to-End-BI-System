--================================================================================
-- Mall Management System | Financial & Operational Analysis
-- Author: Mahmoud Hamdy
-- Purpose: Turn operational data into business insights for executive decision-making
--================================================================================

--------------------------------------------------------------------------------
-- 1) Financial Health Summary
-- Business Question:
-- Are we collecting the revenue we are expecting?
-- Why it matters:
-- Highlights the gap between billed revenue and actual cash collection.
-- Key Outputs:
-- Expected_Revenue, Actual_Collection, Due_Balance
SELECT 
    (SELECT SUM(Total_Amount) FROM Invoices) AS Expected_Revenue,
    (SELECT SUM(Amount) FROM Shop_Collections) AS Actual_Collection,
    (SELECT SUM(Total_Amount) FROM Invoices) - (SELECT SUM(Amount) FROM Shop_Collections) AS Due_Balance;

GO
CREATE VIEW v_Financial_Summary AS
SELECT 
    (SELECT SUM(Total_Amount) FROM Invoices) AS Expected_Revenue,
    (SELECT SUM(Amount) FROM Shop_Collections) AS Actual_Collection,
    (SELECT SUM(Total_Amount) FROM Invoices) - (SELECT SUM(Amount) FROM Shop_Collections) AS Due_Balance;
GO


--------------------------------------------------------------------------------
-- 2) Monthly Operating Expenses Trend
-- Business Question:
-- How are operating costs changing over time?
-- Why it matters:
-- Helps identify cost spikes in maintenance, utilities, or payroll-related spending.
-- Key Outputs:
-- Maintenance_Expenses, Utilities_Expenses, Operational_Expenses
SELECT 
    YEAR(expense_date) AS Expense_Year,
    MONTH(expense_date) AS Expense_Month,
    SUM(CASE WHEN Expense_category = N'ÕíÇäÉ æÅÕáÇÍ' THEN amount ELSE 0 END) AS Maintenance_Expenses,
    SUM(CASE WHEN Expense_category = N'ãÑÇÝÞ ÚÇãÉ' THEN amount ELSE 0 END) AS Utilities_Expenses,
    SUM(CASE WHEN Expense_category = N'ÑæÇÊÈ æÊÔÛíá' THEN amount ELSE 0 END) AS Operational_Expenses
FROM Expenses
GROUP BY YEAR(expense_date), MONTH(expense_date)
ORDER BY Expense_Year, Expense_Month;

GO
CREATE VIEW v_Expenses_Monthly_Trend AS
SELECT 
    YEAR(expense_date) AS Expense_Year,
    MONTH(expense_date) AS Expense_Month,
    SUM(CASE WHEN Expense_category = N'ÕíÇäÉ æÅÕáÇÍ' THEN amount ELSE 0 END) AS Maintenance_Expenses,
    SUM(CASE WHEN Expense_category = N'ãÑÇÝÞ ÚÇãÉ' THEN amount ELSE 0 END) AS Utilities_Expenses,
    SUM(CASE WHEN Expense_category = N'ÑæÇÊÈ æÊÔÛíá' THEN amount ELSE 0 END) AS Operational_Expenses
FROM Expenses
GROUP BY YEAR(expense_date), MONTH(expense_date);
GO


--------------------------------------------------------------------------------
-- 3) Passage Performance
-- Business Question:
-- Do high-traffic passages generate stronger business returns?
-- Why it matters:
-- Supports rental pricing, tenant allocation, and area performance review.
-- Key Outputs:
-- Passage_Name, Peak_Percentage, Total_Revenue, Active_Shops, AvgPricePerSQM
SELECT          
    passages_name    AS Passage_Name,
    Peak_Percentage  AS Peak_Percentage,
    SUM(C.Rent_Amount)     AS Total_Revenue,
    COUNT(S.Shop_ID)       AS Active_Shops,
    CAST(SUM(C.Rent_Amount) / SUM(S.area_size) AS DECIMAL(10,2)) AS AvgPricePerSQM
FROM Passages P 
INNER JOIN Shops S ON P.Passages_ID = S.Passages_ID
INNER JOIN Contracts C ON S.Shop_ID = C.Shop_ID
WHERE C.End_Date >= GETDATE() AND Contract_Status = N'äÔØ'
GROUP BY passages_name, Peak_Percentage
ORDER BY Peak_Percentage DESC;

GO
CREATE VIEW v_Passages_Performance AS
SELECT          
    passages_name    AS Passage_Name,
    Peak_Percentage  AS Peak_Percentage,
    SUM(C.Rent_Amount)     AS Total_Revenue,
    COUNT(S.Shop_ID)       AS Active_Shops,
    CAST(SUM(C.Rent_Amount) / SUM(S.area_size) AS DECIMAL(10,2)) AS AvgPricePerSQM
FROM Passages P 
INNER JOIN Shops S ON P.Passages_ID = S.Passages_ID
INNER JOIN Contracts C ON S.Shop_ID = C.Shop_ID
WHERE C.End_Date >= GETDATE() AND Contract_Status = N'äÔØ'
GROUP BY passages_name, Peak_Percentage;
GO


--------------------------------------------------------------------------------
-- 4) Tenant Risk Analysis
-- Business Question:
-- Which tenants are at risk due to violations or contract issues?
-- Why it matters:
-- Helps management identify tenants that need follow-up before churn or escalation.
-- Key Outputs:
-- Brand_Name, Shop_num, Contract_Status, total_Violation, fine_amount, End_Date
SELECT 
    T.Brand_Name,
    S.Shop_num,
    C.Contract_Status,
    COUNT(V.shop_id) AS total_Violation,
    SUM(VR.fine_amount) AS fine_amount,
    C.End_Date
FROM tenants T
INNER JOIN Contracts C ON T.tenant_ID = C.tenant_ID
INNER JOIN Shops S ON C.Shop_ID = S.Shop_ID
LEFT JOIN ShopViolations V ON S.Shop_ID = V.shop_id AND V.Violation_Date >= C.Start_Date AND V.Violation_Date <= C.End_Date
LEFT JOIN ViolationRules VR ON V.rule_id = VR.rule_id
GROUP BY T.Brand_Name, S.Shop_num, C.Contract_Status, C.End_Date
ORDER BY total_Violation DESC;

GO
CREATE VIEW v_Tenants_At_Risk AS
SELECT 
    T.Brand_Name,
    S.Shop_num,
    C.Contract_Status,
    COUNT(V.shop_id) AS total_Violation,
    SUM(VR.fine_amount) AS fine_amount,
    C.End_Date
FROM tenants T
INNER JOIN Contracts C ON T.tenant_ID = C.tenant_ID
INNER JOIN Shops S ON C.Shop_ID = S.Shop_ID
LEFT JOIN ShopViolations V ON S.Shop_ID = V.shop_id AND V.Violation_Date >= C.Start_Date AND V.Violation_Date <= C.End_Date
LEFT JOIN ViolationRules VR ON V.rule_id = VR.rule_id
GROUP BY T.Brand_Name, S.Shop_num, C.Contract_Status, C.End_Date;
GO


--------------------------------------------------------------------------------
-- 5) Overdue Invoices Seasonality
-- Business Question:
-- Are overdue invoices concentrated in specific months?
-- Why it matters:
-- Supports collection planning and seasonal risk monitoring.
-- Key Outputs:
-- Invoice_Month, Overdue_invoices
SELECT 
    MONTH(Invoice_Date) AS Invoice_Month_Number,
    COUNT(Invoice_Status) AS Overdue_invoices
FROM Invoices
WHERE Invoice_Status = N'ÛíÑ ãÏÝæÚÉ'
GROUP BY MONTH(Invoice_Date);
GO

GO
CREATE VIEW v_Overdue_Invoices_Seasonality AS
SELECT 
    MONTH(Invoice_Date) AS Invoice_Month_Number,
    COUNT(Invoice_Status) AS Overdue_invoices
FROM Invoices
WHERE Invoice_Status = N'ÛíÑ ãÏÝæÚÉ'
GROUP BY MONTH(Invoice_Date);
GO


--------------------------------------------------------------------------------
-- 6) Employee Performance Summary
-- Business Question:
-- How effective are employees in terms of performance and discipline?
-- Why it matters:
-- Combines appraisal, attendance, violations, and sanctions into one view.
-- Key Outputs:
-- Employee_ID, Employee_Name, Job_Title, Avg_Score, Captured_Violations, Sanctions_Count
WITH Evaluation_CTE AS (
    SELECT employee_id, CAST(AVG((attendance_score + performance_score ) / 2.0 ) AS DECIMAL(10, 2)) AS Avg_Score
    FROM EmployeeEvaluations GROUP BY employee_id
),
Sanctions_CTE AS (
    SELECT employee_id, action_type, COUNT(action_type) AS Sanctions_Count 
    FROM EmployeeSanctions WHERE action_type = N'ÎÕã ãÇáí' GROUP BY employee_id, action_type 
),
ShopViolations_CTE AS (
    SELECT employee_id, COUNT(violation_id) AS Count_Violation FROM ShopViolations GROUP BY employee_id
)
SELECT
    E.Employee_ID, E.Employee_Name, E.Job_Title, EC.Avg_Score,
    ISNULL(S.Count_Violation, 0) AS Captured_Violations, ISNULL(SC.Sanctions_Count, 0) AS Sanctions_Count 
FROM Employees E  
LEFT JOIN Evaluation_CTE EC ON E.Employee_ID = EC.employee_id
LEFT JOIN Sanctions_CTE SC ON E.Employee_ID = SC.employee_id 
LEFT JOIN ShopViolations_CTE S ON E.Employee_ID = S.employee_id;

GO
CREATE VIEW v_Employee_Performance_Summary AS
WITH Evaluation_CTE AS (
    SELECT employee_id, CAST(AVG((attendance_score + performance_score ) / 2.0 ) AS DECIMAL(10, 2)) AS Avg_Score
    FROM EmployeeEvaluations GROUP BY employee_id
),
Sanctions_CTE AS (
    SELECT employee_id, action_type, COUNT(action_type) AS Sanctions_Count 
    FROM EmployeeSanctions WHERE action_type = N'ÎÕã ãÇáí' GROUP BY employee_id, action_type 
),
ShopViolations_CTE AS (
    SELECT employee_id, COUNT(violation_id) AS Count_Violation FROM ShopViolations GROUP BY employee_id
)
SELECT
    E.Employee_ID, E.Employee_Name, E.Job_Title, EC.Avg_Score,
    ISNULL(S.Count_Violation, 0) AS Captured_Violations, ISNULL(SC.Sanctions_Count, 0) AS Sanctions_Count 
FROM Employees E  
LEFT JOIN Evaluation_CTE EC ON E.Employee_ID = EC.employee_id
LEFT JOIN Sanctions_CTE SC ON E.Employee_ID = SC.employee_id 
LEFT JOIN ShopViolations_CTE S ON E.Employee_ID = S.employee_id;
GO


--------------------------------------------------------------------------------
-- 7) Asset Condition Summary
-- Business Question:
-- What is the current technical condition of operational assets?
-- Why it matters:
-- Supports maintenance planning and replacement decisions.
-- Key Outputs:
-- Asset_Name, Asset_Condition, Asset_Count
SELECT 
    Asset_Name AS Asset_Name,
    Asset_Condition AS Asset_Condition,
    COUNT(Asset_Id) AS Asset_Count
FROM Assets
GROUP BY Asset_Name, Asset_Condition 
ORDER BY Asset_Condition DESC;

GO
CREATE VIEW v_Assets_Condition_Summary AS
SELECT 
    Asset_Name AS Asset_Name,
    Asset_Condition AS Asset_Condition,
    COUNT(Asset_Id) AS Asset_Count
FROM Assets
GROUP BY Asset_Name, Asset_Condition;
GO