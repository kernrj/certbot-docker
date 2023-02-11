#!/bin/bash -e

set -o pipefail

function handleSig {
    echo "Stopping certbot..."
    pkill sleep
}

trap handleSig SIGINT SIGTERM SIGQUIT SIGHUP

if [ "$CERT_DOMAIN" == "" ]; then
    echo "Specify the name of the domain to fetch a certificate for by setting the CERT_DOMAIN environment variable." >&2
    exit 1
fi

if [ "$CERT_EMAIL" == "" ]; then
    echo "An email needs to be specified for important account information. Set the CERT_EMAIL environment variable." >&2
    exit 1
fi

if [ "$(echo "$AGREE_TOS" | tr '[:upper:]' '[:lower:]')" != "yes" ]; then
    echo "To agree to the certbot terms of service, specify the environment variable AGREE_TOS=yes" >&2
    exit 1
fi

if [ -f "/etc/letsencrypt/volume_was_not_mapped" ]; then
    echo "A writeable volume needs to be mapped to /etc/letsencrypt." >&2
    exit 1
fi

if [ $(ls -1 /etc/letsencrypt/accounts | wc -l) -eq 0 ]; then
    echo "Creating account for $CERT_EMAIL"

    certbot \
	register \
	-n \
	--agree-tos \
	-m "$CERT_EMAIL"
fi

if [ ! -d "/etc/letsencrypt/archive/$CERT_DOMAIN" ]; then
    echo "Creating initial certificate for $CERT_DOMAIN"

    certbot \
	certonly \
	--agree-tos \
	-m "$CERT_EMAIL" \
	-n \
	--standalone \
	--preferred-challenges http \
	-d "$CERT_DOMAIN" ||
	{
            sleep 600 & 
	    wait $!;
            exit 1;
        }
else
    echo "Renewing certificate for $CERT_DOMAIN"
    certbot renew -n    
fi

readonly SECONDS_IN_THIRTY_DAYS=2592000

if [ "$RENEWAL_PERIOD" == "" ]; then
    RENEWAL_PERIOD=$SECONDS_IN_THIRTY_DAYS
fi

echo "Renewal period (seconds): $RENEWAL_PERIOD"

while true; do
    sleep $RENEWAL_PERIOD &
    wait $!

    date
    echo "Renewing certificate for $CERT_DOMAIN"
    certbot renew -n
done
