#!/bin/bash
VENVDIR=venv
KUBESPRAYDIR=kubespray

cd /home/azureuser
git clone https://github.com/kubernetes-sigs/kubespray.git
sudo apt update && sudo apt install virtualenv python3-pip
cd $KUBESPRAYDIR
virtualenv $VENVDIR
source $VENVDIR/bin/activate
pip install -U -r requirements.txt
date +%Y%m%d-%H%M%S > deploy_update_done