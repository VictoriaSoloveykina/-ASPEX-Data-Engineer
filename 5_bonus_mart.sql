-- ==============================================================
-- ВИТРИНА ДАННЫХ ДЛЯ ПРЕМИЙ СОТРУДНИКОВ
-- ==============================================================

USE BicycleRental;
GO

CREATE TABLE [EmployeeBonusMart] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [Year] INT NOT NULL,
    [Month] INT NOT NULL,
    [StaffId] INT NOT NULL,
    [StaffName] VARCHAR(50) NOT NULL,
    [ExperienceYears] INT NOT NULL,
    [ExperienceBonusPercent] DECIMAL(5,2) NOT NULL,
    [RentalRevenue] DECIMAL(10,2) NOT NULL DEFAULT 0,
    [ServiceRevenue] DECIMAL(10,2) NOT NULL DEFAULT 0,
    [RentalBonus] DECIMAL(10,2) NOT NULL DEFAULT 0,
    [ServiceBonus] DECIMAL(10,2) NOT NULL DEFAULT 0,
    [TotalBonus] DECIMAL(10,2) NOT NULL DEFAULT 0,
    [LoadDate] DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_BonusMart_Staff FOREIGN KEY ([StaffId]) REFERENCES [Staff]([Id]),
    CONSTRAINT CHK_BonusMart_Month CHECK ([Month] >= 1 AND [Month] <= 12),
    CONSTRAINT CHK_BonusMart_Year CHECK ([Year] >= 2020 AND [Year] <= 2030)
);
GO

CREATE NONCLUSTERED INDEX IX_EmployeeBonusMart_YearMonth 
ON [EmployeeBonusMart] ([Year], [Month]) 
INCLUDE ([StaffId], [TotalBonus]);

CREATE NONCLUSTERED INDEX IX_EmployeeBonusMart_Staff 
ON [EmployeeBonusMart] ([StaffId], [Year], [Month]);
GO

PRINT '✅ Витрина данных EmployeeBonusMart создана';