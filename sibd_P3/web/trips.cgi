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
print('input {border: black; color: black; padding: 4px 20px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; transition-duration: 0.4s; cursor: pointer; border-radius: 4px;}')
print('input[type=submit] {background-color: white; color: black; border: 2px solid #012a40;}')
print('input[type=submit]:hover {background-color: #d4f0ff; color: black;}')
print('input[type=text] {background-color: white; color: black; border: 2px solid #012a40; font-family: Trebuchet MS;}')
print('input[type=text]:hover {background-color: #d4f0ff; color: black;}')
print('input[type=date] {background-color: white; color: black; border: 2px solid #012a40; font-family: Trebuchet MS;}')
print('input[type=date]:hover {background-color: #d4f0ff; color: black;}')
print('input[type=number] {background-color: white; padding: 1px 10px; color: black; border: 2px solid #012a40; font-family: Trebuchet MS;}')
print('input[type=number]:hover {background-color: #d4f0ff; color: black;}')
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
    print("<p style='font-size:180%;'>Trips</p>")
    print('<p>What would you like to do?</p>')
    print(f'<form action="/{user}/trips.cgi"><input type="submit" name="action" value="Book a trip"/></form>')
    print(f'<form action="/{user}/trips.cgi"><input type="submit" name="action" value="Remove trips"/></form>')
    print(f'<form action="/{user}/trips.cgi"><input type="submit" name="action" value="List all locations"/></form>')
    print(f'<form action="/{user}/trips.cgi"><input type="submit" name="action" value="List all trips"/></form>')
   
  # Form to make a trip
  elif act == "Book a trip":
    print("<p style='font-size:140%;'>Fill in the information for the trip:</p>")
    print(f'<form action="/{user}/trips.cgi">')
    print('<label for="reserv" style="font-family: Trebuchet MS">Choose the associated reservation:</label>')
    print('<select name="reserv" id="reserv" required>')
    cursor.execute('SELECT * FROM reservation ORDER BY start_date, responsible;')
    reserv_result = cursor.fetchall()
    for i, row in enumerate(reserv_result):
      print(f'<option value="res{i}" style="font-family: Trebuchet MS">{row[0]} - {row[1]} ({row[3]}, Responsible: {row[4]})</option>')
    print('</select><br>')
    print('<br><label for="depart">Departure date:</label><br>')
    print('<input type="date" id="depart" name="depart" value="" required><br>')
    print('<label for="arriv">Arrival date:</label><br>')
    print('<input type="date" id="arriv" name="arriv" value="" required><br>')
    print('<br><label for="origin" style="font-family: Trebuchet MS">Choose an origin:</label>')
    print('<select name="origin" id="origin" required>')
    cursor.execute('SELECT * FROM location ORDER BY country_name, name;')
    location_list = cursor.fetchall()
    for i, row in enumerate(location_list):
      print(f'<option value="loc{i}" style="font-family: Trebuchet MS">{row[2]}, {row[3]} ({row[0]}, {row[1]})</option>')
    print('</select><br>')
    print('<br><label for="destin" style="font-family: Trebuchet MS">Choose a destination:</label>')
    print('<select name="destin" id="destin" required>')
    for i, row in enumerate(location_list):
      print(f'<option value="loc{i}" style="font-family: Trebuchet MS">{row[2]}, {row[3]} ({row[0]}, {row[1]})</option>')
    print('</select><br><br>')
    print('<label for="insur">Insurance number:</label>')
    print('<br><input type="number" id="insur" name="insur" min="0"><br><br>')
    print('<label for="skipper" style="font-family: Trebuchet MS">Choose a skipper for this trip:</label>')
    print('<select name="skipper" id="skipper" required>')
    cursor.execute("SELECT * FROM sailor ORDER BY firstname, surname;")
    sailor_list = cursor.fetchall()
    for i, row in enumerate(sailor_list):
      print(f'<option value="sailor{i}" style="font-family: Trebuchet MS">{row[0]} {row[1]} ({row[2]})</option>')
    print('</select><br><br>')    
    print(f'<input type="submit" name="action" value="Submit"></form><form action="/{user}/trips.cgi"><input type="submit" value="Back"/></form>')
    
  # Adding a trip
  elif act == "Submit":
    dep = form.getvalue('depart')
    arr = form.getvalue('arriv')
    orig = form.getvalue('origin')[3:]
    dest = form.getvalue('destin')[3:]
    insur = form.getvalue('insur')
    reserv = form.getvalue('reserv')[3:]
    skip = form.getvalue('skipper')[6:]
    cursor.execute(f"SELECT email FROM sailor ORDER BY firstname, surname LIMIT 1 OFFSET {skip};")
    selected_skipper = cursor.fetchall()[0][0]
    cursor.execute(f"SELECT * FROM reservation ORDER BY start_date, responsible LIMIT 1 OFFSET {reserv};")
    reserv_row = cursor.fetchall()[0]
    cursor.execute(f"SELECT sailor FROM authorised WHERE start_date = '{reserv_row[0]}' AND end_date = '{reserv_row[1]}' AND boat_country = '{reserv_row[2]}' AND cni = '{reserv_row[3]}';")
    authorised = cursor.fetchall()
    if orig == dest:
        print("<p>You can't pick the same origin and destination!</p>")
    elif selected_skipper not in [element[0] for element in authorised]:
        print("<p>The selected skipper is not an authorised sailor for this reservation.</p>")
    else:
        cursor.execute(f"SELECT latitude, longitude FROM location ORDER BY country_name, name LIMIT 1 OFFSET {orig};")
        origin_coord = cursor.fetchall()[0]
        cursor.execute(f"SELECT latitude, longitude FROM location ORDER BY country_name, name LIMIT 1 OFFSET {dest};")
        dest_coord = cursor.fetchall()[0]       
        add_trip_query = "INSERT INTO trip VALUES ('%(dep)s', '%(arr)s', %(ins)i, %(ola)f, %(olo)f, %(dla)f, %(dlo)f, '%(ski)s', '%(rsd)s', '%(red)s', '%(bco)s', '%(cni)s');" % {'dep': dep, 'arr': arr, 'ins': int(insur),'ola': origin_coord[0], 'olo': origin_coord[1], 'dla': dest_coord[0], 'dlo': dest_coord[1], 'ski': selected_skipper, 'rsd': reserv_row[0], 'red': reserv_row[1], 'bco': reserv_row[2], 'cni': reserv_row[3]}
        cursor.execute(add_trip_query)
        print('<p>Trip confirmed!</p>')
    print(f'<form action="/{user}/trips.cgi"><input type="submit" value="Back"/></form>')

  # Form to remove trips
  elif act == "Remove trips":
    print("<p style='font-size:140%;'>Select all trips you would like to remove:</p>")
    print(f'<form action="/{user}/trips.cgi">')
    cursor.execute('SELECT * FROM trip ORDER BY takeoff, arrival, skipper;')
    result = cursor.fetchall()
    for i, row in enumerate(result):
      cursor.execute(f"SELECT name, country_name FROM location WHERE latitude = '{row[3]}' AND longitude = '{row[4]}';")
      o = cursor.fetchall()[0]
      cursor.execute(f"SELECT name, country_name FROM location WHERE latitude = '{row[5]}' AND longitude = '{row[6]}';")
      d = cursor.fetchall()[0]
      print(f'<input type="checkbox" id="trip{i}" name="trip{i}" value={i}>')
      print(f'<label for="trip{i}" style="font-family: Trebuchet MS">{row[0]} to {row[1]}, {o[0]} ({o[1]}) -> {d[0]} ({d[1]}) | From reservation ({row[8]} - {row[9]}), {row[10]}, {row[11]} | Skipper: {row[7]}</label><br>')
    print('<br><input type="submit" name ="action" value="Remove"><input type="submit" value="Back"/>')
    print('</form>')
  
  # Removing trips
  elif act == "Remove":
    form_keys = form.keys()
    form_keys.remove('action')
    rows_to_remove = [form.getvalue(key) for key in form_keys]
    query = ""
    for i, row in enumerate(sorted([int(r) for r in rows_to_remove])):
        trip_row_query = f"SELECT takeoff, reservation_start_date, reservation_end_date, boat_country, cni FROM trip ORDER BY takeoff, arrival, skipper LIMIT 1 OFFSET {row}"
        cursor.execute(trip_row_query)
        trip_row = cursor.fetchall()[0]
        query += f"DELETE FROM trip WHERE takeoff = '{trip_row[0]}' AND reservation_start_date = '{trip_row[1]}' AND reservation_end_date = '{trip_row[2]}' AND boat_country = '{trip_row[3]}' AND cni = '{trip_row[4]}';"
    cursor.execute(query)
    if len(rows_to_remove) > 1:
        print("<p>A total of {} trips were removed.</p>".format(len(rows_to_remove)))
    elif len(rows_to_remove) == 1:
        print("<p>A trip was removed.</p>")
    else:
        print("<p>No trips were removed.</p>")
    print(f'<form action="/{user}/trips.cgi"><input type="submit" value="Back"/></form>')

  # Form to list all locations
  elif act == "List all locations":
    cursor.execute("SELECT * FROM location ORDER BY country_name, name;")
    result = cursor.fetchall()
    num = len(result)
    # Displaying results
    print('<p>There are a total of {} locations registered</p>'.format(num))
    print('<table border="5">')
    print('<tr><td>Latitude</td><td>Longitude</td><td>Name</td><td>Country</td></tr>')
    for row in result:
        print('<tr>')
        for value in row:
            print('<td>{}</td>'.format(value))
        print('</tr>')
    print('</table><br>')
    print(f'<form action="/{user}/trips.cgi"><input type="submit" value="Back"/></form>')

  # Form to list all reservations
  elif act == "List all trips":
    cursor.execute("SELECT * FROM trip;")
    result = cursor.fetchall()
    num = len(result)
    # Displaying results
    print('<p>There are a total of {} trips registered</p>'.format(num))
    print('<table border="5">')
    print('<tr><td>Start date</td><td>End date(s)</td><td>Insurance</td><td>Starting latitude</td><td>Starting longitude</td><td>Ending latitude</td><td>Ending longitude</td><td>Skipper</td><td>Reservation start date</td><td>Reservation end date</td><td>Boat Country</td><td>CNI</td></tr>')
    for row in result:
        print('<tr>')
        for value in row:
            print('<td>{}</td>'.format(value))
        print('</tr>')
    print('</table><br>')
    print(f'<form action="/{user}/trips.cgi"><input type="submit" value="Back"/></form>')
  
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