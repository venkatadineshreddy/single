#!/bin/bash
export OS_TOKEN='{{ TOKEN.stdout }}'
export OS_URL='{{ os_url }}'
export OS_IDENTITY_API_VERSION=3

cmd_openstack=$(which openstack)
cmd_grep=$(which grep)

$cmd_openstack service list | $cmd_grep keystone
if [ $? = 0 ]
then
    echo "keystone service already available"
else
    openstack service create --name keystone --description "OpenStack Identity" identity
fi

$cmd_openstack endpoint list | $cmd_grep keystone

if [ $? = 0 ]
then
    echo "keystone endpoint already available"
else
    openstack endpoint create --region RegionOne identity public http://{{ controller_localhost }}:5000/v3
    openstack endpoint create --region RegionOne identity internal http://{{ controller_localhost }}:5000/v3
    openstack endpoint create --region RegionOne identity admin http://{{ controller_localhost }}:35357/v3
fi

$cmd_openstack domain list | $cmd_grep default

if [ $? = 0 ]
then
    echo "default domain already available"
else
    openstack domain create --description "Default Domain" default
fi

$cmd_openstack project list | $cmd_grep admin
if [ $? = 0 ]
then
    echo "admin project already available"
else
    openstack project create --domain default --description "Admin Project" admin
fi
$cmd_openstack user list | $cmd_grep admin
if [ $? = 0 ]
then
    echo "admin user already available"
else
    openstack user create --domain default --password {{ adminuser_password }} admin
fi
$cmd_openstack role list | $cmd_grep admin
if [ $? = 0 ]
then
    echo "admin role already available"
else
    openstack role create admin
fi
openstack role add --project admin --user admin admin

$cmd_openstack project list | $cmd_grep service
if [ $? = 0 ]
then
    echo "service project already available"
else
    openstack project create --domain default --description "Service Project" service
fi

$cmd_openstack project list | $cmd_grep demo
if [ $? = 0 ]
then
    echo "demo project already available"
else
    openstack project create --domain default --description "Demo Project" demo
fi
$cmd_openstack user list | $cmd_grep demo
if [ $? = 0 ]
then
    echo "demo user already available"
else
    openstack user create --domain default  --password {{ demo_user_pass }} demo
fi
$cmd_openstack role list | $cmd_grep user
if [ $? = 0 ]
then
    echo "user role already available"
else
    openstack role create user
fi
openstack role add --project demo --user demo user
$cmd_openstack user list | $cmd_grep glance
if [ $? = 0 ]
then
    echo "glance user already available"
else
    openstack user create --domain default --password {{ serviceuser_password }} glance
fi
openstack role add --project service --user glance admin

$cmd_openstack service list | $cmd_grep image
if [ $? = 0 ]
then
    echo "image service already available"
else
    openstack service create --name glance --description "OpenStack Image" image
fi

$cmd_openstack endpoint list | $cmd_grep image
if [ $? = 0 ]
then
    echo "image endpoint already available"
else
    openstack endpoint create --region RegionOne image public http://{{ controller_localhost }}:9292
    openstack endpoint create --region RegionOne image internal http://{{ controller_localhost }}:9292
    openstack endpoint create --region RegionOne image admin http://{{ controller_localhost }}:9292
fi

$cmd_openstack user list | $cmd_grep nova
if [ $? = 0 ]
then
    echo "nova user already available"
else
    openstack user create --domain default  --password {{ serviceuser_password }}  nova
fi

openstack role add --project service --user nova admin

$cmd_openstack service list | $cmd_grep nova
if [ $? = 0 ]
then
    echo "compute service already available"
else
    openstack service create --name nova --description "OpenStack Compute" compute
fi

$cmd_openstack endpoint list | $cmd_grep compute
if [ $? = 0 ]
then
    echo "compute endpoint  already available"
else
    openstack endpoint create --region RegionOne compute public http://{{ controller_localhost }}:8774/v2.1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne compute internal http://{{ controller_localhost }}:8774/v2.1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne compute admin http://{{ controller_localhost }}:8774/v2.1/%\(tenant_id\)s
fi

$cmd_openstack user list | $cmd_grep neutron
if [ $? = 0 ]
then
    echo "neutron user already available"
else
    openstack user create --domain default --password {{ serviceuser_password }} neutron
fi
openstack role add --project service --user neutron admin

$cmd_openstack service list | $cmd_grep network
if [ $? = 0 ]
then
    echo "neutron service already available"
else
    openstack service create --name neutron --description "OpenStack Networking" network
fi

$cmd_openstack endpoint list | $cmd_grep network
if [ $? = 0 ]
then
    echo "neutron endpoint already available"
else
    openstack endpoint create --region RegionOne network public http://{{ controller_localhost }}:9696
    openstack endpoint create --region RegionOne network internal http://{{ controller_localhost }}:9696
    openstack endpoint create --region RegionOne network admin http://{{ controller_localhost }}:9696
fi
