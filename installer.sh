#!/bin/bash


# COLORS
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'
RED='\033[0;31m'
# Set the color variable
green='\033[0;32m'
# Clear the color after that
clear='\033[0m'


# Functions

function progress {
    barr=''
    for (( y=50; y <= 100; y++ )); do
        sleep 0.05
        barr="${barr} "

        echo -ne "\r"
        echo -ne "\e[43m$barr\e[0m"

        local left="$(( 100 - $y ))"
        printf " %${left}s"
        echo -n "${y}% Please Wait"
    done
    echo -e "\n"
}



# check x-ui is installed or no for install
check_xui(){

    if ! netstat -tulpn | grep 'x-ui'
    then
    progress
    else
    echo ""
    echo ""
    echo -e "${RED}[ERROR]${clear} You have already installed x-ui ! please unistall that."
    exit 1
    fi
}

# check x-ui is installed or no for uninstall
check_xui_nue(){

    if ! netstat -tulpn | grep 'x-ui'
    then
    echo -e "${RED}[ERROR]${clear} Unfortunately, x-ui is not installed yet!please istall that."
    exit 1
    else
    progress
    return 1
    fi
}

# setup SSL on panel without going to the panel
setupSSL() {

        if ! check_xui_nue; then
            FILE=$(find / -name "x-ui*.db*")
            sql='select * from settings'
            if [[ -f "$FILE" ]]; then

            if sqlite3 ${FILE} "select * from settings where key='webCertFile';" | grep -i 'webCertFile' && sqlite3 ${FILE} "select * from settings where key='webKeyFile';" | grep -i 'webKeyFile'; then

                    CertificatePath=$(certbot certificates | grep -oP '(?<=Certificate Path: ).*(?=.pem)')
                    PrivateKeyPath=$(certbot certificates | grep -oP '(?<=Private Key Path: ).*(?=.pem)')

                    webCertFile="${CertificatePath}.pem"
                    webKeyFile="${PrivateKeyPath}.pem"


                    progress
                    sqlite3 ${FILE} "UPDATE settings SET key='webCertFile',value=\"${webCertFile}\" WHERE key='webCertFile';"
                    echo -e "${green}[SUCCESS]${clear} The certificate public key file is set."


                    progress
                    sqlite3 ${FILE} "UPDATE settings SET key='webKeyFile',value=\"${webKeyFile}\" WHERE key='webKeyFile';"
                    echo -e "${green}[SUCCESS]${clear} The certificate key file is set."





                    x-ui restart
                    echo -e "${green}[SUCCESS]${clear} ssl was successfully set on the panel."



            else

                    CertificatePath=$(certbot certificates | grep -oP '(?<=Certificate Path: ).*(?=.pem)')
                    PrivateKeyPath=$(certbot certificates | grep -oP '(?<=Private Key Path: ).*(?=.pem)')

                    webCertFile="${CertificatePath}.pem"
                    webKeyFile="${PrivateKeyPath}.pem"




                    progress
                    sqlite3 ${FILE} "insert into settings (key,value) values (\"webCertFile\",\"$webCertFile\");"
                    echo -e "${green}[SUCCESS]${clear} The certificate public key file is set."

                    progress
                    sqlite3 ${FILE} "insert into settings (key,value) values (\"webKeyFile\",\"$webKeyFile\");"
                    echo -e "${green}[SUCCESS]${clear} The certificate key file is set."


                    x-ui restart


                    echo -e "${green}[SUCCESS]${clear} ssl was successfully set on the panel."


            fi


            else
            echo -e "${RED}[ERORR]${clear} The database file was not found! Please reinstall."
            fi
            else
            echo -e "${RED}[ERORR]${clear} Unfortunately, x-ui is not installed yet!please istall that."
            exit 1;



        fi
}

install_check(){
    progress
    apt-get install nano wget curl net-tools certbot sqlite3 cron git unzip -y
}

# Function to install SSL certificate using Certbot
install_ssl_certificate() {
    local domain=$1

    echo -e "\e[1;34m[Info] Installing SSL certificate for domain: $domain\e[0m"



    # Run Certbot to obtain SSL certificate
    certbot certonly --standalone --non-interactive --preferred-challenges http --agree-tos --email john@goldaccess.com -d $domain

    # Renew the certificate for a dry run
    certbot renew --dry-run

    echo -e "\e[1;32m[Success] SSL certificate installed successfully!\e[0m"
}

# Function to install SSL certificate using Certbot
install_ssl_certificate() {
    local domain=$1

    echo -e "\e[1;34m[Info] Installing SSL certificate for domain: $domain\e[0m"


    # Run Certbot to obtain SSL certificate
    certbot certonly --standalone --non-interactive --preferred-challenges http --agree-tos --email john@goldaccess.com -d $domain

    # Renew the certificate for a dry run
    certbot renew --dry-run

    echo -e "\e[1;32m[Success] SSL certificate installed successfully!\e[0m"
}

