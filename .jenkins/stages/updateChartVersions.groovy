steps {
    script {
        dir('helm-repo') {
            def currentVersion = sh(script: "grep 'version:' ${CHART_PATH}/Chart.yaml | awk '{print \$2}'", returnStdout: true).trim()

            if (currentVersion.isEmpty()) {
                currentVersion = "0.1.0"  // Default version if not found
                echo "Warning: Version not found in Chart.yaml. Using default version: ${currentVersion}"
            }

            env.NEW_VERSION = load 'pipeline/scripts/incrementVersion.groovy'

            // Update Chart.yaml
            sh "sed -i 's/version: .*/version: ${env.NEW_VERSION}/' ${CHART_PATH}/Chart.yaml"

            // Update values-staging.yaml and values-production.yaml
            sh """
                sed -i 's/tag: .*/tag: ${env.NEW_VERSION}/' ${CHART_PATH}/values-staging.yaml
                sed -i 's/tag: .*/tag: ${env.NEW_VERSION}/' ${CHART_PATH}/values-production.yaml
            """

            // Check if files were updated successfully
            def updatedVersion = sh(script: "grep 'version:' ${CHART_PATH}/Chart.yaml | awk '{print \$2}'", returnStdout: true).trim()
            if (updatedVersion != env.NEW_VERSION) {
                error "Failed to update chart version"
            }

            // Commit and push the changes
            withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                sh """
                    git config --global user.email "atakan1927@gmail.com"
                    git config --global user.name "Atakan G"
                    git add ${CHART_PATH}/Chart.yaml ${CHART_PATH}/values-staging.yaml ${CHART_PATH}/values-production.yaml
                    git commit -m "Update ${APP_NAME} chart version to ${env.NEW_VERSION} for staging"
                    git remote set-url origin https://atakang7:${GIT_PASSWORD}@github.com/AtakanG7/gh-pages.git
                    git push --set-upstream origin main
                """
            }
        }
    }
}
