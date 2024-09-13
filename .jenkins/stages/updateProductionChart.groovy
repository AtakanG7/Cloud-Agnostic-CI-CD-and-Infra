steps {
    script {
        dir('helm-repo') {
            sh """
                helm package ${CHART_PATH} --destination docs
                helm repo index .
                git add docs ${CHART_PATH}
                git commit -m "Update ${APP_NAME} chart to version ${env.NEW_VERSION}"
                git push origin main
            """

            // Verify push was successful
            def pushStatus = sh(script: "git push origin main", returnStatus: true)
            if (pushStatus != 0) {
                error "Failed to push updated chart to repository"
            }
        }
    }
}
