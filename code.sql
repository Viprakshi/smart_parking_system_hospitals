-- ======================================================================
-- SMART HOSPITAL PARKING SYSTEM DATABASE
-- ======================================================================

CREATE DATABASE smart_parking;
USE smart_parking;

-- ======================================================================
-- TABLES
-- ======================================================================

CREATE TABLE Visitors (
    visitor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    visit_date DATE NOT NULL,
    relationship_to_patient VARCHAR(50) DEFAULT 'Family Member',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_visitor_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$'),
    CONSTRAINT chk_visitor_phone_format CHECK (phone REGEXP '^[0-9]{10,15}$')
);

CREATE TABLE Parking_Lots (
    lot_id INT PRIMARY KEY AUTO_INCREMENT,
    lot_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200) NOT NULL,
    total_capacity INT NOT NULL DEFAULT 20,
    lot_type ENUM('General', 'Staff', 'Emergency', 'VIP') NOT NULL DEFAULT 'General', 
    CONSTRAINT chk_lot_capacity_positive CHECK (total_capacity > 0)
);

CREATE TABLE Parking_Spaces (
    space_id INT PRIMARY KEY AUTO_INCREMENT,
    lot_id INT NOT NULL,
    space_type ENUM('Regular', 'Disabled', 'Emergency', 'Electric') NOT NULL DEFAULT 'Regular',
    status ENUM('Available', 'Occupied', 'Reserved', 'Maintenance') NOT NULL DEFAULT 'Available',
    FOREIGN KEY (lot_id) REFERENCES Parking_Lots(lot_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    owner_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('Car', 'Motorcycle', 'SUV', 'Van', 'Ambulance', 'Bus') NOT NULL DEFAULT 'Car',
    lot_id INT,
    space_id INT,
    FOREIGN KEY (lot_id) REFERENCES Parking_Lots(lot_id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (space_id) REFERENCES Parking_Spaces(space_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_owner_name_length CHECK (LENGTH(TRIM(owner_name)) >= 2),
    CONSTRAINT chk_license_plate_format CHECK (license_plate REGEXP '^[A-Z0-9]{4,20}$')
);

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    phone_no VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(150) UNIQUE DEFAULT NULL,
    emergency_contact VARCHAR(15) NOT NULL,
    admission_date DATE DEFAULT NULL,
    discharge_date DATE DEFAULT NULL,
    room_no VARCHAR(10) DEFAULT NULL,
    vehicle_id INT DEFAULT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_patient_name_length CHECK (LENGTH(TRIM(name)) >= 2),
    CONSTRAINT chk_patient_phone_format CHECK (phone_no REGEXP '^[0-9]{10,15}$'),
    CONSTRAINT chk_emergency_contact_format CHECK (emergency_contact REGEXP '^[0-9]{10,15}$'),
    CONSTRAINT chk_patient_email_format CHECK (
        email IS NULL OR email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT chk_discharge_after_admission CHECK (
        discharge_date IS NULL OR admission_date IS NULL OR discharge_date >= admission_date
    )
);

CREATE TABLE Hospital_Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    staff_num VARCHAR(20) NOT NULL UNIQUE,
    department VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    vehicle_id INT DEFAULT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_staff_name_length CHECK (LENGTH(TRIM(name)) >= 2),
    CONSTRAINT chk_staff_num_format CHECK (staff_num REGEXP '^[A-Z0-9]{3,20}$'),
    CONSTRAINT chk_staff_phone_format CHECK (phone REGEXP '^[0-9]{10,15}$'),
    CONSTRAINT chk_staff_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
);

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration INT NOT NULL DEFAULT 30,
    type VARCHAR(50) NOT NULL,
    dept VARCHAR(100) NOT NULL,
    room_num VARCHAR(10) DEFAULT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show', 'Rescheduled') 
           NOT NULL DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_duration_positive CHECK (duration > 0 AND duration <= 480),
    CONSTRAINT chk_room_num_format CHECK (room_num IS NULL OR room_num REGEXP '^[A-Z0-9-]{1,10}$')
);

-- ======================================================================
-- SAMPLE DATA INSERTS
-- ======================================================================
INSERT INTO Visitors (name, email, phone, visit_date, relationship_to_patient)
VALUES
('Rajesh Kumar', 'rajesh.kumar@example.com', '9876543210', '2025-11-01', 'Father'),
('Sneha Reddy', 'sneha.reddy@example.com', '9876543211', '2025-11-01', 'Sister'),
('Anil Mehta', 'anil.mehta@example.com', '9876543212', '2025-11-02', 'Friend'),
('Priya Sharma', 'priya.sharma@example.com', '9876543213', '2025-11-02', 'Wife'),
('Vikram Nair', 'vikram.nair@example.com', '9876543214', '2025-11-02', 'Brother'),
('Deepa Iyer', 'deepa.iyer@example.com', '9876543225', '2025-11-03', 'Mother'),
('Karthik Rao', 'karthik.rao@example.com', '9876543226', '2025-11-03', 'Son'),
('Lakshmi Nair', 'lakshmi.nair@example.com', '9876543227', '2025-11-03', 'Daughter'),
('Suresh Patel', 'suresh.patel@example.com', '9876543228', '2025-11-04', 'Uncle'),
('Meena Gupta', 'meena.gupta@example.com', '9876543229', '2025-11-04', 'Aunt'),
('Ramesh Patel', 'ramesh.patel@example.com', '9876543230', '2025-09-06', 'Uncle'),
('Geeta Rao', 'geeta.rao@example.com', '9876543231', '2025-09-07', 'Mother'),
('Amit Verma', 'amit.verma@example.com', '9876543232', '2025-09-08', 'Cousin'),
('Kavita Sharma', 'kavita.sharma@example.com', '9876543233', '2025-09-09', 'Daughter'),
('Sunil Gupta', 'sunil.gupta@example.com', '9876543234', '2025-09-10', 'Friend'),
('Rekha Singh', 'rekha.singh@example.com', '9876543235', '2025-09-11', 'Sister'),
('Mohan Das', 'mohan.das@example.com', '9876543236', '2025-09-12', 'Husband'),
('Sunita Joshi', 'sunita.joshi@example.com', '9876543237', '2025-09-13', 'Aunt'),
('Ajay Khanna', 'ajay.khanna@example.com', '9876543238', '2025-09-14', 'Son'),
('Neelam Bose', 'neelam.bose@example.com', '9876543239', '2025-09-15', 'Niece');

-- INSERT 5 PARKING LOTS
INSERT INTO Parking_Lots (lot_name, location, total_capacity, lot_type)
VALUES
('Lot A', 'North Wing Entrance', 20, 'General'),
('Lot B', 'South Wing Entrance', 20, 'Staff'),
('Lot C', 'Emergency Bay', 20, 'Emergency'),
('Lot D', 'VIP Zone', 20, 'VIP'),
('Lot E', 'West Wing', 20, 'General');

-- CREATE 100 PARKING SPACES (20 per lot)
-- Lot 1 (General)
INSERT INTO Parking_Spaces (lot_id, space_type, status) VALUES
(1, 'Regular', 'Available'), (1, 'Regular', 'Available'), (1, 'Regular', 'Available'),
(1, 'Regular', 'Available'), (1, 'Regular', 'Available'), (1, 'Regular', 'Available'),
(1, 'Regular', 'Available'), (1, 'Regular', 'Available'), (1, 'Regular', 'Available'),
(1, 'Regular', 'Available'), (1, 'Regular', 'Available'), (1, 'Regular', 'Available'),
(1, 'Regular', 'Available'), (1, 'Regular', 'Available'), (1, 'Regular', 'Available'),
(1, 'Disabled', 'Available'), (1, 'Disabled', 'Available'), (1, 'Electric', 'Available'),
(1, 'Electric', 'Available'), (1, 'Regular', 'Available');

-- Lot 2 (Staff)
INSERT INTO Parking_Spaces (lot_id, space_type, status) VALUES
(2, 'Regular', 'Available'), (2, 'Regular', 'Available'), (2, 'Regular', 'Available'),
(2, 'Regular', 'Available'), (2, 'Regular', 'Available'), (2, 'Regular', 'Available'),
(2, 'Regular', 'Available'), (2, 'Regular', 'Available'), (2, 'Regular', 'Available'),
(2, 'Regular', 'Available'), (2, 'Regular', 'Available'), (2, 'Regular', 'Available'),
(2, 'Regular', 'Available'), (2, 'Regular', 'Available'), (2, 'Regular', 'Available'),
(2, 'Disabled', 'Available'), (2, 'Disabled', 'Available'), (2, 'Electric', 'Available'),
(2, 'Electric', 'Available'), (2, 'Regular', 'Available');

-- Lot 3 (Emergency)
INSERT INTO Parking_Spaces (lot_id, space_type, status) VALUES
(3, 'Emergency', 'Available'), (3, 'Emergency', 'Available'), (3, 'Emergency', 'Available'),
(3, 'Emergency', 'Available'), (3, 'Emergency', 'Available'), (3, 'Regular', 'Available'),
(3, 'Regular', 'Available'), (3, 'Regular', 'Available'), (3, 'Regular', 'Available'),
(3, 'Regular', 'Available'), (3, 'Regular', 'Available'), (3, 'Regular', 'Available'),
(3, 'Regular', 'Available'), (3, 'Regular', 'Available'), (3, 'Regular', 'Available'),
(3, 'Regular', 'Available'), (3, 'Disabled', 'Available'), (3, 'Disabled', 'Available'),
(3, 'Emergency', 'Available'), (3, 'Emergency', 'Available');

-- Lot 4 (VIP)
INSERT INTO Parking_Spaces (lot_id, space_type, status) VALUES
(4, 'Regular', 'Available'), (4, 'Regular', 'Available'), (4, 'Regular', 'Available'),
(4, 'Regular', 'Available'), (4, 'Regular', 'Available'), (4, 'Regular', 'Available'),
(4, 'Regular', 'Available'), (4, 'Regular', 'Available'), (4, 'Regular', 'Available'),
(4, 'Regular', 'Available'), (4, 'Regular', 'Available'), (4, 'Regular', 'Available'),
(4, 'Regular', 'Available'), (4, 'Regular', 'Available'), (4, 'Regular', 'Available'),
(4, 'Disabled', 'Available'), (4, 'Electric', 'Available'), (4, 'Electric', 'Available'),
(4, 'Electric', 'Available'), (4, 'Regular', 'Available');

-- Lot 5 (General)
INSERT INTO Parking_Spaces (lot_id, space_type, status) VALUES
(5, 'Regular', 'Available'), (5, 'Regular', 'Available'), (5, 'Regular', 'Available'),
(5, 'Regular', 'Available'), (5, 'Regular', 'Available'), (5, 'Regular', 'Available'),
(5, 'Regular', 'Available'), (5, 'Regular', 'Available'), (5, 'Regular', 'Available'),
(5, 'Regular', 'Available'), (5, 'Regular', 'Available'), (5, 'Regular', 'Available'),
(5, 'Regular', 'Available'), (5, 'Regular', 'Available'), (5, 'Regular', 'Available'),
(5, 'Disabled', 'Available'), (5, 'Disabled', 'Available'), (5, 'Electric', 'Available'),
(5, 'Electric', 'Available'), (5, 'Regular', 'Available');

-- INSERT 10 VEHICLES
INSERT INTO Vehicles (owner_name, license_plate, vehicle_type, lot_id, space_id)
VALUES
('Aarav Singh', 'KA01AB1234', 'Car', NULL, NULL),
('Riya Gupta', 'KA02CD5678', 'SUV', NULL, NULL),
('Kabir Malhotra', 'KA03EF9012', 'Motorcycle', NULL, NULL),
('Meera Iyer', 'KA04GH3456', 'Van', NULL, NULL),
('Aditya Nair', 'KA05IJ7890', 'Car', NULL, NULL),
('Neha Sharma', 'KA06KL1122', 'Car', NULL, NULL),
('Arjun Patel', 'KA07MN3344', 'SUV', NULL, NULL),
('Kavya Rao', 'KA08OP5566', 'Motorcycle', NULL, NULL),
('Rohit Verma', 'KA09QR7788', 'Car', NULL, NULL),
('Anjali Mehta', 'KA10ST9900', 'Car', NULL, NULL);

-- INSERT 20 PATIENTS (Fixed duplicate phone numbers)
INSERT INTO Patients (name, dob, gender, phone_no, email, emergency_contact, admission_date, discharge_date, room_no, vehicle_id)
VALUES
('Aarav Singh', '1995-03-12', 'Male', '9988776655', 'aarav.singh@example.com', '9112233445', '2025-11-01', NULL, '101A', 1),
('Riya Gupta', '1998-07-20', 'Female', '9988776656', 'riya.gupta@example.com', '9112233446', '2025-11-01', NULL, '102B', 2),
('Kabir Malhotra', '1988-11-05', 'Male', '9988776657', 'kabir.malhotra@example.com', '9112233447', '2025-11-02', NULL, '103C', 3),
('Meera Iyer', '2000-01-15', 'Female', '9988776658', 'meera.iyer@example.com', '9112233448', '2025-11-02', NULL, '104D', 4),
('Aditya Nair', '1992-05-25', 'Male', '9988776659', 'aditya.nair@example.com', '9112233449', '2025-11-03', NULL, '105E', 5),
('Pooja Reddy', '1990-08-18', 'Female', '9988776670', 'pooja.reddy@example.com', '9112233450', '2025-11-03', NULL, '106F', NULL),
('Ramesh Kumar', '1985-12-10', 'Male', '9988776671', 'ramesh.kumar@example.com', '9112233451', '2025-11-04', NULL, '107G', NULL),
('Divya Shah', '1993-04-22', 'Female', '9988776672', 'divya.shah@example.com', '9112233452', '2025-11-04', NULL, '108H', NULL),
('Sanjay Pillai', '1987-09-30', 'Male', '9988776673', 'sanjay.pillai@example.com', '9112233453', '2025-11-05', NULL, '109I', NULL),
('Ananya Desai', '1996-06-14', 'Female', '9988776674', 'ananya.desai@example.com', '9112233454', '2025-11-05', NULL, '110J', NULL),
('Sanjay Kapoor', '1985-06-18', 'Male', '9988776675', 'sanjay.kapoor@example.com', '9112233460', '2025-09-10', '2025-09-15', '106F', NULL),
('Pooja Desai', '1993-09-22', 'Female', '9988776676', 'pooja.desai@example.com', '9112233461', '2025-09-11', '2025-09-16', '107G', NULL),
('Karan Khanna', '1990-12-30', 'Male', '9988776677', 'karan.khanna@example.com', '9112233462', '2025-09-12', '2025-09-17', '108H', NULL),
('Divya Pillai', '1987-04-14', 'Female', '9988776678', 'divya.pillai@example.com', '9112233463', '2025-09-13', '2025-09-18', '109I', NULL),
('Aryan Shah', '1996-08-25', 'Male', '9988776679', 'aryan.shah@example.com', '9112233464', '2025-09-14', '2025-09-19', '110J', NULL),
('Simran Bhatia', '1991-02-10', 'Female', '9988776680', 'simran.bhatia@example.com', '9112233465', '2025-09-15', '2025-09-20', '111K', NULL),
('Rahul Joshi', '1989-11-03', 'Male', '9988776681', 'rahul.joshi@example.com', '9112233466', '2025-09-16', '2025-09-21', '112L', NULL),
('Nisha Agarwal', '1994-07-19', 'Female', '9988776682', 'nisha.agarwal@example.com', '9112233467', '2025-09-17', '2025-09-22', '113M', NULL),
('Varun Menon', '1986-03-28', 'Male', '9988776683', 'varun.menon@example.com', '9112233468', '2025-09-18', '2025-09-23', '114N', NULL),
('Shreya Kulkarni', '1992-10-12', 'Female', '9988776684', 'shreya.kulkarni@example.com', '9112233469', '2025-09-19', '2025-09-24', '115O', NULL);

-- INSERT 20 HOSPITAL STAFF (Fixed duplicate staff numbers)
INSERT INTO Hospital_Staff (name, staff_num, department, hire_date, phone, email, vehicle_id)
VALUES
('Dr. Neha Sharma', 'STF001', 'Cardiology', '2020-01-15', '9123456780', 'neha.sharma@hospital.com', 6),
('Dr. Arjun Patel', 'STF002', 'Neurology', '2019-03-10', '9123456781', 'arjun.patel@hospital.com', 7),
('Nurse Kavya Rao', 'STF003', 'Pediatrics', '2021-06-20', '9123456782', 'kavya.rao@hospital.com', 8),
('Dr. Rohit Verma', 'STF004', 'Orthopedics', '2018-11-05', '9123456783', 'rohit.verma@hospital.com', 9),
('Admin Anjali Mehta', 'STF005', 'Administration', '2022-02-01', '9123456784', 'anjali.mehta@hospital.com', 10),
('Dr. Rajiv Singh', 'STF016', 'General Medicine', '2021-08-12', '9123456795', 'rajiv.singh@hospital.com', NULL),
('Nurse Priya Nair', 'STF017', 'Emergency', '2020-05-18', '9123456796', 'priya.nair@hospital.com', NULL),
('Dr. Sunita Rao', 'STF018', 'Radiology', '2019-09-25', '9123456797', 'sunita.rao@hospital.com', NULL),
('Lab Tech Amit Kumar', 'STF019', 'Laboratory', '2022-03-14', '9123456798', 'amit.kumar@hospital.com', NULL),
('Receptionist Maya Iyer', 'STF020', 'Reception', '2023-01-10', '9123456799', 'maya.iyer@hospital.com', NULL),
('Dr. Suresh Reddy', 'STF006', 'General Surgery', '2017-05-12', '9123456785', 'suresh.reddy@hospital.com', NULL),
('Nurse Priya Das', 'STF007', 'ICU', '2020-08-15', '9123456786', 'priya.das@hospital.com', NULL),
('Dr. Manish Kumar', 'STF008', 'Dermatology', '2019-01-20', '9123456787', 'manish.kumar@hospital.com', NULL),
('Nurse Lakshmi Iyer', 'STF009', 'Emergency', '2021-03-25', '9123456788', 'lakshmi.iyer@hospital.com', NULL),
('Dr. Deepak Jain', 'STF010', 'Radiology', '2018-07-10', '9123456789', 'deepak.jain@hospital.com', NULL),
('Admin Ravi Shankar', 'STF011', 'Finance', '2022-09-05', '9123456790', 'ravi.shankar@hospital.com', NULL),
('Dr. Anita Nair', 'STF012', 'Psychiatry', '2016-12-18', '9123456791', 'anita.nair@hospital.com', NULL),
('Nurse Meena Singh', 'STF013', 'Maternity', '2020-11-22', '9123456792', 'meena.singh@hospital.com', NULL),
('Dr. Prakash Deshmukh', 'STF014', 'Urology', '2017-04-08', '9123456793', 'prakash.deshmukh@hospital.com', NULL),
('Admin Sonal Mehta', 'STF015', 'HR', '2023-01-15', '9123456794', 'sonal.mehta@hospital.com', NULL);

-- INSERT 10 APPOINTMENTS
INSERT INTO Appointments (patient_id, appointment_date, appointment_time, duration, type, dept, room_num, status)
VALUES
(1, '2025-11-06', '10:00:00', 45, 'Consultation', 'Cardiology', '201A', 'Scheduled'),
(2, '2025-11-06', '11:30:00', 30, 'Checkup', 'Neurology', '202B', 'Scheduled'),
(3, '2025-11-07', '09:15:00', 60, 'Follow-up', 'Pediatrics', '203C', 'Scheduled'),
(4, '2025-11-07', '14:00:00', 30, 'Consultation', 'Orthopedics', '204D', 'Scheduled'),
(5, '2025-11-08', '15:45:00', 45, 'Checkup', 'General Medicine', '205E', 'Scheduled'),
(6, '2025-11-08', '10:30:00', 30, 'X-Ray', 'Radiology', '206F', 'Scheduled'),
(7, '2025-11-09', '13:00:00', 60, 'Blood Test', 'Laboratory', '207G', 'Scheduled'),
(8, '2025-11-09', '16:00:00', 45, 'Consultation', 'Cardiology', '201A', 'Scheduled'),
(9, '2025-11-10', '09:00:00', 30, 'Emergency', 'Emergency', '208H', 'Scheduled'),
(10, '2025-11-10', '11:00:00', 45, 'Follow-up', 'Neurology', '202B', 'Scheduled');


-- ======================================================================
-- TRIGGERS
-- ======================================================================

DELIMITER $$

CREATE TRIGGER trg_update_space_status_on_vehicle_insert
AFTER INSERT ON Vehicles
FOR EACH ROW
BEGIN
    IF NEW.space_id IS NOT NULL THEN
        UPDATE Parking_Spaces SET status = 'Occupied' WHERE space_id = NEW.space_id;
    END IF;
END$$

CREATE TRIGGER trg_update_space_status_on_vehicle_update
AFTER UPDATE ON Vehicles
FOR EACH ROW
BEGIN
    IF OLD.space_id IS NOT NULL AND (NEW.space_id IS NULL OR NEW.space_id != OLD.space_id) THEN
        UPDATE Parking_Spaces SET status = 'Available' WHERE space_id = OLD.space_id;
    END IF;
    
    IF NEW.space_id IS NOT NULL AND (OLD.space_id IS NULL OR NEW.space_id != OLD.space_id) THEN
        UPDATE Parking_Spaces SET status = 'Occupied' WHERE space_id = NEW.space_id;
    END IF;
END$$

CREATE TRIGGER trg_update_space_status_on_vehicle_delete
AFTER DELETE ON Vehicles
FOR EACH ROW
BEGIN
    IF OLD.space_id IS NOT NULL THEN
        UPDATE Parking_Spaces SET status = 'Available' WHERE space_id = OLD.space_id;
    END IF;
END$$

CREATE TRIGGER trg_check_lot_capacity
BEFORE INSERT ON Vehicles
FOR EACH ROW
BEGIN
    DECLARE current_count INT;
    DECLARE max_capacity INT;
    
    IF NEW.lot_id IS NOT NULL THEN
        SELECT COUNT(*) INTO current_count FROM Vehicles WHERE lot_id = NEW.lot_id;
        SELECT total_capacity INTO max_capacity FROM Parking_Lots WHERE lot_id = NEW.lot_id;
        IF current_count >= max_capacity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Parking lot is full.';
        END IF;
    END IF;
END$$

DELIMITER ;

-- ======================================================================
-- FUNCTION: fn_check_parking_availability
-- ======================================================================
DELIMITER $$

CREATE FUNCTION fn_check_parking_availability(p_lot_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_available INT DEFAULT 0;
    DECLARE v_status VARCHAR(50);

    SELECT COUNT(*), SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END)
    INTO v_total, v_available
    FROM Parking_Spaces
    WHERE lot_id = p_lot_id;

    IF v_available = 0 THEN
        SET v_status = 'Full';
    ELSEIF v_available < (v_total * 0.25) THEN
        SET v_status = 'Limited';
    ELSE
        SET v_status = 'Available';
    END IF;

    RETURN v_status;
END$$
-- ======================================================================
-- PROCEDURE: assign parking space 
-- ======================================================================
DELIMITER $$

CREATE PROCEDURE sp_assign_parking_space(
    IN p_vehicle_id INT,
    IN p_lot_type VARCHAR(20),
    OUT p_space_id INT,
    OUT p_lot_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_space_id INT DEFAULT NULL;
    DECLARE v_lot_id INT DEFAULT NULL;
    DECLARE v_current_space INT DEFAULT NULL;

    -- Initialize OUT parameters
    SET p_space_id = NULL;
    SET p_lot_id = NULL;
    SET p_message = 'Initializing...';

    -- Check if vehicle exists
    IF NOT EXISTS (SELECT 1 FROM Vehicles WHERE vehicle_id = p_vehicle_id) THEN
        SET p_message = 'Vehicle ID does not exist';
        SET p_space_id = NULL;
        SET p_lot_id = NULL;
    ELSE
        -- Check if vehicle already has parking
        SELECT space_id INTO v_current_space FROM Vehicles WHERE vehicle_id = p_vehicle_id;
        
        IF v_current_space IS NOT NULL THEN
            SET p_message = 'Vehicle already has a parking space assigned';
            SET p_space_id = NULL;
            SET p_lot_id = NULL;
        ELSE
            -- Find an available lot of the requested type
            SELECT pl.lot_id
            INTO v_lot_id
            FROM Parking_Lots pl
            WHERE pl.lot_type = p_lot_type
              AND EXISTS (
                  SELECT 1 FROM Parking_Spaces ps 
                  WHERE ps.lot_id = pl.lot_id 
                  AND ps.status = 'Available'
              )
            LIMIT 1;

            -- If no lot found
            IF v_lot_id IS NULL THEN
                SET p_message = CONCAT('No available spaces in ', p_lot_type, ' lots');
                SET p_space_id = NULL;
                SET p_lot_id = NULL;
            ELSE
                -- Find first available space in that lot
                SELECT ps.space_id
                INTO v_space_id
                FROM Parking_Spaces ps
                WHERE ps.lot_id = v_lot_id
                  AND ps.status = 'Available'
                LIMIT 1;

                IF v_space_id IS NULL THEN
                    SET p_message = CONCAT('No available space found in lot ', v_lot_id);
                    SET p_space_id = NULL;
                    SET p_lot_id = v_lot_id;
                ELSE
                    -- Assign the parking space
                    UPDATE Vehicles
                    SET lot_id = v_lot_id, space_id = v_space_id
                    WHERE vehicle_id = p_vehicle_id;

                    -- Mark space as occupied (trigger should do this, but being explicit)
                    UPDATE Parking_Spaces
                    SET status = 'Occupied'
                    WHERE space_id = v_space_id;

                    -- Set success outputs
                    SET p_space_id = v_space_id;
                    SET p_lot_id = v_lot_id;
                    SET p_message = CONCAT('Successfully assigned space ', v_space_id, ' in lot ', v_lot_id);
                END IF;
            END IF;
        END IF;
    END IF;

END$$

DELIMITER ;
DELIMITER ;

-- ======================================================================
-- PROCEDURE: sp_generate_parking_report
-- ======================================================================
DELIMITER $$

CREATE PROCEDURE sp_generate_parking_report(IN p_lot_id INT)
BEGIN
    -- Summary section
    SELECT 
        pl.lot_name AS 'Parking Lot Name',
        pl.location AS 'Location',
        pl.lot_type AS 'Type',
        COUNT(ps.space_id) AS 'Total Spaces',
        SUM(CASE WHEN ps.status = 'Available' THEN 1 ELSE 0 END) AS 'Available Spaces',
        SUM(CASE WHEN ps.status = 'Occupied' THEN 1 ELSE 0 END) AS 'Occupied Spaces',
        SUM(CASE WHEN ps.status = 'Reserved' THEN 1 ELSE 0 END) AS 'Reserved Spaces',
        SUM(CASE WHEN ps.status = 'Maintenance' THEN 1 ELSE 0 END) AS 'Under Maintenance'
    FROM Parking_Lots pl
    JOIN Parking_Spaces ps ON pl.lot_id = ps.lot_id
    WHERE pl.lot_id = p_lot_id
    GROUP BY pl.lot_id;

    -- Detailed space-level information
    SELECT 
        ps.space_id AS 'Space ID',
        ps.space_type AS 'Type',
        ps.status AS 'Status',
        COALESCE(v.license_plate, 'Empty') AS 'Vehicle Plate',
        COALESCE(v.owner_name, 'N/A') AS 'Owner'
    FROM Parking_Spaces ps
    LEFT JOIN Vehicles v ON ps.space_id = v.space_id
    WHERE ps.lot_id = p_lot_id
    ORDER BY ps.space_id;
END$$

DELIMITER ;

-- ======================================================================
-- END OF SCRIPT
-- ======================================================================
