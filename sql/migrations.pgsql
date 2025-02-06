-- Employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    termination_date DATE,
    tax_id VARCHAR(20) NOT NULL
);

-- Departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    cost_center VARCHAR(20) NOT NULL
);

-- Positions table
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    pay_grade VARCHAR(10) NOT NULL,
    is_exempt BOOLEAN NOT NULL
);

-- Employee positions table
CREATE TABLE employee_positions (
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
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (position_id) REFERENCES positions(position_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Pay periods table
CREATE TABLE pay_periods (
    pay_period_id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    period_type VARCHAR(20) NOT NULL
);

-- Time entries table
CREATE TABLE time_entries (
    time_entry_id SERIAL PRIMARY KEY,
    employee_position_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    work_date DATE NOT NULL,
    hours_worked NUMERIC(5,2) NOT NULL,
    overtime_hours NUMERIC(5,2) DEFAULT 0,
    FOREIGN KEY (employee_position_id) REFERENCES employee_positions(employee_position_id),
    FOREIGN KEY (pay_period_id) REFERENCES pay_periods(pay_period_id)
);

-- Pension providers table
CREATE TABLE pension_providers (
    provider_id SERIAL PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    provider_code VARCHAR(50) NOT NULL,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    reporting_frequency VARCHAR(20) NOT NULL
);

-- Pension plans table
CREATE TABLE pension_plans (
    plan_id SERIAL PRIMARY KEY,
    provider_id INTEGER NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    plan_reference VARCHAR(50) NOT NULL,
    minimum_contribution_percentage NUMERIC(5,2),
    maximum_contribution_percentage NUMERIC(5,2),
    employer_match_percentage NUMERIC(5,2),
    employer_match_limit NUMERIC(5,2),
    FOREIGN KEY (provider_id) REFERENCES pension_providers(provider_id)
);

-- Employee pension enrollments table
CREATE TABLE employee_pension_enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,
    employee_contribution_percentage NUMERIC(5,2) NOT NULL,
    employer_contribution_percentage NUMERIC(5,2) NOT NULL,
    enrollment_date DATE NOT NULL,
    opt_out_date DATE,
    salary_sacrifice BOOLEAN NOT NULL DEFAULT false,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (plan_id) REFERENCES pension_plans(plan_id)
);

-- Payroll records table
CREATE TABLE payroll_records (
    payroll_record_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    pay_period_id INTEGER NOT NULL,
    gross_pay NUMERIC(12,2) NOT NULL,
    net_pay NUMERIC(12,2) NOT NULL,
    total_deductions NUMERIC(12,2) NOT NULL,
    total_taxes NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (pay_period_id) REFERENCES pay_periods(pay_period_id)
);

-- Payroll details table
CREATE TABLE payroll_details (
    payroll_detail_id SERIAL PRIMARY KEY,
    payroll_record_id INTEGER NOT NULL,
    employee_position_id INTEGER NOT NULL,
    earning_type VARCHAR(50) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    hours NUMERIC(5,2),
    rate NUMERIC(10,2),
    pension_eligible BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (payroll_record_id) REFERENCES payroll_records(payroll_record_id),
    FOREIGN KEY (employee_position_id) REFERENCES employee_positions(employee_position_id)
);

-- Pension contributions table
CREATE TABLE pension_contributions (
    contribution_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL,
    payroll_record_id INTEGER NOT NULL,
    employee_contribution NUMERIC(10,2) NOT NULL,
    employer_contribution NUMERIC(10,2) NOT NULL,
    contribution_date DATE NOT NULL,
    reporting_status VARCHAR(20) NOT NULL,
    reporting_reference VARCHAR(50),
    FOREIGN KEY (enrollment_id) REFERENCES employee_pension_enrollments(enrollment_id),
    FOREIGN KEY (payroll_record_id) REFERENCES payroll_records(payroll_record_id)
);

-- HR-specific tables follow the same conversion pattern
-- Employee personal details table
CREATE TABLE employee_personal_details (
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
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Additional HR tables (qualifications, training, etc.) would follow the same conversion pattern

-- Enable row-level security for sensitive tables
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_personal_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll_records ENABLE ROW LEVEL SECURITY;
