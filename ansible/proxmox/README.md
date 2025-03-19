Nejprve desifrujte soubor secrets.yaml obsahujici udaje potrebene ke spusteni skriptu.
```
ansible-vault decrypt secrets.yaml
```

## Backup skript
spousteni:
```
ansible-playbook backup_vms.yaml --extra-vars "px_vmid=<ID virtualniho stroje> apihost=<ip adresa serveru proti, kteremu skript pobezi>" --tags "<backupVMs nebo snapshotVM>"
```

## Power skript

startovani/stopovani vsech virtualnich stroju
```
ansible-playbook vm_power.yaml --extra-vars "apihost=<ip adresa serveru proti, kteremu skript pobezi>" --tags "<startVMs nebo stopVMs>"
```

startovani/stopvani daneho virtualniho stroje
```
ansible-playbook vm_power.yaml --extra-vars "apihost=<ip adresa serveru proti, kteremu skript pobezi> px_vmid=<ID virtualniho stroje> px_node=<jmeno serveru na kterem virtualni stroj bezi>" --tags "<startVM nebo stopVMs"
```