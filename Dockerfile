FROM continuumio/miniconda3

ENTRYPOINT ["/bin/bash", "-c"]

RUN apt update && apt upgrade -y && apt install -y autotools-dev libtool flex bison cmake automake autoconf vim git tar g++

RUN apt install -y libboost-all-dev

RUN git clone https://github.com/picrust/picrust2.git

WORKDIR /picrust2/placement_tools

RUN tar -xzf papara_nt-2.5.tar.gz &&\
	cd papara_nt-2.5 &&\
	sh build_papara2.sh &&\
	ln -s $PWD/papara /bin/

RUN tar -xzf epa-ng.tar.gz &&\
	cd epa-ng/ &&\
	make &&\ 
	ln -s $PWD/bin/epa-ng /bin/

RUN tar -xzf gappa.tar.gz &&\
	cd gappa/ &&\
	make &&\
	ln -s $PWD/bin/gappa /bin/

WORKDIR /picrust2

RUN echo ". /opt/conda/etc/profile.d/conda.sh" > ~/.bashrc 
RUN ["/bin/bash", "-c", "conda env create -f dev-environment.yml"]
RUN echo "conda activate picrust2-dev" >> ~/.bashrc 
RUN ["/bin/bash", "-c",". ~/.bashrc && pip install --editable ."]

RUN mkdir /custom-scripts
WORKDIR /custom-scripts
RUN wget https://raw.githubusercontent.com/gsmashd/picrust2/master/entry.sh && chmod 755 entry.sh
RUN ln -s /custom-scripts/entry.sh /bin/entry.sh

WORKDIR /

ENTRYPOINT ["/bin/bash","entry.sh"]
CMD ["conda list"]
