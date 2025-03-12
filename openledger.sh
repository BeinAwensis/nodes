channel_logo() {
  echo -e '\033[0;31m'
  echo -e ' ____       _       _  __             _ '
  echo -e '| __ )  ___(_)_ __ | |/ /_____      _(_)'
  echo -e '|  _ \ / _ \ | \_ \| \ / _ \ \ /\ / / |'
  echo -e '| |_) |  __/ | | | | . \  __/\ V  V /| |'
  echo -e '|____/ \___|_|_| |_|_|\_\___| \_/\_/ |_|'
  echo -e '\e[0m'
  echo -e "\n\nFollow me on Twitter @BeinKewi"
}

download_node() {
  echo 'Starting node installation...'

  cd $HOME

  sudo apt update -y && sudo apt upgrade -y

  echo "Removing old versions of Docker..."
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg"
    if [ $? -eq 0 ]; then
      echo "$pkg successfully removed."
    else
      echo "Error removing $pkg. Skipping..."
    fi
  done

  sudo apt install curl git build-essential jq pkg-config software-properties-common dos2unix ubuntu-desktop desktop-file-utils -y

  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER
  
  # Use a variable to store the latest tag name
  latest_tag=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
  sudo curl -L "https://github.com/docker/compose/releases/download/$latest_tag/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  sudo rm get-docker.sh

  sudo apt update -y
  sudo systemctl start gdm

  wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip
  unzip openledger-node-1.0.0-linux.zip
  sudo dpkg -i openledger-node-1.0.0.deb

  echo "Starting OpenLedger..."
  openledger-node --no-sandbox
}

launch_node() {
  echo "Starting OpenLedger..."
  openledger-node --no-sandbox
}

check_logs() {
  docker logs opl_worker
}

delete_node() {
  echo "Uninstalling OpenLedger..."

  docker stop opl_worker
  docker rm opl_worker

  sudo rm openledger-node-1.0.0.deb
  sudo rm openledger-node-1.0.0-linux.zip

  sudo apt-get remove -y openledger-node

  echo "OpenLedger uninstalled."
}

exit_from_script() {
  exit 0
}

while true; do
    channel_logo
    sleep 2
    echo -e "\n\nMenu:"
    echo "1. Install Node"
    echo "2. Launch Node"
    echo "3. Check Logs"
    echo "4. Uninstall Node"
    echo -e "5. Exit Script\n"
    read -p "Select a menu item: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        launch_node
        ;;
      3)
        check_logs
        ;;
      4)
        delete_node
        ;;
      5)
        exit_from_script
        ;;
      *)
        echo "Invalid selection. Please choose a valid number from the menu."
        ;;
    esac
done
