#!/bin/bash
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y jq
sudo apt-get install -y ruby-full
sudo apt-get install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
sudo apt-get install -y build-essential libssl-dev libffi-dev
sudo apt-get install -y python3-dev python3-setuptools python3-dnspython
sudo apt-get install -y libldns-dev
sudo apt-get install -y python3-pip
sudo apt-get install -y git
sudo apt-get install -y rename
sudo apt-get install -y xargs

echo "installing bash_profile aliases from recon_profile"
git clone https://github.com/nahamsec/recon_profile.git
cd recon_profile
cat bash_profile >> ~/.profile
source ~/.profile
cd ~/
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
                GO_VERSION="1.22.0"
                cd /tmp || exit 1
                wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
                sudo rm -rf /usr/local/go
                sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
                grep -qxF 'export GOPATH=$HOME/go' ~/.profile || echo 'export GOPATH=$HOME/go' >> ~/.profile
                grep -qxF 'export PATH=$PATH:/usr/local/go/bin' ~/.profile || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
                grep -qxF 'export PATH=$PATH:$GOPATH/bin' ~/.profile || echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.profile
                source ~/.profile
                go version
                sleep 1
                break
                ;;
            no)
                echo "Please install Go and rerun this script"
                exit 1
                ;;
        esac
    done
fi

# installing nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
nuclei -update-templates

# -----------------install required python tooling-----------------#
sudo apt update && sudo apt install -y python3-full pipx
pipx ensurepath

pipx install dirsearch
pipx inject dirsearch setuptools
dirsearch -h

#----------installing project discovery essential tools-----------#
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
#------------------------------------------------------------------#

echo "Don't forget to set up AWS credentials!"
sudo apt install -y awscli

mkdir -p ~/tools
cd ~/tools/

echo "Installing Aquatone"
go install github.com/michenriksen/aquatone@latest
echo "done"

echo "Installing Chromium"
sudo snap install chromium
echo "done"

echo "installing JSParser"
git clone https://github.com/nahamsec/JSParser.git
cd JSParser*
python3 setup.py install --user
cd ~/tools/
echo "done"

echo "installing Sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r*
python3 -m pip install --break-system-packages -r requirements.txt
cd ~/tools/
echo "done"

echo "installing teh_s3_bucketeers"
git clone https://github.com/tomdev/teh_s3_bucketeers.git
echo "done"

echo "installing wpscan"
git clone https://github.com/wpscanteam/wpscan.git
cd wpscan*
sudo gem install bundler && bundle install --without test
cd ~/tools/
echo "done"

echo "installing lazys3"
git clone https://github.com/nahamsec/lazys3.git
echo "done"

echo "installing virtual host discovery"
git clone https://github.com/jobertabma/virtual-host-discovery.git
echo "done"

echo "installing sqlmap"
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
echo "done"

echo "installing knock.py"
git clone https://github.com/guelfoweb/knock.git
echo "done"

echo "installing lazyrecon"
git clone https://github.com/nahamsec/lazyrecon.git
echo "done"

echo "installing nmap"
sudo apt-get install -y nmap
echo "done"

echo "installing massdns"
git clone https://github.com/blechschmidt/massdns.git
cd massdns
make
cd ~/tools/
echo "done"

echo "installing asnlookup"
git clone https://github.com/yassineaboukir/asnlookup.git
cd asnlookup
python3 -m pip install --break-system-packages -r requirements.txt
cd ~/tools/
echo "done"

echo "installing httprobe"
go install github.com/tomnomnom/httprobe@latest
echo "done"

echo "installing unfurl"
go install github.com/tomnomnom/unfurl@latest
echo "done"

echo "installing waybackurls"
go install github.com/tomnomnom/waybackurls@latest
echo "done"

echo "installing crtndstry"
git clone https://github.com/nahamsec/crtndstry.git
echo "done"

echo "downloading Seclists"
git clone https://github.com/danielmiessler/SecLists.git
cd SecLists/Discovery/DNS/
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt
cd ~/tools/
echo "done"

## Docker install for Ubuntu 24.04 (WSL2)
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true
EOF
sudo usermod -aG docker $USER

echo -e "\n\nDone! All tools are set up in ~/tools"
ls -la
echo "One last time: don't forget to set up AWS credentials in ~/.aws/"
