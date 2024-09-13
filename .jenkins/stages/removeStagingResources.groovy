steps {
    script {
        // Uninstall all Helm releases in the staging namespace
        def helmReleases = sh(script: "helm list -n staging -q", returnStdout: true).trim()
        if (helmReleases) {
            helmReleases.split().each { release ->
                sh "helm uninstall ${release} -n staging"
            }
        }

        // Delete all resources in the staging namespace
        sh """
            kubectl delete all --all -n staging
            kubectl delete pvc --all -n staging
            kubectl delete configmap --all -n staging
            kubectl delete secret --all -n staging --ignore-not-found=true
        """
    }
}
