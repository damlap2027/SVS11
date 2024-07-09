# Snakeoil

## TODO
* In der [Dockerfile](Dockerfile) die Variable CI_PROJECT_NAME dem Teamnamen anpassen.
* In der [authorized_keys](authorized_keys) die eigenen SSH Public Keys hinterlegen.
* Die Datei [apache2-user-config.conf](apache2-user-config.conf) möchte um HTTPS-Einstellungen erweitert werden.
* Es empfiehlt sich alle notwendigen Prozeduren in einem Script zu verfassen. Dafür ist die [autorun.sh](userdata/autorun.sh) gedacht, welche beim Imagebau ausgeführt wird.

## DON'T in der VM
* **NICHT** in der Datei [authorized_keys](authorized_keys) den vorhandenen Public Key entfernen 
* **NICHT** die Ports verändern
* **NICHT** den SSHD weiter absichern wollen
* **NICHT** per Firewall aussperren

## Hilfestellung / CheatSheet
### Image bauen
```bash
# cd $ORDER_MIT_Dockerfile
docker build -t snakeoil:latest .
```

### Image im Container starten
```bash
docker run -d -p 80:80 -p 443:443 -p 127.0.0.1:2222:222 --name snakeoil snakeoil:latest 
``` 

### Terminal im Container verwenden
```bash
docker exec -ti snakeoil bash -c 'cd "/userdata/webportal" && echo Hallo ${CI_PROJECT_NAME} && bash' 
``` 

### Container stoppen
```bash
docker stop snakeoil
```

### Container löschen
```bash
docker rm snakeoil
```

### Images löschen / Speicherplatz schaffen
```bash
# Vorhandene Images listen
docker images
# Ausgewähltes Image löschen
docker rmi $IMAGE_ID
```
