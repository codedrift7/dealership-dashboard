import streamlit as st
import pandas as pd
import plotly.express as px
import mysql.connector
import bcrypt

# --- 1. Connect to MySQL ---
conn = mysql.connector.connect(
    host=st.secrets["host"],
    port=st.secrets["port"],
    user=st.secrets["user"],
    password=st.secrets["password"],
    database=st.secrets["database"],
)

# st.set_page_config(page_title="Dealership Dashboard", page_icon="🏎️", layout="wide")



# --- 2. Login gate ---
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

st.set_page_config(
    page_title="Dealership Dashboard",
    page_icon="🚗",
    layout="centered" if not st.session_state.logged_in else "wide",
)

if not st.session_state.logged_in:
    st.title("🏎️ Dealership Dashboard — Login")

    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Log in", type="primary"):
        user_row = pd.read_sql(
            "SELECT PasswordHash, Role FROM UserAccount WHERE Username = %s AND IsActive = TRUE",
            conn, params=(username,)
        )
        if user_row.empty:
            st.error("Invalid username or password.")
        else:
            stored_hash = user_row["PasswordHash"][0].encode()
            if bcrypt.checkpw(password.encode(), stored_hash):
                st.session_state.logged_in = True
                st.session_state.username = username
                st.session_state.role = user_row["Role"][0]
                st.rerun()
            else:
                st.error("Invalid username or password.")

    st.stop()  # nothing below this runs until logged in

# --- 3. Sidebar: who's logged in + logout ---
st.sidebar.write(f"Logged in as **{st.session_state.username}** ({st.session_state.role})")
if st.sidebar.button("Log out"):
    st.session_state.logged_in = False
    st.rerun()

# Only these roles can make changes (e.g. update order status)
STAFF_ROLES = {"Admin", "Owner", "Manager", "Sales"}
can_edit = st.session_state.role in STAFF_ROLES

# --- 4. Main dashboard (everything below is the same as before) ---
st.title("🚗 Dealership Dashboard")

customers = pd.read_sql("SELECT COUNT(*) AS n FROM Buyer", conn)["n"][0]
employees = pd.read_sql("SELECT COUNT(*) AS n FROM Employee", conn)["n"][0]
cars_sold = pd.read_sql("SELECT COUNT(*) AS n FROM CarOrder WHERE OrderStatus='Delivered'", conn)["n"][0]
revenue = pd.read_sql("""
    SELECT COALESCE(SUM(c.SalePrice),0) AS rev
    FROM CarOrder co JOIN Car c ON co.SerialNumber = c.SerialNumber
    WHERE co.OrderStatus = 'Delivered'
""", conn)["rev"][0]

col1, col2, col3, col4 = st.columns(4)
col1.metric("Customers", customers)
col2.metric("Employees", employees)
col3.metric("Cars Sold", cars_sold)
col4.metric("Revenue", f"${float(revenue):,.0f}")

st.divider()

choice = st.selectbox("What else do you want to see?", [
    "Revenue by Brand",
    "Employee Sales Performance",
    "Order Status Breakdown",
    "Customer Purchase Report",
    "Current Inventory",
    "Unsold Vehicles",
    "Low Stock Alert",
    "Update Order Status",  # staff only, checked below
])

if choice == "Revenue by Brand":
    df = pd.read_sql("""
        SELECT c.Brand, COUNT(*) AS CarsSold, SUM(c.SalePrice) AS Revenue
        FROM CarOrder co JOIN Car c ON co.SerialNumber = c.SerialNumber
        WHERE co.OrderStatus = 'Delivered'
        GROUP BY c.Brand ORDER BY Revenue DESC
    """, conn)
    fig = px.bar(df, x="Brand", y="Revenue", color="Brand", title="Revenue by Brand")
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(df, use_container_width=True)

elif choice == "Employee Sales Performance":
    df = pd.read_sql("""
        SELECT e.Employee_ID, CONCAT(e.FirstName,' ',COALESCE(e.LastName,'')) AS EmployeeName,
               COUNT(co.Order_ID) AS CarsSold, COALESCE(SUM(co.DownPayment),0) AS TotalDownPayment
        FROM Employee e
        LEFT JOIN CarOrder co ON e.Employee_ID = co.Employee_ID AND co.OrderStatus = 'Delivered'
        GROUP BY e.Employee_ID ORDER BY CarsSold DESC
    """, conn)
    fig = px.bar(df, x="EmployeeName", y="CarsSold", title="Cars Sold per Employee")
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(df, use_container_width=True)

elif choice == "Order Status Breakdown":
    df = pd.read_sql("SELECT OrderStatus, COUNT(*) AS Count FROM CarOrder GROUP BY OrderStatus", conn)
    fig = px.pie(df, names="OrderStatus", values="Count", title="Orders by Status")
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(df, use_container_width=True)

elif choice == "Customer Purchase Report":
    df = pd.read_sql("""
        SELECT b.Customer_ID, CONCAT(b.FirstName,' ',COALESCE(b.LastName,'')) AS CustomerName,
               c.Brand, c.CarName, c.Model, co.OrderDate, co.OrderStatus, co.DownPayment
        FROM CarOrder co
        JOIN Buyer b ON co.Customer_ID = b.Customer_ID
        JOIN Car c ON co.SerialNumber = c.SerialNumber
        ORDER BY co.OrderDate
    """, conn)
    st.dataframe(df, use_container_width=True)

elif choice == "Current Inventory":
    df = pd.read_sql("""
        SELECT Brand, CarName, Model, ManufacturingYear, SalePrice, StockQuantity
        FROM Car ORDER BY StockQuantity DESC, SalePrice DESC
    """, conn)
    fig = px.bar(df, x="CarName", y="StockQuantity", color="Brand", title="Stock by Vehicle")
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(df, use_container_width=True)

elif choice == "Unsold Vehicles":
    df = pd.read_sql("""
        SELECT c.SerialNumber, c.Brand, c.CarName, c.Model, c.ManufacturingYear, c.StockQuantity
        FROM Car c
        LEFT JOIN CarOrder co ON c.SerialNumber = co.SerialNumber
        WHERE co.SerialNumber IS NULL
    """, conn)
    st.dataframe(df, use_container_width=True)

elif choice == "Low Stock Alert":
    df = pd.read_sql("""
        SELECT SerialNumber, Brand, CarName, Model, StockQuantity
        FROM Car WHERE StockQuantity <= 1 ORDER BY StockQuantity ASC
    """, conn)
    st.dataframe(df, use_container_width=True)

elif choice == "Update Order Status":
    if not can_edit:
        st.warning("Your account role doesn't have permission to update orders.")
    else:
        orders = pd.read_sql("SELECT Order_ID, OrderStatus FROM CarOrder ORDER BY Order_ID", conn)
        order_id = st.selectbox("Order", orders["Order_ID"])
        current_status = orders.loc[orders["Order_ID"] == order_id, "OrderStatus"].iloc[0]
        st.write(f"Current status: **{current_status}**")

        statuses = ["Pending", "Confirmed", "Delivered"]
        new_status = st.selectbox("New status", statuses, index=statuses.index(current_status))

        if st.button("Update status", type="primary"):
            cur = conn.cursor()
            try:
                cur.execute("UPDATE CarOrder SET OrderStatus = %s WHERE Order_ID = %s", (new_status, order_id))
                conn.commit()
                st.success(f"Order {order_id} updated to '{new_status}'.")
                st.rerun()
            except mysql.connector.Error as e:
                conn.rollback()
                st.error(f"Update blocked: {e}")
            finally:
                cur.close()
