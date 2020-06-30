# Trivial example of Dockerizing a Dancer2 webapp

## About the webapp

This is a very simple webapp.  It's simply adding a route for `/:name`, which
if present will change the header on the page to change from "Perl is dancing"
to "Hello _name_, Perl is dancing".  The only "feature" that the application 
implements worth any discussion is the fact both the `/` and `/:name` routes
point to the same `index.tt` template.  The logic of whether or not to display
"Hello _name_," in page is handled entirely in the template engine.  Dancer2's
default simple Template engine cannot do this, so TemplateToolkit is used.  So,
this document is as much about illustrating how to add additional modules when
using Docker as anything else.

The docker image can be built from the base of this repository with the 
following command:

```
docker build -t dancer2-hello .
```

The resuting image could be run with:

```
docker run -p 5000:5000 dancer2-hello
```


## The Dockerfile:

The dockerfile is mutistage build.  We start by creating a build image
from `whosgonna/dancer2-tt-gazelle:build`. `whosgonna/dancer2-tt-gazelle:build`
is about 363 MB insize and contains some common modules that are necessary for 
building modules. To this image we copy the cpanfiles, and then install the 
modules.


A new image is then created from the minimal `whosgonna/perl-runtime:latest`
template. `whosgonna/perl-runtime:latest` is 70 MB. We copy the libraries from 
the build image and the cpanfiles and application files from the development 
computer.  

Next cpm and carton are run to make sure that the modules are installed and 
that the `cpanfile.snapshot` file is updated.

Finally, we launch the webapp using `carton`.  The use of `carton exec` forces
the system to include the `local/lib/perl5` directory in your Perl library 
search path. Also note that although we're calling `plackup` to start the 
serivce, the `--server` attribute is set to run the application under the 
Gazelle plack server.


```dockerfile
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
``` 


# Further explainations

## Why you start from the dancer2-tt-gazelle image, then later from the perl-runtime one?

Because the perl-runtime image does not contain the necessary software packages
to install the perl modules specified in the cpanfile. `dancer2-tt-gazelle` is
363 MB in size.  While the `perl-runtime` image at 70MB does not contain the 
software packages necessary to *install* the modules, it does contain the 
packages  necessary to *use* the modules successfully.  Because `cpm`/`carton` 
have installed the modules into `home/perl/local`, we can copy `home/perl/local`
from the ephemeral `build` image into our final image based off of the 
`perl-runtime` image.

## Why are both `cpm install` AND `carton install` run?

`cpm install` is used to do the actual installation of the modules.  
`carton exec` is used to launch plackup later, but `carton exec` will fail if it
does not find a proper `cpanfile.snapshot`, so `carton install` is run for the 
exclusive purpose of creating the `cpanfile.snapshot` file.

# See Also


* [whosgonna/docker_perl-example](https://github.com/whosgonna/docker_perl-example) 
Another simple example of using the same base runtime image.
* [docker_dancer2-tt-gazelle](https://github.com/whosgonna/docker_dancer2-tt-gazelle)
The image on which this is based
* [Dancer2](https://metacpan.org/pod/Dancer2)
