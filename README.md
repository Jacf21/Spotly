# 🌄 Turismo Bolivia - Aplicación Móvil

[![Flutter Version](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Aplicación móvil diseñada para promover el turismo nacional e internacional en Bolivia, permitiendo descubrir destinos turísticos mediante publicaciones georreferenciadas.

## 📋 Tabla de Contenidos
- [Visión General](#visión-general)
- [Arquitectura](#arquitectura)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Guía de Carpetas](#guía-de-carpetas)
- [Configuración Inicial](#configuración-inicial)
- [Convenciones de Código](#convenciones-de-código)
- [Flujo de Trabajo Git](#flujo-de-trabajo-git)
- [Pruebas](#pruebas)
- [Solución de Problemas](#solución-de-problemas)

## 🎯 Visión General

**Turismo Bolivia** es una red social de viajes georreferenciada que permite a los usuarios:
- 📸 Publicar fotos y videos vinculados automáticamente a ubicaciones reales
- 🗺️ Descubrir destinos turísticos mediante un mapa interactivo
- 🆘 Activar alertas de emergencia para viajes seguros
- 🤝 Compartir experiencias y recomendaciones de transporte

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** organizada por **features** (características), combinada con **Domain-Driven Design** para garantizar escalabilidad y mantenibilidad.

### Capas de la Arquitectura:

PRESENTATION (UI/State)
↓
DOMAIN (Entidades/Casos de Uso)
↓
DATA (Repositorios/Fuentes de Datos)
↓
EXTERNAL (Supabase/APIs)


### Principios Aplicados:
- **Separación de responsabilidades** (SOC)
- **Inyección de dependencias**
- **Principio de inversión de dependencias**
- **Programación orientada a interfaces**

## 📁 Estructura del Proyecto

lib/
├── main.dart # Punto de entrada
├── injection_container.dart # DI (Inyección de dependencias)
├── core/ # Código transversal
│ ├── constants/
│ ├── errors/
│ ├── network/
│ ├── themes/
│ ├── utils/
│ └── widgets/
├── config/ # Configuraciones globales
│ ├── supabase/
│ └── router/
└── features/ # Módulos funcionales
├── auth/ # Autenticación
├── destinations/ # Destinos turísticos
├── posts/ # Publicaciones
└── safety/ # Seguridad y alertas


## 📚 Guía de Carpetas (Explicación Detallada)

### 🎯 **Raíz del Proyecto**

| Archivo/Carpeta | Propósito |
|----------------|-----------|
| `main.dart` | Punto de entrada. Inicializa Supabase, carga variables de entorno y arranca la app. |
| `injection_container.dart` | Centraliza toda la inyección de dependencias usando get_it o provider. |
| `pubspec.yaml` | Declara dependencias, assets, fuentes y configuraciones del proyecto. |
| `.env` | Variables de entorno sensibles (NO SUBIR A GIT). |
| `.env.template` | Plantilla con las variables necesarias para otros desarrolladores. |

### 🧱 **Carpeta `core/`**

Código compartido que puede ser usado por cualquier feature.

core/
├── constants/
│ ├── app_strings.dart # Textos estáticos: "Bienvenido", "Iniciar sesión"
│ ├── app_colors.dart # Paleta de colores: primaryBlue, accentGreen
│ └── api_endpoints.dart # Rutas de API: /auth/login, /destinations
│
├── errors/
│ ├── exceptions.dart # Excepciones específicas: ServerException, CacheException
│ └── failures.dart # Mapeo de excepciones a mensajes de usuario
│
├── network/
│ ├── network_info.dart # Verifica conectividad a internet
│ └── api_client.dart # Cliente HTTP configurado (Dio/Http) con interceptores
│
├── themes/
│ └── app_theme.dart # Tema global: light/dark mode, tipografía
│
├── utils/
│ ├── validators.dart # Validaciones: email válido, contraseña segura
│ └── date_formatter.dart # Formateo de fechas: "hace 2 días"
│
└── widgets/
├── custom_button.dart # Botón reutilizable con estilos de la app
├── loading_indicator.dart # Indicador de carga personalizado
└── error_widget.dart # Widget para mostrar errores al usuario

### ⚙️ **Carpeta `config/`**

Configuración global de servicios externos y navegación.

config/
├── supabase/
│ └── supabase_config.dart # Inicialización y cliente de Supabase
│ # Uso: SupabaseConfig.client.from('tabla').select()
│
└── router/
└── app_router.dart # Configuración de rutas con GoRouter

Define: loginRoute, homeRoute, destinationDetailRoute


### 📦 **Carpeta `features/` - Estructura por Feature**

Cada feature sigue la misma estructura de 3 capas:

#### Ejemplo: `features/auth/` (Autenticación)

auth/
├── data/ # Capa de datos (implementaciones concretas)
│ ├── datasources/
│ │ └── auth_remote_data_source.dart
│ │ # Fuente de datos remota (Supabase)
│ │ # Métodos: login(String email, String password)
│ │ # register(User user)
│ │ # logout()
│ │
│ ├── models/
│ │ └── user_model.dart
│ │ # Modelo que extiende la entidad
│ │ # Incluye: fromJson(), toJson() para Supabase
│ │ # Ejemplo: UserModel extends User
│ │
│ └── repositories/
│ └── auth_repository_impl.dart
│ # Implementación concreta del repositorio
│ # Usa el datasource para obtener datos
│ # Convierte UserModel a User (entidad)
│
├── domain/ # Capa de dominio (reglas de negocio)
│ ├── entities/
│ │ └── user.dart
│ │ # Entidad pura (sin dependencias externas)
│ │ # Atributos: id, name, email, photoUrl
│ │ # Usa equatable para comparaciones
│ │
│ ├── repositories/
│ │ └── auth_repository.dart
│ │ # Contrato/Interfaz (abstract class)
│ │ # Define qué debe hacer el repositorio
│ │ # Ejemplo: Future<Either<Failure, User>> login(String email, String password)
│ │
│ └── usecases/
│ └── login_usecase.dart
│ # Casos de uso específicos
│ # Ejemplo: class LoginUseCase { Future<Either<Failure, User>> call(LoginParams params) }
│ # Cada usecase tiene UNA sola responsabilidad
│
└── presentation/ # Capa de presentación (UI y estado)
├── bloc/ # o provider/riverpod
│ └── auth_bloc.dart
│ # Maneja el estado de autenticación
│ # Eventos: LoginEvent, RegisterEvent, LogoutEvent
│ # Estados: AuthInitial, AuthLoading, AuthSuccess, AuthFailure
│
├── pages/
│ ├── login_page.dart # Pantalla completa de login
│ └── register_page.dart # Pantalla de registro
│ # Cada page usa widgets específicos y el bloc
│
└── widgets/
└── auth_form.dart # Widget reutilizable dentro del feature

Ejemplo: Formulario que puede usarse en login y register

### 🖼️ **Carpeta `assets/`**

assets/
├── images/ # Imágenes PNG, JPG, SVG
│ ├── logo.png
│ ├── onboarding/
│ │ └── welcome_bg.jpg
│ └── destinations/
│ └── placeholder.jpg
│
├── icons/ # Iconos personalizados
│ └── tab_icons/
│ ├── home_selected.png
│ └── home_unselected.png
│
└── fonts/ # Fuentes tipográficas
├── Montserrat-Regular.ttf
└── Montserrat-Bold.ttf


## 🚀 Configuración Inicial

### Prerrequisitos
- Flutter SDK 3.16 o superior
- Dart SDK 3.0 o superior
- Cuenta en Supabase (gratuita)

### Pasos para desarrolladores

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-org/turismo-bolivia.git
cd turismo-bolivia

2. **Configurar variables de entorno**

cp .env.template .env
# Editar .env con tus credenciales de Supabase

3. obtener dependecias
   flutter pub get