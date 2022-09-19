Everybody needs a container image to debug connectivity issues. So here is mine.

# Cheatsheet

Launch a shell in a Kubernetes cluster
```bash
kubectl run debug-shell --rm -it --image vivivanilla/nettools --
```

Run a script
```bash
cat script.sh | kubectl run debug-shell --rm -i --image vivivanilla/nettools -- bash

kubectl run debug-shell --rm -i --image vivivanilla/nettools -- bash <<EOF
#!/bin/bash
echo hello
EOF
```

Fetch and decode secrets
```bash
kubectl get secret -o json <selector> | jq -r '[(.items + [.])[] | {"name": .metadata.name, "namespace": .metadata.namespace, "data": .data | map_values(@base64d) }]'
```


