# pro-analytics-apache-starter

This project provides an isolated development environment for Spark, Kafka, and PySpark using local JDK and virtual environments.  
Works across macOS, Linux, and Windows (via WSL).  

---

## Getting Started

### Just Windows Users: FIRST Set up WSL 

Install Windows Subsystem for Linux (WSL) by following the [instructions](01-setup/windows-users-install-wsl.md).

Open WSL by opening a PowerShell terminal and running wsl. 

```powershell
wsl
```

Important: All remaining commands must be run from within the WSL environment. 
We will use the same ones the Mac/Linux users do when we are working in WSL. 

### All Platforms: Chenge to Home Directory

Change to your home directory (or whereever you want to put your new project repository). 
Run these and all following commands in your shell ($ prompt) terminal.


```shell
cd ~/
```

### All Platforms: Clone Your Repository Into Your Home Directory

1. Copy the template repo into your GitHub account. You can change the name as desired.
2. Open a terminal in your "Projects" folder or where ever you keep your coding projects.
3. Avoid using "Documents" or any folder that syncs automatically to OneDrive or other cloud services.
4. Clone this repository into that folder - Windows users - clone into your default WSL directory. 

In the command below, if you changed the repository name, use that name instead.  

For example - clone with something like this - but use your GitHub account name and repo name:

```shell
git clone https://github.com/denisecase/pro-analytics-apache-starter
```

Then cd into your new folder (if you changed the name, use that):

``shell
cd pro-analytics-apache-starter
```


### All Platforms: Adjust Requirements (Packages Needed)  
Review requirements.txt and comment / uncomment the specific packages needed for your project.  

---

## Create Virtual Environment

```shell
python3 -m venv .venv
source .venv/bin/activate
```

Important Reminder: Always run `source .venv/bin/activate` before working on the project.


## Install Requirements

```shell
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install --upgrade -r requirements.txt

```


## Install JDK

Verify compatible versions. 
See instructions in the file. 
Then, install the necessary OpenJDK locally. 

```shell
./01-setup/download-jdk.sh
```

## Install Apache Tools (As Needed)

Use the commands below to install only the tools your project requires:

```shell
./01-setup/install-kafka.sh
./01-setup/install-pyspark.sh
```

---

## Example: Using Apache Kafka

Start the Kafka service (keep this terminal running)

```shell
./02-scripts/run-kafka.sh
```

In a second terminal, create a Kafka topic

```shell
./kafka/bin/kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092
```

In that second terminal, list Kafka topics

```shell
./kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

In that second terminal, stop the Kafka service when done working with Kafka. Use whichever works. 

```shell
./kafka/bin/kafka-server-stop.sh

pkill -f kafka
```


## Example: Using PySpark

Start PySpark (leave this terminal running)

```shell
./02-scripts/run-pyspark.sh
```

In a second terminal, test Spark
```shell
python 02-scripts/test-spark.py
```


Use that second terminal to stop the service when done:

```shell
pkill -f pyspark
```




