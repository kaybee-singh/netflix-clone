- You can create the container file with this command and enjoy.
```bash
podman build -t netflix-clone -f Containerfile .
```
- Then run the container
```bash
podman run -d -p 8080:80 netflix-clone
```
