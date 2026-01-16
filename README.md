# nut-notify
A simple notification service for NUT.

<img width="3840" height="2160" alt="deleteme" src="https://github.com/user-attachments/assets/113f4651-1b13-48bd-b2c6-e80c87bad598" />

# How to install
Clone the repo, cd in, and run:
```sh
cp ./nut-notify.sh ~/.local/bin/nut-notify.sh
cp ./nut-notify.service ~/.config/systemd/user/nut-notify.service
```

Then enable and start the service

```sh
systemctl --user enable --now nut-notify.service
```

# How to debug
`systemctl --user status nut-notify.service` or `nut-notify.sh` directly if you preffer.

#  How to know it works
You can use nut to simulate UPS changing status like in this example.

```sh
# YOUR NUT USER AND PASSWORD
# ----------------------------
UPS_NAME="<nut_username>"
NUT_PASSWORD="<nut_password>"

# ACTUAL TEST
# ----------------------------
# 1. Start deep battery test (MAXIMUM 10 seconds)
echo "=== Deep battery test (maximum 10s) ==="
upscmd -u "$NUT_USER" -p "$NUT_PASSWORD" "${UPS_NAME}@localhost" test.battery.start.deep &
TEST_PID=$!

# 2. Monitor for 10 seconds
for i in {1..10}; do
    upsc "${UPS_NAME}@localhost" ups.status 2>/dev/null | grep -E "(OL|OB)" || echo "No status"
    sleep 1
done

# 3. Stop the test
kill $TEST_PID 2>/dev/null
upscmd -u "$NUT_USER" -p "$NUT_PASSWORD" "${UPS_NAME}@localhost" test.battery.stop 2>/dev/null
echo "=== Test completed ==="
```

You should be able to see the desktop notifications appearing during the test.
