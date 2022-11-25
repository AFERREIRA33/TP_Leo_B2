FROM debian

RUN apt update -y

RUN apt install apache2 -y

RUN echo "yo" > /var/www/html/index.html

COPY apache2.conf /etc/apache2/

RUN mkdir /etc/apache2/logs

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]