import bcrypt

# Pick any accounts from your UserAccount table + whatever demo password
# you want each one to log in with.
DEMO_LOGINS = {
    "admin":     "admin123",
    "mmoore":    "owner123",
    "asanchez": "sales123",
}

for username, plain_password in DEMO_LOGINS.items():
    hashed = bcrypt.hashpw(plain_password.encode(), bcrypt.gensalt()).decode()
    print(f"UPDATE UserAccount SET PasswordHash = '{hashed}' WHERE Username = '{username}';")
