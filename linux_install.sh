# grant passwordless sudo
visudo "<USER> ALL=(ALL) NOPASSWD:ALL"


# tools
sudo apt-get install -y git
sudo apt-get install -y awscli
sudo apt-get install -y ethtool
sudo apt-get install -y pkg-config
sudo apt-get install -y libpcap-dev
sudo apt-get install -y wireshark-qt
sudo apt-get install -y build-essential


# terraform install
# https://www.hashicorp.com/blog/announcing-the-hashicorp-linux-repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install terraform


# install pyenv
# https://askubuntu.com/questions/865554/how-do-i-install-python-3-6-using-apt-get
sudo apt-get install -y build-essential libbz2-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev tk-dev
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
grep 'pyenv' > /dev/null ~/.profile &&
cat <<EOT >> ~/.profile
export PATH="\$HOME/.pyenv/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
EOT
pyenv install 3.6.0

# installing kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl


# install docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
pip3 install docker-compose
grep 'DOCKER_HOST' ~/.profile > /dev/null || echo "export DOCKER_HOST=tcp://localhost:2375" >> ~/.profile


