# Directorio App (Flutter)

Directorio de usuarios que consume la API pública [JSONPlaceholder](https://jsonplaceholder.typicode.com).

- Lista de usuarios con nombre, correo y empresa (`/users`).
- Detalle con datos del usuario y sus publicaciones (`/posts?userId={id}`).
- Favoritos guardados en el teléfono con `shared_preferences`; se ven sin conexión.
- Estados de carga, éxito, error y sin Internet, con botón **Reintentar**.
- Arquitectura MVVM por capas: `ui` (pantallas y ViewModels) → `data` (repositorios, API y almacenamiento local).

## Cómo ejecutarlo en VS Code

Requisitos: Flutter 3.24 o superior, la extensión **Flutter** de VS Code y un emulador o teléfono Android.

1. Abre esta carpeta en VS Code.
2. En la terminal, genera los archivos de plataforma que faltan (no reemplaza los que ya existen, como `lib/` o el `AndroidManifest.xml`):

   ```bash
   flutter create --project-name directorio_app --org com.example --platforms android .
   ```

3. Descarga las dependencias y ejecuta la app:

   ```bash
   flutter pub get
   flutter run
   ```

4. (Opcional) Ejecuta las pruebas:

   ```bash
   flutter test
   ```

## Cómo ver cada estado

| Estado | Cómo reproducirlo |
|---|---|
| Carga | Abre la app; el indicador aparece mientras llega la lista. |
| Éxito | Con Internet, la lista se muestra completa. |
| Sin conexión | Activa el modo avión y abre la app (o toca **Reintentar**). |
| Favoritos sin conexión | Marca usuarios con la estrella, activa el modo avión y abre la pestaña **Favoritos**. |
| Reintento automático | Con el error en pantalla, desactiva el modo avión y vuelve a la app: la lista se recarga sola. |

## Estructura

```
lib/
├── main.dart                         # arranque, dependencias y manejo global de errores
├── core/
│   ├── app_exception.dart            # errores controlados (sin Internet, servidor, datos...)
│   └── ui_state.dart                 # estados: carga, éxito, error
├── data/
│   ├── models/                       # User, Post (fromJson / toJson)
│   ├── remote/api_service.dart       # consumo de la API con http
│   ├── local/favorites_local_data_source.dart  # persistencia con shared_preferences
│   └── repositories/                 # UserRepository, FavoritesRepository
└── ui/
    ├── viewmodels/                   # UsersViewModel, UserDetailViewModel, FavoritesViewModel
    ├── screens/                      # Home, Usuarios, Detalle, Favoritos
    └── widgets/                      # estados (carga/error/vacío), fila de usuario, estrella
```
