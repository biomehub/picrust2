# Forked from https://github.com/gsmashd/picrust2

FROM python:3.6.5-stretch

ENTRYPOINT ["/bin/bash", "-c"]

RUN apt update &&\
	apt upgrade -y &&\
	apt install -y autotools-dev libtool flex bison cmake automake autoconf git tar g++ apt-utils libboost-all-dev

RUN git clone https://github.com/picrust/picrust2.git

WORKDIR /picrust2/placement_tools

RUN wget https://cme.h-its.org/exelixis/resource/download/software/papara_nt-2.5-static_x86_64.tar.gz &&\
	tar -xzf papara_nt-2.5-static_x86_64.tar.gz &&\
	mv papara_static_x86_64 /bin/papara

RUN wget https://github.com/Pbdas/epa-ng/archive/v0.3.5.tar.gz &&\
	tar -xzf v0.3.5.tar.gz &&\
	cd epa-ng-0.3.5/ &&\
	make &&\
	cp bin/epa-ng /bin/

RUN wget https://github.com/lczech/gappa/archive/v0.4.0.tar.gz &&\
	tar -xzf v0.4.0.tar.gz &&\
	cd gappa-0.4.0/ &&\
	make &&\
	cp bin/gappa /bin/

RUN wget http://eddylab.org/software/hmmer/hmmer-3.2.1.tar.gz &&\
	tar -xzf hmmer-3.2.1.tar.gz &&\
        cd hmmer-3.2.1 &&\
        ./configure &&\
        make &&\
        make check &&\
	make install

WORKDIR /
RUN apt update && apt upgrade -y &&\
	apt install -y r-base python3-h5py python3-pip python3-joblib glpk-utils libglpk-dev
RUN pip3 install --upgrade pip &&\
	pip3 install numpy && pip3 install biom-format pytest pytest-cov

RUN mkdir /r-libs
RUN cd /r-libs &&\
	wget https://cran.r-project.org/src/contrib/naturalsort_0.1.3.tar.gz &&\
	wget https://cran.r-project.org/src/contrib/castor_1.4.1.tar.gz &&\
	wget https://cran.r-project.org/src/contrib/Rcpp_1.0.1.tar.gz &&\
	wget https://cran.r-project.org/src/contrib/nloptr_1.2.1.tar.gz

RUN R CMD INSTALL /r-libs/Rcpp_1.0.1.tar.gz
RUN R CMD INSTALL /r-libs/naturalsort_0.1.3.tar.gz
RUN R CMD INSTALL /r-libs/nloptr_1.2.1.tar.gz
RUN R CMD INSTALL /r-libs/castor_1.4.1.tar.gz

RUN cd /picrust2 && pip install --editable . && pytest
