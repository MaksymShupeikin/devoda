allprojects {
    repositories {
        google()
        mavenCentral()
        // Mapbox Maps SDK is served from a private Maven repo and needs a
        // secret downloads token (scope DOWNLOADS:READ). Put it in
        // ~/.gradle/gradle.properties as MAPBOX_DOWNLOADS_TOKEN=sk.xxxxx
        // (or export it as an env var of the same name).
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication { create<BasicAuthentication>("basic") }
            credentials {
                username = "mapbox"
                password = (project.findProperty("MAPBOX_DOWNLOADS_TOKEN")
                    ?: System.getenv("MAPBOX_DOWNLOADS_TOKEN")
                    ?: "") as String
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
