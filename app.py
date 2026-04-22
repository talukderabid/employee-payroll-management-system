from flask import Flask, render_template, request, redirect, url_for, send_file
import pyodbc
import io
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

app = Flask(__name__)

# ----------------------------
# DB CONNECTION
# ----------------------------
def get_connection():
    return pyodbc.connect(
        r"DRIVER={ODBC Driver 17 for SQL Server};"
        r"SERVER=(localdb)\MSSQLLocalDB;"
        r"DATABASE=PayrollDB;"
        r"Trusted_Connection=yes;"
    )

# ----------------------------
# HOME
# ----------------------------
@app.route("/")
def home():
    return render_template("home.html")

# ----------------------------
# TEST DB
# ----------------------------
@app.route("/test-db")
def test_db():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT DB_NAME()")
    db_name = cursor.fetchone()[0]
    conn.close()
    return f"Connected to {db_name}"

# ----------------------------
# VIEW EMPLOYEES
# ----------------------------
@app.route("/employees")
def employees():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT EmployeeID, FirstName, LastName, City, State, Email, IsActive
    FROM Employees
    WHERE IsActive = 1
    ORDER BY EmployeeID
""")

    data = cursor.fetchall()
    conn.close()

    return render_template("employees.html", employees=data)

# ----------------------------
# ADD EMPLOYEE (NEW PART)
# ----------------------------
@app.route("/add-employee", methods=["GET", "POST"])
def add_employee():
    if request.method == "POST":
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        address = request.form["address"]
        city = request.form["city"]
        state = request.form["state"]
        zipcode = request.form["zipcode"]
        phone = request.form["phone"]
        email = request.form["email"]

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            EXEC sp_AddEmployee ?, ?, ?, ?, ?, ?, ?, ?
        """, first_name, last_name, address, city, state, zipcode, phone, email)

        conn.commit()
        conn.close()

        return redirect(url_for("employees"))

    return render_template("add_employee.html")
# -----------------------------
#Seting payrate
# -----------------------------
@app.route("/set-payrate", methods=["GET", "POST"])
def set_payrate():
    conn = get_connection()
    cursor = conn.cursor()

    # Get employees for dropdown
    cursor.execute("SELECT EmployeeID, FirstName, LastName FROM Employees")
    employees = cursor.fetchall()

    if request.method == "POST":
        employee_id = request.form["employee_id"]
        rate = request.form["rate"]
        date = request.form["date"]

        cursor.execute("""
            EXEC sp_SetPayRate ?, ?, ?
        """, employee_id, rate, date)

        conn.commit()
        conn.close()

        return redirect(url_for("set_payrate"))

    conn.close()
    return render_template("set_payrate.html", employees=employees)


# -------------------
# Enter hours for workers
# ----------------------
@app.route("/enter-hours", methods=["GET", "POST"])
def enter_hours():
    conn = get_connection()
    cursor = conn.cursor()

    # get employees for dropdown
    cursor.execute("SELECT EmployeeID, FirstName, LastName FROM Employees")
    employees = cursor.fetchall()

    if request.method == "POST":
        employee_id = request.form["employee_id"]
        date = request.form["date"]
        hours = request.form["hours"]

        cursor.execute("""
            INSERT INTO HoursWorked (EmployeeID, WeekStartDate, HoursWorked)
            VALUES (?, ?, ?)
        """, employee_id, date, hours)

        conn.commit()
        conn.close()

        return redirect(url_for("generate_payroll"))

    conn.close()
    return render_template("enter_hours.html", employees=employees)

