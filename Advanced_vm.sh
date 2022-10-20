# reading the values from the property files  
pwd=`pwd`

# reading  the path value from the property file 

path=`cat $pwd/property_file| grep "path2"| cut -d"=" -f2 `

cd $path/

#creating directory 

mkdir apigateway

sudo chmod 777 apigateway
 
sudo apt update

# installing firewalld 

sudo apt install firewalld

# enabling firewalld 

sudo  systemctl  enable  --now firewalld

sudo systemctl start firewalld

# exposing the ports

echo "enabling IS port 5555"
sudo firewall-cmd --zone=public --permanent --add-port=5555/tcp

echo "enabling APIGateway UI port 9072"
sudo firewall-cmd --zone=public --permanent --add-port=9072/tcp

echo "enabling ES port 9240"
sudo firewall-cmd --zone=public --permanent --add-port=9240/tcp

echo "enabling Terracotta port 9510"
sudo firewall-cmd --zone=public --permanent --add-port=9510/tcp

echo "enabling kibana port 9450"
sudo firewall-cmd --zone=public --permanent --add-port=9450/tcp

echo "enabling InternalServer port 2222"
sudo firewall-cmd --zone=public --permanent --add-port=2222/tcp

echo "enabling ES Tcp port 9340"
sudo firewall-cmd --zone=public --permanent --add-port=9340/tcp

echo "enabling InternalServer port 3334"
sudo firewall-cmd --zone=public --permanent --add-port=3334/tcp

echo "enabling InternalServer port 2224"
sudo firewall-cmd --zone=public --permanent --add-port=2224/tcp

echo "enabling InternalServer port 2232"
sudo firewall-cmd --zone=public --permanent --add-port=2232/tcp

echo "enabling InternalServer port 1111"
sudo firewall-cmd --zone=public --permanent --add-port=1111/tcp

echo "enabling Terracotta port 9530"
sudo firewall-cmd --zone=public --permanent --add-port=9530/tcp

echo "enabling Terracotta port 9520"
sudo firewall-cmd --zone=public --permanent --add-port=9520/tcp

echo "enabling port 1818"
sudo firewall-cmd --zone=public --permanent --add-port=1818/tcp

echo "enabling port 7777"
sudo firewall-cmd --zone=public --permanent --add-port=7777/tcp

echo "enabling port 9075"
sudo firewall-cmd --zone=public --permanent --add-port=9075/tcp

echo "enabling port 9076"
sudo firewall-cmd --zone=public --permanent --add-port=9076/tcp

echo "enabling port 9076"
sudo firewall-cmd --zone=public --permanent --add-port=9241/tcp

echo "enabling port 9076"
sudo firewall-cmd --zone=public --permanent --add-port=9341/tcp

echo "enabling port 7777"
sudo firewall-cmd --zone=public --permanent --add-port=7777/tcp

echo "enabling port 9075"
sudo firewall-cmd --zone=public --permanent --add-port=9075/tcp

echo "enabling port 3333"
sudo firewall-cmd --zone=public --permanent --add-port=3333/tcp

echo "enabling port 2222"
sudo firewall-cmd --zone=public --permanent --add-port=2222/tcp

sudo firewall-cmd --reload

#listing  the  exposed ports

echo "listing all the enabled ports"

sudo firewall-cmd --list-all

# checking the vm.max_map_count

if sudo grep -q vm.max_map_count= /etc/sysctl.conf; then
  sudo sed -i 's/^vm.max.*/vm.max_map_count=262144/' /etc/sysctl.conf

  echo "vm.max_map_count is changed to 262144"  
 else
  sudo echo  "vm.max_map_count=262144"  >>  /etc/sysctl.conf

  echo  "vm.max_map_count added in sysctl.conf"
fi

#reloading the system  to apply the changes  

sudo sysctl --load /etc/sysctl.conf


sudo sed -i "s+^InstallDir=.*+InstallDir=$path/apigateway+" $pwd/files/apigateway_script

sudo sed -i "s+^InstallDir=.*+InstallDir=$path/terracotta+" $pwd/files/terracotta_script

int_path=$pwd/files/49_APIGatewayAdvanced101.xml 

microgateway_path=$pwd/files/Microgateway103.xml

terracotta_path=$pwd/files/terracotta-license.key

terracotta_path=`echo $terracotta_path |sed 's+/+%2F+g'`

microgateway_path=`echo $microgateway_path |sed 's+/+%2F+g'`

int_path=`echo $int_path |sed 's+/+%2F+g'`

sudo sed -i "s+^integrationServer.LicenseFile.text=__VERSION1__.*+integrationServer.LicenseFile.text=__VERSION1__,$int_path+" $pwd/files/apigateway_script

sudo sed -i "s+^YAMLicenseChooser=__VERSION1__.*+YAMLicenseChooser=__VERSION1__,$microgateway_path+" $pwd/files/apigateway_script

sudo sed -i "s+^TES.LicenseFile.text=__VERSION1__.*+TES.LicenseFile.text=__VERSION1__,$terracotta_path+" $pwd/files/terracotta_script

cd $pwd/files

./SoftwareAGInstaller-Linux_x86_64.bin  -readScript apigateway_script

./SoftwareAGInstaller-Linux_x86_64.bin  -readScript terracotta_script



