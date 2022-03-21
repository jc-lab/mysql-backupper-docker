#!/bin/bash

mkdir -p $HOME/.ssh/

PRIV_KEY_FILE="/root/.ssh/default_private_key"

if [[ -z "$BACKUP_FILE" ]]; then
	echo "No provided BACKUP_FILE"
	exit 1
fi

if [[ -n "$SSH_KEY_FILE" && -e "$SSH_KEY_FILE" ]]; then
	perm=$(stat -c '%a' "$SSH_KEY_FILE")
	if [[ "$perm" != "400" ]]; then
		cp "$SSH_KEY_FILE" "$PRIV_KEY_FILE"
		chmod 400 "$PRIV_KEY_FILE"
	else
		PRIV_KEY_FILE="$SSH_KEY_FILE"
	fi
elif [[ -n "$SSH_KEY_DATA" ]]; then
	echo "$SSH_KEY_DATA" > "$PRIV_KEY_FILE"
	chmod 400 "$PRIV_KEY_FILE"
else
	echo "No provided private key"
	exit 1
fi

KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"

if [[ -n "$SSH_KNOWN_HOSTS_FILE" && -e "$SSH_KNOWN_HOSTS_FILE" ]]; then
	if [[ "$SSH_KNOWN_HOSTS_FILE" != "$HOME/.ssh/known_hosts" ]]; then
		cp "$SSH_KNOWN_HOSTS_FILE" "$KNOWN_HOSTS_FILE"
		chmod 400 "$KNOWN_HOSTS_FILE"
	fi
elif [[ -n "$SSH_KNOWN_HOSTS_DATA" ]]; then
	echo "$SSH_KNOWN_HOSTS_DATA" > "$KNOWN_HOSTS_FILE"
	chmod 400 "$KNOWN_HOSTS_FILE"
else
	echo "No provided known_hosts"
	exit 1
fi

echo "" >> $PRIV_KEY_FILE || true
scp -i "$PRIV_KEY_FILE" $BACKUP_FILE $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH
rc=$?

exit $rc

