plugins {
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    configurations.all {
        resolutionStrategy {
            eachDependency {
                // 'this' is implicitly the DependencyResolveDetails
                if (requested.group == "androidx.glance" && requested.name == "glance-appwidget") {
                    useVersion("1.1.1")
                }
                if (requested.group == "androidx.compose.remote" && requested.name == "remote-creation-android") {
                    useVersion("1.0.0-alpha09")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
