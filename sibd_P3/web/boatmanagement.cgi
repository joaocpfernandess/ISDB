#!/usr/bin/python3

import psycopg2
import login
user = login.IST_ID


print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>ISDB Boat Information</title>')

# STYLING
print('<style>')
print('.button {border: none; color: white; padding: 2px 15px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; transition-duration: 0.4s; cursor: pointer; border-radius: 4px;}')
print('.button1 {background-color: white; color: black; border: 2px solid #012a40;}')
print('.button1:hover {background-color: #d4f0ff; color: black;}')
print('.button2 {background-color: white; color: black; border: 2px solid #012a40;}')
print('.button2:hover {background-color: #008CBA; color: white;}')
print('input {border: none; color: white; padding: 4px 20px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; transition-duration: 0.4s; cursor: pointer; border-radius: 4px;}')
print('input[type=submit] {background-color: white; color: black; border: 2px solid #012a40;}')
print('input[type=submit]:hover {background-color: #d4f0ff; color: black;}')
print('p {font-family: Trebuchet MS}')
print('</style>')

print('</head>')
print('<body>')
connection = None

try:
  # Creating connection
  connection = psycopg2.connect(login.credentials) 
  cursor = connection.cursor()

  print("<p style='font-size:300%;'>Boat Management System</p>")
  print('<p>Click here to manage your sailors</p>')
  print(f'<form action="/{user}/sailors.cgi"><input type="submit" value="Sailors"/></form>')
  print('<p>Click here to manage your reservations')
  print(f'<form action="/{user}/reservations.cgi""><input type="submit" value="Reservations"/></form>')
  print('<p>Click here to manage your trips')
  print(f'<form action="/{user}/trips.cgi"><input type="submit" value="Trips"/></form>')

  # Closing connection
  cursor.close()

except Exception as e:
  print('<h1>An error occurred.</h1>')
  print('<p>{}</p>'.format(e))

finally:
  if connection is not None:
    connection.close()

print('</body>')
print('</html>')