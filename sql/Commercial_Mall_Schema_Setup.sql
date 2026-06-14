

--================================================================================

-- Mall Management System | Database Schema & Architecture
-- Author: Mahmoud Hamdi
-- Purpose:
-- Provide a robust, scalable backend structure to manage mall operations,
-- track tenants and contracts, optimize financial billing, and monitor
-- employee and asset performance.

---- =========================================================



-- ===================================================
-- 1. CREATE DATABASE SECTION
-- ===================================================
USE master;
GO

create database MallManagementSystem;
go

use MallManagementSystem ;
go



-- ===================================================
-- 2. PARENT TABLES 
-- ===================================================


-- =========================================================
-- Passages Table
-- =========================================================


CREATE TABLE Passages (
   Passages_ID      INT IDENTITY (1,1),
   passages_name    NVARCHAR (50) not null ,
   Peak_Percentage  DECIMAL (5,2) DEFAULT 0.00 NOT NULL ,

   CONSTRAINT  PK_Passages_ID  PRIMARY KEY (passages_ID) ,
   CONSTRAINT  CK_Peak_Percentage  CHECK (Peak_Percentage >= 0.00 AND Peak_Percentage <= 100.00 )
);


-- =========================================================
-- Shops Table
-- =========================================================


CREATE TABLE Shops (
    Shop_ID          INT IDENTITY (1,1),
    Shop_num         VARCHAR (10) NOT NULL,
    Area_Size        DECIMAL (8,2) NOT NULL,
    Estimated_Price  DECIMAL (18,2) NOT NULL,
    Passages_ID      INT NOT NULL,
    Shop_Status      NVARCHAR(20) NOT NULL DEFAULT N'„ «Õ ··≈ÌÃ«—',

    CONSTRAINT PK_Shop_ID PRIMARY KEY (Shop_ID),
    CONSTRAINT UK_Shop_num UNIQUE (Shop_num),
    CONSTRAINT CK_Shops_Area_Positive CHECK (Area_Size > 0.00),
    CONSTRAINT CK_Shops_Price_Positive CHECK (Estimated_Price > 0.00),
    CONSTRAINT CK_Shop_Status CHECK (Shop_Status IN (N'„ «Õ ··≈ÌÃ«—', N'„ƒÃ—', N' Õ  «·’Ì«‰…')),
    CONSTRAINT FK_Passages_ID FOREIGN KEY (Passages_ID) 
       REFERENCES Passages(Passages_ID) 
       ON DELETE NO ACTION
       ON UPDATE CASCADE 
);

-- =========================================================
-- tenants Table
-- =========================================================


CREATE TABLE tenants (
    tenant_ID           INT IDENTITY (1,1) ,
    tenant_name         NVARCHAR (100)  NOT NULL ,
    Brand_Name          VARCHAR (100)  NOT NULL ,
    Phone_Number        VARCHAR(15) not null ,
    email               VARCHAR (50) NOT NULL ,
    Commercial_Register VARCHAR (100) NOT NULL , 
    
    CONSTRAINT PK_tenants_ID  PRIMARY KEY (tenant_ID) 
);


-- =========================================================
-- Employees Table (Current & Former)
-- =========================================================


CREATE TABLE Employees (
    Employee_ID    INT IDENTITY (1,1) ,
    Employee_Name  NVARCHAR (50) NOT NULL ,
    Departments    NVARCHAR (20) NOT NULL ,
    Job_Title      NVARCHAR (20) NOT NULL ,
    Hire_Date      DATE NOT NULL ,
    Leave_Date     DATE NULL DEFAULT NULL,
    CONSTRAINT PK_Employee_ID PRIMARY KEY (Employee_ID),
    CONSTRAINT  CK_Leave_Date CHECK ( Leave_Date IS NULL OR Leave_Date>=Hire_Date )
);

-- =========================================================
-- Assets Table
-- =========================================================


CREATE TABLE Assets (
    Asset_ID          INT IDENTITY (1,1),
    Asset_Name        NVARCHAR (50) NOT NULL ,
    Serial_Number     NVARCHAR (50) NOT NULL ,
    Asset_Condition   NVARCHAR (50) NOT NULL DEFAULT N'„„ «“ ' ,

    CONSTRAINT PK_Asset_ID PRIMARY KEY (Asset_ID),
    CONSTRAINT CHK_Asset_Condition CHECK ( Asset_Condition IN (N'„„ «“', N'ÃÌœ', N'„Õ «Ã ’Ì«‰…', N'Œ«—Ã «·Œœ„…'))
);




