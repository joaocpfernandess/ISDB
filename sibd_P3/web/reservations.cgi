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
print('input[type=date] {background-color: white; color: black; border: 2px solid #012a40; font-family: Trebuchet MS;}')
print('input[type=date]:hover {background-color: #d4f0ff; color: black;}')
print('p {font-family: Trebuchet MS}')
print('label {font-family: Trebuchet MS}')
print('option {font-family: Trebuchet MS}')
print('select {font-family: Trebuchet MS; padding: 2px 10px; text-decoration: none; display: inline-block; font-size: 16px; transition-duration: 0.4s; cursor: pointer; border-radius: 2px;}')
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
    print("<p style='font-size:180%;'>Reservations</p>")
    print('<p>What would you like to do?</p>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" name="action" value="Make a reservation"/></form>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" name="action" value="Delete reservations"/></form>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" name="action" value="Authorise/Deauthorise sailors"/></form>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" name="action" value="List all reservations"/></form>')
   
  # Form to make reservations
  elif act == "Make a reservation":
    print("<p style='font-size:140%;'>Fill in the information for the reservation:</p>")
    print(f'<form action="/{user}/reservations.cgi">')
    print('<label for="start">Start date:</label><br>')
    print('<input type="date" id="start" name="start" value="" required><br>')
    print('<label for="end">End date:</label><br>')
    print('<input type="date" id="end" name="end" value="" required><br>')
    print('<br><label for="boat" style="font-family: Trebuchet MS">Choose a boat:</label>')
    print('<select name="boat" id="boat" required>')
    cursor.execute('SELECT name, cni, country FROM boat ORDER BY name;')
    boat_result = cursor.fetchall()
    for i, row in enumerate(boat_result):
      print(f'<option value="boat{i}" style="font-family: Trebuchet MS">{row[0]} ({row[2]}, {row[1]})</option>')
    print('</select><br>')
    print('<label for="resp">Choose a responsible (automatically becomes authorised):</label>')
    print('<select name="resp" id="resp" required>')
    cursor.execute('SELECT * FROM sailor WHERE email IN (SELECT * FROM senior) ORDER BY firstname;')
    resp_result = cursor.fetchall()
    for i, row in enumerate(resp_result):
      print(f'<option value="sen{i}" style="font-family: Trebuchet MS">{row[0]} {row[1]} ({row[2]})</option>')
    print('</select><br>')
    print(f'<input type="submit" name="action" value="Submit"></form><form action="/{user}/reservations.cgi"><input type="submit" value="Back"/></form>')
    
  # Adding a reservation
  elif act == "Submit":
    sd = form.getvalue('start')
    ed = form.getvalue('end')
    boat = form.getvalue('boat')
    cursor.execute(f"SELECT country, cni FROM boat ORDER BY name LIMIT 1 OFFSET {boat[4:]}")
    selected_boat = cursor.fetchall()
    resp = form.getvalue('resp')
    cursor.execute(f"SELECT email FROM sailor WHERE email IN (SELECT email FROM senior) ORDER BY firstname LIMIT 1 OFFSET {resp[3:]}")
    selected_resp = cursor.fetchall()
    date_interval_query = "INSERT INTO date_interval VALUES ('%(sd)s', '%(ed)s');" % {'sd': sd, 'ed': ed}
    reservation_query = "INSERT INTO reservation VALUES ('%(sd)s', '%(ed)s', '%(c)s', '%(cni)s', '%(resp)s');" % {'sd': sd, 'ed': ed, 'c': selected_boat[0][0], 'cni': selected_boat[0][1], 'resp': selected_resp[0][0]}
    authorised_query = "INSERT INTO authorised VALUES ('%(sd)s', '%(ed)s', '%(c)s', '%(cni)s', '%(resp)s');" % {'sd': sd, 'ed': ed, 'c': selected_boat[0][0], 'cni': selected_boat[0][1], 'resp': selected_resp[0][0]}
    cursor.execute(date_interval_query + reservation_query + authorised_query)
    print('<p>Reservation added!</p>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" value="Back"/></form>')

  # Form to remove reservations
  elif act == "Delete reservations":
    print("<p style='font-size:140%;'>Select all reservations you would like to remove:</p>")
    print(f'<form action="/{user}/reservations.cgi">')
    cursor.execute('SELECT * FROM reservation ORDER BY start_date;')
    result = cursor.fetchall()
    for i, row in enumerate(result):
      print(f'<input type="checkbox" id="reserv{i}" name="reserv{i}" value={i}>')
      print(f'<label for="reserv{i}" style="font-family: Trebuchet MS">{row[0]} - {row[1]} ({row[3]}, Responsible: {row[4]})</label><br>')
    print('<br><input type="submit" name ="action" value="Remove"><input type="submit" value="Back"/>')
    print('</form>')
  
  # Removing sailors
  elif act == "Remove":
    form_keys = form.keys()
    form_keys.remove('action')
    rows_to_remove = [form.getvalue(key) for key in form_keys]
    query = ""
    for i, row in enumerate(sorted([int(r) for r in rows_to_remove])):
        reserv_row_query = f"SELECT * FROM reservation ORDER BY start_date LIMIT 1 OFFSET {row}"
        cursor.execute(reserv_row_query)
        reserv_row = cursor.fetchall()[0]
        query += f"DELETE FROM authorised WHERE start_date = '{reserv_row[0]}' AND end_date = '{reserv_row[1]}' AND boat_country = '{reserv_row[2]}' AND cni = '{reserv_row[3]}';"
        query += f"DELETE FROM trip WHERE reservation_start_date = '{reserv_row[0]}' AND reservation_end_date = '{reserv_row[1]}' AND boat_country = '{reserv_row[2]}' AND cni = '{reserv_row[3]}';;"
        query += f"DELETE FROM reservation WHERE start_date = '{reserv_row[0]}' AND end_date = '{reserv_row[1]}' AND country = '{reserv_row[2]}' AND cni = '{reserv_row[3]}' AND responsible = '{reserv_row[4]}';"
        cursor.execute(f"SELECT * FROM reservation WHERE start_date = '{reserv_row[0]}' AND end_date = '{reserv_row[1]}';")
        if len(cursor.fetchall()) == 1:
            query += f"DELETE FROM date_interval WHERE start_date = '{reserv_row[0]}' AND end_date = '{reserv_row[1]}';"
    cursor.execute(query)
    if len(rows_to_remove) > 1:
        print("<p>A total of {} reservations were removed.</p>".format(len(rows_to_remove)))
    elif len(rows_to_remove) == 1:
        print("<p>A reservation was removed.</p>")
    else:
        print("<p>No reservation was removed</p>")
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" value="Back"/></form>')

  # Form to authorise/deauthorise sailors
  elif act == "Authorise/Deauthorise sailors":
    print("<p style='font-size:140%;'>Select a reservation you would like to change</p>")
    print(f'<form action="/{user}/reservations.cgi">')
    print('<select name="pick_res" id="pick_res" required>')
    cursor.execute('SELECT * FROM reservation ORDER BY start_date;')
    reserv_result = cursor.fetchall()
    for i, row in enumerate(reserv_result):
      print(f'<option value="res{i}" style="font-family: Trebuchet MS">{row[0]} - {row[1]} ({row[3]}) - Responsible: {row[4]})</option>')
    print('</select><br>') 
    print('<input type="submit" name="action" value="Proceed"></form>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" value="Back"/></form>')

  elif act == "Proceed":
    sel_row = form.getvalue('pick_res')[3:]
    cursor.execute('SELECT * FROM reservation ORDER BY start_date LIMIT 1 OFFSET {};'.format(sel_row))
    picked_row = cursor.fetchall()[0]
    cursor.execute("SELECT firstname, surname FROM sailor WHERE email = '{}'".format(picked_row[4]))
    responsible_name = ' '.join(list(cursor.fetchall()[0]))
    cursor.execute(f"SELECT * FROM sailor WHERE email IN (SELECT sailor FROM authorised WHERE start_date = '{picked_row[0]}' AND end_date = '{picked_row[1]}' AND boat_country = '{picked_row[2]}' AND cni = '{picked_row[3]}' AND sailor <> '{picked_row[4]}');")
    authorised = cursor.fetchall()
    cursor.execute(f"SELECT * FROM sailor WHERE email NOT IN (SELECT sailor FROM authorised WHERE start_date = '{picked_row[0]}' AND end_date = '{picked_row[1]}' AND boat_country = '{picked_row[2]}' AND cni = '{picked_row[3]}');")
    not_authorised = cursor.fetchall()
    print(f"<p>The sailor responsible for this reservation is {responsible_name} ({picked_row[4]}).</p>")
    print(f"<form action='/{user}/reservations.cgi'")
    if len(not_authorised) == 0:
        print("<p>There are no sailors you can AUTHORISE</p>")
    else:
        print("<p style='font-family: Trebuchet MS'>Select the sailors you would like to AUTHORISE:</p>")
        for i, row in enumerate(not_authorised):
            print(f'<input type="checkbox" id="auth{i}" name="auth{i}" value={row[2]}>')
            print(f'<label for="auth{i}" style="font-family: Trebuchet MS">{row[0]} {row[1]} ({row[2]})</label><br>')
    if len(authorised) == 0:
        print("<p>There are no sailors you can DEAUTHORISE.</p>")
    else:
        print("<p>Select the sailors you would like to DEAUTHORISE:</p>")
        for i, row in enumerate(authorised):
            print(f'<input type="checkbox" id="deauth{i}" name="deauth{i}" value={row[2]}>')
            print(f'<label for="auth{i}" style="font-family: Trebuchet MS">{row[0]} {row[1]} ({row[2]})</label><br>')
    print(f"<input type='hidden' name='reser' value='{sel_row}'>")
    print('<br><input type="submit" name="action" value="Confirm"></form>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" value="Back"/></form>')

  elif act == "Confirm":
    form_keys = form.keys()
    form_keys.remove('action')
    sel_row = form.getvalue('reser')
    cursor.execute('SELECT * FROM reservation ORDER BY start_date LIMIT 1 OFFSET {};'.format(sel_row))
    picked_row = cursor.fetchall()[0]
    deauthorise = "(" + ", ".join(["'" + form.getvalue(key) + "'" for key in form_keys if key.startswith('deauth')]) + ")"
    rows_to_add = [picked_row[:-1] + tuple([em]) for em in [form.getvalue(key) for key in form_keys if key.startswith('auth')]]
    add_query = "INSERT INTO authorised VALUES "
    add_query += ", ".join(["(" + ', '.join([f"'{val}'" for val in row ]) + ")" for row in rows_to_add])
    add_query += ";"
    remove_query = f"DELETE FROM authorised WHERE start_date = '{picked_row[0]}' AND end_date = '{picked_row[1]}' AND boat_country = '{picked_row[2]}' AND cni = '{picked_row[3]}' AND sailor IN {deauthorise};"
    if len([key for key in form_keys if key.startswith('auth')]) > 0:
        cursor.execute(add_query)
        print(f"<p>{len([key for key in form_keys if key.startswith('auth')])} sailors were authorised.</p>")
    else:
        print("<p>No sailor was authorised.</p>")
    if len([key for key in form_keys if key.startswith('deauth')]) > 0:
        cursor.execute(remove_query)
        print(f"<p>{len([key for key in form_keys if key.startswith('deauth')])} sailors were deauthorised.</p>")
    else:
        print("<p>No sailor was deauthorised.</p>")
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" value="Back"/></form>')

  # Form to list all reservations
  elif act == "List all reservations":
    cursor.execute("SELECT * FROM reservation;")
    result = cursor.fetchall()
    num = len(result)
    # Displaying results
    print('<p>There are a total of {} reservations registered</p>'.format(num))
    print('<table border="5">')
    print('<tr><td>Start date</td><td>End date(s)</td><td>Country</td><td>CNI</td><td>Responsible</td></tr>')
    for row in result:
        print('<tr>')
        for value in row:
            print('<td>{}</td>'.format(value))
        print('</tr>')
    print('</table><br>')
    print(f'<form action="/{user}/reservations.cgi"><input type="submit" value="Back"/></form>')
  
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