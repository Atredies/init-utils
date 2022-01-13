# Simple email sending functionality that works with py2 and py3
# It accepts different arguments and attachements to send via smtp

# Import smtplib for the actual sending function
import smtplib
# Here are the email package modules we'll need
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import email
import email.mime.application
# Here are System modules:
import os, socket, getpass, time, sys, sqlite3


# Static Variables:
# Delimitator for email splitting:
COMMASPACE = ", "

# Attachment varaibles
attachment_yes = "attach"
attachment_no = "noattach"
python_version_check = 3


# GET SERVER INFO:
# Get Hostname & FQDN:
hostfqdn_list = (socket.getfqdn()).split(".")

# Get Hostname:
hostname = hostfqdn_list[0]

# Get Stage
stage = hostfqdn_list[1] + "." + hostfqdn_list[2]

# SMTP Server:
smtpServer = "mailgate." + stage

# Get Username:
username = getpass.getuser()

# Get Local time:
localtime = time.asctime(time.localtime(time.time()))

# Email List:
default_list =[
    "email@email.com",
    "email@email.com",
    "email@email.com",
    "email@email.com"
]

# Arguement number handler
if len(sys.argv) == 3:
    report_type = sys.argv[1]
    requires_attachment = sys.argv[2]


elif len(sys.argv) == 4:
    report_type = sys.argv[1]
    requires_attachment = sys.argv[2]
    attachment_path = sys.argv[3]


else:
    print("Could not determine number of arguements")
    exit


# Database Connection:
cwd = os.path.dirname(os.path.abspath(__file__))
db_file = os.path.join(cwd, 'spamcannon.db')
conn = sqlite3.connect(db_file)
c = conn.cursor()
print("Opened database successfully")


# Defines CI and Inbox based on Server
serverinfo = c.execute("SELECT * FROM serverinfo")


for info in serverinfo:
    if info[1] == hostname:
        ci_name = info[2]
        inbox_name = info[3]
        
        
# Defines email components and case
cases = c.execute("SELECT * FROM cases")


for case_type in cases:
    
    if case_type[1] == report_type:
        email_subject = case_type[2] + ' ' + ci_name + ' at ' + localtime
        select_body = c.execute("SELECT * FROM emailbody WHERE id = ?", str(case_type[3]))
        
        
    for body in select_body:
        
        if case_type[3] == 2:
            email_body = body[1] + ' ' + ci_name + ' ' + body[2]
            
            
        else:
            email_body = body[1] + ' ' + ci_name + " folder. The " + inbox_name + ' ' + body[2]

if requires_attachment == attachment_yes:
    report_name = attachment_path.split("/")[-1]


elif requires_attachment == attachment_no:
    attachment_path = "Not required"
    print("Statement is: " + str(requires_attachment) + ". No attachement required")


# From and To Addresses
toaddr = default_list
fromaddr = username + "@" + hostname + "." + stage


# Report import:
def attachment_handler_func():
    global report_name
    
    if requires_attachment == attachment_no:
        print(str(attachment_path) + " not needed... " + "\n")
    
    
    elif requires_attachment == attachment_yes:
        report_name = attachment_path.split("/")[-1]
        print(str(attachment_path) + " has been attached... " + "\n" )
    
    
    else:
        print(str(attachment_path) + " could not be handled... " + "\n")
        exit

# SMTP CONFIGURATION:
def smtp_config_func():
    global msg 
    global email_text
 
 
 # Create the container (outer) email message.
    msg = MIMEMultipart()
    msg["Subject"] = email_subject
    msg["From"] = fromaddr
    msg["To"] = COMMASPACE.join(toaddr)
# Record the MIME types of both parts - text/plain and text/html.
    email_text = MIMEText(email_body, "plain")
 # Sending email with attachement


if requires_attachment == attachment_yes:
 
 # TXT file definition:
    filename = str(attachment_path)
    if int(sys.version[0]) == python_version_check:
        f = open(filename, 'rb')
        attachment = email.mime.application.MIMEApplication(f.read(),_subtype="txt")
        f.close()
    
    
    else:
        f = file(filename)
        attachment = MIMEText(f.read())
        attachment.add_header("Content-Disposition", "attachment", filename=report_name)
        msg.attach(attachment)
 # Attach parts into message container.
        msg.attach(email_text)
        print("Email composed successfully with attachment")
 # Sending email without attachement


elif requires_attachment == attachment_no:
 # Attach parts into message container.
    msg.attach(email_text)
    print("Email composed successfully without attachment")


else:
    print(requires_attachment + " is not a valid option")
    exit
 # SMTP RELAY CONFIG:
 # Send the email via our own SMTP server.
    s = smtplib.SMTP(smtpServer)
    s.sendmail(fromaddr, toaddr, msg.as_string())
    s.quit()
    print("Email sent successfully")
    
    
    def main():
        attachment_handler_func()
        smtp_config_func()
        conn.close
    main()