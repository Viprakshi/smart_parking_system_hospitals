import mysql.connector
from datetime import datetime

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="alphabetagamma@95822",  # Change this to your password
    database="smart_parking"
)

cursor = conn.cursor()

def clear_screen():
    print("\n" * 2)

def press_enter():
    input("\nPress Enter to continue...")

def register_vehicle():
    clear_screen()
    print("=" * 60)
    print("REGISTER VEHICLE")
    print("=" * 60)
    print("\n1. Patient")
    print("2. Hospital Staff")
    print("3. Visitor")
    print("0. Back to Menu")
    
    user_type = input("\nSelect user type (0-3): ")
    
    if user_type == "0":
        return
    elif user_type == "1":
        # Show patients without vehicles
        cursor.execute("SELECT patient_id, name, phone_no, email, room_no FROM Patients WHERE vehicle_id IS NULL ORDER BY patient_id")
        print("\n" + "-" * 60)
        print("PATIENTS WITHOUT VEHICLES")
        print("-" * 60)
        patients = cursor.fetchall()
        if not patients:
            print("No patients without vehicles!")
            press_enter()
            return
        print("{:<5} {:<20} {:<15} {:<25} {:<10}".format("ID", "Name", "Phone", "Email", "Room"))
        print("-" * 60)
        for p in patients:
            print("{:<5} {:<20} {:<15} {:<25} {:<10}".format(
                p[0], p[1][:20], p[2], p[3][:25] if p[3] else "N/A", p[4] if p[4] else "N/A"
            ))
        
        person_id = int(input("\nEnter Patient ID: "))
        cursor.execute("SELECT name FROM Patients WHERE patient_id = %s", (person_id,))
        result = cursor.fetchone()
        if not result:
            print(" Patient not found!")
            press_enter()
            return
        person_name = result[0]
        table = "Patients"
        id_column = "patient_id"
        
    elif user_type == "2":
        # Show staff without vehicles
        cursor.execute("SELECT staff_id, name, staff_num, department, phone, email FROM Hospital_Staff WHERE vehicle_id IS NULL ORDER BY staff_id")
        print("\n" + "-" * 80)
        print("HOSPITAL STAFF WITHOUT VEHICLES")
        print("-" * 80)
        staff = cursor.fetchall()
        if not staff:
            print("No staff without vehicles!")
            press_enter()
            return
        print("{:<5} {:<20} {:<12} {:<15} {:<15} {:<25}".format("ID", "Name", "Staff#", "Department", "Phone", "Email"))
        print("-" * 80)
        for s in staff:
            print("{:<5} {:<20} {:<12} {:<15} {:<15} {:<25}".format(
                s[0], s[1][:20], s[2], s[3][:15], s[4], s[5][:25]
            ))
        
        person_id = int(input("\nEnter Staff ID: "))
        cursor.execute("SELECT name FROM Hospital_Staff WHERE staff_id = %s", (person_id,))
        result = cursor.fetchone()
        if not result:
            print(" Staff not found!")
            press_enter()
            return
        person_name = result[0]
        table = "Hospital_Staff"
        id_column = "staff_id"
        
    elif user_type == "3":
        # Show all visitors
        cursor.execute("SELECT visitor_id, name, phone, email, visit_date, relationship_to_patient FROM Visitors ORDER BY visitor_id")
        print("\n" + "-" * 90)
        print("VISITORS")
        print("-" * 90)
        visitors = cursor.fetchall()
        if not visitors:
            print("No visitors found!")
            press_enter()
            return
        print("{:<5} {:<20} {:<15} {:<25} {:<12} {:<15}".format("ID", "Name", "Phone", "Email", "Visit Date", "Relationship"))
        print("-" * 90)
        for v in visitors:
            print("{:<5} {:<20} {:<15} {:<25} {:<12} {:<15}".format(
                v[0], v[1][:20], v[2], v[3][:25], str(v[4]), v[5][:15]
            ))
        
        person_id = int(input("\nEnter Visitor ID: "))
        cursor.execute("SELECT name FROM Visitors WHERE visitor_id = %s", (person_id,))
        result = cursor.fetchone()
        if not result:
            print(" Visitor not found!")
            press_enter()
            return
        person_name = result[0]
        table = None  # Visitors don't have vehicle_id column
        
    else:
        print(" Invalid choice!")
        press_enter()
        return
    
    print("\n" + "-" * 60)
    license_plate = input("Enter license plate (e.g., KA01AB1234): ").upper()
    
    print("\nVehicle Types:")
    print("1. Car")
    print("2. Motorcycle")
    print("3. SUV")
    print("4. Van")
    print("5. Ambulance")
    print("6. Bus")
    
    vehicle_type_choice = input("Select vehicle type (1-6): ")
    vehicle_types = {
        "1": "Car", "2": "Motorcycle", "3": "SUV", 
        "4": "Van", "5": "Ambulance", "6": "Bus"
    }
    vehicle_type = vehicle_types.get(vehicle_type_choice, "Car")
    
    try:
        # Insert vehicle (lot_id and space_id are NULL initially)
        cursor.execute("""
            INSERT INTO Vehicles (owner_name, license_plate, vehicle_type, lot_id, space_id)
            VALUES (%s, %s, %s, NULL, NULL)
        """, (person_name, license_plate, vehicle_type))
        vehicle_id = cursor.lastrowid
        
        # Update person table with vehicle_id (except visitors)
        if table:
            cursor.execute(f"UPDATE {table} SET vehicle_id = %s WHERE {id_column} = %s", 
                         (vehicle_id, person_id))
        
        conn.commit()
        
        print("\n" + "=" * 60)
        print(" VEHICLE REGISTERED SUCCESSFULLY!")
        print("=" * 60)
        print(f"Vehicle ID      : {vehicle_id}")
        print(f"Owner           : {person_name}")
        print(f"License Plate   : {license_plate}")
        print(f"Vehicle Type    : {vehicle_type}")
        print(f"Parking Status  : Not Assigned")
        print("=" * 60)
        print("\nNext step: Use 'Assign Parking Space' to allocate parking.")
        
    except mysql.connector.IntegrityError as e:
        print("\n ERROR: License plate already registered!")
        print(f"Details: {e}")
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
    
    press_enter()

