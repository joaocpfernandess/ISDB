#!/usr/bin/python3

import psycopg2
import login
import cgi

user = login.IST_ID
form = cgi.FieldStorage()
act = form.getvalue('action')

print('Content-type:text/html\n\n')
print('<html>')
print('<head>')
print('<title>ISDB Boat Information</title>')

# STYLING
print('<style>')
print('input {border: black; color: white; padding: 4px 20px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; transition-duration: 0.4s; cursor: pointer; border-radius: 4px;}')
print('input[type=submit] {background-color: white; color: black; border: 2px solid #012a40;}')
print('input[type=submit]:hover {background-color: #d4f0ff; color: black;}')
print('input[type=text] {background-color: white; color: black; border: 2px solid #012a40; font-family: Trebuchet MS;}')
print('input[type=text]:hover {background-color: #d4f0ff; color: black;}')
print('p {font-family: Trebuchet MS}')
print('</style>')

print('</head>')
print('<body>')
connection = None

try:
  # Creating connection
  connection = psycopg2.connect(login.credentials)
  connection.autocommit	= False 
  cursor = connection.cursor()
  
  # 'Main' page
  if act is None:
    print("<p style='font-size:180%;'>Sailors</p>")
    print('<p>What would you like to do?</p>')
    print(f'<form action="/{user}/sailors.cgi"><input type="submit" name="action" value="Add a sailor"/></form>')
    print(f'<form action="/{user}/sailors.cgi"><input type="submit" name="action" value="Remove sailors"/></form>')
    print(f'<form action="/{user}/sailors.cgi"><input type="submit" name="action" value="List all sailors"/></form>')
   
  # Form to add sailors
  elif act == "Add a sailor":
    print("<p style='font-size:140%;'>Fill in the information for the sailor to be added:</p>")
    print(f'<form action="/{user}/sailors.cgi">')
    print('<label for="fname" style="font-family: Trebuchet MS">First name:</label><br>')
    print('<input type="text" id="fname" name="fname" value="" required><br>')
    print('<label for="lname" style="font-family: Trebuchet MS">Last name:</label><br>')
    print('<input type="text" id="lname" name="lname" value="" required><br>')
    print('<label for="email" style="font-family: Trebuchet MS">Email:</label><br>')
    print('<input type="text" id="email" name="email" value="" required><br>')
    print("<p>Is this sailor a junior or a senior?</p>")
    print('<input type="radio" id="isjunior" name="rank" value="jun" required>')
    print('<label for="isjunior" style="font-family: Trebuchet MS">Junior</label><br>')
    print('<input type="radio" id="issenior" name="rank" value="sen">')
    print('<label for="issenior" style="font-family: Trebuchet MS">Senior</label><br><br>')
    print('<input type="submit" name="action" value="Add"><input type="submit" value="Back"/>')
    print('</form>')

  # Adding a sailor
  elif act == "Add":
    fn = form.getvalue('fname')
    ln = form.getvalue('lname')
    em = form.getvalue('email')
    r = form.getvalue('rank') 
    sailor_query = "INSERT INTO sailor VALUES ('%(first)s', '%(last)s', '%(mail)s');" % {'first': fn, 'last': ln, 'mail': em}
    rank = "junior" if r == "jun" else "senior"
    specialization_query = "INSERT INTO %(rank)s VALUES ('%(mail)s');" % {'rank': rank, 'mail': em}
    cursor.execute(sailor_query + specialization_query)
    print('<p>Sailor added!</p>')
    print(f'<form action="/{form}/sailors.cgi"><input type="submit" value="Back"/></form>')

  # Form to remove sailors
  elif act == "Remove sailors":
    print("<p style='font-size:140%;'>Select all sailors you would like to remove:</p>")
    print("<p style='font-size:90%;'>NOTE: All records in tables that depend on these sailors will also be removed, meaning it can lead to the deletion of trips or reservations.</p>")
    print(f'<form action="/{user}/sailors.cgi">')
    cursor.execute('SELECT * FROM sailor ORDER BY firstname;')
    result = cursor.fetchall()
    #print(result)
    for i, row in enumerate(result):
      print(f'<input type="checkbox" id="sailor{i}" name="sailor{i}" value={row[2]}>')
      print(f'<label for="sailor{i}" style="font-family: Trebuchet MS">{row[0]} {row[1]} ({row[2]})</label><br>')
    print('<br><input type="submit" name ="action" value="Remove"><input type="submit" value="Back"/>')
    print('</form>')
  
  # Removing sailors
  elif act == "Remove":
    form_keys = form.keys()
    form_keys.remove('action')
    email_set = "('"+"', '".join([form.getvalue(key) for key in form_keys])+"')"
    jun_query = f"DELETE FROM junior WHERE email IN {email_set};"
    reserv_query = f"DELETE FROM reservation WHERE responsible IN {email_set};"
    sen_query = f"DELETE FROM senior WHERE email IN {email_set};"
    valid_query = f"DELETE FROM valid_for WHERE sailor IN {email_set};"
    certif_query = f"DELETE FROM sailing_certificate WHERE sailor IN {email_set};"
    trip_query = f"DELETE FROM trip WHERE skipper IN {email_set};"
    trip2_query = f"DELETE FROM trip WHERE (reservation_start_date, reservation_end_date, boat_country, cni) IN (SELECT start_date, end_date, country, cni FROM reservation WHERE responsible IN {email_set});"
    autho_query = f"DELETE FROM authorised WHERE sailor IN {email_set};"
    autho2_query = f"DELETE FROM authorised WHERE (start_date, end_date, boat_country, cni) IN (SELECT start_date, end_date, country, cni FROM reservation WHERE responsible IN {email_set});"
    sailor_query = f"DELETE FROM sailor WHERE email IN {email_set};"
    query = jun_query + autho_query + autho2_query + trip2_query + reserv_query + sen_query + valid_query + certif_query + trip_query + sailor_query
    cursor.execute(query)
    if len([form.getvalue(key) for key in form_keys]) > 1:
        print("<p>A total of {} sailors were removed.</p>".format(len([form.getvalue(key) for key in form_keys])))
    elif len([form.getvalue(key) for key in form_keys]) == 1:
        print("<p>A sailor was removed.</p>")
    else:
        print("<p>No sailor was removed</p>")
    print(f'<form action="/{user}/sailors.cgi"><input type="submit" value="Back"/></form>')

  # Form to list all sailors
  elif act == "List all sailors":
    cursor.execute("SELECT * FROM sailor WHERE email IN (SELECT * FROM senior);")
    senior_result = cursor.fetchall()
    num_sen = len(senior_result)
    cursor.execute("SELECT * FROM sailor WHERE email IN (SELECT * FROM junior);")
    junior_result = cursor.fetchall()
    num_jun = len(junior_result)
    # Displaying results
    print('<p>There are a total of {} sailors registered: {} seniors and {} juniors.</p>'.format(num_sen + num_jun, num_sen, num_jun))
    print('<p>Senior sailors:</p>')
    print('<table border="5">')
    print('<tr><td>First Name</td><td>Surname(s)</td><td>Email</td></tr>')
    for row in senior_result:
        print('<tr>')
        for value in row:
            print('<td>{}</td>'.format(value))
        print('</tr>')
    print('</table>')
    print('<p>Junior sailors:</p>')
    print('<table border="5">')
    print('<tr><td>First Name</td><td>Surname(s)</td><td>Email</td></tr>')
    for row in junior_result:
        print('<tr>')
        for value in row:
            print('<td>{}</td>'.format(value))
        print('</tr>')
    print('</table>')
    print(f'<form action="/{user}/sailors.cgi"><input type="submit" value="Back"/></form>')
  
  # Adding a return button
  print('<form action="boatmanagement.cgi"><input type="submit" value="Return to main page" style="background-color: #fceede"/></form>') 
  
  # Commiting and closing connection
  cursor.close()
  connection.commit()

except Exception as e:
  print('<h1>An error occurred.</h1>')
  print('<p>{}</p>'.format(e))
  print('<form action="boatmanagement.cgi"><input type="submit" value="Return to main page" style="background-color: #fceede"/></form>') 

finally:
  if connection is not None:
    connection.close()

print('</body>')
print('</html>')