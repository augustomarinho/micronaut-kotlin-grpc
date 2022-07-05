## Micronaut gRPC service
###### Exposing gRPC over HTTP 1.1

The main proposal of this repo is to study gRPC services implemented with Micronaut and expose them over HTTP 1.1 through Envoy gRPC_Transcoder filter.

## Running
    $ ./gradlew run

    $ docker-compose up -d --force-recreate

## Reading Envoy Logs
    docker logs -f envoy-transcoder