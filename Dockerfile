# Use official PHP + Apache image
FROM php:8.1-apache

# Copy your PHP source code into Apache's web root
COPY ./src/ /var/www/html/

# Expose port 80 for HTTP traffic
EXPOSE 80