def assign_parking():
    clear_screen()
    print("=" * 60)
    print("ASSIGN PARKING SPACE")
    print("=" * 60)

    cursor.execute("""
        SELECT vehicle_id, owner_name, license_plate, vehicle_type
        FROM Vehicles WHERE space_id IS NULL ORDER BY vehicle_id
    """)
    vehicles = cursor.fetchall()
    if not vehicles:
        print("\nNo unassigned vehicles found.")
        press_enter()
        return

    print("\nVEHICLES WITHOUT PARKING:")
    print("-" * 60)
    print("{:<5} {:<20} {:<15} {:<15}".format("ID", "Owner", "License", "Type"))
    print("-" * 60)
    for v in vehicles:
        print("{:<5} {:<20} {:<15} {:<15}".format(v[0], v[1][:20], v[2], v[3]))

    try:
        vehicle_id = int(input("\nEnter Vehicle ID: "))
        cursor.execute("""
            SELECT owner_name, license_plate FROM Vehicles
            WHERE vehicle_id = %s AND space_id IS NULL
        """, (vehicle_id,))
        result = cursor.fetchone()
        if not result:
            print("✗ Invalid Vehicle ID or already assigned.")
            press_enter()
            return

        print("\nLot Types:\n1. General\n2. Staff\n3. Emergency\n4. VIP")
        lot_type = {"1": "General", "2": "Staff", "3": "Emergency", "4": "VIP"}.get(
            input("\nSelect lot type (1-4): "), "General"
        )

        # Call stored procedure 
        args = (vehicle_id, lot_type, 0, 0, '')
        result_args = cursor.callproc('sp_assign_parking_space', args)
        space_id = result_args[2]
        lot_id = result_args[3]
        message = result_args[4]
        
        conn.commit()

        print("\n" + "=" * 60)
        if space_id is not None:
            print(" PARKING ASSIGNED SUCCESSFULLY")
            print("=" * 60)
            print(f"Vehicle ID      : {vehicle_id}")
            print(f"Owner           : {result[0]}")
            print(f"License Plate   : {result[1]}")
            print(f"Lot ID          : {lot_id}")
            print(f"Space ID        : {space_id}")
            print(f"Lot Type        : {lot_type}")
            print("=" * 60)
            print(f"\nMessage: {message}")
        else:
            print(" PARKING ASSIGNMENT FAILED")
            print("=" * 60)
            print(f"Reason: {message if message else 'Unknown error'}")
            print("=" * 60)
            
    except ValueError:
        print("\n Invalid input! Please enter a valid number.")
    except mysql.connector.Error as db_err:
        print(f"\n DATABASE ERROR: {db_err}")
        conn.rollback()
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
        import traceback
        traceback.print_exc()
        conn.rollback()

    press_enter()
