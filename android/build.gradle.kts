allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuración corregida para el directorio de compilación
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()

// En lugar de usar .value(), configuramos el subproyecto de forma segura
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}