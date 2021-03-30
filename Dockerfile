FROM python:alpine3.13

EXPOSE 5000

ADD app/requirements.txt requirements.txt

RUN apk add --no-cache --virtual .build-deps gcc g++ musl-dev postgresql-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apk --purge del .build-deps
# to fix problem with: ImportError: Error loading shared library libpq.so.5: No such file or directory (needed by /usr/local/lib/python3.9/site-packages/psycopg2/_psycopg.cpython-39-x86_64-linux-gnu.so)
RUN apk add --no-cache libpq

WORKDIR /app
ADD app /app


CMD ["python", "app.py"]