# ---------------------------------
# Generates payroll
# ---------------------------------
@app.route("/generate-payroll", methods=["GET", "POST"])
def generate_payroll():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT EmployeeID, FirstName, LastName FROM Employees WHERE IsActive = 1")
    employees = cursor.fetchall()

    payroll_data = None

    if request.method == "POST":
        employee_id = request.form["employee_id"]
        date = request.form["date"]

        # Run stored procedure to generate payroll
        cursor.execute("EXEC sp_GenerateWeeklyPayroll ?, ?", employee_id, date)
        conn.commit()

        # Read the generated payroll row back from the table
        cursor.execute("""
            SELECT EmployeeID, WeekStartDate, RegularHours, OvertimeHours, HourlyRate, GrossPay
            FROM Payroll
            WHERE EmployeeID = ?
              AND CONVERT(VARCHAR(10), WeekStartDate, 23) = ?
            ORDER BY PayrollID DESC
        """, employee_id, date)

        payroll_data = cursor.fetchall()

    conn.close()
    return render_template("generate_payroll.html", employees=employees, payroll=payroll_data)
#
#


# ---------------
# inactive employees
# ---------------
@app.route("/inactive-employees")
def inactive_employees():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT EmployeeID, FirstName, LastName, City, State, Email, IsActive
        FROM Employees
        WHERE IsActive = 0
        ORDER BY EmployeeID
    """)

    data = cursor.fetchall()
    conn.close()

    return render_template("inactive_employees.html", employees=data)

# ------------
# reactivation route
# --------------------
@app.route("/reactivate-employee/<int:employee_id>", methods=["POST"])
def reactivate_employee(employee_id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE Employees
        SET IsActive = 1
        WHERE EmployeeID = ?
    """, employee_id)

    conn.commit()
    conn.close()

    return redirect(url_for("inactive_employees"))

# -----
# deactivation warning
#------------

@app.route("/deactivate-employee/<int:employee_id>", methods=["POST"])
def deactivate_employee(employee_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            UPDATE Employees
            SET IsActive = 0
            WHERE EmployeeID = ?
        """, employee_id)

        conn.commit()
        conn.close()

        return redirect(url_for("employees"))

    except Exception:
        conn.rollback()
        conn.close()

        return render_template(
            "deactivate_error.html",
            error_message="Cannot deactivate employee because payroll records already exist."
        )

# ----------------
# for pdf
# ------------------
@app.route("/download-payslip/<int:employee_id>/<week_start>")
def download_payslip(employee_id, week_start):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            e.EmployeeID,
            e.FirstName,
            e.LastName,
            p.WeekStartDate,
            p.RegularHours,
            p.OvertimeHours,
            p.HourlyRate,
            p.GrossPay
        FROM Payroll p
        JOIN Employees e
            ON p.EmployeeID = e.EmployeeID
        WHERE p.EmployeeID = ?
          AND CONVERT(VARCHAR(10), p.WeekStartDate, 23) = ?
    """, employee_id, week_start)

    row = cursor.fetchone()
    conn.close()

    if not row:
        return "Payslip data not found."

    # Create PDF in memory
    buffer = io.BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter

    # Title
    pdf.setFont("Helvetica-Bold", 18)
    pdf.drawString(50, height - 50, "Employee Payslip")

    # Employee information
    pdf.setFont("Helvetica", 12)
    pdf.drawString(50, height - 100, f"Employee ID: {row.EmployeeID}")
    pdf.drawString(50, height - 125, f"Employee Name: {row.FirstName} {row.LastName}")
    pdf.drawString(50, height - 150, f"Week Start Date: {row.WeekStartDate}")

    # Payroll information
    pdf.drawString(50, height - 200, f"Regular Hours: {row.RegularHours}")
    pdf.drawString(50, height - 225, f"Overtime Hours: {row.OvertimeHours}")
    pdf.drawString(50, height - 250, f"Hourly Rate: ${row.HourlyRate:.2f}")
    pdf.drawString(50, height - 275, f"Gross Pay: ${row.GrossPay:.2f}")

    # Footer
    pdf.setFont("Helvetica-Oblique", 10)
    pdf.drawString(50, height - 330, "Generated by Employee Payroll Management System")

    pdf.save()
    buffer.seek(0)

    filename = f"payslip_employee_{employee_id}_{week_start}.pdf"

    return send_file(
        buffer,
        as_attachment=True,
        download_name=filename,
        mimetype="application/pdf"
    )
# ---------------------------------
# RUN APP
# ----------------------------
if __name__ == "__main__":
    app.run(debug=True)