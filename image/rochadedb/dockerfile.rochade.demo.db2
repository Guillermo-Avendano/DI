# Author: Guilllermo Avendaño
# Creation Date: 11/24/2023
# md5 control added 02/07/2024
FROM busybox

ARG DB=d2
COPY  ./datbas_demo/${DB}.tar.gz ./root/${DB}.tar.gz

# Copy startup.sh script
COPY ./startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

ENV DB=${DB}

WORKDIR /root

# Default command to execute when the image is started
CMD ["sh", "-c", ". ./startup.sh"]

