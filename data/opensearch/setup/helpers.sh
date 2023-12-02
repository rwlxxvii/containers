#!/usr/bin/env bash

# Log a message.
function log {
	echo "[+] $1"
}

# Log a message at a sub-level.
function sublog {
	echo "   ⠿ $1"
}

# Log an error.
function err {
	echo "[x] $1" >&2
}

# Log an error at a sub-level.
function suberr {
	echo "   ⠍ $1" >&2
}

# Poll the 'opensearch' service until it responds with HTTP code 200.
function wait_for_opensearch {
	local opensearch_host="${OPENSEARCH_HOST:-opensearch}"

	local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}' "http://${opensearch_host}:9200/" )

	if [[ -n "${OPENSEARCH_PASSWORD:-}" ]]; then
		args+=( '-u' "opensearch:${OPENSEARCH_PASSWORD}" )
	fi

	local -i result=1
	local output

	# retry for max 300s (60*5s)
	for _ in $(seq 1 60); do
		local -i exit_code=0
		output="$(curl "${args[@]}")" || exit_code=$?

		if ((exit_code)); then
			result=$exit_code
		fi

		if [[ "${output: -3}" -eq 200 ]]; then
			result=0
			break
		fi

		sleep 5
	done

	if ((result)) && [[ "${output: -3}" -ne 000 ]]; then
		echo -e "\n${output::-3}"
	fi

	return $result
}

# Verify that the given OpenSearch user exists.
function check_user_exists {
	local username=$1

	local opensearch_host="${OPENSEARCH_HOST:-opensearch}"

	local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
		"http://${opensearch_host}:9200/_plugins/_security/api/internalusers/${username}"
		)

	if [[ -n "${OPENSEARCH_PASSWORD:-}" ]]; then
		args+=( '-u' "opensearch:${OPENSEARCH_PASSWORD}" )
	fi

	local -i result=1
	local -i exists=0
	local output

	output="$(curl "${args[@]}")"
	if [[ "${output: -3}" -eq 200 || "${output: -3}" -eq 404 ]]; then
		result=0
	fi
	if [[ "${output: -3}" -eq 200 ]]; then
		exists=1
	fi

	if ((result)); then
		echo -e "\n${output::-3}"
	else
		echo "$exists"
	fi

	return $result
}

# Set password of a given OpenSearch user.
function set_user_password {
	local username=$1
	local password=$2

	local opensearch_host="${OPENSEARCH_HOST:-opensearch}"

	local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
		"http://${opensearch_host}:9200/_plugins/_security/api/internalusers/${username}/_password"
		'-X' 'POST'
		'-H' 'Content-Type: application/json'
		'-d' "{\"password\" : \"${password}\"}"
		)

	if [[ -n "${OPENSEARCH_PASSWORD:-}" ]]; then
		args+=( '-u' "opensearch:${OPENSEARCH_PASSWORD}" )
	fi

	local -i result=1
	local output

	output="$(curl "${args[@]}")"
	if [[ "${output: -3}" -eq 200 ]]; then
		result=0
	fi

	if ((result)); then
		echo -e "\n${output::-3}\n"
	fi

	return $result
}

# Create the given OpenSearch user.
function create_user {
	local username=$1
	local password=$2
	local role=$3

	local opensearch_host="${OPENSEARCH_HOST:-opensearch}"

	local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
		"http://${opensearch_host}:9200/_plugins/_security/api/internalusers/${username}"
		'-X' 'POST'
		'-H' 'Content-Type: application/json'
		'-d' "{\"password\":\"${password}\",\"roles\":[\"${role}\"]}"
		)

	if [[ -n "${OPENSEARCH_PASSWORD:-}" ]]; then
		args+=( '-u' "opensearch:${OPENSEARCH_PASSWORD}" )
	fi

	local -i result=1
	local output

	output="$(curl "${args[@]}")"
	if [[ "${output: -3}" -eq 200 ]]; then
		result=0
	fi

	if ((result)); then
		echo -e "\n${output::-3}\n"
	fi

	return $result
}

# Ensure that the given OpenSearch role is up-to-date, create it if required.
function ensure_role {
	local name=$1
	local body=$2

	local opensearch_host="${OPENSEARCH_HOST:-opensearch}"

	local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
		"http://${opensearch_host}:9200/_plugins/_security/api/roles/${name}"
		'-X' 'POST'
		'-H' 'Content-Type: application/json'
		'-d' "$body"
		)

	if [[ -n "${OPENSEARCH_PASSWORD:-}" ]]; then
		args+=( '-u' "opensearch:${OPENSEARCH_PASSWORD}" )
	fi

	local -i result=1
	local output

	output="$(curl "${args[@]}")"
	if [[ "${output: -3}" -eq 200 ]]; then
		result=0
	fi

	if ((result)); then
		echo -e "\n${output::-3}\n"
	fi

	return $result
}
