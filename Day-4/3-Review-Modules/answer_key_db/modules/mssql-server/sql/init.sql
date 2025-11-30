-- MSSQL Database Initialization Script for Banking System
-- This script creates schemas, tables, and stored procedures for a banking application
-- Variables: $(SCHEMA_NAME) - Schema name passed from Terraform

-- ============================================
-- CREATE SCHEMA
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '$(SCHEMA_NAME)')
BEGIN
    EXEC('CREATE SCHEMA [$(SCHEMA_NAME)]')
    PRINT 'Schema [$(SCHEMA_NAME)] created successfully'
END
ELSE
BEGIN
    PRINT 'Schema [$(SCHEMA_NAME)] already exists'
END
GO

-- ============================================
-- CREATE TABLE: Customers
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Customers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[Customers] (
        CustomerID INT PRIMARY KEY IDENTITY(1,1),
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        Email NVARCHAR(100) NOT NULL UNIQUE,
        Phone NVARCHAR(20),
        DateOfBirth DATE NOT NULL,
        SSN NVARCHAR(11), -- Format: XXX-XX-XXXX (stored encrypted in production)
        AddressLine1 NVARCHAR(100),
        AddressLine2 NVARCHAR(100),
        City NVARCHAR(50),
        State NVARCHAR(2),
        ZipCode NVARCHAR(10),
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1,
        CONSTRAINT CK_Customers_Email CHECK (Email LIKE '%@%.%'),
        CONSTRAINT CK_Customers_SSN CHECK (SSN IS NULL OR LEN(SSN) = 11)
    )
    PRINT 'Table [$(SCHEMA_NAME)].[Customers] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [$(SCHEMA_NAME)].[Customers] already exists'
END
GO

-- ============================================
-- CREATE TABLE: AccountTypes
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[AccountTypes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[AccountTypes] (
        AccountTypeID INT PRIMARY KEY IDENTITY(1,1),
        TypeCode NVARCHAR(10) NOT NULL UNIQUE, -- CHECKING, SAVINGS, MONEYMARKET, CD
        TypeName NVARCHAR(50) NOT NULL,
        Description NVARCHAR(200),
        InterestRate DECIMAL(5,4) DEFAULT 0.0000 CHECK (InterestRate >= 0 AND InterestRate <= 1),
        MinimumBalance DECIMAL(10,2) DEFAULT 0 CHECK (MinimumBalance >= 0),
        MonthlyFee DECIMAL(10,2) DEFAULT 0 CHECK (MonthlyFee >= 0),
        CreatedDate DATETIME DEFAULT GETDATE()
    )
    PRINT 'Table [$(SCHEMA_NAME)].[AccountTypes] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [$(SCHEMA_NAME)].[AccountTypes] already exists'
END
GO

-- ============================================
-- CREATE TABLE: Accounts
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Accounts]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[Accounts] (
        AccountID INT PRIMARY KEY IDENTITY(1,1),
        AccountNumber NVARCHAR(20) NOT NULL UNIQUE, -- Format: XXXX-XXXX-XXXX-XXXX
        CustomerID INT NOT NULL,
        AccountTypeID INT NOT NULL,
        Balance DECIMAL(18,2) DEFAULT 0.00 CHECK (Balance >= 0),
        AvailableBalance DECIMAL(18,2) DEFAULT 0.00 CHECK (AvailableBalance >= 0),
        OpenDate DATETIME DEFAULT GETDATE(),
        CloseDate DATETIME NULL,
        Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Closed', 'Frozen', 'Pending')),
        CONSTRAINT FK_Accounts_Customers FOREIGN KEY (CustomerID) REFERENCES [$(SCHEMA_NAME)].[Customers](CustomerID),
        CONSTRAINT FK_Accounts_AccountTypes FOREIGN KEY (AccountTypeID) REFERENCES [$(SCHEMA_NAME)].[AccountTypes](AccountTypeID)
    )
    PRINT 'Table [$(SCHEMA_NAME)].[Accounts] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [$(SCHEMA_NAME)].[Accounts] already exists'
END
GO

