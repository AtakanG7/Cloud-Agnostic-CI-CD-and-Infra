steps {
    script {
        dir('helm-repo') {
            def charts = sh(script: "ls charts", returnStdout: true).trim().split()
            for (def chart in charts) {
                sh """
                    helm upgrade --install ${chart}-staging charts/${chart} \
                        --namespace staging \
                        -f charts/${chart}/values-staging.yaml \
                        --wait
                """
            }
        }
    }
}
