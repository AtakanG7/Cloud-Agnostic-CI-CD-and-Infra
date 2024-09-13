steps {
    script {
        dir('helm-repo') {
            sh """
                helm repo update
                helm upgrade --install ${APP_NAME} ${CHART_PATH} \
                    --namespace production \
                    -f ${CHART_PATH}/values-production.yaml \
                    --set image.tag=${env.NEW_VERSION} \
                    --wait --timeout 10m
            """
        }
    }
}
