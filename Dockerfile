FROM python:alpine3.13

EXPOSE 5000

WORKDIR /app
ADD app /app
RUN apk add --no-cache --virtual .build-deps gcc g++ musl-dev postgresql-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apk --purge del .build-deps

CMD ["python", "app.py"]
