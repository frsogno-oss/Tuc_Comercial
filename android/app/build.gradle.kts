// --- ARCHIVO COMPLETO Y CORREGIDO ---
// android/app/build.gradle.kts

// Agrega los imports necesarios al principio
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --- CORRECCIÓN CLAVE AQUÍ ---
// Carga las propiedades de tu archivo key.properties
// Busca "key.properties" en la carpeta "android" (el rootProject de Gradle)
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
    println("¡Archivo key.properties cargado exitosamente!")
} else {
    println("ADVERTENCIA: El archivo android/key.properties no se encontró. La firma de lanzamiento fallará.")
}

android {
    // El namespace DEBE coincidir con el 'package' de tu MainActivity.kt
    namespace = "uno.tuccomercial.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String? ?: ""
            keyPassword = keyProperties["keyPassword"] as String? ?: ""
            // --- CORRECCIÓN CLAVE AQUÍ ---
            // Lee la ruta "app/tuc_comercial_nueva.jks" desde key.properties
            // y la resuelve correctamente a "android/app/tuc_comercial_nueva.jks"
            storeFile = if (keyProperties["storeFile"] != null) rootProject.file(keyProperties["storeFile"] as String) else null
            storePassword = keyProperties["storePassword"] as String? ?: ""
        }
    }

    defaultConfig {
        // El applicationId DEBE coincidir con el 'package' de tu MainActivity.kt
        applicationId = "uno.tuccomercial.app"
        minSdk = 34
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Tus dependencias
}