dns=$(nmcli -g IP4.DNS dev show wlp5s0 | head -n1)
adb connect "${dns}:5445"
cd /home/lappy/Documents
scrcpy -S -K --max-fps 24 --no-mouse-hover --no-power-on --window-height 1080 --window-borderless --window-x=1920 > scrcpy-log.txt &
read -t 3
