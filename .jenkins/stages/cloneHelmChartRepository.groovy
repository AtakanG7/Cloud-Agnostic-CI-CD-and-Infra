steps {
    sh "git clone ${HELM_REPO} helm-repo"
    sh "helm repo add myrepo https://atakang7.github.io/gh-pages/docs"
}
