### Package deps, for build and devel phases
FROM whosgonna/dancer2-tt-gazelle:build AS build

## Install all of the perl modules:
COPY cpanfile* /home/perl/
RUN cpm install --workers 16 --without-develop --without-configure --with-suggests \
    && carton install --without 'develop,configure'




### Final phase: the runtime version - notice that we start from the base perl image.
FROM whosgonna/perl-runtime:latest

## Set any environmental variables here.
ENV PLACK_ENV=production

## If any software packages are needed in the final image, here's where they go.
#RUN apk --no-cache add mariadb-client

## Copy the local directory with the perl libraries, copy the cpan files, and re-run
## cpm and carton to finalize things:
COPY --from=build /home/perl/local/ /home/perl/local/

COPY cpanfile* /home/perl/
RUN cpm install --workers 16 --without-develop --without-configure --with-suggests \
    && carton install --without 'develop,configure'



COPY ./Dancer2-Hello/ Dancer2-Hello

CMD  carton exec plackup -p  5000 --server Gazelle /home/perl/Dancer2-Hello/bin/app.psgi
