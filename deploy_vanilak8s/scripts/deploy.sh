#!/bin/bash

cd /home/azureuser
touch startdeploy
git clone https://github.com/kubernetes-sigs/kubespray.git
date +%Y%m%d-%H%M%S > deploy_update_done