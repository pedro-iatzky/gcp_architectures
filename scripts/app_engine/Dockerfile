FROM python:3.6

WORKDIR /app

COPY . /app

RUN pip install -r requirements.txt

ENV PYTHONPATH=$PYTHONPATH:/app

CMD gunicorn -b :8080 "your_python_package.app:app"