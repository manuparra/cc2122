<!-- vscode-markdown-toc -->
* 1. [Create virtual machine](#Createvirtualmachine)
	* 1.1. [Connect to virtual machine](#Connecttovirtualmachine)
	* 1.2. [Install web server](#Installwebserver)
	* 1.3. [View the web server in action](#Viewthewebserverinaction)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


# Session 4 Creating VMs from MS Azure

Azure virtual machines (VMs) can be created through the Azure portal. The Azure portal is a browser-based user interface to create Azure resources. This tutorial shows you how to use the Azure portal to deploy a Linux virtual machine (VM) running Ubuntu (version 18.04 LTS). To see your VM in action, you also SSH to the VM and install the NGINX web server.

If you don't have an Azure subscription, create a free account before you begin. To do it you can use Student version here: https://azure.microsoft.com/es-es/free/students/

After that, sign in to the Azure portal.

##  1. <a name='Createvirtualmachine'></a>Create virtual machine

- Type virtual machines in the search.

- Under Services, select Virtual machines.

- In the Virtual machines page, select Create and then Virtual machine. The Create a virtual machine page opens.

- In the Basics tab, under Project details, make sure the correct subscription is selected and then choose to Create new resource group. Type myResourceGroup for the name.*.

![](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/media/quick-create-portal/project-details.png)

- Screenshot of the Project details section showing where you select the Azure subscription and the resource group for the virtual machine

- Under Instance details, type myVM for the Virtual machine name, and choose Ubuntu 18.04 LTS - Gen2 for your Image. Leave the other defaults. The default size and pricing is only shown as an example. Size availability and pricing are dependent on your region and subscription.

![](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/media/quick-create-portal/instance-details.png)


- Screenshot of the Instance details section where you provide a name for the virtual machine and select its region, image, and size.

- Under Administrator account, select SSH public key.

- In Username type azureuser.

- For SSH public key source, leave the default of Generate new key pair, and then type myKey for the Key pair name.

![](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/media/quick-create-portal/administrator-account.png)

- Screenshot of the Administrator account section where you select an authentication type and provide the administrator credentials

- Under Inbound port rules > Public inbound ports, choose Allow selected ports and then select SSH (22) and HTTP (80) from the drop-down.

![](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/media/quick-create-portal/inbound-port-rules.png)

- Screenshot of the inbound port rules section where you select what ports inbound connections are allowed on

- Leave the remaining defaults and then select the Review + create button at the bottom of the page.

- On the Create a virtual machine page, you can see the details about the VM you are about to create. When you are ready, select Create.

- When the Generate new key pair window opens, select Download private key and create resource. Your key file will be download as myKey.pem. Make sure you know where the .pem file was downloaded, you will need the path to it in the next step.

- When the deployment is finished, select Go to resource.

- On the page for your new VM, select the public IP address and copy it to your clipboard.

![](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/media/quick-create-portal/ip-address.png)

Screenshot showing how to copy the IP address for the virtual machine

###  1.1. <a name='Connecttovirtualmachine'></a>Connect to virtual machine

Create an SSH connection with the VM.

1. If you are on a Mac or Linux machine, open a Bash prompt. If you are on a Windows machine, open a PowerShell prompt.
2. At your prompt, open an SSH connection to your virtual machine. Replace the IP address with the one from your VM, and replace the path to the .pem with the path to where the key file was downloaded.

```
ssh -i .\Downloads\myKey1.pem azureuser@10.111.12.123
```

###  1.2. <a name='Installwebserver'></a>Install web server

To see your VM in action, install the NGINX web server. From your SSH session, update your package sources and then install the latest NGINX package.

```
sudo apt-get -y update
sudo apt-get -y install nginx
```

When done, type exit to leave the SSH session.

###  1.3. <a name='Viewthewebserverinaction'></a>View the web server in action

Use a web browser of your choice to view the default NGINX welcome page. Type the public IP address of the VM as the web address. The public IP address can be found on the VM overview page or as part of the SSH connection string you used earlier.

![](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/media/quick-create-portal/nginx.png)