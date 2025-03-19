## Create namespace skript
```
ansible-playbook create_namespace.yaml --extra-vars "ns_name=<jmenny prostor>"
```

## Create services skript

```
ansible-playbook create_services.yaml --extra-vars "app=<jmeno aplikace> target_port=<cileny port>" --tags "clusterip | nodeport | loadbalancer"
```