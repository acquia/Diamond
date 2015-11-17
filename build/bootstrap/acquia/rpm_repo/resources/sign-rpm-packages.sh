#!/usr/bin/expect -f

# Sign any RPM packages sent in to the script as an arguments
set password ""
spawn /usr/bin/rpm --resign {*}$argv
expect -exact "Enter pass phrase: "
send -- "$password\r"
expect eof