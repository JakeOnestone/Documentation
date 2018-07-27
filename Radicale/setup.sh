# https://radicale.org/tutorial/
# https://radicale.org/setup/
# https://radicale.org/versioning/

# Goal: Run Radicale in a python virtual environment by a system user as a system service.
# Different users are possible, each of them can only read and write their own files.
# Version control changes with git.
# 
# Works with Linux Mint 19 (64 bit)


# Less typing
sudo su

# Add new system user radicale
useradd --system --create-home --shell /sbin/nologin radicale
chmod 700 /home/radicale/

# Create folder structure
cd /home/radicale
mkdir Radicale
chown radicale:radicale Radicale/
cd Radicale
mkdir config log collections
touch config/config config/logging config/users collections/.gitignore
chown radicale:radicale -R config/ log/ collections/
chmod o-rwx config/users collections

# If necessary, install python3, python3 virtual environment, apache2-utils (htpasswd), git
apt-get install -y python3 python3-venv apache2-utils git

# Create virtual environment and inside, install Radicale with bcrypt support
python3 -m venv env_radicale
env_radicale/bin/pip install --upgrade radicale[bcrypt]

## Now, radicale can be started for testing.
## Open "localhost:5232" in a browser to verify.
## After testing, remove the created files
#env_radicale/bin/radicale --config "" --storage-filesystem-folder=/home/radicale/Radicale/tmp_var/lib/radicale/collections
#rm -rf tmp_var/

# Add user, passwords are stored encrypted (bcrypt)
htpasswd -B config/users alice # enter alice's password
htpasswd -B config/users bob # enter bob's password

# Write the files config/config, config/loggin, /etc/systemd/system/radicale.service
cat << EOF >> config/config
# https://radicale.org/configuration/
[server]
hosts = 0.0.0.0:5232
daemon = False
max_connections = 20
max_content_length = 10000000
timeout = 10
ssl = False
dns_lookup = False
realm = Radicale - Authentication required

[encoding]
request = utf-8
stock = utf-8

[auth]
type = htpasswd
htpasswd_filename = /home/radicale/Radicale/config/users
htpasswd_encryption = bcrypt

[rights]
type = owner_only

[storage]
type = multifilesystem
filesystem_folder = /home/radicale/Radicale/collections
hook = git add -A && (git diff --cached --quiet || git commit -m "Changes by "%(user)s)

[logging]
config = /home/radicale/Radicale/config/logging
debug = False
full_environment = False
mask_passwords = True
EOF

cat << EOF >> config/logging
# https://radicale.org/logging/
[loggers]
keys = root

[handlers]
keys = file

[formatters]
keys = full

[logger_root]
level = WARNING
handlers = file

[handler_file]
class = handlers.TimedRotatingFileHandler
args = ('/home/radicale/Radicale/log/radicale.log','midnight',1,7)
formatter = full

[formatter_full]
format = %(asctime)s - %(levelname)s: %(message)s
EOF

cat << EOF > /etc/systemd/system/radicale.service
# https://radicale.org/setup/
# https://github.com/Kozea/Radicale/issues/511
[Unit]
Description=Radicale server
After=network.target
Requires=network.target

[Service]
ExecStart=/home/radicale/Radicale/env_radicale/bin/radicale -C /home/radicale/Radicale/config/config
Restart=on-failure
User=radicale
Group=radicale
UMask=0027
Type=simple
WorkingDirectory=/home/radicale/Radicale/
PrivateTmp=yes
PrivateDevices=yes
ProtectSystem=full
ProtectHome=no
ReadOnlyDirectories=/home/
ReadOnlyDirectories=/home/radicale/
ReadWriteDirectories=/home/radicale/Radicale/
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
EOF

# Setup git
cd collections
cat << EOF >> .gitignore
.Radicale.cache
.Radicale.lock
.Radicale.tmp-*
EOF

sudo -u radicale git init .
sudo -u radicale git config user.name "Radicale"
sudo -u radicale git config user.email "radicale@my-server.org"
sudo -u radicale git add .gitignore
sudo -u radicale git commit -m "Initial commit"

# Start the system services
systemctl enable radicale
systemctl start radicale

# Radicale is running, verify with a browser: "localhost:5232"
