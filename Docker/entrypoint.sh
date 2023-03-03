#!/bin/bash
# Set working directory
cd /home/container
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`

# Download the latest Exiled.Installer-Linux file.
echo "Updating Installer.."
# Remove the old one first.
rm -rf Exiled.Installer-Linux
# Download the latest
wget https://github.com/Exiled-Team/EXILED/releases/latest/download/Exiled.Installer-Linux
# Set it as executable.
chmod +x Exiled.Installer-Linux
echo "Installer updated. Running.."
EXTRA=""
# Setup arguments for Exiled.Installer
if [ $PRE_RELEASE == 1 ]; then
	EXTRA="--pre-releases"
fi
if [ ! -z $EXILED_VER ]; then
	EXTRA="--pre-releases --target-version $EXILED_VER"
fi

if [ "$EXILED_VER" != "-1" ]; then
	mkdir -p .temp
        DOTNET_BUNDLE_EXTRACT_BASE_DIR=".temp" ./Exiled.Installer-Linux -p /home/container/scp_server $EXTRA --github-token 6766d533c0ab67029eff3db88f0a3cc34d6887a0
fi

cd .config &&

cd /home/container &&

# Ensure the SCP config folder exists.
echo "Checking verkey.txt.."
if [ ! -d "/home/container/.config/SCP Secret Laboratory" ];then 
    mkdir "/home/container/.config/SCP Secret Laboratory";
fi

## This is no longer necessary with NW API updates.##
# Verify that verkey.txt exists and has the correct value.
# echo "Touching file.."
# touch "/home/container/.config/SCP Secret Laboratory/verkey.txt"
# echo "Verifying key contents.."
# echo "VERIFIED HOST000" > "/home/container/.config/SCP Secret Laboratory/verkey.txt"
# echo "Contents verified."

# If DiscordIntegration Plugin is installed.
if [ -f "/home/container/.config/EXILED/Plugins/DiscordIntegration.dll" ]; then
        cd DiscordIntegration &&
	# If the old bot files exist, remove them and update everything.
	if [ -f "discordIntegration.js" ]; then
		echo "Removing previous DI installation.."
		sleep 2 &&
		rm -rf "discordIntegration.js"
                rm -rf "node_modules"
		rm -rf "package.json"
		rm -rf "package-lock.json"
		rm -rf "synced-roles.yml"
		# Update the existing plugin.
		rm -rf "/home/container/.config/EXILED/Plugins/DiscordIntegration.dll"
		echo "Downloading new version.."
		sleep 1
		wget https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/Plugin.tar.gz &&
		echo "Extracting new plugin.."
		sleep 1
		tar xzvf Plugin.tar.gz -C /home/container/.config/EXILED/Plugins/ &&

		# Download the latest version of the Linux bot.
		echo "Downloading bot.."
		sleep 1
		wget https://github.com/Exiled-Team/DiscordIntegration/releases/latest/download/DiscordIntegration.Bot &&
		# Set the bot as executable.
		chmod +x DiscordIntegration.Bot &&
		wget https://exiled.host/DiscordIntegration-config.json
        fi
	# if logs folder doesn't exist, create it.
	if [ ! -d "logs" ]; then
		mkdir "logs"
	fi

	# If the DiscordIntegration-config.json file exists, force the config values needed and start the bot.
	if [ -f "DiscordIntegration-config.json" ]; then
		echo "Setting up DI configs.."
		sleep 1
		# Ensure port number in bot config is set to the server's port.
	        sed "s/\"Port\":.*/\"Port\": ${SERVER_PORT},/g" DiscordIntegration-config.json > output.txt &&
	        mv DiscordIntegration-config.json DiscordIntegration-config.old.json &&
	        mv output.txt DiscordIntegration-config.json &&

		# Ensure the IP address in the bot config is set to 127.0.0.1.
		sed "s/\"IpAddress\":.*/\"IpAddress\": \"127.0.0.1\"/g" DiscordIntegration-config.json > output.txt &&
		rm -rf DiscordIntegration-config.json &&
		mv output.txt DiscordIntegration-config.json &&

		# Force the message delay to 10sec for ratelimit control.
		sed "s/\"MessageDelay\":.*/\"MessageDelay\": 10000,/g" DiscordIntegration-config.json > output.txt &&
		rm -rf DiscordIntegration-config.json &&
		mv output.txt DiscordIntegration-config.json
	fi

	# Start the bot process
	./DiscordIntegration.Bot &> /dev/null &

	cd /home/container &&
	# Force 60s status update interval for ratelimit control.
        sed "s/status_update_interval:.*/status_update_interval: 60/g" .config/EXILED/Configs/${SERVER_PORT}-config.yml > output1.txt &&
        rm -rf .config/EXILED/Configs/${SERVER_PORT}-config.yml &&
        mv output1.txt .config/EXILED/Configs/${SERVER_PORT}-config.yml &&

	# Force 300s (5min) topic update interval for ratelimit control.
        sed "s/channel_topic_update_interval:.*/channel_topic_update_interval: 300/g" .config/EXILED/Configs/${SERVER_PORT}-config.yml > output2.txt &&
        rm -rf .config/EXILED/Configs/${SERVER_PORT}-config.yml &&
        mv output2.txt .config/EXILED/Configs/${SERVER_PORT}-config.yml

	# Ensure plugin config port is set to the server's port.
        sed "s/port:.*/port: ${SERVER_PORT}/g" .config/EXILED/Configs/${SERVER_PORT}-config.yml > output3.txt &&
        rm -rf .config/EXILED/Configs/${SERVER_PORT}-config.yml &&
        mv output3.txt .config/EXILED/Configs/${SERVER_PORT}-config.yml &&

	# Ensure plugin config ip address is set to 127.0.0.1.
	sed "s/i_p_address:.*/i_p_address: 127.0.0.1/g" .config/EXILED/Configs/${SERVER_PORT}-config.yml > output4.txt &&
	rm -rf .config/EXILED/Configs/${SERVER_PORT}-config.yml &&
	mv output4.txt .config/EXILED/Configs/${SERVER_PORT}-config.yml

	echo "DI Setup complete."
fi

cd /home/container/scp_server &&
${MODIFIED_STARTUP};
