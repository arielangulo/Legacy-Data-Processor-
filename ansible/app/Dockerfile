FROM python:3.10-slim
WORKDIR /app
COPY app.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
