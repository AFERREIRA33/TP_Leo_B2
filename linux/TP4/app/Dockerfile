FROM python:latest

RUN pip3 netifaces

RUN pip3 install scapy

RUN pip3 install netaddr

COPY Scanner_reseau/scannerreseau.py ./

CMD ["python3", "./scannerreseau.py"]