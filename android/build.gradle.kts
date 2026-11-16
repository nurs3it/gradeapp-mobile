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
    project.evaluationDependsOn(":app")
}
// javac 22+ fails camera_android_camerax when CallbackToFutureAdapter (used in
// camera-core's annotations) is missing from its compile classpath.
// ponytail: drop once the plugin declares androidx.concurrent itself.
project(":camera_android_camerax") {
    afterEvaluate {
        dependencies.add("compileOnly", "androidx.concurrent:concurrent-futures:1.1.0")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