def release_parking():
    clear_screen()
    print("=" * 60)
    print("RELEASE PARKING SPACE")
    print("=" * 60)
    
    # Show vehicles with parking from database
    cursor.execute("""
    SELECT 
        v.vehicle_id,
        v.owner_name,
        v.license_plate,
        v.vehicle_type,
        v.lot_id,
        (SELECT pl.lot_name 
         FROM Parking_Lots pl 
         WHERE pl.lot_id = v.lot_id) AS lot_name,
        v.space_id,
        (SELECT ps.space_type 
         FROM Parking_Spaces ps 
         WHERE ps.space_id = v.space_id) AS space_type
    FROM Vehicles v
    WHERE v.space_id IS NOT NULL
    ORDER BY v.vehicle_id
    """)
    vehicles = cursor.fetchall()
    
    if not vehicles:
        print("\nNo vehicles with parking assignments!")
        press_enter()
        return
    
    print("\nVEHICLES WITH PARKING:")
    print("-" * 90)
    print("{:<5} {:<20} {:<15} {:<10} {:<8} {:<15} {:<8} {:<12}".format(
        "ID", "Owner", "License", "Type", "Lot ID", "Lot Name", "Space", "Type"
    ))
    print("-" * 90)
    for v in vehicles:
        print("{:<5} {:<20} {:<15} {:<10} {:<8} {:<15} {:<8} {:<12}".format(
            v[0], v[1][:20], v[2], v[3], v[4], v[5][:15], v[6], v[7]
        ))
    print("-" * 90)
    
    try:
        vehicle_id = int(input("\nEnter Vehicle ID to release: "))
        
        # Get vehicle details before releasing
        cursor.execute("""
            SELECT v.owner_name, v.license_plate, pl.lot_name, v.space_id 
            FROM Vehicles v
            JOIN Parking_Lots pl ON v.lot_id = pl.lot_id
            WHERE v.vehicle_id = %s AND v.space_id IS NOT NULL
        """, (vehicle_id,))
        result = cursor.fetchone()
        
        if not result:
            print(" Vehicle not found or has no parking assignment!")
            press_enter()
            return
        
        # Release parking (triggers will automatically update space status to 'Available')
        cursor.execute("""
            UPDATE Vehicles SET lot_id = NULL, space_id = NULL 
            WHERE vehicle_id = %s
        """, (vehicle_id,))
        conn.commit()
        
        print("\n" + "=" * 60)
        print("✓ PARKING RELEASED SUCCESSFULLY!")
        print("=" * 60)
        print(f"Vehicle ID      : {vehicle_id}")
        print(f"Owner           : {result[0]}")
        print(f"License Plate   : {result[1]}")
        print(f"Released From   : {result[2]}, Space {result[3]}")
        print("=" * 60)
        
    except ValueError:
        print("Invalid input! Please enter a number.")
    except Exception as e:
        print(f"✗ ERROR: {e}")
    
    press_enter()

