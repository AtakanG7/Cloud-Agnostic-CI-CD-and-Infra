def incrementVersion(String version) {
    def parts = version.split('\\.')
    def lastPart = parts.last()
    def newLastPart = (lastPart.toInteger() + 1).toString()
    parts[parts.size() - 1] = newLastPart
    return parts.join('.')
}

return incrementVersion(env.currentVersion)