-- ============================================
-- CREATE TABLE: TransactionTypes
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[TransactionTypes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[TransactionTypes] (
        TransactionTypeID INT PRIMARY KEY IDENTITY(1,1),
        TypeCode NVARCHAR(10) NOT NULL UNIQUE, -- DEPOSIT, WITHDRAWAL, TRANSFER, FEE, INTEREST
        TypeName NVARCHAR(50) NOT NULL,
        Description NVARCHAR(200),
        IsDebit BIT DEFAULT 0, -- 1 = Debit (money out), 0 = Credit (money in)
        CreatedDate DATETIME DEFAULT GETDATE()
    )
    PRINT 'Table [$(SCHEMA_NAME)].[TransactionTypes] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [$(SCHEMA_NAME)].[TransactionTypes] already exists'
END
GO

-- ============================================
-- CREATE TABLE: Transactions
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Transactions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[Transactions] (
        TransactionID BIGINT PRIMARY KEY IDENTITY(1,1),
        TransactionNumber NVARCHAR(30) NOT NULL UNIQUE,
        AccountID INT NOT NULL,
        TransactionTypeID INT NOT NULL,
        Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
        BalanceAfter DECIMAL(18,2) NOT NULL CHECK (BalanceAfter >= 0),
        Description NVARCHAR(200),
        RelatedAccountID INT NULL, -- For transfers
        TransactionDate DATETIME DEFAULT GETDATE(),
        ProcessedDate DATETIME DEFAULT GETDATE(),
        Status NVARCHAR(20) DEFAULT 'Completed' CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Reversed')),
        CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountID) REFERENCES [$(SCHEMA_NAME)].[Accounts](AccountID),
        CONSTRAINT FK_Transactions_TransactionTypes FOREIGN KEY (TransactionTypeID) REFERENCES [$(SCHEMA_NAME)].[TransactionTypes](TransactionTypeID),
        CONSTRAINT FK_Transactions_RelatedAccount FOREIGN KEY (RelatedAccountID) REFERENCES [$(SCHEMA_NAME)].[Accounts](AccountID)
    )
    PRINT 'Table [$(SCHEMA_NAME)].[Transactions] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [$(SCHEMA_NAME)].[Transactions] already exists'
END
GO

-- ============================================
-- CREATE TABLE: Loans
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Loans]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[Loans] (
        LoanID INT PRIMARY KEY IDENTITY(1,1),
        LoanNumber NVARCHAR(20) NOT NULL UNIQUE,
        CustomerID INT NOT NULL,
        AccountID INT NULL, -- Linked account for auto-pay
        LoanType NVARCHAR(20) NOT NULL CHECK (LoanType IN ('Personal', 'Mortgage', 'Auto', 'Business')),
        PrincipalAmount DECIMAL(18,2) NOT NULL CHECK (PrincipalAmount > 0),
        InterestRate DECIMAL(5,4) NOT NULL CHECK (InterestRate >= 0 AND InterestRate <= 1),
        TermMonths INT NOT NULL CHECK (TermMonths > 0),
        MonthlyPayment DECIMAL(18,2) NOT NULL CHECK (MonthlyPayment > 0),
        RemainingBalance DECIMAL(18,2) NOT NULL CHECK (RemainingBalance >= 0),
        OriginationDate DATETIME DEFAULT GETDATE(),
        MaturityDate DATETIME NOT NULL,
        Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'PaidOff', 'Defaulted', 'Closed')),
        CONSTRAINT FK_Loans_Customers FOREIGN KEY (CustomerID) REFERENCES [$(SCHEMA_NAME)].[Customers](CustomerID),
        CONSTRAINT FK_Loans_Accounts FOREIGN KEY (AccountID) REFERENCES [$(SCHEMA_NAME)].[Accounts](AccountID)
    )
    PRINT 'Table [$(SCHEMA_NAME)].[Loans] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [$(SCHEMA_NAME)].[Loans] already exists'
END
GO

-- ============================================
-- CREATE STORED PROCEDURE: GetCustomerAccounts
-- ============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[GetCustomerAccounts]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [$(SCHEMA_NAME)].[GetCustomerAccounts]
GO

CREATE PROCEDURE [$(SCHEMA_NAME)].[GetCustomerAccounts]
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AccountID,
        a.AccountNumber,
        a.Balance,
        a.AvailableBalance,
        a.Status,
        a.OpenDate,
        at.TypeCode,
        at.TypeName,
        at.InterestRate,
        c.FirstName + ' ' + c.LastName AS CustomerName
    FROM [$(SCHEMA_NAME)].[Accounts] a
    INNER JOIN [$(SCHEMA_NAME)].[AccountTypes] at ON a.AccountTypeID = at.AccountTypeID
    INNER JOIN [$(SCHEMA_NAME)].[Customers] c ON a.CustomerID = c.CustomerID
    WHERE a.CustomerID = @CustomerID
      AND a.Status = 'Active'
    ORDER BY a.OpenDate DESC
END
GO

PRINT 'Stored Procedure [$(SCHEMA_NAME)].[GetCustomerAccounts] created successfully'
GO

