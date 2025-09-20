allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ルート build ディレクトリをプロジェクト外にまとめる
rootProject.layout.buildDirectory.set(file("../../build"))

subprojects {
    // 各サブプロジェクトは「../../build/<プロジェクト名>」
    layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(project.name))

    // 必要なら残す（:app の評価順序に依存するケース向け）
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    // Provider をそのまま渡す（.get() しない）
    delete(rootProject.layout.buildDirectory)
}
