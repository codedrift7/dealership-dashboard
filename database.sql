-- DROP DATABASE Dealership;
CREATE DATABASE Dealership;
USE Dealership;

-- ENTITY TABLE: Buyer
CREATE TABLE Buyer (
	Customer_ID VARCHAR(50) NOT NULL,
	FirstName VARCHAR(100) NOT NULL,
	LastName VARCHAR(100),
	BirthDate DATE,
	Address VARCHAR(255),
	ZipCode VARCHAR(10),
	City VARCHAR(100),
	State CHAR(2),
	Occupation VARCHAR(100),
	PRIMARY KEY (Customer_ID)
);

-- RELATIONSHIP TABLE: BuyerPhone
CREATE TABLE BuyerPhone (
	Customer_ID VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	PRIMARY KEY (Customer_ID, PhoneNumber),
	FOREIGN KEY (Customer_ID) REFERENCES Buyer(Customer_ID)
	ON DELETE CASCADE
);

-- ENTITY TABLE: Job
CREATE TABLE Job (
	Job_ID VARCHAR(50) NOT NULL,
	JobDesc VARCHAR(100),
	Salary DECIMAL(10,2),
	PRIMARY KEY (Job_ID)
);

-- ENTITY TABLE: Workshop
CREATE TABLE Workshop (
	Workshop_ID VARCHAR(50),
	Service VARCHAR(100),
	ServicePrice DECIMAL(10,2),
	PRIMARY KEY (Workshop_ID)
);

-- ENTITY TABLE: Sparepart
CREATE TABLE Sparepart (
	Sparepart_ID VARCHAR(50) NOT NULL,
	Price DECIMAL(10,2),
	BrandSP VARCHAR(100),
	DescSP VARCHAR(100),
	StockQuantity INT,
	Workshop_ID VARCHAR(50),
	PRIMARY KEY (Sparepart_ID),
	FOREIGN KEY (Workshop_ID) REFERENCES Workshop(Workshop_ID)
);

-- ENTITY TABLE: Car
CREATE TABLE Car (
    SerialNumber VARCHAR(50) NOT NULL,
    Brand VARCHAR(100),
    CarName VARCHAR(100),
    Model VARCHAR(100),
    ManufacturingYear INT,
    SalePrice DECIMAL(12,2),
    StockQuantity INT,
    PRIMARY KEY (SerialNumber)
);

CREATE INDEX idx_car_brand ON Car(Brand);

-- RELATIONSHIP TABLE: CarColor
CREATE TABLE CarColor (
    SerialNumber VARCHAR(50) NOT NULL,
    CarColor VARCHAR(50),
    PRIMARY KEY (SerialNumber, CarColor),
    FOREIGN KEY (SerialNumber) REFERENCES Car(SerialNumber)
    ON DELETE CASCADE
);

-- RELATIONSHIP TABLE: Modification
CREATE TABLE Modification (
    SerialNumber VARCHAR(50),
    ModificationType VARCHAR(100),
    ModificationPrice DECIMAL(10,2),
    ModificationDesc VARCHAR(100),
    PRIMARY KEY (SerialNumber, ModificationDesc),
    FOREIGN KEY (SerialNumber) REFERENCES Car(SerialNumber)
    ON DELETE CASCADE
);

-- ENTITY TABLE: Company
CREATE TABLE Company (
    Company_ID VARCHAR(50) NOT NULL,
    CompanyName VARCHAR(100),
    City VARCHAR(100),
    State CHAR(2),
    Address VARCHAR(255),
    ZipCode VARCHAR(10),
    PhoneNumber VARCHAR(20),
    Email VARCHAR(255),
    Headquarters_ID VARCHAR(50) NULL,
    Workshop_ID VARCHAR(50) NOT NULL,
    PRIMARY KEY (Company_ID),
    FOREIGN KEY (Headquarters_ID) REFERENCES Company(Company_ID),
    FOREIGN KEY (Workshop_ID) REFERENCES Workshop(Workshop_ID),
    CONSTRAINT CHK_Company_Not_Own_HQ CHECK (Headquarters_ID <> Company_ID)
);

-- RELATIONSHIP TABLE: CarProvision
CREATE TABLE CarProvision (
    Provision_ID VARCHAR(50) NOT NULL,
    Company_ID VARCHAR(50),
    SerialNumber VARCHAR(50),
    ProcessDate DATE,
    TotalPrice DECIMAL(12,2),

    PRIMARY KEY (Provision_ID),

    FOREIGN KEY (Company_ID)
        REFERENCES Company(Company_ID),

    FOREIGN KEY (SerialNumber)
        REFERENCES Car(SerialNumber)
);

-- ENTITY TABLE: Employee
CREATE TABLE Employee (
    Employee_ID VARCHAR(50) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100),
    Email VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State CHAR(2) NOT NULL,
    ZipCode VARCHAR(10) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Job_ID VARCHAR(50) NOT NULL,
    Manager_ID VARCHAR(50),
    Company_ID VARCHAR(50) NOT NULL,
    PRIMARY KEY (Employee_ID),
    FOREIGN KEY (Job_ID) REFERENCES Job(Job_ID),
    FOREIGN KEY (Manager_ID) REFERENCES Employee(Employee_ID),
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID)
);

