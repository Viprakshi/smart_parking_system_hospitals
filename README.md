
# Smart Hospital Parking System

A comprehensive database-driven parking management system designed for hospitals to efficiently manage vehicle parking for patients, staff, and visitors.


##  Overview

The Smart Hospital Parking System is a complete solution for managing hospital parking facilities. It tracks vehicles, assigns parking spaces intelligently, monitors availability in real-time, and generates comprehensive reports. The system uses MySQL for robust data management and Python for an interactive console interface.

##  Features

### Core Functionality
- **Vehicle Registration** - Register vehicles for patients, hospital staff, and visitors
- **Intelligent Space Assignment** - Automatically assigns parking spaces based on lot type and availability
- **Space Release Management** - Free up parking spaces with automatic status updates via triggers
- **Real-time Availability Tracking** - Monitor parking lot occupancy across all facilities
- **Comprehensive Reporting** - Generate detailed reports for individual parking lots

### User Categories
- **Patients** - Link vehicles to patient records with admission details
- **Hospital Staff** - Dedicated staff parking with department tracking
- **Visitors** - Guest parking with visit date and relationship tracking

### Parking Lot Types
- **General** - Standard parking for patients and visitors
- **Staff** - Reserved parking for hospital employees
- **Emergency** - Priority parking for emergency vehicles
- **VIP** - Premium parking for special guests

### Space Types
- **Regular** - Standard parking spaces
- **Disabled** - Accessible parking spaces
- **Emergency** - Emergency vehicle spaces
- **Electric** - EV charging stations



## Prerequisites

### Software Requirements
- **Python 3.7+**
- **MySQL Server 8.0+**
- **MySQL Connector for Python**

### Python Libraries
```bash
mysql-connector-python
```

## Installation

### Step 1: Clone or Download the Project
```bash
# Create project directory
mkdir smart_parking_system
cd smart_parking_system

# Copy the files
# - code.sql
# - ui_console.py
```

### Step 2: Set Up MySQL Database

1. **Start MySQL Server**
   ```bash
   # On Windows (if installed as service)
   net start MySQL80
   
   # On Linux/Mac
   sudo systemctl start mysql
   ```

2. **Run the SQL Script**
   ```bash
   # Method 1: Using MySQL Command Line
   mysql -u root -p < code.sql
   
   # Method 2: Using MySQL Workbench
   # - Open MySQL Workbench
   # - File > Open SQL Script
   # - Select code.sql
   # - Execute ( icon or Ctrl+Shift+Enter)
   ```

3. **Verify Database Creation**
   ```sql
   SHOW DATABASES;
   USE smart_parking;
   SHOW TABLES;
   ```

### Step 3: Install Python Dependencies

```bash
# Install mysql-connector-python
pip install mysql-connector-python

# Verify installation
python -c "import mysql.connector; print('MySQL Connector installed successfully!')"
```

### Step 4: Configure Database Connection

Edit `ui_console.py` and update the database credentials:

```python
conn = mysql.connector.connect(
    host="localhost",
    user="root",              # Change to your MySQL username
    password="your_password",  # Change to your MySQL password
    database="smart_parking"
)
```

### Step 5: Run the Application

```bash
python ui_console.py
```

##  Database Schema

### Entity Relationship Overview

```
Visitors (20 records)
    └─ visit_date, relationship_to_patient

Parking_Lots (5 lots)
    ├─ lot_type: General, Staff, Emergency, VIP
    └─ total_capacity: 20 spaces each

Parking_Spaces (100 spaces)
    ├─ space_type: Regular, Disabled, Emergency, Electric
    ├─ status: Available, Occupied, Reserved, Maintenance
    └─ lot_id → Parking_Lots

Vehicles (10 initial)
    ├─ license_plate (unique)
    ├─ vehicle_type: Car, Motorcycle, SUV, Van, Ambulance, Bus
    ├─ lot_id → Parking_Lots
    └─ space_id → Parking_Spaces

Patients (20 records)
    ├─ admission_date, discharge_date
    ├─ room_no
    └─ vehicle_id → Vehicles

Hospital_Staff (20 records)
    ├─ staff_num (unique)
    ├─ department
    └─ vehicle_id → Vehicles

Appointments (10 scheduled)
    ├─ patient_id → Patients
    ├─ appointment_date, appointment_time
    └─ status: Scheduled, Completed, Cancelled, No-Show, Rescheduled
```

### Key Constraints

- **Email & Phone Validation** - REGEXP checks for proper formats
- **Unique Constraints** - License plates, emails, phone numbers
- **Referential Integrity** - Foreign keys with CASCADE/SET NULL
- **Business Rules** - Discharge date ≥ admission date, positive capacities
- **Lot Capacity Check** - Trigger prevents overbooking