-- ===================================================
-- 3. CHILD TABLES 
-- ===================================================
-- =========================================================

-- =========================================================
-- Contracts Table
-- =========================================================


CREATE TABLE Contracts (
    Contract_ID       INT IDENTITY (1,1) ,
    tenant_ID         INT NOT NULL , 
    Shop_ID           INT NOT NULL ,
    Start_Date        DATE NOT NULL ,
    End_Date          DATE NOT NULL ,
    Contract_Status   NVARCHAR(20) NOT NULL DEFAULT N'‰‘ÿ',
    Rent_Amount       DECIMAL(18, 2) NOT NULL,

    CONSTRAINT PK_Contracts_ID PRIMARY KEY   (Contract_ID),
    CONSTRAINT CK_Contract_Dates CHECK    (End_Date > Start_Date) ,
    CONSTRAINT CK_Rent_Amount_Positive CHECK    (Rent_Amount > 0) ,
    CONSTRAINT FK_tenants_ID FOREIGN KEY     (tenant_ID )
      REFERENCES   tenants(tenant_ID)
      ON DELETE NO ACTION
        ON UPDATE CASCADE ,
    CONSTRAINT FK_Shop_ID FOREIGN KEY (Shop_ID) 
      REFERENCES Shops(Shop_ID)
      ON DELETE NO ACTION
        ON UPDATE CASCADE

);



-- =========================================================
-- Invoices Table
-- =========================================================


CREATE TABLE Invoices (
    Invoice_ID      INT IDENTITY (1,1) ,
    Contract_ID      INT NOT NULL ,
    Invoice_Date     DATE NOT NULL ,
    Due_Date         DATE  NOT NULL ,-- «·ﬁÌ„… «·≈ÌÃ«—Ì… (‘«„·… «·‹ 10% ·Ê Êﬁ Â« ÃÂ) ⁄·‘«‰ «·«Œÿ«¡ «·„” ﬁ»·ÌÂ
    Total_Amount     DECIMAL(18, 2) NOT NULL,
    Invoice_Status   NVARCHAR(20) NOT NULL DEFAULT N'€Ì— „œ›Ê⁄…',

    CONSTRAINT PK_Invoices_ID   PRIMARY KEY (Invoice_ID),
    CONSTRAINT CK_Due_Date CHECK    (Due_Date > Invoice_Date ),
    CONSTRAINT CK_Total_Amount CHECK   (Total_Amount>=0),
    CONSTRAINT CK_Invoice_Status CHECK (Invoice_Status IN (N'€Ì— „œ›Ê⁄…', N'„œ›Ê⁄… Ã“∆Ì«', N'„œ›Ê⁄… »«·ﬂ«„·', N'„ √Œ—…')),
    CONSTRAINT FK_Contract_ID FOREIGN KEY (Contract_ID) 
      REFERENCES Contracts(Contract_ID)
      ON DELETE NO ACTION
        ON UPDATE CASCADE
);



-- =========================================================
-- Shop Collections Table (Cash & Revenues)
-- =========================================================


