# SVS11
## Security in Distributed System
Prepare the cert.sh Script:

Ensure cert.sh is executable and placed in the directory where you will build the Docker image. Create the Dockerfile:

The Dockerfile will set up an Apache web server, copy the necessary files, run cert.sh to generate certificates, and configure Apache with apache2-user-config.conf. Prepare the apache2-user-config.conf:

This file contains your Apache configuration and will be copied into the appropriate directory in the Docker container.
