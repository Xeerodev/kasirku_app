allprojects {
    repositories {
        google()
        mavenCentral()
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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            
            // 1. Force SDK Versions to 37
            try {
                val setCompileSdk = android.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                setCompileSdk.invoke(android, 37)
                val getDefaultConfig = android.javaClass.getMethod("getDefaultConfig")
                val defaultConfig = getDefaultConfig.invoke(android)
                if (defaultConfig != null) {
                    val setTargetSdk = defaultConfig.javaClass.getMethod("setTargetSdk", Int::class.javaPrimitiveType)
                    setTargetSdk.invoke(defaultConfig, 37)
                }
            } catch (e: Exception) {
                try {
                    val compileSdkVersionMethod = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    compileSdkVersionMethod.invoke(android, 37)
                } catch (e2: Exception) {}
            }

            // 2. Fix missing Namespace for old plugins
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(android) == null) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val xml = manifestFile.readText()
                        val match = Regex("package\\s*=\\s*\"([^\"]+)\"").find(xml)
                        if (match != null) {
                            setNamespace.invoke(android, match.groupValues[1])
                        }
                    }
                }
            } catch (e: Exception) {}
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