CREATE TABLE Shop_Collections (
    collection_id    INT IDENTITY(1,1),
    shop_id          INT NOT NULL,
    invoice_id       INT NOT NULL,
    employee_id      INT NOT NULL,
    amount           DECIMAL(12,2) NOT NULL,
    payment_method   NVARCHAR(30) NOT NULL DEFAULT N'ﬂ«‘',
    receipt_number   NVARCHAR(50) NOT NULL,
    collection_date  DATETIME NOT NULL DEFAULT GETDATE(), 
    notes            NVARCHAR(500) NULL,

    CONSTRAINT PK_Shop_Collections PRIMARY KEY (collection_id),
    CONSTRAINT CK_Collection_Amount_Positive CHECK (amount > 0),
    --  ﬁÌÌœ ÿ—ﬁ «·œ›⁄ «·„⁄ „œ… ›Ì «·„Ê· ›ﬁÿ
    CONSTRAINT CK_Payment_Method CHECK (payment_method IN (N'ﬂ«‘', N'›Ì“«', N'‘Ìﬂ', N' ÕÊÌ· »‰ﬂÌ')),

    CONSTRAINT UQ_Receipt_Number UNIQUE (receipt_number),

    
    CONSTRAINT FK_Collections_Shops FOREIGN KEY (shop_id) 
        REFERENCES Shops(shop_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    
    CONSTRAINT FK_Collections_Invoices FOREIGN KEY (invoice_id) 
        REFERENCES Invoices(Invoice_ID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Collections_Employees FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);



-- =========================================================
-- Employee Monthly Evaluations Table
-- =========================================================


CREATE TABLE EmployeeEvaluations (
    evaluation_id      INT IDENTITY(1,1),
    employee_id        INT NOT NULL, 
    evaluator_id       INT NOT NULL,
    evaluation_date    DATE NOT NULL,
    performance_score  INT NOT NULL, 
    attendance_score   INT NOT NULL,
    manager_notes      NVARCHAR(500) NULL,
    
    CONSTRAINT PK_Employee_Evaluations PRIMARY KEY (evaluation_id),
    ---⁄œ„ Œ—ÊÃ «· ﬁÌÌ„ „‰ «·«—ﬁ„ „« »Ì‰ 1 Ê 5.
    CONSTRAINT CHK_performance_score CHECK (performance_score BETWEEN 1 AND 5),
    CONSTRAINT CK_Attendance_Score CHECK (attendance_score BETWEEN 1 AND 5),

    -- —»ÿ «·„ÊŸ› »ÃœÊ· «·„ÊŸ›Ì‰ «·√”«”Ì
    CONSTRAINT FK_Evaluations_Employee FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    -- —»ÿ «·„œÌ— »ÃœÊ· «·„ÊŸ›Ì‰ «·√”«”Ì („⁄  €ÌÌ— «”„ «·ﬁÌœ „‰⁄« ·· ﬂ—«—)
    CONSTRAINT FK_Evaluations_Evaluator FOREIGN KEY (evaluator_id) 
        REFERENCES Employees(employee_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);


-- =========================================================
-- Employee Sanctions and Rewards Table
-- =========================================================


CREATE TABLE EmployeeSanctions (
    sanction_id      INT IDENTITY(1,1),
    employee_id      INT NOT NULL,
    action_type      NVARCHAR(20) NOT NULL,
    amount           DECIMAL(10,2) NOT NULL,
    action_date      DATE NOT NULL,
    reason           NVARCHAR(500) NOT NULL,
    approved_by      INT NOT NULL,
    CONSTRAINT PK_Employee_Sanctions PRIMARY KEY (sanction_id),
    
    CONSTRAINT CK_Action_Type CHECK (action_type IN (N'Œ’„ „«·Ì', N'„ﬂ«›√… „«·Ì…', N'≈‰–«— ﬂ «»Ì', N'≈Ìﬁ«› ⁄‰ «·⁄„·')),
    CONSTRAINT CK_Sanction_Amount_NonNegative CHECK (amount >= 0),

    CONSTRAINT FK_Sanctions_Employee FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT FK_Sanctions_Approver FOREIGN KEY (approved_by) 
        REFERENCES Employees(employee_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

    
-- =========================================================
-- Violation Rules Table (Fixed Fines)
-- =========================================================


CREATE TABLE ViolationRules (
    rule_id         INT IDENTITY(1,1) ,
    violation_name  NVARCHAR(150) NOT NULL ,  
    fine_amount     DECIMAL(10,2) NOT NULL ,   
    description     NVARCHAR(500) NULL ,

    CONSTRAINT PK_Shop_Fine_Rules PRIMARY KEY (rule_id),
    CONSTRAINT CK_Shop_Fine_Amount_Positive CHECK (fine_amount >= 0)
);



-- =========================================================
-- Shop Violations Log Table
-- =========================================================


CREATE TABLE ShopViolations (
    violation_id     INT IDENTITY(1,1),
    shop_id          INT NOT NULL,
    employee_id      INT NOT NULL, 
    rule_id          INT NOT NULL,
    Violation_Date   DATE NOT NULL ,
    is_paid          BIT NOT NULL DEFAULT 0,    -- »Ê·Ì«‰ (0 = ·„ Ì „ «·œ›⁄ / 1 =  „ «·œ›⁄)
    receipt_number   NVARCHAR(50) NULL,
    notes            NVARCHAR(500) NULL,

    CONSTRAINT PK_Shop_Violations PRIMARY KEY (violation_id),

    CONSTRAINT CK_Receipt_Matches_Payment CHECK (
        (is_paid = 0 AND receipt_number IS NULL) OR 
        (is_paid = 1 AND receipt_number IS NOT NULL)
    ),

    CONSTRAINT FK_Violations_Shops FOREIGN KEY (shop_id) 
        REFERENCES Shops(shop_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    CONSTRAINT FK_Violations_Employees FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT FK_Violations_Rules FOREIGN KEY (rule_id) 
        REFERENCES ViolationRules(rule_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);



-- =========================================================
-- Material Transactions Table (Inbound & Outbound)
-- =========================================================


CREATE TABLE MaterialTransactions (
    transaction_id   INT IDENTITY(1,1),
    material_name    NVARCHAR(150) NOT NULL,
    transaction_type NVARCHAR(20) NOT NULL,
    quantity         DECIMAL(10,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT GETDATE(),
    employee_id      INT NOT NULL,
    notes            NVARCHAR(500) NULL,

    CONSTRAINT PK_Material_Transactions PRIMARY KEY (transaction_id),

    -- ﬁÌœ √„«‰: «· √ﬂœ „‰ ‰Ê⁄ «·Õ—ﬂ… («” ·«„ ··Ê«—œ / ≈—”«· ··„‰’—›)
    CONSTRAINT CK_Material_Transaction_Type CHECK (transaction_type IN (N'«” ·«„', N'≈—”«·')),
   
   CONSTRAINT CK_Material_Quantity_Positive CHECK (quantity > 0),
    CONSTRAINT FK_Material_Transactions_Employees FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);


-- =========================================================
-- Expenses Table
-- =========================================================


create table Expenses (
Expenses_id        INT ,
Expenses_title     NVARCHAR(100) NOT NULL,
Expense_category   NVARCHAR (100) NOT NULL,
amount             DECIMAL(10,2) NOT NULL,
expense_date       DATE NOT NULL,
paid_to            NVARCHAR (100) NOT NULL,
Employee_ID        INT NOT NULL,

CONSTRAINT PK_Expenses_id PRIMARY KEY (Expenses_id),

CONSTRAINT CHK_Expense_Category 
        CHECK (Expense_category IN (N'„‘ —Ì«  √’Ê·', N'’Ì«‰… Ê≈’·«Õ', N'„—«›ﬁ ⁄«„…', N'—Ê« » Ê ‘€Ì·')), -- ÕÿÌ‰« ›«’·… Â‰«
        
    CONSTRAINT FK_employee_id 
        FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);



-- =========================================================
-- Asset Transactions Table (Inbound & Outbound Log)
-- =========================================================


    AssetTransaction_ID   INT IDENTITY(1,1),
    Asset_ID              INT NOT NULL,
    Transaction_Type      NVARCHAR(30) NOT NULL,
    Transaction_Date      DATETIME NOT NULL DEFAULT GETDATE(),
    Employee_ID           INT NOT NULL,
    Notes                 NVARCHAR(500) NULL,

    CONSTRAINT PK_AssetTransactions
        PRIMARY KEY (AssetTransaction_ID),

    CONSTRAINT CK_AssetTransaction_Type
        CHECK (
            Transaction_Type IN (
                N'«” ·«„',
                N'‰ﬁ·',
                N'’Ì«‰…',
                N'≈⁄œ«„',
                N'≈Œ—«Ã „‰ «·Œœ„…',
                N'≈⁄«œ…  ‘€Ì·'
            )
        ),

    CONSTRAINT FK_AssetTransactions_Assets
        FOREIGN KEY (Asset_ID)
        REFERENCES Assets(Asset_ID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,

    CONSTRAINT FK_AssetTransactions_Employees
        FOREIGN KEY (Employee_ID)
        REFERENCES Employees(Employee_ID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);


-- =========================================================
-- Dim_Date Table (Calendar Dimension) 
-- =========================================================


CREATE TABLE Dim_Date (
    DateKey       INT PRIMARY KEY, 
    FullDate      DATE NOT NULL UNIQUE, 
    YearNumber    INT NOT NULL, 
    MonthNumber   INT NOT NULL, 
    MonthName     VARCHAR(20) NOT NULL,
    DayNumber     INT NOT NULL, 
    DayName       VARCHAR(20) NOT NULL 
);
GO

SET LANGUAGE English; 
GO

DECLARE @StartDate DATE = '2020-01-01';
DECLARE @EndDate   DATE = '2030-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO Dim_Date (DateKey, FullDate, YearNumber, MonthNumber, MonthName, DayNumber, DayName)
    VALUES (
        (YEAR(@StartDate) * 10000) + (MONTH(@StartDate) * 100) + DAY(@StartDate),
        @StartDate,
        YEAR(@StartDate),
        MONTH(@StartDate),
        DATENAME(MONTH, @StartDate), 
        DAY(@StartDate),
        DATENAME(WEEKDAY, @StartDate) 
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
GO