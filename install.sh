#!/bin/bash
sudo apt-get -y update
sudo apt-get -y upgrade


sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y jq
sudo apt-get install -y ruby-full
sudo apt-get install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev
sudo apt-get install -y python-setuptools
sudo apt-get install -y libldns-dev
sudo apt-get install -y python3-pip
sudo apt-get install -y python-pip
sudo apt-get install -y python-dnspython
sudo apt-get install -y git
sudo apt-get install -y rename
sudo apt-get install -y xargs

echo "installing bash_profile aliases from recon_profile"
git clone https://github.com/nahamsec/recon_profile.git
cd recon_profile
cat bash_profile >> ~/.bash_profile
source ~/.bash_profile
cd ~/tools/
echo "done"

# install go
if [[ -z "$GOPATH" ]]; then
    echo "It looks like Go is not installed. Would you like to install it now?"
    PS3="Please select an option: "
    choices=("yes" "no")
    select choice in "${choices[@]}"; do
        case $choice in
            yes)
                echo "Installing Golang"
                # Set Go version
                GO_VERSION="1.22.0"   # change as needed
                # Download Go
                cd /tmp || exit 1
                wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
                # Remove any previous Go installation
                sudo rm -rf /usr/local/go
                # Extract Go
                sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
                # Set environment variables (only if not already present)
                grep -qxF 'export GOPATH=$HOME/go' ~/.profile || echo 'export GOPATH=$HOME/go' >> ~/.profile
                grep -qxF 'export PATH=$PATH:/usr/local/go/bin' ~/.profile || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
                grep -qxF 'export PATH=$PATH:$GOPATH/bin' ~/.profile || echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.profile
                # Reload profile
                source ~/.profile
                # Verify installation
                go version
                sleep 1
                break
                ;;
            no)
                echo "Please install Go and rerun this script"
                echo "Aborting installation..."
                exit 1
                ;;
        esac
    done
fi

#installing nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
nuclei -update-templates
# /home/user/nuclei-templates

# -----------------install required python tooling-----------------#
sudo apt update && sudo apt install -y python3-full pipx
# enable pipx in PATH
pipx ensurepath
# reload shell (important)
exec bash
# install dirsearch safely
pipx install dirsearch
# fix Python 3.12 missing dependency
pipx inject dirsearch setuptools
# verify installation
dirsearch -h
#----------installing project discovery essential tools-----------#
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
#------------------------------------------------------------------#
#Don't forget to set up AWS credentials!
echo "Don't forget to set up AWS credentials!"
apt install -y awscli
echo "Don't forget to set up AWS credentials!"

#create a tools folder in ~/
mkdir ~/tools
cd ~/tools/

#install aquatone
echo "Installing Aquatone"
go get github.com/michenriksen/aquatone
echo "done"

#install chromium
echo "Installing Chromium"
sudo snap install chromium
echo "done"

echo "installing JSParser"
git clone https://github.com/nahamsec/JSParser.git
cd JSParser*
sudo python setup.py install
cd ~/tools/
echo "done"

echo "installing Sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r*
pip install -r requirements.txt
cd ~/tools/
echo "done"


echo "installing teh_s3_bucketeers"
git clone https://github.com/tomdev/teh_s3_bucketeers.git
cd ~/tools/
echo "done"


echo "installing wpscan"
git clone https://github.com/wpscanteam/wpscan.git
cd wpscan*
sudo gem install bundler && bundle install --without test
cd ~/tools/
echo "done"

echo "installing dirsearch"
git clone https://github.com/maurosoria/dirsearch.git
cd ~/tools/
echo "done"


echo "installing lazys3"
git clone https://github.com/nahamsec/lazys3.git
cd ~/tools/
echo "done"

echo "installing virtual host discovery"
git clone https://github.com/jobertabma/virtual-host-discovery.git
cd ~/tools/
echo "done"


echo "installing sqlmap"
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
cd ~/tools/
echo "done"

echo "installing knock.py"
git clone https://github.com/guelfoweb/knock.git
cd ~/tools/
echo "done"

echo "installing lazyrecon"
git clone https://github.com/nahamsec/lazyrecon.git
cd ~/tools/
echo "done"

echo "installing nmap"
sudo apt-get install -y nmap
echo "done"

echo "installing massdns"
git clone https://github.com/blechschmidt/massdns.git
cd ~/tools/massdns
make
cd ~/tools/
echo "done"

echo "installing asnlookup"
git clone https://github.com/yassineaboukir/asnlookup.git
cd ~/tools/asnlookup
pip install -r requirements.txt
cd ~/tools/
echo "done"

echo "installing httprobe"
go get -u github.com/tomnomnom/httprobe 
echo "done"

echo "installing unfurl"
go get -u github.com/tomnomnom/unfurl 
echo "done"

echo "installing waybackurls"
go get github.com/tomnomnom/waybackurls
echo "done"

echo "installing crtndstry"
git clone https://github.com/nahamsec/crtndstry.git
echo "done"

echo "downloading Seclists"
cd ~/tools/
git clone https://github.com/danielmiessler/SecLists.git
cd ~/tools/SecLists/Discovery/DNS/
##THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt
cd ~/tools/
echo "done"

## Docker install for Ubuntu 24.04 (WSL2)
echo "Installing prerequisites..."
sudo apt install -y ca-certificates curl gnupg lsb-release
echo "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "Adding Docker repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu noble stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "Installing Docker Engine + plugins..."
sudo apt update
sudo apt install -y \
docker-ce docker-ce-cli containerd.io \
docker-buildx-plugin docker-compose-plugin
echo "Enabling systemd for WSL..."
sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true
EOF
echo "Adding user to docker group..."
sudo usermod -aG docker $USER
##end of docker install


echo -e "\n\n\n\n\n\n\n\n\n\n\nDone! All tools are set up in ~/tools"
ls -la
echo "One last time: don't forget to set up AWS credentials in ~/.aws/!"
