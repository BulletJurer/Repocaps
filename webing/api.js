// api.js
// Módulo para centralizar todas las llamadas a la API del servidor
// Permite cambiar el endpoint base en un solo lugar y facilita mantenimiento

// 🔍 Detecta si estamos en entorno local o remoto
const isLocal = ["localhost", "127.0.0.1"].includes(window.location.hostname) ||
                window.location.hostname.startsWith("192.168.");

// URL base de la API
export const API_BASE_URL = isLocal ? "http://localhost:3000" : "https://testeorepocaps.loca.lt";

// -------------------- FUNCIONES DE LA API -------------------- //

// 🔐 LOGIN
// Recibe usuario y contraseña, devuelve un objeto con empleado y token
export async function login(usuario, contrasena) {
  try {
    const response = await fetch(`${API_BASE_URL}/api/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ usuario, contrasena })
    });

    const data = await response.json();

    if (!response.ok) {
      // Lanza error con mensaje adecuado si el servidor devuelve error
      throw new Error(data.message || "Error en login");
    }

    return data; // { success: true, empleado: {...}, message: 'Login exitoso' }

  } catch (err) {
    console.error("❌ Error en login:", err);
    throw new Error(err.message || "Error de conexión con el servidor");
  }
}

// 👥 OBTENER LISTA DE EMPLEADOS
export async function getEmpleados() {
  try {
    const response = await fetch(`${API_BASE_URL}/api/empleados`);
    if (!response.ok) throw new Error("No se pudieron cargar los empleados");
    const data = await response.json();
    return data; // Array de empleados
  } catch (err) {
    console.error("❌ Error obteniendo empleados:", err);
    throw new Error(err.message || "Error de conexión con el servidor");
  }
}

// 🩺 ESTADO DEL SERVIDOR
export async function getStatus() {
  try {
    const response = await fetch(`${API_BASE_URL}/api/status`);
    if (!response.ok) throw new Error("Error obteniendo estado del servidor");
    const data = await response.json();
    return data; // { status: ..., base_datos: ... }
  } catch (err) {
    console.error("❌ Error obteniendo estado del servidor:", err);
    throw new Error(err.message || "Error de conexión con el servidor");
  }
}

// 📊 FUTURAS FUNCIONES (estadísticas, vehículos, etc.)
export async function getEstadisticas() {
  try {
    const response = await fetch(`${API_BASE_URL}/api/estadisticas`);
    if (!response.ok) throw new Error("Error obteniendo estadísticas");
    const data = await response.json();
    return data; // { vehiculos:..., taller:..., proceso:..., empleados:... }
  } catch (err) {
    console.error("❌ Error obteniendo estadísticas:", err);
    throw new Error(err.message || "Error de conexión con el servidor");
  }
}

// 🚪 CERRAR SESIÓN
// Limpia localStorage y redirige al login
export function cerrarSesion() {
  localStorage.removeItem("usuario");
  localStorage.removeItem("token");
  window.location.href = "inicio-sesion.html";
}
