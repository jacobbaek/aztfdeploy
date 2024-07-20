#!/bin/bash
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray

cd /home/azureuser
git clone https://github.com/kubernetes-sigs/kubespray.git
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements.txt
date +%Y%m%d-%H%M%S > deploy_update_done