def view_availability():
    clear_screen()
    print("=" * 100)
    print("PARKING AVAILABILITY STATUS")
    print("=" * 100)
    
    # Query uses fn_check_parking_availability function from database
    cursor.execute("""
        SELECT 
            pl.lot_id,
            pl.lot_name,
            pl.location,
            pl.lot_type,
            COUNT(ps.space_id) as total_spaces,
            SUM(CASE WHEN ps.status = 'Occupied' THEN 1 ELSE 0 END) as occupied,
            SUM(CASE WHEN ps.status = 'Available' THEN 1 ELSE 0 END) as available,
            SUM(CASE WHEN ps.status = 'Reserved' THEN 1 ELSE 0 END) as reserved,
            SUM(CASE WHEN ps.status = 'Maintenance' THEN 1 ELSE 0 END) as maintenance,
            fn_check_parking_availability(pl.lot_id) AS status
        FROM Parking_Lots pl
        LEFT JOIN Parking_Spaces ps ON pl.lot_id = ps.lot_id
        GROUP BY pl.lot_id, pl.lot_name, pl.location, pl.lot_type
        ORDER BY pl.lot_id
    """)
    
    print("\n{:<5} {:<15} {:<25} {:<10} {:<8} {:<10} {:<10} {:<10} {:<12} {:<20}".format(
        "ID", "Lot Name", "Location", "Type", "Total", "Occupied", "Available", "Reserved", "Maintenance", "Status"
    ))
    print("-" * 100)
    
    for row in cursor.fetchall():
        print("{:<5} {:<15} {:<25} {:<10} {:<8} {:<10} {:<10} {:<10} {:<12} {:<20}".format(
            row[0], row[1][:15], row[2][:25], row[3], row[4], row[5], row[6], row[7], row[8], row[9]
        ))
    
    press_enter()

def generate_report():
    clear_screen()
    print("=" * 60)
    print("GENERATE PARKING REPORT")
    print("=" * 60)
    
    # Show available lots from database
    cursor.execute("SELECT lot_id, lot_name, location, lot_type FROM Parking_Lots ORDER BY lot_id")
    lots = cursor.fetchall()
    
    print("\nAVAILABLE PARKING LOTS:")
    print("-" * 60)
    print("{:<5} {:<20} {:<25} {:<10}".format("ID", "Lot Name", "Location", "Type"))
    print("-" * 60)
    for lot in lots:
        print("{:<5} {:<20} {:<25} {:<10}".format(lot[0], lot[1][:20], lot[2][:25], lot[3]))
    print("-" * 60)
    
    try:
        lot_id = int(input("\nEnter Lot ID for report: "))
        
        # Call stored procedure sp_generate_parking_report
        cursor.callproc('sp_generate_parking_report', [lot_id])
        
        print("\n" + "=" * 90)
        print("PARKING LOT UTILIZATION REPORT")
        print("=" * 90)
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 90)
        
        # Fetch result sets from stored procedure
        for result in cursor.stored_results():
            columns = [desc[0] for desc in result.description]
            rows = result.fetchall()
            
            if "Parking Lot Name" in columns:
                # Summary section
                print("\nSUMMARY:")
                print("-" * 90)
                for row in rows:
                    for col, val in zip(columns, row):
                        print(f"{col:<30}: {val}")
                print("-" * 90)
            else:
                # Detailed space information
                print("\nDETAILED SPACE INFORMATION:")
                print("-" * 90)
                
                # Print header
                header = " | ".join([f"{col:^15}" for col in columns])
                print(header)
                print("-" * len(header))
                
                # Print rows
                for row in rows:
                    row_str = " | ".join([f"{str(val) if val else 'N/A':^15}" for val in row])
                    print(row_str)
        
        print("=" * 90)
        print("\nReport generated using sp_generate_parking_report() stored procedure")
        
    except ValueError:
        print(" Invalid input! Please enter a number.")
    except Exception as e:
        print(f" ERROR: {e}")
    
    press_enter()

