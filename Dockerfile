FROM python:3.8

RUN mkdir -p /data /usr/profiler
WORKDIR /usr/profiler

# install required underlying librarys and the tool
RUN apt-get update && apt-get install -y \
    libcairo2-dev \
    pkg-config \
    python3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install pycairo==1.23.0 SigProfilerExtractor==1.1.21 

COPY src/profiler.py .

ENTRYPOINT ["python", "profiler.py", "-h"]