-- RELATIONSHIP TABLE: CarOrder
CREATE TABLE CarOrder (
    Order_ID VARCHAR(50) NOT NULL,
    Customer_ID VARCHAR(50) NOT NULL,
    Employee_ID VARCHAR(50) NOT NULL,
    SerialNumber VARCHAR(50) NOT NULL,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(20) NOT NULL,
    DownPayment DECIMAL(12,2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Buyer(Customer_ID),
	FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
	FOREIGN KEY (SerialNumber) REFERENCES Car(SerialNumber),
    
    CONSTRAINT CHK_OrderStatus CHECK (
        OrderStatus IN ('Pending', 'Confirmed', 'Delivered')
    )
);

CREATE INDEX idx_carorder_status ON CarOrder(OrderStatus);
CREATE INDEX idx_carorder_orderdate ON CarOrder(OrderDate);

-- RELATIONSHIP TABLE: EmployeePhone
CREATE TABLE EmployeePhone (
    Employee_ID VARCHAR(50),
    PhoneNumber VARCHAR(20),
    PRIMARY KEY (Employee_ID, PhoneNumber),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
    ON DELETE CASCADE
);

-- RELATIONSHIP TABLE: EmployeeFamily
CREATE TABLE EmployeeFamily (
    Employee_ID VARCHAR(50),
    Name VARCHAR(100),
    InsuranceType VARCHAR(100),
    BirthDate DATE,
    Gender CHAR(1),
    PRIMARY KEY (Employee_ID, Name),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
    ON DELETE CASCADE
);

-- ENTITY TABLE: UserAccount (Authentication)
CREATE TABLE UserAccount (
    Account_ID VARCHAR(50) NOT NULL,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL, 
    Role VARCHAR(50) NOT NULL,          
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    LastLogin TIMESTAMP NULL,
    Employee_ID VARCHAR(50) NULL UNIQUE,
    Customer_ID VARCHAR(50) NULL UNIQUE,

    PRIMARY KEY (Account_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE,
    FOREIGN KEY (Customer_ID) REFERENCES Buyer(Customer_ID) ON DELETE CASCADE,

    CONSTRAINT CHK_Account_Owner CHECK (
        (Employee_ID IS NOT NULL AND Customer_ID IS NULL) OR
        (Employee_ID IS NULL AND Customer_ID IS NOT NULL) OR
        (Employee_ID IS NULL AND Customer_ID IS NULL)
    ),
    
    CONSTRAINT CHK_Account_Role CHECK (
        Role IN ('Customer', 'Owner', 'Manager', 'Sales', 'Mechanic',
                 'HR', 'IT Support', 'Accountant', 'Admin')
    )
);

-- ENTITY TABLE: UserSession (Session Management)
CREATE TABLE UserSession (
    Session_ID VARCHAR(255) NOT NULL,  
    Account_ID VARCHAR(50) NOT NULL,
    IPAddress VARCHAR(45),              
    UserAgent VARCHAR(255),             
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ExpiresAt TIMESTAMP NOT NULL,
    
    PRIMARY KEY (Session_ID),
    FOREIGN KEY (Account_ID) REFERENCES UserAccount(Account_ID) ON DELETE CASCADE
);

-- =========================================================
-- Populating Tables
-- =========================================================

INSERT INTO Buyer VALUES
('C001', 'Patricia', 'Mitchell', '2000-09-03', '4606 Highland Dr', '60614', 'Chicago', 'IL', 'Developer'),
('C002', 'Richard', 'Baker', '2000-06-04', '9035 Cedar Way', '90025', 'Los Angeles', 'CA', 'CEO'),
('C003', 'William', 'Wilson', '2000-01-10', '3911 Jefferson St', '75201', 'Dallas', 'TX', 'Staff'),
('C004', 'Brenda', 'Clark', '1988-05-20', '3711 Chestnut Ln', '75201', 'Dallas', 'TX', 'Manager'),
('C005', 'Mary', 'Carter', '1998-07-17', '2715 Ridge Way', '33131', 'Miami', 'FL', 'Designer'),
('C006', 'Charles', 'Wilson', '1995-12-12', '5614 Elm Ave', '80202', 'Denver', 'CO', 'Analyst'),
('C007', 'Ronald', 'Thompson', '1996-10-04', '9991 Sunset St', '78701', 'Austin', 'TX', 'Engineer'),
('C008', 'Brenda', NULL, '1998-03-08', '6301 Cedar Ln', '76102', 'Fort Worth', 'TX', 'Network Admin'),
('C009', 'Christine', 'White', '1994-08-27', '9559 Lincoln Ave', '77002', 'Houston', 'TX', 'Mobile Dev'),
('C010', 'Steven', 'Roberts', '1994-03-23', '4841 Cedar Dr', '77002', 'Houston', 'TX', 'Data Scientist'),
('C011', 'Deborah', 'Moore', '1997-02-15', '7528 Church Ct', '33131', 'Miami', 'FL', 'Software Engineer'),
('C012', 'Ronald', 'Wilson', '1993-08-12', '4474 Ridge Ave', '76102', 'Fort Worth', 'TX', 'Architect'),
('C013', 'Nancy', 'Wright', '1990-11-21', '4110 Washington Pkwy', '78701', 'Austin', 'TX', 'Manager'),
('C014', 'Scott', 'Anderson', '1998-04-03', '5413 Magnolia St', '78701', 'Austin', 'TX', 'UI Designer'),
('C015', 'Robert', 'Lee', '1992-05-18', '6672 Sunset Ave', '85003', 'Phoenix', 'AZ', 'Business Analyst'),
('C016', 'Brandon', 'Rivera', '1995-06-28', '5255 Lincoln Pkwy', '60614', 'Chicago', 'IL', 'Consultant'),
('C017', 'Nicholas', 'Martinez', '1999-01-10', '4439 Pine Dr', '21201', 'Baltimore', 'MD', 'Teacher'),
('C018', 'Brenda', 'Taylor', '1994-07-17', '9677 Birch Way', '75201', 'Dallas', 'TX', 'Entrepreneur'),
('C019', 'Thomas', 'Allen', '1996-09-24', '8185 Cedar St', '10001', 'New York', 'NY', 'Doctor'),
('C020', 'Karen', 'Green', '1991-12-05', '2721 Lakeview Way', '77002', 'Houston', 'TX', 'Engineer'),
('C021', 'Deborah', 'Harris', '1992-02-14', '9863 Chestnut Ln', '10001', 'New York', 'NY', 'Director'),
('C022', 'Mary', 'Baker', '1995-11-30', '1976 Spring Ln', '90025', 'Los Angeles', 'CA', 'VP'),
('C023', 'Carol', 'Davis', '1989-08-08', '4908 Birch Blvd', '33131', 'Miami', 'FL', 'Manager'),
('C024', 'Andrew', 'Allen', '1997-12-25', '3027 Jefferson Ave', '75201', 'Dallas', 'TX', 'Architect'),
('C025', 'Donna', 'Green', '1990-01-19', '8417 Main Dr', '60614', 'Chicago', 'IL', 'Pilot'),
('C026', 'Daniel', 'Wright', '1993-09-09', '8789 Orchard St', '90025', 'Los Angeles', 'CA', 'Accountant'),
('C027', 'Angela', 'Johnson', '1985-05-15', '1932 Orchard Ct', '33131', 'Miami', 'FL', 'Investor'),
('C028', 'Donna', NULL, '1998-04-21', '1049 Highland Ave', '78701', 'Austin', 'TX', 'Content Creator'),
('C029', 'Stephen', 'Jones', '1988-10-10', '8827 Forest Blvd', '10001', 'New York', 'NY', 'Executive'),
('C030', 'Eric', 'Scott', '1996-03-31', '2805 Sunset Way', '60614', 'Chicago', 'IL', 'Pharmacist'),
('C031', 'Brenda', 'Carter', '1994-06-12', '3395 Ridge Ln', '76102', 'Fort Worth', 'TX', 'Musician'),
('C032', 'Jason', 'Lewis', '1999-07-22', '8579 Chestnut Ave', '77002', 'Houston', 'TX', 'Model'),
('C033', 'David', 'Perez', '1991-02-28', '444 Broadway Dr', '85003', 'Phoenix', 'AZ', 'Consultant'),
('C034', 'Mary', 'Jones', '1995-05-05', '1064 Highland Ave', '90025', 'Los Angeles', 'CA', 'Lawyer'),
('C035', 'Carol', 'Jones', '1992-11-11', '8523 Highland Ln', '77002', 'Houston', 'TX', 'Producer'),
('C036', 'Betty', 'Wright', '1994-08-17', '2267 Meadow Pkwy', '78701', 'Austin', 'TX', 'Host'),
('C037', 'Eric', 'Clark', '1997-09-30', '3219 Elm Ave', '75201', 'Dallas', 'TX', 'Director'),
('C038', 'Amanda', 'Ramirez', '1990-01-01', '6835 Chestnut St', '21201', 'Baltimore', 'MD', 'Singer'),
('C039', 'Susan', 'Brown', '1987-12-12', '6696 Meadow Ct', '10001', 'New York', 'NY', 'Comedian'),
('C040', 'Susan', 'Thomas', '1985-03-03', '3239 Lincoln Pkwy', '78701', 'Austin', 'TX', 'Actor');

-- multivalued
INSERT INTO BuyerPhone VALUES
('C001', '(312) 555-0100'),
('C001', '(312) 555-0101'),
('C002', '(310) 555-0100'),
('C003', '(214) 555-0100'),
('C006', '(303) 555-0100'),
('C006', '(303) 555-0101'),
('C007', '(512) 555-0100'),
('C008', '(817) 555-0100'),
('C011', '(305) 555-0100'),
('C012', '(817) 555-0101'),
('C013', '(512) 555-0101'),
('C014', '(512) 555-0102'),
('C015', '(602) 555-0100'),
('C016', '(312) 555-0102'),
('C017', '(410) 555-0100'),
('C018', '(214) 555-0101'),
('C019', '(212) 555-0100'),
('C020', '(713) 555-0100'),
('C021', '(212) 555-0101'),
('C021', '(212) 555-0102'),
('C022', '(310) 555-0101'),
('C023', '(305) 555-0101'),
('C026', '(310) 555-0102'),
('C026', '(310) 555-0103'),
('C027', '(305) 555-0102'),
('C028', '(512) 555-0103'),
('C031', '(817) 555-0102'),
('C032', '(713) 555-0101'),
('C033', '(602) 555-0101'),
('C034', '(310) 555-0104'),
('C035', '(713) 555-0102'),
('C036', '(512) 555-0104'),
('C037', '(214) 555-0102'),
('C038', '(410) 555-0101'),
('C039', '(212) 555-0103'),
('C040', '(512) 555-0105');

INSERT INTO Job VALUES
('J001', 'Owner', 185000.00),
('J002', 'Manager', 78000.00),
('J003', 'Sales', 52000.00),
('J004', 'Mechanic', 58000.00),
('J005', 'Intern', 34000.00),
('J006', 'HR', 68000.00),
('J007', 'IT Support', 64000.00),
('J008', 'Accountant', 72000.00),
('J009', 'Security', 42000.00),
('J010', 'Office Assistant', 38000.00),
('J011', 'Senior Technician', 95000.00),
('J012', 'Marketing Director', 92000.00),
('J013', 'Legal Counsel', 110000.00),
('J014', 'Driver', 40000.00),
('J015', 'Auditor', 75000.00),
('J016', 'Branch Manager', 105000.00),
('J017', 'Warehouse Staff', 42000.00),
('J018', 'PR Specialist', 62000.00),
('J019', 'Trainer', 66000.00),
('J020', 'Receptionist', 38000.00);

INSERT INTO Workshop VALUES
('W001', 'Engine Service', 230.00),
('W002', 'Tire Service', 70.00),
('W003', 'Car Wash', 15.00),
('W004', 'Body Repair', 330.00),
('W005', 'Electrical Service', 130.00),
('W006', 'Interior Custom', 200.00),
('W007', 'Detailing Center', 100.00),
('W008', 'Audio Custom', 270.00),
('W009', 'Suspension Tuning', 230.00),
('W010', 'Glass Replacement', 130.00),
('W011', 'AC Maintenance', 80.00),
('W012', 'ECU Remapping', 300.00);

INSERT INTO Sparepart VALUES
('S001', 15.00, 'Brembo', 'Brake Caliper', 50, 'W001'),
('S002', 25.00, 'K-Sports', 'Brake Caliper', 25, 'W001'),
('S003', 15.00, 'Michelin', 'R17 Sport Tire', 5, 'W002'),
('S004', 5.00, 'Service', 'Wheel Alignment', 1, 'W002'),
('S005', 25.00, 'HKS', 'Racing Exhaust', 5, 'W003'),
('S006', 180.00, 'Cadillac', 'Spoiler Wing', 2, 'W004'),
('S007', 850.00, 'Cadillac', 'Twin Turbo V8', 2, 'W005'),
('S008', 0.00, 'M3', 'Car Wash', 1, 'W006'),
('S009', 35.00, 'Meguiars', 'Ceramic Wax', 30, 'W007'),
('S010', 80.00, 'Pioneer', 'Subwoofer', 15, 'W008'),
('S011', 550.00, 'Ohlins', 'Coilover Set', 8, 'W009'),
('S012', 200.00, 'Carglass', 'Windshield', 10, 'W010'),
('S013', 30.00, 'Denso', 'AC Compressor', 20, 'W011'),
('S014', 100.00, 'Hondata', 'ECU Flash Module', 5, 'W012'),
('S015', 20.00, 'JBL', 'Door Speakers', 25, 'W008'),
('S016', 500.00, 'Tein', 'Lowering Springs', 12, 'W009');

INSERT INTO Car VALUES
('V001', 'Ferrari', '488', 'Supercar', 2015, 1000000.00, 1),
('V002', 'Toyota', 'Supra', 'Sportcar', 2020, 80000.00, 2),
('V003', 'BMW', 'M4', 'Sportcar', 2019, 133500.00, 1),
('V004', 'Honda', 'Civic', 'Sedan', 2018, 26700.00, 5),
('V005', 'Lamborghini', 'Huracan', 'Supercar', 2021, 233500.00, 1),
('V006', 'Audi', 'R8', 'Supercar', 2018, 180000.00, 1),
('V007', 'Mercedes', 'AMG GT', 'Sportcar', 2019, 193500.00, 2),
('V008', 'Mazda', 'MX-5', 'Sportcar', 2017, 40000.00, 3),
('V009', 'Porsche', '911', 'Sportcar', 2020, 213500.00, 1),
('V010', 'Nissan', 'GTR R35', 'Supercar', 2016, 120000.00, 2),
('V011', 'Aston Martin', 'Vantage', 'Sportcar', 2021, 300000.00, 1),
('V012', 'McLaren', '720S', 'Supercar', 2020, 600000.00, 1),
('V013', 'Chevrolet', 'Camaro', 'Sportcar', 2019, 100000.00, 3),
('V014', 'Ford', 'Mustang', 'Sportcar', 2021, 106500.00, 4),
('V015', 'Bugatti', 'Chiron', 'Hypercar', 2022, 4000000.00, 1),
('V016', 'Lexus', 'LC500', 'Sportcar', 2020, 213500.00, 2),
('V017', 'Subaru', 'WRX STI', 'Sedan', 2018, 60000.00, 5),
('V018', 'Mitsubishi', 'Evo X', 'Sedan', 2015, 56500.00, 3),
('V019', 'Koenigsegg', 'Jesko', 'Hypercar', 2021, 3667000.00, 1),
('V020', 'Pagani', 'Huayra', 'Hypercar', 2019, 3000000.00, 1),
('V021', 'Audi', 'R8', 'Supercar', 2019, 180000.00, 2),
('V022', 'BMW', 'M4', 'Executivecar', 2014, 133500.00, 5),
('V023', 'Bugatti', 'Bugatti Veyron EB 16.4', 'Supersport', 2019, 2200000.00, 1),
('V024', 'Chevrolet', 'Corvette Z06', 'Sportcar', 2000, 660000.00, 2),
('V025', 'Ferrari', '225 S', 'Sportcar', 1952, 348000.00, 1),
('V026', 'Pontiac', 'Firebird 400 Coupe', 'Musclecar', 1969, 34100.00, 2),
('V027', 'Ford', 'GT40', 'Sportcar', 2004, 1680000.00, 2),
('V028', 'Honda', 'CR-X', 'Sportcar', 1991, 6200.00, 5),
('V029', 'Honda', 'S2000', 'Sportcar', 2009, 33100.00, 3),
('V030', 'Mitsubishi', 'Lancer Evo 9', 'Sedan', 2002, 35500.00, 2),
('V031', 'Nissan', 'Silvia S15', 'Sedan', 1999, 11400.00, 4),
('V032', 'Nissan', 'GTR R35', 'Supercar', 2007, 93500.00, 3),
('V033', 'Jaguar', 'F-type', 'Sportcar', 2013, 200000.00, 2),
('V034', 'Koenigsegg', 'CCX', 'Sportcar', 2006, 4313000.00, 4),
('V035', 'Lotus', 'Exige', 'Sportcar', 2000, 76000.00, 3),
('V036', 'McLaren', '12C', 'Sportcar', 2011, 466500.00, 2),
('V037', 'Mercedes-Benz', 'CLK', 'Luxurycar', 1997, 34300.00, 2),
('V038', 'Mercedes-Benz', 'SLR McLaren', 'Supercar', 2003, 1353000.00, 3),
('V039', 'Morgan', 'Plus4', 'Classiccar', 1969, 74500.00, 2),
('V040', 'Pagani', 'Zonda', 'Sportcar', 1997, 1307000.00, 3);

INSERT INTO CarColor VALUES
('V004', 'Rallye Red'),
('V004', 'Aegean Blue'),
('V005', 'Verde Mantis'),
('V014', 'Race Red'),
('V014', 'Shadow Black'),
('V021', 'Nardo Grey'),
('V021', 'Daytona Grey'),
('V022', 'Alpine White'),
('V023', 'Bugatti Blue'),
('V024', 'Torch Red'),
('V024', 'Arctic White'),
('V025', 'Rosso Corsa'),
('V026', 'Firebird Gold'),
('V027', 'Gulf Blue'),
('V027', 'Gulf Orange'),
('V028', 'Championship White'),
('V029', 'Berlina Black'),
('V029', 'Formula Red'),
('V030', 'Rally Blue'),
('V031', 'Aztec Silver'),
('V032', 'Super Silver'),
('V033', 'British Racing Green'),
('V033', 'Jag Orange'),
('V034', 'Koenigsegg Green'),
('V035', 'Lotus Yellow'),
('V036', 'Volcano Orange'),
('V037', 'Iridium Silver'),
('V038', 'Sahara Silver'),
('V039', 'Morgan Green'),
('V040', 'Verde Zonda'),
('V040', 'Black Zonda');

INSERT INTO Modification VALUES
('V001', 'Bodykit', 650.00, 'Sport Bodykit'),
('V002', 'Exhaust', 170.00, 'Performance Exhaust'),
('V009', 'Vinyl', 330.00, 'Initial D Paint'),
('V001', 'Interior', 650.00, 'Luxury Seats'),
('V002', 'Engine', 3350.00, 'Performance Engine'),
('V005', 'Wheels', 650.00, 'Racing Wheels'),
('V006', 'Wheels', 3350.00, 'Special Wheels'),
('V007', 'Engine', 1650.00, 'Supercharged Engine'),
('V008', 'Engine', 1000.00, 'Drift Engine'),
('V010', 'Battery', 1650.00, 'Electric Battery'),
('V011', 'Interior', 1650.00, 'Bespoke Leather'),
('V012', 'Aerodynamics', 10000.00, 'Active Aero Wing'),
('V013', 'Wheels', 800.00, 'American Muscle Rims'),
('V014', 'Exhaust', 1200.00, 'Borla Exhaust'),
('V015', 'Engine', 33300.00, 'Quad Turbo Upgrade'),
('V017', 'Suspension', 2350.00, 'Rally Suspension'),
('V018', 'Engine', 3000.00, 'Forged Internals'),
('V019', 'Vinyl', 1000.00, 'Clear PPF Wrap'),
('V020', 'Exhaust', 20000.00, 'Titanium Custom Exhaust'),
('V016', 'Wheels', 1650.00, 'Forged Alloys');

INSERT INTO Company VALUES
('D001', 'Prestige Image Motorsports', 'Los Angeles', 'CA', '9273 Cypress Way', '90025', '(310) 555-0105', 'prestige@imports.com', NULL, 'W001'),
('D002', 'Astra Auto Group', 'New York', 'NY', '2632 Orchard Dr', '10001', '(212) 555-0116', 'astra@imports.com', 'D001', 'W002'),
('D003', 'Xpander Motors', 'Dallas', 'TX', '3000 Cypress Way, Suite 477', '75201', '(214) 555-0103', 'xpander@imports.com', 'D001', 'W004'),
('D004', 'Liberty Toyota', 'Austin', 'TX', '5542 Lakeview Way', '78701', '(512) 555-0109', 'toyota@imports.com', 'D001', 'W003'),
('D005', 'Corporate BMW Imports', 'Los Angeles', 'CA', '4165 Sunset Blvd', '90025', '(310) 555-0106', 'bmwcorpo@imports.com', 'D001', 'W005'),
('D006', 'Metro Motor Company', 'Chicago', 'IL', '1871 Willow St', '60614', '(312) 555-0103', 'oplet@imports.com', 'D001', 'W002'),
('D007', 'Heritage Brothers Motors', 'Nashville', 'TN', '3744 Lincoln Pkwy, Suite 216', '37203', '(615) 555-0101', 'candiku1@imports.com', 'D001', 'W006'),
('D008', 'Victory Automotive Group', 'New York', 'NY', '3752 Maple Dr, Suite 242', '10001', '(212) 555-0117', 'otojaya@imports.com', 'D001', 'W003'),
('D009', 'Prima Honda Motors', 'Chicago', 'IL', '1237 Forest Ln, Suite 360', '60614', '(312) 555-0104', 'hondaprima@imports.com', 'D001', 'W007'),
('D010', 'Stallion Motorcars', 'Los Angeles', 'CA', '6648 Spring Ct', '90025', '(310) 555-0107', 'ferrariid@imports.com', 'D001', 'W008'),
('D011', 'Banteng Auto Imports', 'Seattle', 'WA', '1989 Cypress Ln, Suite 235', '98101', '(206) 555-0101', 'lambo.sea@imports.com', 'D001', 'W009'),
('D012', 'Makmur Motor Company', 'Portland', 'OR', '726 Elm Way, Suite 260', '97201', '(503) 555-0100', 'makmur@imports.com', 'D002', 'W010'),
('D013', 'New Star Motors', 'Atlanta', 'GA', '7249 Main Ave, Suite 395', '30303', '(404) 555-0101', 'bintang.atl@imports.com', 'D003', 'W011'),
('D014', 'Hyper Auto Group', 'Honolulu', 'HI', '3214 Sunset St', '96813', '(808) 555-0104', 'hyper.hnl@imports.com', 'D001', 'W012'),
('D015', 'JDM Garage Motors', 'Austin', 'TX', '127 Jefferson Dr, Suite 135', '78701', '(512) 555-0110', 'jdm.aus@imports.com', 'D004', 'W007'),
('D016', 'Euro Classic Motors', 'Nashville', 'TN', '5509 Main Ct', '37203', '(615) 555-0102', 'euro.bna@imports.com', 'D005', 'W008');

INSERT INTO Employee VALUES
('E001', 'Matthew', 'Moore', 'mmoore@dealership.com', 'New York', 'NY', '10001', '7679 Highland Ave', 'J001', NULL, 'D001'),
('E002', 'Scott', 'Miller', 'smiller@dealership.com', 'New York', 'NY', '10001', '928 Church St', 'J002', 'E001', 'D002'),
('E003', 'Ashley', NULL, 'ashley@dealership.com', 'New York', 'NY', '10001', '6758 Franklin Pkwy', 'J003', 'E002', 'D003'),
('E004', 'Jeffrey', 'Brown', 'jbrown@dealership.com', 'New York', 'NY', '10001', '2797 Willow St', 'J004', 'E002', 'D003'),
('E005', 'Dorothy', 'Robinson', 'drobinson@dealership.com', 'Austin', 'TX', '78701', '4773 Birch Pkwy', 'J005', 'E002', 'D004'),
('E006', 'Kevin', 'Wilson', 'kwilson@dealership.com', 'New York', 'NY', '10001', '1058 Broadway St', 'J002', NULL, 'D003'),
('E007', 'Linda', 'Brown', 'lbrown@dealership.com', 'New York', 'NY', '10001', '9671 Franklin Blvd', 'J004', 'E006', 'D005'),
('E008', 'Jonathan', 'Garcia', 'jgarcia@dealership.com', 'Honolulu', 'HI', '96813', '3144 Cedar Ave', 'J002', NULL, 'D006'),
('E009', 'Ashley', 'Sanchez', 'asanchez@dealership.com', 'Honolulu', 'HI', '96813', '2064 Cypress Dr', 'J003', 'E008', 'D007'),
('E010', 'Jennifer', NULL, 'jennifer@dealership.com', 'Honolulu', 'HI', '96813', '1443 Birch Ct', 'J004', 'E008', 'D008'),
('E011', 'Betty', 'Nelson', 'bnelson@dealership.com', 'New York', 'NY', '10001', '5247 Highland Ln', 'J011', 'E001', 'D009'),
('E012', 'Brian', 'Robinson', 'brobinson@dealership.com', 'New York', 'NY', '10001', '5280 Orchard Ave', 'J012', 'E011', 'D010'),
('E013', 'Gregory', NULL, 'gregory@dealership.com', 'Seattle', 'WA', '98101', '1738 Cedar Dr', 'J013', 'E012', 'D011'),
('E014', 'Sarah', 'Thompson', 'sthompson@dealership.com', 'Portland', 'OR', '97201', '1227 Cypress Dr', 'J014', 'E012', 'D012'),
('E015', 'Daniel', 'Lewis', 'dlewis@dealership.com', 'Atlanta', 'GA', '30303', '9000 Ridge Ln', 'J015', 'E011', 'D013'),
('E016', 'Ruth', 'Smith', 'rsmith@dealership.com', 'Honolulu', 'HI', '96813', '9186 Riverside Ave', 'J016', NULL, 'D014'),
('E017', 'Sarah', 'Taylor', 'staylor@dealership.com', 'Austin', 'TX', '78701', '1991 Cypress Ave', 'J017', 'E016', 'D015'),
('E018', 'Karen', 'Moore', 'kmoore@dealership.com', 'Nashville', 'TN', '37203', '4716 Main Dr', 'J018', NULL, 'D016'),
('E019', 'Betty', 'Baker', 'bbaker@dealership.com', 'New York', 'NY', '10001', '4425 Jefferson Pkwy', 'J019', 'E011', 'D009'),
('E020', 'John', NULL, 'john@dealership.com', 'New York', 'NY', '10001', '7039 Magnolia Ln', 'J020', 'E012', 'D010');

INSERT INTO CarOrder
(Order_ID, Customer_ID, Employee_ID, SerialNumber,
 OrderDate, OrderStatus, DownPayment)
VALUES
('O001', 'C001', 'E003', 'V001', '2019-10-12', 'Delivered', 6700.00),
('O002', 'C002', 'E002', 'V002', '2019-04-26', 'Delivered', 3350.00),
('O003', 'C003', 'E004', 'V003', '2019-06-17', 'Delivered', NULL),
('O004', 'C004', 'E005', 'V004', '2019-05-09', 'Delivered', 23300.00),
('O005', 'C005', 'E003', 'V005', '2019-03-06', 'Delivered', 33300.00),
('O006', 'C006', 'E007', 'V006', '2019-06-01', 'Delivered', 13300.00),
('O007', 'C007', 'E006', 'V007', '2019-07-11', 'Pending', NULL),
('O008', 'C008', 'E009', 'V008', '2019-08-21', 'Delivered', 10000.00),
('O009', 'C009', 'E010', 'V009', '2019-09-30', 'Delivered', 20000.00),
('O010', 'C010', 'E008', 'V010', '2019-10-15', 'Confirmed', 30000.00),
('O011', 'C011', 'E003', 'V002', '2020-01-15', 'Delivered', 4000.00),
('O012', 'C012', 'E003', 'V004', '2020-02-12', 'Delivered', 5300.00),
('O013', 'C013', 'E002', 'V008', '2020-03-10', 'Delivered', 8000.00),
('O014', 'C014', 'E006', 'V007', '2020-04-08', 'Delivered', 16700.00),
('O015', 'C015', 'E009', 'V010', '2020-05-17', 'Delivered', 13300.00),
('O016', 'C016', 'E003', 'V005', '2020-06-11', 'Delivered', 33300.00),
('O017', 'C017', 'E002', 'V004', '2020-07-02', 'Delivered', 6700.00),
('O018', 'C018', 'E009', 'V002', '2020-07-19', 'Delivered', 3350.00),
('O019', 'C019', 'E010', 'V009', '2020-08-15', 'Delivered', 23300.00),
('O020', 'C020', 'E006', 'V008', '2020-09-04', 'Delivered', 10000.00),
('O021', 'C011', 'E003', 'V004', '2021-01-09', 'Delivered', 6700.00),
('O022', 'C012', 'E002', 'V007', '2021-02-11', 'Delivered', 16700.00),
('O023', 'C013', 'E009', 'V002', '2021-03-15', 'Delivered', 4000.00),
('O024', 'C014', 'E003', 'V005', '2021-04-01', 'Delivered', 36700.00),
('O025', 'C015', 'E010', 'V010', '2021-05-06', 'Delivered', 16700.00),
('O026', 'C016', 'E006', 'V008', '2021-06-18', 'Delivered', 10000.00),
('O027', 'C017', 'E003', 'V002', '2021-07-13', 'Delivered', 3350.00),
('O028', 'C018', 'E009', 'V004', '2021-08-22', 'Delivered', 6700.00),
('O029', 'C019', 'E002', 'V007', '2021-09-05', 'Pending', NULL),
('O030', 'C020', 'E010', 'V009', '2021-10-01', 'Confirmed', 20000.00),
('O031', 'C021', 'E011', 'V011', '2021-11-12', 'Delivered', 10000.00),
('O032', 'C022', 'E012', 'V012', '2021-11-20', 'Delivered', 13300.00),
('O033', 'C023', 'E013', 'V013', '2021-12-05', 'Delivered', 6700.00),
('O034', 'C024', 'E014', 'V014', '2022-01-15', 'Delivered', NULL),
('O035', 'C025', 'E015', 'V015', '2022-02-10', 'Delivered', 33300.00),
('O036', 'C026', 'E016', 'V016', '2022-03-01', 'Delivered', 16700.00),
('O037', 'C027', 'E017', 'V017', '2022-03-22', 'Pending', NULL),
('O038', 'C028', 'E018', 'V018', '2022-04-14', 'Delivered', 10000.00),
('O039', 'C029', 'E019', 'V019', '2022-05-18', 'Delivered', 26700.00),
('O040', 'C030', 'E020', 'V020', '2022-06-11', 'Confirmed', 23300.00),
('O041', 'C031', 'E011', 'V012', '2022-07-09', 'Delivered', 4000.00),
('O042', 'C032', 'E012', 'V014', '2022-08-05', 'Delivered', 5300.00),
('O043', 'C033', 'E013', 'V018', '2022-09-12', 'Delivered', 8000.00),
('O044', 'C034', 'E014', 'V017', '2022-10-01', 'Delivered', 16700.00),
('O045', 'C035', 'E015', 'V020', '2022-11-15', 'Delivered', 13300.00),
('O046', 'C036', 'E016', 'V015', '2022-12-10', 'Delivered', 33300.00),
('O047', 'C037', 'E017', 'V014', '2023-01-05', 'Delivered', 6700.00),
('O048', 'C038', 'E018', 'V012', '2023-02-14', 'Delivered', 3350.00),
('O049', 'C039', 'E019', 'V019', '2023-03-21', 'Delivered', 23300.00),
('O050', 'C040', 'E020', 'V018', '2023-04-11', 'Delivered', 10000.00),
('O051', 'C021', 'E012', 'V014', '2023-05-08', 'Delivered', 6700.00),
('O052', 'C022', 'E011', 'V017', '2023-06-03', 'Delivered', 16700.00),
('O053', 'C023', 'E015', 'V012', '2023-07-19', 'Delivered', 4000.00),
('O054', 'C024', 'E016', 'V015', '2023-08-25', 'Delivered', 36700.00),
('O055', 'C025', 'E018', 'V020', '2023-09-14', 'Delivered', 16700.00),
('O056', 'C026', 'E014', 'V018', '2023-10-22', 'Delivered', 10000.00),
('O057', 'C027', 'E013', 'V012', '2023-11-05', 'Delivered', 3350.00),
('O058', 'C028', 'E019', 'V014', '2023-12-01', 'Delivered', 6700.00),
('O059', 'C029', 'E011', 'V017', '2023-12-15', 'Pending', NULL),
('O060', 'C030', 'E020', 'V019', '2023-12-28', 'Confirmed', 20000.00);

/* The price does not include any modifications and applies to only one car */
INSERT INTO CarProvision VALUES
('P001', 'D001', 'V007', '2019-10-22', 66500.00),
('P002', 'D002', 'V002', '2019-03-07', 2200000.00),
('P003', 'D002', 'V005', '2019-05-02', 348000.00),
('P004', 'D003', 'V006', '2019-03-04', 56000.00),
('P005', 'D005', 'V004', '2019-03-04', 660000.00),
('P006', 'D007', 'V007', '2019-03-10', 82000.00),
('P007', 'D008', 'V009', '2019-10-10', 74500.00),
('P008', 'D006', 'V010', '2019-10-10', 93500.00),
('P009', 'D009', 'V017', '2020-01-15', 66500.00),
('P010', 'D010', 'V012', '2020-02-20', 2200000.00),
('P011', 'D011', 'V015', '2020-04-10', 348000.00),
('P012', 'D012', 'V016', '2020-06-05', 56000.00),
('P013', 'D013', 'V014', '2020-08-14', 660000.00),
('P014', 'D014', 'V017', '2020-10-25', 82000.00),
('P015', 'D015', 'V019', '2020-11-30', 74500.00),
('P016', 'D016', 'V020', '2020-12-12', 93500.00);

INSERT INTO EmployeePhone VALUES
('E001', '(212) 555-0104'),
('E001', '(212) 555-0105'),
('E002', '(212) 555-0106'),
('E003', '(212) 555-0107'),
('E004', '(212) 555-0108'),
('E005', '(512) 555-0106'),
('E005', '(512) 555-0107'),
('E008', '(808) 555-0100'),
('E006', '(212) 555-0109'),
('E007', '(212) 555-0110'),
('E009', '(808) 555-0101'),
('E010', '(808) 555-0102'),
('E011', '(212) 555-0111'),
('E012', '(212) 555-0112'),
('E012', '(212) 555-0113'),
('E015', '(404) 555-0100'),
('E016', '(808) 555-0103'),
('E017', '(512) 555-0108'),
('E013', '(206) 555-0100'),
('E018', '(615) 555-0100'),
('E019', '(212) 555-0114'),
('E020', '(212) 555-0115');

INSERT INTO EmployeeFamily VALUES
('E001', 'Robert Moore', 'Full Insurance', '1998-01-26', 'M'),
('E002', 'Timothy Miller', 'Partial Insurance', '1992-01-21', 'M'),
('E005', 'Thomas Robinson', 'Full Insurance', '1995-09-03', 'M'),
('E007', 'Andrew Brown', 'No Insurance', '1993-08-26', 'M'),
('E010', 'Sharon Scott', 'Full Insurance', '1993-02-01', 'F'),
('E008', 'Laura Garcia', 'Partial Insurance', '1978-01-23', 'F'),
('E004', 'James Brown', 'No Insurance', '1988-04-16', 'M'),
('E009', 'David Sanchez', 'Partial Insurance', '1999-05-22', 'M'),
('E010', 'Karen Wright', 'Partial Insurance', '1999-05-29', 'F'),
('E011', 'Jennifer Nelson', 'Full Insurance', '1995-10-12', 'F'),
('E012', 'Benjamin Robinson', 'Partial Insurance', '1993-05-18', 'M'),
('E014', 'Karen Thompson', 'No Insurance', '1997-07-24', 'F'),
('E015', 'Thomas Lewis', 'Full Insurance', '1990-11-09', 'M'),
('E016', 'Donna Smith', 'Partial Insurance', '1998-03-15', 'F'),
('E018', 'Robert Moore', 'Full Insurance', '1992-08-30', 'M'),
('E019', 'Ashley Baker', 'No Insurance', '1996-12-05', 'F'),
('E020', 'Richard Thompson', 'Partial Insurance', '1994-06-22', 'M');

INSERT INTO UserAccount (
    Account_ID, Username, Email, PasswordHash, Role, Employee_ID, Customer_ID
) VALUES
('AUTH_001', 'admin', 'admin@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Admin', NULL, NULL),
('AUTH_002', 'mmoore', 'mmoore@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Owner', 'E001', NULL),
('AUTH_003', 'smiller', 'smiller@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Manager', 'E002', NULL),
('AUTH_004', 'jbrown', 'jbrown@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Mechanic', 'E004', NULL),
('AUTH_005', 'kwilson', 'kwilson@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Manager', 'E006', NULL),
('AUTH_006', 'lbrown', 'lbrown@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Mechanic', 'E007', NULL),
('AUTH_007', 'jgarcia', 'jgarcia@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Manager', 'E008', NULL),
('AUTH_008', 'asanchez', 'asanchez@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Sales', 'E009', NULL),
('AUTH_009', 'jennifer', 'jennifer@dealership.com', '$2b$12$SomeHashedPasswordString...', 'Mechanic', 'E010', NULL),
('AUTH_010', 'rbaker', 'rbaker@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C002'),
('AUTH_011', 'mcarter', 'mcarter@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C005'),
('AUTH_012', 'sroberts', 'sroberts@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C010'),
('AUTH_013', 'rlee', 'rlee@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C015'),
('AUTH_014', 'kgreen', 'kgreen@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C020'),
('AUTH_015', 'dgreen', 'dgreen@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C025'),
('AUTH_016', 'escott', 'escott@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C030'),
('AUTH_017', 'cjones', 'cjones@email.com', '$2b$12$SomeHashedPasswordString...', 'Customer', NULL, 'C035');

INSERT INTO UserSession (
    Session_ID, Account_ID, IPAddress, UserAgent, ExpiresAt
) VALUES
('a1b2c3d4-0001-4a5b-8c6d-000000000001', 'AUTH_002', '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '2026-01-15 09:00:00'),
('a1b2c3d4-0002-4a5b-8c6d-000000000002', 'AUTH_008', '192.168.1.42', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)', '2026-01-20 17:30:00');

-- =========================================================
-- ADDED: Stock-quantity enforcement
-- Nothing previously updated Car.StockQuantity after a sale, so the
-- "Current/Unsold Vehicle Inventory" reports in queries.sql were only ever
-- reflecting the original seed numbers, not real availability. These
-- triggers only affect *future* status changes (an UPDATE into 'Delivered'),
-- so the historical seed rows above — inserted directly as 'Delivered' —
-- are left untouched and won't retroactively drive stock negative.
-- =========================================================
DELIMITER $$

CREATE TRIGGER trg_carorder_check_stock
BEFORE UPDATE ON CarOrder
FOR EACH ROW
BEGIN
    DECLARE available INT;
    IF NEW.OrderStatus = 'Delivered' AND OLD.OrderStatus <> 'Delivered' THEN
        SELECT StockQuantity INTO available FROM Car WHERE SerialNumber = NEW.SerialNumber;
        IF available IS NULL OR available < 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot mark order Delivered: no stock available for this car.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_carorder_decrement_stock
AFTER UPDATE ON CarOrder
FOR EACH ROW
BEGIN
    IF NEW.OrderStatus = 'Delivered' AND OLD.OrderStatus <> 'Delivered' THEN
        UPDATE Car
        SET StockQuantity = StockQuantity - 1
        WHERE SerialNumber = NEW.SerialNumber;
    END IF;
END$$

DELIMITER ;