# Function to download and install X-UI
download_x_ui() {
    echo -e "\e[1;34m[Info] Downloading and installing X-UI...\e[0m"

    cd /usr/local
    wget https://github.com/MHSanaei/3x-ui/releases/download/v1.4.1/x-ui-linux-amd64.tar.gz
    tar -xvf x-ui-linux-amd64.tar.gz
    systemctl restart x-ui.service
    cd
    echo -e "\e[1;32m[Success] X-UI installed successfully!\e[0m"
}

# Function to install the 3X-UI Panel
install_3x_ui() {
    echo -e "\e[1;34m[Info] Running custom installation command...\e[0m"
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
}


uninstallXUI() {
        if ! check_xui_nue; then
            echo -e "${green}[SUCCESS]${clear} Your server has been checked and is ready to uninstall"
            printf "Are you sure to uninstall x-ui? Y/n : "
            read questunistall
            if [[ $questunistall == 'Y' || $questunistall == 'y' ]]; then
                echo 'Y' | x-ui uninstall
                progress
                rm /usr/bin/x-ui -f
                echo -e "${green}[SUCCESS]${clear} x-ui successfully uninstalled"
            else
                exit 1
            fi
            else
            exit 1


        fi

}

setupWARP() {
(echo 18; echo 1;) | cat | x-ui
}


# Function to install requirements
install_requirements() {
    echo -e "\e[1;32m[Success] Starting installation...\e[0m"

    echo -e "\e[1;34m[Info] Updating package lists...\e[0m"
    apt-get update

    echo -e "\e[1;34m[Info] Upgrading packages...\e[0m"
    apt-get dist-upgrade -y

    echo -e "\e[1;34m[Info] Installing required packages...\e[0m"
    apt-get install wget curl certbot git zsh unzip cron -y

    echo -e "\e[1;34m[Info] Installing Oh My Zsh...\e[0m"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo -e "\e[1;32m[Success] Requirements installed successfully!\e[0m"
}

setupCronjob() {
  echo -e "\e[1;32m[Success] Starting Configuring Cronjob...\e[0m"


#  echo "15 18 * * * /usr/bin/certbot renew --dry-run --post-hook 'systemctl restart x-ui.service'" | sudo tee -a /etc/crontab



  new_cron_line="15 18 * * * /usr/bin/certbot renew --dry-run --post-hook 'systemctl restart x-ui.service'"


  choice=1

  if [ "$choice" -eq 1 ]; then
    # Append the code to the crontab file
    (crontab -l ; echo "$new_cron_line") | crontab -
    echo "Code added to crontab successfully!"
  else
    echo "No changes made to crontab."
  fi
  echo -e "\e[1;32m[Success] Cronjob was configured successfully!\e[0m"

}

# Function to simulate typing effect
type_effect() {
    local text="$1"
    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.05  # Adjust the sleep duration for typing speed
    done
    echo
}

# Function to display header with logo
display_header() {
    cat << "EOF"
╔═══════════════════════════════════════╦═══════════════════════════╗
║            #                          ║                           ║
║        ######                ####     ║   1. Install Requirements ║
║        ########            #####      ║   2. Install X-UI         ║
║        ##########       ######        ║   3. Download X-UI        ║
║         ###########  #####            ║   4. Install SSL          ║
║              ##########               ║   5. Setup Cronjob        ║
║                ##########             ║   6. Setup SSL            ║
║              ##### ########           ║   7. Setup WARP           ║
║          #######     ########         ║   8. Uninstall X-UI       ║
║       #######           #######       ║   9. Exit                 ║
║   ########                ### ####    ║                           ║
║  *######                    ### ##    ║                           ║
║   ###                         #       ║                           ║
║                                       ║                           ║
╚═══════════════════════════════════════╩═══════════════════════════╝
EOF
}


# Main script
while true; do
    clear  # Clear the screen for a clean display
    display_header

    read -p "Enter your choice (1-9): " choice

    case $choice in
        1)
            type_effect "[Info] Initiating installation..."
            install_requirements
            install_check
            read -p "Press enter to continue..."
            ;;
        2)
            type_effect "[Info] Running x-ui installation ..."
            install_3x_ui
            read -p "Press enter to continue..."
            ;;
        3)
            type_effect "[Info] Downloading X-UI packages..."
            download_x_ui
            read -p "Press enter to continue..."
            ;;
        4)
            read -p "Enter the domain for SSL certificate installation: " ssl_domain
            type_effect "[Info] Installing SSL certificate for domain: $ssl_domain..."
            install_ssl_certificate "$ssl_domain"
            read -p "Press enter to continue..."
            ;;
        5)
            type_effect "[Info] Running Cronjob  ..."
            setupCronjob
            read -p "Press enter to continue..."
            ;;
        6)
            type_effect "Setting SSL on x-ui panel"
            setupSSL
            read -p "Press enter to continue..."
            ;;
        7)
            type_effect "Setting WARP"
            setupWARP
            read -p "Press enter to continue..."
            ;;
        8)
            type_effect "[Info] Running x-ui uninstallation ..."
            uninstallXUI
            ;;
        9)
            type_effect "Exiting the script. Goodbye!"
            exit 0
            ;;
        *)
            echo -e "\e[1;31m[Error] Invalid choice. Please enter a number between 1 and 3.\e[0m"
            read -p "Press enter to continue..."
            ;;
    esac
done
