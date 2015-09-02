### dump this script to /usr/local/bin. we'll cron it up elsewhere
package { 'awscli' :
	provider => 'pip',
	ensure => 'latest',
}

$script = "#!/bin/bash

# (optional) You might need to set your PATH variable at the top here
# depending on how you run this script
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ \"\$1\" == \"\" ] || [ \"\$2\" == \"\" ] || [ \"\$3\" == \"\" ]; then
  echo 'Usage: script ZONEID RECORDSET TYPE [IP]'
  exit
fi

# Log directory
DIR='/var/log'

# Hosted Zone ID e.g. BJBK35SKMM9OE
ZONEID=\"\$1\"

# The CNAME you want to update e.g. hello.example.com
RECORDSET=\"\$2\"

# More advanced options below
# The Time-To-Live of this recordset
TTL=60
# Change this if you want
COMMENT=\"Auto updating @ `date`\"
# Change to AAAA if using an IPv6 address
TYPE=\"\$3\"

# Choose from several options to get your IP:
#IPPROVIDER=http://ifconfig.me/ip
IPPROVIDER=https://wtfismyip.com/text
#IPPROVIDER=https://icanhasip.com/

echo -e \"\\n### `date`\"

# Get the IP address
if [ \"\$4\" == \"\" ]; then
  echo \"Getting IP address from \$IPPROVIDER\"
  IP=`curl -sS \$IPPROVIDER`
else
  IP=\"\$4\"
fi

echo -e \"Updating \$RECORDSET (\$TYPE) with IP: \$IP\"

function valid_ip()
{
    local  ip=\$1
    local  stat=1

    if [[ \$ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\$ ]]; then
        OIFS=\$IFS
        IFS='.'
        ip=(\$ip)
        IFS=\$OIFS
        [[ \${ip[0]} -le 255 && \${ip[1]} -le 255 \
            && \${ip[2]} -le 255 && \${ip[3]} -le 255 ]]
        stat=\$?
    fi
    return \$stat
}

if [ \"\$TYPE\" == \"A\" ]; then
    if ! valid_ip \$IP; then
        echo \"Invalid IP address: \$IP\"
	exit 1
    fi
fi

CURRENT=\"`dig +noall +answer \$RECORDSET | grep -oe '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'`\"

if [ \"\$CURRENT\" == \"\$IP\" ]; then
    echo \"dig sez the IP for \$RECORDSET is \$CURRENT, which is the same as what we're trying to set (\$IP)\. Exiting\" 
    exit 0
else
    echo \"IP has changed to \$IP\" 
    # Fill a temp file with valid JSON
    TMPFILE=\$(mktemp /tmp/temporary-file.XXXXXXXX)
    cat > \${TMPFILE} << EOF
    {
      \"Comment\":\"\$COMMENT\",
      \"Changes\":[
        {
          \"Action\":\"UPSERT\",
          \"ResourceRecordSet\":{
            \"ResourceRecords\":[
              {
                \"Value\":\"\$IP\"
              }
            ],
            \"Name\":\"\$RECORDSET\",
            \"Type\":\"\$TYPE\",
            \"TTL\":\$TTL
          }
        }
      ]
    }
EOF

    # Update the Hosted Zone record
    aws route53 change-resource-record-sets \
        --hosted-zone-id \$ZONEID \
        --change-batch file://\"\$TMPFILE\"

    # Clean up
    rm \$TMPFILE
fi
"

file { '/usr/local/bin/update-route53':
  ensure => present,
  mode => '755',
  content => $script,
}

$get_nic_id = '#!/usr/bin/perl
$string = `/sbin/lspci | grep Ethernet`;
$bus = hex(substr $string, 0, 2);
$device = hex(substr $string, 3, 2);
print "enp", $bus,"s", $device,"\n";'

file { '/usr/local/bin/get_nic_id':
  ensure => present,
  mode => '755',
  content => $get_nic_id,
}

