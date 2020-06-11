FROM python:alpine as builder
#RUN apk add --no-cache g++ make

RUN touch README.md
COPY setup.py setup.py
RUN python setup.py egg_info
RUN pip wheel -r tosheets.egg-info/requires.txt --wheel-dir=/build/wheels

ENV NO_DEPS NO_DEPS
COPY tosheets tosheets
RUN python setup.py bdist_wheel -d /build/wheels

FROM python:alpine

COPY --from=builder /build/wheels /tmp/wheels

RUN pip3 install \
  --force-reinstall \
  --ignore-installed \
  --upgrade \
  --no-index \
  --no-deps /tmp/wheels/* \
 && rm -rf /tmp/wheels

RUN adduser -S sheets
USER sheets
COPY credentials.json /home/sheets/.credentials/sheets.googleapis.com-python-tosheets.json

#CMD ["usr","local","bin", "tosheets"]
ENTRYPOINT ["/usr/local/bin/tosheets"]