def list_all_vehicles():
    clear_screen()
    print("=" * 100)
    print("ALL REGISTERED VEHICLES")
    print("=" * 100)
    
    # Get statistics
    cursor.execute("SELECT COUNT(*) FROM Vehicles")
    total = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM Vehicles WHERE space_id IS NOT NULL")
    parked = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM Vehicles WHERE space_id IS NULL")
    unparked = cursor.fetchone()[0]
    
    print(f"\nTotal Vehicles: {total} | Parked: {parked} | Not Parked: {unparked}")
    print("-" * 100)
    
    # Get all vehicles from database
    cursor.execute("""
        SELECT 
            v.vehicle_id,
            v.owner_name,
            v.license_plate,
            v.vehicle_type,
            v.lot_id,
            COALESCE(pl.lot_name, 'Not Assigned') as lot_name,
            COALESCE(v.space_id, 0) as space_id,
            CASE WHEN v.space_id IS NOT NULL THEN 'Parked' ELSE 'Not Parked' END as status
        FROM Vehicles v
        LEFT JOIN Parking_Lots pl ON v.lot_id = pl.lot_id
        ORDER BY v.vehicle_id
    """)
    
    print("\n{:<5} {:<20} {:<15} {:<12} {:<8} {:<18} {:<8} {:<12}".format(
        "ID", "Owner", "License", "Type", "Lot ID", "Lot Name", "Space", "Status"
    ))
    print("-" * 100)
    
    vehicles = cursor.fetchall()
    if not vehicles:
        print("No vehicles registered!")
    else:
        for row in vehicles:
            lot_id_display = row[4] if row[4] else "-"
            space = row[6] if row[6] != 0 else "-"
            print("{:<5} {:<20} {:<15} {:<12} {:<8} {:<18} {:<8} {:<12}".format(
                row[0], row[1][:20], row[2], row[3], lot_id_display, row[5][:18], space, row[7]
            ))
    
    print("=" * 100)
    print(f"\nShowing all {len(vehicles)} vehicles from database")
    press_enter()

