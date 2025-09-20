
// ルート build ディレクトリをプロジェクト外にまとめる
allprojects {
    buildDir = file("../../build/${project.name}")
}

subprojects {
    // 必要なら残す（:app の評価順序に依存するケース向け）
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    // Provider をそのまま渡す（.get() しない）
    delete(rootProject.buildDir)
}
