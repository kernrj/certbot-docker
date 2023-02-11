This creates and renews a certficate for a single domain.

This image is designed for use when port 80 is free. It's meant for email, https-only, etc servers.

Required environment variables:
- CERT_DOMAIN - set this to the domain to obtain the certificate for.
- CERT_EMAIL - used for Let's Encrypt registration.
- AGREE_TOS - set this to "yes" if you agree to certbot's terms of service.

Optional environment variables:
- RENEWAL_PERIOD - the number of seconds between renewals. The default renewal period is 30 days (the number of seconds in 30 days).

An external, wrieable directory must be mapped to /etc/letsencrypt. Keys and certs are stored here.

Port 80 on the host needs to be mapped to port 80 in the container.

Example docker command:
```
docker run \
    -p 80:80 \
    -e AGREE_TOS=yes \
    -e CERT_DOMAIN=www.example.com \
    -e CERT_EMAIL=email@example.com \
    -v $(pwd)/letsencrypt:/etc/letsencrypt \
    -it kernrj/certbot
```

Example docker-compose.yml:
```
version: '2'
services:
    certbot:
        image: kernrj/certbot
	ports:
	  - 80:80
	volumes:
	    - type: bind
	      source: /etc/letsencrypt
	      target: /etc/letsencrypt
	environment:
	    - CERT_DOMAIN=example.com
	    - CERT_EMAIL=your_email@example.com
	    - AGREE_TOS=yes  # Specifying "yes" means you agree to the terms of service in the certbot application in the container being launched. This is equivalent to `certbot --agree-tos`.
```
