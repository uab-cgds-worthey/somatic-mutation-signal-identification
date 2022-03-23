FROM python:3.9.11

RUN mkdir -p /usr/sigprof
WORKDIR /usr/sigprof

# install the tool
RUN pip install --no-cache-dir SigProfilerExtractor==1.1.6

# install the reference genomes specialized for the tool
RUN python -c "from SigProfilerMatrixGenerator import install as genInstall; genInstall.install('GRCh38')"

COPY src/profiler.py .

ENTRYPOINT [ "python", "profiler.py" ]