#!/bin/bash -e

default_admin_pin="12345678"
default_user_pin="123456"
fullname="$firstname $lastname"

gpg2 --card-status

[ -z "$admin_pin" ] && admin_pin="$(makepasswd -string 1234567890 -chars 8)"
[ -z "$reset_pin" ] && reset_pin="$(makepasswd -string 1234567890 -chars 8)"
[ -z "$user_pin" ] && user_pin="$(makepasswd -string 1234567890 -chars 6)"



echo "Generating keys"
gpg2 --batch --passphrase '' \
    --quick-generate-key "$firstname $lastname <$email>" rsa4096 cert never

FPR=$(gpg --list-options show-only-fpr-mbox --list-secret-keys | awk '{print $1}')

gpg2 --batch --passphrase '' \
    --quick-add-key $FPR rsa4096 sign 5y
gpg2 --batch --passphrase '' \
    --quick-add-key $FPR rsa4096 encrypt 5y
gpg2 --batch --passphrase '' \
    --quick-add-key $FPR rsa4096 auth 5y

echo "List secrets"
gpg2 --list-secret-keys
gpg2 --export-ssh-key $email

# factory reset
gpg2 --edit-card --no-tty  --pinentry-mode loopback --command-fd=0 --status-fd=1 <<EOF
admin
factory-reset
yes
yes
$default_admin_pin
quit
EOF

# set name of cardholder
gpg2 --edit-card --no-tty  --pinentry-mode loopback --command-fd=0 --status-fd=1 <<EOF
admin
name
$firstname
$lastname
$default_admin_pin
quit
EOF

# change user pin
gpg2 --edit-card --no-tty --pinentry-mode loopback --command-fd=0 --status-fd=1 <<EOF
admin
passwd
1
$default_user_pin
$user_pin
$user_pin
Q
quit
EOF
echo "USER PIN CHANGED"

# change reset pin
gpg2 --edit-card --no-tty --pinentry-mode loopback --command-fd=0 --status-fd=1 <<EOF
admin
passwd
4
$default_admin_pin
$reset_pin
$reset_pin
Q
quit
EOF
echo "RESET PIN CHANGED"

# change admin pin
gpg2 --edit-card --no-tty --pinentry-mode loopback --command-fd=0 --status-fd=1 <<EOF
admin
passwd
3
$default_admin_pin
$admin_pin
$admin_pin
Q
quit
EOF


# save keys and pins
echo "$user_pin" > $output_folder/user-pin.txt
echo "$admin_pin" > $output_folder/admin-pin.txt
echo "$reset_pin" > $output_folder/reset-pin.txt

gpg2 --export-ssh-key $email > $output_folder/ssh.pub
gpg2 --export --armor $FPR > $output_folder/pub.asc
gpg2 --export-secret-keys --armor $FPR > $output_folder/priv.asc
gpg2 --export-secret-subkeys --armor $FPR > $output_folder/sub_priv.asc
gpg2 --batch --yes --delete-secret-key $FPR
gpg2 --import $output_folder/sub_priv.asc

# --debug-all for debug
gpg2 -v --edit-key  --pinentry-mode loopback   --no-tty  --expert  --command-fd=0 --status-fd=1  $FPR <<EOF 
toggle
key 1
keytocard
1
$admin_pin
$admin_pin
Q
EOF

gpg2 -v --edit-key  --pinentry-mode loopback   --no-tty  --expert  --command-fd=0 --status-fd=1  $FPR <<EOF 
toggle
key 2
keytocard
2
$admin_pin
$admin_pin
Q
EOF

gpg2 -v --edit-key  --pinentry-mode loopback   --no-tty  --expert  --command-fd=0 --status-fd=1  $FPR <<EOF 
toggle
key 3
keytocard
3
$admin_pin
$admin_pin
Q
EOF

echo "Keys and pins are generated in : $output_folder"

# gpg2 --card-status
# ykman config nfc -f --disable-all
# ykman config usb -f --disable OTP