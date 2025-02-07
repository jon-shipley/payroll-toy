-- Employees table
CREATE TABLE Employees (
    employeeId SERIAL PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hireDate DATE NOT NULL,
    terminationDate DATE,
    taxId VARCHAR(20) NOT NULL
);

-- Departments table
CREATE TABLE Departments (
    departmentId SERIAL PRIMARY KEY,
    departmentName VARCHAR(100) NOT NULL,
    costCenter VARCHAR(20) NOT NULL
);

-- Positions table
CREATE TABLE Positions (
    positionId SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    payGrade VARCHAR(10) NOT NULL,
    isExempt BOOLEAN NOT NULL
);

-- Employee positions table
CREATE TABLE EmployeePositions (
    employeePositionId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    positionId INTEGER NOT NULL,
    departmentId INTEGER NOT NULL,
    managerId INTEGER,
    isPrimaryPosition BOOLEAN NOT NULL DEFAULT false,
    effectiveDate DATE NOT NULL,
    endDate DATE,
    hourlyRate NUMERIC(10,2),
    annualSalary NUMERIC(12,2),
    FOREIGN KEY (employeeId) REFERENCES Employees(employeeId),
    FOREIGN KEY (positionId) REFERENCES Positions(positionId),
    FOREIGN KEY (departmentId) REFERENCES Departments(departmentId),
    FOREIGN KEY (managerId) REFERENCES Employees(employeeId)
);

-- Pay periods table
CREATE TABLE PayPeriods (
    payPeriodId SERIAL PRIMARY KEY,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    payDate DATE NOT NULL,
    periodType VARCHAR(20) NOT NULL
);

-- Time entries table
CREATE TABLE TimeEntries (
    timeEntryId SERIAL PRIMARY KEY,
    employeePositionId INTEGER NOT NULL,
    payPeriodId INTEGER NOT NULL,
    workDate DATE NOT NULL,
    hoursWorked NUMERIC(5,2) NOT NULL,
    overtimeHours NUMERIC(5,2) DEFAULT 0,
    FOREIGN KEY (employeePositionId) REFERENCES EmployeePositions(employeePositionId),
    FOREIGN KEY (payPeriodId) REFERENCES PayPeriods(payPeriodId)
);

-- Pension providers table
CREATE TABLE PensionProviders (
    providerId SERIAL PRIMARY KEY,
    providerName VARCHAR(100) NOT NULL,
    providerCode VARCHAR(50) NOT NULL,
    contactEmail VARCHAR(100),
    contactPhone VARCHAR(20),
    reportingFrequency VARCHAR(20) NOT NULL
);

-- Pension plans table
CREATE TABLE PensionPlans (
    planId SERIAL PRIMARY KEY,
    providerId INTEGER NOT NULL,
    planName VARCHAR(100) NOT NULL,
    planReference VARCHAR(50) NOT NULL,
    minimumContributionPercentage NUMERIC(5,2),
    maximumContributionPercentage NUMERIC(5,2),
    employerMatchPercentage NUMERIC(5,2),
    employerMatchLimit NUMERIC(5,2),
    FOREIGN KEY (providerId) REFERENCES PensionProviders(providerId)
);

-- Employee pension enrollments table
CREATE TABLE EmployeePensionEnrollments (
    enrollmentId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    planId INTEGER NOT NULL,
    employeeContributionPercentage NUMERIC(5,2) NOT NULL,
    employerContributionPercentage NUMERIC(5,2) NOT NULL,
    enrollmentDate DATE NOT NULL,
    optOutDate DATE,
    salarySacrifice BOOLEAN NOT NULL DEFAULT false,
    FOREIGN KEY (employeeId) REFERENCES Employees(employeeId),
    FOREIGN KEY (planId) REFERENCES PensionPlans(planId)
);

-- Payroll records table
CREATE TABLE PayrollRecords (
    payrollRecordId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    payPeriodId INTEGER NOT NULL,
    grossPay NUMERIC(12,2) NOT NULL,
    netPay NUMERIC(12,2) NOT NULL,
    totalDeductions NUMERIC(12,2) NOT NULL,
    totalTaxes NUMERIC(12,2) NOT NULL,
    paymentMethod VARCHAR(20) NOT NULL,
    paymentStatus VARCHAR(20) NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES Employees(employeeId),
    FOREIGN KEY (payPeriodId) REFERENCES PayPeriods(payPeriodId)
);

-- Payroll details table
CREATE TABLE PayrollDetails (
    payrollDetailId SERIAL PRIMARY KEY,
    payrollRecordId INTEGER NOT NULL,
    employeePositionId INTEGER NOT NULL,
    earningType VARCHAR(50) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    hours NUMERIC(5,2),
    rate NUMERIC(10,2),
    pensionEligible BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (payrollRecordId) REFERENCES PayrollRecords(payrollRecordId),
    FOREIGN KEY (employeePositionId) REFERENCES EmployeePositions(employeePositionId)
);

-- Pension contributions table
CREATE TABLE PensionContributions (
    contributionId SERIAL PRIMARY KEY,
    enrollmentId INTEGER NOT NULL,
    payrollRecordId INTEGER NOT NULL,
    employeeContribution NUMERIC(10,2) NOT NULL,
    employerContribution NUMERIC(10,2) NOT NULL,
    contributionDate DATE NOT NULL,
    reportingStatus VARCHAR(20) NOT NULL,
    reportingReference VARCHAR(50),
    FOREIGN KEY (enrollmentId) REFERENCES EmployeePensionEnrollments(enrollmentId),
    FOREIGN KEY (payrollRecordId) REFERENCES PayrollRecords(payrollRecordId)
);

-- HR-specific tables follow the same conversion pattern
-- Employee personal details table
CREATE TABLE EmployeePersonalDetails (
    personalDetailsId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    dateOfBirth DATE NOT NULL,
    gender VARCHAR(20),
    maritalStatus VARCHAR(20),
    nationality VARCHAR(50),
    addressLine1 VARCHAR(100) NOT NULL,
    addressLine2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    stateProvince VARCHAR(50),
    postalCode VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL,
    homePhone VARCHAR(20),
    mobilePhone VARCHAR(20),
    emergencyContactName VARCHAR(100),
    emergencyContactPhone VARCHAR(20),
    FOREIGN KEY (employeeId) REFERENCES Employees(employeeId)
);


-- Tax codes table
CREATE TABLE taxCodes (
    taxCodeId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    taxCode VARCHAR(20) NOT NULL,
    effectiveFrom DATE NOT NULL,
    effectiveTo DATE,
    isActive BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (employeeId) REFERENCES Employees(employeeId) ON DELETE CASCADE
);

CREATE INDEX ix_taxCode_employee_active_date
ON taxCodes(employeeId, isActive, effectiveFrom);

-- Enable row-level security for sensitive tables
ALTER TABLE Employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE EmployeePersonalDetails ENABLE ROW LEVEL SECURITY;
ALTER TABLE PayrollRecords ENABLE ROW LEVEL SECURITY;
ALTER TABLE taxCodes ENABLE ROW LEVEL SECURITY;
