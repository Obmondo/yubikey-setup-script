<p align="center"><strong>Generate gpg keys on yubikey using gpg in docker</strong> </p>

To generate keys on your yubikey you could simply run

```bash
./launch.sh
```

`launch.sh` script will ask mandatory information (`firstname`, `lastname`, `email`) about yubikey holder and automatically generates pins (`admin_pin`, `reset_pin`, `user_pin`). Script can take either `.env` file or `variables` directly.
Params are:

- firstname: yubikey holder firstname
- lastname: yubikey holder lastname
- email: yubikey holder mail adress

At the end of script execution if everything goes well a message like:

```bash
Keys and pins are generated in : /tmp/tmp.xxxxxx
```

## Method 1 - Use environment file

The script will look for `.env` file in this folder

Example: `.env` file content

```bash
firstname=John
lastname=DOE
email=john.doe@evilcorp.com
admin_pin=12423355
reset_pin=12345623
user_pin=156985
```

## Method 2 - Pass variables to `launch.sh` script

### :warning: suspend bash history before using this command to not have pins displayed in command history!

```bash
    firstname=John lastname=DOE email=john.doe@evilcorp.com admin_pin=12423355 reset_pin=12345623 user_pin=156985 ./launch.sh
```

### Output folder will be displayed after script execution

## To Do

- Generate keys on RAM instead of hard disk
- Validate user inputs (`email`, `admin_pin`, `reset_pin`, `user_pin`)
- Add code to create backup key
- Add code to setup a new yubikey from existing keys and pins

## Known issues

- Using non [ASCII](https://www.w3schools.com/charsets/ref_html_ascii.asp#:~:text=ASCII%20is%20a%207%2Dbit,are%20all%20based%20on%20ASCII.) characters can make the script bug
