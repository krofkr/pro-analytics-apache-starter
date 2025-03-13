# Windows Users: Install WSL First

The open-source Apache tools like Spark come out of the open-source Linux world. 

We can get a little bit of Linux running on Windows machines and it makes installing and using these tools much easier. 

We'll use "Windows Subsystem for Linux (WSL)"

Follow the guide to install and set up WSL. 

When working in WSL, our commands will be the same as those for Mac/Linux users. 

We'll clone the repo into WSL and do everything from within WSL on Windows.

## Update or Install WSL

Open PowerShell as Administrator. Try to update WSL.
If you have it great:

```powershell
wsl --update
```

If it fails, you'll need to install it. 
Run the following command.

```powershell
wsl --install
```

Important: Remember/record your username and password on WSL! 
Make it easy to remember. 

## Update and Upgrade

This and all other commands are to be run in your WSL terminal. 
They are the same as the Mac/Linux versions - not our PowerShell commands.


```shell
sudo apt update
sudo apt upgrade -y
```

Verify it is installed and running correctly.

```shell
wsl --list --verbose
```