steps {
    script {
        // Build the Docker image with the specified version
        sh "docker build -t ${DOCKER_REGISTRY}/${APP_NAME}:${env.NEW_VERSION} ."

        // Push the Docker image to the registry
        sh "docker push ${DOCKER_REGISTRY}/${APP_NAME}:${env.NEW_VERSION}"

        // Verify that the image was pushed successfully
        sh "docker pull ${DOCKER_REGISTRY}/${APP_NAME}:${env.NEW_VERSION}"
    }
}
