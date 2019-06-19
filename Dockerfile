# From https://github.com/gsmashd/picrust2

FROM python:3.6.5-stretch

ENTRYPOINT ["/bin/bash", "-c"]

RUN apt update && apt upgrade -y && apt install -y autotools-dev libtool flex bison cmake automake autoconf git tar g++

RUN apt install -y libboost-all-dev

RUN git clone https://github.com/picrust/picrust2.git

WORKDIR /picrust2/placement_tools

RUN wget https://cme.h-its.org/exelixis/resource/download/software/papara_nt-2.5-static_x86_64.tar.gz &&\
	tar -xzf papara_nt-2.5-static_x86_64.tar.gz &&\
	mv papara_static_x86_64 /bin/papara

RUN wget https://github.com/Pbdas/epa-ng/archive/v0.3.5.tar.gz &&\
	tar -xzf v0.3.5.tar.gz &&\
	cd epa-ng-0.3.5/ &&\
	make &&\ 
	ln -s $PWD/bin/epa-ng /bin/

RUN tar -xzf gappa.tar.gz &&\
	cd gappa/ &&\
	make &&\
	ln -s $PWD/bin/gappa /bin/

WORKDIR /
RUN apt update && apt upgrade -y && apt install -y r-base python3-h5py python3-pip python3-joblib glpk-utils libglpk-dev
RUN pip3 install numpy && pip3 install biom-format pytest pytest-cov

RUN mkdir /r-libs
RUN cd /r-libs && wget https://cran.r-project.org/src/contrib/naturalsort_0.1.3.tar.gz && wget https://cran.r-project.org/src/contrib/castor_1.3.3.tar.gz && wget https://cran.r-project.org/src/contrib/Rcpp_0.12.17.tar.gz

RUN R CMD INSTALL /r-libs/Rcpp_0.12.17.tar.gz
RUN R CMD INSTALL /r-libs/naturalsort_0.1.3.tar.gz
RUN R CMD INSTALL /r-libs/castor_1.3.3.tar.gz

RUN cd /picrust2 && pip install --editable . && pytest

