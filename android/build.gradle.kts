allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://repo1.maven.org/maven2/") }
        maven { url = uri("https://jitpack.io") }
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

subprojects {
    val configureProject = {
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            val android = extensions.findByName("android")
            if (android != null) {
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(android) as? String
                    if (currentNamespace.isNullOrEmpty()) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        val manifestFile = file("src/main/AndroidManifest.xml")
                        var packageName: String? = null
                        if (manifestFile.exists()) {
                            val manifestText = manifestFile.readText()
                            val packageRegex = """package="([^"]+)"""".toRegex()
                            packageName = packageRegex.find(manifestText)?.groupValues?.get(1)
                        }
                        if (packageName == null) {
                            packageName = "com.example.${project.name.replace("-", "_").replace(":", "_")}"
                        }
                        setNamespace.invoke(android, packageName)
                    }
                } catch (e: Exception) {
                    // Ignore or log
                }
            }
        }
    }
    if (state.executed) {
        configureProject()
    } else {
        afterEvaluate {
            configureProject()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
