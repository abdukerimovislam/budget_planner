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

// --- УМНОЕ ИСПРАВЛЕНИЕ ДЛЯ ISAR И AGP 8.0+ ---
subprojects {
    val configureAndroid = Action<Project> {
        val androidExt = this.extensions.findByName("android")
        if (androidExt != null) {
            try {
                // Проверяем через рефлексию, установлен ли namespace
                val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                val namespace = getNamespace.invoke(androidExt)

                // Если namespace отсутствует, присваиваем его автоматически
                if (namespace == null) {
                    val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                    val ns = if (this.group.toString().isNotEmpty()) this.group.toString() else "com.example.${this.name}"
                    setNamespace.invoke(androidExt, ns)
                }
            } catch (e: Exception) {
                // Игнорируем ошибки для несовместимых модулей
            }
        }
    }

    // Если проект уже был принудительно загружен через :app, выполняем сразу
    if (this.state.executed) {
        configureAndroid.execute(this)
    } else {
        // Иначе планируем выполнение после его штатной загрузки
        this.afterEvaluate(configureAndroid)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}