-- ============================================
-- CREATE SEQUENCE FOR TRANSACTION NUMBERS
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'TransactionSequence')
BEGIN
    CREATE SEQUENCE [dbo].[TransactionSequence]
        START WITH 1
        INCREMENT BY 1
        MINVALUE 1
        MAXVALUE 9999999999
        CYCLE
    PRINT 'Sequence TransactionSequence created successfully'
END
ELSE
BEGIN
    PRINT 'Sequence TransactionSequence already exists'
END
GO

-- ============================================
-- CREATE STORED PROCEDURE: ProcessTransaction
-- ============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[ProcessTransaction]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [$(SCHEMA_NAME)].[ProcessTransaction]
GO

CREATE PROCEDURE [$(SCHEMA_NAME)].[ProcessTransaction]
    @AccountID INT,
    @TransactionTypeCode NVARCHAR(10),
    @Amount DECIMAL(18,2),
    @Description NVARCHAR(200) = NULL,
    @RelatedAccountID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    
    BEGIN TRY
        -- Validate account exists and is active
        IF NOT EXISTS (SELECT 1 FROM [$(SCHEMA_NAME)].[Accounts] WHERE AccountID = @AccountID AND Status = 'Active')
        BEGIN
            RAISERROR('Account does not exist or is not active', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Get transaction type
        DECLARE @TransactionTypeID INT
        DECLARE @IsDebit BIT
        
        SELECT @TransactionTypeID = TransactionTypeID, @IsDebit = IsDebit
        FROM [$(SCHEMA_NAME)].[TransactionTypes]
        WHERE TypeCode = @TransactionTypeCode
        
        IF @TransactionTypeID IS NULL
        BEGIN
            RAISERROR('Invalid transaction type', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate amount
        IF @Amount <= 0
        BEGIN
            RAISERROR('Amount must be greater than zero', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Get current balance
        DECLARE @CurrentBalance DECIMAL(18,2)
        DECLARE @AvailableBalance DECIMAL(18,2)
        DECLARE @NewBalance DECIMAL(18,2)
        
        SELECT @CurrentBalance = Balance, @AvailableBalance = AvailableBalance
        FROM [$(SCHEMA_NAME)].[Accounts]
        WHERE AccountID = @AccountID
        
        -- Calculate new balance
        IF @IsDebit = 1 -- Debit (money out)
        BEGIN
            IF @CurrentBalance < @Amount
            BEGIN
                RAISERROR('Insufficient funds', 16, 1)
                ROLLBACK TRANSACTION
                RETURN
            END
            SET @NewBalance = @CurrentBalance - @Amount
        END
        ELSE -- Credit (money in)
        BEGIN
            SET @NewBalance = @CurrentBalance + @Amount
        END
        
        -- Update account balance
        UPDATE [$(SCHEMA_NAME)].[Accounts]
        SET Balance = @NewBalance,
            AvailableBalance = @NewBalance
        WHERE AccountID = @AccountID
        
        -- Generate transaction number
        DECLARE @TransactionNumber NVARCHAR(30)
        SET @TransactionNumber = 'TXN-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + RIGHT('0000000000' + CAST(NEXT VALUE FOR [dbo].[TransactionSequence] AS NVARCHAR), 10)
        
        -- Create transaction record
        INSERT INTO [$(SCHEMA_NAME)].[Transactions] (
            TransactionNumber,
            AccountID,
            TransactionTypeID,
            Amount,
            BalanceAfter,
            Description,
            RelatedAccountID,
            Status
        )
        VALUES (
            @TransactionNumber,
            @AccountID,
            @TransactionTypeID,
            @Amount,
            @NewBalance,
            @Description,
            @RelatedAccountID,
            'Completed'
        )
        
        -- Return transaction details
        SELECT 
            SCOPE_IDENTITY() AS TransactionID,
            @TransactionNumber AS TransactionNumber,
            @NewBalance AS NewBalance,
            'Success' AS Status
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

PRINT 'Stored Procedure [$(SCHEMA_NAME)].[ProcessTransaction] created successfully'
GO

-- ============================================
-- CREATE STORED PROCEDURE: GetAccountBalance
-- ============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[GetAccountBalance]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [$(SCHEMA_NAME)].[GetAccountBalance]
GO

CREATE PROCEDURE [$(SCHEMA_NAME)].[GetAccountBalance]
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AccountID,
        a.AccountNumber,
        a.Balance,
        a.AvailableBalance,
        a.Status,
        at.TypeName AS AccountType,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        (
            SELECT COUNT(*)
            FROM [$(SCHEMA_NAME)].[Transactions] t
            WHERE t.AccountID = a.AccountID
              AND t.TransactionDate >= DATEADD(DAY, -30, GETDATE())
        ) AS TransactionsLast30Days
    FROM [$(SCHEMA_NAME)].[Accounts] a
    INNER JOIN [$(SCHEMA_NAME)].[AccountTypes] at ON a.AccountTypeID = at.AccountTypeID
    INNER JOIN [$(SCHEMA_NAME)].[Customers] c ON a.CustomerID = c.CustomerID
    WHERE a.AccountID = @AccountID
END
GO

PRINT 'Stored Procedure [$(SCHEMA_NAME)].[GetAccountBalance] created successfully'
GO

-- ============================================
-- CREATE STORED PROCEDURE: TransferFunds
-- ============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[TransferFunds]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [$(SCHEMA_NAME)].[TransferFunds]
GO

CREATE PROCEDURE [$(SCHEMA_NAME)].[TransferFunds]
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(18,2),
    @Description NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    
    BEGIN TRY
        -- Validate accounts exist and are active
        IF NOT EXISTS (SELECT 1 FROM [$(SCHEMA_NAME)].[Accounts] WHERE AccountID = @FromAccountID AND Status = 'Active')
        BEGIN
            RAISERROR('Source account does not exist or is not active', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF NOT EXISTS (SELECT 1 FROM [$(SCHEMA_NAME)].[Accounts] WHERE AccountID = @ToAccountID AND Status = 'Active')
        BEGIN
            RAISERROR('Destination account does not exist or is not active', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        IF @FromAccountID = @ToAccountID
        BEGIN
            RAISERROR('Source and destination accounts cannot be the same', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Validate amount
        IF @Amount <= 0
        BEGIN
            RAISERROR('Amount must be greater than zero', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Process withdrawal from source account
        EXEC [$(SCHEMA_NAME)].[ProcessTransaction]
            @AccountID = @FromAccountID,
            @TransactionTypeCode = 'WITHDRAWAL',
            @Amount = @Amount,
            @Description = ISNULL(@Description, 'Transfer to Account ' + CAST(@ToAccountID AS NVARCHAR)),
            @RelatedAccountID = @ToAccountID
        
        -- Process deposit to destination account
        EXEC [$(SCHEMA_NAME)].[ProcessTransaction]
            @AccountID = @ToAccountID,
            @TransactionTypeCode = 'DEPOSIT',
            @Amount = @Amount,
            @Description = ISNULL(@Description, 'Transfer from Account ' + CAST(@FromAccountID AS NVARCHAR)),
            @RelatedAccountID = @FromAccountID
        
        -- Return success
        SELECT 
            'Success' AS Status,
            @Amount AS Amount,
            @FromAccountID AS FromAccountID,
            @ToAccountID AS ToAccountID
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

PRINT 'Stored Procedure [$(SCHEMA_NAME)].[TransferFunds] created successfully'
GO

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Accounts_CustomerID' AND object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Accounts]'))
BEGIN
    CREATE INDEX IX_Accounts_CustomerID ON [$(SCHEMA_NAME)].[Accounts](CustomerID)
    PRINT 'Index IX_Accounts_CustomerID created successfully'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Accounts_AccountNumber' AND object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Accounts]'))
BEGIN
    CREATE UNIQUE INDEX IX_Accounts_AccountNumber ON [$(SCHEMA_NAME)].[Accounts](AccountNumber)
    PRINT 'Index IX_Accounts_AccountNumber created successfully'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Transactions_AccountID' AND object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Transactions]'))
BEGIN
    CREATE INDEX IX_Transactions_AccountID ON [$(SCHEMA_NAME)].[Transactions](AccountID)
    PRINT 'Index IX_Transactions_AccountID created successfully'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Transactions_TransactionDate' AND object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Transactions]'))
BEGIN
    CREATE INDEX IX_Transactions_TransactionDate ON [$(SCHEMA_NAME)].[Transactions](TransactionDate DESC)
    PRINT 'Index IX_Transactions_TransactionDate created successfully'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Transactions_TransactionNumber' AND object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Transactions]'))
BEGIN
    CREATE UNIQUE INDEX IX_Transactions_TransactionNumber ON [$(SCHEMA_NAME)].[Transactions](TransactionNumber)
    PRINT 'Index IX_Transactions_TransactionNumber created successfully'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Loans_CustomerID' AND object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Loans]'))
BEGIN
    CREATE INDEX IX_Loans_CustomerID ON [$(SCHEMA_NAME)].[Loans](CustomerID)
    PRINT 'Index IX_Loans_CustomerID created successfully'
END
GO

PRINT 'Database initialization completed successfully!'
GO
