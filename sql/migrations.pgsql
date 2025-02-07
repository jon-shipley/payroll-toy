--
-- DB Naming rules:
-- - Tables are singular and start with a capital letter, e.g. Employee, Department, Position
-- - Columns are in camelCase: e.g. employeeId, departmentName, positionTitle
-- - Foreign keys are named constraints: E.g. FK_FromTableName_FromColumnName_ToTableName_ToColumnName
-- - Indexes are named IX_TableName_ColumnName
--

-- Employee table
CREATE TABLE Employee (
    employeeId SERIAL PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hireDate DATE NOT NULL,
    terminationDate DATE,
    taxId VARCHAR(20) NOT NULL
);

-- Department table
CREATE TABLE Department (
    departmentId SERIAL PRIMARY KEY,
    departmentName VARCHAR(100) NOT NULL,
    costCenter VARCHAR(20) NOT NULL
);

-- Position table
CREATE TABLE Position (
    positionId SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    payGrade VARCHAR(10) NOT NULL,
    isExempt BOOLEAN NOT NULL
);

-- EmployeePosition table
CREATE TABLE EmployeePosition (
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
    CONSTRAINT FK_EmployeePosition_employeeId_Employee_employeeId FOREIGN KEY (employeeId) REFERENCES Employee(employeeId),
    CONSTRAINT FK_EmployeePosition_positionId_Position_positionId FOREIGN KEY (positionId) REFERENCES Position(positionId),
    CONSTRAINT FK_EmployeePosition_departmentId_Department_departmentId FOREIGN KEY (departmentId) REFERENCES Department(departmentId),
    CONSTRAINT FK_EmployeePosition_managerId_Employee_employeeId FOREIGN KEY (managerId) REFERENCES Employee(employeeId)
);

-- PayPeriod table
CREATE TABLE PayPeriod (
    payPeriodId SERIAL PRIMARY KEY,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    payDate DATE NOT NULL,
    periodType VARCHAR(20) NOT NULL
);

-- TimeEntry table
CREATE TABLE TimeEntry (
    timeEntryId SERIAL PRIMARY KEY,
    employeePositionId INTEGER NOT NULL,
    payPeriodId INTEGER NOT NULL,
    workDate DATE NOT NULL,
    hoursWorked NUMERIC(5,2) NOT NULL,
    overtimeHours NUMERIC(5,2) DEFAULT 0,
    CONSTRAINT FK_TimeEntry_employeePositionId_EmployeePosition_employeePositionId FOREIGN KEY (employeePositionId) REFERENCES EmployeePosition(employeePositionId),
    CONSTRAINT FK_TimeEntry_payPeriodId_PayPeriod_payPeriodId FOREIGN KEY (payPeriodId) REFERENCES PayPeriod(payPeriodId)
);

-- PensionProvider table
CREATE TABLE PensionProvider (
    providerId SERIAL PRIMARY KEY,
    providerName VARCHAR(100) NOT NULL,
    providerCode VARCHAR(50) NOT NULL,
    contactEmail VARCHAR(100),
    contactPhone VARCHAR(20),
    reportingFrequency VARCHAR(20) NOT NULL
);

-- PensionPlan table
CREATE TABLE PensionPlan (
    planId SERIAL PRIMARY KEY,
    providerId INTEGER NOT NULL,
    planName VARCHAR(100) NOT NULL,
    planReference VARCHAR(50) NOT NULL,
    minimumContributionPercentage NUMERIC(5,2),
    maximumContributionPercentage NUMERIC(5,2),
    employerMatchPercentage NUMERIC(5,2),
    employerMatchLimit NUMERIC(5,2),
    CONSTRAINT FK_PensionPlan_providerId_PensionProvider_providerId FOREIGN KEY (providerId) REFERENCES PensionProvider(providerId)
);

