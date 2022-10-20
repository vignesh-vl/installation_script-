
# reading the values from the property_file 

path=`cat /property_file| grep "path"| cut -d"=" -f2 `

node_name_apigw_1=`cat /property_file| grep "node_name_apigw_1"| cut -d"=" -f2 `

node_name_apigw_2=`cat /property_file| grep "node_name_apigw_2"| cut -d"=" -f2 `

node_port_apigw_1=`cat /property_file| grep "node_port_apigw_1"| cut -d"=" -f2 `

node_port_apigw_2=`cat /property_file| grep "node_port_apigw_2"| cut -d"=" -f2 `

cluster_name=`cat /property_file| grep "cluster_name"| cut -d"=" -f2 `

session_time=`cat /property_file| grep "session_time"| cut -d"=" -f2 `

url=`cat /property_file| grep "url"| cut -d"=" -f2 `


cd $path/

#creating directory 

mkdir apigw_1
mkdir apigw_2
sudo chmod 777 apigw_1
sudo chmod 777 apigw_2
 
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

if grep -q vm.max_map_count= /etc/sysctl.conf; then
  sudo sed -i 's/^vm.max.*/vm.max_map_count=262144/' /etc/sysctl.conf
 else
  sudo echo  "vm.max_map_count=262144"  >>  /etc/sysctl.conf
fi

#reloading the system  to apply the changes  

sudo sysctl --load /etc/sysctl.conf


#altering the path  in the silent script  to the current path defined by the user in property_file

sudo sed -i "s+^InstallDir=.*+InstallDir=$path/apigw_1+" /files/apigw_1_script


sudo sed -i "s+^InstallDir=.*+InstallDir=$path/apigw_2+" /files/apigw_2_script


sudo sed -i "s+^InstallDir=.*+InstallDir=$path/elastic_search+" /files/elastic_search_silent_script

cd /files

# executing  or installing the installer  files 

sudo ./SoftwareAGInstaller-Linux_x86_64.bin  -readScript apigw_1_script 

sudo ./SoftwareAGInstaller-Linux_x86_64.bin  -readScript apigw_2_script

sudo ./SoftwareAGInstaller-Linux_x86_64.bin  -readScript elastic_search_silent_script 

#this command  is for only my silent script 

cd $path/

sudo chown -R  vignesh:vignesh $path/apigw_1

sudo chown -R  vignesh:vignesh $path/apigw_2

# copying the terracota licence and starting the  terracotta 

sudo cp /files/terracotta-license.key  $path/apigw_1/common/conf/

sudo cp /files/terracotta-license.key  $path/apigw_2/common/conf/

sudo cp /files/tc-config-new.xml $path/apigw_1/Terracotta/server/wrapper/conf

cd $path/apigw_1/Terracotta/server/bin

sudo nohup ./start-tc-server.sh -n Server1 -f $path/apigw_1/Terracotta/server/wrapper/conf/tc-config-new.xml


# Elastic search configuration

sudo sed -i 's/discovery.seed_hosts:.*/discovery.seed_hosts: ["'"localhost:${node_port_apigw_1// /}"'","'"localhost:${node_port_apigw_2// /}"'"]/' $path/apigw_1/InternalDataStore/config/elasticsearch.yml

sudo sed -i 's/cluster.initial_master_nodes:.*/cluster.initial_master_nodes: ["'"${node_name_apigw_1// /}"'","'"${node_name_apigw_2// /}"'"]/' $path/apigw_1/InternalDataStore/config/elasticsearch.yml

sudo sed -i 's/discovery.seed_hosts:.*/discovery.seed_hosts: ["'"localhost:${node_port_apigw_2// /}"'","'"localhost:${node_port_apigw_1// /}"'"]/' $path/apigw_2/InternalDataStore/config/elasticsearch.yml

sudo sed -i 's/cluster.initial_master_nodes:.*/cluster.initial_master_nodes: ["'"${node_name_apigw_2// /}"'","'"${node_name_apigw_1// /}"'"]/' $path/apigw_2/InternalDataStore/config/elasticsearch.yml

# starting the elastic searcch


cd $path/apigw_1/InternalDataStore/bin

./startup.sh

cd $path/apigw_2/InternalDataStore/bin

./startup.sh

sleep 60

until $(curl --output /dev/null  --silent --head --fail http://localhost:9240/_nodes); do
    printf 'nodes are not up yet \n'
    sleep 5
done

curl -X GET http://localhost:9240/_nodes > output.txt

#checking  the  elastic search clustering 

if [ `jq "._nodes.total" output.txt ` -eq 2 ]
then
 echo "nodes are clustered  successfully"
else
 echo " check the config once  @http://localhost:9240/_nodes"
fi

# starting the  apigateway1

cd  $path/apigw_1/IntegrationServer/instances/default/bin/

./startup.sh

   
until $(curl --output /dev/null  --silent --head --fail http://localhost:5555); do
    printf 'please wait the server you are looking is not up yet\n'
    sleep 5
done

# starting the apigateway2

cd  $path/apigw_2/IntegrationServer/instances/default/bin/

./startup.sh


until $(curl --output /dev/null  --silent --head --fail http://localhost:7777); do
    printf 'please wait the server you are looking is not up yet\n'
    sleep 5
done

# enableing  clustering using  api user interface 

curl --user Administrator:manage -d '{"clusterName":"'"$cluster_name"'","clusterSessTimeout":"'"$session_time"'","actionOnStartupError":"standalone","clusterAware":"true","tsaURLs":"'"$url"'"}' -H "Content-Type: application/json" -X PUT  http://localhost:5555/rest/apigateway/is/cluster 


curl --user Administrator:manage -d '{"clusterName":"'"$cluster_name"'","clusterSessTimeout":"'"$session_time"'","actionOnStartupError":"standalone","clusterAware":"true","tsaURLs":"'"$url"'"}' -H "Content-Type: application/json" -X PUT  http://localhost:7777/rest/apigateway/is/cluster 

#restarting the gateways

cd  $path/apigw_1/IntegrationServer/instances/default/bin/

./shutdown.sh

cd  $path/apigw_2/IntegrationServer/instances/default/bin/

./shutdown.sh


cd  $path/apigw_1/IntegrationServer/instances/default/bin/

./startup.sh



until $(curl --output /dev/null  --silent --head --fail http://localhost:5555); do
    printf 'please wait the server you are looking is not up yet\n'
    sleep 5
done



cd  $path/apigw_2/IntegrationServer/instances/default/bin/

./startup.sh


until $(curl --output /dev/null  --silent --head --fail http://localhost:7777); do
    printf 'please wait the server you are looking is not up yet\n'
    sleep 5
done

# health check  

curl --user Administrator:manage http://localhost:5555/rest/apigateway/health/all -H "Accept:application/json"|jq "." > sts_check.json

if [ `jq ".elasticsearch.status" sts_check.json` == \"green\" ]
 then 
  echo "elastic search status : `jq '.elasticsearch.status' sts_check.json` "
 else 
  echo "elasticsearch is not configured and check the sts_check.json created in the current directory"
fi 

if [ `jq ".cluster.status" sts_check.json` == \"green\" ]
 then 
  echo "cluster status : `jq '.elasticsearch.status' sts_check.json` "
 else 
  echo "cluster is not configured and check the sts_check.json created in the current directory"
fi 

echo "the script executed  successfully"
