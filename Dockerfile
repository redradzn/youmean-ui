FROM cirrusci/flutter:stable
WORKDIR /app
COPY . .
RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web
EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
