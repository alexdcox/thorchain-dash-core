FROM dashpay/dashd:0.16.1.1
USER root
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y jq curl iputils-ping net-tools vim
USER dash:1000
COPY ./scripts /scripts
EXPOSE 9998 9999 19998 19999 19898 19899 28332
CMD ["dashd"]