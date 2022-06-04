
#!/bin/bash -e

function run_it {
    # load env file if exist
    [[ -f ".env" ]] && echo "Loading env file" &&  source ".env"

    [ -z "$firstname" ] && read -p 'firstname: ' firstname
    [ -z "$lastname" ] && read -p 'lastname: ' lastname
    [ -z "$email" ] && read -p 'email: ' email

    docker build . -t gpg_image
    script_name=docker-script.sh
    output_folder=$(mktemp -d)

    function cleanup {
        echo $output_folder
        sudo rm -rf $output_folder
    }
    trap cleanup EXIT

    docker run --privileged --rm                  \
    --env admin_pin="$admin_pin"                  \
    --env reset_pin="$reset_pin"                  \
    --env user_pin="$user_pin"                    \
    --env firstname="$firstname"                  \
    --env lastname="$lastname"                    \
    --env email="$email"                          \
    --env output_folder=$output_folder            \
    --volume /dev/bus/usb:/dev/bus/usb            \
    --volume $output_folder:$output_folder        \
    --volume $PWD/$script_name:/$script_name gpg_image /$script_name

    echo $output_folder
    trap - EXIT
}

while true; do
    read -p "Do you want to setup your yubikey?" yn
    case $yn in
        [Yy]* ) run_it; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


