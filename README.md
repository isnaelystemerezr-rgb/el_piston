# El Pistón – Gestión de taller automotriz

Aplicación móvil (Flutter) para llevar el trabajo diario de un taller mecánico de barrio:
clientes, vehículos, órdenes de servicio, trabajos, repuestos, inventario y cobros.
**Funciona sin conexión** y **conserva los datos al cerrar la app** (SQLite local con Drift).

## Cómo ejecutarlo

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera los *.g.dart de Drift
flutter run
flutter test                                                # pruebas de la lógica de negocio
```

## Pantallas

| Pantalla | Qué resuelve |
|---|---|
| **Panel** | Indicadores: órdenes abiertas, total por cobrar y repuestos por agotarse; acceso rápido a "Nueva orden". |
| **Órdenes** | Órdenes abiertas con vehículo, cliente, mecánico y estado; filtro por estado. |
| **Nueva orden** | Registra cliente + vehículo + orden en un solo formulario (reutiliza cliente por teléfono y vehículo por matrícula, con autocompletado). |
| **Detalle de orden** | Cambio de estado, trabajos (mano de obra), repuestos usados, pagos parciales, total y saldo. |
| **Clientes / Vehículos** | Búsqueda, historial de servicios y saldo pendiente de un cliente o de un vehículo. |
| **Inventario** | Existencias con alerta de stock bajo, alta de repuestos y reposición. |
| **Mecánicos** | Cuántas órdenes abiertas tiene cada mecánico y cuáles son. |
| **Reportes** | Facturado y cobrado en un período elegido, deuda por cliente y repuestos por agotarse. |

## Decisiones de diseño

- **Persistencia:** Drift sobre SQLite → los datos sobreviven al cierre de la app y no se necesita internet.
- **Arquitectura por capas:** `data/` (tablas, DAO, reglas de negocio) · `viewmodels/` · `views/`.
  La lista de órdenes usa un `ViewModel` (`ChangeNotifier`); el resto de pantallas consumen los *streams*
  reactivos del DAO mediante `Provider`, de modo que la UI se actualiza sola cuando cambian los datos.
  Las vistas **no escriben SQL ni construyen consultas**: todo pasa por métodos con nombre del DAO.
- **Estados de la orden:** `enum EstadoOrden` (recibida, en diagnóstico, en reparación, lista para entregar,
  entregada, cancelada). Se guarda su texto en la BD. Entregada y cancelada son estados finales.
- **Reglas de negocio en el DAO (con transacciones):**
  - Usar un repuesto descuenta el stock y recalcula el total de la orden; si no hay stock suficiente no se hace nada.
  - Cancelar una orden devuelve los repuestos al inventario.
  - Un pago no puede superar el saldo pendiente; se admiten pagos parciales.
  - Una orden cerrada no admite nuevos trabajos ni repuestos (sí pagos, si quedó saldo).
  - Al entregar se guarda la fecha de salida.
- **Integridad:** claves foráneas activadas (`PRAGMA foreign_keys = ON`), 8 tablas normalizadas.
- **Decisiones sobre puntos abiertos del enunciado:**
  - *Repuesto por agotarse:* 5 unidades o menos (`core/constantes.dart`); se avisa en el panel, el inventario y los reportes.
  - *Facturado:* suma de mano de obra + repuestos de las órdenes no canceladas con fecha de entrada en el período; se muestra también lo *cobrado*.
  - *Saldo:* total de la orden − pagos; las órdenes canceladas no generan deuda.
  - *Mecánico con carga alta:* más de 4 órdenes abiertas.
- **UX:** Material 3, interfaz en español (incluido el selector de fechas), validación de formularios, aceptan coma o
  punto decimal, mensajes claros ante errores de negocio, buscadores, y datos iniciales (2 mecánicos y 5 repuestos).

## Estructura

```
lib/
  core/        constantes y formato (dinero, fechas)
  data/        tables.dart · app_database.dart · seed.dart · estado_orden.dart · daos/ordenes_dao.dart
  viewmodels/  ordenes_viewmodel.dart
  views/       home · ordenes · clientes · vehiculos · inventario · mecanicos · reportes · widgets
test/          pruebas de la lógica de negocio (BD en memoria)
capturas/      capturas de pantalla de la aplicación en uso
```

## Capturas

Ver la carpeta [`capturas/`](capturas/).

## Créditos

Actividad de *Programación para Dispositivos Móviles* – Ing. Roilán Rodríguez Castillo.
