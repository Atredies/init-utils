import win32com.client

# Initialize Outlook app:
outlook = win32com.client.Dispatch('outlook.application')

# In outlook, email, meeting invite, calendar, appointment etc... are all considered as Item object
# Create Outlook email object:
mail = outlook.CreateItem(0)

mail.To = 'somebody@company.com'
mail.Subject = 'Sample Email'
mail.Body = "This is the normal body"

# Additional Options:
#mail.HTMLBody = '<h3>This is HTML Body</h3>'
#mail.Attachments.Add('c:\\sample.xlsx')
#mail.Attachments.Add('c:\\sample2.xlsx')
#mail.CC = 'somebody@company.com'

if __name__ == '__main__':
    mail.Send()