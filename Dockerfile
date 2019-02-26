FROM alpine:3.6 as builder
COPY version.txt version.txt
RUN touch file-$(cat ./version.txt).txt

FROM alpine:3.6
COPY --from=builder file-*.txt /
RUN ln -s $(find /file-*.txt) /file.txt
