<div align="center">
  <img src="https://git.lgbt/gitlgbt/branding/raw/branch/main/svg/gitlgbtinfra.svg" alt="gitlgbt infra Logo" width="192" />
  <h1>gitlgbt/Infa</h1>
  <p><strong>Infrastructure deploy code for <a href="https://git.lgbt">git.lgbt</a></strong></p>
</div>

# gitlgbt Infrastructure
this is an deploy file for gitlgbt

install git and clone this repo
```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/gitlgbt/infa.git
cd infa
```

install git.lgbt
```bash
chmod +x update.sh
chmod +x install.sh
./install.sh
```

update git.lgbt
```bash
./update.sh
```
install page will be at
<br>
[http://127.0.0.1:3001/](http://127.0.0.1:3001/)

you can point tunnel or proxy manager to 
```bash
http://serverip:3001/
```

to stop the server
```bash
docker stop $(docker ps -q)
```

user data will be at `forgejo-data` DO NOT DELETE IT

---
<br>
<div align="center">
  <img src="https://raw.githubusercontent.com/gitlgbt/forgejo/refs/heads/main/assets/Fryrvo%20pride.svg" alt="Fryrvo Pride Logo" width="70" />
  <p><em>Currently Hosted at Fryrvo</em></p>
</div>