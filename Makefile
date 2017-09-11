.PHONY: up down log tinker artisan test

# Set dir of Makefile to a variable to use later
MAKEPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := $(dir $(MAKEPATH))

up:
	docker-compose up -d

down:
	docker-compose down

# Modified From http://bytefreaks.net/gnulinux/bash/tail-logs-with-color-for-monolog
log:
	tail -f $(PWD)application/storage/logs/laravel.log | awk '\
		{matched=0}\
		/INFO:/    {matched=1; print "\033[0;37m" $$0 "\033[0m"}\
		/WARNING:/ {matched=1; print "\033[0;34m" $$0 "\033[0m"}\
		/ERROR:/   {matched=1; print "\033[0;31m" $$0 "\033[0m"}\
		/Next/     {matched=1; print "\033[0;31m" $$0 "\033[0m"}\
		/ALERT:/   {matched=1; print "\033[0;35m" $$0 "\033[0m"}\
		/Stack trace:/ {matched=1; print "\033[0;35m" $$0 "\033[0m"}\
		matched==0            {print "\033[0;33m" $$0 "\033[0m"}\
	'

tinker:
	docker run -it --rm \
		-e "HOME=/home" \
		-v $(PWD).tinker:/home/.config \
		-v $(PWD)application:/opt \
		-w /opt \
		--network=phpapp_appnet \
		shippingdocker/php:latest \
		php artisan tinker

ART=""
artisan:
	docker run -it --rm \
		-e "HOME=/home" \
		-v $(PWD).tinker:/home/.config \
		-v $(PWD)application:/opt \
		-w /opt \
		--network=phpapp_appnet \
		shippingdocker/php:latest \
		php artisan $(ART)

test:
	docker run -it --rm \
		-v $(PWD)application:/opt \
		-w /opt \
		--network=phpapp_appnet \
		shippingdocker/php:latest \
		./vendor/bin/phpunit
