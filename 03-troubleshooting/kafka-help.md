# Kafka Troubleshooting

All commands should be run from the root project folder.

## Versions Matter! 

Apache Kafka Python currently requires Python 3.11.

TODO: This will change - be sure to check current requirements at <https://kafka.apache.org/>.

## Check requirements.txt

Use this entry in requirements.txt and ensure it is not commented out:

```
kafka-python-ng
```

If changes are made, rerun the install command.

```shell
python3 -m pip install --upgrade -r requirements.txt
```

## Zookeeper is Not Required

- Zookeeper is no longer required for Kafka.
- Kafka now supports KRaft mode (Kafka Raft) for distributed coordination.


## Failure to Start

If Kafka fails to start:

Ensure JAVA_HOME points to your local JDK (not system-wide Java).

```shell
echo $JAVA_HOME
```


Kill the process in case it is running already. 

```
pkill -f kafka
```

Check the logs for detailed information.

```shell
tail -f kafka/logs/server.log
```
