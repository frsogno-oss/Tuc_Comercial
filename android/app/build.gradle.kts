// --- CORRECCIÓN: Imports agregados ---
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Carga las propiedades de tu archivo key.properties
val keyPropertiesFile = rootProject.file("android/key.properties")
val keyProperties = Properties() // Ahora 'Properties' es reconocido
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile)) // Ahora 'FileInputStream' es reconocido
}

android {
    namespace = "uno.tuccomercial.app" // O el que prefieras
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            // Lee las contraseñas y el alias como antes
            keyAlias = keyProperties["keyAlias"] as String? ?: ""
            keyPassword = keyProperties["keyPassword"] as String? ?: ""
            storePassword = keyProperties["storePassword"] as String? ?: ""

            // --- CAMBIO CLAVE AQUÍ ---
            // Construimos la ruta al archivo JKS de forma más explícita
            // Asumiendo que 'tuc_comercial_nueva.jks' está en la carpeta 'android/app'
            val keystoreFile = rootProject.file("android/app/tuc_comercial_nueva.jks")
            if (keystoreFile.exists()) {
                storeFile = keystoreFile
            } else {
                // Si no encuentra el archivo, imprime un mensaje claro
                println("Error: No se encontró el archivo keystore en android/app/tuc_comercial_nueva.jks")
                // Podrías lanzar una excepción aquí si prefieres que falle antes
                // throw GradleException("Keystore file not found at android/app/tuc_comercial_nueva.jks")
            }
        }
    }

    defaultConfig {
        applicationId = "uno.tuccomercial.app" // Debe coincidir con el namespace
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
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
    // Podés tener otras dependencias aquí
}