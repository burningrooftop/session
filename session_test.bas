' Session test suite

global testnum, testok, testfailed

run "session", #s1
run "session", #s2

call test "debug$()"
call assert #s1 debug$(), "Session"

call test "isnull()"
call assertn #s1 isnull(), 0

call test "id() of uninitialised session"
call assertn #s1 id(), 0

s = #s1 new()

call test "id() of new session"
call assertn #s1 id(), s

call test "setting and getting keys"
call assert #s1 value$("a"), ""
call assertn #s1 set("a", "hello world"), 1
call assertn #s1 set("a", "apple's are great"), 1
call assert #s1 value$("a"), "apple's are great"
call assertn #s1 set("b", str$(4532)), 1
call assert #s1 value$("b"), "4532"

call test "delete a non-existent key"
call assertn #s1 del("x"), 1

call test "delete an existing key"
call assertn #s1 del("a"), 1
call assert #s1 value$("a"), ""

call test "connect to session and get key values"
call assertn #s2 connect(s), s
call assert #s2 value$("a"), ""
call assert #s2 value$("b"), "4532"

#s1 clear()

call test "clear() has cleared only values"
call assertn #s1 id(), s
call assertn #s2 id(), s
call assert #s1 value$("a"), ""
call assert #s2 value$("a"), ""

call summary

sub test what$
  testnum = 0
  print
  print "-----------------------------------------------"
  print "Starting testing of "; what$
  print "-----------------------------------------------"
end sub

sub assert in$, expected$
  testnum = testnum + 1
  print "Test "; testnum; " got <"; in$; ">, expected <"; expected$; "> - ";
  if in$ <> expected$ then
    testfailed = testfailed + 1
    print " FAILED"
  else
    testok = testok + 1
    print " Passed"
  end if
end sub

sub assertn in, expected
  call assert str$(in), str$(expected)
end sub

sub summary
  print
  print "==============================================="
  print testok + testfailed; " tests run"
  print testok; " test passed"
  print testfailed; " tests failed"
  print "==============================================="
end sub
