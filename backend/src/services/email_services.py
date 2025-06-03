import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from os import getenv
from dotenv import load_dotenv
import datetime

def html_template(secret_code):
    return ""

def send_secret_via_email(recipient_email, secret_code):
    sender_email = getenv('GMAIL_EMAIL')
    app_password = getenv('GMAIL_APP_PASSWORD')
    
    message = MIMEMultipart()
    message['From'] = 'no-reply@email.com'
    message['To'] = recipient_email
    message['Subject'] = "Your Cerification Code"

    message.attach(MIMEText(html_template(secret_code), 'html'))
    
    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(sender_email, app_password)
            server.sendmail(sender_email, recipient_email, message.as_string())
        return True
    except:
        return False