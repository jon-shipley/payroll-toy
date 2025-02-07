-- Employees table
CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    termination_date DATE,
    tax_id VARCHAR(20) NOT NULL
);

-- Departments table
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    cost_center VARCHAR(20) NOT NULL
);

-- Positions table
CREATE TABLE Positions (
    position_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    pay_grade VARCHAR(10) NOT NULL,
    is_exempt BOOLEAN NOT NULL
);

-- Employee positions table
CREATE TABLE EmployeePositions (
    employee_position_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    manager_id INTEGER,
    is_primary_position BOOLEAN NOT NULL DEFAULT false,
    effective_date DATE NOT NULL,
    end_date DATE,
    hourly_rate NUMERIC(10,2),
    annual_salary NUMERIC(12,2),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (position_id) REFERENCES Positions(position_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)
);

-- Pay periods table
CREATE TABLE PayPeriods (
    pay_period_id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    period_type VARCHAR(20) NOT NULL
);

-- Time entries table
CREATE TABLE TimeEntries (
    time_entry_id SERIAL PRIMARY KEY,
    employee_position_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    work_date DATE NOT NULL,
    hours_worked NUMERIC(5,2) NOT NULL,
    overtime_hours NUMERIC(5,2) DEFAULT 0,
    FOREIGN KEY (employee_position_id) REFERENCES EmployeePositions(employee_position_id),
    FOREIGN KEY (pay_period_id) REFERENCES PayPeriods(pay_period_id)
);

-- Pension providers table
CREATE TABLE PensionProviders (
    provider_id SERIAL PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    provider_code VARCHAR(50) NOT NULL,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    reporting_frequency VARCHAR(20) NOT NULL
);

-- Pension plans table
CREATE TABLE PensionPlans (
    plan_id SERIAL PRIMARY KEY,
    provider_id INTEGER NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    plan_reference VARCHAR(50) NOT NULL,
    minimum_contribution_percentage NUMERIC(5,2),
    maximum_contribution_percentage NUMERIC(5,2),
    employer_match_percentage NUMERIC(5,2),
    employer_match_limit NUMERIC(5,2),
    FOREIGN KEY (provider_id) REFERENCES PensionProviders(provider_id)
);

-- Employee pension enrollments table
CREATE TABLE EmployeePensionEnrollments (
    enrollment_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,
    employee_contribution_percentage NUMERIC(5,2) NOT NULL,
    employer_contribution_percentage NUMERIC(5,2) NOT NULL,
    enrollment_date DATE NOT NULL,
    opt_out_date DATE,
    salary_sacrifice BOOLEAN NOT NULL DEFAULT false,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (plan_id) REFERENCES PensionPlans(plan_id)
);

-- Payroll records table
CREATE TABLE PayrollRecords (
    payroll_record_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    gross_pay NUMERIC(12,2) NOT NULL,
    net_pay NUMERIC(12,2) NOT NULL,
    total_deductions NUMERIC(12,2) NOT NULL,
    total_taxes NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES PayPeriods(pay_period_id)
);

-- Payroll details table
CREATE TABLE PayrollDetails (
    payroll_detail_id SERIAL PRIMARY KEY,
    payroll_record_id INTEGER NOT NULL,
    employee_position_id INTEGER NOT NULL,
    earning_type VARCHAR(50) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    hours NUMERIC(5,2),
    rate NUMERIC(10,2),
    pension_eligible BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (payroll_record_id) REFERENCES PayrollRecords(payroll_record_id),
    FOREIGN KEY (employee_position_id) REFERENCES EmployeePositions(employee_position_id)
);

-- Pension contributions table
CREATE TABLE PensionContributions (
    contribution_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL,
    payroll_record_id INTEGER NOT NULL,
    employee_contribution NUMERIC(10,2) NOT NULL,
    employer_contribution NUMERIC(10,2) NOT NULL,
    contribution_date DATE NOT NULL,
    reporting_status VARCHAR(20) NOT NULL,
    reporting_reference VARCHAR(50),
    FOREIGN KEY (enrollment_id) REFERENCES EmployeePensionEnrollments(enrollment_id),
    FOREIGN KEY (payroll_record_id) REFERENCES PayrollRecords(payroll_record_id)
);

-- HR-specific tables follow the same conversion pattern
-- Employee personal details table
CREATE TABLE EmployeePersonalDetails (
    personal_details_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20),
    marital_status VARCHAR(20),
    nationality VARCHAR(50),
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state_province VARCHAR(50),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL,
    home_phone VARCHAR(20),
    mobile_phone VARCHAR(20),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);


-- Tax codes table
CREATE TABLE taxCodes (
    taxCodeId SERIAL PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    taxCode VARCHAR(20) NOT NULL,
    effectiveFrom DATE NOT NULL,
    effectiveTo DATE,
    isActive BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (employeeId) REFERENCES Employees(employee_id) ON DELETE CASCADE
);

CREATE INDEX ix_taxCode_employee_active_date
ON taxCodes(employeeId, isActive, effectiveFrom);

-- Enable row-level security for sensitive tables
ALTER TABLE Employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE EmployeePersonalDetails ENABLE ROW LEVEL SECURITY;
ALTER TABLE PayrollRecords ENABLE ROW LEVEL SECURITY;
ALTER TABLE taxCodes ENABLE ROW LEVEL SECURITY;
