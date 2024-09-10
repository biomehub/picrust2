# Picrust requires python >=3.5,<3.9
FROM python:3.8
ENV DEBIAN_FRONTEND noninteractive

ENV APP_NAME=Picrust2
ENV PICRUST2_VERSION=2.5.2

# Requirements for Picrust2 v.2.5.2
ENV EPA_NG_VERSION=0.3.8
ENV GAPPA_VERSION=0.8.0
ENV GLPK_VERSION=4.65
ENV HMMER_VERSION=3.1b2
ENV SEPP_VERSION=4.3.10

#ENTRYPOINT ["/bin/bash", "-c"]

# base libs
RUN apt-get update -y; \
        apt-get install -y apt-utils
RUN apt-get install -y r-base autotools-dev wget libtool flex bison cmake automake autoconf git tar g++ apt-utils libboost-all-dev build-essential
RUN apt-get install -y python3-pip python3-joblib glpk-utils libglpk-dev python3-dev
RUN apt-get -y install default-jre
RUN apt-get clean

# Python libs installation
RUN pip3 install pytest==7.4.2 pytest-cov==4.1.0 jinja2==3.1.2 Cython==3.0.2 phylotreelib==1.23.1 wheel==0.41.2 Dendropy==4.5.2
# R files
RUN mkdir /r-libs
# set r-libs path
ENV R_LIBS_USER=/r-libs

# install castor and it's dependencies
RUN R -e "install.packages('castor', dependencies=TRUE, repos='http://cran.rstudio.com/')"

# picrust2 download
RUN wget https://github.com/picrust/picrust2/archive/refs/tags/v$PICRUST2_VERSION.tar.gz \
        && tar xvzf  v$PICRUST2_VERSION.tar.gz \
        && cd picrust2-$PICRUST2_VERSION \
        && cd picrust2 && mkdir placement_tools 

WORKDIR picrust2-$PICRUST2_VERSION/picrust2/placement_tools 

# papara installation
# https://cme.h-its.org/exelixis/web/software/papara/index.html
RUN wget https://cme.h-its.org/exelixis/resource/download/software/papara_nt-2.5-static_x86_64.tar.gz \
        && tar -xzf papara_nt-2.5-static_x86_64.tar.gz \
        && mv papara_static_x86_64 /bin/papara \
        && rm papara_nt-2.5-static_x86_64.tar.gz

# epa-ng installation
RUN wget https://github.com/pierrebarbera/epa-ng/archive/refs/tags/v$EPA_NG_VERSION.tar.gz \
        && tar -xzf v$EPA_NG_VERSION.tar.gz \
        && cd epa-ng-$EPA_NG_VERSION \
        && make \
        && cp bin/epa-ng /bin/ \
        && cd .. \
        && rm v$EPA_NG_VERSION.tar.gz \
        && rm -rf epa-ng-$EPA_NG_VERSION

# gappa installation
RUN wget https://github.com/lczech/gappa/archive/refs/tags/v$GAPPA_VERSION.tar.gz \
        && tar -xzf v$GAPPA_VERSION.tar.gz \
        && cd gappa-$GAPPA_VERSION/ \
        && make \
        && cp bin/gappa /bin/ \
        && cd .. \
        && rm v$GAPPA_VERSION.tar.gz \
        && rm -rf gappa-$GAPPA_VERSION/

# hmmer installation 
RUN wget http://eddylab.org/software/hmmer/hmmer-$HMMER_VERSION.tar.gz \
        && tar -xzf hmmer-$HMMER_VERSION.tar.gz \
        && cd hmmer-$HMMER_VERSION \
        && ./configure \
        && make \
        && make check \
        && make install \
        && cd .. \
        && rm -rf hmmer-$HMMER_VERSION \
        && rm hmmer-$HMMER_VERSION.tar.gz

# sepp installation
RUN wget https://github.com/smirarab/sepp/archive/refs/tags/$SEPP_VERSION.tar.gz \
        && tar -xzf $SEPP_VERSION.tar.gz \
        && cd sepp-$SEPP_VERSION  \
        && python3 setup.py config \
        && python3 setup.py install \
        # pplacerx64 script from sepp is broken
        # core dumpt when running
        # x32 version works
        && mv tools/bundled/Linux/pplacer-32 /root/.sepp/bundled-v$SEPP_VERSION/pplacer \
        && cd .. \
        && rm -rf sepp-$SEPP_VERSION \
        && rm $SEPP_VERSION.tar.gz

WORKDIR /

# picrust2 installation and test
RUN cd picrust2-$PICRUST2_VERSION  \
        && pip3 install --editable . \
        && pip3 cache purge  \
        && pytest
