# kaniko-cache-bug

A bug with the kaniko cache when using globs and multi-stage docker builds.

## Repro Steps

1) Build with kaniko with cache on: `./run_in_docker.sh ./Dockerfile . <some-docker-repo>/kaniko-cache-bug:latest true`
2) Run `ls` in the container to see that the file is properly symlinked.
```
docker pull kaniko-cache-bug:latest && docker run --rm kaniko-cache-bug:latest -l

-rw-r--r--    1 root     root             0 Feb 26 14:33 file-1.txt
lrwxrwxrwx    1 root     root            11 Feb 26 14:33 file.txt -> /file-1.txt
```
3) Update version.txt to `2`
4) Build with kaniko with cache on: `./run_in_docker.sh ./Dockerfile . <some-docker-repo>/kaniko-cache-bug:latest true`
5) Run `ls` in the container to see that the symlink layer was cached and re-used, leading to it pointing at the wrong file.
```
docker pull kaniko-cache-bug:latest && docker run --rm kaniko-cache-bug:latest -l

-rw-r--r--    1 root     root             0 Feb 26 14:39 file-2.txt
lrwxrwxrwx    1 root     root            11 Feb 26 14:33 file.txt -> /file-1.txt
```
6) Build with kaniko with cache off: `./run_in_docker.sh ./Dockerfile . <some-docker-repo>/kaniko-cache-bug:latest false`
7) Observe that everything works as expected.
```
docker pull kaniko-cache-bug:latest && docker run --rm kaniko-cache-bug:latest -l

-rw-r--r--    1 root     root             0 Feb 26 14:40 file-2.txt
lrwxrwxrwx    1 root     root            11 Feb 26 14:40 file.txt -> /file-2.txt
```

## Notes

This only occurs with multi-stage builds. a simple version like this will NOT exhibit the bug:

```
FROM alpine:3.6
COPY version.txt version.txt
RUN touch file-$(cat ./version.txt).txt
RUN ln -s $(find /file-*.txt) /file.txt
```
