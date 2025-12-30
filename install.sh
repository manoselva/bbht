#!/bin/bash

# =================== UI / UX HELPERS ===================
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

info()  { echo -e "${BLUE}[INFO]${RESET} $1"; }
ok()    { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }

section() {
  START_TIME=$(date +%s)
  echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${GREEN}$1${RESET}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

end_section() {
  END_TIME=$(date +%s)
  echo -e "${GREEN}Completed in $((END_TIME - START_TIME))s${RESET}\n"
}

spinner() {
  local pid=$!
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${BLUE}[%c] Working...${RESET}" "${spin:$i:1}"
    sleep .1
  done
  printf "\r"
}

run() {
  "$@" &> /tmp/install.log &
  spinner
  wait $!
  local status=$?
  if [[ $status -ne 0 ]]; then
    echo
    cat /tmp/install.log
    error "Command failed: $*"
  fi
}

TOTAL_START=$(date +%s)

# =================== SYSTEM UPDATE ===================
section "Updating System"
run sudo apt-get -y update
run sudo apt-get -y upgrade
ok "System updated"
end_section

# =================== BASE PACKAGES ===================
section "Installing Base Packages"
run sudo apt-get install -y \
  libcurl4-openssl-dev libssl-dev jq ruby-full \
  libxml2 libxml2-dev libxslt1-dev ruby-dev \
  build-essential libgmp-dev zlib1g-dev \
  libffi-dev python3-dev python3-setuptools \
  python3-dnspython libldns-dev python3-pip \
  git rename findutils
ok "Base packages installed"
end_section

# =================== GO INSTALL ===================
section "Golang Setup"
if ! command -v go &>/dev/null; then
  GO_VERSION="1.22.0"
  info "Installing Go $GO_VERSION"
  run wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz
  run sudo rm -rf /usr/local/go
  run sudo tar -C /usr/local -xzf /tmp/go.tar.gz

  grep -qxF 'export GOPATH=$HOME/go' ~/.profile || echo 'export GOPATH=$HOME/go' >> ~/.profile
  grep -qxF 'export PATH=$PATH:/usr/local/go/bin' ~/.profile || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
  grep -qxF 'export PATH=$PATH:$GOPATH/bin' ~/.profile || echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.profile

  source ~/.profile
  ok "Go installed: $(go version)"
else
  ok "Go already installed"
fi
end_section

# =================== GO TOOLS ===================
section "Installing Go Tools"
TOOLS=(
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
  "github.com/projectdiscovery/katana/cmd/katana@latest"
  "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/sensepost/gowitness@latest"
  "github.com/tomnomnom/httprobe@latest"
  "github.com/tomnomnom/unfurl@latest"
  "github.com/tomnomnom/waybackurls@latest"
)

for tool in "${TOOLS[@]}"; do
  BIN=$(basename "${tool%@*}")
  if command -v "$BIN" &>/dev/null; then
    ok "$BIN already installed"
  else
    info "Installing $BIN"
    run go install "$tool"
  fi
done

nuclei -update-templates &>/dev/null
ok "Go tools ready"
end_section

# =================== PYTHON TOOLING ===================
section "Python Tooling"
run sudo apt install -y python3-full pipx
pipx ensurepath &>/dev/null
if ! command -v dirsearch &>/dev/null; then
  run pipx install dirsearch
  run pipx inject dirsearch setuptools
fi
ok "Python tooling ready"
end_section

# =================== TOOLS DIRECTORY ===================
section "Tools Directory"
mkdir -p ~/tools
cd ~/tools || error "Cannot access ~/tools"
ok "Using ~/tools"
end_section

# =================== GIT TOOLS ===================
section "Cloning Recon Repositories"
REPOS=(
  "https://github.com/nahamsec/JSParser.git"
  "https://github.com/aboul3la/Sublist3r.git"
  "https://github.com/tomdev/teh_s3_bucketeers.git"
  "https://github.com/wpscanteam/wpscan.git"
  "https://github.com/nahamsec/lazys3.git"
  "https://github.com/jobertabma/virtual-host-discovery.git"
  "https://github.com/sqlmapproject/sqlmap.git sqlmap-dev"
  "https://github.com/guelfoweb/knock.git"
  "https://github.com/nahamsec/lazyrecon.git"
  "https://github.com/nahamsec/crtndstry.git"
)

for repo in "${REPOS[@]}"; do
  DIR=$(basename ${repo%% *} .git)
  [[ -d "$DIR" ]] && ok "$DIR already exists" || run git clone $repo
done
end_section

# =================== SECLISTS ===================
section "SecLists"
if [[ ! -d SecLists ]]; then
  run git clone https://github.com/danielmiessler/SecLists.git
fi
head -n -14 SecLists/Discovery/DNS/dns-Jhaddix.txt > SecLists/Discovery/DNS/clean-jhaddix-dns.txt
ok "SecLists cleaned"
end_section

# =================== DOCKER ===================
section "Docker (WSL2)"
if ! command -v docker &>/dev/null; then
  run sudo apt install -y ca-certificates curl gnupg lsb-release
  run sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  run sudo apt update
  run sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true
EOF
  sudo usermod -aG docker $USER
  ok "Docker installed (restart WSL required)"
else
  ok "Docker already installed"
fi
end_section

# =================== FINISH ===================
TOTAL_END=$(date +%s)
echo -e "\n${GREEN}🎉 All setup complete in $((TOTAL_END - TOTAL_START)) seconds${RESET}"
echo -e "${YELLOW}Reminder:${RESET} configure AWS credentials in ~/.aws/"
ls -la ~/tools
