from paramiko import SSHClient
import paramiko

client = SSHClient()

HOST_LIST = [
    "SERVER1",
    "SERVER2",
    "SERVER3",
    ]

def adm_account(host):
    try:
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(str(host), username='USERNAME', password='PASSWORD', timeout=10)
        print("Auth Successful for Server: " + host + " with ADM Account")
        client.close()

    except:
        print("Auth Error for Server: " + host + " with ADM Account")


def service_account(host):
    try:
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(str(host), username='USERNAME', password='PASSWORD', timeout=10)
        print("Auth Successful for Server: " + host + " with SERVICE Account")
        client.close()

    except:
        print("Auth Error for Server: " + host + " with SERVICE Account")


for i in HOST_LIST:
    adm_account(i)
    service_account(i)
