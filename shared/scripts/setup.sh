#!/bin/bash

set -e

# Disable interactive apt prompts
export DEBIAN_FRONTEND=noninteractive

# Allocate, enable and add swap to fstab
sudo fallocate -l 4G /swap
sudo chmod 600 /swap
sudo mkswap /swap
sudo swapon /swap
echo -e "/swap swap swap defaults 0 0" | sudo tee -a /etc/fstab

cd /ops

CONFIGDIR=/ops/shared/config

CONSULVERSION=1.9.5
CONSULDOWNLOAD=https://releases.hashicorp.com/consul/${CONSULVERSION}/consul_${CONSULVERSION}_linux_amd64.zip
CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/consul

VAULTVERSION=1.7.1
VAULTDOWNLOAD=https://releases.hashicorp.com/vault/${VAULTVERSION}/vault_${VAULTVERSION}_linux_amd64.zip
VAULTCONFIGDIR=/etc/vault.d
VAULTDIR=/opt/vault

NOMADVERSION=1.0.4
NOMADDOWNLOAD=https://releases.hashicorp.com/nomad/${NOMADVERSION}/nomad_${NOMADVERSION}_linux_amd64.zip
NOMADCONFIGDIR=/etc/nomad.d
NOMADDIR=/opt/nomad

CONSULTEMPLATEVERSION=0.25.1
CONSULTEMPLATEDOWNLOAD=https://releases.hashicorp.com/consul-template/${CONSULTEMPLATEVERSION}/consul-template_${CONSULTEMPLATEVERSION}_linux_amd64.zip
CONSULTEMPLATECONFIGDIR=/etc/consul-template.d
CONSULTEMPLATEDIR=/opt/consul-template

# Dependencies
sleep 10 # the package list fails to update right after boot
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-get install -y unzip jq curl net-tools
echo 'DNSStubListener=no' | sudo tee -a /etc/systemd/resolved.conf


# Disable the firewall
sudo ufw disable || echo "ufw not installed"

# Consul
curl -L $CONSULDOWNLOAD > consul.zip

## Install
sudo unzip consul.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/consul
sudo chown root:root /usr/local/bin/consul

## Configure
sudo mkdir -p $CONSULCONFIGDIR
sudo chmod 755 $CONSULCONFIGDIR
sudo mkdir -p $CONSULDIR
sudo chmod 755 $CONSULDIR

# Vault

curl -L $VAULTDOWNLOAD > vault.zip

## Install
sudo unzip vault.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

## Configure
sudo mkdir -p $VAULTCONFIGDIR
sudo chmod 755 $VAULTCONFIGDIR
sudo mkdir -p $VAULTDIR
sudo chmod 755 $VAULTDIR

# Nomad

curl -L $NOMADDOWNLOAD > nomad.zip

## Install
sudo unzip nomad.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/nomad
sudo chown root:root /usr/local/bin/nomad

## Configure
sudo mkdir -p $NOMADCONFIGDIR
sudo chmod 755 $NOMADCONFIGDIR
sudo mkdir -p $NOMADDIR
sudo chmod 755 $NOMADDIR

# Consul Template 

curl -L $CONSULTEMPLATEDOWNLOAD > consul-template.zip

## Install
sudo unzip consul-template.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/consul-template
sudo chown root:root /usr/local/bin/consul-template

## Configure
sudo mkdir -p $CONSULTEMPLATECONFIGDIR
sudo chmod 755 $CONSULTEMPLATECONFIGDIR
sudo mkdir -p $CONSULTEMPLATEDIR
sudo chmod 755 $CONSULTEMPLATEDIR


# Docker
distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
sudo apt-get install -y apt-transport-https ca-certificates gnupg2 
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${distro} $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Install autocomplete
nomad -autocomplete-install
consul -autocomplete-install
vault -autocomplete-install
