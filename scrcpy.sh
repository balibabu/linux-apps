dns=$(nmcli -g IP4.DNS dev show wlp5s0 | head -n1)
adb connect "${dns}:5555"
cd /home/lappy/Documents
scrcpy -S -K > scrcpy-log.txt &
read -t 3