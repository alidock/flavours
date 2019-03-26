`alipier/alidock`-based container to support ROCm develompment and cross-compilation.
See main project at [alidock](htpps://github.com/alidock/alidock).

How to run it with alidock
--------------------------

_To execute ROCm enabled apps you will require an host system with the full ROCm driver stack installed._

### Run with alidock

### Run with docker

```
docker pull mconcas/alirocm
docker run -it --device=/dev/kfd --device=/dev/dri --group-add video mconcas/alirocm
```

