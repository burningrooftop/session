' Session
' Session management object
'
' Usage:
'
' Calling project:
'
'    run "session", #session
'    #session new()
'    #session set("key1", "A string")
'    #session set("key2", str$(1234))
'    #session runProject("called_project")
'
' Called project:
'
'    run "session", #session
'    #session getSession(UrlKeys$)
'    a$ = #session value$("key1")
'    b = val(#session value$("key2"))
'    #session clear()
' ----------------------------------------------------------   

' Global variables
global database$ ' database name
global sessionId ' session id
global #lib      ' library object

[init]
  run "functionLibrary", #lib ' Load the library object

  ' Build the database name (stored in the projects directory)
  database$ = "projects" + #lib pathSeparator$() + "session_project" + #lib pathSeparator$() + "session.db"

  ' Create tables
  sqliteconnect #db, database$
  sql$ = "CREATE TABLE IF NOT EXISTS session (session_id INT NOT NULL, key TEXT NOT NULL, value TEXT, timestamp TEXT DEFAULT CURRENT_TIMESTAMP)"
  #db execute(sql$)
  sql$ = "CREATE UNIQUE INDEX IF NOT EXISTS session_pk ON session (session_id, key)"
  #db execute(sql$)
  ' Cleanup old session data
  sql$ = "DELETE FROM session WHERE timestamp < datetime('now', '-1 day')"
  #db execute(sql$)
  #db disconnect()

' Start a new session, return the session id
function new()
  sessionId = 0
  for i = 1 to 12
    sessionId = sessionId * 10 + int(rnd(1) * 10)
  next i
  new = sessionId
end function

' Connect to session id, return the session id
function connect(id)
  if id > 0 then
    sessionId = id
    connect = id
  end if
end function

' Return the session id
function id()
  id = sessionId
end function

' Clear the session (ie. delete all key/value pairs)
function clear()
  if sessionId > 0 then
    sqliteconnect #db, database$
    sql$ = "DELETE FROM session WHERE session_id = " + str$(sessionId)
    #db execute(sql$)
    #db disconnect()
    clear = 1
  end if
end function

' Delete key from session
function del(key$)
  if sessionId > 0 then
    sqliteconnect #db, database$
    sql$ = "DELETE FROM session WHERE session_id = " + str$(sessionId) + " AND key = " + #lib quote$(key$)
    #db execute(sql$)
    del = 1
  end if
end function

' Set string at key
function set(key$, value$)
  if sessionId > 0 then
    sqliteconnect #db, database$
    sql$ = "INSERT OR REPLACE INTO session (session_id, key, value) VALUES (" + str$(sessionId) + "," + #lib quote$(key$) + "," + #lib quote$(value$) + ")"
    #db execute(sql$)
    set = 1
  end if
end function

' Return string at key
function value$(key$)
  if sessionId > 0 then
    sqliteconnect #db, database$
    sql$ = "SELECT value AS v FROM session WHERE session_id = " + str$(sessionId) + " and key = " + #lib quote$(key$)
    #db execute(sql$)
    if #db hasanswer() then
      #row = #db #nextrow()
      value$ = #row v$()
    end if
    #db disconnect()
  end if
end function

' Call project$ with session parameter
function runProject(project$)
  url$ = "/seaside/go/runbasicpersonal?app=" + #lib urlEncode$(project$) + "&session=" + str$(sessionId)
  expire url$
end function

' Get session id from the URL parameters params$
function getSession(params$)
  sessionId = val(#lib getUrlParam$(params$, "session"))
  getSession = sessionId
end function

function isnull()
  isnull = 0
end function

function debug$()
  debug$ = "Session"
end function