def delete_vehicle():
    clear_screen()
    print("=" * 60)
    print("DELETE VEHICLE")
    print("=" * 60)
    
    # Show all vehicles from database
    cursor.execute("""
        SELECT 
            v.vehicle_id,
            v.owner_name,
            v.license_plate,
            v.vehicle_type,
            CASE WHEN v.space_id IS NOT NULL THEN 'Parked' ELSE 'Not Parked' END as status,
            COALESCE(pl.lot_name, 'N/A') as lot_name,
            COALESCE(v.space_id, 0) as space_id
        FROM Vehicles v
        LEFT JOIN Parking_Lots pl ON v.lot_id = pl.lot_id
        ORDER BY v.vehicle_id
    """)
    
    vehicles = cursor.fetchall()
    
    if not vehicles:
        print("\nNo vehicles registered in the system!")
        press_enter()
        return
    
    print("\nREGISTERED VEHICLES:")
    print("-" * 90)
    print("{:<5} {:<20} {:<15} {:<12} {:<12} {:<18} {:<8}".format(
        "ID", "Owner", "License", "Type", "Status", "Lot Name", "Space"
    ))
    print("-" * 90)
    
    for v in vehicles:
        space_display = v[6] if v[6] != 0 else "-"
        print("{:<5} {:<20} {:<15} {:<12} {:<12} {:<18} {:<8}".format(
            v[0], v[1][:20], v[2], v[3], v[4], v[5][:18], space_display
        ))
    print("-" * 90)
    
    try:
        vehicle_id = int(input("\nEnter Vehicle ID to delete (0 to cancel): "))
        
        if vehicle_id == 0:
            print("\nOperation cancelled.")
            press_enter()
            return
        
        cursor.execute("""
            SELECT 
                v.owner_name, 
                v.license_plate, 
                v.vehicle_type,
                v.space_id,
                pl.lot_name
            FROM Vehicles v
            LEFT JOIN Parking_Lots pl ON v.lot_id = pl.lot_id
            WHERE v.vehicle_id = %s
        """, (vehicle_id,))
        
        result = cursor.fetchone()
        
        if not result:
            print("\n Vehicle not found!")
            press_enter()
            return
        
        owner, license_plate, vehicle_type, space_id, lot_name = result
        
        print("\n" + "=" * 60)
        print("VEHICLE DETAILS:")
        print("=" * 60)
        print(f"Vehicle ID      : {vehicle_id}")
        print(f"Owner           : {owner}")
        print(f"License Plate   : {license_plate}")
        print(f"Vehicle Type    : {vehicle_type}")
        print(f"Parking Status  : {'Parked at ' + str(lot_name) + ', Space ' + str(space_id) if space_id else 'Not Parked'}")
        print("=" * 60)
        
        confirm = input("\nAre you sure you want to delete this vehicle? (yes/no): ").lower()
        
        if confirm != "yes":
            print("\nDeletion cancelled.")
            press_enter()
            return
        
        cursor.execute("SELECT patient_id FROM Patients WHERE vehicle_id = %s", (vehicle_id,))
        patient = cursor.fetchone()
        
        cursor.execute("SELECT staff_id FROM Hospital_Staff WHERE vehicle_id = %s", (vehicle_id,))
        staff = cursor.fetchone()
        if patient:
            cursor.execute("UPDATE Patients SET vehicle_id = NULL WHERE vehicle_id = %s", (vehicle_id,))
        
        if staff:
            cursor.execute("UPDATE Hospital_Staff SET vehicle_id = NULL WHERE vehicle_id = %s", (vehicle_id,))
    
        cursor.execute("DELETE FROM Vehicles WHERE vehicle_id = %s", (vehicle_id,))        
        conn.commit()
        
        print("\n" + "=" * 60)
        print("VEHICLE DELETED SUCCESSFULLY!")
        print("=" * 60)
        print(f"Vehicle ID      : {vehicle_id}")
        print(f"Owner           : {owner}")
        print(f"License Plate   : {license_plate}")
        if space_id:
            print(f"Parking Released: {lot_name}, Space {space_id}")
            print("(Space automatically marked as 'Available' by trigger)")
        if patient:
            print(f"Unlinked from   : Patient ID {patient[0]}")
        if staff:
            print(f"Unlinked from   : Staff ID {staff[0]}")
        print("=" * 60)
        print("\nDELETE query executed successfully!")
        
    except ValueError:
        print("\n Invalid input! Please enter a valid number.")
    except mysql.connector.Error as db_err:
        print(f"\n DATABASE ERROR: {db_err}")
        conn.rollback()
    except Exception as e:
        print(f"\n ERROR: {e}")
        conn.rollback()
    
    press_enter()

# Main menu loop
print("\n" + "=" * 60)
print("     SMART HOSPITAL PARKING SYSTEM")
print("=" * 60)
print("=" * 60)

while True:
    print("\n" + "=" * 60)
    print("MAIN MENU")
    print("=" * 60)
    print("1. Register Vehicle")
    print("2. Assign Parking Space")
    print("3. Release Parking Space")
    print("4. View Parking Availability")
    print("5. Generate Parking Report")
    print("6. List All Vehicles")
    print("7. Delete Vehicle")  # NEW OPTION
    print("0. Exit")
    print("=" * 60)
    
    choice = input("Enter your choice (0-7): ")
    
    if choice == "1":
        register_vehicle()
    elif choice == "2":
        assign_parking()
    elif choice == "3":
        release_parking()
    elif choice == "4":
        view_availability()
    elif choice == "5":
        generate_report()
    elif choice == "6":
        list_all_vehicles()
    elif choice == "7":
        delete_vehicle() 
    elif choice == "0":
        print("\n" + "=" * 60)
        cursor.close()
        conn.close()
        print("Exiting system. Goodbye!")
        print("=" * 60)
        break
    else:
        print("\nInvalid choice! Please enter a number between 0-7.")
        press_enter()