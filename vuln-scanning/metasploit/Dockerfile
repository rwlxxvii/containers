FROM docker.io/kalilinux/kali-rolling

LABEL \
    org.opencontainers.image.name='Metasploit Framework' \
    org.opencontainers.image.description='The worlds most used penetration testing framework.' \
    org.opencontainers.image.usage='https://docs.metasploit.com/' \
    org.opencontainers.image.url='https://www.metasploit.com/' \
    org.opencontainers.image.vendor='Rapid7' \
    org.opencontainers.image.schema-version='6'

ENV DEBIAN_FRONTEND noninteractive \
    LANG=en_US.UTF-8

RUN \
	apt-get upgrade -yq; \
	apt-get install -y \
	curl \
	gnupg \
	apt-transport-https; \
	curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - ; \
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/powershell.list; \
	apt-get update -yq; \
	apt-get install -y \
	build-essential \
	libffi-dev \
	libgit2-dev \
	metasploit-framework \
	python3 \
	python3-pip \
	bash \
	tmux \
	go \
	git \
	openssl \
	hydra \
	hashcat \
	tor \
	torsocks \
	vim \
	nmap \
	wget \
	powershell; \
	apt-get clean -y

# copy sploit/tor/wordlist scripts, see README's...
COPY . /

# dotnet for windows exploitation
RUN \
	# Get Ubuntu version
	declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi); \
	# Download Microsoft signing key and repository
	wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb; \
	# Install Microsoft signing key and repository
	dpkg -i packages-microsoft-prod.deb; \
	# Clean up
	rm packages-microsoft-prod.deb; \
	# Update packages
	sudo apt update
 
WORKDIR /opt

# tooling install, gonna be a chonky container.  comment out tools you don't need, automation scripts not included - use chatGPT to make em' :)
RUN \
	cp tmux.conf /root/.tmux.conf; \
	python3 -m pip --no-cache-dir install -r ./requirements.txt; \
	mkdir -p /root/tooling; cd /root/tooling; \
	# mosquito - Automating reconnaissance and brute force attacks.
	git clone https://github.com/r00t-3xp10it/resource_files.git; \
	chmod +x resource_files/mosquito.sh; resource_files/mosquito.sh -i; \
	# msfenum - A Metasploit auto auxiliary script.
	git clone https://github.com/wez3/msfenum.git; \
	python msfenum/msfenum.py -h; \
	# discover - Custom bash scripts used to automate various penetration testing tasks including recon, scanning, enumeration, and malicious payload creation using Metasploit.
	git clone https://github.com/leebaird/discover.git; \
	# scan4all - 15000+PoCs; 23 kinds of application password crack; 7000+Web fingerprints; 146 protocols and 90000+ rules.
	git clone https://github.com/hktalent/scan4all.git; \
	cd scan4all; go install; cd ..; \
	# WinPwn - Automation for internal Windows Penetration test / AD-Security.
	git clone https://github.com/S3cur3Th1sSh1t/WinPwn.git; \
	pwsh WinPwn/WinPwn.ps1; \
	# pentest-tools - A collection of custom security tools for quick needs.
	git clone https://github.com/gwen001/pentest-tools; \
	python3 -m pip --no-cache-dir install -r pentest-tools/requirements.txt; \
	# BeRoot - Privilege Escalation Project - Windows / Linux / Mac.
	git clone https://github.com/AlessandroZ/BeRoot.git; \
	echo -e "Usage: \n\n python /opt/BeRoot/Linux/beroot.py \n example"; \
	# Inveigh - .NET IPv4/IPv6 machine-in-the-middle tool for penetration testers.
	git clone https://github.com/Kevin-Robertson/Inveigh.git;\
	pwsh Inveigh/Inveigh.psm1; \
	# Red_Team - Some scripts useful for red team activities.
	git clone https://github.com/BankSecurity/Red_Team.git; \
	# r77-rootkit - Fileless ring 3 rootkit with installer and persistence that hides processes, files, network connections, etc.
	git clone https://github.com/bytecode77/r77-rootkit.git; \
	echo -e "Usage: \n\n https://bytecode77.com/r77-rootkit"; \
	# Creds - Some usefull Scripts and Executables for Pentest & Forensics.
	git clone https://github.com/S3cur3Th1sSh1t/Creds.git; \
	# DefenderCheck - Identifies the bytes that Microsoft Defender flags on.
	git clone https://github.com/matterpreter/DefenderCheck.git; \
	echo -e "Warning: \n\n \
	As of the 1.337.157.0 Defender signature update, DefenderCheck is classified as VirTool:MSIL/BytzChk.C!MTB. \n\n \
	As a workaround while I work to get around this, please disable Real-time Protection in Defender before compiling DefenderCheck."; \
	find ./ -name "*.sh" -exec chmod +x {} \; ; \
	rm -f *.zip; \
	mv ../*.py .; mv ../torctl.sh .

EXPOSE 4444
EXPOSE 80
EXPOSE 8080
EXPOSE 443
EXPOSE 445
EXPOSE 8081
ENTRYPOINT ["/init.sh"]