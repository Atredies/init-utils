# File used to create database and cases for spam_cannon.py

import sqlite3
import os

cwd = os.path.dirname(os.path.abspath(__file__))
db_file = os.path.join(cwd, 'spamcannon.db')
conn = sqlite3.connect(db_file)
c = conn.cursor()
print("Opened database successfully")


# Email Body composition:
c.execute('''CREATE TABLE IF NOT EXISTS emailbody (
 id INT PRIMARY KEY NOT NULL,
 bodyone TEXT NOT NULL,
 bodytwo TEXT NOT NULL
 );''')
c.execute("INSERT INTO emailbody VALUES (1, 'Please move this email to the', 'will request a ticket if needed' );")


# Case selection & Subject
c.execute('''CREATE TABLE IF NOT EXISTS cases (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 casetype TEXT NOT NULL,
 subject TEXT NOT NULL,
 cases_id INT NOT NULL,
 FOREIGN KEY(cases_id) REFERENCES cases(id)
 );''')


# Default email body is 1 FK
c.execute("INSERT INTO cases VALUES (1, 'alert_name', 'Subject', 'FK' );")



# Servername, CI & Inbox
c.execute('''CREATE TABLE IF NOT EXISTS serverinfo (
 id INT PRIMARY KEY NOT NULL,
 servername TEXT NOT NULL,
 ciname TEXT NOT NULL,
 inboxname TEXT NOT NULL
 );''')
c.execute("INSERT INTO serverinfo VALUES (1, 'server', 'ci', 'inbox');")

# Commit and Close
conn.commit()
conn.close()
