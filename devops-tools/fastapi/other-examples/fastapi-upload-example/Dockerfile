FROM python:3.13.0a4-slim-bullseye

COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt

WORKDIR /app
COPY . /app
EXPOSE 80
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80", "--reload"]