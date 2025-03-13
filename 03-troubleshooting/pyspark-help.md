# PySpark Troubleshooting

All commands should be run from the root project folder.

## Check requirements.txt

Use this entry in requirements.txt and ensure it is not commented out:

```
pyspark<4.0.0
```

If changes are made, rerun the install command.


```shell
python3 -m pip install --upgrade -r requirements.txt
```


## Failure to Start

If PySpark fails to start:

- Ensure JAVA_HOME points to your local JDK (not system-wide Java).

```shell
echo $JAVA_HOME  
```

Kill the process in case it is running already. 

```shell
pkill -f pyspark  
```

Check the logs for detailed information.

```shell
tail -f pyspark.log  
```
