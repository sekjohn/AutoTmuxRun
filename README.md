# AutoTmuxRun

This project was created to automatically restart and run tmux jobs based on cmmand.json .


Stop all tasks in session and run based on command.json (including all windows)

----

### command json file 
```
{
    "session": "test-worker",
    "command" :[
        "celery", 
        "celery",
        ...
    ]
}
```

### Mac or Linux
```
sh run.sh -i command.json
./ run.sh -i command.json
```
```
sh run.sh -t {attach_ssession} -i command.json
./ run.sh -t {attach_ssession} -i command.json
```
```
sh run.sh -n {new_ssession} -i command.json
./ run.sh -n {new_ssession} -i command.json
```