-- EmployeePensionEnrollment table
CREATE TABLE EmployeePensionEnrollment (
    enrollmentId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    planId INTEGER NOT NULL,
    employeeContributionPercentage NUMERIC(5,2) NOT NULL,
    employerContributionPercentage NUMERIC(5,2) NOT NULL,
    enrollmentDate DATE NOT NULL,
    optOutDate DATE,
    salarySacrifice BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT FK_EmployeePensionEnrollment_employeeId_Employee_employeeId FOREIGN KEY (employeeId) REFERENCES Employee(employeeId),
    CONSTRAINT FK_EmployeePensionEnrollment_planId_PensionPlan_planId FOREIGN KEY (planId) REFERENCES PensionPlan(planId)
);

-- PayrollRecord table
CREATE TABLE PayrollRecord (
    payrollRecordId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    payPeriodId INTEGER NOT NULL,
    grossPay NUMERIC(12,2) NOT NULL,
    netPay NUMERIC(12,2) NOT NULL,
    totalDeductions NUMERIC(12,2) NOT NULL,
    totalTaxes NUMERIC(12,2) NOT NULL,
    paymentMethod VARCHAR(20) NOT NULL,
    paymentStatus VARCHAR(20) NOT NULL,
    CONSTRAINT FK_PayrollRecord_employeeId_Employee_employeeId FOREIGN KEY (employeeId) REFERENCES Employee(employeeId),
    CONSTRAINT FK_PayrollRecord_payPeriodId_PayPeriod_payPeriodId FOREIGN KEY (payPeriodId) REFERENCES PayPeriod(payPeriodId)
);

-- PayrollDetail table
CREATE TABLE PayrollDetail (
    payrollDetailId SERIAL PRIMARY KEY,
    payrollRecordId INTEGER NOT NULL,
    employeePositionId INTEGER NOT NULL,
    earningType VARCHAR(50) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    hours NUMERIC(5,2),
    rate NUMERIC(10,2),
    pensionEligible BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT FK_PayrollDetail_payrollRecordId_PayrollRecord_payrollRecordId FOREIGN KEY (payrollRecordId) REFERENCES PayrollRecord(payrollRecordId),
    CONSTRAINT FK_PayrollDetail_employeePositionId_EmployeePosition_employeePositionId FOREIGN KEY (employeePositionId) REFERENCES EmployeePosition(employeePositionId)
);

-- PensionContribution table
CREATE TABLE PensionContribution (
    contributionId SERIAL PRIMARY KEY,
    enrollmentId INTEGER NOT NULL,
    payrollRecordId INTEGER NOT NULL,
    employeeContribution NUMERIC(10,2) NOT NULL,
    employerContribution NUMERIC(10,2) NOT NULL,
    contributionDate DATE NOT NULL,
    reportingStatus VARCHAR(20) NOT NULL,
    reportingReference VARCHAR(50),
    CONSTRAINT FK_PensionContribution_enrollmentId_EmployeePensionEnrollment_enrollmentId FOREIGN KEY (enrollmentId) REFERENCES EmployeePensionEnrollment(enrollmentId),
    CONSTRAINT FK_PensionContribution_payrollRecordId_PayrollRecord_payrollRecordId FOREIGN KEY (payrollRecordId) REFERENCES PayrollRecord(payrollRecordId)
);

-- EmployeePersonalDetail table
CREATE TABLE EmployeePersonalDetail (
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
    CONSTRAINT FK_EmployeePersonalDetail_employeeId_Employee_employeeId FOREIGN KEY (employeeId) REFERENCES Employee(employeeId)
);

-- TaxCode table
CREATE TABLE TaxCode (
    taxCodeId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    taxCode VARCHAR(20) NOT NULL,
    effectiveFrom DATE NOT NULL,
    effectiveTo DATE,
    isActive BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT FK_TaxCode_employeeId_Employee_employeeId FOREIGN KEY (employeeId) REFERENCES Employee(employeeId) ON DELETE CASCADE
);

CREATE INDEX IX_TaxCode_employeeId_isActive_effectiveFrom
ON TaxCode(employeeId, isActive, effectiveFrom);

-- Enable row-level security for sensitive tables
ALTER TABLE Employee ENABLE ROW LEVEL SECURITY;
ALTER TABLE EmployeePersonalDetail ENABLE ROW LEVEL SECURITY;
ALTER TABLE PayrollRecord ENABLE ROW LEVEL SECURITY;
ALTER TABLE TaxCode ENABLE ROW LEVEL SECURITY;
