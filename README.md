# session
Session object for Run Basic

### Requirements

Requires Run Basic 1.01 and [functionLibrary](https://github.com/burningrooftop/functionLibrary).

### Usage

Calling project:

```
run "session", #session
#session new()
#session set("key1", "A string")
#session set("key2", str$(1234))
#session runProject("called_project")
```

Called project:

```
run "session", #session
run "library", #lib
#session getSession(UrlKeys$)
a$ = #session value$("key1")
b = val(#session value$("key2"))
#session clear()
```
