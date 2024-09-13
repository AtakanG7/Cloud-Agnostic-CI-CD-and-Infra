steps {
    script {
        dir('helm-repo') {
            sh """
                helm upgrade --install ${APP_NAME}-staging ${CHART_PATH} \
                    --namespace staging \
                    -f ${CHART_PATH}/values-staging.yaml \
                    --set image.tag=${env.NEW_VERSION} \
                    --wait --timeout 5m
            """

            // Verify deployment
            def deploymentStatus = sh(script: """
                kubectl rollout status deployment/${APP_NAME}-staging -n staging --timeout=300s
            """, returnStatus: true)

            if (deploymentStatus != 0) {
                error "Deployment to staging failed"
            }
        }
    }
}
