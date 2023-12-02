#!/bin/bash

##############################
#
# RHEL78_stig.sh
# Description: Shell script to automate hardening configurations for RHEL 7.x and 8.x

# =============================================================== STIG FUNCTIONS ===============================================================

# ======================================================== GNOME Hardening Functions:  =========================================================
# Comment out gnome functions starting on line 22122 if gui-less
# Enable GNOME3 Login Warning Banner
CCE-26970-4(){
	# Check for setting in any of the DConf db directories
	# If files contain ibus or distro, ignore them.
	# The assignment assumes that individual filenames don't contain :
	readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/login-screen\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	DCONFFILE="/etc/dconf/db/gdm.d/00-security-settings"
	DBDIR="/etc/dconf/db/gdm.d"

	mkdir -p "${DBDIR}"

	if [ "${#SETTINGSFILES[@]}" -eq 0 ]
	then
	    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
	    printf '%s\n' "[org/gnome/login-screen]" >> ${DCONFFILE}
	    printf '%s=%s\n' "banner-message-enable" "true" >> ${DCONFFILE}
	else
	    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "true")"
	    if grep -q "^\\s*banner-message-enable" "${SETTINGSFILES[@]}"
	    then
	        sed -i "s/\\s*banner-message-enable\\s*=\\s*.*/banner-message-enable=${escaped_value}/g" "${SETTINGSFILES[@]}"
	    else
	        sed -i "\\|\\[org/gnome/login-screen\\]|a\\banner-message-enable=${escaped_value}" "${SETTINGSFILES[@]}"
	    fi
	fi

	dconf update
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/login-screen/banner-message-enable$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/gdm.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/login-screen/banner-message-enable" >> "/etc/dconf/db/gdm.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Set the GNOME3 Login Warning Banner Text 
CCE-26892-0(){
	login_banner_text="^(You[\s\n]+are[\s\n]+accessing[\s\n]+a[\s\n]+U\.S\.[\s\n]+Government[\s\n]+\(USG\)[\s\n]+Information[\s\n]+System[\s\n]+\(IS\)[\s\n]+that[\s\n]+is[\s\n]+provided[\s\n]+for[\s\n]+USG\-authorized[\s\n]+use[\s\n]+only\.[\s\n]+By[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+\(which[\s\n]+includes[\s\n]+any[\s\n]+device[\s\n]+attached[\s\n]+to[\s\n]+this[\s\n]+IS\)\,[\s\n]+you[\s\n]+consent[\s\n]+to[\s\n]+the[\s\n]+following[\s\n]+conditions\:(?:[\n]+|(?:\\n)+)\-The[\s\n]+USG[\s\n]+routinely[\s\n]+intercepts[\s\n]+and[\s\n]+monitors[\s\n]+communications[\s\n]+on[\s\n]+this[\s\n]+IS[\s\n]+for[\s\n]+purposes[\s\n]+including\,[\s\n]+but[\s\n]+not[\s\n]+limited[\s\n]+to\,[\s\n]+penetration[\s\n]+testing\,[\s\n]+COMSEC[\s\n]+monitoring\,[\s\n]+network[\s\n]+operations[\s\n]+and[\s\n]+defense\,[\s\n]+personnel[\s\n]+misconduct[\s\n]+\(PM\)\,[\s\n]+law[\s\n]+enforcement[\s\n]+\(LE\)\,[\s\n]+and[\s\n]+counterintelligence[\s\n]+\(CI\)[\s\n]+investigations\.(?:[\n]+|(?:\\n)+)\-At[\s\n]+any[\s\n]+time\,[\s\n]+the[\s\n]+USG[\s\n]+may[\s\n]+inspect[\s\n]+and[\s\n]+seize[\s\n]+data[\s\n]+stored[\s\n]+on[\s\n]+this[\s\n]+IS\.(?:[\n]+|(?:\\n)+)\-Communications[\s\n]+using\,[\s\n]+or[\s\n]+data[\s\n]+stored[\s\n]+on\,[\s\n]+this[\s\n]+IS[\s\n]+are[\s\n]+not[\s\n]+private\,[\s\n]+are[\s\n]+subject[\s\n]+to[\s\n]+routine[\s\n]+monitoring\,[\s\n]+interception\,[\s\n]+and[\s\n]+search\,[\s\n]+and[\s\n]+may[\s\n]+be[\s\n]+disclosed[\s\n]+or[\s\n]+used[\s\n]+for[\s\n]+any[\s\n]+USG\-authorized[\s\n]+purpose\.(?:[\n]+|(?:\\n)+)\-This[\s\n]+IS[\s\n]+includes[\s\n]+security[\s\n]+measures[\s\n]+\(e\.g\.\,[\s\n]+authentication[\s\n]+and[\s\n]+access[\s\n]+controls\)[\s\n]+to[\s\n]+protect[\s\n]+USG[\s\n]+interests\-\-not[\s\n]+for[\s\n]+your[\s\n]+personal[\s\n]+benefit[\s\n]+or[\s\n]+privacy\.(?:[\n]+|(?:\\n)+)\-Notwithstanding[\s\n]+the[\s\n]+above\,[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+does[\s\n]+not[\s\n]+constitute[\s\n]+consent[\s\n]+to[\s\n]+PM\,[\s\n]+LE[\s\n]+or[\s\n]+CI[\s\n]+investigative[\s\n]+searching[\s\n]+or[\s\n]+monitoring[\s\n]+of[\s\n]+the[\s\n]+content[\s\n]+of[\s\n]+privileged[\s\n]+communications\,[\s\n]+or[\s\n]+work[\s\n]+product\,[\s\n]+related[\s\n]+to[\s\n]+personal[\s\n]+representation[\s\n]+or[\s\n]+services[\s\n]+by[\s\n]+attorneys\,[\s\n]+psychotherapists\,[\s\n]+or[\s\n]+clergy\,[\s\n]+and[\s\n]+their[\s\n]+assistants\.[\s\n]+Such[\s\n]+communications[\s\n]+and[\s\n]+work[\s\n]+product[\s\n]+are[\s\n]+private[\s\n]+and[\s\n]+confidential\.[\s\n]+See[\s\n]+User[\s\n]+Agreement[\s\n]+for[\s\n]+details\.|I've[\s\n]+read[\s\n]+\&[\s\n]+consent[\s\n]+to[\s\n]+terms[\s\n]+in[\s\n]+IS[\s\n]+user[\s\n]+agreem't\.)$"

	# Multiple regexes transform the banner regex into a usable banner
	# 0 - Remove anchors around the banner text
	login_banner_text=$(echo "$login_banner_text" | sed 's/^\^\(.*\)\$$/\1/g')
	# 1 - Keep only the first banners if there are multiple
	#    (dod_banners contains the long and short banner)
	login_banner_text=$(echo "$login_banner_text" | sed 's/^(\(.*\)|.*)$/\1/g')
	# 2 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
	login_banner_text=$(echo "$login_banner_text" | sed 's/\[\\s\\n\]+/ /g')
	# 3 - Adds newline "tokens". (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "(n)*")
	login_banner_text=$(echo "$login_banner_text" | sed 's/(?:\[\\n\]+|(?:\\n)+)/(n)*/g')
	# 4 - Remove any leftover backslash. (From any parethesis in the banner, for example).
	login_banner_text=$(echo "$login_banner_text" | sed 's/\\//g')
	# 5 - Removes the newline "token." (Transforms them into newline escape sequences "\n").
	#    ( Needs to be done after 4, otherwise the escapce sequence will become just "n".
	login_banner_text=$(echo "$login_banner_text" | sed 's/(n)\*/\\n/g')

	# Check for setting in any of the DConf db directories
	# If files contain ibus or distro, ignore them.
	# The assignment assumes that individual filenames don't contain :
	readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/login-screen\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	DCONFFILE="/etc/dconf/db/gdm.d/00-security-settings"
	DBDIR="/etc/dconf/db/gdm.d"

	mkdir -p "${DBDIR}"

	if [ "${#SETTINGSFILES[@]}" -eq 0 ]
	then
	    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
	    printf '%s\n' "[org/gnome/login-screen]" >> ${DCONFFILE}
	    printf '%s=%s\n' "banner-message-text" "'${login_banner_text}'" >> ${DCONFFILE}
	else
	    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "'${login_banner_text}'")"
	    if grep -q "^\\s*banner-message-text" "${SETTINGSFILES[@]}"
	    then
	        sed -i "s/\\s*banner-message-text\\s*=\\s*.*/banner-message-text=${escaped_value}/g" "${SETTINGSFILES[@]}"
	    else
	        sed -i "\\|\\[org/gnome/login-screen\\]|a\\banner-message-text=${escaped_value}" "${SETTINGSFILES[@]}"
	    fi
	fi

	dconf update
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/login-screen/banner-message-text$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/gdm.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/login-screen/banner-message-text" >> "/etc/dconf/db/gdm.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Ensure Users Cannot Change GNOME3 Session Idle Settings
CCE-80544-0(){
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/session/idle-delay$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/session/idle-delay" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Set GNOME3 Screensaver Lock Delay After Activation Period
CCE-80370-0(){
	var_screensaver_lock_delay="5"

	# Check for setting in any of the DConf db directories
	# If files contain ibus or distro, ignore them.
	# The assignment assumes that individual filenames don't contain :
	readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/desktop/screensaver\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	DCONFFILE="/etc/dconf/db/local.d/00-security-settings"
	DBDIR="/etc/dconf/db/local.d"

	mkdir -p "${DBDIR}"

	if [ "${#SETTINGSFILES[@]}" -eq 0 ]
	then
	    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
	    printf '%s\n' "[org/gnome/desktop/screensaver]" >> ${DCONFFILE}
	    printf '%s=%s\n' "lock-delay" "uint32 ${var_screensaver_lock_delay}" >> ${DCONFFILE}
	else
	    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "uint32 ${var_screensaver_lock_delay}")"
	    if grep -q "^\\s*lock-delay" "${SETTINGSFILES[@]}"
	    then
	        sed -i "s/\\s*lock-delay\\s*=\\s*.*/lock-delay=${escaped_value}/g" "${SETTINGSFILES[@]}"
	    else
	        sed -i "\\|\\[org/gnome/desktop/screensaver\\]|a\\lock-delay=${escaped_value}" "${SETTINGSFILES[@]}"
	    fi
	fi

	dconf update
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/screensaver/lock-delay$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/screensaver/lock-delay" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Ensure Users Cannot Change GNOME3 Screensaver Settings
CCE-80371-8(){
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/screensaver/lock-delay$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/screensaver/lock-delay" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Enable GNOME3 Screensaver Idle Activation
CCE-80111-8(){
	# Check for setting in any of the DConf db directories
	# If files contain ibus or distro, ignore them.
	# The assignment assumes that individual filenames don't contain :
	readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/desktop/screensaver\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	DCONFFILE="/etc/dconf/db/local.d/00-security-settings"
	DBDIR="/etc/dconf/db/local.d"

	mkdir -p "${DBDIR}"

	if [ "${#SETTINGSFILES[@]}" -eq 0 ]
	then
	    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
	    printf '%s\n' "[org/gnome/desktop/screensaver]" >> ${DCONFFILE}
	    printf '%s=%s\n' "idle-activation-enabled" "true" >> ${DCONFFILE}
	else
	    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "true")"
	    if grep -q "^\\s*idle-activation-enabled" "${SETTINGSFILES[@]}"
	    then
	        sed -i "s/\\s*idle-activation-enabled\\s*=\\s*.*/idle-activation-enabled=${escaped_value}/g" "${SETTINGSFILES[@]}"
	    else
	        sed -i "\\|\\[org/gnome/desktop/screensaver\\]|a\\idle-activation-enabled=${escaped_value}" "${SETTINGSFILES[@]}"
	    fi
	fi

	dconf update
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/screensaver/idle-activation-enabled$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/screensaver/idle-activation-enabled" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Set GNOME3 Screensaver Inactivity Timeout
CCE-80110-0(){
	inactivity_timeout_value="900"

	# Check for setting in any of the DConf db directories
	# If files contain ibus or distro, ignore them.
	# The assignment assumes that individual filenames don't contain :
	readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/desktop/session\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	DCONFFILE="/etc/dconf/db/local.d/00-security-settings"
	DBDIR="/etc/dconf/db/local.d"

	mkdir -p "${DBDIR}"

	if [ "${#SETTINGSFILES[@]}" -eq 0 ]
	then
	    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
	    printf '%s\n' "[org/gnome/desktop/session]" >> ${DCONFFILE}
	    printf '%s=%s\n' "idle-delay" "uint32 ${inactivity_timeout_value}" >> ${DCONFFILE}
	else
	    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "uint32 ${inactivity_timeout_value}")"
	    if grep -q "^\\s*idle-delay" "${SETTINGSFILES[@]}"
	    then
	        sed -i "s/\\s*idle-delay\\s*=\\s*.*/idle-delay=${escaped_value}/g" "${SETTINGSFILES[@]}"
	    else
	        sed -i "\\|\\[org/gnome/desktop/session\\]|a\\idle-delay=${escaped_value}" "${SETTINGSFILES[@]}"
	    fi
	fi

	dconf update
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/session/idle-delay$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/session/idle-delay" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Ensure Users Cannot Change GNOME3 Screensaver Lock After Idle Period
CCE-80563-0(){
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/screensaver/lock-enabled$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/screensaver/lock-enabled" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Enable GNOME3 Screensaver Lock After Idle Period
CCE-80112-6(){
	# Check for setting in any of the DConf db directories
	# If files contain ibus or distro, ignore them.
	# The assignment assumes that individual filenames don't contain :
	readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/desktop/screensaver\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	DCONFFILE="/etc/dconf/db/local.d/00-security-settings"
	DBDIR="/etc/dconf/db/local.d"

	mkdir -p "${DBDIR}"

	if [ "${#SETTINGSFILES[@]}" -eq 0 ]
	then
	    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
	    printf '%s\n' "[org/gnome/desktop/screensaver]" >> ${DCONFFILE}
	    printf '%s=%s\n' "lock-enabled" "true" >> ${DCONFFILE}
	else
	    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "true")"
	    if grep -q "^\\s*lock-enabled" "${SETTINGSFILES[@]}"
	    then
	        sed -i "s/\\s*lock-enabled\\s*=\\s*.*/lock-enabled=${escaped_value}/g" "${SETTINGSFILES[@]}"
	    else
	        sed -i "\\|\\[org/gnome/desktop/screensaver\\]|a\\lock-enabled=${escaped_value}" "${SETTINGSFILES[@]}"
	    fi
	fi

	dconf update
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/screensaver/lock-enabled$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/screensaver/lock-enabled" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Ensure Users Cannot Change GNOME3 Screensaver Idle Activation
CCE-80564-8(){
	# Check for setting in any of the DConf db directories
	LOCKFILES=$(grep -r "^/org/gnome/desktop/screensaver/idle-activation-enabled$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
	LOCKSFOLDER="/etc/dconf/db/local.d/locks"

	mkdir -p "${LOCKSFOLDER}"

	if [[ -z "${LOCKFILES}" ]]
	then
	    echo "/org/gnome/desktop/screensaver/idle-activation-enabled" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
	fi

	dconf update
	}

# Disable GDM Automatic Login
CCE-80104-3(){
	if rpm --quiet -q gdm
	then
		if ! grep -q "^AutomaticLoginEnable=" /etc/gdm/custom.conf
		then
			sed -i "/^\[daemon\]/a \
			AutomaticLoginEnable=False" /etc/gdm/custom.conf
		else
			sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=False/g" /etc/gdm/custom.conf
		fi
	fi
	}

# Disable GDM Guest Login
CCE-80105-0(){
	if rpm --quiet -q gdm
	then
		if ! grep -q "^TimedLoginEnable=" /etc/gdm/custom.conf
		then
			sed -i "/^\[daemon\]/a \
			TimedLoginEnable=False" /etc/gdm/custom.conf
		else
			sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=False/g" /etc/gdm/custom.conf
		fi
	fi
	}

# ===============================================================================================================================================

# The PAM system service can be configured to only store encrypted representations of passwords. 
# In /etc/pam.d/system-auth, the password section of the file controls which PAM modules execute during a password change. 
# Set the pam_unix.so module in the password section to include the argument sha512
CCE-82043-1(){
	AUTH_FILES[0]="/etc/pam.d/system-auth"
	AUTH_FILES[1]="/etc/pam.d/password-auth"

	for pamFile in "${AUTH_FILES[@]}"
	do
		if ! grep -q "^password.*sufficient.*pam_unix.so.*sha512" $pamFile; then
			sed -i --follow-symlinks "/^password.*sufficient.*pam_unix.so/ s/$/ sha512/" $pamFile
		fi
	done
	}

# To configure the system to lock out accounts after a number of incorrect login attempts and require an administrator
# to unlock the account using pam_faillock.so, modify the content of both /etc/pam.d/system-auth and /etc/pam.d/password-auth
CCE-26884-7(){
	var_accounts_passwords_pam_faillock_unlock_time="900"

	AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

	for pam_file in "${AUTH_FILES[@]}"
	do
	    # is auth required pam_faillock.so preauth present?
	    if grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*$' "$pam_file" ; then
	        # is the option set?
	        if grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*'"unlock_time"'=([0-9]*).*$' "$pam_file" ; then
	            # just change the value of option to a correct value
	            sed -i --follow-symlinks 's/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\('"unlock_time"' *= *\).*/\1\2'"$var_accounts_passwords_pam_faillock_unlock_time"'/' "$pam_file"
	        # the option is not set.
	        else
	            # append the option
	            sed -i --follow-symlinks '/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ '"unlock_time"'='"$var_accounts_passwords_pam_faillock_unlock_time"'/' "$pam_file"
	        fi
	    # auth required pam_faillock.so preauth is not present, insert the whole line
	    else
	        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent '"unlock_time"'='"$var_accounts_passwords_pam_faillock_unlock_time" "$pam_file"
	    fi
	    # is auth default pam_faillock.so authfail present?
	    if grep -qE '^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*$' "$pam_file" ; then
	        # is the option set?
	        if grep -qE '^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*'"unlock_time"'=([0-9]*).*$' "$pam_file" ; then
	            # just change the value of option to a correct value
	            sed -i --follow-symlinks 's/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\('"unlock_time"' *= *\).*/\1\2'"$var_accounts_passwords_pam_faillock_unlock_time"'/' "$pam_file"
	        # the option is not set.
	        else
	            # append the option
	            sed -i --follow-symlinks '/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ '"unlock_time"'='"$var_accounts_passwords_pam_faillock_unlock_time"'/' "$pam_file"
	        fi
	    # auth default pam_faillock.so authfail is not present, insert the whole line
	    else
	        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail '"unlock_time"'='"$var_accounts_passwords_pam_faillock_unlock_time" "$pam_file"
	    fi
	    if ! grep -qE '^\s*account\s+required\s+pam_faillock\.so.*$' "$pam_file" ; then
	        sed -E -i --follow-symlinks '/^\s*account\s*required\s*pam_unix.so/i account     required      pam_faillock.so' "$pam_file"
	    fi
	done
	}

# Do not allow users to reuse recent passwords. This can be accomplished by using the remember option for the pam_unix or pam_pwhistory PAM modules.
CCE-82030-8(){
	var_password_pam_unix_remember="5"

	AUTH_FILES[0]="/etc/pam.d/system-auth"
	AUTH_FILES[1]="/etc/pam.d/password-auth"

	for pamFile in "${AUTH_FILES[@]}"
	do
		if grep -q "remember=" $pamFile; then
			sed -i --follow-symlinks "s/\(^password.*sufficient.*pam_unix.so.*\)\(\(remember *= *\)[^ $]*\)/\1remember=$var_password_pam_unix_remember/" $pamFile
		else
			sed -i --follow-symlinks "/^password[[:space:]]\+sufficient[[:space:]]\+pam_unix.so/ s/$/ remember=$var_password_pam_unix_remember/" $pamFile
		fi
	done
	}

# To configure the system to lock out accounts after a number of incorrect login attempts using pam_faillock.so, modify the content of both /etc/pam.d/system-auth and /etc/pam.d/password-auth
CCE-27350-8(){
	var_accounts_passwords_pam_faillock_deny="5"

	AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

	for pam_file in "${AUTH_FILES[@]}"
	do
	    # is auth required pam_faillock.so preauth present?
	    if grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*$' "$pam_file" ; then
	        # is the option set?
	        if grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+preauth.*'"deny"'=([0-9]*).*$' "$pam_file" ; then
	            # just change the value of option to a correct value
	            sed -i --follow-symlinks 's/\(^auth.*required.*pam_faillock.so.*preauth.*silent.*\)\('"deny"' *= *\).*/\1\2'"$var_accounts_passwords_pam_faillock_deny"'/' "$pam_file"
	        # the option is not set.
	        else
	            # append the option
	            sed -i --follow-symlinks '/^auth.*required.*pam_faillock.so.*preauth.*silent.*/ s/$/ '"deny"'='"$var_accounts_passwords_pam_faillock_deny"'/' "$pam_file"
	        fi
	    # auth required pam_faillock.so preauth is not present, insert the whole line
	    else
	        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix.so.*/i auth        required      pam_faillock.so preauth silent '"deny"'='"$var_accounts_passwords_pam_faillock_deny" "$pam_file"
	    fi
	    # is auth default pam_faillock.so authfail present?
	    if grep -qE '^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*$' "$pam_file" ; then
	        # is the option set?
	        if grep -qE '^\s*auth\s+(\[default=die\])\s+pam_faillock\.so\s+authfail.*'"deny"'=([0-9]*).*$' "$pam_file" ; then
	            # just change the value of option to a correct value
	            sed -i --follow-symlinks 's/\(^auth.*[default=die].*pam_faillock.so.*authfail.*\)\('"deny"' *= *\).*/\1\2'"$var_accounts_passwords_pam_faillock_deny"'/' "$pam_file"
	        # the option is not set.
	        else
	            # append the option
	            sed -i --follow-symlinks '/^auth.*[default=die].*pam_faillock.so.*authfail.*/ s/$/ '"deny"'='"$var_accounts_passwords_pam_faillock_deny"'/' "$pam_file"
	        fi
	    # auth default pam_faillock.so authfail is not present, insert the whole line
	    else
	        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix.so.*/a auth        [default=die] pam_faillock.so authfail '"deny"'='"$var_accounts_passwords_pam_faillock_deny" "$pam_file"
	    fi
	    if ! grep -qE '^\s*account\s+required\s+pam_faillock\.so.*$' "$pam_file" ; then
	        sed -E -i --follow-symlinks '/^\s*account\s*required\s*pam_unix.so/i account     required      pam_faillock.so' "$pam_file"
	    fi
	done
	}

# The pam_pwquality module's minlen parameter controls requirements for minimum characters required in a password. Add minlen=14 after pam_pwquality to set minimum password length requirements.
CCE-27293-0(){
	var_password_pam_minlen="16"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^minlen' $var_password_pam_minlen 'CCE-27293-0' '%s = %s'
	}

# The pam_pwquality module's dcredit parameter controls requirements for usage of digits in a password. When set to a negative number, any password will be required to contain that many digits.
# When set to a positive number, pam_pwquality will grant +1 additional length credit for each digit. Modify the dcredit setting in /etc/security/pwquality.conf to require the use of a digit in passwords.
CCE-27214-6(){
	var_password_pam_dcredit="-1"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^dcredit' $var_password_pam_dcredit 'CCE-27214-6' '%s = %s'
	}

# The pam_pwquality module's lcredit parameter controls requirements for usage of lowercase letters in a password. When set to a negative number, any password will be required to contain that many
# lowercase characters. When set to a positive number, pam_pwquality will grant +1 additional length credit for each lowercase character. Modify the lcredit setting in /etc/security/pwquality.conf
# to require the use of a lowercase character in passwords.
CCE-27345-8(){
	var_password_pam_lcredit="-1"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^lcredit' $var_password_pam_lcredit 'CCE-27345-8' '%s = %s'
	}


# The pam_pwquality module's ucredit= parameter controls requirements for usage of uppercase letters in a password. When set to a negative number, any password will be required to contain that many uppercase
# characters. When set to a positive number, pam_pwquality will grant +1 additional length credit for each uppercase character. Modify the ucredit setting in /etc/security/pwquality.conf to require the use
# of an uppercase character in passwords.
CCE-27200-5(){
	var_password_pam_ucredit="-1"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^ucredit' $var_password_pam_ucredit 'CCE-27200-5' '%s = %s'
	}

# To configure the number of retry prompts that are permitted per-session: Edit the pam_pwquality.so statement in /etc/pam.d/system-auth to show retry=3, or a lower value if site policy is more restrictive.
# The DoD requirement is a maximum of 3 prompts per session.
CCE-27160-1(){
	var_password_pam_retry="5"

	if grep -q "retry=" /etc/pam.d/system-auth ; then
		sed -i --follow-symlinks "s/\(retry *= *\).*/\1$var_password_pam_retry/" /etc/pam.d/system-auth
	else
		sed -i --follow-symlinks "/pam_pwquality.so/ s/$/ retry=$var_password_pam_retry/" /etc/pam.d/system-auth
	fi
	}
	
# Single-user mode is intended as a system recovery method, providing a single user root access to the system by providing a boot option at startup. By default, no authentication is performed if single-user mode is selected.
# By default, single-user mode is protected by requiring a password and is set in /usr/lib/systemd/system/rescue.service.
CCE-27287-2(){
	service_file="/usr/lib/systemd/system/rescue.service"

	sulogin='/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'

	if grep "^ExecStart=.*" "$service_file" ; then
	    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin%" "$service_file"
	else
	    echo "ExecStart=-$sulogin" >> "$service_file"
	fi
	}

# Ensure the Default Bash Umask is Set Correctly
CCE-80202-5(){
	var_accounts_user_umask="027"

	grep -q umask /etc/bashrc && \
	  sed -i "s/umask.*/umask $var_accounts_user_umask/g" /etc/bashrc
	if ! [ $? -eq 0 ]; then
	    echo "umask $var_accounts_user_umask" >> /etc/bashrc
	fi
	}

# Ensure the Default Umask is Set Correctly in /etc/profile
CCE-80204-1(){
	var_accounts_user_umask="027"

	grep -q umask /etc/profile && \
	  sed -i "s/umask.*/umask $var_accounts_user_umask/g" /etc/profile
	if ! [ $? -eq 0 ]; then
	    echo "umask $var_accounts_user_umask" >> /etc/profile
	fi
	}

# Set Password Warning Age
CCE-82016-7(){
	var_accounts_password_warn_age_login_defs="7"

	grep -q ^PASS_WARN_AGE /etc/login.defs && \
	  sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE     $var_accounts_password_warn_age_login_defs/g" /etc/login.defs
	if ! [ $? -eq 0 ]; then
	    echo "PASS_WARN_AGE      $var_accounts_password_warn_age_login_defs" >> /etc/login.defs
	fi
	}

# Set Password Minimum Age
CCE-82036-5(){
	var_accounts_minimum_age_login_defs="7"

	grep -q ^PASS_MIN_DAYS /etc/login.defs && \
	  sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS     $var_accounts_minimum_age_login_defs/g" /etc/login.defs
	if ! [ $? -eq 0 ]; then
	    echo "PASS_MIN_DAYS      $var_accounts_minimum_age_login_defs" >> /etc/login.defs
	fi
	}

# Set Password Maximum Age
CCE-27051-2(){
	var_accounts_maximum_age_login_defs="90"

	grep -q ^PASS_MAX_DAYS /etc/login.defs && \
	  sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS     $var_accounts_maximum_age_login_defs/g" /etc/login.defs
	if ! [ $? -eq 0 ]; then
	    echo "PASS_MAX_DAYS      $var_accounts_maximum_age_login_defs" >> /etc/login.defs
	fi
	}

# Verify Only Root Has UID 0
CCE-82054-8(){
	awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd | xargs passwd -l
	}

# Set Account Expiration Following Inactivity
CCE-27355-7(){
	var_account_disable_post_pw_expiration="30"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/default/useradd' '^INACTIVE' "$var_account_disable_post_pw_expiration" 'CCE-27355-7' '%s=%s'
	}

# Configure auditd Max Log File Size
CCE-27319-3(){
	var_auditd_max_log_file="6"

	AUDITCONFIG=/etc/audit/auditd.conf
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append $AUDITCONFIG '^max_log_file' "$var_auditd_max_log_file" "CCE-27319-3"
	}

# Configure auditd mail_acct Action on Low Disk Space 
CCE-27394-6(){
	var_auditd_action_mail_acct="root"

	AUDITCONFIG=/etc/audit/auditd.conf
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append $AUDITCONFIG '^action_mail_acct' "$var_auditd_action_mail_acct" "CCE-27394-6"
	}

# Configure auditd admin_space_left Action on Low Disk Space
CCE-27370-6(){
	var_auditd_admin_space_left_action="single"

	AUDITCONFIG=/etc/audit/auditd.conf
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append $AUDITCONFIG '^admin_space_left_action' "$var_auditd_admin_space_left_action" "CCE-27370-6"
	}

# Configure auditd max_log_file_action Upon Reaching Maximum Log Size
CCE-27231-0(){
	var_auditd_max_log_file_action="rotate"

	AUDITCONFIG=/etc/audit/auditd.conf
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append $AUDITCONFIG '^max_log_file_action' "$var_auditd_max_log_file_action" "CCE-27231-0"
	}

# Ensure auditd Collects Information on Kernel Module Loading and Unloading
CCE-27129-6(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	# Note: 32-bit and 64-bit kernel syscall numbers not always line up =>
	#       it's required on a 64-bit system to check also for the presence
	#       of 32-bit's equivalent of the corresponding rule.
	#       (See `man 7 audit.rules` for details )
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
	        GROUP="modules"

	        PATTERN="-a always,exit -F arch=$ARCH -S init_module -S delete_module -S finit_module \(-F key=\|-k \).*"
	        FULL_RULE="-a always,exit -F arch=$ARCH -S init_module -S delete_module -S finit_module -k modules"

	        # Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	        fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	        fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Attempts to Alter Logon and Logout Events
CCE-27204-7(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/log/tallylog" "wa" "logins"
	fix_audit_watch_rule "augenrules" "/var/log/tallylog" "wa" "logins"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/run/faillock" "wa" "logins"
	fix_audit_watch_rule "augenrules" "/var/run/faillock" "wa" "logins"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/log/lastlog" "wa" "logins"
	fix_audit_watch_rule "augenrules" "/var/log/lastlog" "wa" "logins"
	}

# Record Attempts to Alter Time Through stime
CCE-27299-7(){
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}


	# Function to perform remediation for the 'adjtimex', 'settimeofday', and 'stime' audit
	# system calls on RHEL, Fedora or OL systems.
	# Remediation performed for both possible tools: 'auditctl' and 'augenrules'.
	#
	# Note: 'stime' system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
	# therefore excluded from the list of time group system calls to be audited on this arch
	#
	# Example Call:
	#
	#      perform_audit_adjtimex_settimeofday_stime_remediation
	#
	function perform_audit_adjtimex_settimeofday_stime_remediation {

	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do

		PATTERN="-a always,exit -F arch=${ARCH} -S .* -k *"
		# Create expected audit group and audit rule form for particular system call & architecture
		if [ ${ARCH} = "b32" ]
		then
			# stime system call is known at 32-bit arch (see e.g "$ ausyscall i386 stime" 's output)
			# so append it to the list of time group system calls to be audited
			GROUP="\(adjtimex\|settimeofday\|stime\)"
			FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -S stime -k audit_time_rules"
		elif [ ${ARCH} = "b64" ]
		then
			# stime system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
			# therefore don't add it to the list of time group system calls to be audited
			GROUP="\(adjtimex\|settimeofday\)"
			FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -k audit_time_rules"
		fi
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done

	}
	perform_audit_adjtimex_settimeofday_stime_remediation
	}

# Record attempts to alter time through settimeofday
CCE-27216-1(){
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}


	# Function to perform remediation for the 'adjtimex', 'settimeofday', and 'stime' audit
	# system calls on RHEL, Fedora or OL systems.
	# Remediation performed for both possible tools: 'auditctl' and 'augenrules'.
	#
	# Note: 'stime' system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
	# therefore excluded from the list of time group system calls to be audited on this arch
	#
	# Example Call:
	#
	#      perform_audit_adjtimex_settimeofday_stime_remediation
	#
	function perform_audit_adjtimex_settimeofday_stime_remediation {

	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do

		PATTERN="-a always,exit -F arch=${ARCH} -S .* -k *"
		# Create expected audit group and audit rule form for particular system call & architecture
		if [ ${ARCH} = "b32" ]
		then
			# stime system call is known at 32-bit arch (see e.g "$ ausyscall i386 stime" 's output)
			# so append it to the list of time group system calls to be audited
			GROUP="\(adjtimex\|settimeofday\|stime\)"
			FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -S stime -k audit_time_rules"
		elif [ ${ARCH} = "b64" ]
		then
			# stime system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
			# therefore don't add it to the list of time group system calls to be audited
			GROUP="\(adjtimex\|settimeofday\)"
			FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -k audit_time_rules"
		fi
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done

	}
	perform_audit_adjtimex_settimeofday_stime_remediation
	}

# Record Attempts to Alter the localtime File
CCE-27310-2(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	fix_audit_watch_rule "augenrules" "/etc/localtime" "wa" "audit_time_rules"
	}

# Record Attempts to Alter Time Through clock_settime
CCE-27219-5(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S clock_settime -F a0=.* \(-F key=\|-k \).*"
		GROUP="clock_settime"
		FULL_RULE="-a always,exit -F arch=$ARCH -S clock_settime -F a0=0x0 -k time-change"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record attempts to alter time through adjtimex
CCE-27290-6(){
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}


	# Function to perform remediation for the 'adjtimex', 'settimeofday', and 'stime' audit
	# system calls on RHEL, Fedora or OL systems.
	# Remediation performed for both possible tools: 'auditctl' and 'augenrules'.
	#
	# Note: 'stime' system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
	# therefore excluded from the list of time group system calls to be audited on this arch
	#
	# Example Call:
	#
	#      perform_audit_adjtimex_settimeofday_stime_remediation
	#
	function perform_audit_adjtimex_settimeofday_stime_remediation {

	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do

		PATTERN="-a always,exit -F arch=${ARCH} -S .* -k *"
		# Create expected audit group and audit rule form for particular system call & architecture
		if [ ${ARCH} = "b32" ]
		then
			# stime system call is known at 32-bit arch (see e.g "$ ausyscall i386 stime" 's output)
			# so append it to the list of time group system calls to be audited
			GROUP="\(adjtimex\|settimeofday\|stime\)"
			FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -S stime -k audit_time_rules"
		elif [ ${ARCH} = "b64" ]
		then
			# stime system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
			# therefore don't add it to the list of time group system calls to be audited
			GROUP="\(adjtimex\|settimeofday\)"
			FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -k audit_time_rules"
		fi
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done

	}
	perform_audit_adjtimex_settimeofday_stime_remediation
	}

# Record Events that Modify the System's Discretionary Access Controls - fchown
CCE-27356-5(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S fchown.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S fchown -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - setxattr
CCE-27213-8(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S setxattr.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S setxattr -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - chown
CCE-27364-9(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S chown.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S chown -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - fchownat
CCE-27387-0(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S fchownat.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S fchownat -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - chmod
CCE-27339-1(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S chmod.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S chmod -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - removexattr
CCE-27367-2(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S removexattr.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S removexattr -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - fchmod
CCE-27393-8(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S fchmod.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S fchmod -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - lsetxattr
CCE-27280-7(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S lsetxattr.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S lsetxattr -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - fremovexattr
CCE-27353-2(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S fremovexattr.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S fremovexattr -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - lchown
CCE-27083-5(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S lchown.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S lchown -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - fsetxattr
CCE-27389-6(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S fsetxattr.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S fsetxattr -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - fchmodat
CCE-27388-8(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S fchmodat.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S fchmodat -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify the System's Discretionary Access Controls - lremovexattr
CCE-27410-0(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S lremovexattr.*"
		GROUP="perm_mod"
		FULL_RULE="-a always,exit -F arch=$ARCH -S lremovexattr -F auid>=1000 -F auid!=unset -F key=perm_mod"

		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Unsuccessful Access Attempts to Files - truncate
CCE-80389-0(){
	function create_audit_remediation_unsuccessful_file_modification_detailed {
		mkdir -p "$(dirname "$1")"
		# The - option to mark a here document limit string (<<-EOF) suppresses leading tabs (but not spaces) in the output.
		cat <<-EOF > "$1"
			## This content is a section of an Audit config snapshot recommended for linux systems that target OSPP compliance.
			## The following content has been retreived on 2019-03-11 from: https://github.com/linux-audit/audit-userspace/blob/master/rules/30-ospp-v42.rules

			## The purpose of these rules is to meet the requirements for Operating
			## System Protection Profile (OSPP)v4.2. These rules depends on having
			## 10-base-config.rules, 11-loginuid.rules, and 43-module-load.rules installed.

			## Unsuccessful file creation (open with O_CREAT)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create

			## Unsuccessful file modifications (open for write or truncate)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification

			## Unsuccessful file access (any other opens) This has to go last.
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
		EOF
	}
	create_audit_remediation_unsuccessful_file_modification_detailed /etc/audit/rules.d/30-ospp-v42-remediation.rules
	}

# Record Unsuccessful Access Attempts to Files - creat
CCE-80385-8(){
	function create_audit_remediation_unsuccessful_file_modification_detailed {
		mkdir -p "$(dirname "$1")"
		# The - option to mark a here document limit string (<<-EOF) suppresses leading tabs (but not spaces) in the output.
		cat <<-EOF > "$1"
			## This content is a section of an Audit config snapshot recommended for linux systems that target OSPP compliance.
			## The following content has been retreived on 2019-03-11 from: https://github.com/linux-audit/audit-userspace/blob/master/rules/30-ospp-v42.rules

			## The purpose of these rules is to meet the requirements for Operating
			## System Protection Profile (OSPP)v4.2. These rules depends on having
			## 10-base-config.rules, 11-loginuid.rules, and 43-module-load.rules installed.

			## Unsuccessful file creation (open with O_CREAT)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create

			## Unsuccessful file modifications (open for write or truncate)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification

			## Unsuccessful file access (any other opens) This has to go last.
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
		EOF
	}
	create_audit_remediation_unsuccessful_file_modification_detailed /etc/audit/rules.d/30-ospp-v42-remediation.rules
	}

# Record Unsuccessful Access Attempts to Files - open
CCE-80386-6(){
	function create_audit_remediation_unsuccessful_file_modification_detailed {
		mkdir -p "$(dirname "$1")"
		# The - option to mark a here document limit string (<<-EOF) suppresses leading tabs (but not spaces) in the output.
		cat <<-EOF > "$1"
			## This content is a section of an Audit config snapshot recommended for linux systems that target OSPP compliance.
			## The following content has been retreived on 2019-03-11 from: https://github.com/linux-audit/audit-userspace/blob/master/rules/30-ospp-v42.rules

			## The purpose of these rules is to meet the requirements for Operating
			## System Protection Profile (OSPP)v4.2. These rules depends on having
			## 10-base-config.rules, 11-loginuid.rules, and 43-module-load.rules installed.

			## Unsuccessful file creation (open with O_CREAT)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create

			## Unsuccessful file modifications (open for write or truncate)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification

			## Unsuccessful file access (any other opens) This has to go last.
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
		EOF
	}
	create_audit_remediation_unsuccessful_file_modification_detailed /etc/audit/rules.d/30-ospp-v42-remediation.rules
	}

# Record Unsuccessful Access Attempts to Files - open_by_handle_at
CCE-80388-2(){
	function create_audit_remediation_unsuccessful_file_modification_detailed {
		mkdir -p "$(dirname "$1")"
		# The - option to mark a here document limit string (<<-EOF) suppresses leading tabs (but not spaces) in the output.
		cat <<-EOF > "$1"
			## This content is a section of an Audit config snapshot recommended for linux systems that target OSPP compliance.
			## The following content has been retreived on 2019-03-11 from: https://github.com/linux-audit/audit-userspace/blob/master/rules/30-ospp-v42.rules

			## The purpose of these rules is to meet the requirements for Operating
			## System Protection Profile (OSPP)v4.2. These rules depends on having
			## 10-base-config.rules, 11-loginuid.rules, and 43-module-load.rules installed.

			## Unsuccessful file creation (open with O_CREAT)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create

			## Unsuccessful file modifications (open for write or truncate)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification

			## Unsuccessful file access (any other opens) This has to go last.
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
		EOF
	}
	create_audit_remediation_unsuccessful_file_modification_detailed /etc/audit/rules.d/30-ospp-v42-remediation.rules
	}

# Record Unsuccessful Access Attempts to Files - ftruncate
CCE-80390-8(){
	function create_audit_remediation_unsuccessful_file_modification_detailed {
		mkdir -p "$(dirname "$1")"
		# The - option to mark a here document limit string (<<-EOF) suppresses leading tabs (but not spaces) in the output.
		cat <<-EOF > "$1"
			## This content is a section of an Audit config snapshot recommended for linux systems that target OSPP compliance.
			## The following content has been retreived on 2019-03-11 from: https://github.com/linux-audit/audit-userspace/blob/master/rules/30-ospp-v42.rules

			## The purpose of these rules is to meet the requirements for Operating
			## System Protection Profile (OSPP)v4.2. These rules depends on having
			## 10-base-config.rules, 11-loginuid.rules, and 43-module-load.rules installed.

			## Unsuccessful file creation (open with O_CREAT)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create

			## Unsuccessful file modifications (open for write or truncate)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification

			## Unsuccessful file access (any other opens) This has to go last.
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
		EOF
	}
	create_audit_remediation_unsuccessful_file_modification_detailed /etc/audit/rules.d/30-ospp-v42-remediation.rules
	}

# Record Unsuccessful Access Attempts to Files - openat
CCE-80387-4(){
	function create_audit_remediation_unsuccessful_file_modification_detailed {
		mkdir -p "$(dirname "$1")"
		# The - option to mark a here document limit string (<<-EOF) suppresses leading tabs (but not spaces) in the output.
		cat <<-EOF > "$1"
			## This content is a section of an Audit config snapshot recommended for linux systems that target OSPP compliance.
			## The following content has been retreived on 2019-03-11 from: https://github.com/linux-audit/audit-userspace/blob/master/rules/30-ospp-v42.rules

			## The purpose of these rules is to meet the requirements for Operating
			## System Protection Profile (OSPP)v4.2. These rules depends on having
			## 10-base-config.rules, 11-loginuid.rules, and 43-module-load.rules installed.

			## Unsuccessful file creation (open with O_CREAT)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create
			-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-create

			## Unsuccessful file modifications (open for write or truncate)
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification
			-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-modification

			## Unsuccessful file access (any other opens) This has to go last.
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
			-a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-access
		EOF
	}
	create_audit_remediation_unsuccessful_file_modification_detailed /etc/audit/rules.d/30-ospp-v42-remediation.rules
	}

# Ensure auditd Collects File Deletion Events by User - rmdir
CCE-80412-0(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S rmdir.*"
		GROUP="delete"
		FULL_RULE="-a always,exit -F arch=$ARCH -S rmdir -F auid>=1000 -F auid!=unset -F key=delete"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Ensure auditd Collects File Deletion Events by User - unlinkat
CCE-80662-0(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S unlinkat.*"
		GROUP="delete"
		FULL_RULE="-a always,exit -F arch=$ARCH -S unlinkat -F auid>=1000 -F auid!=unset -F key=delete"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Ensure auditd Collects File Deletion Events by User - rename
CCE-80995-4(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S rename.*"
		GROUP="delete"
		FULL_RULE="-a always,exit -F arch=$ARCH -S rename -F auid>=1000 -F auid!=unset -F key=delete"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Ensure auditd Collects File Deletion Events by User - renameat
CCE-80413-8(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S renameat.*"
		GROUP="delete"
		FULL_RULE="-a always,exit -F arch=$ARCH -S renameat -F auid>=1000 -F auid!=unset -F key=delete"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Ensure auditd Collects File Deletion Events by User - unlink
CCE-80996-2(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S unlink.*"
		GROUP="delete"
		FULL_RULE="-a always,exit -F arch=$ARCH -S unlink -F auid>=1000 -F auid!=unset -F key=delete"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Ensure auditd Collects Information on the Use of Privileged Commands
CCE-27437-3(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to perform remediation for 'audit_rules_privileged_commands' rule
	#
	# Expects two arguments:
	#
	# audit_tool		tool used to load audit rules
	# 			One of 'auditctl' or 'augenrules'
	#
	# min_auid		Minimum original ID the user logged in with
	#
	# Example Call(s):
	#
	#      perform_audit_rules_privileged_commands_remediation "auditctl" "500"
	#      perform_audit_rules_privileged_commands_remediation "augenrules"	"1000"
	#
	function perform_audit_rules_privileged_commands_remediation {
	#
	# Load function arguments into local variables
	local tool="$1"
	local min_auid="$2"

	# Check sanity of the input
	if [ $# -ne "2" ]
	then
		echo "Usage: perform_audit_rules_privileged_commands_remediation 'auditctl | augenrules' '500 | 1000'"
		echo "Aborting."
		exit 1
	fi

	declare -a files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then:
	# * add '/etc/audit/audit.rules'to the list of files to be inspected,
	# * specify '/etc/audit/audit.rules' as the output audit file, where
	#   missing rules should be inserted
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect=("/etc/audit/audit.rules")
		output_audit_file="/etc/audit/audit.rules"
	#
	# If the audit tool is 'augenrules', then:
	# * add '/etc/audit/rules.d/*.rules' to the list of files to be inspected
	#   (split by newline),
	# * specify /etc/audit/rules.d/privileged.rules' as the output file, where
	#   missing rules should be inserted
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t files_to_inspect < <(find /etc/audit/rules.d -maxdepth 1 -type f -name '*.rules' -print)
		output_audit_file="/etc/audit/rules.d/privileged.rules"
	fi

	# Obtain the list of SUID/SGID binaries on the particular system (split by newline)
	# into privileged_binaries array
	privileged_binaries=()
	readarray -t privileged_binaries < <(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null)

	# Keep list of SUID/SGID binaries that have been already handled within some previous iteration
	declare -a sbinaries_to_skip=()

	# For each found sbinary in privileged_binaries list
	for sbinary in "${privileged_binaries[@]}"
	do

		# Check if this sbinary wasn't already handled in some of the previous sbinary iterations
		# Return match only if whole sbinary definition matched (not in the case just prefix matched!!!)
		if [[ $(sed -ne "\|${sbinary}|p" <<< "${sbinaries_to_skip[*]}") ]]
		then
			# If so, don't process it second time & go to process next sbinary
			continue
		fi

		# Reset the counter of inspected files when starting to check
		# presence of existing audit rule for new sbinary
		local count_of_inspected_files=0

		# Define expected rule form for this binary
		expected_rule="-a always,exit -F path=${sbinary} -F perm=x -F auid>=${min_auid} -F auid!=unset -k privileged"

		# If list of audit rules files to be inspected is empty, just add new rule and move on to next binary
		if [[ ${#files_to_inspect[@]} -eq 0 ]]; then
			echo "$expected_rule" >> "$output_audit_file"
			continue
		fi

		# Replace possible slash '/' character in sbinary definition so we could use it in sed expressions below
		sbinary_esc=${sbinary//$'/'/$'\/'}

		# For each audit rules file from the list of files to be inspected
		for afile in "${files_to_inspect[@]}"
		do

			# Search current audit rules file's content for match. Match criteria:
			# * existing rule is for the same SUID/SGID binary we are currently processing (but
			#   can contain multiple -F path= elements covering multiple SUID/SGID binaries)
			# * existing rule contains all arguments from expected rule form (though can contain
			#   them in arbitrary order)
		
			base_search=$(sed -e '/-a always,exit/!d' -e '/-F path='"${sbinary_esc}"'[^[:graph:]]/!d'		\
					-e '/-F path=[^[:space:]]\+/!d'   -e '/-F perm=.*/!d'						\
					-e '/-F auid>='"${min_auid}"'/!d' -e '/-F auid!=\(4294967295\|unset\)/!d'	\
					-e '/-k \|-F key=/!d' "$afile")

			# Increase the count of inspected files for this sbinary
			count_of_inspected_files=$((count_of_inspected_files + 1))

			# Require execute access type to be set for existing audit rule
			exec_access='x'

			# Search current audit rules file's content for presence of rule pattern for this sbinary
			if [[ $base_search ]]
			then

				# Current audit rules file already contains rule for this binary =>
				# Store the exact form of found rule for this binary for further processing
				concrete_rule=$base_search

				# Select all other SUID/SGID binaries possibly also present in the found rule

				readarray -t handled_sbinaries < <(grep -o -e "-F path=[^[:space:]]\+" <<< "$concrete_rule")
				handled_sbinaries=("${handled_sbinaries[@]//-F path=/}")

				# Merge the list of such SUID/SGID binaries found in this iteration with global list ignoring duplicates
				readarray -t sbinaries_to_skip < <(for i in "${sbinaries_to_skip[@]}" "${handled_sbinaries[@]}"; do echo "$i"; done | sort -du)

				# Separate concrete_rule into three sections using hash '#'
				# sign as a delimiter around rule's permission section borders
				concrete_rule="$(echo "$concrete_rule" | sed -n "s/\(.*\)\+\(-F perm=[rwax]\+\)\+/\1#\2#/p")"

				# Split concrete_rule into head, perm, and tail sections using hash '#' delimiter

				rule_head=$(cut -d '#' -f 1 <<< "$concrete_rule")
				rule_perm=$(cut -d '#' -f 2 <<< "$concrete_rule")
				rule_tail=$(cut -d '#' -f 3 <<< "$concrete_rule")

				# Extract already present exact access type [r|w|x|a] from rule's permission section
				access_type=${rule_perm//-F perm=/}

				# Verify current permission access type(s) for rule contain 'x' (execute) permission
				if ! grep -q "$exec_access" <<< "$access_type"
				then

					# If not, append the 'x' (execute) permission to the existing access type bits
					access_type="$access_type$exec_access"
					# Reconstruct the permissions section for the rule
					new_rule_perm="-F perm=$access_type"
					# Update existing rule in current audit rules file with the new permission section
					sed -i "s#${rule_head}\(.*\)${rule_tail}#${rule_head}${new_rule_perm}${rule_tail}#" "$afile"

				fi

			# If the required audit rule for particular sbinary wasn't found yet, insert it under following conditions:
			#
			# * in the "auditctl" mode of operation insert particular rule each time
			#   (because in this mode there's only one file -- /etc/audit/audit.rules to be inspected for presence of this rule),
			#
			# * in the "augenrules" mode of operation insert particular rule only once and only in case we have already
			#   searched all of the files from /etc/audit/rules.d/*.rules location (since that audit rule can be defined
			#   in any of those files and if not, we want it to be inserted only once into /etc/audit/rules.d/privileged.rules file)
			#
			elif [ "$tool" == "auditctl" ] || [[ "$tool" == "augenrules" && $count_of_inspected_files -eq "${#files_to_inspect[@]}" ]]
			then

				# Check if this sbinary wasn't already handled in some of the previous afile iterations
				# Return match only if whole sbinary definition matched (not in the case just prefix matched!!!)
				if [[ ! $(sed -ne "\|${sbinary}|p" <<< "${sbinaries_to_skip[*]}") ]]
				then
					# Current audit rules file's content doesn't contain expected rule for this
					# SUID/SGID binary yet => append it
					echo "$expected_rule" >> "$output_audit_file"
				fi

				continue
			fi

		done

	done
	}
	perform_audit_rules_privileged_commands_remediation "auditctl" "1000"
	perform_audit_rules_privileged_commands_remediation "augenrules" "1000"
	}

# Ensure auditd Collects System Administrator Actions
CCE-27461-3(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/sudoers" "wa" "actions"
	fix_audit_watch_rule "augenrules" "/etc/sudoers" "wa" "actions"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/sudoers.d/" "wa" "actions"
	fix_audit_watch_rule "augenrules" "/etc/sudoers.d/" "wa" "actions"
	}

# Record Events that Modify the System's Network Environment
CCE-27076-9(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S .* -k *"
		# Use escaped BRE regex to specify rule group
		GROUP="set\(host\|domain\)name"
		FULL_RULE="-a always,exit -F arch=$ARCH -S sethostname -S setdomainname -k audit_rules_networkconfig_modification"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done

	# Then perform the remediations for the watch rules
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/issue" "wa" "audit_rules_networkconfig_modification"
	fix_audit_watch_rule "augenrules" "/etc/issue" "wa" "audit_rules_networkconfig_modification"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/issue.net" "wa" "audit_rules_networkconfig_modification"
	fix_audit_watch_rule "augenrules" "/etc/issue.net" "wa" "audit_rules_networkconfig_modification"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/hosts" "wa" "audit_rules_networkconfig_modification"
	fix_audit_watch_rule "augenrules" "/etc/hosts" "wa" "audit_rules_networkconfig_modification"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/sysconfig/network" "wa" "audit_rules_networkconfig_modification"
	fix_audit_watch_rule "augenrules" "/etc/sysconfig/network" "wa" "audit_rules_networkconfig_modification"
	}

# Make the auditd Configuration Immutable
CCE-27097-5(){
	# Traverse all of:
	#
	# /etc/audit/audit.rules,			(for auditctl case)
	# /etc/audit/rules.d/*.rules			(for augenrules case)
	#
	# files to check if '-e .*' setting is present in that '*.rules' file already.
	# If found, delete such occurrence since auditctl(8) manual page instructs the
	# '-e 2' rule should be placed as the last rule in the configuration
	find /etc/audit /etc/audit/rules.d -maxdepth 1 -type f -name '*.rules' -exec sed -i '/-e[[:space:]]\+.*/d' {} ';'

	# Append '-e 2' requirement at the end of both:
	# * /etc/audit/audit.rules file 		(for auditctl case)
	# * /etc/audit/rules.d/immutable.rules		(for augenrules case)

	for AUDIT_FILE in "/etc/audit/audit.rules" "/etc/audit/rules.d/immutable.rules"
	do
		echo '' >> $AUDIT_FILE
		echo '# Set the audit.rules configuration immutable per security requirements' >> $AUDIT_FILE
		echo '# Reboot is required to change audit rules once this setting is applied' >> $AUDIT_FILE
		echo '-e 2' >> $AUDIT_FILE
	done
	}

# Record Events that Modify User/Group Information - /etc/shadow
CCE-80431-0(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/shadow" "wa" "audit_rules_usergroup_modification"
	fix_audit_watch_rule "augenrules" "/etc/shadow" "wa" "audit_rules_usergroup_modification"
	}

# Record Attempts to Alter Process and Session Initiation Information
CCE-27301-1(){
	# Perform the remediation
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/run/utmp" "wa" "session"
	fix_audit_watch_rule "augenrules" "/var/run/utmp" "wa" "session"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/log/btmp" "wa" "session"
	fix_audit_watch_rule "augenrules" "/var/log/btmp" "wa" "session"
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/log/wtmp" "wa" "session"
	fix_audit_watch_rule "augenrules" "/var/log/wtmp" "wa" "session"
	}

# Ensure auditd Collects Information on Exporting to Media (successful)
CCE-27447-2(){
	# Perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S .* -F auid>=1000 -F auid!=unset -k *"
		GROUP="mount"
		FULL_RULE="-a always,exit -F arch=$ARCH -S mount -F auid>=1000 -F auid!=unset -k export"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Events that Modify User/Group Information - /etc/security/opasswd
CCE-80430-2(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/security/opasswd" "wa" "audit_rules_usergroup_modification"
	fix_audit_watch_rule "augenrules" "/etc/security/opasswd" "wa" "audit_rules_usergroup_modification"
	}

# Record Events that Modify the System's Mandatory Access Controls
CCE-27168-4(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/selinux/" "wa" "MAC-policy"
	fix_audit_watch_rule "augenrules" "/etc/selinux/" "wa" "MAC-policy"
	}

# Record Events that Modify User/Group Information - /etc/gshadow
CCE-80432-8(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/gshadow" "wa" "audit_rules_usergroup_modification"
	fix_audit_watch_rule "augenrules" "/etc/gshadow" "wa" "audit_rules_usergroup_modification"
	}

# Record Events that Modify User/Group Information - /etc/passwd
CCE-80435-1(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/passwd" "wa" "audit_rules_usergroup_modification"
	fix_audit_watch_rule "augenrules" "/etc/passwd" "wa" "audit_rules_usergroup_modification"
	}

# Record Events that Modify User/Group Information - /etc/group
CCE-80433-6(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/etc/group" "wa" "audit_rules_usergroup_modification"
	fix_audit_watch_rule "augenrules" "/etc/group" "wa" "audit_rules_usergroup_modification"
	}

# Enable auditd Service
CCE-27407-6(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" start 'auditd.service'
	"$SYSTEMCTL_EXEC" enable 'auditd.service'
	}

# Enable Auditing for Processes Which Start Prior to the Audit Daemon
CCE-27212-0(){
	# Correct the form of default kernel command line in GRUB
	if grep -q '^GRUB_CMDLINE_LINUX=.*audit=.*"'  '/etc/default/grub' ; then
		# modify the GRUB command-line if an audit= arg already exists
		sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)audit=[^[:space:]]*\(.*"\)/\1 audit=1 \2/'  '/etc/default/grub'
	else
		# no audit=arg is present, append it
		sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 audit=1"/'  '/etc/default/grub'
	fi

	# Correct the form of kernel command line for each installed kernel in the bootloader
	grubby --update-kernel=ALL --args="audit=1"
	}

# Ensure Logs Sent To Remote Host
# To configure rsyslog to send logs to a remote log server, open /etc/rsyslog.conf and read and understand the last section of the file, which describes the multiple directives necessary to activate remote logging.
# Along with these other directives, the system can be configured to forward its logs to a particular log server by adding or correcting one of the following lines, substituting logcollector appropriately.
# The choice of protocol depends on the environment of the system; although TCP and RELP provide more reliable message delivery, they may not be supported in all environments.
# To use UDP for log message delivery:
#	*.* @logcollector
# To use TCP for log message delivery:
#	*.* @@logcollector
CCE-27343-3(){
	rsyslog_remote_loghost_address="logcollector"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/rsyslog.conf' '^\*\.\*' "@@$rsyslog_remote_loghost_address" 'CCE-27343-3' '%s %s'
	}

# Ensure Logrotate Runs Periodically
CCE-80195-1(){
	LOGROTATE_CONF_FILE="/etc/logrotate.conf"
	CRON_DAILY_LOGROTATE_FILE="/etc/cron.daily/logrotate"

	# daily rotation is configured
	grep -q "^daily$" $LOGROTATE_CONF_FILE|| echo "daily" >> $LOGROTATE_CONF_FILE

	# remove any line configuring weekly, monthly or yearly rotation
	sed -i -r "/^(weekly|monthly|yearly)$/d" $LOGROTATE_CONF_FILE

	# configure cron.daily if not already
	if ! grep -q "^[[:space:]]*/usr/sbin/logrotate[[:alnum:][:blank:][:punct:]]*$LOGROTATE_CONF_FILE$" $CRON_DAILY_LOGROTATE_FILE; then
		echo "#!/bin/sh" > $CRON_DAILY_LOGROTATE_FILE
		echo "/usr/sbin/logrotate $LOGROTATE_CONF_FILE" >> $CRON_DAILY_LOGROTATE_FILE
	fi
	}

# Ensure System Log Files Have Correct Permissions
CCE-80191-0(){
	# List of log file paths to be inspected for correct permissions
	# * Primarily inspect log file paths listed in /etc/rsyslog.conf
	RSYSLOG_ETC_CONFIG="/etc/rsyslog.conf"
	# * And also the log file paths listed after rsyslog's $IncludeConfig directive
	#   (store the result into array for the case there's shell glob used as value of IncludeConfig)
	readarray -t RSYSLOG_INCLUDE_CONFIG < <(grep -e "\$IncludeConfig[[:space:]]\+[^[:space:];]\+" /etc/rsyslog.conf | cut -d ' ' -f 2)
	# Declare an array to hold the final list of different log file paths
	declare -a LOG_FILE_PATHS

	# Browse each file selected above as containing paths of log files
	# ('/etc/rsyslog.conf' and '/etc/rsyslog.d/*.conf' in the default configuration)
	for LOG_FILE in "${RSYSLOG_ETC_CONFIG}" "${RSYSLOG_INCLUDE_CONFIG[@]}"
	do
		# From each of these files extract just particular log file path(s), thus:
		# * Ignore lines starting with space (' '), comment ('#"), or variable syntax ('$') characters,
		# * Ignore empty lines,
		# * Strip quotes and closing brackets from paths.
		# * Ignore paths that match /dev|/etc.*\.conf, as those are paths, but likely not log files
		# * From the remaining valid rows select only fields constituting a log file path
		# Text file column is understood to represent a log file path if and only if all of the following are met:
		# * it contains at least one slash '/' character,
		# * it is preceded by space
		# * it doesn't contain space (' '), colon (':'), and semicolon (';') characters
		# Search log file for path(s) only in case it exists!
		if [[ -f "${LOG_FILE}" ]]
		then
			NORMALIZED_CONFIG_FILE_LINES=$(sed -e "/^[[:space:]|#|$]/d" "${LOG_FILE}")
			LINES_WITH_PATHS=$(grep '[^/]*\s\+\S*/\S\+' <<< "${NORMALIZED_CONFIG_FILE_LINES}")
			FILTERED_PATHS=$(sed -e 's/[^\/]*[[:space:]]*\([^:;[:space:]]*\)/\1/g' <<< "${LINES_WITH_PATHS}")
			CLEANED_PATHS=$(sed -e "s/[\"')]//g; /\\/etc.*\.conf/d; /\\/dev\\//d" <<< "${FILTERED_PATHS}")
			MATCHED_ITEMS=$(sed -e "/^$/d" <<< "${CLEANED_PATHS}")
			# Since above sed command might return more than one item (delimited by newline), split the particular
			# matches entries into new array specific for this log file
			readarray -t ARRAY_FOR_LOG_FILE <<< "$MATCHED_ITEMS"
			# Concatenate the two arrays - previous content of $LOG_FILE_PATHS array with
			# items from newly created array for this log file
			LOG_FILE_PATHS+=("${ARRAY_FOR_LOG_FILE[@]}")
			# Delete the temporary array
			unset ARRAY_FOR_LOG_FILE
		fi
	done

	for LOG_FILE_PATH in "${LOG_FILE_PATHS[@]}"
	do
		# Sanity check - if particular $LOG_FILE_PATH is empty string, skip it from further processing
		if [ -z "$LOG_FILE_PATH" ]
		then
			continue
		fi

		

		# Also for each log file check if its permissions differ from 600. If so, correct them
		if [ -f "$LOG_FILE_PATH" ] && [ "$(/usr/bin/stat -c %a "$LOG_FILE_PATH")" -ne 600 ]
		then
			/bin/chmod 600 "$LOG_FILE_PATH"
		fi
	done
	}

# Ensure rsyslog is Installed
CCE-80187-8(){
	if ! rpm -q --quiet "rsyslog" ; then
	    yum install -y "rsyslog"
	fi
	}

# Enable rsyslog Service
CCE-80188-6(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" start 'rsyslog.service'
	"$SYSTEMCTL_EXEC" enable 'rsyslog.service'
	}

# Disable IPv6 Networking Support Automatic Loading
CCE-80175-3(){
	# Set runtime for net.ipv6.conf.all.disable_ipv6
	#
	/sbin/sysctl -q -n -w net.ipv6.conf.all.disable_ipv6="1"

	#
	# If net.ipv6.conf.all.disable_ipv6 present in /etc/sysctl.conf, change value to "1"
	#	else, add "net.ipv6.conf.all.disable_ipv6 = 1" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv6.conf.all.disable_ipv6' "1" 'CCE-80175-3'
	}

# Disable Accepting ICMP Redirects for All IPv6 Interfaces
CCE-80182-9(){
	sysctl_net_ipv6_conf_all_accept_redirects_value="0"

	#
	# Set runtime for net.ipv6.conf.all.accept_redirects
	#
	/sbin/sysctl -q -n -w net.ipv6.conf.all.accept_redirects="$sysctl_net_ipv6_conf_all_accept_redirects_value"

	#
	# If net.ipv6.conf.all.accept_redirects present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv6.conf.all.accept_redirects = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv6.conf.all.accept_redirects' "$sysctl_net_ipv6_conf_all_accept_redirects_value" 'CCE-80182-9'
	}

# Disable Accepting Router Advertisements on all IPv6 Interfaces by Default
CCE-80181-1(){
	sysctl_net_ipv6_conf_default_accept_ra_value="0"

	#
	# Set runtime for net.ipv6.conf.default.accept_ra
	#
	/sbin/sysctl -q -n -w net.ipv6.conf.default.accept_ra="$sysctl_net_ipv6_conf_default_accept_ra_value"

	#
	# If net.ipv6.conf.default.accept_ra present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv6.conf.default.accept_ra = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv6.conf.default.accept_ra' "$sysctl_net_ipv6_conf_default_accept_ra_value" 'CCE-80181-1'
	}

# Configure Accepting Router Advertisements on All IPv6 Interfaces
CCE-80180-3(){
	sysctl_net_ipv6_conf_all_accept_ra_value="0"

	#
	# Set runtime for net.ipv6.conf.all.accept_ra
	#
	/sbin/sysctl -q -n -w net.ipv6.conf.all.accept_ra="$sysctl_net_ipv6_conf_all_accept_ra_value"

	#
	# If net.ipv6.conf.all.accept_ra present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv6.conf.all.accept_ra = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv6.conf.all.accept_ra' "$sysctl_net_ipv6_conf_all_accept_ra_value" 'CCE-80180-3'
	}

# Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv6 Interfaces
CCE-80183-7(){
	sysctl_net_ipv6_conf_default_accept_redirects_value="0"

	#
	# Set runtime for net.ipv6.conf.default.accept_redirects
	#
	/sbin/sysctl -q -n -w net.ipv6.conf.default.accept_redirects="$sysctl_net_ipv6_conf_default_accept_redirects_value"

	#
	# If net.ipv6.conf.default.accept_redirects present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv6.conf.default.accept_redirects = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv6.conf.default.accept_redirects' "$sysctl_net_ipv6_conf_default_accept_redirects_value" 'CCE-80183-7'
	}

# Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default 
CCE-80162-1(){
	sysctl_net_ipv4_conf_default_accept_source_route_value="0"

	#
	# Set runtime for net.ipv4.conf.default.accept_source_route
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.default.accept_source_route="$sysctl_net_ipv4_conf_default_accept_source_route_value"

	#
	# If net.ipv4.conf.default.accept_source_route present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.default.accept_source_route = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.default.accept_source_route' "$sysctl_net_ipv4_conf_default_accept_source_route_value" 'CCE-80162-1'
	}

# Enable Kernel Parameter to Ignore Bogus ICMP Error Responses on IPv4 Interfaces
CCE-80166-2(){
	sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value="1"

	#
	# Set runtime for net.ipv4.icmp_ignore_bogus_error_responses
	#
	/sbin/sysctl -q -n -w net.ipv4.icmp_ignore_bogus_error_responses="$sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value"

	#
	# If net.ipv4.icmp_ignore_bogus_error_responses present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.icmp_ignore_bogus_error_responses = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.icmp_ignore_bogus_error_responses' "$sysctl_net_ipv4_icmp_ignore_bogus_error_responses_value" 'CCE-80166-2'
	}

# Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests on IPv4 Interfaces
CCE-80165-4(){
	sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value="1"

	#
	# Set runtime for net.ipv4.icmp_echo_ignore_broadcasts
	#
	/sbin/sysctl -q -n -w net.ipv4.icmp_echo_ignore_broadcasts="$sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value"

	#
	# If net.ipv4.icmp_echo_ignore_broadcasts present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.icmp_echo_ignore_broadcasts = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.icmp_echo_ignore_broadcasts' "$sysctl_net_ipv4_icmp_echo_ignore_broadcasts_value" 'CCE-80165-4'
	}

# Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces
CCE-80163-9(){
	sysctl_net_ipv4_conf_default_accept_redirects_value="0"

	#
	# Set runtime for net.ipv4.conf.default.accept_redirects
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.default.accept_redirects="$sysctl_net_ipv4_conf_default_accept_redirects_value"

	#
	# If net.ipv4.conf.default.accept_redirects present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.default.accept_redirects = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.default.accept_redirects' "$sysctl_net_ipv4_conf_default_accept_redirects_value" 'CCE-80163-9'
	}

# Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces by Default 
CCE-80168-8(){
	sysctl_net_ipv4_conf_default_rp_filter_value="1"

	#
	# Set runtime for net.ipv4.conf.default.rp_filter
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.default.rp_filter="$sysctl_net_ipv4_conf_default_rp_filter_value"

	#
	# If net.ipv4.conf.default.rp_filter present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.default.rp_filter = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.default.rp_filter' "$sysctl_net_ipv4_conf_default_rp_filter_value" 'CCE-80168-8'
	}

# Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces
CCE-80159-7(){
	sysctl_net_ipv4_conf_all_secure_redirects_value="0"

	#
	# Set runtime for net.ipv4.conf.all.secure_redirects
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.all.secure_redirects="$sysctl_net_ipv4_conf_all_secure_redirects_value"

	#
	# If net.ipv4.conf.all.secure_redirects present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.all.secure_redirects = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.all.secure_redirects' "$sysctl_net_ipv4_conf_all_secure_redirects_value" 'CCE-80159-7'
	}

# Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces
CCE-27434-0(){
	sysctl_net_ipv4_conf_all_accept_source_route_value="0"

	#
	# Set runtime for net.ipv4.conf.all.accept_source_route
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.all.accept_source_route="$sysctl_net_ipv4_conf_all_accept_source_route_value"

	#
	# If net.ipv4.conf.all.accept_source_route present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.all.accept_source_route = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.all.accept_source_route' "$sysctl_net_ipv4_conf_all_accept_source_route_value" 'CCE-27434-0'
	}

# Disable Accepting ICMP Redirects for All IPv4 Interfaces
CCE-80158-9(){
	sysctl_net_ipv4_conf_all_accept_redirects_value="0"

	#
	# Set runtime for net.ipv4.conf.all.accept_redirects
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.all.accept_redirects="$sysctl_net_ipv4_conf_all_accept_redirects_value"

	#
	# If net.ipv4.conf.all.accept_redirects present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.all.accept_redirects = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.all.accept_redirects' "$sysctl_net_ipv4_conf_all_accept_redirects_value" 'CCE-80158-9'
	}

# Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces
CCE-80160-5(){
	sysctl_net_ipv4_conf_all_log_martians_value="1"

	#
	# Set runtime for net.ipv4.conf.all.log_martians
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.all.log_martians="$sysctl_net_ipv4_conf_all_log_martians_value"

	#
	# If net.ipv4.conf.all.log_martians present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.all.log_martians = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.all.log_martians' "$sysctl_net_ipv4_conf_all_log_martians_value" 'CCE-80160-5'
	}

# Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces
CCE-80167-0(){
	sysctl_net_ipv4_conf_all_rp_filter_value="1"

	#
	# Set runtime for net.ipv4.conf.all.rp_filter
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.all.rp_filter="$sysctl_net_ipv4_conf_all_rp_filter_value"

	#
	# If net.ipv4.conf.all.rp_filter present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.all.rp_filter = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.all.rp_filter' "$sysctl_net_ipv4_conf_all_rp_filter_value" 'CCE-80167-0'
	}

# Configure Kernel Parameter for Accepting Secure Redirects By Default
CCE-80164-7(){
	sysctl_net_ipv4_conf_default_secure_redirects_value="0"

	#
	# Set runtime for net.ipv4.conf.default.secure_redirects
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.default.secure_redirects="$sysctl_net_ipv4_conf_default_secure_redirects_value"

	#
	# If net.ipv4.conf.default.secure_redirects present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.default.secure_redirects = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.default.secure_redirects' "$sysctl_net_ipv4_conf_default_secure_redirects_value" 'CCE-80164-7'
	}

# Enable Kernel Parameter to Use TCP Syncookies on IPv4 Interfaces
CCE-27495-1(){
	sysctl_net_ipv4_tcp_syncookies_value="1"

	#
	# Set runtime for net.ipv4.tcp_syncookies
	#
	/sbin/sysctl -q -n -w net.ipv4.tcp_syncookies="$sysctl_net_ipv4_tcp_syncookies_value"

	#
	# If net.ipv4.tcp_syncookies present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.tcp_syncookies = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.tcp_syncookies' "$sysctl_net_ipv4_tcp_syncookies_value" 'CCE-27495-1'
	}

# Enable Kernel Paremeter to Log Martian Packets on all IPv4 Interfaces by Default
CCE-80161-3(){
	sysctl_net_ipv4_conf_default_log_martians_value="1"

	#
	# Set runtime for net.ipv4.conf.default.log_martians
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.default.log_martians="$sysctl_net_ipv4_conf_default_log_martians_value"

	#
	# If net.ipv4.conf.default.log_martians present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv4.conf.default.log_martians = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.default.log_martians' "$sysctl_net_ipv4_conf_default_log_martians_value" 'CCE-80161-3'
	}

# Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces
CCE-80156-3(){
	# Set runtime for net.ipv4.conf.all.send_redirects
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.all.send_redirects="0"

	#
	# If net.ipv4.conf.all.send_redirects present in /etc/sysctl.conf, change value to "0"
	#	else, add "net.ipv4.conf.all.send_redirects = 0" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.all.send_redirects' "0" 'CCE-80156-3'
	}

# Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces by Default
CCE-80999-6(){
	# Set runtime for net.ipv4.conf.default.send_redirects
	#
	/sbin/sysctl -q -n -w net.ipv4.conf.default.send_redirects="0"

	#
	# If net.ipv4.conf.default.send_redirects present in /etc/sysctl.conf, change value to "0"
	#	else, add "net.ipv4.conf.default.send_redirects = 0" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv4.conf.default.send_redirects' "0" 'CCE-80999-6'
	}

# Disable DCCP Support
CCE-82024-1(){
	if LC_ALL=C grep -q -m 1 "^install dccp" /etc/modprobe.d/dccp.conf ; then
		sed -i 's/^install dccp.*/install dccp /bin/true/g' /etc/modprobe.d/dccp.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/dccp.conf
		echo "install dccp /bin/true" >> /etc/modprobe.d/dccp.conf
	fi
	}

# Disable SCTP Support
CCE-82044-9(){
	if LC_ALL=C grep -q -m 1 "^install sctp" /etc/modprobe.d/sctp.conf ; then
		sed -i 's/^install sctp.*/install sctp /bin/true/g' /etc/modprobe.d/sctp.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/sctp.conf
		echo "install sctp /bin/true" >> /etc/modprobe.d/sctp.conf
	fi
	}

# Verify /boot/grub2/grub.cfg User Ownership
CCE-82026-6(){
	chown 0 /boot/grub2/grub.cfg
	}

# Verify /boot/grub2/grub.cfg Permissions
CCE-82039-9(){
	chmod 0600 /boot/grub2/grub.cfg
	}

# Verify /boot/grub2/grub.cfg Group Ownership
CCE-82023-3(){
	chgrp 0 /boot/grub2/grub.cfg
	}

# Uninstall setroubleshoot Package
CCE-80444-3(){
	# CAUTION: This remediation script will remove setroubleshoot
	#	   from the system, and may remove any packages
	#	   that depend on setroubleshoot. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "setroubleshoot" ; then
	    yum remove -y "setroubleshoot"
	fi
	}

# Ensure SELinux Not Disabled in /etc/default/grub 
CCE-26961-3(){
	sed -i --follow-symlinks "s/selinux=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
	sed -i --follow-symlinks "s/enforcing=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
	}

# Configure SELinux Policy
CCE-27279-9(){
	var_selinux_policy_name="targeted"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysconfig/selinux' '^SELINUXTYPE=' $var_selinux_policy_name 'CCE-27279-9' '%s=%s'
	}

# Ensure SELinux State is Enforcing
CCE-27334-2(){
	var_selinux_state="enforcing"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state 'CCE-27334-2' '%s=%s'

	fixfiles onboot
	fixfiles -f relabel
	}

# Verify User Who Owns group File
# Verify Permissions on group File
# Verify Group Who Owns shadow File
# Verify Permissions on shadow File
# Verify Group Who Owns gshadow File
# Verify User Who Owns passwd File
# Verify User Who Owns gshadow File
# Verify Group Who Owns group File
# Verify Permissions on passwd File
# Verify User Who Owns shadow File 
# Verify Permissions on gshadow File
# Verify Group Who Owns passwd File
CCE-82031-6_CCE-82032-4_CCE-82051-4_CCE-82042-3_CCE-82025-8_CCE-82052-2_CCE-82195-9_CCE-82037-3_CCE-82029-0_CCE-82022-5_CCE-82192-6_CCE-26639-5(){
	chown 0 /etc/group
	chmod 0644 /etc/group
	chgrp 0 /etc/shadow
	chmod 0000 /etc/shadow
	chgrp 0 /etc/gshadow
	chown 0 /etc/passwd
	chown 0 /etc/gshadow
	chgrp 0 /etc/group
	chmod 0644 /etc/passwd
	chown 0 /etc/shadow
	chmod 0000 /etc/gshadow
	chgrp 0 /etc/passwd
	}

# Verify that All World-Writable Directories Have Sticky Bits Set
CCE-80130-8(){
	df --local -P | awk '{if (NR!=1) print $6}' \
	| xargs -I '{}' find '{}' -xdev -type d \
	\( -perm -0002 -a ! -perm -1000 \) 2>/dev/null \
	| xargs chmod a+t
	}

# Disable the Automounter
CCE-27498-5(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'autofs.service'
	"$SYSTEMCTL_EXEC" disable 'autofs.service'
	"$SYSTEMCTL_EXEC" mask 'autofs.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^autofs.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'autofs.socket'
	    "$SYSTEMCTL_EXEC" disable 'autofs.socket'
	    "$SYSTEMCTL_EXEC" mask 'autofs.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'autofs.service' || true
	}

# Disable Mounting of freevxfs
CCE-80138-1(){
	if LC_ALL=C grep -q -m 1 "^install freevxfs" /etc/modprobe.d/freevxfs.conf ; then
		sed -i 's/^install freevxfs.*/install freevxfs /bin/true/g' /etc/modprobe.d/freevxfs.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/freevxfs.conf
		echo "install freevxfs /bin/true" >> /etc/modprobe.d/freevxfs.conf
	fi
	}

# Disable Mounting of cramfs
CCE-80137-3(){
	if LC_ALL=C grep -q -m 1 "^install cramfs" /etc/modprobe.d/cramfs.conf ; then
		sed -i 's/^install cramfs.*/install cramfs /bin/true/g' /etc/modprobe.d/cramfs.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/cramfs.conf
		echo "install cramfs /bin/true" >> /etc/modprobe.d/cramfs.conf
	fi
	}

# Disable Mounting of squashfs
CCE-80142-3(){
	if LC_ALL=C grep -q -m 1 "^install squashfs" /etc/modprobe.d/squashfs.conf ; then
		sed -i 's/^install squashfs.*/install squashfs /bin/true/g' /etc/modprobe.d/squashfs.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/squashfs.conf
		echo "install squashfs /bin/true" >> /etc/modprobe.d/squashfs.conf
	fi
	}

# Disable Mounting of jffs2
CCE-80139-9(){
	if LC_ALL=C grep -q -m 1 "^install jffs2" /etc/modprobe.d/jffs2.conf ; then
		sed -i 's/^install jffs2.*/install jffs2 /bin/true/g' /etc/modprobe.d/jffs2.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/jffs2.conf
		echo "install jffs2 /bin/true" >> /etc/modprobe.d/jffs2.conf
	fi
	}

# Disable Mounting of hfsplus 
CCE-80141-5(){
	if LC_ALL=C grep -q -m 1 "^install hfsplus" /etc/modprobe.d/hfsplus.conf ; then
		sed -i 's/^install hfsplus.*/install hfsplus /bin/true/g' /etc/modprobe.d/hfsplus.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/hfsplus.conf
		echo "install hfsplus /bin/true" >> /etc/modprobe.d/hfsplus.conf
	fi
	}

# Disable Mounting of hfs
CCE-80140-7(){
	if LC_ALL=C grep -q -m 1 "^install hfs" /etc/modprobe.d/hfs.conf ; then
		sed -i 's/^install hfs.*/install hfs /bin/true/g' /etc/modprobe.d/hfs.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/hfs.conf
		echo "install hfs /bin/true" >> /etc/modprobe.d/hfs.conf
	fi
	}

# Disable Mounting of udf 
CCE-80143-1(){
	if LC_ALL=C grep -q -m 1 "^install udf" /etc/modprobe.d/udf.conf ; then
		sed -i 's/^install udf.*/install udf /bin/true/g' /etc/modprobe.d/udf.conf
	else
		echo -e "\n# Disable per security requirements" >> /etc/modprobe.d/udf.conf
		echo "install udf /bin/true" >> /etc/modprobe.d/udf.conf
	fi
	}

# Add noexec Option to /dev/shm
CCE-80153-0(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "no" = 'yes'; then
			assert_mount_point_in_fstab /dev/shm || { echo "Not remediating, because there is no record of /dev/shm in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/dev/shm" "noexec" "tmpfs" "tmpfs"

		ensure_partition_is_mounted "/dev/shm"
	}

	perform_remediation
	}

# Add nodev Option to /tmp
CCE-80149-8(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "yes" = 'yes'; then
			assert_mount_point_in_fstab /tmp || { echo "Not remediating, because there is no record of /tmp in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/tmp" "nodev" "" ""

		ensure_partition_is_mounted "/tmp"
	}

	perform_remediation
	}

# Add nosuid Option to /tmp
CCE-80151-4(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "yes" = 'yes'; then
			assert_mount_point_in_fstab /tmp || { echo "Not remediating, because there is no record of /tmp in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/tmp" "nosuid" "" ""

		ensure_partition_is_mounted "/tmp"
	}

	perform_remediation
	}

# Add nodev Option to Removable Media Partitions
CCE-80146-4(){
	var_removable_partition="(N/A)"

	device_regex="^\s*$var_removable_partition\s\+"
	mount_option="nodev"

	if grep -q $device_regex /etc/fstab ; then
	    previous_opts=$(grep $device_regex /etc/fstab | awk '{print $4}')
	    sed -i "s|\($device_regex.*$previous_opts\)|\1,$mount_option|" /etc/fstab
	else
	    echo "Not remediating, because there is no record of $var_removable_partition in /etc/fstab" >&2
	    return 1
	fi
	}

# Add nodev Option to /home
CCE-81047-3(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "yes" = 'yes'; then
			assert_mount_point_in_fstab /home || { echo "Not remediating, because there is no record of /home in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/home" "nodev" "" ""

		ensure_partition_is_mounted "/home"
	}

	perform_remediation
	}

# Add nosuid Option to /var/tmp
CCE-82153-8(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "yes" = 'yes'; then
			assert_mount_point_in_fstab /var/tmp || { echo "Not remediating, because there is no record of /var/tmp in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/var/tmp" "nosuid" "" ""

		ensure_partition_is_mounted "/var/tmp"
	}

	perform_remediation
	}

# Add nodev Option to /dev/shm 
CCE-80152-2(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "no" = 'yes'; then
			assert_mount_point_in_fstab /dev/shm || { echo "Not remediating, because there is no record of /dev/shm in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/dev/shm" "nodev" "tmpfs" "tmpfs"

		ensure_partition_is_mounted "/dev/shm"
	}

	perform_remediation
	}

# Add nosuid Option to /dev/shm
CCE-80154-8(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "no" = 'yes'; then
			assert_mount_point_in_fstab /dev/shm || { echo "Not remediating, because there is no record of /dev/shm in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/dev/shm" "nosuid" "tmpfs" "tmpfs"

		ensure_partition_is_mounted "/dev/shm"
	}

	perform_remediation
	}

# Add noexec Option to /tmp
CCE-80150-6(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "yes" = 'yes'; then
			assert_mount_point_in_fstab /tmp || { echo "Not remediating, because there is no record of /tmp in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/tmp" "noexec" "" ""

		ensure_partition_is_mounted "/tmp"
	}

	perform_remediation
	}

# Add nodev Option to /var/tmp
CCE-81052-3(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "yes" = 'yes'; then
			assert_mount_point_in_fstab /var/tmp || { echo "Not remediating, because there is no record of /var/tmp in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/var/tmp" "nodev" "" ""

		ensure_partition_is_mounted "/var/tmp"
	}

	perform_remediation
	}

# Add nosuid Option to Removable Media Partitions
CCE-80148-0(){
	var_removable_partition="(N/A)"

	device_regex="^\s*$var_removable_partition\s\+"
	mount_option="nosuid"

	if grep -q $device_regex /etc/fstab ; then
	    previous_opts=$(grep $device_regex /etc/fstab | awk '{print $4}')
	    sed -i "s|\($device_regex.*$previous_opts\)|\1,$mount_option|" /etc/fstab
	else
	    echo "Not remediating, because there is no record of $var_removable_partition in /etc/fstab" >&2
	    return 1
	fi
	}

# Add noexec Option to Removable Media Partitions
CCE-80147-2(){
	var_removable_partition="(N/A)"

	device_regex="^\s*$var_removable_partition\s\+"
	mount_option="noexec"

	if grep -q $device_regex /etc/fstab ; then
	    previous_opts=$(grep $device_regex /etc/fstab | awk '{print $4}')
	    sed -i "s|\($device_regex.*$previous_opts\)|\1,$mount_option|" /etc/fstab
	else
	    echo "Not remediating, because there is no record of $var_removable_partition in /etc/fstab" >&2
	    return 1
	fi
	}

# Add noexec Option to /var/tmp
CCE-82150-4(){
	function include_mount_options_functions {
		:
	}

	# $1: type of filesystem
	# $2: new mount point option
	# $3: filesystem of new mount point (used when adding new entry in fstab)
	# $4: mount type of new mount point (used when adding new entry in fstab)
	function ensure_mount_option_for_vfstype {
	        local _vfstype="$1" _new_opt="$2" _filesystem=$3 _type=$4 _vfstype_points=()
	        readarray -t _vfstype_points < <(grep -E "[[:space:]]${_vfstype}[[:space:]]" /etc/fstab | awk '{print $2}')

	        for _vfstype_point in "${_vfstype_points[@]}"
	        do
	                ensure_mount_option_in_fstab "$_vfstype_point" "$_new_opt" "$_filesystem" "$_type"
	        done
	}

	# $1: mount point
	# $2: new mount point option
	# $3: device or virtual string (used when adding new entry in fstab)
	# $4: mount type of mount point (used when adding new entry in fstab)
	function ensure_mount_option_in_fstab {
		local _mount_point="$1" _new_opt="$2" _device=$3 _type=$4
		local _mount_point_match_regexp="" _previous_mount_opts=""
		_mount_point_match_regexp="$(get_mount_point_regexp "$_mount_point")"

		if [ "$(grep -c "$_mount_point_match_regexp" /etc/fstab)" -eq 0 ]; then
			# runtime opts without some automatic kernel/userspace-added defaults
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/mtab | head -1 |  awk '{print $4}' \
						| sed -E "s/(rw|defaults|seclabel|${_new_opt})(,|$)//g;s/,$//")
			[ "$_previous_mount_opts" ] && _previous_mount_opts+=","
			echo "${_device} ${_mount_point} ${_type} defaults,${_previous_mount_opts}${_new_opt} 0 0" >> /etc/fstab
		elif [ "$(grep "$_mount_point_match_regexp" /etc/fstab | grep -c "$_new_opt")" -eq 0 ]; then
			_previous_mount_opts=$(grep "$_mount_point_match_regexp" /etc/fstab | awk '{print $4}')
			sed -i "s|\(${_mount_point_match_regexp}.*${_previous_mount_opts}\)|\1,${_new_opt}|" /etc/fstab
		fi
	}

	# $1: mount point
	function get_mount_point_regexp {
			printf "[[:space:]]%s[[:space:]]" "$1"
	}

	# $1: mount point
	function assert_mount_point_in_fstab {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		grep "$_mount_point_match_regexp" -q /etc/fstab \
			|| { echo "The mount point '$1' is not even in /etc/fstab, so we can't set up mount options" >&2; return 1; }
	}

	# $1: mount point
	function remove_defaults_from_fstab_if_overriden {
		local _mount_point_match_regexp
		_mount_point_match_regexp="$(get_mount_point_regexp "$1")"
		if grep "$_mount_point_match_regexp" /etc/fstab | grep -q "defaults,"
		then
			sed -i "s|\(${_mount_point_match_regexp}.*\)defaults,|\1|" /etc/fstab
		fi
	}

	# $1: mount point
	function ensure_partition_is_mounted {
		local _mount_point="$1"
		mkdir -p "$_mount_point" || return 1
		if mountpoint -q "$_mount_point"; then
			mount -o remount --target "$_mount_point"
		else
			mount --target "$_mount_point"
		fi
	}
	include_mount_options_functions

	function perform_remediation {
		# test "$mount_has_to_exist" = 'yes'
		if test "yes" = 'yes'; then
			assert_mount_point_in_fstab /var/tmp || { echo "Not remediating, because there is no record of /var/tmp in /etc/fstab" >&2; return 1; }
		fi

		ensure_mount_option_in_fstab "/var/tmp" "noexec" "" ""

		ensure_partition_is_mounted "/var/tmp"
	}

	perform_remediation
	}

# Disable Core Dumps for SUID programs
CCE-26900-1(){
	# Set runtime for fs.suid_dumpable
	#
	/sbin/sysctl -q -n -w fs.suid_dumpable="0"

	#
	# If fs.suid_dumpable present in /etc/sysctl.conf, change value to "0"
	#	else, add "fs.suid_dumpable = 0" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^fs.suid_dumpable' "0" 'CCE-26900-1'
	}

# Disable Core Dumps for All Users
CCE-80169-6(){
	SECURITY_LIMITS_FILE="/etc/security/limits.conf"

	if grep -qE '\*\s+hard\s+core' $SECURITY_LIMITS_FILE; then
	        sed -ri 's/(hard\s+core\s+)[[:digit:]]+/\1 0/' $SECURITY_LIMITS_FILE
	else
	        echo "*     hard   core    0" >> $SECURITY_LIMITS_FILE
	fi
	}

# Enable ExecShield via sysctl
CCE-27211-2(){
	if [ "$(getconf LONG_BIT)" = "32" ] ; then
	  #
	  # Set runtime for kernel.exec-shield
	  #
	  sysctl -q -n -w kernel.exec-shield=1

	  #
	  # If kernel.exec-shield present in /etc/sysctl.conf, change value to "1"
	  #	else, add "kernel.exec-shield = 1" to /etc/sysctl.conf
	  #
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	  replace_or_append '/etc/sysctl.conf' '^kernel.exec-shield' '1' 'CCE-27211-2'
	fi

	if [ "$(getconf LONG_BIT)" = "64" ] ; then
	  if grep --silent noexec /boot/grub2/grub*.cfg ; then 
	        sed -i "s/noexec.*//g" /etc/default/grub
	        sed -i "s/noexec.*//g" /etc/grub.d/*
	        GRUBCFG=/boot/grub2/*.cfg
	        grub2-mkconfig -o "$GRUBCFG"
	  fi
	fi
	}

# Enable Randomized Layout of Virtual Address Space
CCE-27127-0(){
	# Set runtime for kernel.randomize_va_space
	#
	/sbin/sysctl -q -n -w kernel.randomize_va_space="2"

	#
	# If kernel.randomize_va_space present in /etc/sysctl.conf, change value to "2"
	#	else, add "kernel.randomize_va_space = 2" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' "2" 'CCE-27127-0'
	}

# Install AIDE
CCE-27096-7(){
	if ! rpm -q --quiet "aide" ; then
	    yum install -y "aide"
	fi
	}

# Configure Periodic Execution of AIDE
CCE-26952-2(){
	if ! rpm -q --quiet "aide" ; then
	    yum install -y "aide"
	fi

	if ! grep -q "/usr/sbin/aide --check" /etc/crontab ; then
	    echo "05 4 * * * root /usr/sbin/aide --check" >> /etc/crontab
	else
	    sed -i '/^.*\/usr\/sbin\/aide --check.*$/d' /etc/crontab
	    echo "05 4 * * * root /usr/sbin/aide --check" >> /etc/crontab
	fi
	}

# Disable Prelinking
CCE-27078-5(){
	# prelink not installed
	if test -e /etc/sysconfig/prelink -o -e /usr/sbin/prelink; then
	    if grep -q ^PRELINKING /etc/sysconfig/prelink
	    then
	        sed -i 's/^PRELINKING[:blank:]*=[:blank:]*[:alpha:]*/PRELINKING=no/' /etc/sysconfig/prelink
	    else
	        printf '\n' >> /etc/sysconfig/prelink
	        printf '%s\n' '# Set PRELINKING=no per security requirements' 'PRELINKING=no' >> /etc/sysconfig/prelink
	    fi

	    # Undo previous prelink changes to binaries if prelink is available.
	    if test -x /usr/sbin/prelink; then
	        /usr/sbin/prelink -ua
	    fi
	fi
	}

# Ensure gpgcheck Enabled In Main yum Configuration
CCE-26989-4(){
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append "/etc/yum.conf" '^gpgcheck' '1' 'CCE-26989-4'
	}

# Disable rlogin Service
CCE-27336-7(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'rlogin.service'
	"$SYSTEMCTL_EXEC" disable 'rlogin.service'
	"$SYSTEMCTL_EXEC" mask 'rlogin.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^rlogin.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'rlogin.socket'
	    "$SYSTEMCTL_EXEC" disable 'rlogin.socket'
	    "$SYSTEMCTL_EXEC" mask 'rlogin.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'rlogin.service' || true
	}

# Disable rexec Service
CCE-27408-4(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'rexec.service'
	"$SYSTEMCTL_EXEC" disable 'rexec.service'
	"$SYSTEMCTL_EXEC" mask 'rexec.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^rexec.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'rexec.socket'
	    "$SYSTEMCTL_EXEC" disable 'rexec.socket'
	    "$SYSTEMCTL_EXEC" mask 'rexec.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'rexec.service' || true
	}

# Disable rsh Service
CCE-27337-5(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'rsh.service'
	"$SYSTEMCTL_EXEC" disable 'rsh.service'
	"$SYSTEMCTL_EXEC" mask 'rsh.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^rsh.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'rsh.socket'
	    "$SYSTEMCTL_EXEC" disable 'rsh.socket'
	    "$SYSTEMCTL_EXEC" mask 'rsh.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'rsh.service' || true
	}

# Remove Rsh Trust Files
CCE-27406-8(){
	find /home -maxdepth 2 -type f -name .rhosts -exec rm -f '{}' \;

	if [ -f /etc/hosts.equiv ]; then
		/bin/rm -f /etc/hosts.equiv
	fi
	}

# Remove telnet Clients
CCE-27305-2(){
	# CAUTION: This remediation script will remove telnet
	#	   from the system, and may remove any packages
	#	   that depend on telnet. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "telnet" ; then
	    yum remove -y "telnet"
	fi
	}

# Disable telnet Service
CCE-27401-9(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'telnet.service'
	"$SYSTEMCTL_EXEC" disable 'telnet.service'
	"$SYSTEMCTL_EXEC" mask 'telnet.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^telnet.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'telnet.socket'
	    "$SYSTEMCTL_EXEC" disable 'telnet.socket'
	    "$SYSTEMCTL_EXEC" mask 'telnet.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'telnet.service' || true
	}

# Remove NIS Client 
CCE-27396-1(){
	# CAUTION: This remediation script will remove ypbind
	#	   from the system, and may remove any packages
	#	   that depend on ypbind. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "ypbind" ; then
	    yum remove -y "ypbind"
	fi
	}

# Uninstall ypserv Package
CCE-27399-5(){
	# CAUTION: This remediation script will remove ypserv
	#	   from the system, and may remove any packages
	#	   that depend on ypserv. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "ypserv" ; then
	    yum remove -y "ypserv"
	fi
	}

# Disable tftp Service
CCE-80212-4(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'tftp.service'
	"$SYSTEMCTL_EXEC" disable 'tftp.service'
	"$SYSTEMCTL_EXEC" mask 'tftp.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^tftp.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'tftp.socket'
	    "$SYSTEMCTL_EXEC" disable 'tftp.socket'
	    "$SYSTEMCTL_EXEC" mask 'tftp.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'tftp.service' || true
	}

# Install tcp_wrappers Package
CCE-27361-5(){
	if ! rpm -q --quiet "tcp_wrappers" ; then
	    yum install -y "tcp_wrappers"
	fi
	}

# Disable xinetd Service
CCE-27443-1(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'xinetd.service'
	"$SYSTEMCTL_EXEC" disable 'xinetd.service'
	"$SYSTEMCTL_EXEC" mask 'xinetd.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^xinetd.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'xinetd.socket'
	    "$SYSTEMCTL_EXEC" disable 'xinetd.socket'
	    "$SYSTEMCTL_EXEC" mask 'xinetd.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'xinetd.service' || true
	}

# Uninstall talk Package
CCE-27432-4(){
	# CAUTION: This remediation script will remove talk
	#	   from the system, and may remove any packages
	#	   that depend on talk. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "talk" ; then
	    yum remove -y "talk"
	fi
	}

# Uninstall talk-server Package
CCE-27210-4(){
	# CAUTION: This remediation script will remove talk-server
	#	   from the system, and may remove any packages
	#	   that depend on talk-server. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "talk-server" ; then
	    yum remove -y "talk-server"
	fi
	}

# Disable vsftpd Service
CCE-80244-7(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'vsftpd.service'
	"$SYSTEMCTL_EXEC" disable 'vsftpd.service'
	"$SYSTEMCTL_EXEC" mask 'vsftpd.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^vsftpd.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'vsftpd.socket'
	    "$SYSTEMCTL_EXEC" disable 'vsftpd.socket'
	    "$SYSTEMCTL_EXEC" mask 'vsftpd.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'vsftpd.service' || true
	}

# Disable snmpd Service
CCE-80274-4(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'snmpd.service'
	"$SYSTEMCTL_EXEC" disable 'snmpd.service'
	"$SYSTEMCTL_EXEC" mask 'snmpd.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^snmpd.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'snmpd.socket'
	    "$SYSTEMCTL_EXEC" disable 'snmpd.socket'
	    "$SYSTEMCTL_EXEC" mask 'snmpd.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'snmpd.service' || true
	}

# Crontab settings
crontaby(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" start 'crond.service'
	"$SYSTEMCTL_EXEC" enable 'crond.service'
	chown 0 /etc/cron.hourly/
	chown 0 /etc/cron.d/
	chgrp 0 /etc/cron.daily/
	chgrp 0 /etc/crontab
	chmod 0700 /etc/cron.hourly/
	chgrp 0 /etc/cron.weekly/
	chmod 0700 /etc/cron.daily/
	chmod 0600 /etc/crontab
	chgrp 0 /etc/cron.d/
	chown 0 /etc/cron.monthly/
	chmod 0700 /etc/cron.monthly/
	chmod 0700 /etc/cron.d/
	chgrp 0 /etc/cron.hourly/
	chown 0 /etc/crontab
	chmod 0700 /etc/cron.weekly/
	chown 0 /etc/cron.daily/
	chgrp 0 /etc/cron.monthly/
	chown 0 /etc/cron.weekly/
	}

# Disable Samba
CCE-80277-7(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'smb.service'
	"$SYSTEMCTL_EXEC" disable 'smb.service'
	"$SYSTEMCTL_EXEC" mask 'smb.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^smb.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'smb.socket'
	    "$SYSTEMCTL_EXEC" disable 'smb.socket'
	    "$SYSTEMCTL_EXEC" mask 'smb.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'smb.service' || true
	}

# Enable the NTP Daemon
CCE-27444-9(){
	if rpm -q --quiet chrony ; then
	    if ! /usr/sbin/pidof ntpd ; then
	        /usr/bin/systemctl enable "chronyd"
	        /usr/bin/systemctl start "chronyd"
	        # The service may not be running because it has been started and failed,
	        # so let's reset the state so OVAL checks pass.
	        # Service should be 'inactive', not 'failed' after reboot though.
	        /usr/bin/systemctl reset-failed "chronyd"
	    fi
	elif rpm -q --quiet ntp ; then
	    /usr/bin/systemctl enable "ntpd"
	    /usr/bin/systemctl start "ntpd"
	    # The service may not be running because it has been started and failed,
	    # so let's reset the state so OVAL checks pass.
	    # Service should be 'inactive', not 'failed' after reboot though.
	    /usr/bin/systemctl reset-failed "ntpd"
	else
	    if ! rpm -q --quiet "chrony" ; then
	        yum install -y "chrony"
	    fi
	    /usr/bin/systemctl enable "chronyd"
	    /usr/bin/systemctl start "chronyd"
	    # The service may not be running because it has been started and failed,
	    # so let's reset the state so OVAL checks pass.
	    # Service should be 'inactive', not 'failed' after reboot though.
	    /usr/bin/systemctl reset-failed "chronyd"
	fi
	}

# Disable Red Hat Network Service (rhnsd) 
CCE-80269-4(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'rhnsd.service'
	"$SYSTEMCTL_EXEC" disable 'rhnsd.service'
	"$SYSTEMCTL_EXEC" mask 'rhnsd.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^rhnsd.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'rhnsd.socket'
	    "$SYSTEMCTL_EXEC" disable 'rhnsd.socket'
	    "$SYSTEMCTL_EXEC" mask 'rhnsd.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'rhnsd.service' || true
	}

# Disable DHCP Service
CCE-80330-4(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" stop 'dhcpd.service'
	"$SYSTEMCTL_EXEC" disable 'dhcpd.service'
	"$SYSTEMCTL_EXEC" mask 'dhcpd.service'
	# Disable socket activation if we have a unit file for it
	if "$SYSTEMCTL_EXEC" list-unit-files | grep -q '^dhcpd.socket'; then
	    "$SYSTEMCTL_EXEC" stop 'dhcpd.socket'
	    "$SYSTEMCTL_EXEC" disable 'dhcpd.socket'
	    "$SYSTEMCTL_EXEC" mask 'dhcpd.socket'
	fi
	# The service may not be running because it has been started and failed,
	# so let's reset the state so OVAL checks pass.
	# Service should be 'inactive', not 'failed' after reboot though.
	"$SYSTEMCTL_EXEC" reset-failed 'dhcpd.service' || true
	}

# Disable SSH Access via Empty Passwords
CCE-27471-2(){
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*PermitEmptyPasswords\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "PermitEmptyPasswords no" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "PermitEmptyPasswords no" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	}

# Set SSH Client Alive Max Count
CCE-27082-7(){
	var_sshd_set_keepalive="0"

	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*ClientAliveCountMax\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "ClientAliveCountMax $var_sshd_set_keepalive" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "ClientAliveCountMax $var_sshd_set_keepalive" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	}

# Enable SSH Warning Banner 
CCE-27314-4(){
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*Banner\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "Banner /etc/issue" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "Banner /etc/issue" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	}

# Use Only FIPS 140-2 Validated MACs
CCE-27455-5(){
	sshd_approved_macs="hmac-sha2-512,hmac-sha2-256,hmac-sha1,hmac-sha1-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/ssh/sshd_config' '^MACs' "$sshd_approved_macs" 'CCE-27455-5' '%s %s'
	}

# SSH Hardening Configurations
hardenssh(){
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*LogLevel\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "LogLevel INFO" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "LogLevel INFO" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/ssh/sshd_config' '^Protocol' '2' 'CCE-27320-1' '%s %s'
	sshd_idle_timeout_value="300"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/ssh/sshd_config' '^ClientAliveInterval' $sshd_idle_timeout_value 'CCE-27433-2' '%s %s'
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*PermitUserEnvironment\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "PermitUserEnvironment no" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "PermitUserEnvironment no" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*X11Forwarding\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "X11Forwarding yes" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "X11Forwarding yes" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	sshd_approved_ciphers="aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/ssh/sshd_config' '^Ciphers' "$sshd_approved_ciphers" 'CCE-27295-5' '%s %s'
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*HostbasedAuthentication\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "HostbasedAuthentication no" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "HostbasedAuthentication no" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	sshd_max_auth_tries_value="4"

	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*MaxAuthTries\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "MaxAuthTries $sshd_max_auth_tries_value" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "MaxAuthTries $sshd_max_auth_tries_value" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*PermitRootLogin\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "PermitRootLogin no" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "PermitRootLogin no" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	chgrp 0 /etc/ssh/sshd_config
	chown 0 /etc/ssh/sshd_config
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*IgnoreRhosts\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "IgnoreRhosts yes" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "IgnoreRhosts yes" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*PermitUserEnvironment\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "PermitUserEnvironment no" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "PermitUserEnvironment no" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	var_sshd_priv_separation="sandbox"

	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*UsePrivilegeSeparation\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "UsePrivilegeSeparation $var_sshd_priv_separation" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "UsePrivilegeSeparation $var_sshd_priv_separation" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*GSSAPIAuthentication\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "GSSAPIAuthentication no" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "GSSAPIAuthentication no" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*PrintLastLog\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "PrintLastLog yes" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "PrintLastLog yes" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	if [ -e "/etc/ssh/sshd_config" ] ; then
	    LC_ALL=C sed -i "/^\s*PrintLastLog\s\+/Id" "/etc/ssh/sshd_config"
	else
	    touch "/etc/ssh/sshd_config"
	fi
	cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
	# Insert before the line matching the regex '^Match'.
	line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
	if [ -z "$line_number" ]; then
	    # There was no match of '^Match', insert at
	    # the end of the file.
	    printf '%s\n' "PrintLastLog yes" >> "/etc/ssh/sshd_config"
	else
	    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
	    printf '%s\n' "PrintLastLog yes" >> "/etc/ssh/sshd_config"
	    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
	fi
	# Clean up after ourselves.
	rm "/etc/ssh/sshd_config.bak"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/ssh/sshd_config' '^RhostsRSAAuthentication' 'no' 'CCE-80373-4' '%s %s'
	var_sshd_disable_compression="no"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/ssh/sshd_config' '^Compression' "$var_sshd_disable_compression" 'CCE-80224-9' '%s %s'
	find /etc/ssh/ -regex '^.*.pub$' -exec chmod 0644 {} \;
	find /etc/ssh/ -regex '^.*_key$' -exec chmod 0640 {} \;
	}

#Set Password Hashing Algorithm in /etc/login.defs
CCE-82050-6(){
	if grep --silent ^ENCRYPT_METHOD /etc/login.defs ; then
		sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/g' /etc/login.defs
	else
		echo "" >> /etc/login.defs
		echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
	fi
	}

# Set Password Hashing Algorithm in /etc/libuser.conf
CCE-82038-1(){
	LIBUSER_CONF="/etc/libuser.conf"
	CRYPT_STYLE_REGEX='[[:space:]]*\[defaults](.*(\n)+)+?[[:space:]]*crypt_style[[:space:]]*'

	# Try find crypt_style in [defaults] section. If it is here, then change algorithm to sha512.
	# If it isn't here, then add it to [defaults] section.
	if grep -qzosP $CRYPT_STYLE_REGEX $LIBUSER_CONF ; then
	        sed -i "s/\(crypt_style[[:space:]]*=[[:space:]]*\).*/\1sha512/g" $LIBUSER_CONF
	elif grep -qs "\[defaults]" $LIBUSER_CONF ; then
	        sed -i "/[[:space:]]*\[defaults]/a crypt_style = sha512" $LIBUSER_CONF
	else
	        echo -e "[defaults]\ncrypt_style = sha512" >> $LIBUSER_CONF
	fi
	}

# Configure the root Account for Failed Password Attempts
CCE-80353-6(){
	AUTH_FILES[0]="/etc/pam.d/system-auth"
	AUTH_FILES[1]="/etc/pam.d/password-auth"

	# This script fixes absence of pam_faillock.so in PAM stack or the
	# absense of even_deny_root in pam_faillock.so arguments
	# When inserting auth pam_faillock.so entries,
	# the entry with preauth argument will be added before pam_unix.so module
	# and entry with authfail argument will be added before pam_deny.so module.

	# The placement of pam_faillock.so entries will not be changed
	# if they are already present

	for pamFile in "${AUTH_FILES[@]}"
	do
		# if PAM file is missing, system is not using PAM or broken
		if [ ! -f $pamFile ]; then
			continue
		fi

		# is 'auth required' here?
		if grep -q "^auth.*required.*pam_faillock.so.*" $pamFile; then
			# has 'auth required' even_deny_root option?
			if ! grep -q "^auth.*required.*pam_faillock.so.*preauth.*even_deny_root" $pamFile; then
				# even_deny_root is not present
				sed -i --follow-symlinks "s/\(^auth.*required.*pam_faillock.so.*preauth.*\).*/\1 even_deny_root/" $pamFile
			fi
		else
			# no 'auth required', add it
			sed -i --follow-symlinks "/^auth.*pam_unix.so.*/i auth required pam_faillock.so preauth silent even_deny_root" $pamFile
		fi

		# is 'auth [default=die]' here?
		if grep -q "^auth.*\[default=die\].*pam_faillock.so.*" $pamFile; then
			# has 'auth [default=die]' even_deny_root option?
			if ! grep -q "^auth.*\[default=die\].*pam_faillock.so.*authfail.*even_deny_root" $pamFile; then
				# even_deny_root is not present
				sed -i --follow-symlinks "s/\(^auth.*\[default=die\].*pam_faillock.so.*authfail.*\).*/\1 even_deny_root/" $pamFile
			fi
		else
			# no 'auth [default=die]', add it
			sed -i --follow-symlinks "/^auth.*pam_unix.so.*/a auth [default=die] pam_faillock.so authfail silent even_deny_root" $pamFile
		fi
	done
	}

# Ensure PAM Enforces Password Requirements - Maximum Consecutive Repeating Characters from Same Character Class 
CCE-27512-3(){
	var_password_pam_maxclassrepeat="4"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^maxclassrepeat' $var_password_pam_maxclassrepeat 'CCE-27512-3' '%s = %s'
	}

# Set Password Maximum Consecutive Repeating Characters 
CCE-82055-5(){
	var_password_pam_maxrepeat="3"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^maxrepeat' $var_password_pam_maxrepeat 'CCE-82055-5' '%s = %s'
	}

# Ensure PAM Enforces Password Requirements - Minimum Different Categories
CCE-82045-6(){
	var_password_pam_minclass="4"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^minclass' $var_password_pam_minclass 'CCE-82045-6' '%s = %s'
	}

# Ensure PAM Enforces Password Requirements - Minimum Different Characters
CCE-82020-9(){
	var_password_pam_difok="8"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^difok' $var_password_pam_difok 'CCE-82020-9' '%s = %s'
	}

# Ensure PAM Enforces Password Requirements - Minimum Special Characters
CCE-27360-7(){
	var_password_pam_ocredit="-1"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/security/pwquality.conf' '^ocredit' $var_password_pam_ocredit 'CCE-27360-7' '%s = %s'
	}

# Ensure PAM Displays Last Logon/Access Notification
CCE-27275-7(){
	if grep -q "^session.*pam_lastlog.so" /etc/pam.d/postlogin; then
		sed -i --follow-symlinks "/pam_lastlog.so/d" /etc/pam.d/postlogin
	fi

	echo "session     [default=1]   pam_lastlog.so nowtmp showfailed" >> /etc/pam.d/postlogin
	echo "session     optional      pam_lastlog.so silent noupdate showfailed" >> /etc/pam.d/postlogin
	}

# Install the screen Package
# Install Smart Card Packages For Multifactor Authentication
# Install the tmux Package
CCE-27351-6_CCE-80519-2_(){
	if ! rpm -q --quiet "screen" ; then
	    yum install -y "screen"
	fi
	if ! rpm -q --quiet "esc" ; then
	    yum install -y "esc"
	fi
	if ! rpm -q --quiet "pam_pkcs11" ; then
	    yum install -y "pam_pkcs11"
	fi
	if ! rpm -q --quiet "esc" ; then
	    yum install -y "esc"
	fi
	if ! rpm -q --quiet "tmux" ; then
	    yum install -y "tmux"
	fi
	}

# Disable Ctrl-Alt-Del Reboot Activation
CCE-27511-5(){
	# The process to disable ctrl+alt+del has changed in RHEL7. 
	# Reference: https://access.redhat.com/solutions/1123873

	systemctl mask ctrl-alt-del.target
	}

# Ensure the Default Umask is Set Correctly in login.defs
CCE-80205-8(){
	var_accounts_user_umask="077"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/login.defs' '^UMASK' "$var_accounts_user_umask" 'CCE-80205-8' '%s %s'
	}

# Set Interactive Session Timeou
CCE-27557-8(){
	var_accounts_tmout="600"

	if grep --silent ^TMOUT /etc/profile ; then
	        sed -i "s/^TMOUT.*/TMOUT=$var_accounts_tmout/g" /etc/profile
	else
	        echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile
	        echo "TMOUT=$var_accounts_tmout" >> /etc/profile
	fi
	}

# Ensure Home Directories are Created for New Users
CCE-80434-4(){
	if ! grep -q ^CREATE_HOME /etc/login.defs; then
		echo "CREATE_HOME     yes" >> /etc/login.defs
	else
		sed -i "s/^\(CREATE_HOME\).*/\1 yes/g" /etc/login.defs
	fi
	}

# Ensure the Logon Failure Delay is Set Correctly in login.defs
CCE-80352-8(){
	# Set variables
	var_accounts_fail_delay="4"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/login.defs' '^FAIL_DELAY' "$var_accounts_fail_delay" 'CCE-80352-8' '%s %s'
	}

# Limit the Number of Concurrent Login Sessions Allowed Per User
CCE-82041-5(){
	var_accounts_max_concurrent_login_sessions="10"

	if grep -q '^[^#]*\<maxlogins\>' /etc/security/limits.d/*.conf; then
		sed -i "/^[^#]*\<maxlogins\>/ s/maxlogins.*/maxlogins $var_accounts_max_concurrent_login_sessions/" /etc/security/limits.d/*.conf
	elif grep -q '^[^#]*\<maxlogins\>' /etc/security/limits.conf; then
		sed -i "/^[^#]*\<maxlogins\>/ s/maxlogins.*/maxlogins $var_accounts_max_concurrent_login_sessions/" /etc/security/limits.conf
	else
		echo "*	hard	maxlogins	$var_accounts_max_concurrent_login_sessions" >> /etc/security/limits.conf
	fi
	}

# Prevent Login to Accounts With Empty Password
CCE-27286-4(){
	sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth
	sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/password-auth
	}

# Encrypt Audit Records Sent With audispd Plugin
CCE-80540-8(){
	AUDISP_REMOTE_CONFIG="/etc/audisp/audisp-remote.conf"
	option="^enable_krb5"
	value="yes"
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append $AUDISP_REMOTE_CONFIG "$option" "$value" "CCE-80540-8"
	}

# Configure auditd space_left on Low Disk Space
CCE-80537-4(){
	var_auditd_space_left="100"

	grep -q "^space_left[[:space:]]*=.*$" /etc/audit/auditd.conf && \
	  sed -i "s/^space_left[[:space:]]*=.*$/space_left = $var_auditd_space_left/g" /etc/audit/auditd.conf || \
	  echo "space_left = $var_auditd_space_left" >> /etc/audit/auditd.conf
	}

# Ensure auditd Collects Information on Kernel Module Loading and Unloading - finit_module
CCE-80547-3(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	# Note: 32-bit and 64-bit kernel syscall numbers not always line up =>
	#       it's required on a 64-bit system to check also for the presence
	#       of 32-bit's equivalent of the corresponding rule.
	#       (See `man 7 audit.rules` for details )
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S finit_module \(-F key=\|-k \).*"
		GROUP="modules"
		FULL_RULE="-a always,exit -F arch=$ARCH -S finit_module -k modules"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Ensure auditd Collects Information on Kernel Module Loading - init_module
CCE-80414-6(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	# Note: 32-bit and 64-bit kernel syscall numbers not always line up =>
	#       it's required on a 64-bit system to check also for the presence
	#       of 32-bit's equivalent of the corresponding rule.
	#       (See `man 7 audit.rules` for details )
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S init_module \(-F key=\|-k \).*"
		GROUP="modules"
		FULL_RULE="-a always,exit -F arch=$ARCH -S init_module -k modules"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Ensure auditd Collects Information on Kernel Module Unloading - delete_module
CCE-80415-3(){
	# First perform the remediation of the syscall rule
	# Retrieve hardware architecture of the underlying system
	# Note: 32-bit and 64-bit kernel syscall numbers not always line up =>
	#       it's required on a 64-bit system to check also for the presence
	#       of 32-bit's equivalent of the corresponding rule.
	#       (See `man 7 audit.rules` for details )
	[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

	for ARCH in "${RULE_ARCHS[@]}"
	do
		PATTERN="-a always,exit -F arch=$ARCH -S delete_module \(-F key=\|-k \).*"
		GROUP="modules"
		FULL_RULE="-a always,exit -F arch=$ARCH -S delete_module -k modules"
		# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
		fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
		fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	done
	}

# Record Attempts to Alter Logon and Logout Events - lastlog
CCE-80384-1(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/log/lastlog" "wa" "logins"
	fix_audit_watch_rule "augenrules" "/var/log/lastlog" "wa" "logins"
	}

# Record Attempts to Alter Logon and Logout Events - faillock
CCE-80383-3(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/run/faillock" "wa" "logins"
	fix_audit_watch_rule "augenrules" "/var/run/faillock" "wa" "logins"
	}

# Record Attempts to Alter Logon and Logout Events - tallylog
CCE-80994-7(){
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix audit file system object watch rule for given path:
	# * if rule exists, also verifies the -w bits match the requirements
	# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
	#   audit rules file, depending on the tool which was used to load audit rules
	#
	# Expects four arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules'
	# * path                        	value of -w audit rule's argument
	# * required access bits        	value of -p audit rule's argument
	# * key                         	value of -k audit rule's argument
	#
	# Example call:
	#
	#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
	#
	function fix_audit_watch_rule {

	# Load function arguments into local variables
	local tool="$1"
	local path="$2"
	local required_access_bits="$3"
	local key="$4"

	# Check sanity of the input
	if [ $# -ne "4" ]
	then
		echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	#
	# -----------------------------------------------------------------------------------------
	# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
	# -----------------------------------------------------------------------------------------
	#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
	# -----------------------------------------------------------------------------------------
	# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
	# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	declare -a files_to_inspect
	files_to_inspect=()

	# Check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		exit 1
	# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# into the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules')
	# If the audit is 'augenrules', then check if rule is already defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
	# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
	elif [ "$tool" == 'augenrules' ]
	then
		readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

		# For each of the matched entries
		for match in "${matches[@]}"
		do
			# Extract filepath from the match
			rulesd_audit_file=$(echo $match | cut -f1 -d ':')
			# Append that path into list of files for inspection
			files_to_inspect+=("$rulesd_audit_file")
		done
		# Case when particular audit rule isn't defined yet
		if [ "${#files_to_inspect[@]}" -eq "0" ]
		then
			# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
			local key_rule_file="/etc/audit/rules.d/$key.rules"
			# If the $key.rules file doesn't exist yet, create it with correct permissions
			if [ ! -e "$key_rule_file" ]
			then
				touch "$key_rule_file"
				chmod 0640 "$key_rule_file"
			fi

			files_to_inspect+=("$key_rule_file")
		fi
	fi

	# Finally perform the inspection and possible subsequent audit rule
	# correction for each of the files previously identified for inspection
	for audit_rules_file in "${files_to_inspect[@]}"
	do

		# Check if audit watch file system object rule for given path already present
		if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
		then
			# Rule is found => verify yet if existing rule definition contains
			# all of the required access type bits

			# Escape slashes in path for use in sed pattern below
			local esc_path=${path//$'/'/$'\/'}
			# Define BRE whitespace class shortcut
			local sp="[[:space:]]"
			# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
			current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
			# Split required access bits string into characters array
			# (to check bit's presence for one bit at a time)
			for access_bit in $(echo "$required_access_bits" | grep -o .)
			do
				# For each from the required access bits (e.g. 'w', 'a') check
				# if they are already present in current access bits for rule.
				# If not, append that bit at the end
				if ! grep -q "$access_bit" <<< "$current_access_bits"
				then
					# Concatenate the existing mask with the missing bit
					current_access_bits="$current_access_bits$access_bit"
				fi
			done
			# Propagate the updated rule's access bits (original + the required
			# ones) back into the /etc/audit/audit.rules file for that rule
			sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
		else
			# Rule isn't present yet. Append it at the end of $audit_rules_file file
			# with proper key

			echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
		fi
	done
	}
	fix_audit_watch_rule "auditctl" "/var/log/tallylog" "wa" "logins"
	fix_audit_watch_rule "augenrules" "/var/log/tallylog" "wa" "logins"
	}

# Record Any Attempts to Run setfiles
CCE-80660-4(){
	PATTERN="-a always,exit -F path=/usr/sbin/setfiles\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/setfiles -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Record Any Attempts to Run setsebool
CCE-80392-4(){
	PATTERN="-a always,exit -F path=/usr/sbin/setsebool\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/setsebool -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Record Any Attempts to Run semanage
CCE-80391-6(){
	PATTERN="-a always,exit -F path=/usr/sbin/semanage\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/semanage -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Record Any Attempts to Run chcon
CCE-80393-2(){
	PATTERN="-a always,exit -F path=/usr/bin/chcon\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - passwd
CCE-80395-7(){
	PATTERN="-a always,exit -F path=/usr/bin/passwd\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - sudo
CCE-80401-3(){
	PATTERN="-a always,exit -F path=/usr/bin/sudo\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - postdrop
CCE-80406-2(){
	PATTERN="-a always,exit -F path=/usr/sbin/postdrop\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/postdrop -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - chsh
CCE-80404-7(){
	PATTERN="-a always,exit -F path=/usr/bin/chsh\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/chsh -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - gpasswd
CCE-80397-3(){
	PATTERN="-a always,exit -F path=/usr/bin/gpasswd\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - chage 
CCE-80398-1(){
	PATTERN="-a always,exit -F path=/usr/bin/chage\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/chage -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - userhelper
CCE-80399-9(){
	PATTERN="-a always,exit -F path=/usr/sbin/userhelper\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/userhelper -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - pam_timestamp_check
CCE-80411-2(){
	PATTERN="-a always,exit -F path=/usr/sbin/pam_timestamp_check\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/pam_timestamp_check -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - crontab
CCE-80405-4(){
	PATTERN="-a always,exit -F path=/usr/bin/crontab\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - unix_chkpwd
CCE-80396-5(){
	PATTERN="-a always,exit -F path=/usr/sbin/unix_chkpwd\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - ssh-keysign
CCE-80408-8(){
	PATTERN="-a always,exit -F path=/usr/libexec/openssh/ssh-keysign\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/libexec/openssh/ssh-keysign -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - sudoedit
CCE-80402-1(){
	PATTERN="-a always,exit -F path=/usr/bin/sudoedit\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/sudoedit -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - postqueue
CCE-80407-0(){
	PATTERN="-a always,exit -F path=/usr/sbin/postqueue\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/sbin/postqueue -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - su
CCE-80400-5(){
	PATTERN="-a always,exit -F path=/usr/bin/su\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/su -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Ensure auditd Collects Information on the Use of Privileged Commands - newgrp
CCE-80403-9(){
	PATTERN="-a always,exit -F path=/usr/bin/newgrp\\s\\+.*"
	GROUP="privileged"
	# Although the fix doesn't use ARCH, we reset it because it could have been set by some other remediation
	ARCH=""
	FULL_RULE="-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	# Function to fix syscall audit rule for given system call. It is
	# based on example audit syscall rule definitions as outlined in
	# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
	# package. It will combine multiple system calls belonging to the same
	# syscall group into one audit rule (rather than to create audit rule per
	# different system call) to avoid audit infrastructure performance penalty
	# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
	#
	#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
	#
	# for further details.
	#
	# Expects five arguments (each of them is required) in the form of:
	# * audit tool				tool used to load audit rules,
	# 					either 'auditctl', or 'augenrules
	# * audit rules' pattern		audit rule skeleton for same syscall
	# * syscall group			greatest common string this rule shares
	# 					with other rules from the same group
	# * architecture			architecture this rule is intended for
	# * full form of new rule to add	expected full form of audit rule as to be
	# 					added into audit.rules file
	#
	# Note: The 2-th up to 4-th arguments are used to determine how many existing
	# audit rules will be inspected for resemblance with the new audit rule
	# (5-th argument) the function is going to add. The rule's similarity check
	# is performed to optimize audit.rules definition (merge syscalls of the same
	# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
	# penalty.
	#
	# Example call:
	#
	#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
	#
	function fix_audit_syscall_rule {

	# Load function arguments into local variables
	local tool="$1"
	local pattern="$2"
	local group="$3"
	local arch="$4"
	local full_rule="$5"

	# Check sanity of the input
	if [ $# -ne "5" ]
	then
		echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
		echo "Aborting."
		exit 1
	fi

	# Create a list of audit *.rules files that should be inspected for presence and correctness
	# of a particular audit rule. The scheme is as follows:
	# 
	# -----------------------------------------------------------------------------------------
	#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
	# -----------------------------------------------------------------------------------------
	#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
	# -----------------------------------------------------------------------------------------
	#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
	#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
	# -----------------------------------------------------------------------------------------
	#
	declare -a files_to_inspect

	retval=0

	# First check sanity of the specified audit tool
	if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
	then
		echo "Unknown audit rules loading tool: $1. Aborting."
		echo "Use either 'auditctl' or 'augenrules'!"
		return 1
	# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
	# file to the list of files to be inspected
	elif [ "$tool" == 'auditctl' ]
	then
		files_to_inspect+=('/etc/audit/audit.rules' )
	# If audit tool is 'augenrules', then check if the audit rule is defined
	# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
	# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
	elif [ "$tool" == 'augenrules' ]
	then
		# Extract audit $key from audit rule so we can use it later
		matches=()
		key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
		readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
		if [ $? -ne 0 ]
		then
			retval=1
		fi
		for match in "${matches[@]}"
		do
			files_to_inspect+=("${match}")
		done
		# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
		if [ ${#files_to_inspect[@]} -eq "0" ]
		then
			file_to_inspect="/etc/audit/rules.d/$key.rules"
			files_to_inspect=("$file_to_inspect")
			if [ ! -e "$file_to_inspect" ]
			then
				touch "$file_to_inspect"
				chmod 0640 "$file_to_inspect"
			fi
		fi
	fi

	#
	# Indicator that we want to append $full_rule into $audit_file by default
	local append_expected_rule=0

	for audit_file in "${files_to_inspect[@]}"
	do
		# Filter existing $audit_file rules' definitions to select those that:
		# * follow the rule pattern, and
		# * meet the hardware architecture requirement, and
		# * are current syscall group specific
		readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
		if [ $? -ne 0 ]
		then
			retval=1
		fi

		# Process rules found case-by-case
		for rule in "${existing_rules[@]}"
		do
			# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
			if [ "${rule}" != "${full_rule}" ]
			then
				# If so, isolate just '(-S \w)+' substring of that rule
				rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
				# Check if list of '-S syscall' arguments of that rule is subset
				# of '-S syscall' list of expected $full_rule
				if grep -q -- "$rule_syscalls" <<< "$full_rule"
				then
					# Rule is covered (i.e. the list of -S syscalls for this rule is
					# subset of -S syscalls of $full_rule => existing rule can be deleted
					# Thus delete the rule from audit.rules & our array
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi
					existing_rules=("${existing_rules[@]//$rule/}")
				else
					# Rule isn't covered by $full_rule - it besides -S syscall arguments
					# for this group contains also -S syscall arguments for other syscall
					# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
					# since 'lchown' & 'fchownat' share 'chown' substring
					# Therefore:
					# * 1) delete the original rule from audit.rules
					# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
					# * 2) delete the -S syscall arguments for this syscall group, but
					# keep those not belonging to this syscall group
					# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
					# * 3) append the modified (filtered) rule again into audit.rules
					# if the same rule not already present
					#
					# 1) Delete the original rule
					sed -i -e "\;${rule};d" "$audit_file"
					if [ $? -ne 0 ]
					then
						retval=1
					fi

					# 2) Delete syscalls for this group, but keep those from other groups
					# Convert current rule syscall's string into array splitting by '-S' delimiter
					IFS_BKP="$IFS"
					IFS=$'-S'
					read -a rule_syscalls_as_array <<< "$rule_syscalls"
					# Reset IFS back to default
					IFS="$IFS_BKP"
					# Splitting by "-S" can't be replaced by the readarray functionality easily

					# Declare new empty string to hold '-S syscall' arguments from other groups
					new_syscalls_for_rule=''
					# Walk through existing '-S syscall' arguments
					for syscall_arg in "${rule_syscalls_as_array[@]}"
					do
						# Skip empty $syscall_arg values
						if [ "$syscall_arg" == '' ]
						then
							continue
						fi
						# If the '-S syscall' doesn't belong to current group add it to the new list
						# (together with adding '-S' delimiter back for each of such item found)
						if grep -q -v -- "$group" <<< "$syscall_arg"
						then
							new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
						fi
					done
					# Replace original '-S syscall' list with the new one for this rule
					updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
					# Squeeze repeated whitespace characters in rule definition (if any) into one
					updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
					# 3) Append the modified / filtered rule again into audit.rules
					#    (but only in case it's not present yet to prevent duplicate definitions)
					if ! grep -q -- "$updated_rule" "$audit_file"
					then
						echo "$updated_rule" >> "$audit_file"
					fi
				fi
			else
				# $audit_file already contains the expected rule form for this
				# architecture & key => don't insert it second time
				append_expected_rule=1
			fi
		done

		# We deleted all rules that were subset of the expected one for this arch & key.
		# Also isolated rules containing system calls not from this system calls group.
		# Now append the expected rule if it's not present in $audit_file yet
		if [[ ${append_expected_rule} -eq "0" ]]
		then
			echo "$full_rule" >> "$audit_file"
		fi
	done

	return $retval

	}
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	}

# Shutdown System When Auditing Failures Occur
CCE-80997-0(){
	# Traverse all of:
	#
	# /etc/audit/audit.rules,			(for auditctl case)
	# /etc/audit/rules.d/*.rules			(for augenrules case)
	#
	# files to check if '-f .*' setting is present in that '*.rules' file already.
	# If found, delete such occurrence since auditctl(8) manual page instructs the
	# '-f 2' rule should be placed as the last rule in the configuration
	find /etc/audit /etc/audit/rules.d -maxdepth 1 -type f -name '*.rules' -exec sed -i '/-e[[:space:]]\+.*/d' {} ';'

	# Append '-f 2' requirement at the end of both:
	# * /etc/audit/audit.rules file 		(for auditctl case)
	# * /etc/audit/rules.d/immutable.rules		(for augenrules case)

	for AUDIT_FILE in "/etc/audit/audit.rules" "/etc/audit/rules.d/immutable.rules"
	do
		echo '' >> $AUDIT_FILE
		echo '# Set the audit.rules configuration to halt system upon audit failure per security requirements' >> $AUDIT_FILE
		echo '-f 2' >> $AUDIT_FILE
	done
	}

# Ensure cron Is Logging To Rsyslog
CCE-80380-9(){
	if ! grep -s "^\s*cron\.\*\s*/var/log/cron$" /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
		mkdir -p /etc/rsyslog.d
		echo "cron.*	/var/log/cron" >> /etc/rsyslog.d/cron.conf
	fi
	}

# Verify firewalld Enabled
CCE-80998-8(){
	SYSTEMCTL_EXEC='/usr/bin/systemctl'
	"$SYSTEMCTL_EXEC" start 'firewalld.service'
	"$SYSTEMCTL_EXEC" enable 'firewalld.service'
	}

# Configure firewalld To Rate Limit Connections
CCE-80542-4(){
	firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -p tcp -m limit --limit 25/minute --limit-burst 100  -j INPUT_ZONES
	firewall-cmd --reload
	}

# Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv6 Interfaces
CCE-80179-5(){
	sysctl_net_ipv6_conf_all_accept_source_route_value="0"

	#
	# Set runtime for net.ipv6.conf.all.accept_source_route
	#
	/sbin/sysctl -q -n -w net.ipv6.conf.all.accept_source_route="$sysctl_net_ipv6_conf_all_accept_source_route_value"

	#
	# If net.ipv6.conf.all.accept_source_route present in /etc/sysctl.conf, change value to appropriate value
	#	else, add "net.ipv6.conf.all.accept_source_route = value" to /etc/sysctl.conf
	#
	# Function to replace configuration setting in config file or add the configuration setting if
	# it does not exist.
	#
	# Expects arguments:
	#
	# config_file:		Configuration file that will be modified
	# key:			Configuration option to change
	# value:		Value of the configuration option to change
	# cce:			The CCE identifier or '@CCENUM@' if no CCE identifier exists
	# format:		The printf-like format string that will be given stripped key and value as arguments,
	#			so e.g. '%s=%s' will result in key=value subsitution (i.e. without spaces around =)
	#
	# Optional arugments:
	#
	# format:		Optional argument to specify the format of how key/value should be
	# 			modified/appended in the configuration file. The default is key = value.
	#
	# Example Call(s):
	#
	#     With default format of 'key = value':
	#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
	#
	#     With custom key/value format:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
	#
	#     With a variable:
	#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
	#
	function replace_or_append {
	  local default_format='%s = %s' case_insensitive_mode=yes sed_case_insensitive_option='' grep_case_insensitive_option=''
	  local config_file=$1
	  local key=$2
	  local value=$3
	  local cce=$4
	  local format=$5

	  if [ "$case_insensitive_mode" = yes ]; then
	    sed_case_insensitive_option="i"
	    grep_case_insensitive_option="-i"
	  fi
	  [ -n "$format" ] || format="$default_format"
	  # Check sanity of the input
	  [ $# -ge "3" ] || { echo "Usage: replace_or_append <config_file_location> <key_to_search> <new_value> [<CCE number or literal '@CCENUM@' if unknown>] [printf-like format, default is '$default_format']" >&2; exit 1; }

	  # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
	  # Otherwise, regular sed command will do.
	  sed_command=('sed' '-i')
	  if test -L "$config_file"; then
	    sed_command+=('--follow-symlinks')
	  fi

	  # Test that the cce arg is not empty or does not equal @CCENUM@.
	  # If @CCENUM@ exists, it means that there is no CCE assigned.
	  if [ -n "$cce" ] && [ "$cce" != '@CCENUM@' ]; then
	    cce="${cce}"
	  else
	    cce="CCE"
	  fi

	  # Strip any search characters in the key arg so that the key can be replaced without
	  # adding any search characters to the config file.
	  stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "$key")

	  # shellcheck disable=SC2059
	  printf -v formatted_output "$format" "$stripped_key" "$value"

	  # If the key exists, change it. Otherwise, add it to the config_file.
	  # We search for the key string followed by a word boundary (matched by \>),
	  # so if we search for 'setting', 'setting2' won't match.
	  if LC_ALL=C grep -q -m 1 $grep_case_insensitive_option -e "${key}\\>" "$config_file"; then
	    "${sed_command[@]}" "s/${key}\\>.*/$formatted_output/g$sed_case_insensitive_option" "$config_file"
	  else
	    # \n is precaution for case where file ends without trailing newline
	    printf '\n# Per %s: Set %s in %s\n' "$cce" "$formatted_output" "$config_file" >> "$config_file"
	    printf '%s\n' "$formatted_output" >> "$config_file"
	  fi
	}
	replace_or_append '/etc/sysctl.conf' '^net.ipv6.conf.all.accept_source_route' "$sysctl_net_ipv6_conf_all_accept_source_route_value" 'CCE-80179-5'
	}

# Enable FIPS mode
fips_enabled(){
	# prelink not installed
	if test -e /etc/sysconfig/prelink -o -e /usr/sbin/prelink; then
	    if grep -q ^PRELINKING /etc/sysconfig/prelink
	    then
	        sed -i 's/^PRELINKING[:blank:]*=[:blank:]*[:alpha:]*/PRELINKING=no/' /etc/sysconfig/prelink
	    else
	        printf '\n' >> /etc/sysconfig/prelink
	        printf '%s\n' '# Set PRELINKING=no per security requirements' 'PRELINKING=no' >> /etc/sysconfig/prelink
	    fi

	    # Undo previous prelink changes to binaries if prelink is available.
	    if test -x /usr/sbin/prelink; then
	        /usr/sbin/prelink -ua
	    fi
	fi

	if grep -q -m1 -o aes /proc/cpuinfo; then
		if ! rpm -q --quiet "dracut-fips-aesni" ; then
	    yum install -y "dracut-fips-aesni"
	fi
	fi
	if ! rpm -q --quiet "dracut-fips" ; then
	    yum install -y "dracut-fips"
	fi

	dracut -f

	# Correct the form of default kernel command line in  grub
	if grep -q '^GRUB_CMDLINE_LINUX=.*fips=.*"'  /etc/default/grub; then
		# modify the GRUB command-line if a fips= arg already exists
		sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)fips=[^[:space:]]*\(.*"\)/\1 fips=1 \2/'  /etc/default/grub
	else
		# no existing fips=arg is present, append it
		sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 fips=1"/'  /etc/default/grub
	fi

	# Get the UUID of the device mounted at root (/).
	ROOT_UUID=$(findmnt --noheadings --output uuid --target /)

	# Get the UUID of the device mounted at /boot.
	BOOT_UUID=$(findmnt --noheadings --output uuid --target /boot)

	if [ "${ROOT_UUID}" == "${BOOT_UUID}" ]; then
		# root UUID same as boot UUID, so do not modify the GRUB command-line or add boot arg to kernel command line
		# Correct the form of kernel command line for each installed kernel in the bootloader
		/sbin/grubby --update-kernel=ALL --args="fips=1"
	else
		# root UUID different from boot UUID, so modify the GRUB command-line and add boot arg to kernel command line
		if grep -q '^GRUB_CMDLINE_LINUX=".*boot=.*"'  /etc/default/grub; then
			# modify the GRUB command-line if a boot= arg already exists
			sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)boot=[^[:space:]]*\(.*"\)/\1 boot=UUID='"${BOOT_UUID} \2/" /etc/default/grub
		else
			# no existing boot=arg is present, append it
			sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)"/\1 boot=UUID='${BOOT_UUID}'"/'  /etc/default/grub
		fi
		# Correct the form of kernel command line for each installed kernel in the bootloader
		/sbin/grubby --update-kernel=ALL --args="fips=1 boot=UUID=${BOOT_UUID}"
	fi
	}

# Configure AIDE to Verify Access Control Lists (ACLs)
CCE-80375-9(){
	if ! rpm -q --quiet "aide" ; then
	    yum install -y "aide"
	fi

	aide_conf="/etc/aide.conf"

	groups=$(LC_ALL=C grep "^[A-Z]\+" $aide_conf | grep -v "^ALLXTRAHASHES" | cut -f1 -d '=' | tr -d ' ' | sort -u)

	for group in $groups
	do
		config=$(grep "^$group\s*=" $aide_conf | cut -f2 -d '=' | tr -d ' ')

		if ! [[ $config = *acl* ]]
		then
			if [[ -z $config ]]
			then
				config="acl"
			else
				config=$config"+acl"
			fi
		fi
		sed -i "s/^$group\s*=.*/$group = $config/g" $aide_conf
	done
	}

# Configure AIDE to Use FIPS 140-2 for Validating Hashes
CCE-80377-5(){
	if ! rpm -q --quiet "aide" ; then
	    yum install -y "aide"
	fi

	aide_conf="/etc/aide.conf"
	forbidden_hashes=(sha1 rmd160 sha256 whirlpool tiger haval gost crc32)

	groups=$(LC_ALL=C grep "^[A-Z]\+" $aide_conf | cut -f1 -d ' ' | tr -d ' ' | sort -u)

	for group in $groups
	do
		config=$(grep "^$group\s*=" $aide_conf | cut -f2 -d '=' | tr -d ' ')

		if ! [[ $config = *sha512* ]]
		then
			config=$config"+sha512"
		fi

		for hash in ${forbidden_hashes[@]}
		do
			config=$(echo $config | sed "s/$hash//")
		done

		config=$(echo $config | sed "s/^\+*//")
		config=$(echo $config | sed "s/\+\++/+/")
		config=$(echo $config | sed "s/\+$//")

		sed -i "s/^$group\s*=.*/$group = $config/g" $aide_conf
	done
	}

# Configure Notification of Post-AIDE Scan Details
CCE-80374-2(){
	if ! rpm -q --quiet "aide" ; then
	    yum install -y "aide"
	fi

	CRONTAB=/etc/crontab
	CRONDIRS='/etc/cron.d /etc/cron.daily /etc/cron.weekly /etc/cron.monthly'

	if [ -f /var/spool/cron/root ]; then
		VARSPOOL=/var/spool/cron/root
	fi

	if ! grep -qR '^.*\/usr\/sbin\/aide\s*\-\-check.*|.*\/bin\/mail\s*-s\s*".*"\s*root@.*$' $CRONTAB $VARSPOOL $CRONDIRS; then
		echo '0 5 * * * root /usr/sbin/aide  --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost' >> $CRONTAB
	fi
	}

# Remove User Host-Based Authentication Files
CCE-80514-3(){
	# Identify local mounts
	MOUNT_LIST=$(df --local | awk '{ print $6 }')

	# Find file on each listed mount point
	for cur_mount in ${MOUNT_LIST}
	do
		find ${cur_mount} -xdev -type f -name ".shosts" -exec rm -f {} \;
	done
	}

# Remove Host-Based Authentication Files
CCE-80513-5(){
	# Identify local mounts
	MOUNT_LIST=$(df --local | awk '{ print $6 }')

	# Find file on each listed mount point
	for cur_mount in ${MOUNT_LIST}
	do
		find ${cur_mount} -xdev -type f -name "shosts.equiv" -exec rm -f {} \;
	done
	}

# Uninstall telnet-server Package
CCE-27165-0(){
	# CAUTION: This remediation script will remove telnet-server
	#	   from the system, and may remove any packages
	#	   that depend on telnet-server. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "telnet-server" ; then
	    yum remove -y "telnet-server"
	fi
	}

# Uninstall tftp-server Package
CCE-80213-2(){
	# CAUTION: This remediation script will remove tftp-server
	#	   from the system, and may remove any packages
	#	   that depend on tftp-server. Execute this
	#	   remediation AFTER testing on a non-production
	#	   system!

	if rpm -q --quiet "tftp-server" ; then
	    yum remove -y "tftp-server"
	fi
	}

# Ensure Default SNMP Password Is Not Used 
CCE-27386-2(){
	if grep -s "public\|private" /etc/snmp/snmpd.conf | grep -qv "^#"; then
		sed -i "/^\s*#/b;/public\|private/ s/^/#/" /etc/snmp/snmpd.conf
	fi
	}

# Prevent Unrestricted Mail Relaying
CCE-80512-7(){
	if ! grep -q ^smtpd_client_restrictions /etc/postfix/main.cf; then
		echo "smtpd_client_restrictions = permit_mynetworks,reject" >> /etc/postfix/main.cf
	else
		sed -i "s/^smtpd_client_restrictions.*/smtpd_client_restrictions = permit_mynetworks,reject/g" /etc/postfix/main.cf
	fi
	}





# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# =============================================================== FUNCTION CALLS ===============================================================
# NOTE: Each STIG is a function with a corresponding ID (e.g. CCE-234584-3) 
# Declare the functions you wish to run against Red Hat Enterprise Linux 7.x
# =============================================================== FUNCTION CALLS ===============================================================


# Manual shell code
# Modify the System Login Banner for DoD use
login_banner_text="^(You[\s\n]+are[\s\n]+accessing[\s\n]+a[\s\n]+U\.S\.[\s\n]+Government[\s\n]+\(USG\)[\s\n]+Information[\s\n]+System[\s\n]+\(IS\)[\s\n]+that[\s\n]+is[\s\n]+provided[\s\n]+for[\s\n]+USG\-authorized[\s\n]+use[\s\n]+only\.[\s\n]+By[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+\(which[\s\n]+includes[\s\n]+any[\s\n]+device[\s\n]+attached[\s\n]+to[\s\n]+this[\s\n]+IS\)\,[\s\n]+you[\s\n]+consent[\s\n]+to[\s\n]+the[\s\n]+following[\s\n]+conditions\:(?:[\n]+|(?:\\n)+)\-The[\s\n]+USG[\s\n]+routinely[\s\n]+intercepts[\s\n]+and[\s\n]+monitors[\s\n]+communications[\s\n]+on[\s\n]+this[\s\n]+IS[\s\n]+for[\s\n]+purposes[\s\n]+including\,[\s\n]+but[\s\n]+not[\s\n]+limited[\s\n]+to\,[\s\n]+penetration[\s\n]+testing\,[\s\n]+COMSEC[\s\n]+monitoring\,[\s\n]+network[\s\n]+operations[\s\n]+and[\s\n]+defense\,[\s\n]+personnel[\s\n]+misconduct[\s\n]+\(PM\)\,[\s\n]+law[\s\n]+enforcement[\s\n]+\(LE\)\,[\s\n]+and[\s\n]+counterintelligence[\s\n]+\(CI\)[\s\n]+investigations\.(?:[\n]+|(?:\\n)+)\-At[\s\n]+any[\s\n]+time\,[\s\n]+the[\s\n]+USG[\s\n]+may[\s\n]+inspect[\s\n]+and[\s\n]+seize[\s\n]+data[\s\n]+stored[\s\n]+on[\s\n]+this[\s\n]+IS\.(?:[\n]+|(?:\\n)+)\-Communications[\s\n]+using\,[\s\n]+or[\s\n]+data[\s\n]+stored[\s\n]+on\,[\s\n]+this[\s\n]+IS[\s\n]+are[\s\n]+not[\s\n]+private\,[\s\n]+are[\s\n]+subject[\s\n]+to[\s\n]+routine[\s\n]+monitoring\,[\s\n]+interception\,[\s\n]+and[\s\n]+search\,[\s\n]+and[\s\n]+may[\s\n]+be[\s\n]+disclosed[\s\n]+or[\s\n]+used[\s\n]+for[\s\n]+any[\s\n]+USG\-authorized[\s\n]+purpose\.(?:[\n]+|(?:\\n)+)\-This[\s\n]+IS[\s\n]+includes[\s\n]+security[\s\n]+measures[\s\n]+\(e\.g\.\,[\s\n]+authentication[\s\n]+and[\s\n]+access[\s\n]+controls\)[\s\n]+to[\s\n]+protect[\s\n]+USG[\s\n]+interests\-\-not[\s\n]+for[\s\n]+your[\s\n]+personal[\s\n]+benefit[\s\n]+or[\s\n]+privacy\.(?:[\n]+|(?:\\n)+)\-Notwithstanding[\s\n]+the[\s\n]+above\,[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+does[\s\n]+not[\s\n]+constitute[\s\n]+consent[\s\n]+to[\s\n]+PM\,[\s\n]+LE[\s\n]+or[\s\n]+CI[\s\n]+investigative[\s\n]+searching[\s\n]+or[\s\n]+monitoring[\s\n]+of[\s\n]+the[\s\n]+content[\s\n]+of[\s\n]+privileged[\s\n]+communications\,[\s\n]+or[\s\n]+work[\s\n]+product\,[\s\n]+related[\s\n]+to[\s\n]+personal[\s\n]+representation[\s\n]+or[\s\n]+services[\s\n]+by[\s\n]+attorneys\,[\s\n]+psychotherapists\,[\s\n]+or[\s\n]+clergy\,[\s\n]+and[\s\n]+their[\s\n]+assistants\.[\s\n]+Such[\s\n]+communications[\s\n]+and[\s\n]+work[\s\n]+product[\s\n]+are[\s\n]+private[\s\n]+and[\s\n]+confidential\.[\s\n]+See[\s\n]+User[\s\n]+Agreement[\s\n]+for[\s\n]+details\.|I've[\s\n]+read[\s\n]+\&[\s\n]+consent[\s\n]+to[\s\n]+terms[\s\n]+in[\s\n]+IS[\s\n]+user[\s\n]+agreem't\.)$"

# Multiple regexes transform the banner regex into a usable banner
# 0 - Remove anchors around the banner text
login_banner_text=$(echo "$login_banner_text" | sed 's/^\^\(.*\)\$$/\1/g')
# 1 - Keep only the first banners if there are multiple
#    (dod_banners contains the long and short banner)
login_banner_text=$(echo "$login_banner_text" | sed 's/^(\(.*\)|.*)$/\1/g')
# 2 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
login_banner_text=$(echo "$login_banner_text" | sed 's/\[\\s\\n\]+/ /g')
# 3 - Adds newlines. (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "\n")
login_banner_text=$(echo "$login_banner_text" | sed 's/(?:\[\\n\]+|(?:\\n)+)/\n/g')
# 4 - Remove any leftover backslash. (From any parethesis in the banner, for example).
login_banner_text=$(echo "$login_banner_text" | sed 's/\\//g')
formatted=$(echo "$login_banner_text" | fold -sw 80)

cat <<EOF >/etc/issue
$formatted
EOF

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# GNOME Function Calls (NOTE: If the server is GUI-less, comment out these functions!)

# Enable GNOME3 Login Warning Banner
CCE-26970-4

# Set the GNOME3 Login Warning Banner Text 
CCE-26892-0

# Ensure Users Cannot Change GNOME3 Screensaver Settings
CCE-80371-8

# Enable GNOME3 Screensaver Idle Activation
CCE-80111-8

# Set GNOME3 Screensaver Inactivity Timeout
CCE-80110-0

# Ensure Users Cannot Change GNOME3 Session Idle Settings
CCE-80544-0

# Set GNOME3 Screensaver Lock Delay After Activation Period
CCE-80370-0

# Ensure Users Cannot Change GNOME3 Screensaver Lock After Idle Period
CCE-80563-0

# Enable GNOME3 Screensaver Lock After Idle Period
CCE-80112-6

# Ensure Users Cannot Change GNOME3 Screensaver Idle Activation
CCE-80564-8

# Disable GDM Automatic Login
CCE-80104-3

# Disable GDM Guest Login
CCE-80105-0

#=======================================================================================================================================================================================================
# The PAM system service can be configured to only store encrypted representations of passwords. 
# In /etc/pam.d/system-auth, the password section of the file controls which PAM modules execute during a password change. 
# Set the pam_unix.so module in the password section to include the argument sha512
CCE-82043-1

# To configure the system to lock out accounts after a number of incorrect login attempts and require an administrator
# to unlock the account using pam_faillock.so, modify the content of both /etc/pam.d/system-auth and /etc/pam.d/password-auth
CCE-26884-7

# Do not allow users to reuse recent passwords. This can be accomplished by using the remember option for the pam_unix or pam_pwhistory PAM modules.
CCE-82030-8

# To configure the system to lock out accounts after a number of incorrect login attempts using pam_faillock.so, modify the content of both /etc/pam.d/system-auth and /etc/pam.d/password-auth
CCE-27350-8

# The pam_pwquality module's minlen parameter controls requirements for minimum characters required in a password. Add minlen=14 after pam_pwquality to set minimum password length requirements.
CCE-27293-0

# The pam_pwquality module's dcredit parameter controls requirements for usage of digits in a password. When set to a negative number, any password will be required to contain that many digits.
# When set to a positive number, pam_pwquality will grant +1 additional length credit for each digit. Modify the dcredit setting in /etc/security/pwquality.conf to require the use of a digit in passwords.
CCE-27214-6

# The pam_pwquality module's lcredit parameter controls requirements for usage of lowercase letters in a password. When set to a negative number, any password will be required to contain that many
# lowercase characters. When set to a positive number, pam_pwquality will grant +1 additional length credit for each lowercase character. Modify the lcredit setting in /etc/security/pwquality.conf
# to require the use of a lowercase character in passwords.
CCE-27345-8

# The pam_pwquality module's ucredit= parameter controls requirements for usage of uppercase letters in a password. When set to a negative number, any password will be required to contain that many uppercase
# characters. When set to a positive number, pam_pwquality will grant +1 additional length credit for each uppercase character. Modify the ucredit setting in /etc/security/pwquality.conf to require the use
# of an uppercase character in passwords.
CCE-27200-5

# To configure the number of retry prompts that are permitted per-session: Edit the pam_pwquality.so statement in /etc/pam.d/system-auth to show retry=3, or a lower value if site policy is more restrictive.
# The DoD requirement is a maximum of 3 prompts per session.
CCE-27160-1

# Single-user mode is intended as a system recovery method, providing a single user root access to the system by providing a boot option at startup. By default, no authentication is performed if single-user mode is selected.
# By default, single-user mode is protected by requiring a password and is set in /usr/lib/systemd/system/rescue.service.
CCE-27287-2

# Ensure the Default Bash Umask is Set Correctly
CCE-80202-5

# Ensure the Default Umask is Set Correctly in /etc/profile
CCE-80204-1

# Set Password Warning Age
CCE-82016-7

# Set Password Minimum Age
CCE-82036-5

# Set Password Maximum Age
CCE-27051-2

# Verify Only Root Has UID 0
CCE-82054-8

# Set Account Expiration Following Inactivity
CCE-27355-7

# Configure auditd Max Log File Size
CCE-27319-3

# Configure auditd mail_acct Action on Low Disk Space 
CCE-27394-6

# Configure auditd admin_space_left Action on Low Disk Space
CCE-27370-6

# Configure auditd max_log_file_action Upon Reaching Maximum Log Size
CCE-27231-0

# Ensure auditd Collects Information on Kernel Module Loading and Unloading
CCE-27129-6

# Record Attempts to Alter Logon and Logout Events
CCE-27204-7

# Record Attempts to Alter Time Through stime
CCE-27299-7

# Record attempts to alter time through settimeofday
CCE-27216-1

# Record Attempts to Alter the localtime File
CCE-27310-2

# Record Attempts to Alter Time Through clock_settime
CCE-27219-5

# Record attempts to alter time through adjtimex
CCE-27290-6

# Record Events that Modify the System's Discretionary Access Controls - fchown
CCE-27356-5

# Record Events that Modify the System's Discretionary Access Controls - setxattr
CCE-27213-8

# Record Events that Modify the System's Discretionary Access Controls - chown
CCE-27364-9

# Record Events that Modify the System's Discretionary Access Controls - fchownat
CCE-27387-0

# Record Events that Modify the System's Discretionary Access Controls - chmod
CCE-27339-1

# Record Events that Modify the System's Discretionary Access Controls - removexattr
CCE-27367-2

# Record Events that Modify the System's Discretionary Access Controls - fchmod
CCE-27393-8

# Record Events that Modify the System's Discretionary Access Controls - lsetxattr
CCE-27280-7

# Record Events that Modify the System's Discretionary Access Controls - fremovexattr
CCE-27353-2

# Record Events that Modify the System's Discretionary Access Controls - lchown
CCE-27083-5

# Record Events that Modify the System's Discretionary Access Controls - fsetxattr
CCE-27389-6

# Record Events that Modify the System's Discretionary Access Controls - fchmodat
CCE-27388-8

# Record Events that Modify the System's Discretionary Access Controls - lremovexattr
CCE-27410-0

# Record Unsuccessful Access Attempts to Files - truncate
CCE-80389-0

# Record Unsuccessful Access Attempts to Files - creat
CCE-80385-8

# Record Unsuccessful Access Attempts to Files - open
CCE-80386-6

# Record Unsuccessful Access Attempts to Files - open_by_handle_at
CCE-80388-2

# Record Unsuccessful Access Attempts to Files - ftruncate
CCE-80390-8

# Record Unsuccessful Access Attempts to Files - openat
CCE-80387-4

# Ensure auditd Collects File Deletion Events by User - rmdir
CCE-80412-0

# Ensure auditd Collects File Deletion Events by User - unlinkat
CCE-80662-0

# Ensure auditd Collects File Deletion Events by User - rename
CCE-80995-4

# Ensure auditd Collects File Deletion Events by User - renameat
CCE-80413-8

# Ensure auditd Collects File Deletion Events by User - unlink
CCE-80996-2

# Ensure auditd Collects Information on the Use of Privileged Commands - passwd
CCE-80395-7

# Ensure auditd Collects Information on the Use of Privileged Commands - sudo
CCE-80401-3

# Ensure auditd Collects Information on the Use of Privileged Commands - postdrop
CCE-80406-2

# Ensure auditd Collects Information on the Use of Privileged Commands - chsh
CCE-80404-7

# Ensure auditd Collects Information on the Use of Privileged Commands - gpasswd
CCE-80397-3

# Ensure auditd Collects Information on the Use of Privileged Commands - chage 
CCE-80398-1

# Ensure auditd Collects Information on the Use of Privileged Commands - userhelper
CCE-80399-9

# Ensure auditd Collects Information on the Use of Privileged Commands - pam_timestamp_check
CCE-80411-2

# Ensure auditd Collects Information on the Use of Privileged Commands - crontab
CCE-80405-4

# Ensure auditd Collects Information on the Use of Privileged Commands - unix_chkpwd
CCE-80396-5

# Ensure auditd Collects Information on the Use of Privileged Commands - ssh-keysign
CCE-80408-8

# Ensure auditd Collects Information on the Use of Privileged Commands - sudoedit
CCE-80402-1

# Ensure auditd Collects Information on the Use of Privileged Commands - postqueue
CCE-80407-0

# Ensure auditd Collects Information on the Use of Privileged Commands - su
CCE-80400-5

# Ensure auditd Collects Information on the Use of Privileged Commands - newgrp
CCE-80403-9

# Ensure auditd Collects Information on the Use of Privileged Commands
CCE-27437-3

# Ensure auditd Collects System Administrator Actions
CCE-27461-3

# Record Events that Modify the System's Network Environment
CCE-27076-9

# Make the auditd Configuration Immutable
CCE-27097-5

# Record Events that Modify User/Group Information - /etc/shadow
CCE-80431-0

# Record Attempts to Alter Process and Session Initiation Information
CCE-27301-1

# Ensure auditd Collects Information on Exporting to Media (successful)
CCE-27447-2

# Record Events that Modify User/Group Information - /etc/security/opasswd
CCE-80430-2

# Record Events that Modify the System's Mandatory Access Controls
CCE-27168-4

# Record Events that Modify User/Group Information - /etc/gshadow
CCE-80432-8

# Record Events that Modify User/Group Information - /etc/passwd
CCE-80435-1

# Record Events that Modify User/Group Information - /etc/group
CCE-80433-6

# Enable auditd Service
CCE-27407-6

# Enable Auditing for Processes Which Start Prior to the Audit Daemon
CCE-27212-0

# Ensure Logs Sent To Remote Host
CCE-27343-3

# Ensure Logrotate Runs Periodically
CCE-80195-1

# Ensure System Log Files Have Correct Permissions
CCE-80191-0

# Ensure rsyslog is Installed
CCE-80187-8

# Enable rsyslog Service
CCE-80188-6

# Disable IPv6 Networking Support Automatic Loading
CCE-80175-3

# Disable Accepting ICMP Redirects for All IPv6 Interfaces
CCE-80182-9

# Disable Accepting Router Advertisements on all IPv6 Interfaces by Default
CCE-80181-1

# Configure Accepting Router Advertisements on All IPv6 Interfaces
CCE-80180-3

# Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv6 Interfaces
CCE-80183-7

# Disable Kernel Parameter for Accepting Source-Routed Packets on IPv4 Interfaces by Default 
CCE-80162-1

# Enable Kernel Parameter to Ignore Bogus ICMP Error Responses on IPv4 Interfaces
CCE-80166-2

# Enable Kernel Parameter to Ignore ICMP Broadcast Echo Requests on IPv4 Interfaces
CCE-80165-4

# Disable Kernel Parameter for Accepting ICMP Redirects by Default on IPv4 Interfaces
CCE-80163-9

# Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces by Default 
CCE-80168-8

# Disable Kernel Parameter for Accepting Secure ICMP Redirects on all IPv4 Interfaces
CCE-80159-7

# Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv4 Interfaces
CCE-27434-0

# Disable Accepting ICMP Redirects for All IPv4 Interfaces
CCE-80158-9

# Enable Kernel Parameter to Log Martian Packets on all IPv4 Interfaces
CCE-80160-5

# Enable Kernel Parameter to Use Reverse Path Filtering on all IPv4 Interfaces
CCE-80167-0

# Configure Kernel Parameter for Accepting Secure Redirects By Default
CCE-80164-7

# Enable Kernel Parameter to Use TCP Syncookies on IPv4 Interfaces
CCE-27495-1

# Enable Kernel Paremeter to Log Martian Packets on all IPv4 Interfaces by Default
CCE-80161-3

# Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces
CCE-80156-3

# Disable Kernel Parameter for Sending ICMP Redirects on all IPv4 Interfaces by Default
CCE-80999-6

# Disable DCCP Support
CCE-82024-1

# Disable SCTP Support
CCE-82044-9

# Verify /boot/grub2/grub.cfg User Ownership
CCE-82026-6

# Verify /boot/grub2/grub.cfg Permissions
CCE-82039-9

# Verify /boot/grub2/grub.cfg Group Ownership
CCE-82023-3

# Uninstall setroubleshoot Package
CCE-80444-3

# Ensure SELinux Not Disabled in /etc/default/grub 
CCE-26961-3

# Configure SELinux Policy
CCE-27279-9

# Ensure SELinux State is Enforcing
CCE-27334-2

# Verify User Who Owns group File
# Verify Permissions on group File
# Verify Group Who Owns shadow File
# Verify Permissions on shadow File
# Verify Group Who Owns gshadow File
# Verify User Who Owns passwd File
# Verify User Who Owns gshadow File
# Verify Group Who Owns group File
# Verify Permissions on passwd File
# Verify User Who Owns shadow File 
# Verify Permissions on gshadow File
# Verify Group Who Owns passwd File
CCE-82031-6_CCE-82032-4_CCE-82051-4_CCE-82042-3_CCE-82025-8_CCE-82052-2_CCE-82195-9_CCE-82037-3_CCE-82029-0_CCE-82022-5_CCE-82192-6_CCE-26639-5

# Verify that All World-Writable Directories Have Sticky Bits Set
CCE-80130-8

# Disable the Automounter
CCE-27498-5

# Disable Mounting of freevxfs
CCE-80138-1

# Disable Mounting of cramfs
CCE-80137-3

# Disable Mounting of squashfs
CCE-80142-3

# Disable Mounting of jffs2
CCE-80139-9

# Disable Mounting of hfsplus 
CCE-80141-5

# Disable Mounting of hfs
CCE-80140-7

# Disable Mounting of udf 
CCE-80143-1

# Add noexec Option to /dev/shm
CCE-80153-0

# Add nodev Option to /tmp
CCE-80149-8

# Add nosuid Option to /tmp
CCE-80151-4

# Add nodev Option to Removable Media Partitions
CCE-80146-4

# Add nodev Option to /home
CCE-81047-3

# Add nosuid Option to /var/tmp
CCE-82153-8

# Add nodev Option to /dev/shm 
CCE-80152-2

# Add nosuid Option to /dev/shm
CCE-80154-8

# Add noexec Option to /tmp
CCE-80150-6

# Add nodev Option to /var/tmp
CCE-81052-3

# Add nosuid Option to Removable Media Partitions
CCE-80148-0

# Add noexec Option to Removable Media Partitions
CCE-80147-2

# Add noexec Option to /var/tmp
CCE-82150-4

# Disable Core Dumps for SUID programs
CCE-26900-1

# Disable Core Dumps for All Users
CCE-80169-6

# Enable ExecShield via sysctl
CCE-27211-2

# Enable Randomized Layout of Virtual Address Space
CCE-27127-0

# Install AIDE
CCE-27096-7

# Configure Periodic Execution of AIDE
CCE-26952-2

# Disable Prelinking
CCE-27078-5

# Ensure gpgcheck Enabled In Main yum Configuration
CCE-26989-4

# Disable rlogin Service
CCE-27336-7

# Disable rexec Service
CCE-27408-4

# Disable rsh Service
CCE-27337-5

# Remove Rsh Trust Files
CCE-27406-8

# Remove telnet Clients
CCE-27305-2

# Disable telnet Service
CCE-27401-9

# Remove NIS Client 
CCE-27396-1

# Uninstall ypserv Package
CCE-27399-5

# Disable tftp Service
CCE-80212-4

# Install tcp_wrappers Package
CCE-27361-5

# Disable xinetd Service
CCE-27443-1

# Uninstall talk Package
CCE-27432-4

# Uninstall talk-server Package
CCE-27210-4

# Disable vsftpd Service
CCE-80244-7

# Disable snmpd Service
CCE-80274-4

# Crontab settings
crontaby

# Disable Samba
CCE-80277-7

# Enable the NTP Daemon
CCE-27444-9

# Disable Red Hat Network Service (rhnsd) 
CCE-80269-4

# Disable DHCP Service
CCE-80330-4

# Disable SSH Access via Empty Passwords
CCE-27471-2

# Set SSH Client Alive Max Count
CCE-27082-7

# Enable SSH Warning Banner 
CCE-27314-4

# Use Only FIPS 140-2 Validated MACs
CCE-27455-5

# SSH Hardening Configurations
hardenssh

#Set Password Hashing Algorithm in /etc/login.defs
CCE-82050-6

# Set Password Hashing Algorithm in /etc/libuser.conf
CCE-82038-1

# Configure the root Account for Failed Password Attempts
CCE-80353-6

# Ensure PAM Enforces Password Requirements - Maximum Consecutive Repeating Characters from Same Character Class 
CCE-27512-3

# Set Password Maximum Consecutive Repeating Characters 
CCE-82055-5

# Ensure PAM Enforces Password Requirements - Minimum Different Characters
CCE-82020-9

# Ensure PAM Enforces Password Requirements - Minimum Special Characters
CCE-27360-7

# Ensure PAM Displays Last Logon/Access Notification
CCE-27275-7

# Install the screen Package
# Install Smart Card Packages For Multifactor Authentication
# Install the tmux Package
CCE-27351-6_CCE-80519-2_

# Disable Ctrl-Alt-Del Reboot Activation
CCE-27511-5

# Ensure the Default Umask is Set Correctly in login.defs
CCE-80205-8

# Set Interactive Session Timeou
CCE-27557-8

# Ensure Home Directories are Created for New Users
CCE-80434-4

# Ensure the Logon Failure Delay is Set Correctly in login.defs
CCE-80352-8

# Limit the Number of Concurrent Login Sessions Allowed Per User
CCE-82041-5

# Prevent Login to Accounts With Empty Password
CCE-27286-4

# Encrypt Audit Records Sent With audispd Plugin
CCE-80540-8

# Configure auditd space_left on Low Disk Space
CCE-80537-4

# Ensure auditd Collects Information on Kernel Module Loading and Unloading - finit_module
CCE-80547-3

# Ensure auditd Collects Information on Kernel Module Loading - init_module
CCE-80414-6

# Ensure auditd Collects Information on Kernel Module Unloading - delete_module
CCE-80415-3

# Record Attempts to Alter Logon and Logout Events - lastlog
CCE-80384-1

# Record Attempts to Alter Logon and Logout Events - faillock
CCE-80383-3

# Record Attempts to Alter Logon and Logout Events - tallylog
CCE-80994-7

# Record Any Attempts to Run setfiles
CCE-80660-4

# Record Any Attempts to Run setsebool
CCE-80392-4

# Record Any Attempts to Run semanage
CCE-80391-6

# Record Any Attempts to Run chcon
CCE-80393-2

# Shutdown System When Auditing Failures Occur
CCE-80997-0

# Ensure cron Is Logging To Rsyslog
CCE-80380-9

# Verify firewalld Enabled
CCE-80998-8

# Configure firewalld To Rate Limit Connections
CCE-80542-4

# Disable Kernel Parameter for Accepting Source-Routed Packets on all IPv6 Interfaces
CCE-80179-5

# Enable FIPS mode
fips_enabled

# Configure AIDE to Verify Access Control Lists (ACLs)
CCE-80375-9

# Configure AIDE to Use FIPS 140-2 for Validating Hashes
CCE-80377-5

# Configure Notification of Post-AIDE Scan Details
CCE-80374-2

# Remove User Host-Based Authentication Files
CCE-80514-3

# Remove Host-Based Authentication Files
CCE-80513-5

# Uninstall telnet-server Package
CCE-27165-0

# Uninstall tftp-server Package
CCE-80213-2

# Ensure tftp Daemon Uses Secure Mode
CCE-80214-0

# Ensure Default SNMP Password Is Not Used 
CCE-27386-2

# Prevent Unrestricted Mail Relaying
CCE-80512-7

echo "
         =========================================================================
         !!!!!!!!!!!!!!! Rebooting system for configs to take place !!!!!!!!!!!!!!
         60 Second Delay Starting...
         [NOTE] To cancel shutdown, enter this command: shutdown -c
         ========================================================================="

shutdown -r -t 00:01
